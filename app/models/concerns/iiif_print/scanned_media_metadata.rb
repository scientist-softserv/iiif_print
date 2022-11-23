# Scanned Media: Shared Metadata
module IiifPrint
  # scanned media metadata for newspaper models (e.g. page, article images)
  module ScannedMediaMetadata
    extend ActiveSupport::Concern

    included do
      # common descriptive metadata properties for scanned media like pages
      # that do not already have implementation in Hyrax::BasicMetadata

      # - Label
      #   (implemented by Hyrax::Metadata as :title, we omit here)
      # - Text direction
      property(
        :text_direction,
        predicate: ::RDF::Vocab::OA.textDirection,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # - Page Number
      property(
        :page_number,
        predicate: ::RDF::Vocab::SCHEMA.pagination,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # - Section
      property(
        :section,
        predicate: ::RDF::Vocab::BIBO.section,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # - Reel # TBD TODO needs predicate TBD
    end
  end
end
