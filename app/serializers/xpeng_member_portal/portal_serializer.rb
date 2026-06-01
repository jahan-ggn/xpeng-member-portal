# frozen_string_literal: true

module XpengMemberPortal
  class PortalSerializer < ApplicationSerializer
    attributes :vehicle_model, :trim_level, :colour, :registration_year,
               :registration_number, :registration_verified, :member_type,
               :uid, :discourse_username, :resources

    def resources
      object[:resources] || []
    end
  end
end
