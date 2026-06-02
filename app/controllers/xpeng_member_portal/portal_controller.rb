# frozen_string_literal: true

module XpengMemberPortal
  class PortalController < ::ApplicationController
    requires_plugin XpengMemberPortal::PLUGIN_NAME
    before_action :ensure_logged_in

    def profile
      target_user = User.find_by(username: params[:username]) || current_user

      raise Discourse::InvalidAccess unless guardian.can_see_xpeng_portal?(target_user)

      result = FetchProfile.new(target_user).call

      if result.success?
        data =
          result.data.merge(
            dvla_verified:
              target_user.groups.exists?(name: SiteSetting.xpeng_dvla_verified_group_name),
          )
        puts "Fetched profile for #{target_user.username}: #{data.inspect}"
        render json: { data: data }
      else
        render json: { error: result.error }, status: :unprocessable_entity
      end
    end

    def verify_dvla
      reg_number = params[:registration_number]&.strip&.upcase

      if reg_number.blank?
        return render json: { error: "Registration number required" }, status: :unprocessable_entity
      end

      result =
        DvlaClient.new(
          user: current_user,
          registration_number: reg_number,
          api_key: SiteSetting.xpeng_member_api_key,
          api_username: SiteSetting.xpeng_member_api_username,
        ).verify

      if result[:verified]
        group = Group.find_by(name: SiteSetting.xpeng_dvla_verified_group_name)
        group.add(current_user) if group && !group.users.include?(current_user)

        current_user.custom_fields["xpeng_registration_number"] = reg_number
        current_user.save_custom_fields

        ProfileCache.delete(current_user.id)
        render json: { verified: true, vehicle: result }
      else
        message = result[:error].presence || result[:reason].presence || "Verification failed"
        render json: { verified: false, reason: message }, status: :unprocessable_entity
      end
    rescue XpengMemberPortal::DvlaClient::Error => e
      render json: { verified: false, error: e.message }, status: :unprocessable_entity
    end
  end
end
