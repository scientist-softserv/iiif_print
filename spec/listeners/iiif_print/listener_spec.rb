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
end
