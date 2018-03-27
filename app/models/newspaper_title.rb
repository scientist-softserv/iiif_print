# NewspaperTitle: object for a publication/title
class NewspaperTitle < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  include NewspaperWorks::NewspaperCoreMetadata

  self.indexer = NewspaperTitleIndexer

  # containment/aggregation:
  self.valid_child_concerns = [NewspaperContainer, NewspaperIssue]

  # Validation and required fields:
  # self.required_fields = [:resource_type, :genre, :language, :held_by]
  validates :title, presence: {
    message: 'A newspaper title a title (publication name).'
  }

  self.human_readable_type = 'Newspaper Title'

  # == Type-specific properties ==

  #  - Alternative Title
  property(
    :alternative_title,
    predicate: ::RDF::Vocab::DC.alternative,
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods:
  def issues
    self.members.select { |v| v.instance_of?(NewspaperIssue) }
  end

  def containers
    self.members.select { |v| v.instance_of?(NewspaperContainer) }
  end

end
