Standalone usage:

```ts
import { Sandbox } from 'cryptocert/ethereum-sandbox';

const sandbox = new Sandbox();
await sandbox.listen();
...
await sandbox.close();
```

Specron example:

```ts
import { Spec } from "@specron/spec";
import { Protocol } from "cryptocert/ethereum-sandbox";

const spec = new Spec();

spec.before(async (stage) => {
  await Protocol.deploy(stage.web3);
});

export default spec;
```

Hayspec example:

```ts
import { Spec } from "@hayspec/spec";
import { Sandbox } from "cryptocert/ethereum-sandbox";

interface Data {
  sandbox: Sandbox;
}

const spec = new Spec<Data>();

spec.before(async (stage) => {
  stage.set("sandbox", await Sandbox.listen());
});

spec.after(async (stage) => {
  await stage.get("sandbox").close();
});

export default spec;
```
