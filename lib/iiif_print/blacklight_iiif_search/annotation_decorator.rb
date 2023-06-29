# customize behavior for IiifSearch
module IiifPrint
  module BlacklightIiifSearch
    module AnnotationDecorator
      ##
      # Create a URL for the annotation
      # use a Hyrax-y URL syntax:
      # protocol://host:port/concern/model_type/work_id/manifest/canvas/file_set_id/annotation/index
      # @return [String]
      def annotation_id
        "#{base_url}/manifest/canvas/#{file_set_id}/annotation/#{hl_index}"
      end

      ##
      # Create a URL for the canvas that the annotation refers to
      # match the Hyrax default canvas URL syntax:
      # protocol://host:port/concern/model_type/work_id/manifest/canvas/file_set_id
      # @return [String]
      def canvas_uri_for_annotation
        "#{base_url}/manifest/canvas/#{file_set_id}#{coordinates}"
      end

      private

      ##
      # return a string like "#xywh=100,100,250,20"
      # corresponding to coordinates of query term on image
      # @return [String]
      def coordinates
        return default_coords if query.blank?
        coords_json = fetch_and_parse_coords
        return default_coords unless coords_json && coords_json['coords']
        sanitized_query = query.match(additional_query_terms_regex)[1].strip
        query_terms = sanitized_query.split(' ').map(&:downcase)
        matches = coords_json['coords'].select do |k, _v|
          k.downcase =~ /(#{query_terms.join('|')})/
        end
        return default_coords if matches.blank?
        coords_array = matches.values.flatten(1)[hl_index]
        return default_coords unless coords_array
        "#xywh=#{coords_array.join(',')}"
      end

      ##
      # return the JSON word-coordinates file contents
      # @return [JSON]
      def fetch_and_parse_coords
        coords = IiifPrint.config.ocr_coords_from_json_function.call(file_set_id: file_set_id, document: document)
        return nil if coords.blank?
        begin
          JSON.parse(coords)
        rescue JSON::ParserError
          nil
        end
      end

      ##
      # a default set of coordinates
      # @return [String]
      def default_coords
        '#xywh=0,0,0,0'
      end

      ##
      # the base URL for the Newspaper object
      # use polymorphic_url, since we deal with multiple object types
      # @return [String]
      def base_url
        host = controller.request.base_url
        controller.polymorphic_url(parent_document, host: host, locale: nil)
      end

      ##
      # return the first file set id
      # @return [String]
      def file_set_id
        return document['id'] if document.file_set?

        file_set_ids = document['file_set_ids_ssim']
        raise "#{self.class}: NO FILE SET ID" if file_set_ids.blank?

        # Since a parent work's `file_set_ids_ssim` can contain child work ids as well as file set ids,
        # this will ensure that the file set id is indeed a `FileSet`
        file_set_ids.detect { |id| SolrDocument.find(id).file_set? }
      end

      ##
      # This method is a workaround to compensate for overriding the solr_params method in
      # BlacklightIiifSearch::IiifSearch. In the override, the solr_params method adds an additional filter to the query
      # to include either the object_relation_field OR the parent document's id and removes the :f parameter from the
      # query. This resulted in the query split here returning more than the actual query term.
      #
      # @see IiifPrint::IiifSearchDecorator#solr_params
      # @return [Regexp] A regular expression to find the last AND and everything after it
      # @example
      #   'foo AND (is_page_of_ssim:\"123123\" OR id:\"123123\")' #=> 'foo'
      def additional_query_terms_regex
        /(.*)(?= AND (\(.+\)|\w+)$)/
      end
    end
  end
end
