import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";

module("Integration | Component | admin/user/table-row", function (hooks) {
  setupRenderingTest(hooks);

  test("it renders with data", async function (assert) {
    let now = new Date();
    this.set("user", {
      label: "Bob Muster",
      username: "bob",
      lastLoginAt: now,
      lastLoginFrom: "127.0.0.1",
      providerUid: "123456",
      role: "user"
    });

    await render(hbs`<Admin::User::TableRow @user={{this.user}}/>`);

    let text = this.element.textContent.trim();
    assert.ok(text.includes("Bob Muster"));
    assert.ok(text.includes("bob"));
    /* eslint-disable no-undef  */
    assert.ok(text.includes(moment(now).format("DD.MM.YYYY hh:mm")));
    /* eslint-enable no-undef  */
    assert.ok(text.includes("127.0.0.1"));
    assert.ok(text.includes("123456"));
    assert.ok(text.includes("user"));
  });
});
