# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IiifPrint::SplitPdfs::DerivativeRodeoSplitter do
  let(:path) { __FILE__ }
  let(:work) { double(MyWork, aark_id: '12345') }
  let(:file_set) { FileSet.new.tap { |fs| fs.save!(validate: false) } }

  describe 'class' do
    subject { described_class }

    it { is_expected.to respond_to(:call) }
  end

  describe "instance" do
    subject { described_class.new(path, file_set: file_set) }
    let(:generator) { double(DerivativeRodeo::Generators::PdfSplitGenerator, generated_files: []) }

    before do
      allow(file_set).to receive(:parent).and_return(work)
      # TODO: This is a hack that leverages the internals of Hydra::Works; not excited about it but
      # this part is only one piece of the over all integration.
      allow(file_set).to receive(:original_file).and_return(double(original_filename: __FILE__))
    end

    it { is_expected.to respond_to :split_files }

    it 'uses the rodeo to split' do
      expect(DerivativeRodeo::Generators::PdfSplitGenerator).to receive(:new).and_return(generator)
      described_class.call(path, file_set: file_set)
    end
  end
end
