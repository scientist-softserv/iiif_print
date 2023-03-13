require 'spec_helper'

RSpec.describe IiifPrint::BaseDerivativeService do
  let(:file_set) { double(FileSet) }
  let(:service) { described_class.new(file_set) }

  describe '#valid?' do
    subject { service.valid? }

    it { is_expected.to be_truthy }
  end

  describe "instance" do
    subject { service }

    it { is_expected.to respond_to :target_extension }
  end
end
