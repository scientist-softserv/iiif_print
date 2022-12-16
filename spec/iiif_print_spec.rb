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
        # TODO: This should be a class that is a Job but we don't yet have that.
        expect(record.iiif_print_config.pdf_splitter_job).to be_present
      end
    end
  end
end
