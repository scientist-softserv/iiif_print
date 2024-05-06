# rubocop:disable Metrics/ClassLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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
          elsif @number_of_failures.zero? && @number_of_successes > @pending_children.count
            # remove pending relationships but raise error that too many relationships formed
            @pending_children.each(&:destroy)
            raise "CreateRelationshipsJob for parent id: #{@parent_id} " \
                  "added #{@number_of_successes} children, " \
                  "expected #{@pending_children.count} children."
          else
            # report failures & keep pending relationships
            raise "CreateRelationshipsJob failed for parent id: #{@parent_id} " \
                  "had #{@number_of_successes} successes & #{@number_of_failures} failures, " \
                  "with errors: #{@errors}. Wanted #{@pending_children.count} children."
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
          found_children = IiifPrint.find_by_title_for(title: child.child_title, model: @child_model)
          found_all_children = false if found_children.empty?
          break unless found_all_children == true
          @child_works += found_children
        end
        # return boolean
        found_all_children
      end

      def add_children_to_parent
        parent_work = IiifPrint.find_by(id: @parent_id)
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

          if @parent_record_members_added && @number_of_failures.zero?
            IiifPrint.save(object: parent)
          end
        end

        # Bulkrax no longer reindexes file_sets, but IiifPrint needs both to add is_page_of_ssim for universal viewer.
        # This is where child works need to be indexed (AFTER the parent save), as opposed to how Bulkrax does it.
        IiifPrint.index_works(objects: ordered_children)
      end

      def add_to_work(child_record:, parent_record:)
        @parent_record_members_added = IiifPrint.create_relationship_between(child_record: child_record, parent_record: parent_record)
      end
    end
  end
  # rubocop:enable Metrics/ClassLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
