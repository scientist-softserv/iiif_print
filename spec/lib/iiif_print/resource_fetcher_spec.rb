require 'spec_helper'

describe IiifPrint::ResourceFetcher do
  describe "cache hit and expiration handling" do
    cached_time_url1 = 0
    cached_time_url2 = 0

    let(:url1) { 'https://www.example.com/1' }
    let(:url2) { 'https://www.example.com/2' }

    before do
      stub_request(:any, url1)
        .to_return(body: 'abc', headers: { 'Content-Length' => 3 })
      stub_request(:any, url2)
        .to_return(body: 'xyz', headers: { 'Content-Length' => 3 })
      # populate cache for url1 by getting:
      record = described_class.new(3600).miss_get(url1)
      cached_time_url1 = record['cached_time']
      # populate cache for url2, but...
      record = described_class.new(3600).miss_get(url2)
      # set cached time to something old:
      record['cached_time'] = record['cached_time'] - 3601
      cached_time_url2 = record['cached_time']
    end

    it "gets cached record for url" do
      expect(described_class.include?(url1)).to be true
      record = described_class.get(url1)
      expect(record['cached_time']).to eq cached_time_url1
    end

    it "refreshes resource from origin on stale cached record" do
      # while it "has" or includes url:
      expect(described_class.include?(url2)).to be true
      # on the terms of the default stale_after parameter, it is too old:
      record = described_class.cache[url2]
      expect(described_class.new(3600).expired(record)).to be true
      # ...fetching will get new:
      record = described_class.get(url2)
      # new time means fresh request made to origin:
      expect(record['cached_time']).not_to eq cached_time_url2
    end
  end

  describe "cache miss fetch handling" do
    let(:url) { 'https://www.example.com' }

    before do
      stub_request(:any, url)
        .to_return(body: 'abc', headers: { 'Content-Length' => 3 })
    end

    it "makes request on cache miss" do
      expect(described_class.include?(url)).to be false
      record = described_class.get(url)
      expect(record).to be_a Hash
      timestamp = record['cached_time']
      # now cached:
      expect(described_class.include?(url)).to be true
      record = described_class.get(url)
      # same timestamp == effect of cache HIT
      expect(record['cached_time']).to eq timestamp
    end
  end
end
