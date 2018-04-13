# Generated via
#  `rails generate hyrax:work NewspaperTitle`
require 'rails_helper'
require 'model_shared'

RSpec.describe NewspaperTitle do

  before(:all) do
    @fixture = model_fixtures(NewspaperTitle)
  end

  # shared behaviors
  it_behaves_like("a work and PCDM object")
  it_behaves_like("a persistent work type")

  describe "Model behaviors and properties" do
    it "class has expected properties" do
      properties = NewspaperTitle.properties
      expect(properties.keys).to include "alternative_title"
    end
  end

  describe "Relationship methods" do
    it "has expected test fixture" do
      expect(@fixture).to be_an_instance_of(NewspaperTitle)
    end

    it "can get issues" do
      issues = @fixture.issues
      expect(issues).to be_an_instance_of(Array)
      # our test fixture is non-empty
      expect(issues.length).to be > 0
      issues.each do |e|
        expect(e).to be_an_instance_of(NewspaperIssue)
      end
    end
  end

  it "can get containers" do
    containers = @fixture.containers
    expect(containers).to be_an_instance_of(Array)
    expect(containers.length).to be > 0
    containers.each do |e|
      expect(e).to be_an_instance_of(NewspaperContainer)
    end
  end
end
