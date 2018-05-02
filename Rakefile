
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'engine_cart/rake_task'

#Bundler.require(*Rails.groups)

#Rails.application.load_tasks

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

#task :ci => ['engine_cart:generate'] do
  # run the tests
#end

#RSpec::Core::RakeTask.new(:spec)

#task :default => :spec
#RSpec::Core::RakeTask.new

task :setup_test_server do
  require 'engine_cart'
  EngineCart.load_application!
end

Dir.glob('tasks/*.rake').each { |r| import r }

task default: :ci
