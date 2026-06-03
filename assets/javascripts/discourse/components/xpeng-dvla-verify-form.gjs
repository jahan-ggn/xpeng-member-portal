import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import DButton from "discourse/ui-kit/d-button";
import TextField from "discourse/ui-kit/d-text-field";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class XpengDvlaVerifyForm extends Component {
  @tracked regNumber = "";
  @tracked errorMessage = null;
  @tracked isLoading = false;

  @action
  async verifyRegistration() {
    const number = this.regNumber.trim();

    if (!number) {
      this.errorMessage = i18n("xpeng_member_portal.dvla.reg_number_required");
      return;
    }

    this.isLoading = true;
    this.errorMessage = null;

    try {
      const result = await ajax("/xpeng-member-portal/verify-dvla", {
        type: "POST",
        data: { registration_number: number },
      });

      if (result.verified) {
        this.args.onSuccess?.();
      } else {
        this.errorMessage =
          result.reason || i18n("xpeng_member_portal.dvla.verification_failed");
      }
    } catch (error) {
      this.errorMessage =
        error.jqXHR?.responseJSON?.error ||
        error.jqXHR?.responseJSON?.reason ||
        i18n("xpeng_member_portal.dvla.generic_error");
    } finally {
      this.isLoading = false;
    }
  }

  <template>
    <div class="xpeng-dvla-verify-form">
      <TextField
        @value={{this.regNumber}}
        @placeholder={{i18n "xpeng_member_portal.dvla.placeholder"}}
        @disabled={{this.isLoading}}
        class="xpeng-dvla-verify-form__input"
      />
      <DButton
        @action={{this.verifyRegistration}}
        @disabled={{this.isLoading}}
        @translatedLabel={{i18n "xpeng_member_portal.dvla.verify_button"}}
        class="btn-primary"
      />
    </div>

    {{#if this.errorMessage}}
      <div class="xpeng-dvla-verify-form__error">
        {{dIcon "triangle-exclamation"}}
        {{this.errorMessage}}
      </div>
    {{/if}}
  </template>
}
