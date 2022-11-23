module IiifPrint
  module Ingest
    module NDNP
      class ContainerMetadata
        include IiifPrint::Ingest::NDNP::NDNPMetsHelper

        attr_accessor :path, :doc

        def initialize(path, parent = nil)
          @path = path
          @parent = parent
          @doc = nil
          load_doc
        end

        def inspect
          format(
            "<#{self.class}:0x000000000%<oid>x\n" \
              "\tpath: '#{path}',\n",
            oid: object_id << 1
          )
        end

        # Reel Number (NDNP-mandatory)
        # @return [String] a serial number string for reel, may correspond
        #   to an issued barcode
        def reel_number
          v = xpath("//mods:identifier[@type='reel number']").first
          return v.text unless v.nil?
          xpath('//mets:mets/@LABEL').first.value
        end

        # Original Source Repository (NDNP-mandatory)
        # @return [String]
        def held_by
          v = xpath("//mods:physicalLocation").first
          return v['displayLabel'] unless v.nil?
          # fallback to look at mods:note/@displayLabel, when the
          #   @type="agencyResponsibleForReproduction"
          xpath(
            '//mods:note[@type="agencyResponsibleForReproduction"]' \
            '/@displayLabel'
          ).first.value
        end

        # Media genre/form (Page Physical Description, e.g. "microform")
        #   NDNP Mandatory.
        # @return [String]
        def genre
          form = xpath('//mods:physicalDescription/MODS:form').first
          form.attributes['type'].value
        end

        # Titles (on Reel) (optional)
        # @return [String] title
        def title
          techmd('ndnp:titles')
        end

        # Start Date (optional)
        # @return [String] ISO 8601 formatted date
        def publication_date_start
          techmd('ndnp:startDate')
        end

        # End Date (optional)
        # @return [String] ISO 8601 formatted date
        def publication_date_end
          techmd('ndnp:endDate')
        end

        private

        def load_doc
          @doc = @parent.doc unless @parent.nil?
          @doc = Nokogiri::XML(File.open(path)) if @doc.nil?
        end

        def techmd(spec = nil)
          base = xpath('//ndnp:reelTechMD')
          return base if spec.nil?
          base.xpath(spec).first.text
        end
      end
    end
  end
end
