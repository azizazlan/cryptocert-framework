import { XcertAbilities } from "@cryptocert/ethereum-xcert-contracts/src/core/types";
import { Spec } from "@specron/spec";
import { AbilitableManageProxyAbilities } from "../core/types";

/**
 * Spec context interfaces.
 */

interface Data {
  abilitableManageProxy?: any;
  owner?: string;
  bob?: string;
  jane?: string;
  cat?: string;
}

const spec = new Spec<Data>();

spec.before(async (ctx) => {
  const accounts = await ctx.web3.eth.getAccounts();
  ctx.set("owner", accounts[0]);
  ctx.set("bob", accounts[1]);
  ctx.set("jane", accounts[2]);
});

spec.beforeEach(async (ctx) => {
  const abilitableManageProxy = await ctx.deploy({
    src: "./build/abilitable-manage-proxy.json",
    contract: "AbilitableManageProxy",
  });
  ctx.set("abilitableManageProxy", abilitableManageProxy);
});

spec.test("adds authorized address", async (ctx) => {
  const abilitableManageProxy = ctx.get("abilitableManageProxy");
  const owner = ctx.get("owner");
  const bob = ctx.get("bob");
  const logs = await abilitableManageProxy.instance.methods
    .grantAbilities(bob, AbilitableManageProxyAbilities.EXECUTE)
    .send({ from: owner });
  ctx.not(logs.events.SetAbilities, undefined);

  const bobHasAbilityToExecute = await abilitableManageProxy.instance.methods
    .isAble(bob, AbilitableManageProxyAbilities.EXECUTE)
    .call();
  ctx.is(bobHasAbilityToExecute, true);
});

spec.test("removes authorized address", async (ctx) => {
  const abilitableManageProxy = ctx.get("abilitableManageProxy");
  const owner = ctx.get("owner");
  const bob = ctx.get("bob");
  await abilitableManageProxy.instance.methods
    .grantAbilities(bob, AbilitableManageProxyAbilities.EXECUTE)
    .send({ from: owner });
  const logs = await abilitableManageProxy.instance.methods
    .revokeAbilities(bob, AbilitableManageProxyAbilities.EXECUTE)
    .send({ from: owner });
  ctx.not(logs.events.SetAbilities, undefined);

  const bobHasAbilityToExecute = await abilitableManageProxy.instance.methods
    .isAble(bob, AbilitableManageProxyAbilities.EXECUTE)
    .call();
  ctx.is(bobHasAbilityToExecute, false);
});

spec.test("sets abilities", async (ctx) => {
  const abilitableManageProxy = ctx.get("abilitableManageProxy");
  const owner = ctx.get("owner");
  const bob = ctx.get("bob");
  const jane = ctx.get("jane");

  await abilitableManageProxy.instance.methods
    .grantAbilities(bob, AbilitableManageProxyAbilities.EXECUTE)
    .send({ from: owner });

  const cat = await ctx.deploy({
    src: "cryptocert/ethereum-xcert-contracts/build/xcert-mock.json",
    contract: "XcertMock",
    args: [
      "cat",
      "CAT",
      "https://0xcert.org/",
      ".json",
      "0xa65de9e6",
      ["0x0d04c3b8"],
    ],
  });

  await cat.instance.methods
    .grantAbilities(
      abilitableManageProxy.receipt._address,
      XcertAbilities.MANAGE_ABILITIES
    )
    .send({ from: owner });
  await abilitableManageProxy.instance.methods
    .set(cat.receipt._address, jane, XcertAbilities.TOGGLE_TRANSFERS)
    .send({ from: bob });

  const hasToggleTransferAbility = await cat.instance.methods
    .isAble(jane, XcertAbilities.TOGGLE_TRANSFERS)
    .call();
  ctx.true(hasToggleTransferAbility);
});

spec.test("removes self manage abilities", async (ctx) => {
  const abilitableManageProxy = ctx.get("abilitableManageProxy");
  const owner = ctx.get("owner");
  const bob = ctx.get("bob");

  await abilitableManageProxy.instance.methods
    .grantAbilities(bob, AbilitableManageProxyAbilities.EXECUTE)
    .send({ from: owner });

  const cat = await ctx.deploy({
    src: "cryptocert/ethereum-xcert-contracts/build/xcert-mock.json",
    contract: "XcertMock",
    args: [
      "cat",
      "CAT",
      "https://0xcert.org/",
      ".json",
      "0xa65de9e6",
      ["0x0d04c3b8"],
    ],
  });

  await cat.instance.methods
    .grantAbilities(
      abilitableManageProxy.receipt._address,
      XcertAbilities.MANAGE_ABILITIES
    )
    .send({ from: owner });

  await abilitableManageProxy.instance.methods
    .set(cat.receipt._address, abilitableManageProxy.receipt._address, 0)
    .send({ from: bob });
  const hasManageAbility = await cat.instance.methods
    .isAble(
      abilitableManageProxy.receipt._address,
      XcertAbilities.MANAGE_ABILITIES
    )
    .call();
  ctx.false(hasManageAbility);
});

spec.test(
  "fails if set abilities is called by an unauthorized address",
  async (ctx) => {
    const abilitableManageProxy = ctx.get("abilitableManageProxy");
    const owner = ctx.get("owner");
    const bob = ctx.get("bob");
    const jane = ctx.get("jane");

    const cat = await ctx.deploy({
      src: "cryptocert/ethereum-xcert-contracts/build/xcert-mock.json",
      contract: "XcertMock",
      args: [
        "cat",
        "CAT",
        "https://0xcert.org/",
        ".json",
        "0xa65de9e6",
        ["0x0d04c3b8"],
      ],
    });

    await cat.instance.methods
      .grantAbilities(
        abilitableManageProxy.receipt._address,
        XcertAbilities.MANAGE_ABILITIES
      )
      .send({ from: owner });
    await ctx.reverts(() =>
      abilitableManageProxy.instance.methods
        .set(cat.receipt._address, jane, XcertAbilities.TOGGLE_TRANSFERS)
        .send({ from: bob })
    );
  }
);

export default spec;
