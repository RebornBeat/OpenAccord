# OpenAccord — Privacy Notice

**Version 1.0 | Effective: May 1, 2026**

---

## 1. No Central Data Collection

OpenAccord does not operate a central server, database, or hosted service.
No central entity collects your data.

The openaccord.xyz website is a static informational site. It may use:
- Basic web server access logs (IP address, browser type, referrer)
- No analytics cookies by default
- No user accounts, no registration

These logs, if any, are not shared and are not used to identify individuals.

---

## 2. Local Software

The OpenAccord desktop and mobile applications run entirely on your device.

**Data stored locally (on your device only):**
- Your RPC endpoint configurations
- Cached blockchain data synced by the local indexer
- Application settings including wallet preferences

**No data is transmitted** from the local software to any OpenAccord-controlled server.

---

## 3. On-Chain Data (Public by Design)

When you interact with OpenAccord smart contracts, the following data becomes
permanently public on the relevant blockchain:

- Your wallet address (public by nature of blockchain)
- Intent content you publish (schema, payload, state labels, image references)
- Contact information you choose to include in Intent payloads
- Acknowledgement records (your address, intent reference, state data)
- OutcomeRecord data you choose to publish

**This data is irreversible.** Blockchain data cannot be deleted. Before publishing
any information to a smart contract, carefully consider its permanent public nature.

**Recommendations:**
- Use pseudonymous identifiers (Telegram username, ENS name, Nostr key) rather than email or phone
- Do not include physical addresses in publicly visible Intent payloads
- Do not include sensitive personal information (government ID, financial details)

---

## 4. Third-Party Services

Users may choose to:
- Use third-party RPC providers (Infura, Alchemy, QuickNode, etc.) — these providers have their own privacy policies
- Use IPFS or Arweave for image storage — these are public decentralized networks
- Use third-party wallets (MetaMask, Phantom, Sui Wallet, etc.) — these have their own privacy policies
- Reference third-party escrow services — these are independent of OpenAccord

OpenAccord is not responsible for the data practices of third-party services.

---

## 5. Developer Contributions

If the optional developer contribution is enabled in the GUI and you submit a transaction,
your wallet address will appear in the blockchain transaction record alongside the contribution
amount. This is inherent to blockchain transactions and is not specific to OpenAccord.

---

## 6. Contact

There is no centralized OpenAccord organization. For privacy questions, open an issue
in the public repository at github.com/openaccord (placeholder — replace with actual repo).

---

*This privacy notice is a best-effort description of the protocol's data practices.*
*OpenAccord is open-source. Audit the code yourself.*
