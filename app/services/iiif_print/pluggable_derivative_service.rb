# General derivative service for IiifPrint, which is meant to wrap
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
#     IiifPrint::PluggableDerivativeService
#   )
#
#   Modify IiifPrint::PluggableDerivativeService.plugins
#   to add, remove, or reorder plugin (derivative service) classes.
#
class IiifPrint::PluggableDerivativeService
  class_attribute :allowed_methods, default: [:cleanup_derivatives, :create_derivatives]
  class_attribute :default_plugins, default: [Hyrax::FileSetDerivativesService]
  class_attribute :derivative_path_factory, default: Hyrax::DerivativePath

  def initialize(file_set, plugins: plugins_for(file_set))
    @file_set = file_set
    @plugins = Array.wrap(plugins)
    @valid_plugins = plugins.map { |plugin| plugin.new(file_set) }.select(&:valid?)
  end

  attr_reader :file_set, :plugins, :valid_plugins
  delegate :uri, :mime_type, to: :file_set

  # this wrapper/proxy/composite is always valid, but it may compose
  #   multiple plugins, some of which may or may not be valid, so
  #   validity checks happen within as well.
  def valid?
    !valid_plugins.size.zero?
  end

  # get derivative services relevant to method name and file_set context
  #   -- omits plugins if particular destination exists or will soon.
  def services(method_name)
    valid_plugins.select do |plugin|
      dest = nil
      dest = plugin.target_extension if plugin.respond_to?(:target_extension)
      !skip_destination?(method_name, dest)
    end
  end

  private

  def respond_to_missing?(method_name, include_private = false)
    allowed_methods.include?(method_name) || super
  end

  def method_missing(method_name, *args, **opts, &block)
    if allowed_methods.include?(method_name)
      # we have an allowed method, construct services and include all valid
      #   services for the file_set
      # services = plugins.map { |plugin| plugin.new(file_set) }.select(&:valid?)
      # run all valid services, in order:
      services(method_name).each do |plugin|
        plugin.send(method_name, *args, **opts, &block)
      end
    else
      super
    end
  end

  def skip_destination?(method_name, destination_name)
    return false unless method_name == :create_derivatives
    return false unless destination_name
    # NOTE: What are we after with this nil test?  Are we looking for persisted objects?
    return false if file_set.id.nil?

    # skip :create_derivatives if existing --> do not re-create
    existing_derivative?(destination_name) ||
      impending_derivative?(destination_name)
  end

  def existing_derivative?(name)
    path = derivative_path_factory.derivative_path_for_reference(
      file_set,
      name
    )
    File.exist?(path)
  end

  # is there an impending attachment from ingest logged to db?
  #   -- avoids stomping over pre-made derivative
  #      for which an attachment is still in-progress.
  def impending_derivative?(name)
    IiifPrint::DerivativeAttachment.exists?(
      fileset_id: file_set.id,
      destination_name: name
    )
  end

  # This method is responsible for determine what are the possible plugins / services that this file
  # set would use.  That "possibility" is based on the work.  Later, we will check the plugin's
  # "valid?" which would now look at the specific file_set for validity.
  def plugins_for(file_set)
    parent = parent_for(file_set)
    return Array(default_plugins) if parent.nil?
    return Array(default_plugins) unless parent.respond_to?(:iiif_print_config)

    (file_set.parent.iiif_print_config.derivative_service_plugins + Array(default_plugins)).flatten.compact.uniq
  end

  def parent_for(file_set)
    # fallback to Fedora-stored relationships if work's aggregation of
    #   file set is not indexed in Solr
    file_set.parent || file_set.member_of.find(&:work?)
  end
end
