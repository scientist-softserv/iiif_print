module IiifPrint
  module Jobs
    # Break a pdf into individual pages
    class CreateRelationshipsJob < IiifPrint::Jobs::ApplicationJob
      # Link newly created child works to the parent
      # @param user: [User] user
      # @param parent_id: [<String>] parent work id
      # @param parent_model: [<String>] parent model
      # @param child_model: [<String>] child model
      def perform(user:, parent_id:, parent_model:, child_model:)
        if completed_child_data_for(parent_id, child_model)
          # add the members
          parent_work = parent_model.constantize.find(parent_id)
          create_relationships(user: user, parent: parent_work, ordered_child_ids: @child_ids)
          @pending_children.each(&:destroy)
        else
          # reschedule the job and end this one normally
          #
          # TODO: Depending on how things shake out, we could be infinitely rescheduling this job.
          # Consider a time to live parameter.
          reschedule(user: user, parent_id: parent_id, parent_model: parent_model, child_model: child_model)
        end
      end

      private

      # load @child_ids, and return true or false
      def completed_child_data_for(parent_id, child_model)
        @child_ids = []
        found_all_children = true

        # find and sequence all pending children
        @pending_children = IiifPrint::PendingRelationship.where(parent_id: parent_id).order('child_order asc')

        # find child ids (skip out if any haven't yet been created)
        @pending_children.each do |child|
          # find by title... if any aren't found, the child works are not yet ready
          found_child = find_children_by_title_for(child.child_title, child_model).map(&:id)
          found_all_children = false if found_child.empty?
          break unless found_all_children == true
          @child_ids += found_child
        end
        # return boolean
        found_all_children
      end

      def find_children_by_title_for(title, model)
        @child_works = model.constantize.where(title: title)
      end

      def reschedule(user:, parent_id:, parent_model:, child_model:)
        CreateRelationshipsJob.set(wait: 10.minutes).perform_later(
          user: user,
          parent_id: parent_id,
          parent_model: parent_model,
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
        # need to reindex all file_sets to make sure 
        @child_works.each do |child_record|
          child_record.file_sets.each(&:update_index) if child_record.respond_to?(:file_sets)
        end
      end
    end
  end
end
