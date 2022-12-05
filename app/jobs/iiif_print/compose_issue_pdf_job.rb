module IiifPrint
  # Compose and attach a multi-page PDF from constituent pages, if ready
  #   (if not ready, job retry requires Rails >= 5.1)
  class ComposeIssuePDFJob < IiifPrint::ApplicationJob
    retry_on IiifPrint::PagesNotReady,
             wait: :exponentially_longer,
             attempts: 8

    def perform(issue)
      IiifPrint::IssuePDFComposer.new(issue).compose
    end
  end
end
