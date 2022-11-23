module NewspaperWorks
  # generic/base NewspaperWorks-specific exception:
  class NewspaperWorksError < StandardError
  end

  # Data transformation or read-error:
  class DataError < NewspaperWorksError
  end

  # Specific exception for temporary state where one or more PDF page source
  #   files are not ready, for which a retry at a later time is warranted.
  class PagesNotReady < DataError
  end
end
