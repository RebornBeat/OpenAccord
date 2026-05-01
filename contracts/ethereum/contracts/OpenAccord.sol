// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title OpenAccord Protocol — Ethereum/EVM Contract
 *
 * @notice A neutral, schema-blind intent publication and outcome recording protocol.
 *
 * LEGAL NOTICE: This contract enforces no economic structure, performs no matching,
 * executes no transactions, and intermediates no agreements. All data is user-provided
 * and self-reported. The protocol does not custody funds, act as a broker, exchange,
 * or money transmitter. Users are solely responsible for all interactions and compliance.
 *
 * Dev contributions are optional. Pass msg.value = 0 to use the protocol at no cost.
 * The contract never rejects transactions for zero contribution.
 */
contract OpenAccord {

    // =========================================================================
    // Errors
    // =========================================================================

    error NotCreator();
    error IntentNotActive();
    error IntentCancelled();
    error AcknowledgementMismatch();
    error InvalidStatus();
    error OnlyAcknowledger();

    // =========================================================================
    // Types
    // =========================================================================

    enum IntentStatus { Active, Paused, Settled, Cancelled }

    struct Intent {
        uint256 intentId;
        address creator;
        string schemaRef;
        bytes payload;
        string stateLabel;
        IntentStatus status;
        uint256 createdAt;
        uint256 updatedAt;
        uint256 expiresAt;       // 0 = no expiry
        string imageRefsCsv;     // Comma-separated IPFS/Arweave/HTTPS refs
        string contactType;      // "telegram", "nostr", "lens", "xmtp", ""
        string contactValue;     // "@username", "npub1...", "alice.eth", ""
    }

    struct Acknowledgement {
        uint256 ackId;
        uint256 intentId;
        address acknowledger;
        bytes notePayload;
        string stateLabel;
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct OutcomeRecord {
        uint256 outcomeId;
        uint256 intentId;
        uint256 ackId;           // 0 = no linked acknowledgement
        address recorder;
        bytes outcomePayload;
        uint256 recordedAt;
    }

    // =========================================================================
    // State
    // =========================================================================

    address public owner;
    address public devAddress;

    uint256 private _nextIntentId;
    uint256 private _nextAckId;
    uint256 private _nextOutcomeId;

    uint256 public totalIntents;
    uint256 public totalAcknowledgements;
    uint256 public totalOutcomes;

    mapping(uint256 => Intent) public intents;
    mapping(uint256 => Acknowledgement) public acknowledgements;
    mapping(uint256 => OutcomeRecord) public outcomes;

    // Index: creator address -> array of intent IDs
    mapping(address => uint256[]) public intentsByCreator;
    // Index: intent ID -> array of ack IDs
    mapping(uint256 => uint256[]) public acksByIntent;
    // Index: address -> array of ack IDs (as acknowledger)
    mapping(address => uint256[]) public acksByAcknowledger;
    // Index: intent ID -> array of outcome IDs
    mapping(uint256 => uint256[]) public outcomesByIntent;
    // Index: address -> array of outcome IDs (as recorder)
    mapping(address => uint256[]) public outcomesByRecorder;

    // =========================================================================
    // Events
    // =========================================================================

    event IntentPublished(
        uint256 indexed intentId,
        address indexed creator,
        string schemaRef,
        uint256 createdAt
    );

    event IntentUpdated(
        uint256 indexed intentId,
        address indexed creator,
        uint8 newStatus,
        string stateLabel,
        uint256 updatedAt
    );

    event IntentCancelledEvent(
        uint256 indexed intentId,
        address indexed cancelledBy,
        uint256 cancelledAt
    );

    event AcknowledgementSubmitted(
        uint256 indexed ackId,
        uint256 indexed intentId,
        address indexed acknowledger,
        uint256 createdAt
    );

    event StateAdvanced(
        uint256 indexed ackId,
        uint256 indexed intentId,
        address indexed advancer,
        string newStateLabel,
        uint256 updatedAt
    );

    event AcknowledgementCancelledEvent(
        uint256 indexed ackId,
        address indexed cancelledBy,
        uint256 cancelledAt
    );

    event OutcomeRecorded(
        uint256 indexed outcomeId,
        uint256 indexed intentId,
        uint256 ackId,
        address indexed recorder,
        uint256 recordedAt
    );

    event DevAddressUpdated(address oldAddress, address newAddress);
    event DevContributionReceived(address sender, uint256 amount);

    // =========================================================================
    // Constructor
    // =========================================================================

    constructor(address _devAddress) {
        owner = msg.sender;
        devAddress = _devAddress;
        _nextIntentId = 1;
        _nextAckId = 1;
        _nextOutcomeId = 1;
    }

    // =========================================================================
    // Modifiers
    // =========================================================================

    modifier onlyOwner() {
        require(msg.sender == owner, "OpenAccord: not owner");
        _;
    }

    // =========================================================================
    // Core Functions
    // =========================================================================

    /**
     * @notice Publish a new Intent.
     *
     * @dev The dev contribution is optional. msg.value may be 0.
     * The contract never reverts due to zero contribution.
     * The payload and schemaRef are stored as-is. The contract does not
     * interpret, validate, or act upon their contents.
     *
     * @param schemaRef     Schema identifier (e.g., "service_agreement_v1")
     * @param payload       Arbitrary encoded data (JSON bytes from GUI)
     * @param stateLabel    Initial user-defined state (e.g., "open")
     * @param expiresAt     Expiry timestamp (seconds). 0 = no expiry.
     * @param imageRefsCsv  Comma-separated image refs (IPFS/Arweave/HTTPS)
     * @param contactType   Contact method type (e.g., "telegram")
     * @param contactValue  Contact method value (e.g., "@username")
     */
    function publishIntent(
        string calldata schemaRef,
        bytes calldata payload,
        string calldata stateLabel,
        uint256 expiresAt,
        string calldata imageRefsCsv,
        string calldata contactType,
        string calldata contactValue
    ) external payable returns (uint256 intentId) {
        // Route optional dev contribution
        if (msg.value > 0) {
            (bool sent,) = devAddress.call{value: msg.value}("");
            require(sent, "OpenAccord: dev fee transfer failed");
            emit DevContributionReceived(msg.sender, msg.value);
        }

        intentId = _nextIntentId++;

        intents[intentId] = Intent({
            intentId:        intentId,
            creator:         msg.sender,
            schemaRef:       schemaRef,
            payload:         payload,
            stateLabel:      stateLabel,
            status:          IntentStatus.Active,
            createdAt:       block.timestamp,
            updatedAt:       block.timestamp,
            expiresAt:       expiresAt,
            imageRefsCsv:    imageRefsCsv,
            contactType:     contactType,
            contactValue:    contactValue
        });

        intentsByCreator[msg.sender].push(intentId);
        totalIntents++;

        emit IntentPublished(intentId, msg.sender, schemaRef, block.timestamp);
    }

    /**
     * @notice Update an existing Intent. Only callable by creator.
     *
     * @param intentId          ID of the intent to update
     * @param newPayload        New payload. Empty bytes = skip update.
     * @param newStateLabel     New state label. Empty string = skip update.
     * @param newStatus         New status (0-3). 255 = skip update.
     * @param newExpiresAt      New expiry. 0 = skip. 1 = clear expiry.
     * @param newImageRefsCsv   New image refs CSV. Empty = skip.
     */
    function updateIntent(
        uint256 intentId,
        bytes calldata newPayload,
        string calldata newStateLabel,
        uint8 newStatus,
        uint256 newExpiresAt,
        string calldata newImageRefsCsv
    ) external {
        Intent storage intent = intents[intentId];

        if (intent.creator != msg.sender) revert NotCreator();
        if (intent.status == IntentStatus.Cancelled) revert IntentCancelled();

        if (newPayload.length > 0) {
            intent.payload = newPayload;
        }

        if (bytes(newStateLabel).length > 0) {
            intent.stateLabel = newStateLabel;
        }

        if (newStatus != 255) {
            if (newStatus > 3) revert InvalidStatus();
            intent.status = IntentStatus(newStatus);
        }

        if (newExpiresAt == 1) {
            intent.expiresAt = 0;   // Clear expiry
        } else if (newExpiresAt > 1) {
            intent.expiresAt = newExpiresAt;
        }

        if (bytes(newImageRefsCsv).length > 0) {
            intent.imageRefsCsv = newImageRefsCsv;
        }

        intent.updatedAt = block.timestamp;

        emit IntentUpdated(
            intentId,
            msg.sender,
            uint8(intent.status),
            intent.stateLabel,
            block.timestamp
        );
    }

    /**
     * @notice Cancel an Intent. Only callable by creator. Irreversible.
     */
    function cancelIntent(uint256 intentId) external {
        Intent storage intent = intents[intentId];
        if (intent.creator != msg.sender) revert NotCreator();
        if (intent.status == IntentStatus.Cancelled) revert IntentCancelled();

        intent.status = IntentStatus.Cancelled;
        intent.updatedAt = block.timestamp;

        emit IntentCancelledEvent(intentId, msg.sender, block.timestamp);
    }

    /**
     * @notice Submit a non-binding Acknowledgement for an Intent.
     *
     * IMPORTANT: This is a declarative signal only. It does not represent
     * acceptance, commitment, or agreement to any terms.
     *
     * @param intentId    ID of the intent to acknowledge
     * @param notePayload Optional arbitrary data (may be empty)
     * @param stateLabel  Initial state label (e.g., "interested")
     */
    function acknowledgeIntent(
        uint256 intentId,
        bytes calldata notePayload,
        string calldata stateLabel
    ) external returns (uint256 ackId) {
        Intent storage intent = intents[intentId];
        if (intent.status != IntentStatus.Active) revert IntentNotActive();

        ackId = _nextAckId++;

        acknowledgements[ackId] = Acknowledgement({
            ackId:        ackId,
            intentId:     intentId,
            acknowledger: msg.sender,
            notePayload:  notePayload,
            stateLabel:   stateLabel,
            createdAt:    block.timestamp,
            updatedAt:    block.timestamp
        });

        acksByIntent[intentId].push(ackId);
        acksByAcknowledger[msg.sender].push(ackId);
        totalAcknowledgements++;

        emit AcknowledgementSubmitted(ackId, intentId, msg.sender, block.timestamp);
    }

    /**
     * @notice Advance the state label of an Acknowledgement.
     * Callable by the acknowledger (taker side).
     */
    function advanceStateAcknowledger(
        uint256 ackId,
        string calldata newStateLabel
    ) external {
        Acknowledgement storage ack = acknowledgements[ackId];
        if (ack.acknowledger != msg.sender) revert OnlyAcknowledger();

        ack.stateLabel = newStateLabel;
        ack.updatedAt = block.timestamp;

        emit StateAdvanced(ackId, ack.intentId, msg.sender, newStateLabel, block.timestamp);
    }

    /**
     * @notice Advance the state label of an Acknowledgement.
     * Callable by the Intent creator (maker side).
     * Verifies caller is the intent creator and the ack belongs to this intent.
     */
    function advanceStateCreator(
        uint256 intentId,
        uint256 ackId,
        string calldata newStateLabel
    ) external {
        Intent storage intent = intents[intentId];
        if (intent.creator != msg.sender) revert NotCreator();

        Acknowledgement storage ack = acknowledgements[ackId];
        if (ack.intentId != intentId) revert AcknowledgementMismatch();

        ack.stateLabel = newStateLabel;
        ack.updatedAt = block.timestamp;

        emit StateAdvanced(ackId, intentId, msg.sender, newStateLabel, block.timestamp);
    }

    /**
     * @notice Cancel an Acknowledgement. Only callable by the acknowledger.
     */
    function cancelAcknowledgement(uint256 ackId) external {
        Acknowledgement storage ack = acknowledgements[ackId];
        if (ack.acknowledger != msg.sender) revert OnlyAcknowledger();

        ack.stateLabel = "cancelled";
        ack.updatedAt = block.timestamp;

        emit AcknowledgementCancelledEvent(ackId, msg.sender, block.timestamp);
    }

    /**
     * @notice Record a self-reported Outcome.
     *
     * Any party may call this independently.
     * LEGAL NOTE: Outcomes are user-generated and self-reported.
     * The protocol makes no warranty about accuracy or completeness.
     *
     * @param intentId       ID of the related intent
     * @param linkedAckId    ID of linked acknowledgement. 0 = none.
     * @param outcomePayload Arbitrary outcome data (JSON bytes)
     */
    function recordOutcome(
        uint256 intentId,
        uint256 linkedAckId,
        bytes calldata outcomePayload
    ) external payable returns (uint256 outcomeId) {
        // Route optional dev contribution
        if (msg.value > 0) {
            (bool sent,) = devAddress.call{value: msg.value}("");
            require(sent, "OpenAccord: dev fee transfer failed");
            emit DevContributionReceived(msg.sender, msg.value);
        }

        outcomeId = _nextOutcomeId++;

        outcomes[outcomeId] = OutcomeRecord({
            outcomeId:      outcomeId,
            intentId:       intentId,
            ackId:          linkedAckId,
            recorder:       msg.sender,
            outcomePayload: outcomePayload,
            recordedAt:     block.timestamp
        });

        outcomesByIntent[intentId].push(outcomeId);
        outcomesByRecorder[msg.sender].push(outcomeId);
        totalOutcomes++;

        emit OutcomeRecorded(outcomeId, intentId, linkedAckId, msg.sender, block.timestamp);
    }

    // =========================================================================
    // Admin Functions
    // =========================================================================

    /**
     * @notice Update the dev contribution recipient address.
     */
    function updateDevAddress(address newDevAddress) external onlyOwner {
        address old = devAddress;
        devAddress = newDevAddress;
        emit DevAddressUpdated(old, newDevAddress);
    }

    /**
     * @notice Transfer ownership.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    // =========================================================================
    // View / Query Functions
    // =========================================================================

    function getIntent(uint256 intentId) external view returns (Intent memory) {
        return intents[intentId];
    }

    function getAcknowledgement(uint256 ackId) external view returns (Acknowledgement memory) {
        return acknowledgements[ackId];
    }

    function getOutcome(uint256 outcomeId) external view returns (OutcomeRecord memory) {
        return outcomes[outcomeId];
    }

    function getIntentsByCreator(address creator) external view returns (uint256[] memory) {
        return intentsByCreator[creator];
    }

    function getAcksByIntent(uint256 intentId) external view returns (uint256[] memory) {
        return acksByIntent[intentId];
    }

    function getAcksByAcknowledger(address acknowledger) external view returns (uint256[] memory) {
        return acksByAcknowledger[acknowledger];
    }

    function getOutcomesByIntent(uint256 intentId) external view returns (uint256[] memory) {
        return outcomesByIntent[intentId];
    }

    function getOutcomesByRecorder(address recorder) external view returns (uint256[] memory) {
        return outcomesByRecorder[recorder];
    }

    function getStats() external view returns (uint256, uint256, uint256) {
        return (totalIntents, totalAcknowledgements, totalOutcomes);
    }

    // Prevent accidental ETH sends outside the designated functions
    receive() external payable {
        if (msg.value > 0) {
            (bool sent,) = devAddress.call{value: msg.value}("");
            require(sent, "OpenAccord: forwarding failed");
        }
    }
}
