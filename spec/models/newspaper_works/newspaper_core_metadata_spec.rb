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
    expect(work).to respond_to(:genre)
    expect(work).to respond_to(:place_of_publication)
    expect(work).to respond_to(:issn)
    expect(work).to respond_to(:lccn)
    expect(work).to respond_to(:oclcnum)
    expect(work).to respond_to(:held_by)
  end

  it 'work can set/get properties' do
    genre_uri = 'http://cv.iptc.org/newscodes/genre/Opinion'
    work.genre = [genre_uri]
    expect(work.genre).to include genre_uri
  end

  it 'work using mixin saves' do
    work.place_of_publication = ['http://www.geonames.org/5780993/about.rdf']
    work.genre = ['http://cv.iptc.org/newscodes/genre/Opinion']
    expect(work.id).to be_nil
    work.save!
    expect(work.id).not_to be_nil
    expect(NewspaperishWork.all.map(&:id)).to include(work.id)
  end
end
