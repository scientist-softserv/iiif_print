# frozen_string_literal: true
###################################################################################################
#
# The purpose of this file is to define the models we'll use in our spec application.  Some of these
# models are echoes of what downstream apps will define (e.g. FileSet).  Other are for internal
# modeling purposes only.
#
####################################################################################################

##
# iiif_print requires a file set model that is compatible with Hyrax assumptions.  We do not want to
# add this to app/models because those are loaded in the downstream application; which can create
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
end

# Newspaper Issue
class NewspaperIssue < ActiveFedora::Base
  # WorkBehavior mixes in minimal ::Hyrax::CoreMetadata fields of
  # depositor, title, date_uploaded, and date_modified.
  # https://samvera.github.io/customize-metadata-model.html#core-metadata
  include ::Hyrax::WorkBehavior
  # BasicMetadata must be included last
  include ::Hyrax::BasicMetadata
end

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
