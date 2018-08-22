# General derivative service for NewspaperWorks, which is meant to wrap
#   and replace the stock Hyrax::FileSetDerivativeService with a proxy
#   that runs one or more derivative service "plugin" components.
#
#   Note: Hyrax::DerivativeService consumes this, instead of (directly)
#   consuming Hyrax::FileSetDerivativeService.
#
#   Unlike the "run the first valid plugin" arrangement that the
#   Hyrax::DerivativeService uses to run an actual derivative creation
#   service component, this component is:
#
#   (a) Consumed by Hyrax::DerivativeService as that first valid plugin;
#
#   (b) Wraps and runs 0..* plugins, not just the first.
#
# This should be registered to take precedence over default by:
#   Hyrax::DerivativeService.services.unshift(
#     NewspaperWorks::PluggableDerivativeService
#   )
#
#   Modify NewspaperWorks::PluggableDerivativeService.plugins
#   to add, remove, or reorder plugin (derivative service) classes.
#
class NewspaperWorks::PluggableDerivativeService
  attr_reader :file_set
  delegate :uri, :mime_type, to: :file_set

  # default plugin Hyrax OOTB, makes thumbnails and sometimes extracts text:
  default_plugin = Hyrax::FileSetDerivativesService

  # make and expose an array of plugins
  @plugins = [default_plugin]
  @allowed_methods = [:cleanup_derivatives, :create_derivatives]
  class << self
    attr_accessor :plugins, :allowed_methods
  end

  def plugins
    self.class.plugins
  end

  def initialize(file_set)
    @file_set = file_set
  end

  def valid?
    # this wrapper/proxy/composite is always valid, but it may compose
    #   multiple plugins, some of which may or may not be valid, so
    #   validity checks happen within as well.
    true
  end

  def respond_to_missing?(method_name)
    self.class.allowed_methods.include?(method_name) || super
  end

  def method_missing(name, *args, **opts, &block)
    if respond_to_missing?(name)
      # we have an allowed method, construct services and include all valid
      #   services for the file_set
      services = plugins.map { |plugin| plugin.new(file_set) }.select(&:valid?)
      # run all valid services, in order:
      services.each do |plugin|
        plugin.send(name, *args)
      end
    else
      super
    end
  end
end
