# adds controller-scope behavior to the implementing application
require 'rails/generators'

module NewspaperWorks
  class CatalogControllerGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc "
  This generator makes the following changes to your app:
   1. Adds index fields in CatalogController
   2. Adds facet fields in CatalogController
   3. Adds sort fields in CatalogController
         "

    def add_index_fields_to_catalog_controller
      marker = 'configure_blacklight do |config|'
      inject_into_file 'app/controllers/catalog_controller.rb', after: marker do
        "\n\n    # NewspaperWorks index fields\n"\
        "    config.add_index_field 'publication_title_ssi', label: I18n.t('newspaper_works.attributes.publication_title.label'), link_to_search: 'publication_title_ssi'\n"\
        "    config.add_index_field solr_name('publication_date', :stored_sortable, type: :date), label: 'Publication date', helper_method: :human_readable_date\n"\
        "    config.add_index_field solr_name('place_of_publication_label', :stored_searchable), label: I18n.t('newspaper_works.attributes.place_of_publication.label'), link_to_search: solr_name('place_of_publication_label', :facetable)\n"\
        "    config.add_index_field solr_name('publication_date_start', :stored_sortable, type: :date), label: 'Publication date (start)', helper_method: :human_readable_date\n"\
        "    config.add_index_field solr_name('publication_date_end', :stored_sortable, type: :date), label: 'Publication date (end)', helper_method: :human_readable_date\n"\
        "    config.add_index_field 'all_text_tsimv', highlight: true, helper_method: :render_ocr_snippets\n"
      end
    end

    def add_facets_to_catalog_controller
      marker = 'configure_blacklight do |config|'
      inject_into_file 'app/controllers/catalog_controller.rb', after: marker do
        "\n\n    # NewspaperWorks facet fields\n"\
        "    config.add_facet_field solr_name('place_of_publication_city', :facetable), label: 'Place of publication', limit: 5\n"\
        "    config.add_facet_field 'publication_title_ssi', label: 'Publication title', limit: 5\n"\
        "    config.add_facet_field solr_name('genre', :facetable), label: 'Article type', limit: 5\n\n"\
        "    # additional NewspaperWorks fields not displayed in the facet list,\n"\
        "    # but below definitions give labels to filters for linked metadata\n"\
        "    config.add_facet_field solr_name('place_of_publication_label', :facetable), label: 'Place of publication', if: false\n"\
        "    config.add_facet_field solr_name('issn', :facetable), label: 'ISSN', if: false\n"\
        "    config.add_facet_field solr_name('lccn', :facetable), label: 'LCCN', if: false\n"\
        "    config.add_facet_field solr_name('oclcnum', :facetable), label: 'OCLC #', if: false\n"\
        "    config.add_facet_field solr_name('held_by', :facetable), label: 'Held by', if: false\n"\
        "    config.add_facet_field solr_name('author', :facetable), label: 'Author', if: false\n"\
        "    config.add_facet_field solr_name('photographer', :facetable), label: 'Photographer', if: false\n"\
        "    config.add_facet_field solr_name('geographic_coverage', :facetable), label: 'Geographic coverage', if: false\n"\
        "    config.add_facet_field solr_name('preceded_by', :facetable), label: 'Preceded by', if: false\n"\
        "    config.add_facet_field solr_name('succeeded_by', :facetable), label: 'Succeeded by', if: false\n"\
        "    config.add_facet_field 'first_page_bsi', label: 'First page', if: false\n"
      end
    end

    def add_pubdate_sort_to_catalog_controller
      marker = 'config.add_sort_field "#{modified_field} asc", label: "date modified \u25B2"'
      inject_into_file 'app/controllers/catalog_controller.rb', after: marker do
        "\n\n    # NewspaperWorks sort fields\n"\
        '    config.add_sort_field "publication_date_dtsi desc", label: "publication date \u25BC"
    config.add_sort_field "publication_date_dtsi asc", label: "publication date \u25B2"'
      end
    end
  end
end
