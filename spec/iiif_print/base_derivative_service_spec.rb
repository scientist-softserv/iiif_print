require 'spec_helper'

RSpec.describe IiifPrint::BaseDerivativeService do
  describe '#valid?' do
    subject(:service) { described_class.new(file_set) }

    context 'when parent is iiif_print configured' do
      let(:file_set) { double(FileSet, in_works: [work]) }
      let(:work) { WorkWithIiifPrintConfig.new }

      it { is_expected.to be_valid }
    end

    context 'when parent is not iiif_print configured' do
      let(:file_set) { double(FileSet, in_works: [work]) }
      let(:work) { WorkWithOutConfig.new }

      it { is_expected.not_to be_valid }
    end
  end
end
