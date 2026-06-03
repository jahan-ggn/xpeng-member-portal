# frozen_string_literal: true

module XpengMemberPortal
  class BaseClient
    class Error < StandardError; end
    class TimeoutError < Error; end

    DEFAULT_OPEN_TIMEOUT = 5
    DEFAULT_READ_TIMEOUT = 10

    def initialize(api_key:, api_username:)
      @api_key = api_key
      @api_username = api_username
    end

    private

    attr_reader :api_key, :api_username

    def http_request(uri, type: :get, body: nil, headers: {})
      http = FinalDestination::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = DEFAULT_OPEN_TIMEOUT
      http.read_timeout = DEFAULT_READ_TIMEOUT

      request = build_request(uri, type, body, headers)
      request["X-Discourse-Api-Key"] = api_key
      request["X-Discourse-Api-Username"] = api_username

      http.request(request)
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise TimeoutError
    end

    def build_request(uri, type, body, extra_headers)
      request =
        case type
        when :post
          FinalDestination::HTTP::Post.new(uri.request_uri)
        else
          FinalDestination::HTTP::Get.new(uri.request_uri)
        end

      extra_headers.each { |k, v| request[k] = v }
      request["Content-Type"] = "application/json" if body
      request.body = body.to_json if body
      request
    end
  end
end
