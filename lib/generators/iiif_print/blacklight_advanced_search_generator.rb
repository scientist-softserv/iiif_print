# adds controller-scope behavior to the implementing application
require 'rails/generators'

module IiifPrint
  class BlacklightAdvancedSearchGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "
      This generator makes the following changes to your app:
      1. Adjusts config.search_builder_class settings in CatalogController
      2. Adds an initializer to patch some BlacklightAdvancedSearch classes to allow for date range searches
      "

    def update_search_builder
      gsub_file('app/controllers/catalog_controller.rb',
                "config.search_builder_class = Hyrax::CatalogSearchBuilder",
                "config.search_builder_class = IiifPrint::CatalogSearchBuilder")
    end

    # TODO: I suspect this is something else to further adjust.
    def inject_initializer
      copy_file 'config/initializers/patch_blacklight_advanced_search.rb'
    end
  end
end
