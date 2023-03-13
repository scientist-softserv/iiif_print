require 'spec_helper'
require 'misc_shared'

RSpec.describe IiifPrint::SplitPdfs::PagesToJpgsSplitter do
  let(:path) { __FILE__ }
  let(:splitter) { described_class.new(path) }

  describe '#quality' do
    subject { splitter.quality }
    it { is_expected.to eq(described_class.quality) }
  end

  describe '#quality?' do
    subject { splitter.quality? }
    it { is_expected.to be_truthy }
  end

  describe '#image_extension' do
    subject { splitter.image_extension }
    it { is_expected.to eq('jpg') }
  end
end
