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

      response =
        Excon.get(request_url, headers: request_headers, connect_timeout: 5, read_timeout: 10)

      unless response.status == 200
        raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_failed")
      end

      JSON.parse(response.body)
    rescue Excon::Errors::Timeout
      raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_timeout")
    rescue Excon::Error, JSON::ParserError => e
      Rails.logger.warn("[XpengMemberPortal] #{e.class}: #{e.message}")
      raise Error, I18n.t("xpeng_member_portal.errors.profile_fetch_failed")
    end

    private

    attr_reader :user, :api_key, :api_username

    def validate_config!
      required = {
        endpoint => "endpoint_not_configured",
        api_key => "api_key_missing",
        api_username => "api_username_missing",
        member_uid => "member_uid_missing",
      }
      required.each do |value, error_key|
        raise Error, I18n.t("xpeng_member_portal.errors.#{error_key}") if value.blank?
      end
    end

    def request_url
      "#{endpoint}?uid=#{CGI.escape(member_uid)}"
    end

    def request_headers
      { "X-Discourse-Api-Key" => api_key, "X-Discourse-Api-Username" => api_username }
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
