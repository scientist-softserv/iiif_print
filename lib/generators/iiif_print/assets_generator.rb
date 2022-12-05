require 'rails/generators'

module IiifPrint
  class AssetsGenerator < Rails::Generators::Base
    desc "This generator installs the iiif_print CSS assets into your application"

    source_root File.expand_path('../templates', __FILE__)

    def inject_css
      copy_file "iiif_print.scss", "app/assets/stylesheets/iiif_print.scss"
    end

    def inject_js
      return if iiif_print_js_installed?
      insert_into_file 'app/assets/javascripts/application.js', after: '//= require hyrax' do
        <<-JS.strip_heredoc

        //= require iiif_print
        JS
      end
    end

    private

    def iiif_print_js_installed?
      IO.read("app/assets/javascripts/application.js").include?('iiif_print')
    end
  end
end
