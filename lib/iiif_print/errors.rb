module IiifPrint
  # generic/base IiifPrint-specific exception:
  class IiifPrintError < StandardError
  end

  # Data transformation or read-error:
  class DataError < IiifPrintError
  end

  class MissingFileError < IiifPrintError
  end

  class WorkNotConfiguredToSplitFileSetError < IiifPrintError
    def initialize(file_set:, work:)
      message = "Expected that we would be splitting #{file_set.class} ID=#{file_set&.id} #to_param=#{file_set&.to_param} " \
                "for work #{work.class} ID=#{work&.id} #to_param=#{work&.to_param}.  " \
                "However it was not configured for PDF splitting."
      super(message)
    end
  end

  class UnexpectedMimeTypeError < IiifPrintError
    def initialize(file_set:, mime_type:)
      super "Unexpected mime_type #{mime_type} for #{file_set.class} ID=#{file_set.id.inspect}"
    end
  end
end
