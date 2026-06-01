# frozen_string_literal: true

XpengMemberPortal::Engine.routes.draw { get "member-profile" => "portal#profile" }

Discourse::Application.routes.draw do
  mount ::XpengMemberPortal::Engine, at: "xpeng-member-portal"
  get "u/:username/portal" => "users#show", :constraints => { username: RouteFormat.username }
end
