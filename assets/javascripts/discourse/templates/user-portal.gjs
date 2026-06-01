import Component from "@glimmer/component";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";
import isTruthyCustomField from "../lib/xpeng-truthy";

export default class UserPortal extends Component {
  get profile() {
    return this.args.model?.data || {};
  }

  get error() {
    return this.args.model?.error;
  }

  get isReady() {
    return !!this.profile?.member_type;
  }

  get vehicleDisplay() {
    const p = this.profile;
    const parts = [p.vehicle_model, p.trim_level].filter(Boolean);
    return parts.length ? parts.join(" — ") : null;
  }

  get vehicleMeta() {
    const p = this.profile;
    const meta = [p.colour, p.registration_year].filter(Boolean).join(", ");
    return meta || null;
  }

  get displayMemberType() {
    const type = this.profile?.member_type;
    if (!type) {
      return null;
    }
    return type
      .split("_")
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(" ");
  }

  get infoCards() {
    const p = this.profile;
    return [
      {
        label: i18n("xpeng_member_portal.vehicle"),
        value: this.vehicleDisplay || i18n("xpeng_member_portal.pending"),
        highlight: !!this.vehicleDisplay,
      },
      {
        label: i18n("xpeng_member_portal.member_type"),
        value: this.displayMemberType || i18n("xpeng_member_portal.pending"),
        memberType: true,
      },
      {
        label: i18n("xpeng_member_portal.member_id"),
        value: p.uid || i18n("xpeng_member_portal.pending"),
        mono: true,
      },
      {
        label: i18n("xpeng_member_portal.discourse_username"),
        value: p.discourse_username || i18n("xpeng_member_portal.pending"),
        mono: true,
      },
    ];
  }

  get resources() {
    return this.profile.resources || [];
  }

  get verified() {
    return isTruthyCustomField(this.profile.registration_verified);
  }

  <template>
    <div class="xpeng-member-portal">
      {{#if this.error}}
        <div class="xpeng-member-portal__error">
          <span class="xpeng-member-portal__error-icon">
            {{dIcon "triangle-exclamation"}}
          </span>
          <p>{{this.error}}</p>
        </div>
      {{else}}
        <div class="xpeng-member-portal__grid">
          {{#each this.infoCards as |card|}}
            <div class="xpeng-member-portal__card">
              <h3>{{card.label}}</h3>
              <p
                class="xpeng-member-portal__value
                  {{if card.highlight 'xpeng-member-portal__value--highlight'}}
                  {{if
                    card.memberType
                    'xpeng-member-portal__value--member-type'
                  }}
                  {{if card.mono 'xpeng-member-portal__value--mono'}}"
              >
                {{card.value}}
              </p>
            </div>
          {{/each}}
        </div>

        {{#if this.verified}}
          <div class="xpeng-member-portal__dvla">
            <div class="xpeng-member-portal__dvla-info">
              <div class="xpeng-member-portal__dvla-title">
                {{i18n "xpeng_member_portal.dvla_verified_title"}}
              </div>
              <div class="xpeng-member-portal__dvla-sub">
                {{this.profile.vehicle_model}}
                ·
                {{i18n "xpeng_member_portal.dvla_confirmed_owner"}}
              </div>
            </div>
            <div class="xpeng-member-portal__dvla-plate">
              {{this.profile.registration_number}}
            </div>
          </div>
        {{/if}}

        {{#if this.isReady}}
          {{#if this.resources.length}}
            <div class="xpeng-member-portal__resources">
              <h3 class="xpeng-member-portal__section-title">
                {{i18n "xpeng_member_portal.resources"}}
              </h3>
              <div class="xpeng-member-portal__resource-list">
                {{#each this.resources as |res|}}
                  <a
                    href="/t/{{res.id}}"
                    class="xpeng-member-portal__resource-link"
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    {{dIcon "link"}}
                    <div class="xpeng-member-portal__resource-text">
                      <span class="xpeng-member-portal__resource-title">
                        {{res.title}}
                      </span>
                      <p class="xpeng-member-portal__resource-excerpt">
                        {{res.excerpt}}
                      </p>
                    </div>
                  </a>
                {{/each}}
              </div>
            </div>
          {{/if}}
        {{else}}
          <div class="xpeng-member-portal__not-ready">
            <h3>{{i18n "xpeng_member_portal.vehicle_pending_title"}}</h3>
            <p>{{i18n "xpeng_member_portal.vehicle_pending_body"}}</p>
          </div>
        {{/if}}
      {{/if}}
    </div>
  </template>
}
