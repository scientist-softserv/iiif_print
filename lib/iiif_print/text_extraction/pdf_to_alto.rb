# frozen_string_literal: true

require 'nokogiri'

module IiifPrint
  module TextExtraction
    class PdfToAlto
      def initialize(pdf_path)
        @pdf_path = pdf_path
        @filename = File.basename(pdf_path, File.extname(pdf_path))
        @output_dir = File.join(File.dirname(pdf_path), @filename)
        Dir.mkdir(@output_dir) unless Dir.exist?(@output_dir)
      end

      attr_reader :pdf_path, :filename, :output_dir

      def extract_text
        run_pdfalto

        output_path = File.join(File.dirname(pdf_path), "#{File.basename(pdf_path, '.pdf')}.xml")
        # pdfalto extracts the Alto XML into one big file
        doc = Nokogiri::XML(File.read(output_path))
        # Find all the <Page> elements in the Alto XML file
        pages = doc.xpath('//alto:Page', 'alto' => 'http://www.loc.gov/standards/alto/ns-v3#')
        # Write each page to separate Alto XML files
        extracted_alto_files = save_pages_to_files(pages)

        clean_up!
        extracted_alto_files
      end

      private

      def run_pdfalto
        # Run the pdfalto command line tool to extract the Alto XML from the PDF
        # Assumes that `pdfalto` is in your PATH
        `pdfalto -noImage #{pdf_path}`
      end

      def save_pages_to_files(pages)
        extracted_alto_files = []

        # Write each page to a separate XML file
        pages.each_with_index do |page, index|
          page_output_path = "#{@output_dir}/#{filename}#{index + 1}.xml"
          # Create a new xml document for each page
          page_doc = Nokogiri::XML("<?xml version='1.0' encoding='UTF-8' standalone='yes'?>#{page}")
          File.write(page_output_path, page_doc.to_xml)
          extracted_alto_files << page_output_path
        end

        extracted_alto_files
      end

      def clean_up!
        # Clean up the original and metadata xml files that were created by pdfalto that are no longer needed
        containing_dir = output_dir.gsub(filename, '')
        original_xml, metadata_xml = "#{containing_dir}/#{filename}.xml", "#{containing_dir}/#{filename}_metadata.xml"

        File.delete(original_xml) if File.exist?(original_xml)
        File.delete(metadata_xml) if File.exist?(metadata_xml)
      end
    end
  end
end
