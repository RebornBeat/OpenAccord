# OpenAccord Protocol — Disclaimer and Legal Notice

**Version 1.0 | Effective: May 1, 2026**

---

## 1. Nature of the Protocol

OpenAccord is a neutral, open-source software framework that enables users to publish
arbitrary user-defined data entries ("Intents") and optionally record self-reported
outcomes of independent interactions ("OutcomeRecords") on blockchain networks.

**OpenAccord does not:**

- Custody, hold, control, or transfer any user funds or assets
- Execute, facilitate, intermediate, or guarantee any transaction
- Match, introduce, or recommend counterparties to one another
- Provide exchange, brokerage, payment processing, money transmission, or marketplace services
- Participate as a counterparty in any agreement between users
- Collect, process, or verify user identity information
- Operate a central server, database, or hosted platform

**OpenAccord does:**

- Provide open-source smart contract code deployable by any party
- Provide open-source local software (indexer, GUI, transaction constructor) runnable by any party
- Publish schema definitions as reference data

---

## 2. No Financial Services

The OpenAccord protocol and all associated software tools do not constitute:

- A money transmitter or money services business under U.S. law (Bank Secrecy Act)
- A broker-dealer, exchange, or alternative trading system under the Securities Exchange Act
- A commodity trading platform under the Commodity Exchange Act
- A Virtual Asset Service Provider (VASP) under MiCA, AMLD5/AMLD6, or FATF guidelines
- A payment service provider under PSD2 or equivalent
- A financial institution under any applicable law

---

## 3. User Responsibilities

**By using OpenAccord, users acknowledge and accept sole responsibility for:**

- Negotiating all agreement terms with counterparties, entirely off-chain
- Executing all value transfers (crypto, fiat, or otherwise) independently
- Selecting, engaging, and trusting any third-party escrow services
- Verifying the identity, reputation, and reliability of counterparties
- Assessing all risks including counterparty risk, payment reversal risk, smart contract risk, and regulatory risk
- Complying with all applicable local, national, and international laws, including:
  - Tax obligations and reporting
  - Anti-money laundering (AML) requirements
  - Know-your-customer (KYC) requirements, where applicable
  - Sanctions compliance
  - Securities regulations
  - Import/export regulations

---

## 4. No Warranties

The OpenAccord smart contracts, software tools, and associated documentation are provided
**"AS IS"** and **"AS AVAILABLE"** without warranty of any kind, express or implied, including
but not limited to warranties of merchantability, fitness for a particular purpose, accuracy,
reliability, or non-infringement.

Smart contracts have known and unknown risks including but not limited to:
- Bugs and vulnerabilities in code
- Exploits by malicious actors
- Changes in underlying blockchain protocol behavior
- Loss of funds due to user error

**No professional audit has yet been completed.** Do not use with funds you cannot afford to lose.

---

## 5. Data Published On-Chain

**All data published to smart contracts via OpenAccord is permanently public and immutable.**

Users who publish contact information, images, or any personal data to smart contracts do so
voluntarily and irrevocably. The protocol cannot delete on-chain data. Users are solely
responsible for assessing the privacy implications of publishing any information.

The local software GUI warns users before publishing contact data. Users are advised to use
pseudonymous identifiers (usernames, ENS names, Nostr keys) rather than personally
identifying information.

---

## 6. OutcomeRecords

OutcomeRecords are self-reported by individual users and are not verified, authenticated,
or endorsed by the protocol or its contributors. They may be false, misleading, or incomplete.
Users should not rely on OutcomeRecords or any activity signals derived from them as
authoritative representations of any party's trustworthiness.

---

## 7. Third-Party Escrow

The protocol supports references to third-party escrow services in schema data fields.
OpenAccord does not register, vet, endorse, or recommend any escrow service. References
to escrow services are user-defined data only. Users engage with third-party escrow services
at their own risk.

---

## 8. Limitation of Liability

To the maximum extent permitted by applicable law, the contributors, developers, and
distributors of OpenAccord shall not be liable for any direct, indirect, incidental, special,
consequential, or punitive damages arising from:

- Use or inability to use the protocol or software
- Loss of funds or assets
- Counterparty fraud or non-performance
- Smart contract bugs or exploits
- Regulatory actions

---

## 9. Regulatory Risk

Cryptocurrency and blockchain regulation is evolving rapidly. The legality of using
OpenAccord may vary by jurisdiction and may change over time. Users are solely responsible
for determining whether their use of the protocol is lawful in their jurisdiction.

---

## 10. No Legal Advice

This document does not constitute legal advice. Users should consult qualified legal counsel
in their jurisdiction before using this protocol for significant transactions.

---

## 11. Optional Developer Contributions

The official open-source GUI includes an optional developer contribution mechanism
(default: enabled, amount configurable, removable in Settings). This contribution:

- Is entirely voluntary
- Does not affect protocol functionality
- Is not required to use any feature
- Can be disabled at any time in the application Settings
- Is not a trading fee, commission, or protocol tax

Contributions support ongoing open-source software development, security audits, and
new chain integrations.

---

*This disclaimer is provided for informational purposes. It does not create legal rights
or obligations. The OpenAccord codebase is MIT licensed.*
