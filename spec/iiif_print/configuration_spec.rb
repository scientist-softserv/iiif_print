require 'spec_helper'

RSpec.describe IiifPrint::Configuration do
  let(:config) { described_class.new }

  describe "#metadata_fields" do
    subject { config.metadata_fields }

    it { is_expected.to be_a Hash }
    it "allows for an override" do
      original = config.metadata_fields
      config.metadata_fields = { title: {} }
      expect(config.metadata_fields).not_to eq original
    end
  end

  describe "#sort_iiif_manifest_canvases_by" do
    subject { config.sort_iiif_manifest_canvases_by }

    it { is_expected.to be_a Symbol }
    it "allows for an override" do
      original = config.sort_iiif_manifest_canvases_by
      config.sort_iiif_manifest_canvases_by = :title
      expect(config.metadata_fields).not_to eq original
    end
  end

  describe "#handle_after_create_fileset" do
    let(:file_set) { double(FileSet) }
    let(:user) { double(User) }
    subject(:called_function) { config.handle_after_create_fileset(file_set, user) }

    context "without configuration" do
      it "calls IiifPrint::Data.handle_after_create_fileset" do
        expect(IiifPrint::Data).to receive(:handle_after_create_fileset).with(file_set, user)

        called_function
      end
    end

    context "with configuration" do
      let(:config_func) { ->(_file_set, _user) { :yup } }

      it "calls the given configured lambda" do
        config.after_create_fileset_handler = config_func
        expect(IiifPrint::Data).not_to receive(:handle_after_create_fileset)
        expect(config_func).to receive(:call).with(file_set, user)
        called_function
      end
    end
  end

  describe '#additional_tessearct_options' do
    context "by default" do
      subject { config.additional_tessearct_options }
      it { is_expected.not_to be_present }
    end

    it "can be configured" do
      expect do
        config.additional_tessearct_options = "-l esperanto"
      end.to change(config, :additional_tessearct_options)
        .from("")
        .to("-l esperanto")
    end
  end
end
