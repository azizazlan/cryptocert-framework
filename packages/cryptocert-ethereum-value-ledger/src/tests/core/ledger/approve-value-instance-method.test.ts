import { GenericProvider } from "@cryptocert/ethereum-generic-provider";
import { Protocol } from "@cryptocert/ethereum-sandbox";
import { Spec } from "@specron/spec";
import { ValueLedger } from "../../../core/ledger";

const spec = new Spec<{
  provider: GenericProvider;
  ledger: ValueLedger;
  protocol: Protocol;
  coinbase: string;
  bob: string;
  jane: string;
  sara: string;
}>();

spec.before(async (stage) => {
  const protocol = new Protocol(stage.web3);
  stage.set("protocol", await protocol.deploy());
});

spec.before(async (stage) => {
  const accounts = await stage.web3.eth.getAccounts();
  stage.set("coinbase", accounts[0]);
  stage.set("bob", accounts[1]);
  stage.set("jane", accounts[2]);
  stage.set("sara", accounts[3]);
});

spec.before(async (stage) => {
  const provider = new GenericProvider({
    client: stage.web3,
    accountId: stage.get("coinbase"),
    requiredConfirmations: 0,
  });
  stage.set("provider", provider);
});

spec.before(async (stage) => {
  const provider = stage.get("provider");
  const ledgerId = stage.get("protocol").erc20.instance.options.address;
  const actionsGatewayId =
    stage.get("protocol").actionsGateway.instance.options.address;
  stage.set("ledger", new ValueLedger(provider, ledgerId));
});

spec.test("approves account for value transfer", async (ctx) => {
  const ledger = ctx.get("ledger");
  const coinbase = ctx.get("coinbase");
  const bob = ctx.get("bob");
  const token = ctx.get("protocol").erc20;
  const value = "300000000000000000000000";
  const mutation = await ledger.approveValue(value, bob);
  await mutation.complete();
  ctx.is(mutation.logs[0].event, "Approval");
  ctx.is(await token.instance.methods.allowance(coinbase, bob).call(), value);
});

spec.test(
  "fails to reapprove account without reseting approval",
  async (ctx) => {
    const ledger = ctx.get("ledger");
    const coinbase = ctx.get("coinbase");
    const jane = ctx.get("jane");
    const token = ctx.get("protocol").erc20;
    const value = "300000000000000000000000";
    await ledger.approveValue(value, jane);
    ctx.is(
      await token.instance.methods.allowance(coinbase, jane).call(),
      value
    );
    await ctx.throws(() => ledger.approveValue(value, jane));
  }
);

spec.test("reapprove account by reseting approval", async (ctx) => {
  const ledger = ctx.get("ledger");
  const coinbase = ctx.get("coinbase");
  const sara = ctx.get("sara");
  const token = ctx.get("protocol").erc20;
  const value = "300000000000000000000000";
  await ledger.approveValue(value, sara);
  ctx.is(await token.instance.methods.allowance(coinbase, sara).call(), value);
  await ledger.approveValue("0", sara);
  ctx.is(await token.instance.methods.allowance(coinbase, sara).call(), "0");
  await ledger.approveValue(value, sara);
  ctx.is(await token.instance.methods.allowance(coinbase, sara).call(), value);
});

export default spec;
