require 'spec_helper'

RSpec.describe NewspaperWorks::Configuration do
  subject { described_class.new }
  it { is_expected.to respond_to(:title_unique_id_field) }

  describe '#title_unique_id_field' do
    subject { described_class.new.title_unique_id_field }
    it { is_expected.to eq('lccn_sim') }
  end
end
