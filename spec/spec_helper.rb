require 'json'

# testing environent:
ENV['RAILS_ENV'] ||= 'test'

require 'coveralls'
Coveralls.wear!

require 'shoulda/matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
  end
end

# engine_cart:
require 'bundler/setup'
require 'engine_cart'
EngineCart.load_application!

# webmock
require 'webmock'
# include WebMock API makes stub_request available in initial config, not
#   just inside tests:
include WebMock::API
# Allow connections to pass through by default, so that any before(:suite)
#   hook that runs before WebMock config isn't affected:
WebMock.allow_net_connect!

# test account for Geonames-related specs
Qa::Authorities::Geonames.username = 'newspaper_works'

require 'rails-controller-testing'
require 'rspec/rails'
require 'support/controller_level_helpers'
require 'rspec/active_model/mocks'
require 'selenium-webdriver'
require 'webdrivers'

# @note In January 2018, TravisCI disabled Chrome sandboxing in its Linux
#       container build environments to mitigate Meltdown/Spectre
#       vulnerabilities, at which point Hyrax could no longer use the
#       Capybara-provided :selenium_chrome_headless driver (which does not
#       include the `--no-sandbox` argument).
Capybara.register_driver :selenium_chrome_headless_sandboxless do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  browser_options.args << '--no-sandbox'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.default_driver = :rack_test # This is a faster driver
Capybara.javascript_driver = :selenium_chrome_headless_sandboxless # This is slower

# FIXME: Pin to older version of chromedriver to avoid issue with clicking non-visible elements
Webdrivers::Chromedriver.required_version = '72.0.3626.69'

ActiveJob::Base.queue_adapter = :test

module EngineRoutes
  def self.included(base)
    base.routes { NewspaperWorks::Engine.routes }
  end
end

RSpec.configure do |config|
  # enable FactoryBot:
  require 'factory_bot'
  config.include FactoryBot::Syntax::Methods
  # auto-detect and load all factories in spec/factories:
  FactoryBot.find_definitions

  config.infer_spec_type_from_file_location!

  # Transactional
  config.use_transactional_fixtures = false
  config.include Devise::Test::ControllerHelpers, type: :controller

  # require shared examples
  require 'lib/newspaper_works/ingest/ingest_shared'

  config.include(ControllerLevelHelpers, type: :helper)
  config.before(:each, type: :helper) { initialize_controller_helpers(helper) }

  config.include(ControllerLevelHelpers, type: :view)
  config.before(:each, type: :view) { initialize_controller_helpers(view) }

  config.before(:all, type: :feature) do
    # Assets take a long time to compile. This causes two problems:
    # 1) the profile will show the first feature test taking much longer than it
    #    normally would.
    # 2) The first feature test will trigger rack-timeout
    #
    # Precompile the assets to prevent these issues.
    visit "/assets/application.css"
    visit "/assets/application.js"
  end

  config.include EngineRoutes, type: :controller

  # ensure Hyrax has active sipity workflow for default admin set:
  config.before(:suite) do
    begin
      # ensure permission template actually exists in RDBMS:
      id = 'admin_set/default'
      no_template = Hyrax::PermissionTemplate.find_by(source_id: id).nil?
      Hyrax::PermissionTemplate.create!(source_id: id) if no_template
      # ensure workflows exist, presumes permission template does first:
      Hyrax::Workflow::WorkflowImporter.load_workflows
      # Default admin set needs to exist in Fedora, with relation to its
      #   PermissionTemplate object:
      begin
        admin_set = AdminSet.find(AdminSet.find_or_create_default_admin_set_id)
        admin_set.save!
      rescue ActiveRecord::RecordNotUnique
        admin_set = AdminSet.find(AdminSet::DEFAULT_ID)
      end
      permission_template = admin_set.permission_template
      workflow = permission_template.available_workflows.where(
        name: 'default'
      ).first
      Sipity::Workflow.activate!(
        permission_template: permission_template,
        workflow_id: workflow.id
      )
    rescue Faraday::ConnectionFailed
      STDERR.puts "Attempting to run test suite without Fedora and/or Solr..."
    end
  end

  # enable WebMock, but make sure it is opt-in for stubs, allowing non-stubbed
  # HTTP requests to proceed normally
  config.before(:suite) do
    WebMock.enable!
    WebMock.allow_net_connect!
    # Load stubs from manifest
    fixtures = File.join(NewspaperWorks::GEM_PATH, 'spec', 'fixtures', 'files')
    manifest_path = File.join(fixtures, 'resource_mocks', 'urls.json')
    manifest = JSON.parse(File.read(manifest_path))
    manifest['urls'].each do |r|
      path = File.join(fixtures, 'resource_mocks', r['local'])
      status = r['status'] || 200
      stub_request(:any, r['url']).to_return(
        body: File.open(path),
        status: status
      )
    end
  end
  # ensure HTTP connections allowed by webmock between/before tests:
  config.before { WebMock.allow_net_connect! }

  # :perform_enqueued config setting below copied from Hyrax spec_helper.rb
  config.before(:example, :perform_enqueued) do |example|
    ActiveJob::Base.queue_adapter.filter = example.metadata[:perform_enqueued].try(:to_a)
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
  end
  config.after(:example, :perform_enqueued) do
    ActiveJob::Base.queue_adapter.filter = nil
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = false
  end

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # The settings below are suggested to provide a good initial experience
  # with RSpec, but feel free to customize to your heart's content.

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  # config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  # config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  # config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  # if config.files_to_run.one?
  # Use the documentation formatter for detailed output,
  # unless a formatter has already been configured
  # (e.g. via a command-line flag).
  #  config.default_formatter = "doc"
  # end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  # config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  # config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  # Kernel.srand config.seed
  # end
end

# ===
#   Means to suppress pending by running something like:
#   $ SUPPRESS_PENDING=1 rspec -fd
# ===
module SuccinctFormatterOverrides
  def example_pending(_) end

  def dump_pending(_) end
end

unless ENV['SUPPRESS_PENDING'].nil?
  RSpec::Core::Formatters::DocumentationFormatter.prepend SuccinctFormatterOverrides
  RSpec::Core::Formatters::ProgressFormatter.prepend SuccinctFormatterOverrides
end
