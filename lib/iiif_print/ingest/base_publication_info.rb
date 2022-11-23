module NewspaperWorks
  module Ingest
    class BasePublicationInfo
      attr_accessor :lccn, :issn

      def initialize(lccn)
        @lccn = lccn
        load
      end

      def load
        raise NotImplementedError, "abstract"
      end

      # Return normalized, prefixed OCLC number from numeric Integer or
      #   String inputs; prefxes based on number of digits, leaves any
      #   prefix in input unchanged.
      # @param oclcnum [String, Integer] prefixed or unprefixed OCLC control #
      # @return [String] normalized, prefixed OCLC number
      def oclc_prefixed(oclcnum)
        # unprefixed number, as string
        digits = oclcnum.to_s.gsub(/[A-Za-z]/, '')
        return "ocm#{digits}" if digits.size == 8
        return "ocn#{digits}" if digits.size == 9
        "on#{digits}"
      end

      def place_name_from_title(title)
        parts = title.split(/ [\(]/)
        return if parts.size < 2
        parts[1].split(')')[0]
      end
    end
  end
end
