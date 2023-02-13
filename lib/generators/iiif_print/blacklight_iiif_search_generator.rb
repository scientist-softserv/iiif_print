# adds controller-scope behavior to the implementing application
require 'rails/generators'

module IiifPrint
  class BlacklightIiifSearchGenerator < Rails::Generators::Base
    desc "
      This generator makes the following changes to your app:

      1. Adjusts Blacklight IIIF Search configuration settings in CatalogController
      "

    # Update the blacklight catalog controller
    def adjust_catalog_controller_all_text_config
      gsub_file('app/controllers/catalog_controller.rb',
                " full_text_field: 'text',",
                " full_text_field: 'all_text_tsimv',")
    end

    def adjust_catalog_controller_is_page_of_config
      gsub_file('app/controllers/catalog_controller.rb',
                " object_relation_field: 'is_page_of_s',",
                " object_relation_field: 'is_page_of_ssim',")
    end
  end
end
