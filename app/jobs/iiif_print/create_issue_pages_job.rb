module IiifPrint
  # Create child page works for issue
  class CreateIssuePagesJob < IiifPrint::ApplicationJob
    def perform(work, _pdf_paths, user, admin_set_id)
      # we will need depositor set on work, if it is nil
      work.depositor ||= user
      # if we do not have admin_set_id yet, set it on the issue work:
      work.admin_set_id ||= admin_set_id
      # create child pages for each page within each PDF uploaded:
      # TODO need to reimplement this w/o it being tied up with
      # the otherwise un-needed ingest work
      # pdf_paths.each do |path|
      #   adapter = IiifPrint::Ingest::NewspaperIssueIngest.new(work)
      #   adapter.load(path)
      #   adapter.create_child_pages
      # end
      # re-save pages so that parent and sibling relationships are indexed
      # work.pages.each(&:save)
    end
  end
end
