# adds controller-scope behavior to the implementing application
require 'rails/generators'

module IiifPrint
  class CatalogControllerGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "
  This generator makes the following changes to your app:
   1. Adds index fields in CatalogController
   2. Adds facet fields in CatalogController
         "

    def add_index_fields_to_catalog_controller
      marker = 'configure_blacklight do |config|'
      inject_into_file 'app/controllers/catalog_controller.rb', after: marker do
        "\n\n    # IiifPrint index fields\n"\
        "    config.add_index_field 'all_text_tsimv', highlight: true, helper_method: :render_ocr_snippets\n"
      end
    end
  end
end
