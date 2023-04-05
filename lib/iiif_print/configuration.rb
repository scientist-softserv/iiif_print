module IiifPrint
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

    attr_writer :additional_tessearct_options
    ##
    # The additional options to pass to the Tesseract configuration
    #
    # @see https://tesseract-ocr.github.io/tessdoc/Command-Line-Usage.html
    # @return [String]
    def additional_tessearct_options
      @additional_tessearct_options || ""
    end
  end
end
