require 'spec_helper'

RSpec.describe 'Routes', type: :routing do
  routes { IiifPrint::Engine.routes }
end
