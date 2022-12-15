module IiifPrint
  module IiifPrintBehavior
    # adds IIIF Print behavior to an object
    def split_pdf
      true
    end

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
