require 'active_fedora'
require 'hyrax'

module NewspaperWorks
  # module constants:
  GEM_PATH = Gem::Specification.find_by_name("newspaper_works").gem_dir

  # Engine Class
  class Engine < ::Rails::Engine
    isolate_namespace NewspaperWorks
  end
end
