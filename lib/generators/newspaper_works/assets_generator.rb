require 'rails/generators'

module NewspaperWorks
  class AssetsGenerator < Rails::Generators::Base
    desc "This generator installs the newspaper_works CSS assets into your application"

    source_root File.expand_path('../templates', __FILE__)

    def inject_css
      copy_file "newspaper_works.scss", "app/assets/stylesheets/newspaper_works.scss"
    end

    def inject_js
      return if newspaper_works_js_installed?
      insert_into_file 'app/assets/javascripts/application.js', after: '//= require hyrax' do
        <<-JS.strip_heredoc

        //= require newspaper_works
        JS
      end
    end

    private

    def newspaper_works_js_installed?
      IO.read("app/assets/javascripts/application.js").include?('newspaper_works')
    end
  end
end
