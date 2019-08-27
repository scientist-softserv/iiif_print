require 'spec_helper'
require_relative '../newspaper_works/newspaper_core_presenter_spec'

RSpec.describe Hyrax::NewspaperTitlePresenter do
  # use before(:all) so we only create fixtures once
  # rubocop:disable RSpec/InstanceVariable
  before(:all) do
    @publication = NewspaperTitle.new
    @publication.title = ["Wall Street Journal"]
    @publication.edition_name = "1st"
    @publication.frequency = ["often"]
    @publication.preceded_by = ["Something"]
    @publication.succeeded_by = ["Something Else"]
    @publication.lccn = "sn1234567"

    issue1 = NewspaperIssue.new
    issue1.title = ['February 13, 2016']
    issue1.resource_type = ["newspaper"]
    issue1.language = ["eng"]
    issue1.held_by = "Marriott Library"
    issue1.publication_date = '2016-02-13'
    @publication.members.push issue1

    issue2 = NewspaperIssue.new
    issue2.title = ['February 13, 2019']
    issue2.resource_type = ["newspaper"]
    issue2.language = ["eng"]
    issue2.held_by = "Marriott Library"
    issue2.publication_date = '2019-02-13'
    @publication.members.push issue2

    issue3 = NewspaperIssue.new
    issue3.title = ['March 5, 2019']
    issue3.resource_type = ["newspaper"]
    issue3.language = ["eng"]
    issue3.held_by = "Marriott Library"
    issue3.publication_date = '2019-03-05'
    @publication.members.push issue3

    issue1.save!
    issue2.save!
    issue3.save!
    @publication.save!
    @issues = [issue1, issue2, issue3]
  end

  let(:solr_document) { SolrDocument.find(@publication.id) }
  let(:request) { double(host: 'example.org', base_url: 'http://example.org', params: {}) }
  let(:user_key) { 'a_user_key' }
  let(:ability) { double Ability }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  subject { presenter }

  it { is_expected.to delegate_method(:alternative_title).to(:solr_document) }
  it { is_expected.to delegate_method(:issn).to(:solr_document) }
  it { is_expected.to delegate_method(:lccn).to(:solr_document) }
  it { is_expected.to delegate_method(:oclcnum).to(:solr_document) }
  it { is_expected.to delegate_method(:held_by).to(:solr_document) }

  it { is_expected.to delegate_method(:edition_name).to(:solr_document) }
  it { is_expected.to delegate_method(:frequency).to(:solr_document) }
  it { is_expected.to delegate_method(:preceded_by).to(:solr_document) }
  it { is_expected.to delegate_method(:succeeded_by).to(:solr_document) }

  describe 'title_search_params' do
    subject { presenter.title_search_params }
    it 'will return solr query parameters for locating issues of the title' do
      expect(subject).to contain_exactly([:f, "publication_title_ssi" => ["Wall Street Journal"]])
    end
  end

  describe 'front_page_search_params' do
    subject { presenter.front_page_search_params }
    it 'will return solr query parameters for locating every first page associated with the title' do
      expect(subject).to contain_exactly([:f, "publication_title_ssi" => ["Wall Street Journal"],
                                              "first_page_bsi" => [true]],
                                         [:sort, "publication_date_dtsi asc"])
    end
  end

  describe '#issues' do
    subject { presenter.issues }
    it 'will return a all member issues for the earliest year when no year param is provided' do
      expect(subject.pluck("id")).to contain_exactly(@issues[0].id)
    end

    it 'will return all member issues for a given year when a year param is provided' do
      allow(request).to receive(:params).and_return(year: 2019)
      expect(subject.pluck("id")).to contain_exactly(@issues[1].id, @issues[2].id)
    end
  end

  describe '#issue_years' do
    subject { presenter.issue_years }
    it "will return a sorted list of years with no nil values" do
      allow(presenter).to receive(:all_title_issue_dates).and_return(['2017-01-01T00:00:00Z', nil, '2016-01-01', '2001-12-01', '2017-12-10'])
      is_expected.to eq [2001, 2016, 2017]
    end
  end

  describe '#prev_year' do
    subject { presenter.prev_year }
    it "will return nil if the current year is earliest" do
      is_expected.to be nil
    end

    it "will return the previous year if the current year isn't earliest" do
      allow(request).to receive(:params).and_return(year: 2019)
      is_expected.to eq 2016
    end
  end

  describe '#next_year' do
    subject { presenter.next_year }
    it "will return the next year if the current year isn't latest" do
      is_expected.to be 2019
    end

    it "will return nil if the current year is latest" do
      allow(request).to receive(:params).and_return(year: 2019)
      is_expected.to eq nil
    end
  end

  describe '#year' do
    subject { presenter.year }
    it "will return the earliest issue year if no year is provided" do
      is_expected.to eq 2016
    end

    it "will return the param year if provided" do
      allow(request).to receive(:params).and_return(year: 2019)
      is_expected.to eq 2019
    end
  end

  describe '#all_title_issues' do
    subject { presenter.all_title_issues }
    it 'will return a all member issues' do
      expect(subject.pluck("id")).to contain_exactly(@issues[0].id, @issues[1].id, @issues[2].id)
    end
  end

  describe '#publication_unique_id' do
    subject { presenter.publication_unique_id }
    it { is_expected.to eq ['sn1234567'] }
  end

  describe '#persistent_url' do
    subject { presenter.persistent_url }
    it { is_expected.to include '/newspapers/sn1234567' }
  end
  # rubocop:enable RSpec/InstanceVariable
end
