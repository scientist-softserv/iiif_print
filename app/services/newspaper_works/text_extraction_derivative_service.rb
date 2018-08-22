module NewspaperWorks
  class TextExtractionDerivativeService < NewspaperPageDerivativeService
    def initialize(file_set)
      super(file_set)
      @alto_path = nil
      @txt_path = nil
    end

    def create_derivatives(filename)
      @source_path = filename
      # prepare destination directory for ALTO (as .xml files):
      @alto_path = prepare_path('xml')
      # prepare destination directory for plain text (as .txt files):
      @txt_path = prepare_path('txt')
      ocr = NewspaperWorks::TextExtraction::PageOCR.new(filename)
      # OCR will run once, on first method call to either .alto or .plain:
      write_plain_text(ocr.plain)
      write_alto(ocr.alto)
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

    def cleanup_derivatives
      super('txt')
      super('xml')
    end
  end
end
