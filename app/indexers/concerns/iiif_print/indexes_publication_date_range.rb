# indexes the publication_date_start and _end fields
module IiifPrint
  module IndexesPublicationDateRange
    # adds publication date start to solr_doc Hash in Solr datetime format
    #
    # @param pubdate [String] publication start date
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_pubdate_start(pubdate, solr_doc)
      case pubdate
      when /\A\d{4}\z/
        solr_doc['publication_date_start_dtsi'] = "#{pubdate}-01-01".to_datetime
      when /\A\d{4}-\d{2}\z/
        solr_doc['publication_date_start_dtsi'] = "#{pubdate}-01".to_datetime
      end
      solr_doc['publication_date_start_ssi'] = nil
    end

    # adds publication date end to solr_doc Hash in Solr datetime format
    #
    # @param pubdate [String] publication end date
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_pubdate_end(pubdate, solr_doc)
      end_time = 'T23:59:59Z'
      case pubdate
      when /\A\d{4}\z/
        solr_doc['publication_date_end_dtsi'] = "#{pubdate}-12-31#{end_time}"
      when /\A\d{4}-\d{2}\z/
        date_split = pubdate.split('-')
        end_day = Date.new(date_split[0].to_i, date_split[1].to_i, -1).strftime('%d')
        solr_doc['publication_date_end_dtsi'] = "#{pubdate}-#{end_day}#{end_time}"
      end
      solr_doc['publication_date_end_ssi'] = nil
    end
  end
end
