
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Rails.application.load_tasks

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

Bundler::GemHelper.install_tasks

require 'engine_cart/rake_task'

RSpec::Core::RakeTask.new(:spec)
