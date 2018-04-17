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

  # - Creator
  property(
      :creator,
      predicate: ::RDF::Vocab::DC.creator,
      multiple: true
  ) do |index|
    index.as :stored_searchable
  end

  # - Contributor
  property(
      :contributor,
      predicate: ::RDF::Vocab::DC.contributor,
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
      :issue,
      predicate: ::RDF::Vocab::BIBO.issue,
      multiple: false
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

  # - Subject
  property(
      :subject,
      predicate: ::RDF::Vocab::DC.subject,
      multiple: true
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

  # - Pagination
  property(
      :pagination,
      predicate: ::RDF::Vocab::SCHEMA.pagination,
      multiple: false
  )

  # - Section
  property(
      :section,
      predicate: ::RDF::Vocab::BIBO.section,
      multiple: false
  ) do |index|
    index.as :stored_searchable
  end

  # TODO: Add Reel number

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
