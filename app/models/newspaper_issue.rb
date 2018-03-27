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
  # self.required_fields = [:resource_type, :genre, :language, :held_by]
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Newspaper Issue'

  #  - Alternative Title
  property(
    :alternative_title,
    predicate: ::RDF::Vocab::DC.alternative,
    multiple: true
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

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods
  def publication
    result = self.member_of.select { |v| v.instance_of?(NewspaperTitle) }
    result[0] unless result.length == 0
  end

  def articles
    self.members.select { |v| v.instance_of?(NewspaperArticle) }
  end

  def pages
    self.members.select { |v| v.instance_of?(NewspaperPage) }
  end

end
