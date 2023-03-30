require 'rspec/core/rake_task'
require 'engine_cart/rake_task'
require 'rubocop/rake_task'

desc 'Run style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

RSpec::Core::RakeTask.new(:spec)

desc 'Spin up test servers and run specs'
task :spec_with_app_load do
  require 'solr_wrapper'   # necessary for rake_support to work
  require 'fcrepo_wrapper' # necessary for rake_support to work
  require 'active_fedora/rake_support'
  with_test_server do
    Rake::Task['spec'].invoke
  end
end

if ENV.fetch('IN_DOCKER', false)
  desc 'Generate the engine_cart, copy authorities and spin up test servers and run specs'
  task ci: %w[rubocop engine_cart:generate engine_cart:copy_authorities] do
    puts 'running continuous integration'
    Rake::Task['spec'].invoke
  end
else
  desc 'Generate the engine_cart, copy authorities and spin up test servers and run specs'
  task ci: %w[rubocop engine_cart:generate engine_cart:copy_authorities] do
    puts 'running continuous integration'
    Rake::Task['spec_with_app_load'].invoke
  end
end
