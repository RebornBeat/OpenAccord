//! OpenAccord Protocol — Solana/Anchor Program
//!
//! A neutral, schema-blind intent publication and outcome recording protocol.
//!
//! LEGAL NOTICE: This program enforces no economic structure, performs no matching,
//! executes no transactions, and intermediates no agreements. All data is
//! user-provided and self-reported. The protocol does not custody funds.
//!
//! Dev contributions are strictly optional. The program never rejects instructions
//! for zero contribution.

use anchor_lang::prelude::*;
use anchor_lang::solana_program::system_program;

declare_id!("PLACEHOLDER_REPLACE_WITH_DEPLOYED_PROGRAM_ID");

// =============================================================================
// Status Constants
// =============================================================================
pub const STATUS_ACTIVE: u8 = 0;
pub const STATUS_PAUSED: u8 = 1;
pub const STATUS_SETTLED: u8 = 2;
pub const STATUS_CANCELLED: u8 = 3;

// =============================================================================
// Space Constants (for account allocation)
// =============================================================================

/// Discriminator: 8 bytes (Anchor adds automatically)
/// Global state account space
pub const GLOBAL_STATE_SPACE: usize = 8    // discriminator
    + 32   // authority: Pubkey
    + 32   // dev_address: Pubkey
    + 8    // total_intents: u64
    + 8    // total_acknowledgements: u64
    + 8    // total_outcomes: u64
    + 1;   // bump: u8

/// Intent account space
/// We allocate for reasonable max field sizes.
pub const INTENT_SPACE: usize = 8      // discriminator
    + 32   // creator: Pubkey
    + 8    // intent_index: u64
    + 4 + 64   // schema_ref: String (max 64 chars)
    + 4 + 2048 // payload: Vec<u8> (max 2KB)
    + 4 + 32   // state_label: String (max 32 chars)
    + 1    // status: u8
    + 8    // created_at: i64
    + 8    // updated_at: i64
    + 1 + 8    // expires_at: Option<i64>
    + 4 + 512  // image_refs_csv: String (max 512 chars)
    + 4 + 32   // contact_type: String (max 32 chars)
    + 4 + 64   // contact_value: String (max 64 chars)
    + 1;   // bump: u8

/// Acknowledgement account space
pub const ACK_SPACE: usize = 8     // discriminator
    + 32   // intent_key: Pubkey
    + 32   // acknowledger: Pubkey
    + 8    // ack_index: u64
    + 4 + 512  // note_payload: Vec<u8> (max 512 bytes)
    + 4 + 32   // state_label: String (max 32 chars)
    + 8    // created_at: i64
    + 8    // updated_at: i64
    + 1;   // bump: u8

/// Outcome record account space
pub const OUTCOME_SPACE: usize = 8     // discriminator
    + 32   // intent_key: Pubkey
    + 1 + 32   // linked_ack_key: Option<Pubkey>
    + 32   // recorder: Pubkey
    + 4 + 1024 // outcome_payload: Vec<u8> (max 1KB)
    + 8    // recorded_at: i64
    + 1;   // bump: u8

// =============================================================================
// Program
// =============================================================================

#[program]
pub mod open_accord {
    use super::*;

    /// Initialize the global state. Called once by the deployer.
    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        let state = &mut ctx.accounts.global_state;
        state.authority = ctx.accounts.authority.key();
        state.dev_address = ctx.accounts.authority.key();
        state.total_intents = 0;
        state.total_acknowledgements = 0;
        state.total_outcomes = 0;
        state.bump = ctx.bumps.global_state;
        Ok(())
    }

    /// Update the dev contribution recipient address. Authority only.
    pub fn update_dev_address(ctx: Context<UpdateDevAddress>, new_dev_address: Pubkey) -> Result<()> {
        ctx.accounts.global_state.dev_address = new_dev_address;
        emit!(DevAddressUpdated {
            old_address: ctx.accounts.global_state.dev_address,
            new_address: new_dev_address,
        });
        Ok(())
    }

    /// Publish a new Intent.
    ///
    /// The dev contribution (lamports) is optional — pass 0 to contribute nothing.
    /// The program never rejects instructions for zero contribution.
    ///
    /// # Arguments
    /// * `schema_ref`     - Schema identifier (e.g., "service_agreement_v1")
    /// * `payload`        - Arbitrary bytes (JSON from GUI, max 2KB)
    /// * `state_label`    - Initial state (e.g., "open")
    /// * `expires_at`     - Optional Unix timestamp (seconds). 0 = no expiry.
    /// * `image_refs_csv` - Comma-separated image refs (IPFS/Arweave/HTTPS)
    /// * `contact_type`   - Contact method type ("telegram", "nostr", etc.)
    /// * `contact_value`  - Contact method value ("@username", "npub1...", etc.)
    /// * `dev_fee_lamports` - Optional contribution in lamports (may be 0)
    pub fn publish_intent(
        ctx: Context<PublishIntent>,
        schema_ref: String,
        payload: Vec<u8>,
        state_label: String,
        expires_at: i64,
        image_refs_csv: String,
        contact_type: String,
        contact_value: String,
        dev_fee_lamports: u64,
    ) -> Result<()> {
        // Validate field sizes
        require!(schema_ref.len() <= 64, OpenAccordError::SchemaRefTooLong);
        require!(payload.len() <= 2048, OpenAccordError::PayloadTooLarge);
        require!(state_label.len() <= 32, OpenAccordError::StateLabelTooLong);
        require!(image_refs_csv.len() <= 512, OpenAccordError::ImageRefsTooLong);
        require!(contact_type.len() <= 32, OpenAccordError::ContactTypeTooLong);
        require!(contact_value.len() <= 64, OpenAccordError::ContactValueTooLong);

        // Route optional dev contribution
        if dev_fee_lamports > 0 {
            let cpi_context = CpiContext::new(
                ctx.accounts.system_program.to_account_info(),
                anchor_lang::system_program::Transfer {
                    from: ctx.accounts.creator.to_account_info(),
                    to: ctx.accounts.dev_address.to_account_info(),
                },
            );
            anchor_lang::system_program::transfer(cpi_context, dev_fee_lamports)?;
        }

        let state = &mut ctx.accounts.global_state;
        let intent_index = state.total_intents;
        state.total_intents += 1;

        let intent = &mut ctx.accounts.intent;
        let now = Clock::get()?.unix_timestamp;

        intent.creator = ctx.accounts.creator.key();
        intent.intent_index = intent_index;
        intent.schema_ref = schema_ref.clone();
        intent.payload = payload;
        intent.state_label = state_label;
        intent.status = STATUS_ACTIVE;
        intent.created_at = now;
        intent.updated_at = now;
        intent.expires_at = if expires_at > 0 { Some(expires_at) } else { None };
        intent.image_refs_csv = image_refs_csv;
        intent.contact_type = contact_type;
        intent.contact_value = contact_value;
        intent.bump = ctx.bumps.intent;

        emit!(IntentPublished {
            intent_key: ctx.accounts.intent.key(),
            creator: ctx.accounts.creator.key(),
            intent_index,
            schema_ref,
            created_at: now,
        });

        Ok(())
    }

    /// Update an existing Intent. Only callable by creator.
    ///
    /// Pass None for fields you do not wish to update.
    /// Pass Some(STATUS_CANCELLED) to cancel via update (prefer cancel_intent).
    pub fn update_intent(
        ctx: Context<UpdateIntent>,
        new_payload: Option<Vec<u8>>,
        new_state_label: Option<String>,
        new_status: Option<u8>,
        new_expires_at: Option<i64>,
        new_image_refs_csv: Option<String>,
    ) -> Result<()> {
        let intent = &mut ctx.accounts.intent;
        require!(intent.status != STATUS_CANCELLED, OpenAccordError::IntentCancelled);

        let now = Clock::get()?.unix_timestamp;

        if let Some(p) = new_payload {
            require!(p.len() <= 2048, OpenAccordError::PayloadTooLarge);
            intent.payload = p;
        }
        if let Some(s) = new_state_label {
            require!(s.len() <= 32, OpenAccordError::StateLabelTooLong);
            intent.state_label = s;
        }
        if let Some(status) = new_status {
            require!(status <= 3, OpenAccordError::InvalidStatus);
            intent.status = status;
        }
        if let Some(exp) = new_expires_at {
            intent.expires_at = if exp > 0 { Some(exp) } else { None };
        }
        if let Some(refs) = new_image_refs_csv {
            require!(refs.len() <= 512, OpenAccordError::ImageRefsTooLong);
            intent.image_refs_csv = refs;
        }

        intent.updated_at = now;

        emit!(IntentUpdated {
            intent_key: ctx.accounts.intent.key(),
            creator: ctx.accounts.creator.key(),
            new_status: intent.status,
            state_label: intent.state_label.clone(),
            updated_at: now,
        });

        Ok(())
    }

    /// Cancel an Intent. Only callable by creator. Irreversible.
    pub fn cancel_intent(ctx: Context<CancelIntent>) -> Result<()> {
        let intent = &mut ctx.accounts.intent;
        require!(intent.status != STATUS_CANCELLED, OpenAccordError::IntentCancelled);

        let now = Clock::get()?.unix_timestamp;
        intent.status = STATUS_CANCELLED;
        intent.updated_at = now;

        emit!(IntentCancelledEvent {
            intent_key: ctx.accounts.intent.key(),
            cancelled_by: ctx.accounts.creator.key(),
            cancelled_at: now,
        });

        Ok(())
    }

    /// Submit a non-binding Acknowledgement for an Intent.
    ///
    /// IMPORTANT: Not a commitment. Not acceptance of any terms.
    /// A declarative data record only.
    ///
    /// # Arguments
    /// * `note_payload` - Optional arbitrary data (max 512 bytes, may be empty)
    /// * `state_label`  - Initial state (e.g., "interested")
    pub fn acknowledge_intent(
        ctx: Context<AcknowledgeIntent>,
        note_payload: Vec<u8>,
        state_label: String,
    ) -> Result<()> {
        require!(
            ctx.accounts.intent.status == STATUS_ACTIVE,
            OpenAccordError::IntentNotActive
        );
        require!(note_payload.len() <= 512, OpenAccordError::PayloadTooLarge);
        require!(state_label.len() <= 32, OpenAccordError::StateLabelTooLong);

        let state = &mut ctx.accounts.global_state;
        let ack_index = state.total_acknowledgements;
        state.total_acknowledgements += 1;

        let ack = &mut ctx.accounts.acknowledgement;
        let now = Clock::get()?.unix_timestamp;

        ack.intent_key = ctx.accounts.intent.key();
        ack.acknowledger = ctx.accounts.acknowledger.key();
        ack.ack_index = ack_index;
        ack.note_payload = note_payload;
        ack.state_label = state_label.clone();
        ack.created_at = now;
        ack.updated_at = now;
        ack.bump = ctx.bumps.acknowledgement;

        emit!(AcknowledgementSubmitted {
            ack_key: ctx.accounts.acknowledgement.key(),
            intent_key: ctx.accounts.intent.key(),
            acknowledger: ctx.accounts.acknowledger.key(),
            ack_index,
            created_at: now,
        });

        Ok(())
    }

    /// Advance state of an Acknowledgement. Callable by the acknowledger.
    pub fn advance_state_acknowledger(
        ctx: Context<AdvanceStateAcknowledger>,
        new_state_label: String,
    ) -> Result<()> {
        require!(new_state_label.len() <= 32, OpenAccordError::StateLabelTooLong);

        let ack = &mut ctx.accounts.acknowledgement;
        let now = Clock::get()?.unix_timestamp;

        let old_state = ack.state_label.clone();
        ack.state_label = new_state_label.clone();
        ack.updated_at = now;

        emit!(StateAdvanced {
            ack_key: ctx.accounts.acknowledgement.key(),
            intent_key: ack.intent_key,
            advancer: ctx.accounts.acknowledger.key(),
            old_state_label: old_state,
            new_state_label,
            updated_at: now,
        });

        Ok(())
    }

    /// Advance state of an Acknowledgement. Callable by the Intent creator.
    pub fn advance_state_creator(
        ctx: Context<AdvanceStateCreator>,
        new_state_label: String,
    ) -> Result<()> {
        require!(new_state_label.len() <= 32, OpenAccordError::StateLabelTooLong);
        require!(
            ctx.accounts.acknowledgement.intent_key == ctx.accounts.intent.key(),
            OpenAccordError::AcknowledgementMismatch
        );

        let ack = &mut ctx.accounts.acknowledgement;
        let now = Clock::get()?.unix_timestamp;

        let old_state = ack.state_label.clone();
        ack.state_label = new_state_label.clone();
        ack.updated_at = now;

        emit!(StateAdvanced {
            ack_key: ctx.accounts.acknowledgement.key(),
            intent_key: ack.intent_key,
            advancer: ctx.accounts.creator.key(),
            old_state_label: old_state,
            new_state_label,
            updated_at: now,
        });

        Ok(())
    }

    /// Cancel an Acknowledgement. Callable by the acknowledger only.
    pub fn cancel_acknowledgement(ctx: Context<CancelAcknowledgement>) -> Result<()> {
        let ack = &mut ctx.accounts.acknowledgement;
        let now = Clock::get()?.unix_timestamp;

        ack.state_label = "cancelled".to_string();
        ack.updated_at = now;

        emit!(AcknowledgementCancelledEvent {
            ack_key: ctx.accounts.acknowledgement.key(),
            cancelled_by: ctx.accounts.acknowledger.key(),
            cancelled_at: now,
        });

        Ok(())
    }

    /// Record a self-reported Outcome.
    ///
    /// Any party may call this independently. Not verified by the protocol.
    ///
    /// # Arguments
    /// * `linked_ack_key`   - Optional Pubkey of linked acknowledgement
    /// * `outcome_payload`  - Arbitrary outcome data (max 1KB)
    /// * `dev_fee_lamports` - Optional contribution (may be 0)
    pub fn record_outcome(
        ctx: Context<RecordOutcome>,
        linked_ack_key: Option<Pubkey>,
        outcome_payload: Vec<u8>,
        dev_fee_lamports: u64,
    ) -> Result<()> {
        require!(outcome_payload.len() <= 1024, OpenAccordError::PayloadTooLarge);

        // Route optional dev contribution
        if dev_fee_lamports > 0 {
            let cpi_context = CpiContext::new(
                ctx.accounts.system_program.to_account_info(),
                anchor_lang::system_program::Transfer {
                    from: ctx.accounts.recorder.to_account_info(),
                    to: ctx.accounts.dev_address.to_account_info(),
                },
            );
            anchor_lang::system_program::transfer(cpi_context, dev_fee_lamports)?;
        }

        let state = &mut ctx.accounts.global_state;
        state.total_outcomes += 1;

        let outcome = &mut ctx.accounts.outcome;
        let now = Clock::get()?.unix_timestamp;

        outcome.intent_key = ctx.accounts.intent.key();
        outcome.linked_ack_key = linked_ack_key;
        outcome.recorder = ctx.accounts.recorder.key();
        outcome.outcome_payload = outcome_payload;
        outcome.recorded_at = now;
        outcome.bump = ctx.bumps.outcome;

        emit!(OutcomeRecorded {
            outcome_key: ctx.accounts.outcome.key(),
            intent_key: ctx.accounts.intent.key(),
            linked_ack_key,
            recorder: ctx.accounts.recorder.key(),
            recorded_at: now,
        });

        Ok(())
    }
}

// =============================================================================
// Account Structs (Data)
// =============================================================================

#[account]
pub struct GlobalState {
    pub authority: Pubkey,
    pub dev_address: Pubkey,
    pub total_intents: u64,
    pub total_acknowledgements: u64,
    pub total_outcomes: u64,
    pub bump: u8,
}

#[account]
pub struct Intent {
    pub creator: Pubkey,
    pub intent_index: u64,
    pub schema_ref: String,
    pub payload: Vec<u8>,
    pub state_label: String,
    pub status: u8,
    pub created_at: i64,
    pub updated_at: i64,
    pub expires_at: Option<i64>,
    pub image_refs_csv: String,
    pub contact_type: String,
    pub contact_value: String,
    pub bump: u8,
}

#[account]
pub struct Acknowledgement {
    pub intent_key: Pubkey,
    pub acknowledger: Pubkey,
    pub ack_index: u64,
    pub note_payload: Vec<u8>,
    pub state_label: String,
    pub created_at: i64,
    pub updated_at: i64,
    pub bump: u8,
}

#[account]
pub struct OutcomeRecord {
    pub intent_key: Pubkey,
    pub linked_ack_key: Option<Pubkey>,
    pub recorder: Pubkey,
    pub outcome_payload: Vec<u8>,
    pub recorded_at: i64,
    pub bump: u8,
}

// =============================================================================
// Instruction Contexts
// =============================================================================

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = authority,
        space = GLOBAL_STATE_SPACE,
        seeds = [b"global_state"],
        bump
    )]
    pub global_state: Account<'info, GlobalState>,

    #[account(mut)]
    pub authority: Signer<'info>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct UpdateDevAddress<'info> {
    #[account(
        mut,
        seeds = [b"global_state"],
        bump = global_state.bump,
        has_one = authority
    )]
    pub global_state: Account<'info, GlobalState>,

    pub authority: Signer<'info>,
}

#[derive(Accounts)]
pub struct PublishIntent<'info> {
    #[account(
        mut,
        seeds = [b"global_state"],
        bump = global_state.bump
    )]
    pub global_state: Account<'info, GlobalState>,

    #[account(
        init,
        payer = creator,
        space = INTENT_SPACE,
        seeds = [
            b"intent",
            creator.key().as_ref(),
            &global_state.total_intents.to_le_bytes()
        ],
        bump
    )]
    pub intent: Account<'info, Intent>,

    #[account(mut)]
    pub creator: Signer<'info>,

    /// CHECK: Dev address is validated by global state. Used only as transfer target.
    #[account(
        mut,
        constraint = dev_address.key() == global_state.dev_address
    )]
    pub dev_address: AccountInfo<'info>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct UpdateIntent<'info> {
    #[account(
        mut,
        has_one = creator,
        seeds = [
            b"intent",
            creator.key().as_ref(),
            &intent.intent_index.to_le_bytes()
        ],
        bump = intent.bump
    )]
    pub intent: Account<'info, Intent>,

    pub creator: Signer<'info>,
}

#[derive(Accounts)]
pub struct CancelIntent<'info> {
    #[account(
        mut,
        has_one = creator,
        seeds = [
            b"intent",
            creator.key().as_ref(),
            &intent.intent_index.to_le_bytes()
        ],
        bump = intent.bump
    )]
    pub intent: Account<'info, Intent>,

    pub creator: Signer<'info>,
}

#[derive(Accounts)]
pub struct AcknowledgeIntent<'info> {
    #[account(
        mut,
        seeds = [b"global_state"],
        bump = global_state.bump
    )]
    pub global_state: Account<'info, GlobalState>,

    /// CHECK: Any active intent may be acknowledged. Status is checked in instruction.
    #[account(constraint = intent.status == STATUS_ACTIVE)]
    pub intent: Account<'info, Intent>,

    #[account(
        init,
        payer = acknowledger,
        space = ACK_SPACE,
        seeds = [
            b"ack",
            acknowledger.key().as_ref(),
            &global_state.total_acknowledgements.to_le_bytes()
        ],
        bump
    )]
    pub acknowledgement: Account<'info, Acknowledgement>,

    #[account(mut)]
    pub acknowledger: Signer<'info>,

    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct AdvanceStateAcknowledger<'info> {
    #[account(
        mut,
        has_one = acknowledger,
        seeds = [
            b"ack",
            acknowledger.key().as_ref(),
            &acknowledgement.ack_index.to_le_bytes()
        ],
        bump = acknowledgement.bump
    )]
    pub acknowledgement: Account<'info, Acknowledgement>,

    pub acknowledger: Signer<'info>,
}

#[derive(Accounts)]
pub struct AdvanceStateCreator<'info> {
    /// CHECK: Verified by constraint below (creator must own intent)
    #[account(
        has_one = creator,
        seeds = [
            b"intent",
            creator.key().as_ref(),
            &intent.intent_index.to_le_bytes()
        ],
        bump = intent.bump
    )]
    pub intent: Account<'info, Intent>,

    #[account(
        mut,
        constraint = acknowledgement.intent_key == intent.key()
    )]
    pub acknowledgement: Account<'info, Acknowledgement>,

    pub creator: Signer<'info>,
}

#[derive(Accounts)]
pub struct CancelAcknowledgement<'info> {
    #[account(
        mut,
        has_one = acknowledger,
        seeds = [
            b"ack",
            acknowledger.key().as_ref(),
            &acknowledgement.ack_index.to_le_bytes()
        ],
        bump = acknowledgement.bump
    )]
    pub acknowledgement: Account<'info, Acknowledgement>,

    pub acknowledger: Signer<'info>,
}

#[derive(Accounts)]
pub struct RecordOutcome<'info> {
    #[account(
        mut,
        seeds = [b"global_state"],
        bump = global_state.bump
    )]
    pub global_state: Account<'info, GlobalState>,

    /// CHECK: Any intent may have an outcome recorded against it.
    pub intent: Account<'info, Intent>,

    #[account(
        init,
        payer = recorder,
        space = OUTCOME_SPACE,
        seeds = [
            b"outcome",
            recorder.key().as_ref(),
            intent.key().as_ref(),
            &global_state.total_outcomes.to_le_bytes()
        ],
        bump
    )]
    pub outcome: Account<'info, OutcomeRecord>,

    #[account(mut)]
    pub recorder: Signer<'info>,

    /// CHECK: Dev address validated by global state.
    #[account(
        mut,
        constraint = dev_address.key() == global_state.dev_address
    )]
    pub dev_address: AccountInfo<'info>,

    pub system_program: Program<'info, System>,
}

// =============================================================================
// Events
// =============================================================================

#[event]
pub struct IntentPublished {
    pub intent_key: Pubkey,
    pub creator: Pubkey,
    pub intent_index: u64,
    pub schema_ref: String,
    pub created_at: i64,
}

#[event]
pub struct IntentUpdated {
    pub intent_key: Pubkey,
    pub creator: Pubkey,
    pub new_status: u8,
    pub state_label: String,
    pub updated_at: i64,
}

#[event]
pub struct IntentCancelledEvent {
    pub intent_key: Pubkey,
    pub cancelled_by: Pubkey,
    pub cancelled_at: i64,
}

#[event]
pub struct AcknowledgementSubmitted {
    pub ack_key: Pubkey,
    pub intent_key: Pubkey,
    pub acknowledger: Pubkey,
    pub ack_index: u64,
    pub created_at: i64,
}

#[event]
pub struct StateAdvanced {
    pub ack_key: Pubkey,
    pub intent_key: Pubkey,
    pub advancer: Pubkey,
    pub old_state_label: String,
    pub new_state_label: String,
    pub updated_at: i64,
}

#[event]
pub struct AcknowledgementCancelledEvent {
    pub ack_key: Pubkey,
    pub cancelled_by: Pubkey,
    pub cancelled_at: i64,
}

#[event]
pub struct OutcomeRecorded {
    pub outcome_key: Pubkey,
    pub intent_key: Pubkey,
    pub linked_ack_key: Option<Pubkey>,
    pub recorder: Pubkey,
    pub recorded_at: i64,
}

#[event]
pub struct DevAddressUpdated {
    pub old_address: Pubkey,
    pub new_address: Pubkey,
}

// =============================================================================
// Errors
// =============================================================================

#[error_code]
pub enum OpenAccordError {
    #[msg("Not the creator of this intent")]
    NotCreator,
    #[msg("Intent is not in active status")]
    IntentNotActive,
    #[msg("Intent is already cancelled")]
    IntentCancelled,
    #[msg("Acknowledgement does not belong to this intent")]
    AcknowledgementMismatch,
    #[msg("Invalid status value (must be 0-3)")]
    InvalidStatus,
    #[msg("Schema ref exceeds maximum length of 64 characters")]
    SchemaRefTooLong,
    #[msg("Payload exceeds maximum size")]
    PayloadTooLarge,
    #[msg("State label exceeds maximum length of 32 characters")]
    StateLabelTooLong,
    #[msg("Image refs CSV exceeds maximum length of 512 characters")]
    ImageRefsTooLong,
    #[msg("Contact type exceeds maximum length of 32 characters")]
    ContactTypeTooLong,
    #[msg("Contact value exceeds maximum length of 64 characters")]
    ContactValueTooLong,
}
