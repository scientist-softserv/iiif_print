# module comment...
module NewspaperWorks
  # core metdata for newspaper models
  module NewspaperCoreMetadata
    extend ActiveSupport::Concern

    included do
      # common metadata for Newspaper title, issue, article; fields
      # that are not in ::Hyrax::BasicMetadata are enumerated here.

      #  - Alternative Title
      property(
          :alternative_title,
          predicate: ::RDF::Vocab::DC.alternative,
          multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      # - Genre
      property(
          :genre,
          predicate: ::RDF::Vocab::EDM.hasType,
          multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      #  - Issued date
      property(
          :issued,
          predicate: ::RDF::Vocab::DC.issued,
          multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      #  - Place of Publication
      property(
          :place_of_publication,
          predicate: ::RDF::Vocab::MARCRelators.pup,
          multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      # Holding location (held by):
      property(
        :held_by,
        predicate: ::RDF::Vocab::BF2.heldBy,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      class_attribute :controlled_properties
      self.controlled_properties = []
    end
  end
end
