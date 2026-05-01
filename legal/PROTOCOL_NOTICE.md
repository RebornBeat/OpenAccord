# OpenAccord — Protocol Classification Notice

**Version 1.0**

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

**4. Generalized Schema:** The protocol stores arbitrary user-defined data.
It is not structurally limited to financial transactions. Documented use cases
include services, goods, rentals, barter, job postings, and identity records.

**5. No Central Operator:** No hosted service, central database, or aggregation
point is operated by any identifiable entity. The local GUI, indexer, and
transaction constructor run entirely on user devices.

**6. User-Generated Data:** All data published to smart contracts is user-generated,
self-reported, and unverified by the protocol.

**7. Permissionless:** All smart contract functions are callable by any wallet.
No registration, approval, or permission is required.

---

## Regulatory Contact

OpenAccord has no legal entity, registered address, or compliance officer.

The protocol is open-source software maintained by contributors. If a regulatory
authority wishes to discuss the protocol's design or seeks technical clarification,
the appropriate channel is the public GitHub repository.

---

*This notice is informational. It does not constitute legal advice and does not
create legal rights or obligations.*
