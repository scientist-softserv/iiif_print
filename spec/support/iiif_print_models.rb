# frozen_string_literal: true
###################################################################################################
#
# The purpose of this file is to define the models we'll use in our spec application.  Some of these
# models are echoes of what downstream apps will define (e.g. FileSet).  Other are for internal
# modeling purposes only.
#
####################################################################################################

class FakeDerivativeService
  @create_called = 0
  @cleanup_called = 0
  class << self
    attr_accessor :create_called, :cleanup_called

    def target_ext
      'txt'
    end
  end

  def initialize(fileset)
    @fileset = fileset
    @created = false
  end

  def valid?
    true
  end

  def create_derivatives(filename)
    self.class.create_called += 1
    filename
  end

  def cleanup_derivatives
    self.class.cleanup_called += 1
  end
end

##
# iiif_print requires a file set model that is compatible with Hyrax assumptions.  We do not want to
# add this to app/models because those are loaded in the downstream application; which can create
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
end

class MyWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
end

class MyWorkNeedsDerivative < ActiveFedora::Base
  attr_accessor :title
  def members
    []
  end
end

class MyWorkDoesNotNeedDerivative < ActiveFedora::Base
  attr_accessor :title
  def members
    []
  end
end

class MyIiifConfiguredWorkWithAllDerivativeServices < ActiveFedora::Base
  include IiifPrint.model_configuration

  attr_accessor :title
  def members
    []
  end
end

class MyIiifConfiguredWork < ActiveFedora::Base
  include IiifPrint.model_configuration(
    derivative_service_plugins: [FakeDerivativeService]
  )
  attr_accessor :title
  def members
    []
  end
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
