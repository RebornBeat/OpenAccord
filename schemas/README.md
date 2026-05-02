# OpenAccord Schema Library

Schemas define how Intent payloads are structured and rendered in the local GUI. They are the "lens" through which the GUI interprets the protocol's raw data.

## How Schemas Work

1. The smart contract is completely schema-blind. It stores `schema_ref` (a string) and `payload` (arbitrary bytes).
2. The GUI reads the `schema_ref` from an on-chain Intent.
3. It looks up the matching `.json` file from this directory.
4. It renders a structured form based on the schema definition.
5. Unknown schemas fall back to a raw JSON viewer.

**For Acknowledgements:**
If an Intent payload includes a field specifying a `preferred_ack_schema`, the GUI will attempt to render the Acknowledgement payload using that schema definition. This enables structured responses and complex workflows.

---

## Core Concepts

### Schema-Blind Storage
The OpenAccord smart contract does not validate payload content. It stores:
- `schema_ref`: A string identifier (e.g., `"service_agreement_v1"`)
- `payload`: Arbitrary bytes (typically JSON encoded by the GUI)

Validation and rendering happen entirely in the local GUI based on the schema definition files. This allows the protocol to support any future use case without upgrading the smart contract.

### Schema-Bound Acknowledgements (Advanced)
An Intent is not just a static listing; it can define the "rules of engagement" for responses.

By including a field like `preferred_ack_schema` in your Intent payload, you can signal to the GUI that you expect Acknowledgements to follow a specific structure.

**Example:**
- **Intent:** "Cross-Chain Asset Swap" (`asset_swap_v1`) includes a field requesting `cross_chain_lock_v1` acknowledgement schema.
- **Acknowledgement:** The GUI renders a form asking the user to input their transaction hash and lock details, rather than just a generic text box.
- **Result:** Structured, machine-readable responses that can trigger off-chain logic or verification.

---

## Schema File Format

Each schema file defines:
- `id` — Matches the `schema_ref` string stored on-chain
- `version` — Semver string
- `label` — Human-readable name
- `description` — What this schema is for
- `category` — UI grouping (`"services"`, `"goods"`, `"financial"`, `"identity"`, `"communication"`, `"other"`)
- `fields` — Array of field definitions
- `acknowledgement_guidance` (Optional) — Defines how Acknowledgements for this Intent should be structured. Can suggest a specific schema or define fields inline.

---

## Field Types

| Type | Description |
|---|---|
| `text` | Short single-line string |
| `textarea` | Multi-line string |
| `number` | Numeric value |
| `select` | Dropdown (provide `options` array) |
| `multiselect` | Multiple choice |
| `url` | URL validation |
| `address` | Blockchain address |
| `timestamp` | Date/time picker |
| `boolean` | Toggle |
| `image_refs` | Image reference input (IPFS/Arweave/HTTPS) |
| `contact` | Contact method selector (type + value pair) |
| `tags` | Free-form tag array |

---

## Advanced Payload Patterns

Because `payload` is arbitrary bytes, schemas can define complex Web3 interactions. The GUI interprets these bytes, enabling powerful dApp-like functionality on top of the neutral protocol.

### A. Encrypted Messaging
Use the `encrypted_message_v1` schema to store PGP or NaCl encrypted content in the payload.
- **GUI Role:** Decrypts content locally using the user's private key (if available) or displays the encrypted blob.
- **Use Case:** Private negotiation, decentralized chat applications, secure data transfer.

### B. Cross-Chain Value Assignment
Use the `cross_chain_lock_v1` schema inside an Acknowledgement.
- **Payload Data:** Chain ID, Transaction Hash, Lock Contract Address.
- **GUI Role:** Displays a verification status or "View on Explorer" link for the referenced chain.
- **Use Case:** Proving funds are locked on Chain A for an Intent on Chain B, enabling cross-chain coordination without bridges.

### C. Phased Workflows
Use `milestone_deliverable_v1` schemas in Acknowledgements to track project progress.
- **State Labels:** Use `advance_state` functions to mark milestones as `approved` or `revision_requested`.
- **Use Case:** Freelance platforms, supply chain tracking, multi-stage service agreements.

---

## Contributing Schemas

1. Create a new `.json` file following the format above.
2. Use a unique `id` in the format `descriptive_name_v1`.
3. If building a specialized dApp, consider creating a "Suite" of schemas (Intent Schema + Acknowledgement Schema) to enable complex workflows.
4. Submit a PR to this repository.

All schemas are opt-in. Users can always define custom schemas without submitting here.
