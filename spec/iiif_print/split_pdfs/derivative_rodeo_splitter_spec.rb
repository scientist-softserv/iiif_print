# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IiifPrint::SplitPdfs::DerivativeRodeoSplitter do
  let(:filename) { __FILE__ }
  let(:work) { double(MyWork, id: 'id-12345', aark_id: '12345') }
  let(:file_set) { FileSet.new.tap { |fs| fs.save!(validate: false) } }
  let(:location_stub) { double(DerivativeRodeo::StorageLocations::BaseLocation, exist?: true) }

  before do
    allow(DerivativeRodeo::StorageLocations::BaseLocation).to receive(:from_uri).and_return(location_stub)
  end

  describe 'class' do
    subject { described_class }

    it { is_expected.to respond_to(:call) }
  end

  subject(:instance) { described_class.new(filename, file_set: file_set, output_tmp_dir: Dir.tmpdir) }
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
    described_class.call(filename, file_set: file_set)
  end

  describe '#preprocessed_location_template' do
    let(:derivative_rodeo_preprocessed_file) { IiifPrint::DerivativeRodeoService.derivative_rodeo_uri(file_set: file_set, filename: filename) }
    let(:import_url) { "https://somewhere.com/that/exists.pdf" }
    subject { instance.preprocessed_location_template }

    context 'when the s3 file exists in the rodeo' do
      it 'is that file' do
        is_expected.to eq(derivative_rodeo_preprocessed_file)
      end
    end

    context 'when the s3 file does not exist in the rodeo and we have the local file' do
      it 'is the import_url' do
        expect_any_instance_of(DerivativeRodeo::Generators::CopyGenerator).not_to receive(:generated_uris)
        file_set.import_url = import_url
        expect(instance).to receive(:rodeo_conformant_uri_exists?).with(derivative_rodeo_preprocessed_file).and_return(false)
        expect(instance).to receive(:rodeo_conformant_uri_exists?).with(instance.input_uri).and_return(true)
        expect(subject).to eq(instance.input_uri)
      end
    end

    context 'when the s3 file does not exist and we do not have the input URI nor the given import url does NOT exist' do
      let(:generator) { double(DerivativeRodeo::Generators::CopyGenerator, generated_uris: ["file:///generated/uri"]) }
      it 'will invoke the DerivativeRodeo::Generators::CopyGenerator to bring the file locally' do
        allow(DerivativeRodeo::Generators::CopyGenerator).to receive(:new).and_return(generator)
        file_set.import_url = import_url
        expect(instance).to receive(:rodeo_conformant_uri_exists?).with(derivative_rodeo_preprocessed_file).and_return(false)
        expect(instance).to receive(:rodeo_conformant_uri_exists?).with(instance.input_uri).and_return(false)

        expect(subject).to eq(generator.generated_uris.first)
      end
    end

    context "when the s3 file does not exist and we don't have a remote_url" do
      it 'will use the given filename' do
        file_set.import_url = nil
        expect(instance).to receive(:rodeo_conformant_uri_exists?).with(derivative_rodeo_preprocessed_file).and_return(false)

        expect(subject).to eq(nil)
      end
    end
  end
end
