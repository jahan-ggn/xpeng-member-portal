# frozen_string_literal: true

module XpengMemberPortal
  class DvlaService
    Result = Struct.new(:success?, :verified, :vehicle, :error, keyword_init: true)

    def initialize(user, registration_number)
      @user = user
      @registration_number = registration_number
    end

    def verify
      result =
        DvlaClient.new(
          user: user,
          registration_number: registration_number,
          api_key: SiteSetting.xpeng_member_api_key,
          api_username: SiteSetting.xpeng_member_api_username,
        ).verify

      if result[:verified]
        add_user_to_verified_group
        persist_registration_number
        ProfileCache.delete(user.id)
        Result.new(success?: true, verified: true, vehicle: result)
      else
        message = result[:error].presence || result[:reason].presence || "Verification failed"
        Result.new(success?: false, error: message)
      end
    rescue DvlaClient::Error => e
      Result.new(success?: false, error: e.message)
    end

    private

    attr_reader :user, :registration_number

    def add_user_to_verified_group
      group = XpengMemberPortal.verified_group
      group&.add(user)
    end

    def persist_registration_number
      user.custom_fields["xpeng_registration_number"] = registration_number
      user.save_custom_fields
    end
  end
end
