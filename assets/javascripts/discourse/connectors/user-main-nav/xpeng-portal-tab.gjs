import Component from "@glimmer/component";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class XpengPortalNavItem extends Component {
  @service router;
  @service currentUser;

  get isActive() {
    return this.router.currentRouteName === "user.portal";
  }

  get shouldRender() {
    if (!this.currentUser) {
      return false;
    }
    if (this.currentUser.admin) {
      return true;
    }
    return this.currentUser.id === this.args.model?.id;
  }

  <template>
    {{#if this.shouldRender}}
      <li class="user-nav__portal {{if this.isActive 'active'}}">
        <LinkTo @route="user.portal" @model={{@outletArgs.model}}>
          {{dIcon "id-card"}}
          <span>{{i18n "xpeng_member_portal.nav_label"}}</span>
        </LinkTo>
      </li>
    {{/if}}
  </template>
}
