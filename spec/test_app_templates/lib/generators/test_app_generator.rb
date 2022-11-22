# Test App Generator
require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root './spec/test_app_templates'

  def install_redis
    gem 'redis', '4.8.0'
    Bundler.with_clean_env do
      run "bundle install"
    end
  end

  def install_hyrax
    generate 'hyrax:install', '-f'
  end

  def create_config_files
    copy_file 'config/blacklight.yaml', 'config/blacklight.yaml'
    copy_file 'config/fcrepo.yaml', 'config/fcrepo.yaml'
    copy_file 'config/redis.yaml', 'config/redis.yaml'
    copy_file 'config/solr.yaml', 'config/solr.yaml'
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
