# Scanned Media Metada Spec Tests
RSpec.describe NewspaperWorks::ScannedMediaMetadata do
  class ScannedMediaWork < ActiveFedora::Base
    include ::Hyrax::WorkBehavior
    include NewspaperWorks::ScannedMediaMetadata
    include ::Hyrax::BasicMetadata
  end

  let(:work) { ScannedMediaWork.new }

  it 'creates work using mixin' do
    expect(work).to be_an_instance_of(ScannedMediaWork)
  end

  it 'has expected properties' do
    expect(work).to respond_to(:text_direction)
    expect(work).to respond_to(:page_number)
    expect(work).to respond_to(:section)
  end

  it 'work can set/get properties' do
    work.section = 'foo'
    expect(work.section).to include 'foo'
  end

  it 'work using mixin saves' do
    work.title = ['label able label']
    expect(work.id).to be_nil
    work.save!
    expect(work.id).not_to be_nil
    expect(ScannedMediaWork.all.map(&:id)).to include(work.id)
  end
end
