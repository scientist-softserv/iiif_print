require 'spec_helper'
require 'misc_shared'

RSpec.describe IiifPrint::SplitPdfs::PagesToJpgsSplitter do
  describe '.quality' do
    subject { described_class.quality }
    it { is_expected.to eq(described_class::DEFAULT_QUALITY) }
  end

  describe '.quality?' do
    subject { described_class.quality? }
    it { is_expected.to be_truthy }
  end

  describe '.image_extension' do
    subject { described_class.image_extension }
    it { is_expected.to eq('jpg') }
  end
end
