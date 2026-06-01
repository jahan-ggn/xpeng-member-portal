import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

export default class UserPortalRoute extends Route {
  model() {
    const user = this.modelFor("user");
    return ajax("/xpeng-member-portal/member-profile.json", {
      data: { username: user.username },
    }).catch((error) => {
      const specificError =
        error?.responseJSON?.error || error?.jqXHR?.responseJSON?.error;
      if (specificError) {
        return { error: specificError };
      }
      return {
        error: `${i18n("xpeng_member_portal.error_title")} — ${i18n("xpeng_member_portal.unknown_error")}`,
      };
    });
  }
}
