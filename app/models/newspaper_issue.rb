# Newspaper Issue
class NewspaperIssue < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata

  self.indexer = NewspaperIssueIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  # Validation and required fields:
  validates :title, presence: {
    message: 'Your work must have a title.'
  }

  validates_with NewspaperWorks::PublicationDateValidator

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

  self.human_readable_type = 'Newspaper Issue'

  # TODO: Reel #: https://github.com/samvera-labs/uri_selection_wg/issues/2

  #  - Volume
  property(
    :volume,
    predicate: ::RDF::Vocab::BIBO.volume,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  #  - Edition
  property(
    :edition,
    predicate: ::RDF::Vocab::BIBO.edition,
    multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  #  - Issue
  property(
    :issue_number,
    predicate: ::RDF::Vocab::BIBO.issue,
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

  #  - publication date
  property(
    :publication_date,
    predicate: ::RDF::Vocab::DC.issued,
    multiple: false
  ) do |index|
    index.as :dateable
  end

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # for GeoNames autocomplete lookup
  include NewspaperWorks::PlaceOfPublicationBehavior

  # relationship methods
  def publication
    result = member_of.select { |v| v.instance_of?(NewspaperTitle) }
    result[0] unless result.empty?
  end

  def articles
    members.select { |v| v.instance_of?(NewspaperArticle) }
  end

  def pages
    members.select { |v| v.instance_of?(NewspaperPage) }
  end
end
