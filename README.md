# 0xcert suite

## TODO

### Docs

- add provider errors table
- add asset ledger
- add value ledger
- add order gateway

### Core

- [L,K,T] 0xcert/ethereum-utils complete refactoring - remove web3
- [K] WsProvider for https://github.com/ethereum/go-ethereum/wiki/RPC-PUB-SUB (window.Websocket or require('ws')).
- [K] AssetLedger, ValueLedger and OrderGateway subscribe to events (handle connetion lost)
- [K] use BigNumber for all ethereum packages (when 0xcert/ethereum-utils is refactored)
- [T] GenericProvider, OrderGateway support safeTransfer by adding a list of trusted addresses
- [T] automatically handle `gas: 6000000,` on mutations
- [T] add transfer to ValueLedger
- [T] upgrade to solidity 5
- [T] Trezor & EIP712 signature

## Development

Repository management: https://gist.github.com/xpepermint/eecfc6ad6cd7c9f5dcda381aa255738d
Codecov integration: https://gist.github.com/xpepermint/34c1815c2c0eae7aebed58941b16094e
Rush commands: https://gist.github.com/xpepermint/eecfc6ad6cd7c9f5dcda381aa255738d
Error code list: https://docs.google.com/spreadsheets/d/1TKiFKO9oORTIrMyjC11oqcaWWpTUVli5o9tOTh5Toio/edit?usp=sharing

## CDN hosting

```
https://cdn.jsdelivr.net/gh/0xcert/ethereum-erc721/dist/<file-name>.min.js
```

Note this URL above is not secure, it is for testing purposes only, for details see https://github.com/0xcert/framework/issues/180

## Contributing

See [CONTRIBUTING.md](https://github.com/0xcert/suite/blob/master/CONTRIBUTING.md) for how to help out.

## Licence

See [LICENSE](https://github.com/0xcert/suite/blob/master/LICENCE) for details.

## CDN
Once this repo is public we'll be able to use the compiled libraries through a CDN like this:
* For `0xcert-main`: `https://cdn.jsdelivr.net/gh/0xcert/framework@[version]/dist/0xcert-main.js`,
* For `0xcert-web3`: `https://cdn.jsdelivr.net/gh/0xcert/framework@[version]/dist/0xcert-web3.js`.
