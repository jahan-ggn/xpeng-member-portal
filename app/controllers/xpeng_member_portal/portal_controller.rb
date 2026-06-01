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
        render json: { data: result.data }
      else
        render json: { error: result.error }, status: :unprocessable_entity
      end
    end
  end
end
