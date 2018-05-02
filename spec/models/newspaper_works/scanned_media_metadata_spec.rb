RSpec.describe "ScannedMediaMetadata" do

  before do
    class ScannedMediaWork < ActiveFedora::Base
      include ::Hyrax::WorkBehavior
      include NewspaperWorks::ScannedMediaMetadata
      include ::Hyrax::BasicMetadata
    end
  end

  it "creates work using mixin" do
    work = ScannedMediaWork.new
    expect(work).to be_an_instance_of(ScannedMediaWork)
  end

  it "has expected properties" do
    properties = ScannedMediaWork.properties
    expect(properties.keys).to include "text_direction"
    expect(properties.keys).to include "pagination"
    expect(properties.keys).to include "section"
  end

  it "work can set/get properties" do
    work = ScannedMediaWork.new
    work.section = 'foo'
    expect(work.section).to include 'foo'
  end

  it "work using mixin saves" do
    work = ScannedMediaWork.new
    work.title = ['label able label']
    expect(work.id).to be_nil
    work.save!
    expect(work.id).to_not be_nil
    expect(ScannedMediaWork.all.map { |w| w.id }).to include(work.id)
  end
end
