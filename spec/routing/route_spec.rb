require 'spec_helper'

RSpec.describe 'Routes', type: :routing do
  routes { IiifPrint::Engine.routes }

  describe 'Chronicling America-style routes' do
    describe 'title' do
      it 'routes the title url to NewspapersController#title' do
        expect(get: '/newspapers/foo').to route_to(controller: 'iiif_print/newspapers',
                                                   action: 'title',
                                                   unique_id: 'foo')
      end
    end

    describe 'issue' do
      it 'routes the issue url to NewspapersController#issue' do
        expect(get: '/newspapers/foo/bar').to route_to(controller: 'iiif_print/newspapers',
                                                       action: 'issue',
                                                       unique_id: 'foo',
                                                       date: 'bar')
      end
    end

    describe 'issue with edition' do
      it 'routes the issue url with edition param to NewspapersController#issue' do
        expect(get: '/newspapers/foo/bar/baz').to route_to(controller: 'iiif_print/newspapers',
                                                           action: 'issue',
                                                           unique_id: 'foo',
                                                           date: 'bar',
                                                           edition: 'baz')
      end
    end

    describe 'page' do
      it 'routes the page url to NewspapersController#page' do
        expect(get: '/newspapers/foo/bar/baz/quux').to route_to(controller: 'iiif_print/newspapers',
                                                                action: 'page',
                                                                unique_id: 'foo',
                                                                date: 'bar',
                                                                edition: 'baz',
                                                                page: 'quux')
      end
    end
  end

  describe 'newspapers_search' do
    it 'routes to the NewspapersSearch#search page' do
      expect(get: '/newspapers_search').to route_to(controller: 'iiif_print/newspapers_search',
                                                    action: 'search')
    end
  end
end
