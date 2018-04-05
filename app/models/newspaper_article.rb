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

  # Validation and required fields:
  # self.required_fields = [:resource_type, :genre, :language, :held_by]
  validates :title, presence: { message: 'A newspaper article requires a title.' }

  self.human_readable_type = 'Newspaper Article'

  # == Type-specific properties ==

  # TODO: DRY on the indexing of fields, the index block is repetitive...

  #  - Section
  property(
    :section,
    predicate: ::RDF::Vocab::BIBO.section,
    multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata

  # relationship methods:
  
  def pages
    self.members.select { |v| v.instance_of?(NewspaperPage) }
  end

  def issue
    issues = self.member_of.select { |v| v.instance_of?(NewspaperIssue) }
    issues[0] unless !issues.length
  end

  def publication
    issue = self.issue
    issue.publication unless issue.nil?
  end

  def containers
    pages = self.pages
    if pages.length > 0
      return pages[0].member_of.select { |v| v.instance_of?(NewspaperContainer) }
    end
  end
end
