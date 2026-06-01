# frozen_string_literal: true

module Jobs
  class XpengMemberPortalPersistCustomFields < ::Jobs::Base
    def execute(args)
      user = User.find_by(id: args["user_id"])
      return if user.blank?

      fields = args["fields"] || {}
      return if fields.blank?

      fields.each do |key, value|
        user.custom_fields[key.to_s] = value
      end

      user.save_custom_fields(true)
    end
  end
end
