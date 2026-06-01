import Component from "@glimmer/component";
import I18n, { i18n } from "discourse-i18n";
import isTruthyCustomField from "../../lib/xpeng-truthy";

export default class XpengProfileBadges extends Component {
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

  get verified() {
    return isTruthyCustomField(this.args.model.xpeng_registration_verified);
  }

  get displayMemberType() {
    const type = this.memberType;
    if (!type) {
      return null;
    }
    return type
      .split("_")
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(" ");
  }

  <template>
    <div class="xpeng-profile-badges">
      {{#if this.memberSince}}
        <div class="xpeng-profile-badges__since">{{this.memberSince}}</div>
      {{/if}}

      <div class="xpeng-profile-badges__badges">
        {{#if this.memberType}}
          <span
            class="xpeng-profile-badges__pill"
          >{{this.displayMemberType}}</span>
        {{/if}}

        {{#if this.verified}}
          <span
            class="xpeng-profile-badges__pill xpeng-profile-badges__pill--verified"
          >
            {{i18n "xpeng_member_portal.verified"}}
          </span>
          <span
            class="xpeng-profile-badges__pill xpeng-profile-badges__pill--dvla"
          >
            {{i18n "xpeng_member_portal.dvla_confirmed"}}
          </span>
        {{/if}}
      </div>
    </div>
  </template>
}
