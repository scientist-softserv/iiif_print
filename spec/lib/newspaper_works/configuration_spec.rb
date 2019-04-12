require 'spec_helper'

RSpec.describe NewspaperWorks::Configuration do
  subject { described_class.new }

  it { is_expected.to respond_to(:publication_unique_id_property) }
  it { is_expected.to respond_to(:publication_unique_id_field) }

  describe '#publicationunique_id_property' do
    subject { described_class.new.publication_unique_id_property }
    it { is_expected.to eq(:lccn) }
  end

  describe '#publication_unique_id_field' do
    subject { described_class.new.publication_unique_id_field }
    it { is_expected.to eq('lccn_tesim') }
  end
end
