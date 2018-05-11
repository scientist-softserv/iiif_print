# Core Metadata Spec Tests
RSpec.describe 'NewspaperCoreMetadata' do
  before do
    class NewspaperishWork < ActiveFedora::Base
      include ::Hyrax::WorkBehavior
      include NewspaperWorks::NewspaperCoreMetadata
      include ::Hyrax::BasicMetadata
    end
  end

  it 'creates work using mixin' do
    work = NewspaperishWork.new
    expect(work).to be_an_instance_of(NewspaperishWork)
  end

  it 'has expected properties' do
    properties = NewspaperishWork.properties
    expect(properties.keys).to include 'genre'
    expect(properties.keys).to include 'held_by'
    expect(properties.keys).to include 'issued'
    expect(properties.keys).to include 'place_of_publication'
  end

  it 'work can set/get properties' do
    work = NewspaperishWork.new
    work.genre = ['http://cv.iptc.org/newscodes/genre/Opinion']
    expect(work.genre).to include 'http://cv.iptc.org/newscodes/genre/Opinion'
  end

  it 'work using mixin saves' do
    work = NewspaperishWork.new
    work.place_of_publication = ['http://www.geonames.org/5780993/about.rdf']
    work.genre = ['http://cv.iptc.org/newscodes/genre/Opinion']
    expect(work.id).to be_nil
    work.save!
    expect(work.id).to_not be_nil
    expect(NewspaperishWork.all.map { |w| w.id }).to include(work.id)
  end
end
