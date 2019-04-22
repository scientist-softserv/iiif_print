FactoryBot.define do
  factory :newspaper_page_solr_document, class: SolrDocument do
    initialize_with do
      new(id: '123456',
          title_tesim: ['Page 1'],
          has_model_ssim: ['NewspaperPage'],
          thumbnail_path_ss: '/downloads/123456?file=thumbnail')
    end
  end
end
