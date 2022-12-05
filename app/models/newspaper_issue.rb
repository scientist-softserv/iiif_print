# Newspaper Issue
class NewspaperIssue < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include IiifPrint::NewspaperCoreMetadata

  self.indexer = NewspaperIssueIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []

  # Validation and required fields:
  validates :title, presence: {
    message: 'Your work must have a title.'
  }

  validates_with IiifPrint::PublicationDateValidator

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

  # TODO: Reel #: https://github.com/samvera-labs/uri_selection_wg/issues/2

  #  - Volume
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
    index.type :date
    index.as :stored_sortable
  end

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # for GeoNames autocomplete lookup
  include IiifPrint::PlaceOfPublicationBehavior

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

  def ordered_pages
    ordered_members.to_a.select { |v| v.instance_of?(NewspaperPage) }
  end

  def ordered_page_ids
    ordered_pages.map(&:id)
  end
end
