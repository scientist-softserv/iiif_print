module IiifPrint
  class TextExtractionDerivativeService < NewspaperPageDerivativeService
    def initialize(file_set)
      super(file_set)
      @alto_path = nil
      @txt_path = nil
    end

    def create_derivatives(src)
      from_alto = IiifPrint::TextFormatsFromALTOService.new(
        file_set
      )
      return from_alto.create_derivatives(src) unless from_alto.alto_path.nil?
      create_derivatives_from_ocr(src)
    end

    def create_derivatives_from_ocr(filename)
      @source_path = filename
      # prepare destination directory for ALTO (as .xml files):
      @alto_path = prepare_path('xml')
      # prepare destination directory for plain text (as .txt files):
      @txt_path = prepare_path('txt')
      # prepare destination directory for flat JSON (as .json files):
      @json_path = prepare_path('json')
      ocr = IiifPrint::TextExtraction::PageOCR.new(filename)
      # OCR will run once, on first method call to either .alto or .plain:
      write_plain_text(ocr.plain)
      write_alto(ocr.alto)
      write_json(ocr.word_json)
    end

    def write_alto(xml)
      File.open(@alto_path, 'w') do |outfile|
        outfile.write(xml)
      end
    end

    def write_plain_text(text)
      File.open(@txt_path, 'w') do |outfile|
        outfile.write(text)
      end
    end

    def write_json(text)
      File.open(@json_path, 'w') do |outfile|
        outfile.write(text)
      end
    end

    def cleanup_derivatives
      super('txt')
      super('xml')
      super('json')
    end
  end
end
