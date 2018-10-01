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
  # validates :genre, presence: {
  #   message: 'A newspaper article requires a genre.'
  # }
  # validates :language, presence: {
  #   message: 'A newspaper article requires a language.'
  # }
  # validates :held_by, presence: {
  #   message: 'A newspaper article requires a holding location.'
  # }

  self.human_readable_type = 'Newspaper Article'

  # == Type-specific properties ==

  # TODO: DRY on the indexing of fields, the index block is repetitive...

  # TODO: Reel #: https://github.com/samvera-labs/uri_selection_wg/issues/2

  # - Author
  property(
    :author,
    predicate: ::RDF::Vocab::MARCRelators.aut,
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - Photographer
  property(
    :photographer,
    predicate: ::RDF::Vocab::MARCRelators.pht,
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - Volume
  property(
    :volume,
    predicate: ::RDF::Vocab::BIBO.volume,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # - Edition
  property(
    :edition,
    predicate: ::RDF::Vocab::BIBO.edition,
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

  #  - publication date
  property(
    :publication_date,
    predicate: ::RDF::Vocab::DC.issued,
    multiple: false
  ) do |index|
    index.as :dateable
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
