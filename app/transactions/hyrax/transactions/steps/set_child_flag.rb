# frozen_string_literal: true

module Hyrax
  module Transactions
    module Steps
      class SetChildFlag
        include Dry::Monads[:result]

        def call(resource)
          return Failure(:resource_not_persisted) unless resource.persisted?

          user = ::User.find_by_user_key(resource.depositor)

          Hyrax.custom_queries.find_child_works(resource: resource).each do |child_work|
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
