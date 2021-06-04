import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import UserHumanPasswordEditValidations from "../../validations/user-human/passwordEdit";
import lookupValidator from "ember-changeset-validations";
import Changeset from "ember-changeset";
import { inject as service } from "@ember/service";
import ENV from "../../config/environment";

export default class ProfilePasswordUpdateComponent extends Component {
  @service fetchService;

  UserHumanPasswordEditValidations = UserHumanPasswordEditValidations;

  constructor() {
    super(...arguments);

    let passwordChangeset = {
      oldPassword: "",
      newPassword1: "",
      newPassword2: ""
    };

    this.changeset = new Changeset(
      passwordChangeset,
      lookupValidator(UserHumanPasswordEditValidations),
      UserHumanPasswordEditValidations
    );
  }

  @action
  abort() {
    if (this.onAbort) this.onAbort();
  }

  @action
  async submit() {
    await this.changeset.validate();
    if (this.changeset.inValid) return;

    const requestBody = {
      data: {
        attributes: {
          old_password: this.changeset.oldPassword,
          new_password1: this.changeset.newPassword1,
          new_password2: this.changeset.newPassword2
        }
      }
    };

    this.fetchService.send("/api/profile/password", {
      method: "PATCH",
      headers: {
        Accept: "application/vnd.api+json",
        "Content-Type": "application/json",
        "X-CSRF-Token": ENV.CSRFToken
      },
      body: JSON.stringify(requestBody)
    });
  }
}
