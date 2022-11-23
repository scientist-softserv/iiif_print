module NewspaperWorks
  # in-memory caching fetcher for HTTP GET requests, wraps Faraday.get
  class ResourceFetcher
    # only cache following HTTP response codes, per Section 6.1, RFC 7231
    CACHEABLE_STATUS = [
      200, 203, 204, 206, 300, 301, 404, 405, 410, 414, 501
    ].freeze

    class << self
      attr_accessor :cache
    end

    def self.get(url, stale_after = 3600)
      new(stale_after).get(url)
    end

    def self.include?(url)
      return false if cache.nil?
      cache.keys.include?(url)
    end

    def initialize(stale_after = 3600)
      @stale_after = stale_after # seconds
      # initialize shared state only if missing:
      self.class.cache = {} if self.class.cache.nil?
    end

    def get(url)
      cache_get(url) || miss_get(url)
    end

    # @return [Hash] shared cache state
    def cache
      self.class.cache
    end

    # @return [NilClass, Hash] hash of status, response body — or nil if no HIT
    def cache_get(url)
      return unless cache.include?(url)
      check_expiry(url)
      # in case of expiration, cache will no longer include URL:
      return unless cache.include?(url)
      # return non-expired cache HIT:
      cache[url]
    end

    # Get URL from original source, by URL; will cache any cachable response
    #   in self.class.cache (shared state).
    # @param url [String] URL to GET
    # @raise [Faraday::ConnectionFailed] if DNS or TCP connection error.
    # @return [Hash] hash containing status, response headers, response body
    def miss_get(url)
      resp = Faraday.get url
      # create a new hash from headers
      result = resp.headers.to_h
      # add status and body to
      result['status'] = resp.status
      result['body'] = resp.body
      # set (new or replaced previously) cached value for URL:
      if CACHEABLE_STATUS.include?(resp.status)
        result['cached_time'] = DateTime.now.to_time.to_i
        cache[url] = result
      end
      result
    end

    def check_expiry(url)
      return unless cache.include?(url)
      cache.delete(url) if expired(cache[url])
    end

    def expired(record)
      now = DateTime.now.to_time.to_i
      # does elapsed seconds between store and now exceed threshold?
      (now - record['cached_time']) > @stale_after
    end
  end
end
