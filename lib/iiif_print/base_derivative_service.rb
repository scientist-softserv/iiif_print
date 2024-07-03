module IiifPrint
  # Base type for IiifPrint derivative services
  class BaseDerivativeService
    attr_reader :file_set, :master_format
    delegate :uri, to: :file_set

    class_attribute :target_extension, default: nil

    def initialize(file_set)
      @file_set = if file_set.is_a?(Hyrax::FileMetadata)
                    Hyrax.query_service.find_by(id: file_set.file_set_id)
                  else
                    file_set
                  end
      @dest_path = nil
      @source_path = nil
      @source_meta = nil
    end

    ##
    # We assume that for the file set's parent that this is an acceptable plugin.  Now, we ask for
    # this specific file_set is it valid.  For example, we would not attempt to extract text from a
    # movie even though the parent work says to attempt to extract text on any attached file sets.
    # Put another way, we can upload a PDF or a Movie to the parent.
    #
    # In subclass, you'll want to consider the attributes of the file_set and whether that subclass
    # should process the given file_set.
    #
    # @see IiifPrint::PluggableDerivativeService#plugins_for
    # @return [Boolean]
    def valid?
      # @note We are taking a shortcut because currently we are only concerned about images.
      # @TODO: verify if this works for ActiveFedora and if so, remove commented code.
      #        If not, modify to use adapter.
      # file_set.class.image_mime_types.include?(file_set.mime_type)
      file_set.original_file&.image?
    end

    def derivative_path_factory
      Hyrax::DerivativePath
    end

    # prepare full path for passed extension/destination name, return path
    def prepare_path(extension)
      dest_path = derivative_path_factory.derivative_path_for_reference(
        @file_set,
        extension
      )
      dir = File.join(dest_path.split('/')[0..-2])
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      dest_path
    end

    # calculate and ensure directory components for singular @dest_path
    #   should only be used by subclasses producing a single derivative
    def load_destpath
      @dest_path = prepare_path(target_extension)
    end

    def identify
      return @source_meta unless @source_meta.nil?
      @source_meta = IiifPrint::ImageTool.new(@source_path).metadata
    end

    def mime_type
      identify[:content_type]
    end

    def use_color?
      identify[:color] == 'color'
    end

    # is source one-bit monochrome?
    def one_bit?
      identify[:color] == 'monochrome'
    end

    def create_derivatives(filename)
      # presuming that filename is full path to source file
      @source_path = filename

      # Get destination path from Hyrax for file extension defined in
      #   self.target_extension constant on respective derivative service subclass.
      load_destpath
    end

    def cleanup_derivatives(extension = target_extension, *_args)
      derivative_path_factory.derivatives_for_reference(file_set).each do |path|
        FileUtils.rm_f(path) if path.ends_with?(extension)
      end
    end

    def jp2_to_intermediate
      intermediate_path = File.join(Dir.mktmpdir, 'intermediate.tif')
      jp2_cmd = "opj_decompress -i #{@source_path} -o #{intermediate_path}"
      # make intermediate, then...
      `#{jp2_cmd}`
      intermediate_path
    end

    def convert_cmd
      raise NotImplementedError, 'Calling subclass missing convert_cmd method'
    end

    # convert non-JP2 source/primary file to PDF derivative with ImageMagick6
    #   calls convert_cmd on calling subclasses
    def im_convert
      `#{convert_cmd}`
    end

    # convert JP2 source/primary file to PDF derivative, via
    #   opj_decompress to intermediate TIFF, then ImageMagick6 convert
    def jp2_convert
      # jp2 source -> intermediate
      intermediate_path = jp2_to_intermediate
      @source_path = intermediate_path
      # intermediate -> PDF
      im_convert
    end

    def mime_type_for(extension)
      Marcel::MimeType.for extension: extension
    end
  end
end
