# Generated via
#  `rails generate hyrax:work NewspaperArticle`
module Hyrax
  class NewspaperArticlePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    include NewspaperWorks::ScannedMediaPresenter
    include NewspaperWorks::TitleInfoPresenter
    include NewspaperWorks::IssueInfoPresenter
    include NewspaperWorks::IiifSearchPresenterBehavior

    delegate :author, :photographer, :volume, :edition, :issue_number,
             :geographic_coverage, :extent, :genre, to: :solr_document

    def publication_date
      solr_document["publication_date_dtsim"]
    end

    def page_ids
      solr_document['page_ids_ssim']
    end

    def page_titles
      solr_document['page_titles_ssim']
    end
  end
end
