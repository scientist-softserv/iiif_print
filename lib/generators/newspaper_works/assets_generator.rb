require 'rails/generators'

module NewspaperWorks
  class AssetsGenerator < Rails::Generators::Base
    desc "This generator installs the newspaper_works CSS assets into your application"

    source_root File.expand_path('../templates', __FILE__)

    def inject_css
      copy_file "newspaper_works.scss", "app/assets/stylesheets/newspaper_works.scss"
    end
  end
end
