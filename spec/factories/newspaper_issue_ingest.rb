FactoryBot.define do
  factory :newspaper_issue_ingest, class: IiifPrint::Ingest::NewspaperIssueIngest do
    newspaper_issue
    initialize_with { new(newspaper_issue) }
  end
end
