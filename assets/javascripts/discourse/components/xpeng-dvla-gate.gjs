import Component from "@glimmer/component";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";
import { service } from "@ember/service";
import routeAction from "discourse/helpers/route-action";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import XpengDvlaVerifyForm from "./xpeng-dvla-verify-form";

export default class XpengDvlaGate extends Component {
  @service currentUser;
  @service router;
  @service siteSettings;

  get topicRequiresVerification() {
    return this.args.topic?.requires_dvla_verification;
  }

  get isAnonymous() {
    return !this.currentUser;
  }

  get isVerifiedUser() {
    return this.currentUser?.groups?.some(
      (g) => g.name === this.siteSettings.xpeng_dvla_verified_group_name
    );
  }

  get shouldShow() {
    return (
      this.topicRequiresVerification &&
      !this.isVerifiedUser &&
      !this.currentUser?.admin
    );
  }

  @action
  addBodyClass() {
    document.body.classList.add("has-xpeng-dvla-gate");
  }

  @action
  removeBodyClass() {
    document.body.classList.remove("has-xpeng-dvla-gate");
  }

  @action
  handleVerifySuccess() {
    this.router.refresh();
  }

  <template>
    {{#if this.shouldShow}}
      <div
        class="xpeng-dvla-gate"
        {{didInsert this.addBodyClass}}
        {{willDestroy this.removeBodyClass}}
      >
        <div class="xpeng-dvla-gate__content">
          <div class="xpeng-dvla-gate__content--header">
            {{#if this.isAnonymous}}
              {{i18n "xpeng_member_portal.dvla.anonymous_heading_text"}}
            {{else}}
              {{i18n "xpeng_member_portal.dvla.logged_in_heading_text"}}
            {{/if}}
          </div>

          <p class="xpeng-dvla-gate__content--text">
            {{#if this.isAnonymous}}
              {{i18n "xpeng_member_portal.dvla.anonymous_subheading_text"}}
            {{else}}
              {{i18n "xpeng_member_portal.dvla.logged_in_subheading_text"}}
            {{/if}}
          </p>

          {{#if this.isAnonymous}}
            <div class="xpeng-dvla-gate__content--cta">
              <div class="xpeng-dvla-gate__content--cta__signup">
                <DButton
                  @action={{routeAction "showCreateAccount"}}
                  class="btn-primary btn-large sign-up-button"
                  @translatedLabel={{i18n
                    "xpeng_member_portal.dvla.signup_cta"
                  }}
                />
              </div>

              <div class="xpeng-dvla-gate__content--cta__login">
                <DButton
                  @action={{routeAction "showLogin"}}
                  @id="cta-login-link"
                  class="btn btn-text login-button"
                  @translatedLabel={{i18n "xpeng_member_portal.dvla.login_cta"}}
                />
              </div>
            </div>
          {{else}}
            <XpengDvlaVerifyForm @onSuccess={{this.handleVerifySuccess}} />
          {{/if}}
        </div>
      </div>
    {{/if}}
  </template>
}
