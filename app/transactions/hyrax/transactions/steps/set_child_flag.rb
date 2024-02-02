# frozen_string_literal: true

module Hyrax
  module Transactions
    module Steps
      class SetChildFlag
        include Dry::Monads[:result]

        # @see IiifPrint.model_configuration
        def call(resource)
          return Failure(:resource_not_persisted) unless resource.persisted?

          user = ::User.find_by_user_key(resource.depositor)

          Hyrax.custom_queries.find_child_works(resource: resource).each do |child_work|
            # not all child works might have the is_child property that we define when we configure
            # the a model for iiif_print.  see IiifPrint.model_configuration
            #
            # Put another the existence of the is_child property is optional.
            next unless child_work.respond_to?(:is_child)
            next if child_work.is_child
            child_work.is_child = true
            Hyrax.persister.save(resource: child_work)
            Hyrax.publisher.publish('object.metadata.updated', object: child_work, user: user)
          end

          Success(resource)
        end
      end
    end
  end
end
