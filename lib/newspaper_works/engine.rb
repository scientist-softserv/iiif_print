require 'active_fedora'
require 'hyrax'

module NewspaperWorks
  # Engine Class
  class Engine < ::Rails::Engine
    isolate_namespace NewspaperWorks
  end
end
