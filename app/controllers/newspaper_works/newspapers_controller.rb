module NewspaperWorks
  class NewspapersController < ApplicationController
    include NewspaperWorks::PageOrder
    # Adds Hyrax behaviors to the controller.
    #include Hyrax::WorksControllerBehavior
    #include Hyrax::BreadcrumbsForWorks
    #self.curation_concern_type = ::NewspaperArticle

    # Use this line if you want to use a custom presenter
    #self.show_presenter = Hyrax::NewspaperArticlePresenter

    # TODO: use a SearchBuilder for this?
    # might be needed for permissions checking, etc.
    before_action :title_id
    before_action :issue_id, only: [:issue, :page]

    def title
      redirect_to_object(@title_id, 'hyrax_newspaper_title_path')
    end

    def issue
      redirect_to_object(@issue_id, 'hyrax_newspaper_issue_path')
    end

    def page
      @page_id = page_id(@issue_id, params[:page])
      redirect_to_object(@page_id, 'hyrax_newspaper_page_path')
    end

    private

    def redirect_to_object(id, path)
      id ? redirect_to(main_app.send(path, id)) : bad_url_handler
    end

    def bad_url_handler
      #raise(ActionController::RoutingError, 'Not Found')
      redirect_to main_app.root_path,
                  alert: "Item not found",
                  status: 404
    end

    def title_id
      unique_id_field = 'lccn_sim' # TODO set unique_id_field from config
      solr_params = ["has_model_ssim:\"NewspaperTitle\""]
      solr_params << "#{unique_id_field}:\"#{params[:unique_id]}\""
      @title_id = find_object_id(solr_params.join(' AND '))
    end

    def issue_id
      solr_params = ["has_model_ssim:\"NewspaperIssue\""]
      solr_params << "publication_id_ssi:\"#{@title_id}\""
      solr_params << "publication_date_dtsim:\"#{params[:date]}T00:00:00Z\""
      solr_params << "edition_tesim:\"#{edition_for_search(params[:edition])}\""
      @issue_id = find_object_id(solr_params.join(' AND '))
    end

    def page_id(issue_id, pagenum)
      page_index = pagenum_to_index(pagenum)
      solr_params = ["has_model_ssim:\"NewspaperPage\""]
      solr_params << "issue_id_ssi:\"#{issue_id}\""
      solr_resp = Blacklight.default_index.search(fq: solr_params.join(' AND '))
      docs = solr_resp.documents
      return nil if docs.blank? || docs[page_index].blank?
      pages = ordered_pages(solr_resp.documents)
      pages[page_index]['id']
    end

    def find_object_id(solr_params)
      solr_resp = Blacklight.default_index.search(fq: solr_params)
      return nil unless solr_resp.documents.count == 1
      solr_resp.documents.first['id']
    end

    def edition_for_search(edition)
      return '1' if edition.nil?
      edition = edition.gsub(/\Aed-/, '')
      return '1' unless edition.to_i.positive?
      edition
    end

    def pagenum_to_index(pagenum)
      page_i = pagenum.gsub(/\Aseq-/, '').to_i
      (page_i - 1).negative? ? 0 : (page_i - 1)
    end
  end
end
