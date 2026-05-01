# OpenAccord

**A neutral, open-source protocol for publishing intents and recording self-directed outcomes across multiple blockchains.**

> "Publish intents. Record outcomes. Use at your own discretion."

OpenAccord is not an exchange. It is not a marketplace. It is not a broker.

It is generalized agreement infrastructure — a protocol that lets any user publish arbitrary structured data ("Intents") and independently record the results of their own interactions ("Outcomes") on-chain, across multiple blockchains, without any central operator, custodian, or intermediary.

---

## What You Can Use It For

- Publishing a service offer and recording when work is delivered
- Listing goods for local or global sale with on-chain proof of completion
- Coordinating asset swaps peer-to-peer without an exchange
- Posting job listings with milestone tracking
- Rental agreements with on-chain phased records
- Barter coordination
- Anything that involves two parties reaching an agreement

---

## Core Philosophy

| Property | Status |
|---|---|
| Non-custodial | ✅ Protocol never touches funds |
| Permissionless | ✅ Any wallet can publish or acknowledge |
| Generalized | ✅ Schema-driven, not trade-specific |
| Local-first | ✅ All tooling runs on your device |
| Open-source | ✅ MIT licensed, fully forkable |
| Chain-agnostic | ✅ Sui, Ethereum, Solana (and more) |
| No central operator | ✅ No hosted backend |
| No KYC | ✅ Protocol collects nothing |

---

## Repository Structure

```
openaccord/
├── contracts/
│   ├── sui/                    # Sui Move smart contract
│   ├── ethereum/               # Solidity contract (EVM chains)
│   └── solana/                 # Anchor program (Solana)
├── schemas/                    # JSON schema definitions
├── legal/                      # Legal documents and notices
├── website/                    # Informational site (React + Tailwind)
│   └── src/
├── desktop/                    # Desktop app (Electron + React)
│   ├── electron/
│   └── src/
│       ├── renderer/           # React UI
│       ├── indexer/            # Local blockchain indexer
│       └── constructor/        # Transaction builder
├── mobile/                     # React Native mobile app
└── docs/
    └── guides/                 # User guides
```

---

## Architecture Overview

### On-Chain Layer (The Protocol)

The protocol defines three core objects:

1. **Intent** — A user-published record containing a `schema_ref` (string) and `payload` (arbitrary bytes). The contract is schema-blind: it stores whatever the user puts in.
2. **Acknowledgement** — A non-binding signal that another address has interacted with an Intent. Does not imply commitment or acceptance of any terms.
3. **OutcomeRecord** — A self-reported, non-authoritative record of what happened. Created independently by any party. Not verified by the protocol.

### Off-Chain Layer (Local Tooling)

- **Local Indexer** — Syncs on-chain events via RPC, builds a local SQLite database. You control your data.
- **Transaction Constructor** — Builds ready-to-sign transaction payloads. Optional dev contribution included by default, removable in settings.
- **Desktop GUI** — Electron + React. Runs fully locally. Schema-aware rendering.
- **Mobile App** — React Native. Same local-first model.

### Schema System

The contract is schema-blind. The GUI is schema-aware. Schemas are JSON files stored locally (and contributed to this repo). When the GUI sees a known `schema_ref`, it renders a structured form. When it sees an unknown one, it shows a raw JSON viewer. Users can define custom schemas without permission.

### Image & Media References

Images are never hosted by OpenAccord. The `image_refs` field in any schema accepts:
- IPFS links: `ipfs://QmXxx...`
- Arweave links: `ar://xxxTx`
- HTTPS links: `https://any-cdn.com/image.jpg`

The GUI resolves IPFS via public gateways (configurable), Arweave via arweave.net, and HTTPS directly.

### Stores (Profile Intents)

There is no central store concept. Users publish a `profile_v1` Intent that aggregates their identity. The GUI detects this schema and renders a "store view" — all Intents from that address, grouped by schema type. No central registration required.

---

## Fee Model

Core smart contract calls are gas-only. The protocol charges nothing.

The open-source desktop/mobile GUI includes an optional developer contribution field (default: enabled, small fixed amount in native token). Users can disable this in Settings → Advanced → Developer Contribution. The contract always accepts 0-fee transactions. This is by design: the protocol is permissionless.

**Legal framing:** Contributions are voluntary support for open-source software maintenance. They are not protocol fees, commissions, or trading taxes.

---

## Deployed Contract Addresses

| Chain | Address | Status |
|---|---|---|
| Sui Mainnet | TBD after audit | Pending |
| Ethereum Mainnet | TBD after audit | Pending |
| Solana Mainnet | TBD after audit | Pending |
| Sui Testnet | TBD | Active |
| Sepolia (ETH Testnet) | TBD | Active |
| Solana Devnet | TBD | Active |

---

## Getting Started

### Use the Desktop App (Recommended)
1. Download from [openaccord.xyz](https://openaccord.xyz)
2. Open and connect your wallet
3. Select a chain
4. Browse Intents or publish your own

### Use the CLI / Contract Directly
1. Deploy or point to existing contract addresses above
2. Call `publish_intent` with your schema ref and encoded payload
3. No software required

### Run the Indexer Only
```bash
cd desktop
npm install
npm run indexer
```

---

## Legal Notice

OpenAccord is neutral infrastructure. It does not facilitate, execute, match, or intermediate transactions. Users are solely responsible for all interactions, compliance, and risks. See `/legal/DISCLAIMER.md` for full notice.

---

## Contributing

All contributions welcome. Priority areas:
- New schema definitions (`/schemas/`)
- Additional chain contracts
- Indexer chain adapters
- GUI improvements
- Translations

Please read `CONTRIBUTING.md` before submitting PRs.

---

## License

MIT License. See `LICENSE`.

---

## Security

Do not use this software with funds you cannot afford to lose. Smart contracts have not yet been professionally audited. Audit is planned before mainnet deployment. See `SECURITY.md`.
