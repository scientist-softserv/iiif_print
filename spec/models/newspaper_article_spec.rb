# Generated via
#  `rails generate hyrax:work NewspaperArticle`
require 'spec_helper'
require 'model_shared'

RSpec.describe NewspaperArticle do
  let(:fixture) { model_fixtures(described_class) }

  # shared behaviors
  it_behaves_like('a work and PCDM object')
  it_behaves_like('a persistent work type')

  describe 'Metadata properties' do
    it 'has expected properties' do
      expect(fixture).to respond_to(:author)
      expect(fixture).to respond_to(:photographer)
      expect(fixture).to respond_to(:volume)
      expect(fixture).to respond_to(:edition)
      expect(fixture).to respond_to(:issue_number)
      expect(fixture).to respond_to(:geographic_coverage)
      expect(fixture).to respond_to(:extent)
      expect(fixture).to respond_to(:publication_date)
    end
  end

  describe 'Relationship methods' do
    it 'has expected test fixture' do
      expect(fixture).to be_an_instance_of(described_class)
    end

    it 'can get aggregated pages' do
      pages = fixture.pages
      expect(pages).to be_an_instance_of(Array)
      expect(pages.length).to be > 0
      pages.each do |e|
        expect(e).to be_an_instance_of(NewspaperPage)
      end
    end

    it 'can get aggregating issue' do
      issue = fixture.issue
      expect(issue).to be_an_instance_of(NewspaperIssue)
    end

    it 'can get publication (transitive)' do
      publication = fixture.publication
      expect(publication).to be_an_instance_of(NewspaperTitle)
    end

    it 'can get aggregating container (transitive)' do
      container = fixture.container
      expect(container).to be_an_instance_of(NewspaperContainer)
    end
  end

  describe 'publication_date' do
    it "is not valid with bad date format" do
      na = described_class.new(title: ["Breaking News!"],
                               publication_date: "06/21/1978")
      expect(na).not_to be_valid
    end

    it "is valid with proper date format" do
      na = described_class.new(title: ["Breaking News!"],
                               publication_date: "1978-06-21")
      expect(na).to be_valid
    end
  end
end
