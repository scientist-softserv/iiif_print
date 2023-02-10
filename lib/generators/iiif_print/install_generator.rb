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
      generate 'blacklight_iiif_search:install'
    end

    def iiif_configuration
      generate 'iiif_print:blacklight_iiif_search'
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
  end
end
