require 'spec_helper'

RSpec.describe IiifPrint::BaseDerivativeService do
  describe '#valid?' do
    let(:file_set) { double(FileSet) }
    let(:service) { described_class.new(file_set) }
    subject { service.valid? }

    it { is_expected.to be_truthy }
  end
end
