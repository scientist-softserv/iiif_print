module IiifPrint
  module Jobs
    # Break a pdf into individual pages
    class CreateRelationshipsJob < IiifPrint::Jobs::ApplicationJob
      # @param parent_id [String] Work ID
      def perform(user:, parent_id:, parent_model:, child_count:, child_model:)
        if completed_child_data_for(parent_id, child_count, child_model)
          # add the members
          parent_work = parent_model.constantize.find(parent_id)
          create_relationships(user: user, parent: parent_work, ordered_child_ids: @child_ids)
          @pending_children.each(&:destroy)
        else
          # reschedule the job and end this one normally
          reschedule(user: user, parent_id: parent_id, parent_model: parent_model, child_count: child_count, child_model: child_model)
        end
      end

      private

      # check of all child works have been created
      def completed_child_data_for(parent_id, child_count, child_model)
        # find pending children and verify the quantity is correct (BatchCreateJobs completed)
        @pending_chilren = IiifPrint::PendingRelationship.where(parent_id: parent_id).sort_by(:order)
        return false unless @pending_children.count == child_count

        # find child ids and verify the quantity is correct (CreateChildWork jobs completed)
        @child_ids = []
        @pending_children.each do |pending_child|
          @child_ids << find_id_by_title_for(pending_child.child_title, child_model)
        end
        return false unless @child_ids.count == child_count

        true
      end

      def find_id_by_title_for(title, model)
        model.constantize.where(title: title).map(&:id)
      end

      def reschedule(user:, parent_id:, parent_model:, child_count:, child_model:)
        CreateRelationshipsJob.set(wait: 10.minutes).perform_later(
          user: user,
          parent_id: parent_id,
          parent_model: parent_model,
          child_count: child_count,
          child_model: child_model
        )
      end

      def create_relationships(user:, parent:, ordered_child_ids:)
          records_hash = {}
          ordered_child_ids.each_with_index do |child_id, i|
            records_hash[i] = { id: child_id }
          end
          attrs = { work_members_attributes: records_hash }
          parent.try(:reindex_extent=, Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX)
          env = Hyrax::Actors::Environment.new(parent, Ability.new(user), attrs)
  
          Hyrax::CurationConcern.actor.update(env)
      end
    end
  end
end
