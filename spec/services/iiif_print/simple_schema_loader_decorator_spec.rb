# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hyrax::SimpleSchemaLoader do
  subject(:instance) { described_class.new }

  context '#config_search_paths' do
    subject  { instance.config_search_paths }

    # Would it make sense for IiifPrint::Engine to come before Hyrax::Engine?  As IiifPrint depends
    # on Hyrax.
    it { is_expected.to match_array([Rails.root, Hyrax::Engine.root, IiifPrint::Engine.root]) }
  end
end
