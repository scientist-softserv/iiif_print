require 'open3'
require 'securerandom'
require 'tmpdir'
require 'iiif_print/split_pdfs/pdf_image_extraction_service'

module IiifPrint
  module SplitPdfs
    # The purpose of this class is to split the PDF into constituent TIFF files.
    #
    # @see #each
    class PagesIntoImagesService
      DEFAULT_COMPRESSION = 'lzw'.freeze
      def initialize(path, compression: DEFAULT_COMPRESSION, tmpdir: Dir.mktmpdir, default_dpi: 400)
        @baseid = SecureRandom.uuid
        @pdfpath = path
        @pdfinfo = IiifPrint::SplitPdfs::PdfImageExtractionService.new(@pdfpath)
        @tmpdir = tmpdir
        @compression = compression
        @default_dpi = default_dpi
      end

      # In creating {#each} we get many of the methods of array operation (e.g. #to_a).
      include Enumerable

      # @api public
      #
      # @yieldparam [String] the path to the page's tiff.
      def each
        entries.each do |e|
          yield(e)
        end
      end

      # @api private
      #
      # TODO: put this test somewhere to prevent invalid pdfs from crashing the image service.
      def invalid_pdf?
        return true if pdfinfo.color.include?(nil) || pdfinfo.width.nil? || pdfinfo.height.nil? || pdfinfo.entries.length.zero?
        false
      end

      attr_reader :pdfinfo, :tmpdir, :baseid, :compression, :default_dpi, :pdfpath
      private :pdfinfo, :tmpdir, :baseid, :compression, :default_dpi, :pdfpath

      private

      # entries for each page
      def entries
        return @entries if defined? @entries

        @entries = Array.wrap(gsconvert)
      end

      # ghostscript convert all pages to TIFF
      def gsconvert
        output_base = File.join(tmpdir, "#{baseid}-page%d.tiff")
        # NOTE: you must call gsdevice before compression, as compression is
        # updated during the gsdevice call.
        cmd = "gs -dNOPAUSE -dBATCH -sDEVICE=#{gsdevice} " \
              "-dTextAlphaBits=4 -sCompression=#{compression} " \
              "-sOutputFile=#{output_base} -r#{ppi} -f #{pdfpath}"
        filenames = []

        Open3.popen3(cmd) do |_stdin, stdout, _stderr, _wait_thr|
          page_number = 0
          stdout.read.split("\n").each do |line|
            next unless line.start_with?('Page ')

            page_number += 1
            filenames << File.join(tmpdir, "#{baseid}-page#{page_number}.tiff")
          end
        end

        filenames
      end

      def gsdevice
        color, channels, bpc = pdfinfo.color
        device = nil
        if color == 'gray'
          # CCITT Group 4 Black and White, if applicable:
          if bpc == 1
            device = 'tiffg4'
            @compression = 'g4'
          elsif bpc > 1
            # 8 Bit Grayscale, if applicable:
            device = 'tiffgray'
          end
        end

        # otherwise color:
        device = colordevice(channels, bpc) if device.nil?
        device
      end

      def colordevice(channels, bpc)
        bits = bpc * channels
        # will be either 8bpc/16bpd color TIFF,
        #   with any CMYK source transformed to 8bpc RBG
        bits = 24 unless [24, 48].include? bits
        "tiff#{bits}nc"
      end

      PAGE_COUNT_REGEXP = %r{^Pages: +(\d+)$}.freeze

      def pagecount
        return @pagecount if defined? @pagecount

        cmd = "pdfinfo #{pdfpath}"
        Open3.popen3(cmd) do |_stdin, stdout, _stderr, _wait_thr|
          match = PAGE_COUNT_REGEXP.match(stdout.read)
          @pagecount = match[1].to_i
        end
        @pagecount
      end

      def ppi
        if looks_scanned?
          # For scanned media, defer to detected image PPI:
          pdfinfo.ppi
        else
          # 400 dpi for something that does not look like scanned media:
          default_dpi
        end
      end

      def looks_scanned?
        max_image_px = pdfinfo.width * pdfinfo.height
        # single 10mp+ image per page?
        single_image_per_page? && max_image_px > 1024 * 1024 * 10
      end

      def single_image_per_page?
        pdfinfo.entries.length == pagecount
      end
    end
  end
end
