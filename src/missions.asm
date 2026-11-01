// CYCLE 64 - Record rewards, access checks, control-chip programming and reactor outcomes.

// A=record. Stores it once and applies its rewards: credentials, firmware
// and story flags. The event names the record on every read.
learn_record:
{
    tax
    stx event_arg
    stx show_record
    lda rec_known, x
    bne !event+
    // 2 = stored and not yet viewed, 1 = viewed.
    lda #2
    sta rec_known, x
    // A new record opens on the screen after this cycle (after_tick).
    stx show_record
    lda new_record
    bne !grant+
    stx new_record
    !grant:
    lda credentials
    ora rec_cred, x
    sta credentials
    lda firmware
    ora rec_fw, x
    sta firmware
    lda story_flags
    ora rec_flag, x
    sta story_flags
    cpx #REC_REFUGE
    bne !event+
    jsr reveal_refuge
    !event:
    lda #EV_RECORD
    jmp raise_event
}

// The evacuation order marks the sealed refuge on the map.
reveal_refuge:
{
    lda #1
    sta room_known+REFUGE_ROOM
    ldx #119
    !tile:
    sta discovered+REFUGE_ROOM*120, x
    dex
    bpl !tile-
    rts
}

// ACCESS: gates and hatches open for this loop,
// and the workshop programmer writes the authorized image to a held chip.
world_access:
{
    lda active_dir
    jsr adjacent_target
    bcs !fail+
    // A sealed door has no console. The halt says why it stays shut.
    lda target_tile
    cmp #TILE_DOOR
    beq !door+
    jsr find_device
    bcs !fail+
    lda dev_hidden, x
    beq !visible+
    lda dev_found, x
    beq !fail+
    !visible:
    lda dev_kind, x
    cmp #KIND_PROG
    bne !gate+
    jmp program_chip
    !gate:
    cmp #KIND_GATE
    beq !open+
    cmp #KIND_HATCH
    beq !open+
    cmp #KIND_REACTOR
    bne !fail+
    // The module takes the chip with DROP. Without the chip, READ it.
    lda held
    cmp #CARGO_CHIP
    bne !sealed+
    lda #HALT_USE_DROP
    bne !error+
    !sealed:
    lda #HALT_SEALED_MODULE
    bne !error+
    !door:
    // The junction door opens with power (M4). The refuge door stays sealed.
    lda target_room
    cmp #3
    bne !inside+
    lda #HALT_DOOR_POWER
    bne !error+
    !inside:
    lda #HALT_DOOR_INSIDE
    bne !error+
    !fail:
    lda #HALT_NO_LOCK
    !error:
    sta action_error
    rts
    !open:
    lda dev_cred, x
    beq !free+
    and credentials
    beq !unknown+
    !free:
    // The dock hatch opens only while a cell lies on the east dock socket.
    cpx #DEV_DOCK_HATCH
    bne !unlock+
    stx scratch+13
    jsr hatch_powered
    ldx scratch+13
    cmp #64
    beq !unlock+
    lda #HALT_HATCH_POWER
    sta action_error
    rts
    !unlock:
    lda dev_fw, x
    beq !firmwareReady+
    and firmware
    bne !firmwareReady+
    lda #HALT_FIRMWARE
    sta action_error
    rts
    !firmwareReady:
    lda dev_param, x
    ldy target_index
    sta (data_ptr), y
    lda dev_kind, x
    cmp #KIND_HATCH
    beq !hatch+
    lda #EV_GATE
    bne !event+
    !hatch:
    lda #EV_HATCH
    !event:
    jsr raise_event
    lda target_room
    cmp #2
    bne !reveal+
    lda target_index
    cmp #52
    bne !reveal+
    ldx #MISSION_HUB
    lda elapsed
    clc
    adc #1
    jsr record_mission
    !reveal:
    jmp reveal_normal
    !unknown:
    lda #HALT_CREDENTIAL
    sta action_error
    rts
}

// Write the authorized reactor image to the held control chip.
program_chip:
{
    lda held
    cmp #CARGO_CHIP
    bne !noChip+
    lda image_authorized
    beq !noImage+
    lda #1
    sta chip_state
    lda #EV_CHIP
    jmp raise_event
    !noChip:
    lda #HALT_NO_CHIP
    bne !error+
    !noImage:
    lda #HALT_NO_IMAGE
    !error:
    sta action_error
    rts
}

// DROP of the chip into the reactor control module. The authorized image runs.
// Good and bad results end the game, the others are diagnostic halts.
install_chip:
{
    lda chip_state
    bne !programmed+
    lda #HALT_CHIP_BLANK
    sta action_error
    rts
    !programmed:
    lda #253
    sta cargo_room+CARGO_CHIP
    lda #255
    sta held
    jsr reactor_eval
    sta ending_kind
    cmp #3
    bcs !diagnostic+
    jsr record_ending
    !diagnostic:
    lda ending_kind
    tax
    lda outcome_halt, x
    sta action_error
    rts
}

outcome_halt:
    .byte HALT_ENDING, HALT_ENDING, HALT_ENDING, HALT_R_POWER, HALT_R_FIELD, HALT_R_INERT
// Runs the reactor image in order. Returns A=OUT_*.
// FEEDBACK raises usable power, PULSE needs that power to overclock the control
// processor, ROUTE needs the processor to contract the field, and RESET OFF is
// safe only around a contracted field. SHUTDOWN always ends containment.
// Returns: A = OUT_*; preserves Y, clobbers X/flags and scratch+8..scratch+11.
// Precondition: image contains IMAGE_SLOTS valid reactor command IDs or empty slots.
reactor_eval:
{
    lda #0
    sta scratch+8                                           // power
    sta scratch+9                                           // processor
    sta scratch+10                                          // field contracted
    sta scratch+11                                          // quarantine released
    ldx #0
    !slot:
    lda image, x
    cmp #RC_FEEDBACK
    bne !pulse+
    sta scratch+8
    jmp !next+
    !pulse:
    cmp #RC_PULSE
    bne !route+
    lda scratch+8
    beq !power+
    sta scratch+9
    jmp !next+
    !route:
    cmp #RC_ROUTE
    bne !release+
    lda scratch+9
    beq !field+
    sta scratch+10
    jmp !next+
    !release:
    cmp #RC_RESET_OFF
    bne !shutdown+
    lda scratch+10
    beq !danger+
    sta scratch+11
    jmp !next+
    !shutdown:
    cmp #RC_SHUTDOWN
    beq !off+
    !next:
    inx
    cpx #IMAGE_SLOTS
    bne !slot-
    lda scratch+11
    beq !inert+
    lda #OUT_GOOD
    rts
    !inert:
    lda #OUT_INERT
    rts
    !power:
    lda #OUT_POWER
    rts
    !field:
    lda #OUT_FIELD
    rts
    !danger:
    lda #OUT_RELEASE
    rts
    !off:
    lda #OUT_SHUTDOWN
    rts
}

// Records 0-24: credential, firmware and story flag rewards. Transmissions
// (15-24) give none.
rec_cred:
    .byte 0, CRED_ORBIT, 0, CRED_VECTOR, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, CRED_ZENITH
    .fill 10, 0
rec_fw:
    .byte 0, 0, 0, 0, FW_PULSE, FW_ROUTE, 0, FW_FEEDBACK, 0, 0, 0, 0, 0, 0, 0
    .fill 10, 0
rec_flag:
    .byte 0, 0, 0, 0, 0, 0, FLAG_REFUGE, 0, FLAG_TRUTH, FLAG_OBJECTIVE, 0, 0, 0, 0, 0
    .fill 10, 0
