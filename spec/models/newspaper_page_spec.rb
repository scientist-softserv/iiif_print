# Generated via
#  `rails generate hyrax:work NewspaperPage`
require 'spec_helper'
require 'model_shared'

RSpec.describe NewspaperPage do
  before(:all) do
    @fixture = model_fixtures(NewspaperPage)
  end

  it_behaves_like('a work and PCDM object')
  it_behaves_like('a persistent work type')

  describe 'Relationship methods' do
    it 'has expected test fixture' do
      expect(@fixture).to be_an_instance_of(NewspaperPage)
    end

    it 'can get aggregating articles for page' do
      articles = @fixture.articles
      expect(articles).to be_an_instance_of(Array)
      expect(articles.length).to be > 0
      articles.each do |e|
        expect(e).to be_an_instance_of(NewspaperArticle)
      end
    end

    it 'can get aggregating issues for page' do
      issues = @fixture.issues
      expect(issues).to be_an_instance_of(Array)
      expect(issues.length).to be > 0
      issues.each do |e|
        expect(e).to be_an_instance_of(NewspaperIssue)
      end
    end

    it 'can get aggregating containers for page' do
      containers = @fixture.containers
      expect(containers).to be_an_instance_of(Array)
      expect(containers.length).to be > 0
      containers.each do |e|
        expect(e).to be_an_instance_of(NewspaperContainer)
      end
    end

    it 'can get publication (transitive)' do
      publication = @fixture.publication
      expect(publication).to_not be_nil
      expect(publication).to be_an_instance_of(NewspaperTitle)
    end
  end
end
