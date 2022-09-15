# customize behavior for IiifSearch
module NewspaperWorks
  module BlacklightIiifSearch
    module AnnotationBehavior
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
        query_terms = query.split(' ').map(&:downcase)
        matches = coords_json['coords'].select do |k, _v|
          k.downcase =~ /(#{query_terms.join('|')})/
        end
        return default_coords if matches.blank?
        coords_array = matches.values.flatten(1)[hl_index]
        return default unless coords_array
        "#xywh=#{coords_array.join(',')}"
      end

      ##
      # return the JSON word-coordinates file contents
      # @return [JSON]
      def fetch_and_parse_coords
        coords = NewspaperWorks::Data::WorkDerivatives.data(from: file_set_id, of_type: 'json')
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
        file_set_ids = document['file_set_ids_ssim']
        raise "#{self.class}: NO FILE SET ID" if file_set_ids.blank?
        file_set_ids.first
      end
    end
  end
end
