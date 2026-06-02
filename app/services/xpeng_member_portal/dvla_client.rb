# frozen_string_literal: true

module XpengMemberPortal
  class DvlaClient
    class Error < StandardError
    end

    def initialize(user:, registration_number:, api_key:, api_username:)
      @user = user
      @registration_number = registration_number
      @api_key = api_key
      @api_username = api_username
    end

    def verify
      validate_config!

      uri = URI.parse(SiteSetting.xpeng_dvla_verification_endpoint)
      http = FinalDestination::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 5
      http.read_timeout = 10

      request = FinalDestination::HTTP::Post.new(uri.request_uri)
      request["Content-Type"] = "application/json"
      request["X-Discourse-Api-Key"] = api_key
      request["X-Discourse-Api-Username"] = api_username
      request.body = {
        discourse_username: user.username,
        registration_number: registration_number,
      }.to_json

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body).symbolize_keys
      when Net::HTTPNotFound
        body =
          begin
            JSON.parse(response.body)
          rescue StandardError
            {}
          end
        { error: body["error"] }.compact.symbolize_keys
      else
        raise Error, I18n.t("xpeng_member_portal.errors.dvla_verification_failed")
      end
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise Error, I18n.t("xpeng_member_portal.errors.dvla_verification_timeout")
    rescue Net::HTTPError, JSON::ParserError => e
      raise Error, I18n.t("xpeng_member_portal.errors.dvla_verification_failed")
    end

    private

    attr_reader :user, :registration_number, :api_key, :api_username

    def validate_config!
      if SiteSetting.xpeng_dvla_verification_endpoint.blank?
        raise Error, I18n.t("xpeng_member_portal.errors.dvla_endpoint_not_configured")
      end

      raise Error, I18n.t("xpeng_member_portal.errors.api_key_missing") if api_key.blank?

      raise Error, I18n.t("xpeng_member_portal.errors.api_username_missing") if api_username.blank?
    end
  end
end
