module IiifPrint
  # generic/base IiifPrint-specific exception:
  class IiifPrintError < StandardError
  end

  # Data transformation or read-error:
  class DataError < IiifPrintError
  end

  # Specific exception for temporary state where one or more PDF page source
  #   files are not ready, for which a retry at a later time is warranted.
  class PagesNotReady < DataError
  end
end
