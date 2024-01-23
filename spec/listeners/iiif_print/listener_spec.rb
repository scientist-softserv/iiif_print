# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IiifPrint::Listener do
  describe '#on_file_set_attached' do
    subject { described_class.new.on_file_set_attached(event) }
    let(:file_set) { double(Hyrax::FileSet, file_set?: true) }
    let(:user) { double(User) }
    let(:event) { { user: user, file_set: file_set } }

    before { allow(IiifPrint).to receive(:parent_for).with(file_set).and_return(parent) }

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
        expect(IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService).to receive(:conditionally_enqueue)
        expect(file_set).to receive(:original_file).and_return(double)
        subject
      end
    end
  end

  describe '#on_object_deposited' do
    class Work < Hyrax::Work
      include Hyrax::Schema(:child_works_from_pdf_splitting)
    end
    subject { described_class.new.on_object_deposited(event) }

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
      expect(child_work.is_child).to be nil
      subject
      # gets a reloaded version of the child work
      expect(Hyrax.query_service.find_by(id: child_work.id).is_child).to be true
    end
  end
end
