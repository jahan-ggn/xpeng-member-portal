# frozen_string_literal: true

module XpengMemberPortal
  class ProfileClient < BaseClient
    class Error < BaseClient::Error
    end

    def initialize(user:, api_key:, api_username:)
      super(api_key: api_key, api_username: api_username)
      @user = user
    end

    def fetch
      validate_config!

      response = http_request(URI.parse(request_url))

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_failed")
      end

      JSON.parse(response.body)
    rescue BaseClient::TimeoutError
      raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_timeout")
    rescue JSON::ParserError
      raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_failed")
    end

    private

    attr_reader :user

    def validate_config!
      raise Error, I18n.t("xpeng_member_portal.errors.endpoint_not_configured") if endpoint.blank?
      raise Error, I18n.t("xpeng_member_portal.errors.api_key_missing") if api_key.blank?
      raise Error, I18n.t("xpeng_member_portal.errors.api_username_missing") if api_username.blank?
      raise Error, I18n.t("xpeng_member_portal.errors.member_uid_missing") if member_uid.blank?
    end

    def request_url
      "#{endpoint}?uid=#{CGI.escape(member_uid)}"
    end

    def endpoint
      SiteSetting.xpeng_member_profile_endpoint
    end

    def member_uid
      @member_uid ||=
        begin
          field_name = SiteSetting.xpeng_member_uid_field
          return nil if field_name.blank?

          user_field_id = XpengMemberPortal.user_field_id_for(field_name)
          return nil if user_field_id.blank?

          user.custom_fields["user_field_#{user_field_id}"].presence
        end
    end
  end
end
