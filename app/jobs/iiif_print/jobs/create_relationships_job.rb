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
          found_children = find_children_by_title_for(child.child_title, @child_model)
          found_all_children = false if found_children.empty?
          break unless found_all_children == true
          @child_works += found_children
        end
        # return boolean
        found_all_children
      end

      def find_children_by_title_for(title, model)
        work_type = model.constantize
        if work_type.respond_to?(:where)
          # We should only find one, but there is no guarantee of that and `:where` returns an array.
          work_type.where(title: title)
        else
          # TODO: This creates a hard dependency on Bulkrax because that is where this custom query is defined
          #       Is this adequate?
          Array.wrap(Hyrax.query_service.custom_query.find_by_model_and_property_value(model: work_type,
                                                                                       property: :title,
                                                                                       value: title))
        end
      end

      def add_children_to_parent
        parent_work = Hyrax.query_service.find_by(id: @parent_id)
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
            if parent.respond_to?(:save!)
              parent.save!
            else
              Hyrax.persister.save(resource: parent)
            end
          end
        end

        # Bulkrax no longer reindexes file_sets, but IiifPrint needs both to add is_page_of_ssim for universal viewer.
        # This is where child works need to be indexed (AFTER the parent save), as opposed to how Bulkrax does it.
        ordered_children.each do |child_work|
          if child_work.respond_to?(:update_index)
            child_work.update_index
            child_work.file_sets.each(&:update_index) if child_work.respond_to?(:file_sets)
          else
            Hyrax.index_adapter.save(resource: child_work)
            Hyrax.custom_queries.find_child_file_sets(resource: child_work).each do |file_set|
              Hyrax.index_adapter.save(resource: file_set)
            end
          end
        end
      end

      def add_to_work(child_record:, parent_record:)
        if parent_record.respond_to?(:ordered_members)
          return true if parent_record.ordered_members.to_a.include?(child_record)

          parent_record.ordered_members << child_record
          @parent_record_members_added = true
          # Bulkrax does child_record.save! here, but it makes no sense
          # as there is nothing to save or index at this point.
        else
          return true if parent_record.member_ids.include?(child_record.id)

          parent_record.member_ids << child_record.id
          Hyrax.persister.save(resource: parent_record)
          Hyrax.index_adapter.save(resource: parent_record)
        end
      end
    end
  end
end
