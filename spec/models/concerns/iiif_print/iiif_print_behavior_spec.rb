require 'spec_helper'
RSpec.describe IiifPrint::IiifPrintBehavior do
  describe "including_this_module" do
    before do
      class PrintWork < ActiveFedora::Base
        include IiifPrint::IiifPrintBehavior
      end
    end
    let(:klass) { Class.new }
    subject { PrintWork.new }

    describe 'split_pdf' do
      it 'is true' do
        expect(subject.split_pdf).to be true
      end
    end
  end
end
