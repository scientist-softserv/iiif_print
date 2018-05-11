# Generated via
#  `rails generate hyrax:work NewspaperArticle`
require 'spec_helper'
require 'model_shared'

RSpec.describe NewspaperArticle do
  before(:all) do
    @fixture = model_fixtures(NewspaperArticle)
  end

  # shared behaviors
  it_behaves_like('a work and PCDM object')
  it_behaves_like('a persistent work type')

  describe 'Model behaviors and properties' do
    it 'has expected properties' do
      properties = NewspaperArticle.properties
      expect(properties.keys).to include 'section'
    end
  end

  describe 'Relationship methods' do
    it 'has expected test fixture' do
      expect(@fixture).to be_an_instance_of(NewspaperArticle)
    end

    it 'can get aggregated pages' do
      pages = @fixture.pages
      expect(pages).to be_an_instance_of(Array)
      expect(pages.length).to be > 0
      pages.each do |e|
        expect(e).to be_an_instance_of(NewspaperPage)
      end
    end

    it 'can get aggregating issue' do
      issue = @fixture.issue
      expect(issue).to be_an_instance_of(NewspaperIssue)
    end

    it 'can get publicaiton (transitive)' do
      publication = @fixture.publication
      expect(publication).to be_an_instance_of(NewspaperTitle)
    end

    it 'can get aggregating containers (transitive)' do
      containers = @fixture.containers
      expect(containers).to be_an_instance_of(Array)
      expect(containers.length).to be > 0
      containers.each do |e|
        expect(e).to be_an_instance_of(NewspaperContainer)
      end
    end
  end
end
