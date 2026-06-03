# frozen_string_literal: true

module XpengMemberPortal
  class ProfileService
    def initialize(user)
      @user = user
    end

    def fetch
      result = FetchProfile.new(user).call

      if result.success?
        data =
          result.data.merge(
            dvla_verified: user.groups.exists?(name: SiteSetting.xpeng_dvla_verified_group_name),
          )
        { data: data }
      else
        { error: result.error }
      end
    end

    private

    attr_reader :user
  end
end
