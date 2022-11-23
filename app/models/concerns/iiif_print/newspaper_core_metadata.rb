# module comment...
module NewspaperWorks
  # core metadata for newspaper models
  module NewspaperCoreMetadata
    extend ActiveSupport::Concern

    included do
      # common metadata for Newspaper title, issue, article; fields
      # that are not in ::Hyrax::BasicMetadata are enumerated here.

      # - Alternative Title
      property(
        :alternative_title,
        predicate: ::RDF::Vocab::DC.alternative,
        multiple: true
      ) do |index|
        index.as :stored_searchable
      end

      #  - Place of Publication
      property(
        :place_of_publication,
        predicate: ::RDF::Vocab::MARCRelators.pup,
        multiple: true,
        class_name: Hyrax::ControlledVocabularies::Location
      ) do |index|
        index.as :stored_searchable
      end

      # - ISSN
      property(
        :issn,
        predicate: ::RDF::Vocab::Identifiers.issn,
        multiple: false
      ) do |index|
        index.as :stored_searchable, :facetable
      end

      # - LCCN
      property(
        :lccn,
        predicate: ::RDF::Vocab::Identifiers.lccn,
        multiple: false
      ) do |index|
        index.as :stored_searchable, :facetable
      end

      # - OCLC Number
      property(
        :oclcnum,
        predicate: ::RDF::Vocab::BIBO.oclcnum,
        multiple: false
      ) do |index|
        index.as :stored_searchable, :facetable
      end

      # Holding location (held by):
      property(
        :held_by,
        predicate: ::RDF::Vocab::BF2.heldBy,
        multiple: false
      ) do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end
end
