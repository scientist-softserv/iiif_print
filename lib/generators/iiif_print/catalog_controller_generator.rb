# adds controller-scope behavior to the implementing application
require 'rails/generators'

module IiifPrint
  class CatalogControllerGenerator < Rails::Generators::Base
    desc "
      This generator makes the following changes to your app:
      1. Adds index fields in CatalogController
      2. Adjusts Blacklight IIIF Search configuration settings in CatalogController
      "

    def add_index_fields_to_catalog_controller
      marker = 'configure_blacklight do |config|'
      inject_into_file 'app/controllers/catalog_controller.rb', after: marker do
        "\n\n    # IiifPrint index fields\n"\
        "    config.add_index_field 'all_text_tsimv', highlight: true, helper_method: :render_ocr_snippets\n"
      end
    end

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
