# indexes the full text of a Newspaper object
module IiifPrint
  module IndexesFullText
    # index full text
    # load text from plain text derivative
    # index as *both* stored (for highlighting) and non-stored (Hyrax default) text field
    #
    # @param work [Newspaper*] an instance of a IiifPrint model
    # @param solr_doc [Hash] the hash of field data to be pushed to Solr
    def index_full_text(work, solr_doc)
      # TODO: Don't make this a mixin, instead create a module function that does this work.
      # TODO: We're assigning an all_text value to the hash before calling this; let's look at the
      # general approach to resolve duplication of effort.  See
      # https://github.com/scientist-softserv/iiif_print/blob/c854fe39f7fcd31b2008eb94db1c0738d977b2d9/app/indexers/concerns/iiif_print/file_set_indexer.rb#L14
      text = IiifPrint::Data::WorkDerivatives.data(from: work, of_type: 'txt')
      text = text.gsub(/\n/, ' ').squeeze(' ')
      solr_doc['all_text_timv'] = text
      solr_doc['all_text_tsimv'] = text
    end
  end
end
