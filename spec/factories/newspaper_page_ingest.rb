FactoryBot.define do
  factory :newspaper_page_ingest, class: NewspaperWorks::Ingest::NewspaperPageIngest do
    newspaper_page
    initialize_with { new(newspaper_page) }
  end
end
