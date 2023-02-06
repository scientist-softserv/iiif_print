module IiifPrint
  module IiifPrintBehavior
    ##
    # relationship indexing for fileset and works
    #
    # @param options [Hash] options hash provided by Blacklight
    # @return [String] snippets HTML to be rendered
    # rubocop:disable Rails/OutputSafety
    def ancestor_ids(o)
      a_ids = []
      o.in_works.each do |work|
        a_ids << work.id
        a_ids += ancestor_ids(work) if work.is_child
      end
      a_ids
    end
  end
end
