# Generated via
#  `rails generate hyrax:work NewspaperTitle`
module Hyrax
  class NewspaperTitlePresenter < Hyrax::WorkShowPresenter
    include NewspaperWorks::NewspaperCorePresenter
    delegate :edition, :frequency, :preceded_by, :succeeded_by, to: :solr_document

    def issues
      all_title_issues.select { |issue| year_or_nil(issue["publication_date_dtsim"]) == year }
    end

    def issue_years
      all_title_issue_dates.map { |issue| year_or_nil(issue) }.compact.uniq.sort
    end

    def prev_year
      return nil if issue_years.empty?
      index = issue_years.index(year) - 1
      return nil if index.negative?
      issue_years[index]
    end

    def next_year
      return nil if issue_years.empty?
      issue_years[issue_years.index(year) + 1]
    end

    def publication_date_start
      solr_document["publication_date_start_dtsim"]
    end

    def publication_date_end
      solr_document["publication_date_end_dtsim"]
    end

    def year
      return nil if issue_years.empty?
      number_or_nil(request.params[:year]) || issue_years.first
    end

    def all_title_issues
      issue_query = Blacklight.default_index.search(q: "has_model_ssim:NewspaperIssue AND publication_id_ssi:#{id} AND visibility_ssi:#{solr_document.visibility}",
                                                    rows: 50_000,
                                                    fl: "id, publication_date_dtsim")
      issue_query.documents
    end

    def publication_unique_id
      solr_document[NewspaperWorks.config.publication_unique_id_field]
    end

    def persistent_url
      return nil unless publication_unique_id
      NewspaperWorks::Engine.routes.url_helpers.newspaper_title_url(unique_id: publication_unique_id.first,
                                                                    host: request.host)
    end

    private

      def all_title_issue_dates
        all_title_issues.pluck("publication_date_dtsim")
      end

      def number_or_nil(string)
        Integer(string || '')
      rescue ArgumentError
        nil
      end

      def year_or_nil(date_array)
        return nil unless date_array.is_a?(Array)
        Date.parse(date_array.first).year
      rescue TypeError
        nil
      end
  end
end
