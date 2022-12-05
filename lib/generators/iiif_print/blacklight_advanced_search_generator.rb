# adds controller-scope behavior to the implementing application
require 'rails/generators'

module IiifPrint
  class BlacklightAdvancedSearchGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "
  This generator makes the following changes to your app:
   1. Creates a new SearchBuilder class that inherits from Hyrax::CatalogSearchBuilder
   2. Adjusts config.search_builder_class settings in CatalogController
   3. Adds configuration to config.advanced_search settings in CatalogController
   4. Adds an initializer to patch some BlacklightAdvancedSearch classes to allow for date range searches
         "

    def inject_search_builder
      copy_file 'custom_search_builder.rb',
                'app/models/custom_search_builder.rb'
    end

    def update_search_builder
      gsub_file('app/controllers/catalog_controller.rb',
                "config.search_builder_class = Hyrax::CatalogSearchBuilder",
                "config.search_builder_class = CustomSearchBuilder")
    end

    def inject_initializer
      copy_file 'config/initializers/patch_blacklight_advanced_search.rb'
    end
  end
end
