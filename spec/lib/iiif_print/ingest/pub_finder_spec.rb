require 'spec_helper'

RSpec.describe IiifPrint::Ingest::PubFinder do
  describe "mixin publication find-or-create module" do
    let(:klass) do
      Class.new do
        include IiifPrint::Ingest::PubFinder
      end
    end

    before do
      ['sn2099999999', 'sn2036999999', 'sn82014496'].each do |lccn|
        NewspaperTitle.where(lccn: lccn).delete_all
      end
    end

    # use factory for saved NewspaperIssue:
    let(:issue) { create(:newspaper_issue) }

    let(:ingester) { klass.new }

    let(:publication) { create(:newspaper_title) }

    it "finds existing publication, if it exists" do
      lccn = publication.lccn
      expect(ingester.find_publication(lccn)).to be_a NewspaperTitle
    end

    it "links existing publication on find-or-create" do
      lccn = publication.lccn
      ingester.find_or_create_publication_for_issue(issue, lccn, nil, {})
      publication.reload
      expect(publication.members.to_a).to include issue
    end

    it "links issue to new publication" do
      lccn = 'sn2099999999'
      expect(ingester.find_publication(lccn)).to be_nil
      ingester.find_or_create_publication_for_issue(issue, lccn, nil, {})
      publication = ingester.find_publication(lccn)
      expect(publication).to be_a NewspaperTitle
      expect(publication.members.to_a).to include issue
    end

    it "copies metadata for created publication" do
      lccn = 'sn82014496'
      expect(ingester.find_publication(lccn)).to be_nil
      publication = ingester.create_publication(lccn, nil, {})
      expect(publication.title).to contain_exactly "Rocky Mountain news"
      expect(publication.place_of_publication.map { |v| v.to_uri.to_s }).to \
        contain_exactly(
          "http://sws.geonames.org/5419384/"
        )
      expect(publication.language).to contain_exactly 'eng'
      expect(publication.oclcnum).to eq 'ocm03946163'
    end
  end
end
