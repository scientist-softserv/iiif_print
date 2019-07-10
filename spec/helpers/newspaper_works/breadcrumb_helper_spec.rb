require 'spec_helper'
RSpec.describe NewspaperWorks::BreadcrumbHelper do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:attributes) do
    {
      'publication_id_ssi' => 'foo',
      'publication_title_ssi' => 'bar',
      'issue_id_ssi' => 'baz',
      'issue_title_ssi' => 'quux',
      'is_following_page_of_ssi' => 'one',
      'is_preceding_page_of_ssi' => 'three'
    }
  end
  let(:presenter) { Hyrax::NewspaperPagePresenter.new(solr_document, nil) }
  let(:object_type) { :issue }

  describe '#newspaper_breadcrumbs' do
    it 'returns an array of links' do
      allow(presenter).to receive(:title).and_return(["2018-05-08: Page 1"])
      breadcrumbs = helper.newspaper_breadcrumbs(presenter)
      expect(breadcrumbs.length).to eq 3
      expect(breadcrumbs[0]).to include('href="/concern/newspaper_titles/foo"')
      expect(breadcrumbs[1]).to include('href="/concern/newspaper_issues/baz"')
    end

    it 'returns a filtered version of a newspaper page title' do
      allow(presenter).to receive(:title).and_return(["2018-05-08: Page 1"])
      breadcrumbs = helper.newspaper_breadcrumbs(presenter)
      expect(breadcrumbs[-1]).to eq("Page 1")
    end

    it 'returns a filtered version of the newspaper issue title' do
      allow(presenter).to receive(:title).and_return(["2018-05-18"])
      breadcrumbs = helper.newspaper_breadcrumbs(presenter)
      expect(breadcrumbs[-1]).to eq("May 18, 2018")
    end
  end

  describe '#create_breadcrumb_link' do
    it 'returns an array of links' do
      array_for_spec = helper.create_breadcrumb_link(object_type, presenter)
      expect(array_for_spec.class).to eq Array
      expect(array_for_spec.first).to include('href="/concern/newspaper_issues/baz"')
    end
  end

  describe '#breadcrumb_object_link' do
    it 'returns a link a newspaper object' do
      link_for_spec = helper.breadcrumb_object_link(object_type, 'foo', 'bar')
      expect(link_for_spec).to include('href="/concern/newspaper_issues/foo"')
    end
  end

  describe 'breacrumb_object_title' do
    it 'returns the page number portion of a string if a page number is included' do
      title_for_spec = helper.breacrumb_object_title("2018-05-08: Page 1")
      expect(title_for_spec).to eq('Page 1')
    end

    it 'returns a formatted date if a date is passed without a page number' do
      title_for_spec = helper.breacrumb_object_title("2018-05-18")
      expect(title_for_spec).to eq("May 18, 2018")
    end

    it 'returns the original string if neither a page number or date is passed' do
      title_for_spec = helper.breacrumb_object_title("Foo")
      expect(title_for_spec).to eq("Foo")
    end
  end

  describe '#previous_page_link' do
    it 'returns a link to the previous page' do
      expect(helper.previous_page_link(presenter)).to include('href="/concern/newspaper_pages/one"')
    end
  end

  describe '#next_page_link' do
    it 'returns a link to the next page' do
      expect(helper.next_page_link(presenter)).to include('href="/concern/newspaper_pages/three')
    end
  end
end
