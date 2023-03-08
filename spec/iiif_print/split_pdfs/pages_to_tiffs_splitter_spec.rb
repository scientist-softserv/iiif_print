require 'spec_helper'
require 'misc_shared'

RSpec.describe IiifPrint::SplitPdfs::PagesToTiffsSplitter do
  describe '.compression' do
    subject { described_class.compression }
    it { is_expected.to eq(described_class::DEFAULT_COMPRESSION) }
  end

  describe '.compression?' do
    subject { described_class.compression? }
    it { is_expected.to be_truthy }
  end

  describe '.image_extension' do
    subject { described_class.image_extension }
    it { is_expected.to eq('tiff') }
  end
end
