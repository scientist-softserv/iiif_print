# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IiifPrint::Listener do
  describe '#on_file_characterized' do
    subject { described_class.new.on_file_characterized(event) }
    let(:file_set) { double(Hyrax::FileSet, file_set?: true) }
    let(:file_metadata) { double(Hyrax::FileMetadata) }
    let(:user) { double(User) }
    let(:event) { { user: user, file_set: file_set } }

    before do
      allow(IiifPrint).to receive(:parent_for).with(file_set).and_return(parent)
      allow(file_set).to receive(:original_file).and_return(file_metadata)
      allow(file_metadata).to receive(:pdf?).and_return(true)
    end

    context 'without a parent work' do
      let(:parent) { nil }

      it "does not call the service's #conditionally_enqueue method" do
        expect(IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService).not_to receive(:conditionally_enqueue)
        subject
      end
    end

    context 'with a parent work' do
      let(:parent) { double(Valkyrie::Resource) }

      it "calls the service's #conditionally_enqueue method" do
        allow(parent).to receive(:depositor).and_return(double('User'))

        expect(IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService).to receive(:conditionally_enqueue)
        subject
      end
    end
  end

  describe '#on_object_membership_updated' do
    class Work < Hyrax::Work
      include Hyrax::Schema(:child_works_from_pdf_splitting)

      def iiif_print_config?
        true
      end
    end

    subject { described_class.new.on_object_membership_updated(event) }

    let(:event) { { object: parent_work } }
    let(:parent_work) do
      parent_work = Work.new
      parent_work.title = ['Parent Work']
      Hyrax.persister.save(resource: parent_work)
    end
    let(:child_work) do
      child_work = Work.new
      child_work.title = ['Child Work']
      Hyrax.persister.save(resource: child_work)
    end

    before do
      parent_work.member_ids << child_work.id
      Hyrax.persister.save(resource: parent_work)
      Hyrax.index_adapter.save(resource: parent_work)
    end

    it 'sets the is_child flag on the child work' do
      expect { subject }.to change { Hyrax.query_service.find_by(id: child_work.id).is_child }.to(true)
    end
  end
end
