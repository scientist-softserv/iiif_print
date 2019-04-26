require 'spec_helper'

RSpec.describe NewspaperWorks::NewspapersController do
  pubdate = '2015-03-15'

  # have to build a set of related objects first, can't use model_shared
  # because we need a unique lccn every time specs are run
  # otherwise query in NewspaperController#find_object returns false
  # use before(:all) so we only create fixtures once
  # rubocop:disable RSpec/InstanceVariable
  before(:all) do
    @lccn = "sn#{rand(10_000)}"

    title = NewspaperTitle.new
    title.title = ["Yesterday's News"]
    title.lccn = @lccn
    title.visibility = 'open'

    issue = NewspaperIssue.new
    issue.title = ["Yesterday's News: December 7, 1941"]
    issue.publication_date = pubdate
    issue.visibility = 'open'

    title.members.push issue

    page1 = NewspaperPage.new
    page1.title = ['Page 1']
    page1.visibility = 'open'
    page2 = NewspaperPage.new
    page2.title = ['Page 2']
    page2.visibility = 'open'

    issue.ordered_members << page1
    issue.ordered_members << page2

    issue.save!
    title.save!
    page1.save!
    page2.save!
  end

  describe 'GET "title"' do
    describe 'with a valid unique_id' do
      it 'renders the page' do
        get :title, params: { unique_id: @lccn }
        expect(response).to be_successful
        expect(response).to render_template('hyrax/newspaper_titles/show')
      end
    end

    describe 'with an invalid unique_id' do
      it 'returns an error' do
        expect do
          get :title, params: { unique_id: 'foo' }
        end.to raise_error ActionController::RoutingError
      end
    end
  end

  describe 'GET "issue"' do
    describe 'with a valid date' do
      it 'renders the page' do
        get :issue, params: { unique_id: @lccn, date: pubdate }
        expect(response).to be_successful
        expect(response).to render_template('hyrax/newspaper_issues/show')
      end
    end

    describe 'with an edition param' do
      it 'renders the page' do
        get :issue, params: { unique_id: @lccn, date: pubdate, edition: 'ed-1' }
        expect(response).to be_successful
        expect(response).to render_template('hyrax/newspaper_issues/show')
      end
    end

    describe 'with an invalid date' do
      it 'returns an error' do
        expect do
          get :issue, params: { unique_id: @lccn, date: '2015-02-31' }
        end.to raise_error ActionController::RoutingError
      end
    end
  end

  describe 'GET "page"' do
    describe 'with valid params' do
      it 'renders the page' do
        get :page,
            params: {
              unique_id: @lccn,
              date: pubdate,
              edition: 'ed-1',
              page: 'seq-1'
            }
        expect(response).to be_successful
        expect(response).to render_template('hyrax/newspaper_pages/show')
      end
    end

    describe 'with invalid page params' do
      it 'returns an error' do
        expect do
          get :page,
              params: {
                unique_id: @lccn,
                date: pubdate,
                edition: 'ed-1',
                page: 'seq-3'
              }
        end.to raise_error ActionController::RoutingError
      end
    end
  end
  # rubocop:enable RSpec/InstanceVariable
end
