begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

Bundler::GemHelper.install_tasks

require 'engine_cart/rake_task'

task :ci => ['engine_cart:generate'] do
  # run the tests
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
RSpec::Core::RakeTask.new
