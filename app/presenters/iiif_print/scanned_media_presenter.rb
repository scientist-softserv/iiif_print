# Scanned Media: Shared Metadata
module IiifPrint
  # scanned media metadata for newspaper models (e.g. page, article images)
  module ScannedMediaPresenter
    delegate :text_direction, :page_number, :section, to: :solr_document
  end
end
