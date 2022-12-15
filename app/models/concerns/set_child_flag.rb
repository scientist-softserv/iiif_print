# frozen_string_literal: true

require Rails.root.join('lib', 'rdf', 'custom_is_child_term.rb')

module SetChildFlag
  extend ActiveSupport::Concern
  included do
    after_save :set_children
    property :is_child,
             predicate: ::RDF::CustomIsChildTerm.is_child,
             multiple: false do |index|
               index.as :stored_searchable
             end
  end

  def set_children
    ordered_works.each do |child_work|
      child_work.update(is_child: true) unless child_work.is_child
    end
  end
end
