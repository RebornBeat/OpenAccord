/// OpenAccord Protocol — Sui Move Contract
///
/// A neutral, schema-blind intent publication and outcome recording protocol.
/// The contract stores arbitrary user-defined data. It enforces no economic
/// structure, performs no matching, and intermediates no transactions.
///
/// All fields are user-defined. The protocol is permissionless.
/// Dev contributions are strictly optional (contract accepts zero-value coins).
module openaccord::intent {

    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::event;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::clock::{Self, Clock};
    use std::string::{Self, String};
    use std::option::{Self, Option};
    use std::vector;

    // =========================================================================
    // Error Codes
    // =========================================================================

    /// Caller is not the creator of this object
    const E_NOT_CREATOR: u64 = 0;
    /// The intent is not in active status
    const E_INTENT_NOT_ACTIVE: u64 = 1;
    /// Invalid state transition
    const E_INVALID_STATE: u64 = 2;
    /// Acknowledgement does not belong to this intent
    const E_ACK_MISMATCH: u64 = 3;
    /// Dev fee coin must have value >= 0 (always true, guard for zero destroy)
    const E_INVALID_FEE: u64 = 4;

    // =========================================================================
    // Status Constants
    // =========================================================================

    const STATUS_ACTIVE: u8 = 0;
    const STATUS_PAUSED: u8 = 1;
    const STATUS_SETTLED: u8 = 2;
    const STATUS_CANCELLED: u8 = 3;

    // =========================================================================
    // Structs
    // =========================================================================

    /// One-time admin capability minted at init.
    /// Controls dev address updates only.
    struct AdminCap has key, store {
        id: UID,
    }

    /// Global shared configuration.
    /// Tracks dev address for optional contributions and aggregate stats.
    struct Config has key {
        id: UID,
        dev_address: address,
        total_intents: u64,
        total_outcomes: u64,
        total_acknowledgements: u64,
    }

    /// The core protocol object. Schema-blind: stores schema_ref (string identifier)
    /// and payload (arbitrary bytes — typically JSON encoded by the GUI).
    ///
    /// LEGAL NOTE: This struct enforces no economic structure. All data is
    /// user-provided and may represent any type of agreement or intent.
    struct Intent has key, store {
        id: UID,
        creator: address,
        /// Schema identifier string. e.g., "service_agreement_v1", "goods_listing_v1".
        /// The contract does not interpret this value. The local GUI uses it to
        /// select a rendering schema from the local schema library.
        schema_ref: String,
        /// Arbitrary payload bytes. Typically JSON encoded by the GUI.
        /// Not validated or interpreted by the contract.
        payload: vector<u8>,
        /// User-defined free-form state label. Not enforced by the protocol.
        /// Examples: "open", "in_progress", "awaiting_payment", "completed"
        state_label: String,
        /// 0=Active, 1=Paused, 2=Settled, 3=Cancelled
        status: u8,
        /// Unix timestamp (ms) of creation
        created_at: u64,
        /// Unix timestamp (ms) of last update
        updated_at: u64,
        /// Optional expiry timestamp (ms). Not enforced on-chain — indexer handles filtering.
        expires_at: Option<u64>,
        /// IPFS, Arweave, or HTTPS image/media references.
        /// Format: ["ipfs://QmXxx", "ar://xxxTx", "https://example.com/img.jpg"]
        /// Never hosted by OpenAccord. Resolved locally by the GUI.
        image_refs: vector<String>,
        /// Contact method type: "telegram", "signal", "nostr", "lens", "email", "xmtp", ""
        contact_method_type: String,
        /// Contact method value: "@username", "npub1...", "alice.eth", ""
        /// IMPORTANT: Users are responsible for their own privacy. The GUI
        /// warns users that this data is permanently public on-chain.
        contact_method_value: String,
    }

    /// A non-binding signal that an address has interacted with an Intent.
    ///
    /// LEGAL NOTE: An Acknowledgement does not represent acceptance, commitment,
    /// execution, or agreement to any terms. It is a declarative data record only.
    struct Acknowledgement has key, store {
        id: UID,
        /// The Intent this acknowledgement references
        intent_id: ID,
        /// The address that submitted this acknowledgement
        acknowledger: address,
        /// Arbitrary optional data (JSON bytes). May be empty.
        note_payload: vector<u8>,
        /// User-defined state label for this acknowledgement.
        /// Examples: "interested", "pending", "delivered", "completed"
        state_label: String,
        created_at: u64,
        updated_at: u64,
    }

    /// A self-reported, non-authoritative record of an outcome.
    ///
    /// LEGAL NOTE: OutcomeRecords are self-reported by users and are not
    /// verified, enforced, or guaranteed by the protocol. They serve only
    /// as voluntary public activity signals.
    struct OutcomeRecord has key, store {
        id: UID,
        intent_id: ID,
        acknowledgement_id: Option<ID>,
        /// Address that recorded this outcome (any party — maker or taker)
        recorder: address,
        /// Arbitrary outcome data (JSON bytes). Self-reported.
        outcome_payload: vector<u8>,
        recorded_at: u64,
    }

    // =========================================================================
    // Events (consumed by local indexers)
    // =========================================================================

    struct IntentPublished has copy, drop {
        intent_id: ID,
        creator: address,
        schema_ref: String,
        created_at: u64,
    }

    struct IntentUpdated has copy, drop {
        intent_id: ID,
        creator: address,
        new_status: u8,
        state_label: String,
        updated_at: u64,
    }

    struct IntentCancelled has copy, drop {
        intent_id: ID,
        cancelled_by: address,
        cancelled_at: u64,
    }

    struct AcknowledgementSubmitted has copy, drop {
        acknowledgement_id: ID,
        intent_id: ID,
        acknowledger: address,
        created_at: u64,
    }

    struct StateAdvanced has copy, drop {
        acknowledgement_id: ID,
        intent_id: ID,
        advancer: address,
        new_state_label: String,
        updated_at: u64,
    }

    struct AcknowledgementCancelled has copy, drop {
        acknowledgement_id: ID,
        cancelled_by: address,
        cancelled_at: u64,
    }

    struct OutcomeRecorded has copy, drop {
        outcome_id: ID,
        intent_id: ID,
        acknowledgement_id: Option<ID>,
        recorder: address,
        recorded_at: u64,
    }

    struct DevAddressUpdated has copy, drop {
        old_address: address,
        new_address: address,
    }

    // =========================================================================
    // Initialization
    // =========================================================================

    fun init(ctx: &mut TxContext) {
        let deployer = tx_context::sender(ctx);

        let admin_cap = AdminCap {
            id: object::new(ctx),
        };

        let config = Config {
            id: object::new(ctx),
            dev_address: deployer,
            total_intents: 0,
            total_outcomes: 0,
            total_acknowledgements: 0,
        };

        transfer::transfer(admin_cap, deployer);
        transfer::share_object(config);
    }

    // =========================================================================
    // Public Entry Functions
    // =========================================================================

    /// Publish a new Intent.
    ///
    /// The `dev_fee` coin is optional — pass a zero-value SUI coin to contribute
    /// nothing. The contract always accepts zero-fee transactions. This is
    /// intentional: the protocol is permissionless.
    ///
    /// Parameters:
    ///   config          — Global shared Config object
    ///   clock           — Sui Clock object (object ID 0x6)
    ///   schema_ref      — Schema identifier string bytes (e.g., b"service_agreement_v1")
    ///   payload         — Arbitrary data bytes (JSON encoded by GUI)
    ///   state_label     — Initial user-defined state (e.g., b"open")
    ///   expires_at_ms   — Optional expiry timestamp in ms. Pass 0 for no expiry.
    ///   image_refs_csv  — Comma-separated image reference URLs. Pass empty for none.
    ///   contact_type    — Contact method type bytes (e.g., b"telegram"). Pass empty for none.
    ///   contact_value   — Contact method value bytes (e.g., b"@username"). Pass empty for none.
    ///   dev_fee         — Optional SUI contribution coin (may be zero value)
    public entry fun publish_intent(
        config: &mut Config,
        clock: &Clock,
        schema_ref: vector<u8>,
        payload: vector<u8>,
        state_label: vector<u8>,
        expires_at_ms: u64,
        image_refs_csv: vector<u8>,
        contact_type: vector<u8>,
        contact_value: vector<u8>,
        dev_fee: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        // Route optional dev contribution
        let fee_value = coin::value(&dev_fee);
        if (fee_value > 0) {
            transfer::public_transfer(dev_fee, config.dev_address);
        } else {
            coin::destroy_zero(dev_fee);
        };

        let now = clock::timestamp_ms(clock);

        // Parse image refs: comma-separated string -> vector<String>
        let image_refs = parse_csv_to_string_vec(image_refs_csv);

        // Build optional expires_at (0 = no expiry)
        let expires_at = if (expires_at_ms > 0) {
            option::some(expires_at_ms)
        } else {
            option::none()
        };

        let intent = Intent {
            id: object::new(ctx),
            creator: tx_context::sender(ctx),
            schema_ref: string::utf8(schema_ref),
            payload,
            state_label: string::utf8(state_label),
            status: STATUS_ACTIVE,
            created_at: now,
            updated_at: now,
            expires_at,
            image_refs,
            contact_method_type: string::utf8(contact_type),
            contact_method_value: string::utf8(contact_value),
        };

        let intent_id = object::id(&intent);
        config.total_intents = config.total_intents + 1;

        event::emit(IntentPublished {
            intent_id,
            creator: tx_context::sender(ctx),
            schema_ref: intent.schema_ref,
            created_at: now,
        });

        // Share intent so any address can read/acknowledge it
        transfer::share_object(intent);
    }

    /// Update an existing Intent. Only callable by creator.
    ///
    /// Pass empty vectors/zero for fields you do not wish to update.
    /// Empty `new_payload` (length 0) = skip payload update.
    /// Empty `new_state_label` (length 0) = skip state label update.
    /// `new_status = 255` = skip status update (use 0-3 for real values).
    /// `new_expires_at_ms = 0` = skip expiry update; `1` = clear expiry.
    public entry fun update_intent(
        intent: &mut Intent,
        clock: &Clock,
        new_payload: vector<u8>,
        new_state_label: vector<u8>,
        new_status: u8,
        new_expires_at_ms: u64,
        new_image_refs_csv: vector<u8>,
        ctx: &mut TxContext,
    ) {
        assert!(intent.creator == tx_context::sender(ctx), E_NOT_CREATOR);
        assert!(intent.status != STATUS_CANCELLED, E_INTENT_NOT_ACTIVE);

        let now = clock::timestamp_ms(clock);

        if (vector::length(&new_payload) > 0) {
            intent.payload = new_payload;
        };

        if (vector::length(&new_state_label) > 0) {
            intent.state_label = string::utf8(new_state_label);
        };

        // 0-3 are valid statuses; 255 = no-op sentinel
        if (new_status != 255u8) {
            intent.status = new_status;
        };

        // 0 = skip, 1 = clear, >1 = set new value
        if (new_expires_at_ms == 1) {
            intent.expires_at = option::none();
        } else if (new_expires_at_ms > 1) {
            intent.expires_at = option::some(new_expires_at_ms);
        };

        if (vector::length(&new_image_refs_csv) > 0) {
            intent.image_refs = parse_csv_to_string_vec(new_image_refs_csv);
        };

        intent.updated_at = now;

        event::emit(IntentUpdated {
            intent_id: object::id(intent),
            creator: intent.creator,
            new_status: intent.status,
            state_label: intent.state_label,
            updated_at: now,
        });
    }

    /// Cancel an Intent. Only callable by creator. Irreversible.
    public entry fun cancel_intent(
        intent: &mut Intent,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        assert!(intent.creator == tx_context::sender(ctx), E_NOT_CREATOR);
        assert!(intent.status != STATUS_CANCELLED, E_INTENT_NOT_ACTIVE);

        let now = clock::timestamp_ms(clock);
        intent.status = STATUS_CANCELLED;
        intent.updated_at = now;

        event::emit(IntentCancelled {
            intent_id: object::id(intent),
            cancelled_by: intent.creator,
            cancelled_at: now,
        });
    }

    /// Submit a non-binding Acknowledgement for an Intent.
    ///
    /// IMPORTANT: This does not represent acceptance or commitment to any terms.
    /// It is a declarative signal only. The acknowledger retains full autonomy.
    ///
    /// Any address may acknowledge any active Intent.
    /// The note_payload is arbitrary (may be empty).
    public entry fun acknowledge_intent(
        config: &mut Config,
        intent: &Intent,
        clock: &Clock,
        note_payload: vector<u8>,
        state_label: vector<u8>,
        ctx: &mut TxContext,
    ) {
        assert!(intent.status == STATUS_ACTIVE, E_INTENT_NOT_ACTIVE);

        let now = clock::timestamp_ms(clock);
        let intent_id = object::id(intent);

        let ack = Acknowledgement {
            id: object::new(ctx),
            intent_id,
            acknowledger: tx_context::sender(ctx),
            note_payload,
            state_label: string::utf8(state_label),
            created_at: now,
            updated_at: now,
        };

        let ack_id = object::id(&ack);
        config.total_acknowledgements = config.total_acknowledgements + 1;

        event::emit(AcknowledgementSubmitted {
            acknowledgement_id: ack_id,
            intent_id,
            acknowledger: tx_context::sender(ctx),
            created_at: now,
        });

        // Share so both parties and indexers can read
        transfer::share_object(ack);
    }

    /// Advance the state label of an Acknowledgement. Callable by the acknowledger.
    ///
    /// State transitions are user-defined and not enforced by the protocol.
    public entry fun advance_state_acknowledger(
        ack: &mut Acknowledgement,
        clock: &Clock,
        new_state_label: vector<u8>,
        ctx: &mut TxContext,
    ) {
        assert!(ack.acknowledger == tx_context::sender(ctx), E_NOT_CREATOR);

        let now = clock::timestamp_ms(clock);
        ack.state_label = string::utf8(new_state_label);
        ack.updated_at = now;

        event::emit(StateAdvanced {
            acknowledgement_id: object::id(ack),
            intent_id: ack.intent_id,
            advancer: tx_context::sender(ctx),
            new_state_label: ack.state_label,
            updated_at: now,
        });
    }

    /// Advance the state label of an Acknowledgement. Callable by the Intent creator.
    ///
    /// Requires passing the Intent object to verify creator identity and
    /// that the acknowledgement belongs to this intent.
    public entry fun advance_state_creator(
        intent: &Intent,
        ack: &mut Acknowledgement,
        clock: &Clock,
        new_state_label: vector<u8>,
        ctx: &mut TxContext,
    ) {
        assert!(intent.creator == tx_context::sender(ctx), E_NOT_CREATOR);
        assert!(ack.intent_id == object::id(intent), E_ACK_MISMATCH);

        let now = clock::timestamp_ms(clock);
        ack.state_label = string::utf8(new_state_label);
        ack.updated_at = now;

        event::emit(StateAdvanced {
            acknowledgement_id: object::id(ack),
            intent_id: ack.intent_id,
            advancer: tx_context::sender(ctx),
            new_state_label: ack.state_label,
            updated_at: now,
        });
    }

    /// Cancel an Acknowledgement. Callable by the acknowledger only.
    public entry fun cancel_acknowledgement(
        ack: &mut Acknowledgement,
        clock: &Clock,
        ctx: &mut TxContext,
    ) {
        assert!(ack.acknowledger == tx_context::sender(ctx), E_NOT_CREATOR);

        let now = clock::timestamp_ms(clock);
        ack.state_label = string::utf8(b"cancelled");
        ack.updated_at = now;

        event::emit(AcknowledgementCancelled {
            acknowledgement_id: object::id(ack),
            cancelled_by: ack.acknowledger,
            cancelled_at: now,
        });
    }

    /// Record a self-reported Outcome.
    ///
    /// Any party (maker or taker) may call this independently.
    /// LEGAL NOTE: OutcomeRecords are user-generated, self-reported, and not
    /// verified by the protocol. The protocol makes no warranty about accuracy.
    ///
    /// Pass a zero-value SUI coin for dev_fee to contribute nothing.
    public entry fun record_outcome(
        config: &mut Config,
        clock: &Clock,
        intent_id: ID,
        acknowledgement_id: vector<u8>,
        outcome_payload: vector<u8>,
        dev_fee: Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        // Route optional dev contribution
        let fee_value = coin::value(&dev_fee);
        if (fee_value > 0) {
            transfer::public_transfer(dev_fee, config.dev_address);
        } else {
            coin::destroy_zero(dev_fee);
        };

        let now = clock::timestamp_ms(clock);

        // Parse optional acknowledgement_id from bytes
        let ack_id_opt = if (vector::length(&acknowledgement_id) > 0) {
            option::some(object::id_from_bytes(acknowledgement_id))
        } else {
            option::none()
        };

        let outcome = OutcomeRecord {
            id: object::new(ctx),
            intent_id,
            acknowledgement_id: ack_id_opt,
            recorder: tx_context::sender(ctx),
            outcome_payload,
            recorded_at: now,
        };

        let outcome_id = object::id(&outcome);
        config.total_outcomes = config.total_outcomes + 1;

        event::emit(OutcomeRecorded {
            outcome_id,
            intent_id,
            acknowledgement_id: outcome.acknowledgement_id,
            recorder: tx_context::sender(ctx),
            recorded_at: now,
        });

        transfer::share_object(outcome);
    }

    // =========================================================================
    // Admin Functions
    // =========================================================================

    /// Update the dev contribution recipient address.
    /// Requires AdminCap — only the deployer or whoever holds AdminCap can call this.
    public entry fun update_dev_address(
        _cap: &AdminCap,
        config: &mut Config,
        new_dev_address: address,
    ) {
        let old = config.dev_address;
        config.dev_address = new_dev_address;
        event::emit(DevAddressUpdated {
            old_address: old,
            new_address: new_dev_address,
        });
    }

    // =========================================================================
    // View Functions (read-only, no gas for off-chain calls)
    // =========================================================================

    public fun intent_creator(intent: &Intent): address { intent.creator }
    public fun intent_schema_ref(intent: &Intent): &String { &intent.schema_ref }
    public fun intent_state_label(intent: &Intent): &String { &intent.state_label }
    public fun intent_status(intent: &Intent): u8 { intent.status }
    public fun intent_created_at(intent: &Intent): u64 { intent.created_at }
    public fun intent_updated_at(intent: &Intent): u64 { intent.updated_at }
    public fun intent_expires_at(intent: &Intent): &Option<u64> { &intent.expires_at }
    public fun intent_image_refs(intent: &Intent): &vector<String> { &intent.image_refs }
    public fun intent_contact_type(intent: &Intent): &String { &intent.contact_method_type }
    public fun intent_contact_value(intent: &Intent): &String { &intent.contact_method_value }
    public fun intent_is_active(intent: &Intent): bool { intent.status == STATUS_ACTIVE }

    public fun ack_intent_id(ack: &Acknowledgement): ID { ack.intent_id }
    public fun ack_acknowledger(ack: &Acknowledgement): address { ack.acknowledger }
    public fun ack_state_label(ack: &Acknowledgement): &String { &ack.state_label }

    public fun outcome_intent_id(outcome: &OutcomeRecord): ID { outcome.intent_id }
    public fun outcome_recorder(outcome: &OutcomeRecord): address { outcome.recorder }
    public fun outcome_recorded_at(outcome: &OutcomeRecord): u64 { outcome.recorded_at }

    public fun config_stats(config: &Config): (u64, u64, u64) {
        (config.total_intents, config.total_outcomes, config.total_acknowledgements)
    }

    public fun config_dev_address(config: &Config): address { config.dev_address }

    // =========================================================================
    // Helper Functions
    // =========================================================================

    /// Parse a comma-separated byte vector into a vector of String.
    /// e.g., b"ipfs://Qmx,ar://abc,https://example.com" -> [String, String, String]
    fun parse_csv_to_string_vec(csv: vector<u8>): vector<String> {
        let result = vector::empty<String>();
        if (vector::length(&csv) == 0) {
            return result
        };

        let current = vector::empty<u8>();
        let i = 0;
        let len = vector::length(&csv);

        while (i < len) {
            let byte = *vector::borrow(&csv, i);
            if (byte == 44u8) { // ASCII comma
                if (vector::length(&current) > 0) {
                    vector::push_back(&mut result, string::utf8(current));
                    current = vector::empty<u8>();
                };
            } else {
                vector::push_back(&mut current, byte);
            };
            i = i + 1;
        };

        // Push last segment
        if (vector::length(&current) > 0) {
            vector::push_back(&mut result, string::utf8(current));
        };

        result
    }

    // =========================================================================
    // Constants (public for external use)
    // =========================================================================

    public fun status_active(): u8 { STATUS_ACTIVE }
    public fun status_paused(): u8 { STATUS_PAUSED }
    public fun status_settled(): u8 { STATUS_SETTLED }
    public fun status_cancelled(): u8 { STATUS_CANCELLED }
}
