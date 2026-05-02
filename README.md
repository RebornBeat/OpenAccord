Here is the fully updated, corrected, and expanded `README.md`. This version integrates the new vision, the multi-chain advantages, the ecosystem potential, and the advanced "Schema-Bound Acknowledgement" architecture while preserving all existing technical details and structure.

```markdown
# OpenAccord

**A neutral, open-source protocol for publishing intents and recording self-directed outcomes across multiple blockchains.**

> "The HTTP of Web3 agreements."

OpenAccord is not an exchange. It is not a marketplace. It is not a broker.

It is **generalized agreement infrastructure** — a protocol that lets any user publish arbitrary structured data ("Intents") and independently record the results of their own interactions ("Outcomes") on-chain, across multiple blockchains, without any central operator, custodian, or intermediary.

---

## The Vision: A Universal Coordination Layer

The original web succeeded because HTTP was a neutral, lightweight standard for publishing information. It decoupled content from the platform.

OpenAccord does the same for **value exchange and human agreement**.

By standardizing the format of an "Intent" and an "Outcome," OpenAccord creates a **Universal Coordination Layer** that is:
- **Chain-agnostic:** Native to Sui, Ethereum, Solana, and beyond.
- **Application-agnostic:** Neutral to whether the intent is a job offer, a goods listing, or a cross-chain swap.
- **Execution-agnostic:** The protocol records the agreement and the result; it does not enforce the middle.

This layer enables a new ecosystem of vertical applications, AI agents, and reputation systems to flourish on top of a shared, permissionless data standard.

---

## What You Can Use It For

The protocol is generalized. The specific use case is defined by the schema you choose:

- **Services:** Publishing a service offer and recording when work is delivered.
- **Commerce:** Listing goods for local or global sale with on-chain proof of completion.
- **Finance:** Coordinating asset swaps peer-to-peer without an exchange.
- **Rental:** Managing property or equipment rentals with phased on-chain records.
- **Barter:** Exchanging anything for anything — no currency required.
- **Identity:** Creating a portable profile that aggregates all your intents into a "Store."
- **Messaging:** Encrypted, decentralized communication layers via structured payloads.
- **Coordination:** Phased project management and milestone tracking.

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
| No Identity Verification | ✅ Protocol performs no identity checks |

---

## The Multi-Chain Advantage

Most Web3 protocols are siloed by chain. A marketplace on Ethereum cannot easily see a listing on Solana.

OpenAccord unifies these silos via **Local-First Architecture**:
1.  **Native Deployments:** Identical smart contracts are deployed independently on every major chain.
2.  **Unified Local View:** The user’s local indexer (desktop/mobile) syncs events from *all* supported chains into a single, local database.
3.  **Cross-Chain Discovery:** A user can browse service offers on Ethereum, goods on Solana, and rentals on Sui — all in one unified interface, with no central server.

**The result:** A global, borderless, and chain-portable graph of peer-to-peer activity.

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

The protocol defines three core objects. The on-chain layer is strictly a **data storage layer**; it does not execute logic.

1. **Intent** — A user-published record containing a `schema_ref` (string) and `payload` (arbitrary bytes). The contract is schema-blind: it stores whatever the user puts in.
2. **Acknowledgement** — A non-binding signal that another address has interacted with an Intent. Does not imply commitment or acceptance of any terms.
3. **OutcomeRecord** — A self-reported, non-authoritative record of what happened. Created independently by any party. Not verified by the protocol.

### The "Payload" Revolution

Because the protocol is schema-blind, the `payload` field in both Intents and Acknowledgements can carry arbitrary data. This allows developers to build complex dApps *on top of* OpenAccord without changing the protocol.

#### Schema-Bound Acknowledgements
An Intent creator can specify a `preferred_ack_schema` in their payload. This turns an Acknowledgement from a simple "I'm interested" into a structured data entry.
-   **Example:** An Intent seeking funding requests a `cross_chain_lock_v1` Acknowledgement. The Acknowledger submits a payload containing the transaction hash of a locked vault on another chain.
-   **Result:** Cross-chain value assignment without a bridge.

#### Encrypted Messaging
Schemas can define encryption standards.
-   **Example:** A `encrypted_message_v1` Intent starts a secure thread. Acknowledgements carry encrypted blobs (using PGP or wallet signatures).
-   **Result:** A decentralized, encrypted messaging app runs entirely on top of OpenAccord infrastructure.

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

## Ecosystem Potential

Because the protocol is schema-blind and the GUI is local-first, OpenAccord serves as the base layer for thousands of potential applications:

### 1. Vertical Marketplaces (The "Web3 Fiverr/Craigslist")
Specialized applications can wrap the OpenAccord protocol with a custom GUI and curated schema sets.
-   **Freelance Platforms:** A "Web3 Upwork" that reads `service_agreement_v1` intents from the blockchain and displays them in a polished dashboard.
-   **Local Commerce:** A city-specific app that filters `goods_listing_v1` intents by location.

### 2. AI Agents & Autonomous Coordination
Intents are structured, machine-readable data. This enables AI-to-AI and AI-to-human coordination.
-   **Autonomous Negotiation:** AI agents scan open Intents across chains and propose deals based on user-defined criteria.
-   **Service Discovery:** An AI agent finds the best rate for a specific service by parsing Intent payloads globally.

### 3. Portable, Self-Sovereign Reputation
Existing platforms lock reputation inside their walled gardens. OpenAccord makes reputation portable.
-   **Activity Signals:** OutcomeRecords create a raw, on-chain history of successful interactions.
-   **Trust Portability:** A user can carry their on-chain history from a freelance app to a rental app to a trading platform — no login required, just their wallet.

---

## Fee Model

Core smart contract calls are gas-only. The protocol charges nothing.

The open-source desktop/mobile GUI includes an optional developer contribution field (default: enabled, small fixed amount in native token). Users can disable this or set it to zero in Settings → Advanced. The contract always accepts 0-fee transactions. This is by design: the protocol is permissionless.

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

OpenAccord is neutral infrastructure. It does not facilitate, execute, match, or intermediate transactions. Users are solely responsible for all interactions, compliance, and risks.

**Content Responsibility:** OpenAccord does not host files, moderate content, or verify the legality of user-submitted data. Users are solely responsible for ensuring that any data, images, or links published via the protocol comply with all applicable laws.

See `/legal/DISCLAIMER.md` for full notice.

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
