// One logical cycle per call; empty lines and program end cost none.
// Sample elapsed, resolve action, increment cycle. Delivery records elapsed+1.
// HALT_END is not final: the UI clears it to continue with lines added later.
vm_tick:
    lda halt_reason
    beq !ready+
    rts
!ready:
    // A zero-cycle halt must not repeat the previous cycle's delivery event.
    lda #0
    sta delivery_event
    lda cycles_left
    bne !execute+
    ldx ip
    cpx program_len
    bcc !load+
    lda #HALT_END
    sta halt_reason
    rts
!load:
    lda program_op,x
    cmp #OP_EMPTY
    bne !command+
    inc ip
    inx
    cpx program_len
    bcc !load-
    lda #HALT_END
    sta halt_reason
    rts
!command:
    sta active_op
    lda program_arg,x
    sta active_arg
    lda program_dir,x
    sta active_dir
    lda #0
    sta substep
    lda active_op
    jsr op_cost
    sta cycles_left
!execute:
    lda #0
    sta action_error
    sta delivery_event
    inc substep
    lda active_op
    cmp #4
    bcc !move+
    cmp #OP_PICK
    beq !pick+
    cmp #OP_DROP
    beq !drop+
    cmp #OP_SCAN
    beq !scan+
    cmp #OP_READ
    beq !read+
    cmp #OP_ACCESS
    beq !access+
    cmp #OP_BOOST
    beq !boost+
    cmp #OP_LINK
    beq !link+
    jmp !consume+
!move:
    jsr world_move_dir
    jmp !consume+
!pick:
    jsr world_pick
    jmp !consume+
!drop:
    jsr world_drop
    jmp !consume+
!scan:
    lda cycles_left
    cmp #1
    bne !consume+
    jsr reveal_scan
    jmp !consume+
!read:
    lda cycles_left
    cmp #1
    bne !consume+
    jsr world_read
    jmp !consume+
!access:
    jsr world_access
    jmp !consume+
!link:
    lda cycles_left
    cmp #1
    bne !consume+
    jsr world_link
    jmp !consume+
!boost:
    // Two tiles per cycle. substep counts tiles, and each tile is checked.
    lda active_dir
    jsr world_move_dir
    lda action_error
    bne !consume+
    lda substep
    cmp active_arg
    bcs !consume+
    jsr laser_check
    lda action_error
    bne !consume+
    inc substep
    lda active_dir
    jsr world_move_dir
!consume:
    lda action_error
    bne !counted+
    jsr laser_check
!counted:
    inc elapsed
    dec cycles_left
    lda elapsed
    cmp #64
    bcs !expired+
    lda action_error
    beq !clock+
    sta halt_reason
    rts
!clock:
    lda cycles_left
    bne !return+
    inc ip
    rts
!expired:
    // A failure in the last cycle still names its cause.
    lda action_error
    bne !failed+
    lda #HALT_CLOCK
!failed:
    sta halt_reason
!return:
    rts
// A=opcode, active_arg loaded. Returns A=cycle cost.
op_cost:
    cmp #OP_SCAN
    beq !two+
    cmp #OP_LINK
    beq !two+
    cmp #OP_READ
    beq !two+
    cmp #OP_BOOST
    beq !boost+
    cmp #OP_PICK
    bcc !count+
    cmp #OP_WAIT
    beq !count+
    lda #1
    rts
!two:
    lda #2
    rts
!boost:
    lda active_arg
    clc
    adc #1
    lsr
    rts
!count:
    lda active_arg
    rts
