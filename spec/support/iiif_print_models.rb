# frozen_string_literal: true
###################################################################################################
#
# The purpose of this file is to define the models we'll use in our spec application.  Some of these
# models are echoes of what downstream apps will define (e.g. FileSet).  Other are for internal
# modeling purposes only.
#
####################################################################################################
class FakeDerivativeService
  class_attribute :target_extension, default: 'txt'
  def initialize(target_extension: nil)
    self.target_extension = target_extension if target_extension
    @create_called = 0
    @cleanup_called = 0
  end
  attr_reader :create_called, :cleanup_called

  # Why the #new method?
  #
  # Because the plugin interface assumes we're passing a
  # plugin that responds to `new`.  In prod code, that plugin is a class.
  # However, in test, to facilitate observing what methods are called we pass
  # the plugin as an instance of this class (e.g. `plugin =
  # FakeDerivativeService.new`).  Later, in the process, the code calls
  # `plugin.new(file_set)`; it is then expected to return something that
  # responds to `create_derivatives` and `cleanup_derivatives`.
  #
  # @see IiifPrint::PluggableDerivativeService#initialize
  # @see IiifPrint::PluggableDerivativeService#services
  #
  # @note FakeDerivativeService.new returns an instance of
  #       FakeDerivativeService.  Likewise, FakeDerivativeService#new will now
  #       return an instance of FakeDerivativeService
  def new(fileset)
    @fileset = fileset
    self
  end

  def valid?
    true
  end

  def create_derivatives(filename)
    @create_called += 1
    filename
  end

  def cleanup_derivatives
    @cleanup_called += 1
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
