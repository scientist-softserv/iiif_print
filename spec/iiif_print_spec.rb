require 'spec_helper'

RSpec.describe IiifPrint do
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
    end
  end
end
