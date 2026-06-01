# frozen_string_literal: true

module XpengMemberPortal
  class ResourcesQuery
    def initialize(member_type)
      @member_type = member_type
    end

    def to_a
      return [] if topic_ids.empty?

      Topic
        .where(id: topic_ids)
        .pluck(:id, :title, :excerpt)
        .map { |id, title, excerpt| { id: id, title: title, excerpt: excerpt } }
    end

    private

    attr_reader :member_type

    def topic_ids
      @topic_ids ||=
        begin
          ids_string =
            case member_type.to_s.downcase
            when "current_owner", "owner"
              SiteSetting.xpeng_owner_resource_topic_ids
            when "dealer"
              SiteSetting.xpeng_dealer_resource_topic_ids
            else
              SiteSetting.xpeng_member_resource_topic_ids
              # when "member" then SiteSetting.xpeng_member_resource_topic_ids
              # else ""
            end

          ids_string.to_s.split("|").map(&:to_i).reject(&:zero?)
        end
    end
  end
end
