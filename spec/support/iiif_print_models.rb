# frozen_string_literal: true

# TODO: merge this in with whatever is needed from misc_shared.rb
class WorkWithIiifPrintConfig < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint::SetChildFlag
  include IiifPrint.model_configuration(pdf_split_child_model: WorkWithIiifPrintConfig)
  include ::Hyrax::BasicMetadata

  validates :title, presence: { message: 'Your work must have a title.' }

  # self.indexer = GenericWorkIndexer
end

class WorkWithOutConfig < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  include IiifPrint::SetChildFlag
  include ::Hyrax::BasicMetadata

  validates :title, presence: { message: 'Your work must have a title.' }

  # self.indexer = GenericWorkIndexer
end