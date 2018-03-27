# Scanned Media: Shared Metadata
module NewspaperWorks
  # scanned media metdata for newspaper models (e.g. page, article images)
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

      # - Height
      property(
        :height,
        predicate: ::RDF::URI.new('http://dbpedia.org/ontology/height'),
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # - Width
      property(
        :width,
        predicate: ::RDF::URI.new('http://dbpedia.org/ontology/width'),
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # - Page Number
      property(
        :pagination,
        predicate: ::RDF::Vocab::SCHEMA.pagination,
        multiple: false
      ) do |index|
        index.as :stored_searchable
      end

      # - Identifier (local)
      property(
        :identifier,
        predicate: ::RDF::Vocab::DC.identifier,
        multiple: true
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
