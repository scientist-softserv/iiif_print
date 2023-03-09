require 'spec_helper'
require 'misc_shared'

RSpec.describe IiifPrint::Jobs::ChildWorksFromPdfJob do
  # TODO: add specs
  let(:work) { WorkWithIiifPrintConfig.new(title: ['required title'], id: '123') }
  let(:my_user) { build(:user) }
  let(:uploaded_pdf_file) { create(:uploaded_pdf_file) }
  let(:uploaded_file_ids) { [uploaded_pdf_file.id] }
  let(:pdf_paths) do
    uploads = Hyrax::UploadedFile.find(uploaded_file_ids)
    upload_paths = uploads.map { |upload| upload.file.file.file }
    upload_paths.select { |path| path.end_with?('.pdf', '.PDF') }
  end
  let(:admin_set_id) { "admin_set/default" }
  let(:prior_pdfs) { 0 }

  let(:subject) { described_class.perform_now(work, pdf_paths, my_user, admin_set_id, prior_pdfs) }

  describe '#perform' do
    xit 'calls pdf splitter service with path' do
    end

    xit 'submits one BatchCreateJob per PDF' do
    end

    xit 'submits IiifPrint::Jobs::CreateRelationshipsJob' do
    end

    context 'with more than 9 pages' do
      xit 'pads the page number with a zero' do
      end
    end
  end
end
