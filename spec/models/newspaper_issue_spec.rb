# Generated via
#  `rails generate hyrax:work NewspaperIssue`
require 'spec_helper'
require 'model_shared'

RSpec.describe NewspaperIssue do
  let(:fixture) { model_fixtures(described_class) }

  # shared behaviors
  it_behaves_like('a work and PCDM object')
  it_behaves_like('a persistent work type')

  describe 'Metadata properties' do
    it 'has expected properties' do
      expect(fixture).to respond_to(:volume)
      expect(fixture).to respond_to(:edition)
      expect(fixture).to respond_to(:issue_number)
      expect(fixture).to respond_to(:extent)
    end
  end

  describe 'Relationship methods' do
    it 'has expected test fixture' do
      expect(fixture).to be_an_instance_of(described_class)
    end

    it 'can get aggregating publication/title' do
      parent = fixture.publication
      expect(parent).not_to be_nil
      expect(parent).to be_an_instance_of(NewspaperTitle)
      # reciprocity and round-trip
      expect(parent.issues).to include fixture
    end

    it 'can get aggregated pages' do
      contained_pages = fixture.pages
      expect(contained_pages).to be_an_instance_of(Array)
      expect(contained_pages.length).to be > 0
      contained_pages.each do |e|
        expect(e).to be_an_instance_of(NewspaperPage)
      end
    end

    it 'can get aggregated articles' do
      contained_articles = fixture.articles
      expect(contained_articles).to be_an_instance_of(Array)
      expect(contained_articles.length).to be > 0
      contained_articles.each do |e|
        expect(e).to be_an_instance_of(NewspaperArticle)
      end
    end
  end
end
