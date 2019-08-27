# Generated via
#  `rails generate hyrax:work NewspaperIssue`
class NewspaperIssueIndexer < NewspaperWorks::NewspaperCoreIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  # include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  # include Hyrax::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      # set manually to ensure correct field type (_dtsi)
      if object.publication_date =~ /\A\d{4}-\d{2}-\d{2}\z/
        solr_doc['publication_date_ssi'] = nil
        solr_doc['publication_date_dtsi'] = object.publication_date.to_datetime
      end

      # if edition number is not set, add a default
      # to support ChronAm-style URL pattern linking
      solr_doc['edition_number_tesim'] ||= '1'
    end
  end
end
