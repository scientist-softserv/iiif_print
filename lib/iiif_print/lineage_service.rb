module IiifPrint
  # The purpose of this module is to encode lineage related services:
  #
  # - {.ancestor_ids_for}
  # - {.descendent_file_set_ids_for}
  #
  # The ancestor and descendent_file_sets are useful for ensuring we index together related items.
  # For example, when I have a work that is a book, and one file set per page of that book, when I
  # search the book I want to find the text within the given book's pages.
  #
  # The methods of this module should be considered as defining an interface.
  module LineageService
    ##
    # @api public
    #
    # @param object [#in_works] An object that responds to #in_works
    # @return [Array<String>]
    def self.ancestor_ids_for(object)
      ancestor_ids ||= []
      object.in_works.each do |work|
        ancestor_ids << work.id
        ancestor_ids += ancestor_ids_for(work) if work.is_child
      end
      ancestor_ids.flatten.compact.uniq
    end

    ##
    # @param object [#ordered_works, #file_sets, #member_ids]
    # @return [Array<String>] the ids of associated file sets
    def self.descendent_file_set_ids_for(object)
      # enables us to return parents when searching for child OCR
      file_set_ids = object.file_sets.map(&:id)
      object.ordered_works&.each do |child|
        file_set_ids += descendent_file_set_ids_for(child)
      end
      # enables us to return parents when searching for child metadata
      file_set_ids += object.member_ids
      file_set_ids.flatten.uniq.compact
    end
  end
end
