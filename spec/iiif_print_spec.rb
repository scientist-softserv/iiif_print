require 'spec_helper'

RSpec.describe IiifPrint do
  describe ".manifest_metadata_for" do
    let(:attributes) do
      { "id" => "abc123",
        "title_tesim" => ['My Awesome Title'] }
    end
    let(:solr_document) { SolrDocument.new(attributes) }

    subject(:manifest_metadata) do
      described_class.manifest_metadata_for(model: solr_document, current_ability: double(Ability))
    end
    it { is_expected.not_to be_falsey }
    it "does not contain any nil values" do
      expect(subject).not_to include(nil)
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
