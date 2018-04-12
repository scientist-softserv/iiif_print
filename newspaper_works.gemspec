$:.push File.expand_path("../lib", __FILE__)

# version updated in one place:
require "newspaper_works/version"

# Gem description:
Gem::Specification.new do |spec|
  spec.name        = "newspaper_works"
  spec.version     = NewspaperWorks::VERSION
  spec.authors     = ["Sean Upton"]
  spec.email       = ["sean.upton@utah.edu"]
  spec.homepage    = "https://github.com/marriott-library/newspaper_works"
  spec.description = "Gem/Engine for Newspaper Works in Hyrax-based Samvera Applicationspec."
  spec.summary     = <<-SUMMARY
  newspaper_works is a Rails Engine gem providing model and administrative
  functions to Hyrax-based Samvera applications, for management of
  (primarily scanned) archival newspaper content.
SUMMARY
  spec.license     = "Apache-2.0"
  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  spec.add_dependency "rails", "~> 5.0.7"
  spec.add_dependency "hyrax"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-rails', '~> 3.1'
  spec.add_development_dependency 'engine_cart', '~> 2.0'
  spec.add_development_dependency 'solr_wrapper', '~> 0.4'
  spec.add_development_dependency 'fcrepo_wrapper', '~> 0.1'
end
