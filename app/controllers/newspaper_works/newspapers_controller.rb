module NewspaperWorks
  class NewspapersController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks

    include NewspaperWorks::PageFinder

    before_action :find_title
    before_action :find_issue, only: [:issue, :page]
    before_action :build_breadcrumbs

    def title
      if @title
        params[:id] = @title['id']
        @presenter = Hyrax::NewspaperTitlePresenter.new(@title, current_ability, request)
        render 'hyrax/newspaper_titles/show'
      else
        bad_url_handler
      end
    end

    def issue
      if @issue
        params[:id] = @issue['id']
        @presenter = Hyrax::NewspaperIssuePresenter.new(@issue, current_ability, request)
        render 'hyrax/newspaper_issues/show'
      else
        bad_url_handler
      end
    end

    def page
      @page = find_page
      if @page
        params[:id] = @page['id']
        @presenter = Hyrax::NewspaperPagePresenter.new(@page, current_ability, request)
        render 'hyrax/newspaper_pages/show'
      else
        bad_url_handler
      end
    end

    private

    # override from Hyrax::WorksControllerBehavior
    # or else this evals to 'dashboard'
    def decide_layout
      File.join(theme, '1_column')
    end

    # override from Hyrax::BreadcrumbsForWorks; copy of Hyrax::Breadcrumbs
    # so method gets called despite action_name != 'show'
    def build_breadcrumbs
      if request.referer
        trail_from_referer
      else
        default_trail
      end
    end

    def bad_url_handler
      raise(ActionController::RoutingError, 'Not Found')
    end

    def find_title
      unique_id_field = NewspaperWorks.config.publication_unique_id_field
      solr_params = ["has_model_ssim:\"NewspaperTitle\""]
      solr_params << "#{unique_id_field}:\"#{params[:unique_id]}\""
      @title = find_object(solr_params.join(' AND '))
    end

    def find_issue
      return nil unless @title
      solr_params = ["has_model_ssim:\"NewspaperIssue\""]
      solr_params << "publication_id_ssi:\"#{@title['id']}\""
      solr_params << "publication_date_dtsim:\"#{params[:date]}T00:00:00Z\""
      solr_params << "edition_tesim:\"#{edition_for_search}\""
      @issue = find_object(solr_params.join(' AND '))
    end

    def find_page
      return nil unless @issue
      page_index = pagenum_to_index
      pages = pages_for_issue(@issue['id'])
      return nil if pages.blank? || pages[page_index].blank?
      search_result_document(id: pages[page_index]['id'])
    end

    def find_object(solr_params)
      begin
        solr_resp = Blacklight.default_index.search(fq: solr_params)
      rescue # in case of RSolr::Error, etc.
        return nil
      end
      return nil unless solr_resp.documents.count == 1
      object_id = solr_resp.documents.first['id']
      # we run the search again, to add permissions/access filters
      # invoked by Hyrax::WorkSearchBuilder
      search_result_document(id: object_id)
    end

    def edition_for_search
      edition = params[:edition]
      default = '1'
      return default if edition.nil?
      edition = edition.gsub(/\Aed-/, '')
      return default unless edition.to_i.positive?
      edition
    end

    def pagenum_to_index
      page_i = params[:page].gsub(/\Aseq-/, '').to_i
      (page_i - 1).negative? ? 0 : (page_i - 1)
    end
  end
end
