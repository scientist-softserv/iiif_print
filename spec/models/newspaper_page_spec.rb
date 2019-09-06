# Generated via
#  `rails generate hyrax:work NewspaperPage`
require 'spec_helper'
require 'model_shared'

RSpec.describe NewspaperPage do
  before(:all) do
    @fixture = model_fixtures(described_class)
  end

  it_behaves_like('a work and PCDM object')
  it_behaves_like('a persistent work type')

  describe 'Relationship methods' do
    it 'has expected test fixture' do
      expect(@fixture).to be_an_instance_of(described_class)
    end

    it 'can get aggregating articles for page' do
      articles = @fixture.articles
      expect(articles).to be_an_instance_of(Array)
      expect(articles.length).to be > 0
      articles.each do |e|
        expect(e).to be_an_instance_of(NewspaperArticle)
      end
    end

    it 'can get aggregating issue for page' do
      issue = @fixture.issue
      expect(issue).to be_an_instance_of(NewspaperIssue)
    end

    it 'can get aggregating container for page' do
      container = @fixture.container
      expect(container).to be_an_instance_of(NewspaperContainer)
    end

    it 'can get publication (transitive)' do
      publication = @fixture.publication
      expect(publication).not_to be_nil
      expect(publication).to be_an_instance_of(NewspaperTitle)
    end
  end
end
