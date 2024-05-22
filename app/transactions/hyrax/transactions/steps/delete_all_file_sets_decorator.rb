# frozen_string_literal: true

# OVERRIDE Hyrax 5.0.0rc2 to add file_set.iiif_print_conditionally_destroy_spawned_children with user args

module Hyrax
  module Transactions
    module Steps
      module DeleteAllFileSetsDecorator
        include Dry::Monads[:result]

        ##
        # @param [Valkyrie::Resource] resource
        # @param [::User] the user resposible for the delete action
        #
        # @return [Dry::Monads::Result]
        def call(resource, user: nil)
          return Failure(:resource_not_persisted) unless resource.persisted?

          @query_service.custom_queries.find_child_file_sets(resource: resource).each do |file_set|
            return Failure[:failed_to_delete_file_set, file_set] unless
              Hyrax::Transactions::Container['file_set.destroy']
              .with_step_args('file_set.remove_from_work' => { user: user },
                              'file_set.delete' => { user: user },
                              'file_set.iiif_print_conditionally_destroy_spawned_children' => { user: user })
              .call(file_set).success?
          rescue ::Ldp::Gone
            nil
          end

          Success(resource)
        end
      end
    end
  end
end

"Hyrax::Transactions::Steps::DeleteAllFileSets".safe_constantize&.prepend(Hyrax::Transactions::Steps::DeleteAllFileSetsDecorator)
