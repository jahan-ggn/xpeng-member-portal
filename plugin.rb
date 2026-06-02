# frozen_string_literal: true

# name: xpeng-member-portal
# about: Integrates a member portal, profile badges, and DVLA verification workflows
# version: 0.0.1
# authors: Jahan Gagan
# url: https://github.com/jahan-ggn/xpeng-member-portal

enabled_site_setting :xpeng_member_portal_enabled

module ::XpengMemberPortal
  PLUGIN_NAME = "xpeng-member-portal"
end

require_relative "lib/xpeng_member_portal/engine"
register_asset "stylesheets/portal.scss"
register_asset "stylesheets/profile-badges.scss"
register_asset "stylesheets/dvla-gate.scss"

after_initialize do
  add_to_serializer(
    :user,
    :xpeng_registration_verified,
    include_condition: -> { scope.can_see_xpeng_portal?(object) },
  ) { object.custom_fields["xpeng_registration_verified"] }

  add_to_serializer(
    :user,
    :xpeng_member_type,
    include_condition: -> { scope.can_see_xpeng_portal?(object) },
  ) { object.custom_fields["xpeng_member_type"] }

  add_to_serializer(
    :user,
    :xpeng_registration_year,
    include_condition: -> { scope.can_see_xpeng_portal?(object) },
  ) { object.custom_fields["xpeng_registration_year"] }

  add_to_serializer(
    :user,
    :xpeng_registration_number,
    include_condition: -> { scope.can_see_xpeng_portal?(object) },
  ) { object.custom_fields["xpeng_registration_number"] }

  add_to_serializer(
    :topic_view,
    :requires_dvla_verification,
    include_condition: -> do
      SiteSetting.xpeng_dvla_gated_category_ids.present? &&
        SiteSetting
          .xpeng_dvla_gated_category_ids
          .split("|")
          .map(&:to_i)
          .include?(object.topic.category_id)
    end,
  ) { !scope.user&.groups&.exists?(name: SiteSetting.xpeng_dvla_verified_group_name) }

  add_to_class(:guardian, :can_see_xpeng_portal?) do |target_user|
    return false unless SiteSetting.xpeng_member_portal_enabled
    return true if is_admin?
    target_user == @user
  end
end
