# OpenAccord — Terms of Use

**Version 1.1 | Effective: May 1, 2026**

---

## 1. Agreement

By downloading, running, or interacting with OpenAccord software or smart contracts,
you ("User") agree to these Terms of Use. If you do not agree, do not use this software.

---

## 2. What OpenAccord Provides

OpenAccord provides neutral, open-source infrastructure for publishing and recording data.

**a) Open-source smart contracts** deployable on supported blockchains. These contracts
allow users to publish arbitrary data records ("Intents"), submit non-binding
acknowledgements ("Acknowledgements"), and record self-reported outcomes ("OutcomeRecords").
The contracts are **schema-blind** and store arbitrary bytes provided by the User without validation.

**b) Open-source local software** — a desktop application, mobile application, transaction
constructor, and blockchain indexer — that helps users interact with smart contracts.
All software runs locally on the User's device. No data is sent to any central server.
The software includes a "Schema Library" to interpret on-chain data, but this interpretation
is local and client-side only.

**c) Schema definitions** — Reference JSON files describing how Intent and Acknowledgement
payloads may be structured and rendered. These are suggestions for the local GUI to interpret data.
The protocol does not enforce, validate, or execute any schema logic.

**d) Generalized Infrastructure.** OpenAccord is a base protocol. It is not a specific application
but a framework upon which various applications (marketplaces, messaging tools, coordinators)
can be built by Users and third-party developers.

---

## 3. What OpenAccord Does Not Provide

OpenAccord does **not** provide:

-   **Matching or Discovery:** No algorithmic or manual matching of Intents to Acknowledgements.
-   **Execution:** No transaction execution, asset transfer, or swap facilitation.
-   **Intermediation:** No brokerage, escrow, or custody of funds or assets.
-   **Verification:** No verification of the truthfulness, accuracy, or legality of any payload data
    (including cross-chain references, lock proofs, or identity claims).
-   **Messaging Services:** No hosted messaging infrastructure. While payloads may contain
    encrypted data simulating chat applications, the protocol only stores this data; it does not
    route, encrypt, or decrypt messages.
-   **Financial Services:** No investment advice, trading execution, or money transmission.
-   **Compliance:** No Anti-Money Laundering (AML) or Know Your Customer (KYC) verification.
-   **Dispute Resolution:** No arbitration or enforcement mechanisms for agreements.
-   **Customer Support:** No mediation service for disputes between Users.

---

## 4. User-Defined Logic & Payloads

Users acknowledge that the OpenAccord protocol is designed to support arbitrary, user-defined logic via the `payload` field.

**a) Simulation vs. Reality:** Schemas may define workflows that *simulate* functionality such as
encrypted messaging, escrow locking, or milestone tracking. Users acknowledge that these are
**data representations only**. The OpenAccord protocol does not execute, enforce, or verify
any logic defined within user-submitted payloads or schemas.

**b) Schema-Bound Acknowledgements:** Users may request specific Acknowledgement schemas
(e.g., "Proof of Lock" or "Signed Message"). The submission of such an Acknowledgement is a
declarative data entry. It does not constitute a verified fact or legally binding agreement
unless explicitly agreed upon by the parties involved outside of the protocol.

**c) Cross-Chain References:** Payloads may reference data on other blockchains (e.g.,
transaction hashes, vault addresses). The protocol does not verify the existence, validity,
or finality of these external references. Users are solely responsible for verifying cross-chain data.

---

## 5. User Conduct

Users agree to:

**a)** Use OpenAccord in compliance with all applicable laws in their jurisdiction, including
but not limited to tax, securities, sanctions, and financial regulations.

**b)** **Content Responsibility:** Users are solely responsible for all content they publish,
including text, images (via IPFS/Arweave/HTTPS references), and structured data.
Users must ensure that published content:
-   Is lawful and does not facilitate fraud, money laundering, terrorist financing, or sanctions evasion.
-   Does not infringe on third-party intellectual property rights.
-   Does not contain illegal content, including but not limited to child exploitation material
    or non-consensual intimate imagery.
-   Does not contain personal data of third parties without their consent.

**c)** **Privacy of Contact Data:** Users acknowledge that entering contact information
(even in encrypted or hashed forms) into a public blockchain is irreversible. Users are
strongly advised to use pseudonymous identifiers (e.g., Telegram handles, Nostr keys)
rather than personal email addresses or phone numbers.

**d)** Accept sole responsibility for all interactions with counterparties, including
negotiation, payment, and delivery.

**e)** Not attempt to exploit, attack, disrupt, or spam the smart contracts or software.

---

## 6. Risk Acknowledgment

Users acknowledge significant risks inherent to this software:

**a) Software Risk:** Smart contracts are experimental, unaudited software. Bugs may result in
the loss of funds or data corruption. Use at your own risk.

**b) Data Permanence:** All data published to OpenAccord smart contracts is permanent and public.
There is no "delete" function. Users cannot revoke data once it is on-chain.

**c) Counterparty Risk:** Counterparties may be fraudulent, unreliable, or act in bad faith.
The protocol provides no guarantee of performance or recourse for scams.

**d) Payment Risk:** Off-chain payment methods (bank transfer, PayPal, cash) carry chargeback,
reversal, and theft risks. The protocol cannot reverse fiat or crypto transfers.

**e) Schema Interpretation Risk:** The local GUI interprets data based on local schema files.
A malicious or buggy schema could display data incorrectly (e.g., showing a "Lock Proof" as valid
when it is not). Users must verify critical data via the raw on-chain state or a trusted block explorer.

**f) Encryption Risk:** If Users utilize schemas for encrypted messaging, they are solely
responsible for the management of their private keys. Lost keys result in permanently unreadable data.
The protocol does not assist in key recovery.

**g) Regulatory Risk:** The legality of using OpenAccord may vary by jurisdiction.
Users are responsible for their own compliance.

---

## 7. No Warranties; Limitation of Liability

THE SOFTWARE AND PROTOCOL ARE PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, ACCURACY, RELIABILITY, OR NON-INFRINGEMENT.

TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE CONTRIBUTORS, DEVELOPERS, AND DISTRIBUTORS OF
OPENACCORD SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL,
OR PUNITIVE DAMAGES ARISING FROM USE OF THE SOFTWARE OR PROTOCOL.

See `DISCLAIMER.md` for full warranty disclaimers and liability limitations, incorporated here by reference.

---

## 8. Open-Source License

The OpenAccord codebase is released under the MIT License. Users may fork, modify,
and redistribute the code freely subject to the MIT License terms. Forked versions
are not affiliated with openaccord.xyz unless explicitly authorized.

---

## 9. Changes

These terms may be updated. Continued use of the software after updates constitutes
acceptance of revised terms. The current version is always available at
openaccord.xyz and in the repository.

---

## 10. Governing Law

These terms are provided for informational purposes and do not create a contract
between the User and any identifiable legal entity. No central organization
operates or controls this protocol.

---

*OpenAccord is open-source software. These terms are community-maintained.*
