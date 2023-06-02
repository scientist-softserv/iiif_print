module IiifPrint
  ##
  # This class implements the interface of a Hyrax::DerivativeService.
  #
  # That means three important methods are:
  #
  # - {#valid?}
  # - {#create_derivatives}
  # - {#cleanup_derivatives}
  #
  # And the object initializes with a FileSet.
  #
  # It is a companion to {IiifPrint::PluggableDerivativeService}.
  #
  # @see https://github.com/samvera/hyrax/blob/main/app/services/hyrax/derivative_service.rb Hyrax::DerivativesService
  class DerivativeRodeoService
    ##
    # @!group Class Attributes
    #
    # @attr parent_work_identifier_property_name [String] the property we use to identify the unique
    #       identifier of the parent work as it went through the SpaceStone pre-process.
    #
    # TODO: The default of :aark_id is a quick hack for adventist.  By exposing a configuration
    # value, my hope is that this becomes easier to configure.
    class_attribute :parent_work_identifier_property_name, default: 'aark_id'

    ##
    # @attr input_location_adapter_name [String] The name of a derivative rodeo storage location;
    #       this will must be a registered with the DerivativeRodeo::StorageLocations::BaseLocation.
    class_attribute :input_location_adapter_name, default: 's3'

    ##
    # @attr named_derivatives_and_generators_by_type [Hash<Symbol, #constantize>] the named derivative and it's
    #       associated generator.  The "name" is important for Hyrax.  The generator is one that
    #       exists in the DerivativeRodeo.
    #
    # TODO: Could be nice to have a registry for the DerivativeRodeo::Generators; but that's a
    # tomorrow wish.
    class_attribute(:named_derivatives_and_generators_by_type, default: {
                      pdf: { thumbnail: "DerivativeRodeo::Generators::ThumbnailGenerator" }
                    })
    # @!endgroup Class Attributes
    ##

    ##
    # This method "hard-codes" some existing assumptions about the input_uri based on
    # implementations for Adventist.  Those are reasonable assumptions but time will tell how
    # reasonable.
    #
    # @param file_set [FileSet]
    # @return [String]
    def self.derivative_rodeo_input_uri(file_set:)
      return @derivative_rodeo_input_uri if defined?(@derivative_rodeo_input_uri)

      # TODO: URGENT For a child work (e.g. an image split off of a PDF) we will know that the file_set's
      # parent is a child, and the rules of the URI for those derivatives are different from the
      # original ingested PDF or the original ingested Image.

      # TODO: This logic will work for an attached PDF; but not for each of the split pages of that
      # PDF.  How to do that?

      # TODO: This is duplicated logic for another service, consider extracting a helper module;
      # better yet wouldn't it be nice if Hyrax did this right and proper.
      parent = file_set.parent || file_set.member_of.find(&:work?)
      raise IiifPrint::DataError, "Parent not found for #{file_set.class} ID=#{file_set.id}" unless parent

      dirname = parent.public_send(parent_work_identifier_property_name)

      # TODO: This is a hack that knows about the inner workings of Hydra::Works, but for
      # expendiency, I'm using it.  See
      # https://github.com/samvera/hydra-works/blob/c9b9dd0cf11de671920ba0a7161db68ccf9b7f6d/lib/hydra/works/services/add_file_to_file_set.rb#L49-L53
      # TODO: Could we get away with filename that is passed in the create_derivatives process?
      filename = Hydra::Works::DetermineOriginalName.call(file_set.original_file)

      # TODO: What kinds of exceptions might we raise if the location is not configured?  Do we need
      # to "validate" it in another step.
      location = DerivativeRodeo::StorageLocations::BaseLocation.load_location(input_location_adapter_name)

      # TODO: This is based on the provided output template in
      # https://github.com/scientist-softserv/space_stone-serverless/blob/0dbe2b6fa13b9f4bf8b9580ec14d0af5c98e2b00/awslambda/bin/sample_post.rb#L1
      # and is very much hard-coded.  We likely want to "store" the template in a common place for
      # the application.
      #
      # s3://s3-antics/:aark_id/:file_name_with_extension
      # s3://s3-antics/12345/hello-world.pdf
      @derivative_rodeo_input_uri = File.join(location.adapter_prefix, dirname, File.basename(filename))
    end

    def initialize(file_set)
      @file_set = file_set
    end

    attr_reader :file_set
    delegate :uri, :mime_type, to: :file_set

    ##
    # @return
    # @see https://github.com/samvera/hyrax/blob/426575a9065a5dd3b30f458f5589a0a705ad7be2/app/services/hyrax/file_set_derivatives_service.rb#L18-L20 Hyrax::FileSetDerivativesService#valid?
    def valid?
      if in_the_rodeo?
        Rails.logger.info("🤠🐮 Using the DerivativeRodeo for FileSet ID=#{file_set.id} with mime_type of #{mime_type}")
        true
      else
        Rails.logger.info("Skipping the DerivativeRodeo for FileSet ID=#{file_set.id} with mime_type of #{mime_type}")
        false
      end
    end

    ##
    # @api public
    #
    # The file_set.class.*_mime_types are carried over from Hyrax.
    def create_derivatives(filename)
      # TODO: Do we need to handle "impending derivatives?"  as per {IiifPrint::PluggableDerivativeService}?
      case mime_type
      when file_set.class.pdf_mime_types
        lasso_up_some_derivatives(filename: filename, type: :pdf)
      when file_set.class.image_mime_types
        lasso_up_some_derivatives(filename: filename, type: :image)
      else
        # TODO: add more mime types but for now image and PDF are the two we accept.
        raise "Unexpected mime_type #{mime_type} for filename #{filename}"
      end
    end

    private

    def lasso_up_some_derivatives(type:, **)
      # TODO: Can we use the filename instead of the antics of the original_file on the file_set?
      # We have the filename in create_derivatives.
      named_derivatives_and_generators_by_type.fetch(type).flat_map do |named_derivative, generator_name|
        # This is the location that Hyrax expects us to put files that will be added to Fedora.
        output_location_template = "file://#{Hyrax::DerivativePath.derivative_path_for_reference(file_set, named_derivative)}"
        generator = generator_name.constantize
        generator.new(input_uris: [derivative_rodeo_input_uri], output_location_template: output_location_template).generate_uris
      end
    end

    def supported_mime_types
      # If we've configured the rodeo
      named_derivatives_and_generators_by_type.keys.flat_map { |type| file_set.class.public_send("#{type}_mime_types") }
    end

    def derivative_rodeo_input_uri
      @derivative_rodeo_input_uri ||= self.class.derivative_rodeo_input_uri(file_set: file_set)
    end

    def in_the_rodeo?
      # We can assume that we are not going to process a supported mime type; and there is a cost
      # for looking in the rodeo.
      return false unless supported_mime_types.include?(mime_type)

      location = DerivativeRodeo::StorageLocations::BaseLocation.from_uri(derivative_rodeo_input_uri)
      location.exist?
    end
  end
end
