# Test App Generator
require 'rails/generators'
require 'byebug'
class TestAppGenerator < Rails::Generators::Base
  source_root File.expand_path('../../../spec/test_app_templates', __dir__)

  def install_redis
    gem 'redis', '4.8.1'
    Bundler.with_unbundled_env do
      run "bundle install"
    end
  end

  def install_hyrax
    generate 'hyrax:install', '-f'
  end

  # TODO not sure why this doesnt work
  # just copy them manually for the moment
  def install_config_files
    copy_file 'blacklight.yml', 'config/blacklight.yml'
    copy_file 'fedora.yml', 'config/fedora.yml'
    copy_file 'redis.yml', 'config/redis.yml'
    copy_file 'solr.yml', 'config/solr.yml'
    copy_file 'solr/conf/schema.xml', 'solr/conf/schema.xml'
    copy_file 'solr/conf/solrconfig.xml', 'solr/conf/solrconfig.xml'
  end

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
