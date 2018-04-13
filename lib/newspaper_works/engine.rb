require 'active_fedora'
require 'hyrax'

module NewspaperWorks
  class Engine < ::Rails::Engine
    isolate_namespace NewspaperWorks
  end
end
