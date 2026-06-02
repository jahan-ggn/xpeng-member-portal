# frozen_string_literal: true

module XpengMemberPortal
  class ProfileClient
    class Error < StandardError
    end

    def initialize(user:, api_key:, api_username:)
      @user = user
      @api_key = api_key
      @api_username = api_username
    end

    def fetch
      validate_config!

      uri = URI.parse(request_url)

      http = FinalDestination::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 5
      http.read_timeout = 10

      request = FinalDestination::HTTP::Get.new(uri.request_uri)
      request["X-Discourse-Api-Key"] = api_key
      request["X-Discourse-Api-Username"] = api_username

      response = http.request(request)

      unless response.is_a?(Net::HTTPSuccess)
        raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_failed")
      end

      JSON.parse(response.body)
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_timeout")
    rescue Net::HTTPError, JSON::ParserError => e
      raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_failed")
    end

    private

    attr_reader :user, :api_key, :api_username

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

          user_field = UserField.find_by(name: field_name)
          return nil if user_field.blank?

          user.custom_fields["user_field_#{user_field.id}"].presence
        end
    end
  end
end
