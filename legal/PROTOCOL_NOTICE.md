# OpenAccord — Protocol Classification Notice

**Version 1.1 | Updated: May 2026**

---

This notice describes the legal and regulatory nature of the OpenAccord protocol
for the benefit of users, regulators, and legal counsel.

---

## Classification

OpenAccord is a neutral, open-source software protocol for publishing user-defined
data records and self-reporting outcomes of independently conducted interactions.

It is not, and does not operate as:

| Category | Status | Basis |
|---|---|---|
| Money Transmitter (FinCEN/BSA) | Not applicable | No funds accepted, transmitted, or controlled |
| Broker-Dealer (SEC) | Not applicable | No securities traded; no matching; no intermediation |
| Exchange (SEC/CFTC) | Not applicable | No order book; no matching engine; no execution |
| VASP (MiCA/FATF) | Not applicable | No custody; no exchange services |
| Payment Service Provider (PSD2) | Not applicable | No payment rails; no fund handling |
| Alternative Trading System | Not applicable | No trading facilitation; no counterparty discovery |
| Money Service Business | Not applicable | No currency exchange; no fund transmission |
| Communication Service Provider | Not applicable | No message delivery infrastructure; stores static encrypted blobs only |
| Social Media Platform | Not applicable | No content algorithm; no central feed; no content moderation capabilities |

---

## Key Architectural Facts

**1. No Custody:** The protocol's smart contracts contain no functions to receive,
hold, or transfer user funds. No approvals are requested. No token transfers occur
within the protocol layer.

**2. No Matching:** There is no algorithm, service, or mechanism that matches
Intent publishers with Acknowledgement submitters. Counterparties discover each
other through entirely independent means.

**3. No Execution:** No transaction between parties is facilitated, required,
or triggered by the protocol. All value transfers happen independently and
entirely outside the protocol.

**4. Schema-Blind Storage:** The protocol stores arbitrary user-defined data
(`payload` bytes) and a string identifier (`schema_ref`). It is structurally
incapable of validating or enforcing the contents of any payload.
- **Interpretation Layer:** Schemas are JSON files used solely by local client software (GUIs) to interpret data. They are not part of the protocol logic.
- **Simulated Workflows:** While schemas may define complex workflows (e.g., escrow simulation, milestone sign-offs), these are data representations only. The protocol does not execute logic defined in schemas.

**5. Schema-Bound Acknowledgements:** Users may request specific schema formats in their Intent payloads (e.g., "I require an Acknowledgement following the `cross_chain_lock_v1` schema").
- **Legal Effect:** This is a data preference, not a binding contract or protocol-enforced rule. The protocol accepts any Acknowledgement payload regardless of the Intent publisher's preference. Validation is strictly a client-side function.

**6. Cross-Chain Data Referencing:** Payloads may contain references to external data, including transaction hashes on other blockchains.
- **Not a Bridge:** The protocol does not verify, bridge, or interact with external chains. It merely stores the user-provided string (e.g., a TX hash). Cross-chain functionality is a user-side interpretive act, not a protocol feature.

**7. No Central Operator:** No hosted service, central database, or aggregation
point is operated by any identifiable entity. The local GUI, indexer, and
transaction constructor run entirely on user devices. There is no backend server
processing user data.

**8. User-Generated Data:** All data published to smart contracts is user-generated,
self-reported, and unverified by the protocol. The protocol makes no warranty
regarding the accuracy, legality, or truthfulness of any published data.

**9. Permissionless:** All smart contract functions are callable by any wallet.
No registration, approval, or permission is required.

**10. Encrypted Payload Capability:** Users may store encrypted data in the `payload` field.
- **Not a Messaging Service:** The protocol cannot decrypt, route, or moderate this data. It functions as a static data store (similar to a public bulletin board). Any messaging functionality is constructed entirely by the user’s local client software.

---

## Specific Regulatory Clarifications

### Regarding "dApp Layer" Functionality
While specialized GUIs (vertical applications) may use OpenAccord to build interfaces resembling marketplaces (e.g., a "Web3 Upwork"), these are **client-side interpretations** of neutral data.
- The protocol does not differentiate between a "freelance job" and a "barter offer."
- The protocol does not enforce escrow, dispute resolution, or payment release.
- Regulatory obligations arising from these client-side interfaces belong to the operators of those interfaces, not to the OpenAccord protocol.

### Regarding Cross-Chain Coordination
Intents may reference assets or contracts on other chains.
- The protocol stores these references as text strings.
- The protocol has no technical ability to enforce or verify the state of the referenced external asset.
- This is distinct from cross-chain bridging or interoperability protocols which perform verification; OpenAccord performs **logging only**.

---

## Regulatory Contact

OpenAccord has no legal entity, registered address, or compliance officer.

The protocol is open-source software maintained by contributors. If a regulatory
authority wishes to discuss the protocol's design or seeks technical clarification,
the appropriate channel is the public GitHub repository.

---

*This notice is informational. It does not constitute legal advice and does not
create legal rights or obligations.*
