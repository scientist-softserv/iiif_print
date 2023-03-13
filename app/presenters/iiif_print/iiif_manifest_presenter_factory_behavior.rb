module IiifPrint
  module IiifManifestPresenterFactoryBehavior
    # This will override Hyrax::IiifManifestPresenter::Factory#build and introducing
    # the expected behavior:
    # - child work images show as canvases in the parent work manifest
    # - child work images show in the uv on the parent show page
    # - still create the manifest if the parent work has images attached but the child works do not
    def build
      ids.map do |id|
        solr_doc = load_docs.find { |doc| doc.id == id }
        next unless solr_doc

        if solr_doc.file_set?
          presenter_class.for(solr_doc)
        elsif Hyrax.config.curation_concerns.include?(solr_doc.hydra_model)
          # look up file set ids and loop through those
          file_set_docs = load_file_set_docs(solr_doc.try(:file_set_ids) || solr_doc.try(:[], 'file_set_ids_ssim'))
          file_set_docs.map { |doc| presenter_class.for(doc) } if file_set_docs.length
        end
      end.flatten.compact
    end

    private

    # still create the manifest if the parent work has images attached but the child works do not
    def load_file_set_docs(file_set_ids)
      return [] if file_set_ids.nil?

      query("{!terms f=id}#{file_set_ids.join(',')}", rows: 1000)
        .map { |res| ::SolrDocument.new(res) }
    end
  end
end
