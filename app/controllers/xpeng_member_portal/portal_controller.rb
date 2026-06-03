# frozen_string_literal: true

module XpengMemberPortal
  class PortalController < ::ApplicationController
    requires_plugin XpengMemberPortal::PLUGIN_NAME
    before_action :ensure_logged_in
    before_action :rate_limit_dvla, only: [:verify_dvla]

    def profile
      target_user = User.find_by(username: params[:username]) || current_user
      raise Discourse::InvalidAccess unless guardian.can_see_xpeng_portal?(target_user)
      result = ProfileService.new(target_user).fetch

      if result[:error]
        render json: result, status: :unprocessable_entity
      else
        render json: result
      end
    end

    def verify_dvla
      reg_number = params[:registration_number]&.strip&.upcase

      if reg_number.blank?
        return render json: { error: "Registration number required" }, status: :unprocessable_entity
      end

      result = DvlaService.new(current_user, reg_number).verify

      if result.success?
        render json: { verified: true, vehicle: result.vehicle }
      else
        render json: { verified: false, reason: result.error }, status: :unprocessable_entity
      end
    end

    private

    def rate_limit_dvla
      RateLimiter.new(current_user, "verify_dvla", 5, 1.minute).performed!
    rescue RateLimiter::LimitExceeded
      render json: {
               error: "Rate limit exceeded. Please try again later.",
             },
             status: :too_many_requests
    end
  end
end
