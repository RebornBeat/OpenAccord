# OpenAccord Schema Library

Schemas define how Intent payloads are structured and rendered in the local GUI.

## How Schemas Work

1. The smart contract is completely schema-blind. It stores `schema_ref` (a string) and `payload` (arbitrary bytes).
2. The GUI reads the `schema_ref` from an on-chain Intent.
3. It looks up the matching `.json` file from this directory.
4. It renders a structured form based on the schema definition.
5. Unknown schemas fall back to a raw JSON viewer.

## Schema File Format

Each schema file defines:
- `id` — Matches the `schema_ref` string stored on-chain
- `version` — Semver string
- `label` — Human-readable name
- `description` — What this schema is for
- `category` — UI grouping ("services", "goods", "financial", "identity", "other")
- `fields` — Array of field definitions

## Field Types
- `text` — Short single-line string
- `textarea` — Multi-line string
- `number` — Numeric value
- `select` — Dropdown (provide `options` array)
- `multiselect` — Multiple choice
- `url` — URL validation
- `address` — Blockchain address
- `timestamp` — Date/time picker
- `boolean` — Toggle
- `image_refs` — Image reference input (IPFS/Arweave/HTTPS)
- `contact` — Contact method selector (type + value pair)
- `tags` — Free-form tag array

## Contributing Schemas

1. Create a new `.json` file following the format below
2. Use a unique `id` in the format `descriptive_name_v1`
3. Submit a PR to this repository

All schemas are opt-in. Users can always define custom schemas without submitting here.
