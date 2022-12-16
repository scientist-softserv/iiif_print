# frozen_string_literal: true

module Hyrax
  module FileSetIndexerDecorator
    include IiifPrint::FileSetIndexer
    binding.pry
  end
end

Hyrax::FileSetIndexer.prepend(Hyrax::FileSetIndexerDecorator)
# Hyrax::FileSetIndexer.class_eval do
#   include IiifPrint::FileSetIndexer
# end
