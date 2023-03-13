require 'open3'
require 'securerandom'
require 'tmpdir'
require 'iiif_print/split_pdfs/pdf_image_extraction_service'

module IiifPrint
  module SplitPdfs
    # @abstract
    #
    # The purpose of this class is to split the PDF into constituent image files.
    #
    # @see #each
    class BaseSplitter
      class_attribute :image_extension
      class_attribute :compression, default: nil
      class_attribute :quality, default: nil

      def initialize(path, tmpdir: Dir.mktmpdir, default_dpi: 400)
        @baseid = SecureRandom.uuid
        @pdfpath = path
        @pdfinfo = IiifPrint::SplitPdfs::PdfImageExtractionService.new(@pdfpath)
        @tmpdir = tmpdir
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

      attr_reader :pdfinfo, :tmpdir, :baseid, :compression, :default_dpi, :quality
      private :pdfinfo, :tmpdir, :baseid, :default_dpi

      private

      # entries for each page
      def entries
        return @entries if defined? @entries

        @entries = Array.wrap(gsconvert)
      end

      # rubocop:disable Metrics/MethodLength
      # ghostscript convert all pages to TIFF
      def gsconvert
        output_base = File.join(tmpdir, "#{baseid}-page%d.#{image_extension}")
        # NOTE: you must call gsdevice before compression, as compression is
        # updated during the gsdevice call.
        cmd = "gs -dNOPAUSE -dBATCH -sDEVICE=#{gsdevice} -dTextAlphaBits=4"
        cmd += " -sCompression=#{self.class.compression}" if self.class.compression?
        cmd += " -dJPEGQ=#{self.class.quality}" if self.class.quality?
        cmd += " -sOutputFile=#{output_base} -r#{ppi} -f #{@pdfpath}"
        filenames = []

        Open3.popen3(cmd) do |_stdin, stdout, _stderr, _wait_thr|
          page_number = 0
          stdout.read.split("\n").each do |line|
            next unless line.start_with?('Page ')

            page_number += 1
            filenames << File.join(tmpdir, "#{baseid}-page#{page_number}.#{image_extension}")
          end
        end

        filenames
      end
      # rubocop:enable Metrics/MethodLength

      def gsdevice
        raise NotImplementedError
      end

      PAGE_COUNT_REGEXP = %r{^Pages: +(\d+)$}.freeze

      def pagecount
        return @pagecount if defined? @pagecount

        cmd = "pdfinfo #{@pdfpath}"
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

require "iiif_print/split_pdfs/pages_to_jpgs_splitter"
require "iiif_print/split_pdfs/pages_to_pngs_splitter"
require "iiif_print/split_pdfs/pages_to_tiffs_splitter"
