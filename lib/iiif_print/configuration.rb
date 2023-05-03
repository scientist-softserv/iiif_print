module IiifPrint
  # rubocop:disable Metrics/ClassLength
  class Configuration
    attr_writer :after_create_fileset_handler

    # @param file_set [FileSet]
    # @param user [User]
    def handle_after_create_fileset(file_set, user)
      if defined? @after_create_fileset_handler
        @after_create_fileset_handler.call(file_set, user)
      else
        IiifPrint::Data.handle_after_create_fileset(file_set, user)
      end
    end

    attr_writer :ancestory_identifier_function
    # The function, with arity 1, that receives a work and returns it's identifier for the purposes
    # of object ancestry.
    # @return [Proc]
    def ancestory_identifier_function
      @ancestory_identifier_function ||= ->(work) { work.id }
    end

    attr_writer :excluded_model_name_solr_field_values
    # By default, this uses an array of human readable types
    #   ex: ['Generic Work', 'Image']
    # @return [Array<String>]
    def excluded_model_name_solr_field_values
      return @excluded_model_name_solr_field_values unless @excluded_model_name_solr_field_values.nil?
      @excluded_model_name_solr_field_values = []
    end

    attr_writer :unique_child_title_generator_function

    # The function, with keywords (though maybe you'll want to splat ignore a few), is responsible
    # for generating the child work file title.  of object ancestry.
    #
    # The keyword parameters that will be passed to this function are:
    #
    # :original_pdf_path - The fully qualified pathname to the original PDF from which the images
    #                      were split.
    # :image_path - The fully qualified pathname for an image of the single page from the PDF.
    # :parent_work - The object in which we're "attaching" the image.
    # :page_number - The image is of the N-th page_number of the original PDF
    # :page_padding - A helper number that indicates the number of significant digits of pages
    #                 (e.g. 150 pages would have a padding of 3).
    #
    # @return [Proc]
    # rubocop:disable Lint/UnusedBlockArgument
    def unique_child_title_generator_function
      @unique_child_title_generator_function ||= lambda { |original_pdf_path:, image_path:, parent_work:, page_number:, page_padding:|
        identifier = parent_work.id
        filename = File.basename(original_pdf_path)
        page_suffix = "Page #{(page_number.to_i + 1).to_s.rjust(page_padding.to_i, '0')}"
        "#{identifier} - #{filename} #{page_suffix}"
      }
    end
    # rubocop:enable Lint/UnusedBlockArgument

    # This method wraps Hyrax's configuration so we can sniff out the correct method to use.  The
    # {Hyrax::Configuration#whitelisted_ingest_dirs} is deprecated in favor of
    # {Hyrax::Configuration#registered_ingest_dirs}.
    #
    # @return [Array<String>]
    def registered_ingest_dirs
      if Hyrax.config.respond_to?(:registered_ingest_dirs)
        Hyrax.config.registered_ingest_dirs
      else
        Hyrax.config.whitelisted_ingest_dirs
      end
    end

    attr_writer :excluded_model_name_solr_field_key
    # A string of a solr field key
    # @return [String]
    def excluded_model_name_solr_field_key
      return "human_readable_type_sim" unless defined?(@excluded_model_name_solr_field_key)
      @excluded_model_name_solr_field_key
    end

    attr_writer :default_iiif_manifest_version
    def default_iiif_manifest_version
      @default_iiif_manifest_version.presence || 2
    end

    attr_writer :metadata_fields
    # rubocop:disable Metrics/MethodLength
    # @api private
    # @note These fields will appear in rendering order.
    # @todo To move this to an `@api public` state, we need to consider what a proper configuration looks like.
    def metadata_fields
      @metadata_fields ||= {
        title: {},
        description: {},
        collection: {},
        abstract: {},
        date_modified: {},
        creator: { render_as: :faceted },
        contributor: { render_as: :faceted },
        subject: { render_as: :faceted },
        publisher: { render_as: :faceted },
        language: { render_as: :faceted },
        identifier: { render_as: :linked },
        keyword: { render_as: :faceted },
        date_created: { render_as: :linked },
        based_near_label: {},
        related_url: { render_as: :external_link },
        resource_type: { render_as: :faceted },
        source: {},
        extent: {},
        rights_statement: { render_as: :rights_statement },
        rights_notes: {},
        access_right: {},
        license: { render_as: :license },
        searchable_text: {}
      }
    end
    # rubocop:enable Metrics/MethodLength

    attr_writer :additional_tesseract_options
    ##
    # The additional options to pass to the Tesseract configuration
    #
    # @see https://tesseract-ocr.github.io/tessdoc/Command-Line-Usage.html
    # @return [String]
    def additional_tesseract_options
      @additional_tesseract_options || ""
    end

    attr_writer :uv_config_path
    ##
    # According to https://github.com/samvera/hyrax/wiki/Hyrax-Management-Guide#universal-viewer-config
    # the name of the UV config file should be /uv/uv_config.json (with an _)
    # However, in most applications, it is /uv/uv-config.json (with a -)
    def uv_config_path
      @uv_config_path || "/uv/uv-config.json"
    end

    attr_writer :uv_base_path
    ##
    # While we're at it, we're going to go ahead and make the base path configurable as well
    def uv_base_path
      @uv_base_path || "/uv/uv.html"
    end

    attr_writer :child_work_attributes_function
    ##
    # Here we allow for customization of the child work attributes
    def child_work_attributes_function
      @child_work_attributes_function ||= lambda do |parent_work:, admin_set_id:|
        {
          admin_set_id: admin_set_id.to_s,
          creator: parent_work.creator.to_a,
          rights_statement: parent_work.rights_statement.to_a,
          visibility: parent_work.visibility.to_s
        }
      end
    end

    attr_writer :sort_iiif_manifest_canvases_by
    ##
    # Normally, the canvases are sorted by the `ordered_members` association.
    # However, if you want it to be sorted by another property, you can set this
    # configuration.  Change `nil` to something like `:title` or `:identifier`.
    #
    # Should you want to sort by the filename of the image, you
    # set `nil` to `:label`.  This looks at the canvas label, which is typically set
    # to the filename of the image.
    def sort_iiif_manifest_canvases_by
      @sort_iiif_manifest_canvases_by || nil
    end

    attr_writer :ocr_coords_from_json_function
    ##
    # This is used to determine where to pull the OCR coordinates from.  By default, it will
    # pull from the JSON file that is generated by the OCR engine.  However, if you have a
    # different source, you can set this configuration.  Current implementation has access to
    # the `file_set_id`` and the `document` [SolrDocument].
    #
    # @see IiifPrint::BlacklightIiifSearch::AnnotationDecorator#fetch_and_parse_coords
    def ocr_coords_from_json_function
      @ocr_coords_from_json_function ||= lambda do |file_set_id:, **|
        IiifPrint::Data::WorkDerivatives.data(from: file_set_id, of_type: 'json')
      end
    end

    attr_writer :all_text_generator_function
    ##
    # This configuration determines where to pull the full text from.  By default, it will
    # pull from the TXT file that is generated by the OCR engine.  However, if your
    # application has its own implementation of generating the full text, then you can
    # set your own configuration here.
    def all_text_generator_function
      @all_text_generator_function ||= lambda do |object:|
        IiifPrint::Data::WorkDerivatives.data(from: object, of_type: 'txt')
      end
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
