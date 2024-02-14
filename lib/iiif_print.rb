require "iiif_print/engine"
require "iiif_print/errors"
require "iiif_print/jp2_image_metadata"
require "iiif_print/image_tool"
require "iiif_print/text_extraction"
require "iiif_print/data"
require "iiif_print/configuration"
require "iiif_print/base_derivative_service"
require "iiif_print/jp2_derivative_service"
require "iiif_print/pdf_derivative_service"
require "iiif_print/text_extraction_derivative_service"
require "iiif_print/text_formats_from_alto_service"
require "iiif_print/tiff_derivative_service"
require "iiif_print/lineage_service"
require "iiif_print/metadata"
require "iiif_print/works_controller_behavior"
require "iiif_print/blacklight_iiif_search/annotation_decorator"
require "iiif_print/split_pdfs/base_splitter"
require "iiif_print/split_pdfs/child_work_creation_from_pdf_service"
require "iiif_print/split_pdfs/derivative_rodeo_splitter"
require "iiif_print/split_pdfs/destroy_pdf_child_works_service"

# rubocop:disable Metrics/ModuleLength
module IiifPrint
  extend ActiveSupport::Autoload
  autoload :Configuration
  autoload :CatalogSearchBuilder

  ##
  # @api public
  #
  # Exposes the IiifPrint configuration.
  #
  # @yieldparam [IiifPrint::Configuration] config if a block is passed
  # @return [IiifPrint::Configuration]
  # @see IiifPrint::Configuration for configuration options
  def self.config(&block)
    @config ||= IiifPrint::Configuration.new
    yield @config if block
    @config
  end

  class << self
    delegate :skip_splitting_pdf_files_that_end_with_these_texts, to: :config
  end

  ##
  # Return the immediate parent of the given :file_set.
  #
  # @param file_set [FileSet]
  # @return [#work?, Hydra::PCDM::Work]
  # @return [NilClass] when no parent is found.
  def self.parent_for(file_set)
    # fallback to Fedora-stored relationships if work's aggregation of
    #   file set is not indexed in Solr
    file_set.parent || file_set.member_of.find(&:work?)
  end

  ##
  # Return the parent's parent of the given :file_set.
  #
  # @param file_set [FileSet]
  # @return [#work?, Hydra::PCDM::Work]
  # @return [NilClass] when no grand parent is found.
  def self.grandparent_for(file_set)
    parent_of_file_set = parent_for(file_set)
    # HACK: This is an assumption about the file_set structure, namely that an image page split from
    # a PDF is part of a file set that is a child of a work that is a child of a single work.  That
    # is, it only has one grand parent.  Which is a reasonable assumption for IIIF Print but is not
    # valid when extended beyond IIIF Print.  That is GenericWork does not have a parent method but
    # does have a parents method.
    parent_of_file_set.try(:parent_works).try(:first) ||
      parent_of_file_set.try(:parents).try(:first) ||
      parent_of_file_set&.member_of&.find(&:work?)
  end

  # NOTE: We use lambdas so we can have default values but also provide a lazy configuration.
  # There are certainly better ways but this is the least intrusive refactor from prior state.
  DEFAULT_MODEL_CONFIGURATION = {
    # Split a PDF into individual page images and create a new child work for each image.
    pdf_splitter_job: -> { IiifPrint::Jobs::ChildWorksFromPdfJob },
    pdf_splitter_service: -> { IiifPrint::SplitPdfs::PagesToJpgsSplitter },
    derivative_service_plugins: lambda {
                                  [
                                    IiifPrint::TextExtractionDerivativeService
                                  ]
                                }
  }.freeze

  # This is the record level configuration for PDF split handling.
  ModelConfig = Struct.new(:pdf_split_child_model, *DEFAULT_MODEL_CONFIGURATION.keys, keyword_init: true)
  private_constant :ModelConfig

  ##
  # @api public
  # This method is responsible for configuring a model for additional derivative generation.
  #
  # @example
  #   class Book < ActiveFedora::Base
  #     include IiifPrint.model_configuration(
  #       pdf_split_child_model: Page,
  #       derivative_service_plugins: [
  #         IiifPrint::JP2DerivativeService,
  #         IiifPrint::PDFDerivativeService,
  #         IiifPrint::TextExtractionDerivativeService,
  #         IiifPrint::TIFFDerivativeService
  #       ]
  #     )
  #   end
  #
  # @param kwargs [Hash<Symbol,Object>] the configuration values that overrides the
  #        DEFAULT_MODEL_CONFIGURATION.
  # @option kwargs [Array<Class>] derivative_service_plugins the various derivatives to run on the
  #        "original" files associated with this work.  Options include:
  #        {IiifPrint::JP2DerivativeService}, {IiifPrint::PDFDerivativeService},
  #        {IiifPrint::TextExtractionDerivativeService}, {IiifPrint::TIFFDerivativeService}
  # @option kwargs [Class] pdf_splitter_job responsible for handling the splitting of the original file
  # @option kwargs [Class] pdf_split_child_model when we split the file into pages, what's the child model
  #         we want for those pages?  Often times this is likely the same model as the parent.
  # @option kwargs [Class] pdf_splitter_service the specific service that splits the PDF.  Options are:
  #         {IiifPrint::SplitPdfs::PagesToJpgsSplitter},
  #         {IiifPrint::SplitPdfs::PagesToTiffsSplitter},
  #         {IiifPrint::SplitPdfs::PagesToPngsSplitter},
  #         {IiifPrint::SplitPdfs::DerivativeRodeoSplitter}
  #
  # @return [Module]
  #
  # @see IiifPrint::DEFAULT_MODEL_CONFIGURATION
  # @todo Because not every job will split PDFs and write to a child model. May want to introduce
  #       an alternative splitting method to create new filesets on the existing work instead of new child works.
  def self.model_configuration(**kwargs)
    Module.new do
      def iiif_print_config?
        true
      end

      # We don't know what you may want in your configuration, but from this gems implementation,
      # we're going to provide the defaults to ensure that it works.
      DEFAULT_MODEL_CONFIGURATION.each_pair do |key, default_value|
        kwargs[key] ||= default_value.call
      end

      define_method(:iiif_print_config) do
        @iiif_print_config ||= ModelConfig.new(**kwargs)
      end
    end
  end

  # @api public
  #
  # Map the given work's metadata to the given IIIF version spec's metadata structure.  This
  # is intended to be a drop-in replacement for `Hyrax::IiifManifestPresenter#manifest_metadata`.
  #
  # @param work [Object]
  # @param version [Integer]
  # @param fields [Array<IiifPrint::Metadata::Field>, Array<#name, #label>]
  # @return [Array<Hash>]
  #
  # @see specs for expected output
  #
  # @see Hyrax::IiifManifestPresenter#manifest_metadata
  def self.manifest_metadata_for(work:,
                                 version: config.default_iiif_manifest_version,
                                 fields: defined?(AllinsonFlex) ? fields_for_allinson_flex : default_fields,
                                 current_ability:,
                                 base_url:)
    Metadata.build_metadata_for(work: work,
                                version: version,
                                fields: fields,
                                current_ability: current_ability,
                                base_url: base_url)
  end

  def self.manifest_metadata_from(work:, presenter:)
    current_ability = presenter.try(:ability) || presenter.try(:current_ability)
    base_url = presenter.try(:base_url) || presenter.try(:request)&.base_url
    IiifPrint.manifest_metadata_for(work: work, current_ability: current_ability, base_url: base_url)
  end
  # Hash is an arbitrary attribute key/value pairs
  # Struct is a defined set of attribute "keys".  When we favor defined values,
  # then we are naming the concept and defining the range of potential values.
  Field = Struct.new(:name, :label, :options, keyword_init: true)

  # @api private
  # @todo Figure out a way to use a custom label, right now it takes it get rendered from the title.
  def self.default_fields(fields: config.metadata_fields)
    fields.map do |field|
      Field.new(
        name: field.first,
        label: Hyrax::Renderers::AttributeRenderer.new(field.first, nil).label,
        options: field.last
      )
    end
  end

  ##
  # @param fields [Array<IiifPrint::Field>]
  def self.fields_for_allinson_flex(fields: allinson_flex_fields, sort_order: IiifPrint.config.iiif_metadata_field_presentation_order)
    fields = sort_af_fields!(fields, sort_order: sort_order)
    fields.each_with_object({}) do |field, hash|
      # filters out admin_only fields
      next if field.indexing&.include?('admin_only')

      # WARNING: This is assuming A LOT
      # This is taking the Allinson Flex fields that have the same name and only
      # using the first one while discarding the rest.  There currently no way to
      # controller which one(s) are discarded but this fits for the moment.
      next if hash.key?(field.name)

      # currently only supports the faceted option
      # Why the `render_as:`? This was originally derived from Hyku default attributes
      # @see https://github.com/samvera/hyku/blob/c702844de4c003eaa88eb5a7514c7a1eae1b289e/app/views/hyrax/base/_attribute_rows.html.erb#L3
      hash[field.name] = Field.new(
        name: field.name,
        label: field.value,
        options: field.indexing&.include?('facetable') ? { render_as: :faceted } : nil
      )
    end.values
  end

  CollectionFieldShim = Struct.new(:name, :value, :indexing, keyword_init: true)

  ##
  # @return [Array<IiifPrint::Field>]
  def self.allinson_flex_fields
    return @allinson_flex_fields if defined?(@allinson_flex_fields)

    allinson_flex_relation = AllinsonFlex::ProfileProperty
                             .joins(:texts)
                             .where(allinson_flex_profile_texts: { name: 'display_label' })
                             .distinct
                             .select(:name, :value, :indexing)
    flex_fields = allinson_flex_relation.to_a
    unless allinson_flex_relation.exists?(name: 'collection')
      collection_field = CollectionFieldShim.new(name: :collection, value: 'Collection', indexing: [])
      flex_fields << collection_field
    end
    @allinson_flex_fields = flex_fields
  end

  ##
  # @param fields [Array<IiifPrint::Field>]
  # @param sort_order [Array<Symbol>]
  def self.sort_af_fields!(fields, sort_order:)
    return fields if sort_order.blank?

    fields.sort_by do |field|
      sort_order_index = sort_order.index(field.name.to_sym)
      sort_order_index.nil? ? sort_order.length : sort_order_index
    end
  end

  ##
  # @api public
  #
  # @param work [ActiveFedora::Base]
  # @param file_set [FileSet]
  # @param locations [Array<String>]
  # @param user [User]
  #
  # @return [Symbol] when none of the locations are to be split.
  def self.conditionally_submit_split_for(work:, file_set:, locations:, user:, skip_these_endings: skip_splitting_pdf_files_that_end_with_these_texts)
    locations = locations.select { |location| split_for_path_suffix?(location, skip_these_endings: skip_these_endings) }
    return :no_pdfs_for_splitting if locations.empty?

    work.try(:iiif_print_config)&.pdf_splitter_job&.perform_later(
      file_set,
      locations,
      user,
      work.admin_set_id,
      0 # A no longer used parameter; but we need to preserve the method signature (for now)
    )
  end

  ##
  # @api public
  #
  # @param path [String] the path, hopefully with an extension, to the file we're considering
  #        splitting.
  # @param skip_these_endings [Array<#downcase>] the endings that we should skip for splitting
  #        purposes.
  # @return [TrueClass] when the path is one we should split
  # @return [FalseClass] when the path is one we should not split
  #
  # @see .skip_splitting_pdf_files_that_end_with_these_texts
  def self.split_for_path_suffix?(path, skip_these_endings: skip_splitting_pdf_files_that_end_with_these_texts)
    return false unless path.downcase.end_with?('.pdf')
    return true if skip_these_endings.empty?
    !path.downcase.end_with?(*skip_these_endings.map(&:downcase))
  end
end
# rubocop:enable Metrics/ModuleLength
