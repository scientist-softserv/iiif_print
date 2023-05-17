module IiifPrint
  module Jobs
    # Link newly created child works to the parent
    class CreateRelationshipsJob < IiifPrint::Jobs::ApplicationJob
      include Hyrax::Lockable

      RETRY_MAX = 10

      # @param parent_id: [<String>] parent work id
      # @param parent_model: [<String>] parent model
      # @param child_model: [<String>] child model
      # @param retries: [<Integer>] count used during rescheduling to prevent infinite retries
      def perform(parent_id:, parent_model:, child_model:, retries: 0, **)
        @parent_id = parent_id
        @parent_model = parent_model
        @child_model = child_model
        @retries = retries + 1

        @number_of_successes = 0
        @number_of_failures = 0
        @parent_record_members_added = false
        @errors = []

        # Because we need our children in the correct order, we can't create any
        # relationships until all child works have been created.
        if completed_child_data
          # add the members
          add_children_to_parent
          if @number_of_failures.zero? && @number_of_successes == @pending_children.count
            # remove pending relationships upon valid completion
            @pending_children.each(&:destroy)
          else
            raise "CreateRelationshipsJob failed for parent id: #{@parent_id} " \
                  "had #{@number_of_successes} successes & #{@number_of_failures} failures, " \
                  "with errors: #{@errors}"
          end
        else
          # if we aren't ready yet, reschedule the job and end this one normally
          reschedule_job
        end
      end

      private

      # load @child_works and @pending children, and
      # return boolean indicating whether all chilren are present
      def completed_child_data
        @child_works = []
        found_all_children = true

        # find and sequence all pending children
        @pending_children = IiifPrint::PendingRelationship.where(parent_id: @parent_id).order('child_order asc')

        # find child works (skip out if any haven't yet been created)
        @pending_children.each do |child|
          # find by title... if any aren't found, the child works are not yet ready
          found_children = find_children_by_title_for(child.child_title, @child_model)
          found_all_children = false if found_children.empty?
          break unless found_all_children == true
          @child_works += found_children
        end
        # return boolean
        found_all_children
      end

      def find_children_by_title_for(title, model)
        # We should only find one, but there is no guarantee of that and `:where` returns an array.
        model.constantize.where(title: title)
      end

      def add_children_to_parent
        parent_work = @parent_model.constantize.find(@parent_id)
        create_relationships(parent: parent_work, ordered_children: @child_works)
      end

      def reschedule_job
        return if @retries > RETRY_MAX
        CreateRelationshipsJob.set(wait: 10.minutes).perform_later(
          parent_id: @parent_id,
          parent_model: @parent_model,
          child_model: @child_model,
          retries: @retries
        )
      end

      def create_relationships(parent:, ordered_children:)
        acquire_lock_for(parent.id) do
          # Not sure uncached is needed here, but kept
          # for consistency with Bulkrax's relationships logic
          ActiveRecord::Base.uncached do
            ordered_children.each do |child|
              add_to_work(child_record: child, parent_record: parent)
              @number_of_successes += 1
            rescue => e
              @number_of_failures += 1
              @errors << e
            end
          end
          parent.save! if @parent_record_members_added && @number_of_failures.zero?
        end

        # Bulkrax no longer reindexes file_sets, but IiifPrint needs both to add is_page_of_ssim for universal viewer.
        # This is where child works need to be indexed (AFTER the parent save), as opposed to how Bulkrax does it.
        ordered_children.each do |child_work|
          child_work.update_index
          child_work.file_sets.each(&:update_index) if child_work.respond_to?(:file_sets)
        end
      end

      def add_to_work(child_record:, parent_record:)
        return true if parent_record.ordered_members.to_a.include?(child_record)

        parent_record.ordered_members << child_record
        @parent_record_members_added = true
        # Bulkrax does child_record.save! here, but it makes no sense
        # as there is nothing to save or index at this point.
      end
    end
  end
end
