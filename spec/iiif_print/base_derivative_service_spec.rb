require 'spec_helper'

RSpec.describe IiifPrint::BaseDerivativeService do
  let(:file_set) { double(FileSet) }
  let(:service) { described_class.new(file_set) }

  describe '#valid?' do
    subject { service.valid? }

    context 'when given an image file' do
      let(:file_set) { double(FileSet, mime_type: 'image/tiff', class: FileSet) }

      it { is_expected.to be_truthy }
    end

    context 'when given a non-image file' do
      let(:file_set) { double(FileSet, mime_type: 'audio/mpeg', class: FileSet) }

      it { is_expected.to be_falsey }
    end
  end

  describe "instance" do
    subject { service }

    it { is_expected.to respond_to :target_extension }
  end
end
