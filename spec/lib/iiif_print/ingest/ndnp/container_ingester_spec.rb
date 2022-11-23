require 'spec_helper'
require 'ndnp_shared'
require 'misc_shared'

RSpec.describe IiifPrint::Ingest::NDNP::ContainerIngester do
  include_context "ndnp fixture setup"
  include_context "shared setup"

  # use FactoryBot for publication, issue
  let(:publication) { create(:newspaper_title) }
  let(:issue) do
    issue = create(:newspaper_issue)
    publication.members << issue
    publication.save!
    issue
  end
  let(:linked_publication) { issue.publication }

  let(:issue_data) do
    IiifPrint::Ingest::NDNP::IssueIngest.new(issue2)
  end

  let(:page_data) do
    data = issue_data.to_a[0]
    # some NDNP samples missing TIFF, put dummy in place of missing, as needed
    data.files = data.files.map do |path|
      File.exist?(path) ? path : File.join(fixture_path, 'ocr_gray.tiff')
    end
    data
  end

  let(:page) do
    ingester = IiifPrint::Ingest::NDNP::PageIngester.new(page_data, issue)
    ingester.ingest
    ingester.target
  end

  # reel data via ContainerIngest, ContainerMetadata objects:
  let(:reel_data) { issue_data.container }
  let(:metadata) { reel_data.metadata }
  let(:sn) { metadata.reel_number }

  describe "asset construction and linking" do
    before do
      # trick with testing ingest that does find-or-create on reel is
      #   that we want to clear previous reel assets left over from
      #   other tests, most of the time.
      containers = NewspaperContainer.where(identifier: sn)
      next if containers.size.zero?
      # first, unlink the reel from publication before deleting:
      container = containers[0]
      publication = container.publication
      publication.members.delete(container) unless publication.nil?
      # then delete reel
      containers.delete_all
    end

    it "constructs adapter wth reel_data, publication asset" do
      adapter = described_class.new(reel_data, linked_publication)
      expect(adapter.source).to be reel_data
      expect(adapter.publication).to be linked_publication
    end

    it "constructs a publication-linked asset for reel" do
      adapter = described_class.new(reel_data, linked_publication)
      expect(adapter.target).to be_nil
      adapter.ingest
      expect(adapter.target).to be_a NewspaperContainer
      expect(adapter.target.publication).to be_a NewspaperTitle
    end

    it "links pages to reel" do
      adapter = described_class.new(reel_data, linked_publication)
      adapter.ingest
      adapter.link(page)
      expect(adapter.target.pages.map(&:id)).to include page.id
      expect(adapter.target.pages.size).to eq 1
    end

    it "copies reel metadata" do
      adapter = described_class.new(reel_data, linked_publication)
      adapter.ingest
      reel = adapter.target
      expect(reel.identifier).to contain_exactly sn
      expect(reel.held_by).to eq metadata.held_by
      expect(reel.title).to contain_exactly "Microform reel (#{sn})"
      expect(reel.publication_date_start).to eq metadata.publication_date_start
      expect(reel.publication_date_end).to eq metadata.publication_date_end
    end

    it "sets default administrative metadata with default construction" do
      adapter = described_class.new(reel_data, linked_publication)
      adapter.ingest
      asset = adapter.target
      expect(asset.depositor).to eq User.batch_user.user_key
      expect(asset.admin_set).to eq AdminSet.find(AdminSet::DEFAULT_ID)
      expect(asset.visibility).to eq 'open'
    end

    it "sets custom administrative metadata" do
      # test one exemplary/representative option:
      adapter = described_class.new(
        reel_data,
        linked_publication,
        visibility: 'open'
      )
      adapter.ingest
      expect(adapter.target.visibility).to eq 'open'
    end

    it "finds or creates container asset for reel" do
      # No initial container for thre reel id, per before block above:
      expect(NewspaperContainer.where(identifier: sn).size).to eq 0
      # create it once
      described_class.new(reel_data, linked_publication).ingest
      result = NewspaperContainer.where(identifier: sn)
      expect(result.size).to eq 1
      expect(result.first.identifier).to contain_exactly sn
      # now do this again, expecting to find the existing container asset:
      described_class.new(reel_data, linked_publication).ingest
      result = NewspaperContainer.where(identifier: sn)
      expect(result.size).to eq 1 # still just one asset
      expect(result.first.identifier).to contain_exactly sn
    end
  end
end
