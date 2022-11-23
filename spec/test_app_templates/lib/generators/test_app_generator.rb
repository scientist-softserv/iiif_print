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

  # TODO not sure why this doesnt work
  # just copy them manually for the moment
  # def install_config_files
  #   copy_file 'blacklight.yml', 'config/blacklight.yml'
  #   copy_file 'fcrepo.yml', 'config/fcrepo.yml'
  #   copy_file 'redis.yml', 'config/redis.yml'
  #   copy_file 'solr.yml', 'config/solr.yml'
  # end

  def install_engine
    generate 'iiif_print:install'
  end

  def db_migrations
    rake 'db:migrate'
  end

  def configure_browse_everything
    generate 'browse_everything:config'
  end
end
