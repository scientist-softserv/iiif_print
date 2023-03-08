require 'spec_helper'

RSpec.describe IiifPrint::SplitPdfs::PagesToPngsSplitter do
  describe '.compression' do
    subject { described_class.compression }
    it { is_expected.to be_nil }
  end

  describe '.compression?' do
    subject { described_class.compression? }
    it { is_expected.to be_falsey }
  end

  describe '.image_extension' do
    subject { described_class.image_extension }
    it { is_expected.to eq('png') }
  end
end
