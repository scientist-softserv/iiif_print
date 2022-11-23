require 'spec_helper'

# Core Metadata Spec Tests
RSpec.describe NewspaperWorks::NewspaperCoreMetadata do
  class NewspaperishWork < ActiveFedora::Base
    include ::Hyrax::WorkBehavior
    include NewspaperWorks::NewspaperCoreMetadata
    include ::Hyrax::BasicMetadata
  end

  let(:work) { NewspaperishWork.new }

  it 'creates work using mixin' do
    expect(work).to be_an_instance_of(NewspaperishWork)
  end

  it 'has expected properties' do
    expect(work).to respond_to(:alternative_title)
    expect(work).to respond_to(:place_of_publication)
    expect(work).to respond_to(:issn)
    expect(work).to respond_to(:lccn)
    expect(work).to respond_to(:oclcnum)
    expect(work).to respond_to(:held_by)
  end

  it 'uses correct class for place_of_publication' do
    pop_class = work.class.properties['place_of_publication'].class_name
    expect(pop_class).to eq Hyrax::ControlledVocabularies::Location
  end

  it 'work can set/get properties' do
    issn_value = '0000-1111'
    work.issn = issn_value
    expect(work.issn).to eq issn_value
  end

  it 'work using mixin saves' do
    work.place_of_publication = ['http://www.geonames.org/5780993/about.rdf']
    work.alternative_title = ['The alt title']
    expect(work.id).to be_nil
    work.save!
    expect(work.id).not_to be_nil
    expect(NewspaperishWork.all.map(&:id)).to include(work.id)
  end
end
