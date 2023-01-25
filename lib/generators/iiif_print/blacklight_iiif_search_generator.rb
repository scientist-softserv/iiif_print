# adds controller-scope behavior to the implementing application
require 'rails/generators'

module IiifPrint
  class BlacklightIiifSearchGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "
  This generator makes the following changes to your app:
   1. Adjusts Blacklight IIIF Search configuration settings in CatalogController
   2. Adjusts Blacklight IIIF Search configuration settings in IiifSearchBuilder
   3. creates a new BlacklightIiifSearch::SearchBehavior module
   4. creates a new BlacklightIiifSearch::AnnotationBehaviorBehavior module
         "

    # Update the blacklight catalog controller
    def adjust_catalog_controller_all_text_config
      gsub_file('app/controllers/catalog_controller.rb',
                "     full_text_field: 'text',",
                "     full_text_field: 'all_text_tsimv',")
    end

    def adjust_catalog_controller_is_page_of_config
      gsub_file('app/controllers/catalog_controller.rb',
                "      object_relation_field: 'is_page_of_s',",
                "      object_relation_field: 'is_page_of_ssim',")
    end

    def inject_search_behavior
      copy_file 'search_behavior.rb',
                'app/models/concerns/blacklight_iiif_search/search_behavior.rb'
    end

    def inject_annotation_behavior
      copy_file 'annotation_behavior.rb',
                'app/models/concerns/blacklight_iiif_search/annotation_behavior.rb'
    end
  end
end
