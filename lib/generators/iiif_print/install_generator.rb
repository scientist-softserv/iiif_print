require 'rails/generators'

module IiifPrint
  # Install Generator Class
  # rubocop:disable Metrics/ClassLength
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_migrations
      rake "iiif_print:install:migrations"
    end

    def verify_biiif_installed
      return if IO.read('app/controllers/catalog_controller.rb').include?('include BlacklightIiifSearch::Controller')
      say_status('info',
                 'BLACKLIGHT IIIF SEARCH NOT INSTALLED; INSTALLING BLACKLIGHT IIIF SEARCH',
                 :blue)
      generate 'blacklight_iiif_search:install --skip-solr'
    end

    def catalog_controller_configuration
      generate 'iiif_print:catalog_controller'
    end

    def inject_configuration
      copy_file 'config/initializers/iiif_print.rb'
    end

    def inject_assets
      generate 'iiif_print:assets'
    end

    def inject_helper
      copy_file 'helpers/iiif_print_helper.rb'
    end

    # Blacklight IIIF Search generator has some linting that does not agree with CircleCI on Hyku
    # ref https://github.com/boston-library/blacklight_iiif_search/blob/v1.0.0/lib/generators/blacklight_iiif_search/controller_generator.rb
    # the follow two methods does a clean up to appease Rubocop
    def lint_catalog_controller
      file = "app/controllers/catalog_controller.rb"
      contents = File.read(file)
      contents.gsub!(/\n\s*\n\s*# IiifPrint index fields/, "\n    # IiifPrint index fields")
      contents.gsub!(/\n\s*\n\s*# configuration for Blacklight IIIF Content Search/, "\n\n    # configuration for Blacklight IIIF Content Search")
      File.write(file, contents)
    end

    # ref https://github.com/boston-library/blacklight_iiif_search/blob/v1.0.0/lib/generators/blacklight_iiif_search/templates/iiif_search_builder.rb
    def lint_iiif_search_builder
      file = "app/models/iiif_search_builder.rb"
      contents = File.read(file)
      contents.insert(0, "# frozen_string_literal: true\n\n")
      File.write(file, contents)
    end

    def add_allinson_flex_fields_method_to_iiif_search_builder
      file_path = "app/models/iiif_search_builder.rb"
      contents = File.read(file_path)
      contents.gsub!('include Blacklight::Solr::SearchBuilderBehavior', "include Blacklight::Solr::SearchBuilderBehavior\n  include IiifPrint::AllinsonFlexFields")
      contents.gsub!('self.default_processor_chain += [:ocr_search_params]', 'self.default_processor_chain += %i[ocr_search_params include_allinson_flex_fields]')
      File.write(file_path, contents)
    end
  end
end
