# Test App Generator
require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root './spec/test_app_templates'

  def install_hyrax
    generate 'hyrax:install', '-f'
  end

  def install_engine
    generate 'newspaper_works:install'
  end

  def db_migrations
    rake 'db:migrate'
  end

  def configure_browse_everything
    generate 'browse_everything:config'
  end
end
