module IiifPrint
  # generic/base IiifPrint-specific exception:
  class IiifPrintError < StandardError
  end

  # Data transformation or read-error:
  class DataError < IiifPrintError
  end

  class MissingFileError < IiifPrintError
  end
end
