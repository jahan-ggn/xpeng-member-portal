# frozen_string_literal: true

module XpengMemberPortal
  class FetchProfile
    Result = Struct.new(:success?, :data, :error, keyword_init: true)

    def initialize(user)
      @user = user
    end

    def call
      cached = ProfileCache.read(user.id)
      return Result.new(success?: true, data: cached) if cached.present?

      payload = fetch_and_transform
      ProfileCache.write(user.id, payload)

      new_fields = {
        "xpeng_registration_verified" => payload[:registration_verified],
        "xpeng_member_type" => payload[:member_type],
        "xpeng_registration_year" => payload[:registration_year],
      }

      changed = new_fields.any? { |key, value| user.custom_fields[key] != value }
      if changed
        Jobs.enqueue(
          :xpeng_member_portal_persist_custom_fields,
          user_id: user.id,
          fields: new_fields,
        )
      end

      Result.new(success?: true, data: payload)
    rescue ProfileClient::Error => e
      Result.new(success?: false, error: e.message)
    end

    private

    attr_reader :user

    def fetch_and_transform
      raw =
        ProfileClient.new(
          user: user,
          api_key: SiteSetting.xpeng_member_api_key,
          api_username: SiteSetting.xpeng_member_api_username,
        ).fetch

      api_data = raw.is_a?(Hash) && raw["data"] ? raw["data"] : raw
      api_data = api_data.with_indifferent_access

      {
        vehicle_model: api_data["vehicle_model"],
        trim_level: api_data["trim_level"],
        colour: api_data["colour"],
        registration_year: api_data["registration_year"],
        registration_verified: api_data["registration_verified"],
        member_type: api_data["member_type"],
        uid: api_data["uid"],
        resources: ResourcesQuery.new(api_data["member_type"]).to_a,
        discourse_username: user.username,
      }
    end
  end
end
