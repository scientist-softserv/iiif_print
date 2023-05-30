require 'spec_helper'

RSpec.describe IiifPrint::SplitPdfs::BaseSplitter do
  let(:path) { __FILE__ }
  let(:splitter) { described_class.new(path) }
  subject { described_class }

  it { is_expected.to respond_to(:call) }

  describe "instance" do
    subject { splitter }

    it { is_expected.to respond_to :compression }
    it { is_expected.to respond_to :compression? }
    it { is_expected.to respond_to :image_extension }
    it { is_expected.to respond_to :quality }
  end

  describe '#compression' do
    it 'can be changed within the instance' do
      expect do
        splitter.compression = 'squishy'
      end.not_to change(splitter.class, :compression)
      expect(splitter.compression).to eq('squishy')
    end
  end
end
