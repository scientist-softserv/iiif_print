module NewspaperWorks
  # Compose and attach a multi-page PDF from constituent pages, if ready
  #   (if not ready, job retry requires Rails >= 5.1)
  class ComposeIssuePDFJob < NewspaperWorks::ApplicationJob
    retry_on NewspaperWorks::PagesNotReady,
             wait: :exponentially_longer,
             attempts: 8

    def perform(issue)
      NewspaperWorks::IssuePDFComposer.new(issue).compose
    end
  end
end
