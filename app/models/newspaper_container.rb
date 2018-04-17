class NewspaperContainer < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata

  self.indexer = NewspaperContainerIndexer

  # containment/aggregation:
  self.valid_child_concerns = [NewspaperPage]

  # Validation and required fields:
  # self.required_fields = [:resource_type, :genre, :language, :held_by]
  validates :title, presence: { message: 'A newspaper container requires a title.' }

  self.human_readable_type = 'Newspaper Container'

  # == Type-specific properties ==

  # TODO: DRY on the indexing of fields, the index block is repetative...


  #  - Type (TODO: make a behavior mixin for common fields)
  property(
    :resource_type,
    predicate: ::RDF::Vocab::DC.type,
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - ISSN
  property(
      :issn,
      predicate: ::RDF::Vocab::Identifiers.issn,
      multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - LCCN
  property(
      :lccn,
      predicate: ::RDF::Vocab::Identifiers.lccn,
      multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - OCLC Number
  property(
      :oclcnum,
      predicate: ::RDF::Vocab::BIBO.oclcnum,
      multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Extent
  property(
    :extent,
    predicate: ::RDF::Vocab::DC.extent,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # TODO: Reel #
  # TODO: Titles on reel

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods
  
  def publication
    result = self.member_of.select { |v| v.instance_of?(NewspaperTitle) }
    result[0] unless result.length == 0
  end

  def pages
    self.members.select { |v| v.instance_of?(NewspaperPage) }
  end

end
