# indexes the place_of_publication field
module NewspaperWorks
  module IndexesPlaceOfPublication
    # wrapper for methods for indexing place_of_publication values
    #
    # @param object [Newspaper*] an instance of a NewspaperWorks model
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_pop(object, solr_doc)
      return unless object.respond_to?(:place_of_publication)
      object.place_of_publication.each do |pop|
        next unless pop.is_a?(ActiveTriples::Resource)
        geonames_id = pop.id.match(/[\d]{4,}/).to_s
        geodata = get_geodata(geonames_id)
        return false if geodata.blank?
        add_geodata_fields(solr_doc)
        index_pop_geodata(geodata, solr_doc)
      end
    end

    # adds empty placeholder fields to solr_doc for incoming geodata
    #
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def add_geodata_fields(solr_doc)
      %w[city county state country].each do |place|
        solr_doc["place_of_publication_#{place}_ssim"] ||= []
      end
      solr_doc['place_of_publication_label_tesim'] ||= []
      solr_doc['place_of_publication_llsim'] ||= []
    end

    # adds geographic data to solr_doc Hash, with fields for
    # city, county, state, country, coordinates
    #
    # @param geodata [Hash] hash of GeoNames data returned by #get_geodata
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_pop_geodata(geodata, solr_doc)
      city = geodata['name']
      county = geodata['adminName2']
      state = geodata['adminName1']
      country = geodata['countryName']
      solr_doc['place_of_publication_city_ssim'] << city
      solr_doc['place_of_publication_county_ssim'] << county
      solr_doc['place_of_publication_state_ssim'] << state
      solr_doc['place_of_publication_country_ssim'] << country
      display_name = [city, state, country].compact.join(', ')
      solr_doc['place_of_publication_label_tesim'] << display_name
      return unless geodata['lat'] && geodata['lng']
      # TODO: this should use a Solr location_rpt field type
      solr_doc['place_of_publication_llsim'] << "#{geodata['lat']},#{geodata['lng']}"
    end

    # fetch data from GeoNames API
    #
    # @param geoname_id [String] GeoNames id of geographic entity
    # @return [Hash] GeoNames API response as Hash
    def get_geodata(geoname_id)
      return false if geoname_id.to_i.zero?
      geonames_un = Qa::Authorities::Geonames.username
      return false unless geonames_un
      geonames_url = "http://api.geonames.org/getJSON?geonameId=#{geoname_id}&username=#{geonames_un}"
      resp = Faraday.new(geonames_url).get
      JSON.parse(resp.body)
    end
  end
end
