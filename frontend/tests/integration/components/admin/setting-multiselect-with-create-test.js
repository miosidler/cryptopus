import { module, test } from "qunit";
import { setupRenderingTest } from "ember-qunit";
import { render } from "@ember/test-helpers";
import { hbs } from "ember-cli-htmlbars";
import { setLocale } from "ember-intl/test-support";

module(
  "Integration | Component | admin/setting-multiselect-with-create",
  function (hooks) {
    setupRenderingTest(hooks);

    hooks.beforeEach(function () {
      setLocale("en");
    });

    test("it renders without data", async function (assert) {
      await render(hbs`<Admin::SettingMultiselectWithCreate />`);

      let text = this.element.textContent.trim();
      assert.ok(text.includes("Whitelisted ips"));
    });

    test("it renders with data", async function (assert) {
      this.set("ipAddresses", {
        key: "ip_whitelist",
        value: ["0.0.0.0", "255.255.255.255", "3.3.3.3"]
      });

      await render(
        hbs`<Admin::SettingMultiselectWithCreate @options={{this.ipAddresses}}/>`
      );

      let text = this.element.textContent.trim();
      assert.ok(text.includes("0.0.0.0"));
      assert.ok(text.includes("255.255.255.255"));
      assert.ok(text.includes("3.3.3.3"));
    });
  }
);
