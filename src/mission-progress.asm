// CYCLE 64 - Persistent mission results and hints selected from current world state.

// A=elapsed cycle of completion, X=mission. Physical resets never erase these.
// Input: A = completion cycle, X = mission ID. Preserves X/Y; clobbers A and flags.
// Scratch: scratch+18. Results survive physical loop resets.
record_mission:
{
    sta scratch+18
    lda mission_done, x
    bne !known+
    txa
    clc
    adc #1
    sta delivery_event
    !known:
    lda #1
    sta mission_done, x
    sta delivered_run
    lda program_len
    sta run_lines
    lda scratch+18
    cmp best_ticks, x
    bcc !better+
    bne !done+
    lda run_lines
    cmp best_lines, x
    bcs !done+
    !better:
    lda scratch+18
    sta best_ticks, x
    lda run_lines
    sta best_lines, x
    lda loop_count
    sta best_loops, x
    lda #1
    sta new_best
    txa
    clc
    adc #1
    sta delivery_event
    !done:
    rts
}

// A failed ending is recorded as LOST. A secured result and its best time
// can never be overwritten by a later, quicker failed ending.
record_ending:
{
    ldx #MISSION_REACTOR
    lda ending_kind
    beq !secured+
    lda mission_done, x
    cmp #1
    beq !done+
    lda elapsed
    clc
    adc #1
    jsr record_mission
    lda #2
    sta mission_done+MISSION_REACTOR
    rts
    !secured:
    lda mission_done, x
    cmp #2
    bne !record+
    lda #255
    sta best_ticks, x
    sta best_lines, x
    !record:
    lda elapsed
    clc
    adc #1
    jmp record_mission
    !done:
    rts
}

// The first unfinished milestone selects a goal; its hint uses live state.
// Optional records cannot keep the hint stuck on an earlier completed goal.
build_mission:
{
    jsr buf_clear
    lda mission_done+MISSION_REACTOR
    cmp #1
    bne !lost+
    :Ptr(goal_secured)
    jmp buf_text
    !lost:
    cmp #2
    bne !mission+
    :Ptr(mh_revise)
    jmp buf_text
    !mission:
    lda mission_done+MISSION_DOCK
    bne !hub+
    lda held
    cmp #CARGO_CHIP
    bcs !findCell+
    :Ptr(mh_socket)
    jmp buf_text
    !findCell:
    lda discovered+29
    bne !pickCell+
    :Ptr(mh_find)
    jmp buf_text
    !pickCell:
    :Ptr(mh_pick)
    jmp buf_text
    !hub:
    lda mission_done+MISSION_HUB
    bne !junction+
    lda credentials
    and #CRED_ORBIT
    beq !seekOrbit+
    :Ptr(mh_open_hub)
    jmp buf_text
    !seekOrbit:
    lda room_known+1
    bne !workshop+
    lda rec_known+13
    bne !east+
    :Ptr(mh_dock_note)
    jmp buf_text
    !east:
    :Ptr(mh_east)
    jmp buf_text
    !workshop:
    lda dev_found
    bne !workPower+
    :Ptr(mh_scan)
    jmp buf_text
    !workPower:
    lda powered_mask
    and #%00000010
    bne !workRead+
    :Ptr(mh_work_power)
    jmp buf_text
    !workRead:
    :Ptr(mh_work_read)
    jmp buf_text
    !junction:
    lda mission_done+MISSION_JUNCTION
    bne !door+
    lda credentials
    and #CRED_ZENITH
    beq !hubPower+
    :Ptr(mh_south_gate)
    jmp buf_text
    !hubPower:
    lda powered_mask
    and #%00010000
    bne !hubRead+
    :Ptr(mh_hub_power)
    jmp buf_text
    !hubRead:
    :Ptr(mh_hub_read)
    jmp buf_text
    !door:
    lda mission_done+MISSION_DOOR
    bne !reactor+
    lda discovered+3*120+26
    bne !secondCell+
    :Ptr(mh_junction_cell)
    jmp buf_text
    !secondCell:
    lda powered_mask
    and #%00001100
    beq !both+
    :Ptr(mh_second)
    jmp buf_text
    !both:
    :Ptr(mh_both)
    jmp buf_text
    !reactor:
    lda credentials
    and #CRED_VECTOR
    bne !truth+
    :Ptr(mh_security)
    jmp buf_text
    !truth:
    lda rec_known+8
    bne !pulse+
    :Ptr(mh_status)
    jmp buf_text
    !pulse:
    lda firmware
    and #FW_PULSE
    bne !route+
    :Ptr(mh_pulse)
    jmp buf_text
    !route:
    lda firmware
    and #FW_ROUTE
    bne !feedback+
    lda room_known+4
    bne !archivePower+
    :Ptr(mh_archive)
    jmp buf_text
    !archivePower:
    lda powered_mask
    and #%00100000
    bne !archiveRead+
    :Ptr(mh_archive_power)
    jmp buf_text
    !archiveRead:
    :Ptr(mh_route)
    jmp buf_text
    !feedback:
    lda firmware
    and #FW_FEEDBACK
    bne !service+
    lda linked
    bne !vault+
    lda powered_mask
    and #%00100000
    beq !archivePower-
    :Ptr(mh_link)
    jmp buf_text
    !vault:
    lda powered_mask
    and #%10000000
    bne !vaultRead+
    lda held
    cmp #CARGO_CHIP
    bcs !vaultFind+
    :Ptr(mh_vault_power)
    jmp buf_text
    !vaultFind:
    lda discovered+4*120+17
    beq !vaultExplore+
    :Ptr(mh_vault_pick)
    jmp buf_text
    !vaultRead:
    :Ptr(mh_vault_read)
    jmp buf_text
    !vaultExplore:
    :Ptr(mh_feedback)
    jmp buf_text
    !service:
    lda rec_known+9
    bne !notes+
    :Ptr(mh_service)
    jmp buf_text
    !notes:
    lda rec_known+10
    bne !image+
    :Ptr(mh_notes)
    jmp buf_text
    !image:
    lda image_authorized
    bne !chip+
    :Ptr(mh_image)
    jmp buf_text
    !chip:
    lda held
    cmp #CARGO_CHIP
    beq !program+
    :Ptr(mh_chip)
    jmp buf_text
    !program:
    lda chip_state
    bne !deliver+
    :Ptr(mh_programmer)
    jmp buf_text
    !deliver:
    :Ptr(mh_deliver)
    jmp buf_text
}
