# Newspaper Article Cass
class NewspaperArticle < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata
  include NewspaperWorks::ScannedMediaMetadata

  self.indexer = NewspaperArticleIndexer

  # containment/aggregation:
  self.valid_child_concerns = [NewspaperPage]

  validates_with NewspaperWorks::PublicationDateValidator

  # Validation and required fields:
  validates :title, presence: {
    message: 'A newspaper article requires a title.'
  }

  # TODO: Implement validations
  # validates :resource_type, presence: {
  #   message: 'A newspaper article requires a resource type.'
  # }
  # validates :language, presence: {
  #   message: 'A newspaper article requires a language.'
  # }
  # validates :held_by, presence: {
  #   message: 'A newspaper article requires a holding location.'
  # }

  # == Type-specific properties ==

  # TODO: DRY on the indexing of fields, the index block is repetitive...

  # TODO: Reel #: https://github.com/samvera-labs/uri_selection_wg/issues/2

  # - Genre
  property(
    :genre,
    predicate: ::RDF::Vocab::EDM.hasType,
    multiple: true
  ) do |index|
    index.as :stored_searchable, :facetable
  end

  # - Author
  property(
    :author,
    predicate: ::RDF::Vocab::MARCRelators.aut,
    multiple: true
  ) do |index|
    index.as :stored_searchable, :facetable
  end

  # - Photographer
  property(
    :photographer,
    predicate: ::RDF::Vocab::MARCRelators.pht,
    multiple: true
  ) do |index|
    index.as :stored_searchable, :facetable
  end

  # - Volume
  property(
    :volume,
    predicate: ::RDF::Vocab::BIBO.volume,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Edition name
  property(
    :edition_name,
    predicate: ::RDF::Vocab::BF2.editionStatement,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Edition number / enumeration
  property(
    :edition_number,
    predicate: ::RDF::Vocab::BF2.editionEnumeration,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Issue
  property(
    :issue_number,
    predicate: ::RDF::Vocab::BIBO.issue,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Geographic coverage
  property(
    :geographic_coverage,
    predicate: ::RDF::Vocab::DC.spatial,
    multiple: true
  ) do |index|
    index.as :stored_searchable, :facetable
  end

  # - Extent
  property(
    :extent,
    predicate: ::RDF::Vocab::DC.extent,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  #  - publication date
  property(
    :publication_date,
    predicate: ::RDF::Vocab::DC.issued,
    multiple: false
  ) do |index|
    index.type :date
    index.as :stored_sortable
  end

  # TODO: Add Reel number: https://github.com/samvera-labs/uri_selection_wg/issues/2

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # for GeoNames autocomplete lookup
  include NewspaperWorks::PlaceOfPublicationBehavior

  # relationship methods:

  def pages
    members.select { |v| v.instance_of?(NewspaperPage) }
  end

  def issue
    issues = member_of.select { |v| v.instance_of?(NewspaperIssue) }
    issues[0] unless issues.empty?
  end

  def publication
    issue = self.issue
    issue.publication unless issue.nil?
  end

  def container
    pages = self.pages
    pages.first.container unless pages.empty?
  end
end
