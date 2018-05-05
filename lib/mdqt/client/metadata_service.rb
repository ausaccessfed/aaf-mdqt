module MDQT
  class Client

    class MetadataService

      require 'faraday'
      require 'typhoeus'
      require 'typhoeus/adapters/faraday'
      require 'cgi'

      require 'faraday_middleware'
      require 'faraday-http-cache'

      require 'active_support/cache'
      require 'active_support/cache/file_store'
      require 'active_support/cache/mem_cache_store'
      require 'active_support/logger'

      require_relative './metadata_response'

      def initialize(base_url, options = {})
        @base_url     = base_url
        @cache_type   = options[:cache_type] ? options[:cache_type].to_sym : :none
        @store_config = options[:cache_store]
        @verbose      = options[:verbose] ? true : false
      end

      def base_url
        @base_url
      end

      def get(entity_id)

        entity_id = prepare_id(entity_id)

        http_response = connection.get do |req|
          req.url ['entities/', entity_id].join
          req.options.timeout = 100
          req.options.open_timeout = 5
        end

        MetadataResponse.new(entity_id, base_url, http_response)

      end

      def prepare_id(id)
        case id
        when :all, "", nil
          ""
        when /^{sha1}/i
          CGI.escape(id.downcase.strip)
        when /^\[sha1\]/i
          CGI.escape(id.downcase.strip.gsub "[sha1]", "{sha1}")
        else
          CGI.escape(id.strip)
        end
      end

      def verbose?
        @verbose
      end

      def cache?
        cache_type == :none ? false : true
      end

      def cache_type
        @cache_type || :none
      end

      def store_config
        @store_config || default_store_config
      end

      private

      def connection
        Faraday.new(:url => base_url) do |faraday|
          faraday.request :url_encoded
          faraday.use FaradayMiddleware::Gzip
          faraday.use FaradayMiddleware::FollowRedirects
          faraday.use :http_cache, faraday_cache_config if cache?
          faraday.headers['Content-Type'] = 'application/samlmetadata+xml'
          faraday.headers['User-Agent'] = "MDQT v#{MDQT::VERSION}"
          faraday.adapter :typhoeus
          #faraday.response :logger
        end
      end

      def default_store_config
        case cache_type
        when :none, nil
          nil
        when :file, :files
          File.absolute_path(File.join(Dir.tmpdir, 'mdqt_cache'))
        when :memcached, :memcache
          'localhost:11211'
        end
      end

      def faraday_cache_config
        {
            store: cache_store,
            shared_cache: false,
            serializer: Marshal,
            #logger: cache_logger,
            instrumenter: ActiveSupport::Notifications
        }
      end

      def cache_logger
        verbose? ? Logger.new('mdqt_cache.log') : nil
      end

      def cache_store
        case cache_type
        when :file, :files, nil
          @cache_store = ActiveSupport::Cache.lookup_store(:file_store, store_config)
        when :memcache, :memcached
          @cache_store = ActiveSupport::Cache.lookup_store(:mem_cache_store, [store_config])
        end
      end

    end

  end

end