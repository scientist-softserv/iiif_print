require 'spec_helper'

RSpec.describe IiifPrint do
  describe ".manifest_metadata_for" do
    let(:attributes) do
      { "id" => "abc123",
        "title_tesim" => ['My Awesome Title'] }
    end
    let(:solr_document) { SolrDocument.new(attributes) }
    let(:base_url) { "https://my.dev.test" }

    subject(:manifest_metadata) do
      described_class.manifest_metadata_for(work: solr_document, current_ability: double(Ability), base_url: base_url)
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
        expect(record.iiif_print_config.pdf_splitter_job).to be(IiifPrint::Jobs::ChildWorksFromPdfJob)
      end

      it "has a #pdf_splitter_service" do
        expect(record.iiif_print_config.pdf_splitter_service).to be(IiifPrint::SplitPdfs::PagesIntoImagesService)
      end

      it "has #derivative_service_plugins" do
        expect(record.iiif_print_config.derivative_service_plugins).to eq(
          [IiifPrint::JP2DerivativeService,
           IiifPrint::PDFDerivativeService,
           IiifPrint::TextExtractionDerivativeService,
           IiifPrint::TIFFDerivativeService]
        )
      end
    end
  end
end
