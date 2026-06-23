import Component from "@glimmer/component";
import { service } from "@ember/service";
import I18n, { i18n } from "discourse-i18n";
import { isDvlaVerified } from "../../lib/xpeng-helpers";

export default class XpengProfileBadges extends Component {
  @service siteSettings;

  get memberSince() {
    const dateStr = this.args.model.created_at;
    if (!dateStr) {
      return null;
    }

    const date = new Date(dateStr);
    const locale = I18n.locale || "en";
    const formatted = date.toLocaleDateString(locale, {
      month: "long",
      year: "numeric",
    });

    return i18n("xpeng_member_portal.member_since", { date: formatted });
  }

  get memberType() {
    return this.args.model.xpeng_member_type;
  }

  get isVerified() {
    return isDvlaVerified(
      this.args.model,
      this.siteSettings.xpeng_dvla_verified_group_name
    );
  }

  get displayMemberType() {
    const type = this.memberType;
    if (!type) {
      return null;
    }

    if (
      this.isVerified &&
      (type.toLowerCase() === "current_owner" || type.toLowerCase() === "owner")
    ) {
      return "Verified Owner";
    }

    return type
      .split("_")
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(" ");
  }

  get pillClass() {
    if (this.displayMemberType === "Verified Owner") {
      return "xpeng-profile-badges__pill xpeng-profile-badges__pill--verified-owner";
    }
    return "xpeng-profile-badges__pill";
  }

  <template>
    <div class="xpeng-profile-badges">
      {{#if this.memberSince}}
        <div class="xpeng-profile-badges__since">{{this.memberSince}}</div>
      {{/if}}

      <div class="xpeng-profile-badges__badges">
        {{#if this.memberType}}
          <span class={{this.pillClass}}>{{this.displayMemberType}}</span>
        {{/if}}
      </div>
    </div>
  </template>
}
