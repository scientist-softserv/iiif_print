# frozen_string_literal: true

module IiifPrint
  module ChildIndexer
    extend ActiveSupport::Concern
    include IiifPrint::IiifPrintBehavior

    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['is_child_bsi'] = object.is_child
        solr_doc['is_page_of_ssim'] = ancestor_ids(object)
        solr_doc['file_set_ids_ssim'] = all_decendent_file_sets(object)
      end
    end

    private

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

    def all_decendent_file_sets(o)
      # enables us to return parents when searching for child OCR
      all_my_children = o.file_sets.map(&:id)
      o.ordered_works&.each do |child|
        all_my_children += all_decendent_file_sets(child)
      end
      # enables us to return parents when searching for child metadata
      all_my_children << o.member_ids
      all_my_children.flatten!.uniq.compact
    end
  end
end
