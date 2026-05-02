# OpenAccord — Privacy Notice

**Version 1.1 | Effective: May 1, 2026**

---

## 1. No Central Data Collection

OpenAccord is a decentralized protocol, not a hosted service. There is no central server, database, or backend operated by a controlling entity.

**No central entity collects your data.**

The `openaccord.xyz` website is a static informational site. It may use:
- Basic web server access logs (IP address, browser type, referrer)
- No analytics cookies by default
- No user accounts, no registration, no login

These logs, if any, are not shared and are not used to identify individuals. The protocol itself has no capacity to collect, store, or process personal data off-chain.

---

## 2. Local Software Architecture

The OpenAccord desktop and mobile applications run entirely on your device (Local-First).

**Data stored locally (on your device only):**
- **RPC Endpoint Configurations:** Your connections to blockchain nodes.
- **Local Indexer Database (SQLite):** A cached copy of public blockchain events synced via RPC. This data is a local replica of public on-chain data.
- **Application Settings:** User preferences, theme settings, and developer contribution preferences.
- **Encryption Keys:** If you utilize encryption features (e.g., for `encrypted_message_v1` schemas), your private keys for decryption are stored locally in your wallet or application storage. They are never transmitted to the protocol.

**No data is transmitted** from the local software to any OpenAccord-controlled server, because no such server exists.

**Transaction Construction:** Transactions are built locally in the application. Signing happens locally via your connected wallet. The software does not transmit unsigned transaction data externally.

---

## 3. On-Chain Data (Public by Design)

OpenAccord is a protocol for **publishing public data**. When you interact with OpenAccord smart contracts, your data becomes permanently public on the relevant blockchain.

**The following data is permanently public:**

- **Wallet Address:** Your public key is inherent to the transaction.
- **Intent Data:**
  - `schema_ref` (the type of intent, e.g., "service_agreement_v1")
  - `payload` (arbitrary data bytes, usually JSON)
  - `state_label` (status of the intent)
  - `image_refs` (links to media)
  - **Contact Information:** Any contact details embedded within the `payload` (e.g., Telegram handles, emails) are permanently visible.
- **Acknowledgement Data:**
  - Acknowledger Address
  - `note_payload` (arbitrary response data)
  - `state_label` (status of the acknowledgement)
- **OutcomeRecord Data:**
  - Outcome details and references to completed interactions.

**Irreversibility:** Blockchain data cannot be deleted. Once published, it is immutable and public forever.

**Warning regarding Schema-Bound Payloads:**
The protocol is schema-blind. It accepts arbitrary bytes. You are solely responsible for the content of your payloads.
- **Do not publish Personally Identifiable Information (PII)** (government IDs, home addresses, phone numbers) inside unencrypted payloads.
- **Do not publish sensitive financial details** (bank account numbers, credit cards) in plain text.
- Use **pseudonymous identifiers** (ENS names, Nostr keys, Telegram usernames) instead of real names or emails.

---

## 4. Encrypted Payloads & Messaging

OpenAccord supports schemas (e.g., `encrypted_message_v1`) that allow for encrypted communication.

**Protocol Blindness:**
The protocol stores encrypted payloads as arbitrary bytes. It cannot decrypt them, read them, or enforce encryption standards.

**User Responsibility:**
- **Encryption/Decryption:** Encryption and decryption happen locally in the GUI or via your wallet.
- **Key Management:** If you lose the private key required to decrypt a payload, the data remains on-chain but becomes unreadable to you (and everyone else without the key).
- **Metadata Visibility:** Even if payload content is encrypted, the **metadata** (sender address, receiver address, timestamp, transaction value, and schema type) is always public on-chain.

---

## 5. Cross-Chain References & Media

Users often reference external data in their Intents and Acknowledgements.

**Image & Media References:**
The protocol accepts references to images/media (IPFS, Arweave, HTTPS).
- **IPFS/Arweave:** These are public, decentralized networks. Accessing these links usually involves communicating with a gateway (e.g., `ipfs.io`, `arweave.net`), which may log your IP address.
- **HTTPS:** Direct links may track access.
- **Content:** The protocol does not host, censor, or filter referenced media.

**Cross-Chain References:**
Payloads may reference activity on other chains (e.g., a lock on Ethereum for an Intent on Solana).
- Publishing a transaction hash or address from another chain makes that association permanently public.

---

## 6. Third-Party Services & Ecosystem

OpenAccord operates within a broader ecosystem. You may interact with third-party services that have their own privacy policies:

**RPC Providers:**
To sync blockchain data, the local indexer connects to RPC nodes (e.g., Infura, Alchemy, QuickNode, Ankr, or private nodes).
- These providers may log your IP address and the requests you make.
- **Mitigation:** Configure your local app to use a private node or a trusted RPC endpoint in Settings.

**Wallets:**
You interact with the protocol via third-party wallets (MetaMask, Phantom, Sui Wallet, Ledger, etc.).
- These wallets manage your private keys and have their own privacy policies.

**Specialized GUIs & Third-Party Frontends:**
The OpenAccord ecosystem allows anyone to build specialized frontends (e.g., a "Web3 Fiverr" app built on OpenAccord).
- **These applications are independent of the core protocol.**
- They may collect data, require logins, or use analytics.
- **Always check the privacy policy of the specific frontend application you are using.** The core protocol has no data sharing agreements with these entities.

---

## 7. Developer Contributions

The official open-source GUI includes an optional developer contribution mechanism.

- If enabled, the contribution amount and your wallet address are recorded in the transaction on the relevant blockchain.
- This is public data inherent to the blockchain transaction, not collected by OpenAccord.

---

## 8. Data Retention

**On-Chain Data:** Retained indefinitely by the blockchain network. The protocol cannot delete or modify it.

**Local Data:** Retained on your device until you uninstall the application or manually delete the local database.

**Logs:** The website `openaccord.xyz` retains basic server logs for a maximum of 30 days for security maintenance, after which they are deleted.

---

## 9. Contact

There is no centralized organization, Data Protection Officer, or compliance department for OpenAccord.

For questions regarding this notice or the protocol's architecture, open an issue in the public repository:
`github.com/openaccord` (placeholder — replace with actual repo).

---

*This privacy notice describes the architecture of a decentralized, local-first protocol. It is not a policy of a data controller, because no central controller exists.*
