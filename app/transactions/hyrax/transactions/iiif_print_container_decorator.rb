# frozen_string_literal: true

module Hyrax
  module Transactions
    ##
    # This decorator does the following:
    #
    # - Prepend the {ConditionallyDestroyChildrenFromSplit} transaction to the "file_set.destroy"
    #   step.  The prependment corresponds to the behavior for
    #   {IiifPrint::Actors::FileSetActorDecorator#destroy}
    #
    # For more information about adjusting transactions, see
    # [Transitioning workshop solution for adding transaction](https://github.com/samvera-labs/transitioning-to-valkyrie-workshop/commit/bcab2bb8f65078e88395c68f72be00e7ffad57ec)
    #
    # @see https://github.com/samvera/hyrax/blob/f875d61dc87229cf1f05eb2bb6d414b5ef314616/lib/hyrax/transactions/container.rb
    class IiifPrintContainerDecorator
      extend Dry::Container::Mixin

      namespace 'file_set' do |ops|
        ops.register 'iiif_print_conditionally_destroy_spawned_children' do
          Steps::ConditionallyDestroyChildrenFromSplit.new
        end
        ops.register 'destroy' do
          Hyrax::Transactions::FileSetDestroy.new(
            steps: (['file_set.iiif_print_conditionally_destroy_spawned_children'] +
              Hyrax::Transactions::FileSetDestroy::DEFAULT_STEPS)
          )
        end
      end

      namespace 'change_set' do |ops|
        ops.register 'update_work' do
          steps = Hyrax::Transactions::WorkUpdate::DEFAULT_STEPS.dup
          steps.insert(steps.index('work_resource.update_work_members') + 1, 'work_resource.set_child_flag')
          Hyrax::Transactions::WorkUpdate.new(steps: steps)
        end
      end

      namespace 'work_resource' do |ops|
        ops.register 'set_child_flag' do
          Steps::SetChildFlag.new
        end
      end
    end
  end
end

Hyrax::Transactions::Container.merge(Hyrax::Transactions::IiifPrintContainerDecorator)
