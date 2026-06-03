# frozen_string_literal: true

# name: xpeng-member-portal
# about: Integrates a member portal, profile badges, and DVLA verification workflows
# version: 0.0.1
# authors: Jahan Gagan
# url: https://github.com/jahan-ggn/xpeng-member-portal

enabled_site_setting :xpeng_member_portal_enabled

module ::XpengMemberPortal
  PLUGIN_NAME = "xpeng-member-portal"

  USER_CUSTOM_FIELDS = %w[
    xpeng_registration_verified
    xpeng_member_type
    xpeng_registration_year
    xpeng_registration_number
  ].freeze

  def self.gated_category_ids
    @gated_category_ids ||=
      begin
        ids = SiteSetting.xpeng_dvla_gated_category_ids
        ids.present? ? ids.split("|").map(&:to_i).to_set : Set.new
      end
  end

  def self.clear_gated_category_ids!
    @gated_category_ids = nil
  end

  def self.user_field_id_for(name)
    Discourse
      .cache
      .fetch("xpeng_member_portal:user_field_id:#{name}", expires_in: 1.hour) do
        UserField.find_by(name: name)&.id
      end
  end

  def self.verified_group
    group_name = SiteSetting.xpeng_dvla_verified_group_name
    return if group_name.blank?

    Discourse
      .cache
      .fetch("xpeng_member_portal:verified_group:#{group_name}", expires_in: 1.hour) do
        Group.find_by(name: group_name)
      end
  end
end

require_relative "lib/xpeng_member_portal/engine"
register_asset "stylesheets/portal.scss"
register_asset "stylesheets/profile-badges.scss"
register_asset "stylesheets/dvla-gate.scss"

after_initialize do
  XpengMemberPortal::USER_CUSTOM_FIELDS.each do |field|
    User.register_custom_field_type(field, :string)
  end

  XpengMemberPortal::USER_CUSTOM_FIELDS.each do |field|
    add_to_serializer(
      :user,
      field.to_sym,
      include_condition: -> { scope.can_see_xpeng_portal?(object) },
    ) { object.custom_fields[field] }
  end

  add_to_class(:guardian, :dvla_verified?) do
    user&.groups&.exists?(name: SiteSetting.xpeng_dvla_verified_group_name)
  end

  add_to_serializer(
    :topic_view,
    :requires_dvla_verification,
    include_condition: -> do
      XpengMemberPortal.gated_category_ids.include?(object.topic.category_id)
    end,
  ) { !scope.dvla_verified? }

  add_to_class(:guardian, :can_see_xpeng_portal?) do |target_user|
    return false unless SiteSetting.xpeng_member_portal_enabled
    return true if is_admin?
    target_user == @user
  end

  on(:site_setting_changed) do |name|
    XpengMemberPortal.clear_gated_category_ids! if name == :xpeng_dvla_gated_category_ids

    if name == :xpeng_member_uid_field
      Discourse.cache.delete(
        "xpeng_member_portal:user_field_id:#{SiteSetting.xpeng_member_uid_field}",
      )
    end

    if name == :xpeng_dvla_verified_group_name
      Discourse.cache.delete(
        "xpeng_member_portal:verified_group:#{SiteSetting.xpeng_dvla_verified_group_name}",
      )
    end
  end
end
