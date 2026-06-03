# frozen_string_literal: true

module XpengMemberPortal
  class DvlaClient < BaseClient
    class Error < BaseClient::Error
    end

    def initialize(user:, registration_number:, api_key:, api_username:)
      super(api_key: api_key, api_username: api_username)
      @user = user
      @registration_number = registration_number
    end

    def verify
      validate_config!

      response =
        http_request(
          URI.parse(endpoint),
          type: :post,
          body: {
            discourse_username: user.username,
            registration_number: registration_number,
          },
        )

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
    rescue BaseClient::TimeoutError
      raise Error, I18n.t("xpeng_member_portal.errors.dvla_verification_timeout")
    rescue JSON::ParserError
      raise Error, I18n.t("xpeng_member_portal.errors.dvla_verification_failed")
    end

    private

    attr_reader :user, :registration_number

    def validate_config!
      if SiteSetting.xpeng_dvla_verification_endpoint.blank?
        raise Error, I18n.t("xpeng_member_portal.errors.dvla_endpoint_not_configured")
      end

      raise Error, I18n.t("xpeng_member_portal.errors.api_key_missing") if api_key.blank?
      raise Error, I18n.t("xpeng_member_portal.errors.api_username_missing") if api_username.blank?
    end

    def endpoint
      SiteSetting.xpeng_dvla_verification_endpoint
    end
  end
end
