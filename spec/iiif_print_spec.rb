require 'spec_helper'

RSpec.describe IiifPrint do
  describe ".manifest_metadata_for" do
    let(:model) { double(title: "My Title", metadata_fields: [:title]) }

    subject(:manifest_metadata) { described_class.manifest_metadata_for(model: model, version: version) }
    context "for version 2 of the IIIF spec" do
      let(:version) { 2 }
      it "maps the metadata accordingly" do
        expect(manifest_metadata).to eq [{ "label" => "Title", "value" => ["My Title"] }]
      end
    end

    context "for version 3 of the IIIF spec" do
      let(:version) { 3 }
      it "maps the metadata accordingly" do
        # Note: this assumes the I18n.locale is set as :en
        expect(manifest_metadata).to eq [{ "label" => { I18n.locale.to_s => ["Title"] }, "value" => { "none" => ["My Title"] } }]
      end
    end
  end
  describe ".model_configuration" do
    context "default configuration" do
      let(:model) do
        Class.new do
          include IiifPrint.model_configuration(pdf_split_child_model: Class.new)
        end
      end

      subject(:record) { model.new }

      it { is_expected.to be_iiif_print_config }

      it "has a #pdf_splitter_job" do
        # TODO: This should be a class that is a Job but we don't yet have that.
        expect(record.iiif_print_config.pdf_splitter_job).to be_present
      end
    end
  end
end
