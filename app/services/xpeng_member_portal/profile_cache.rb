# frozen_string_literal: true

module XpengMemberPortal
  class ProfileCache
    CACHE_TTL = 5.minutes
    PREFIX = "xpeng_member_portal:profile"

    def self.read(user_id)
      data = Discourse.redis.get("#{PREFIX}:#{user_id}")
      JSON.parse(data) if data.present?
    rescue JSON::ParserError
      nil
    end

    def self.write(user_id, payload)
      Discourse.redis.setex("#{PREFIX}:#{user_id}", CACHE_TTL, payload.to_json)
    end

    def self.delete(user_id)
      Discourse.redis.del("#{PREFIX}:#{user_id}")
    end
  end
end
