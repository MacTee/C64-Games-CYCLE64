// CYCLE 64 - Room-clipped visibility, integer line of sight and hidden-device discovery.

// Square radius, room-clipped Bresenham sight. Opaque target is revealed;
// intermediate walls/closed gates block it. Uses only integer coordinates.
reveal_normal:
{
    lda #1
    bne reveal_radius
}

// SCAN: radius 3, then hidden devices in sight are found. A FEEDBACK
// diagnostic is necessary for the concealed duct hatches.
reveal_scan:
{
    lda #3
    jsr reveal_radius
    ldx #DEV_COUNT-1
    !device:
    lda dev_room, x
    cmp robot_room
    bne !next+
    lda dev_hidden, x
    beq !next+
    lda dev_found, x
    bne !next+
    ldy dev_index, x
    lda visible_now, y
    beq !next+
    lda dev_hidden, x
    cmp #2
    bne !found+
    lda firmware
    and #FW_FEEDBACK
    bne !duct+
    lda #EV_ECHO
    jsr raise_event
    jmp !next+
    !duct:
    lda #EV_DUCT
    bne !mark+
    !found:
    lda #EV_SCAN
    !mark:
    jsr raise_event
    lda #1
    sta dev_found, x
    !next:
    dex
    bpl !device-
    rts
}

// Reveal the room-clipped square sight radius supplied in A.
reveal_radius:
{
    sta vision_radius
    // The first visit of a room raises its arrival line.
    ldx robot_room
    lda room_known, x
    bne !known+
    lda #1
    sta room_known, x
    stx event_arg
    lda #EV_ROOM
    jsr raise_event
    !known:
    lda #0
    ldx #119
    !clear:
    sta visible_now, x
    dex
    bpl !clear-
    lda robot_x
    sec
    sbc vision_radius
    bcs !minX+
    lda #0
    !minX:
    sta vision_min_x
    lda robot_x
    clc
    adc vision_radius
    cmp #12
    bcc !maxX+
    lda #11
    !maxX:
    sta vision_max_x
    lda robot_y
    sec
    sbc vision_radius
    bcs !minY+
    lda #0
    !minY:
    sta vision_min_y
    sta vision_y
    lda robot_y
    clc
    adc vision_radius
    cmp #10
    bcc !maxY+
    lda #9
    !maxY:
    sta vision_max_y
    !row:
    lda vision_min_x
    sta vision_x
    !tile:
    jsr line_of_sight
    bcs !next+
    ldx vision_y
    lda row12, x
    clc
    adc vision_x
    tay
    lda #1
    sta visible_now, y
    ldx robot_room
    lda discovery_lo, x
    sta data_ptr
    lda discovery_hi, x
    sta data_ptr+1
    lda #1
    sta (data_ptr), y
    !next:
    lda vision_x
    cmp vision_max_x
    beq !rowDone+
    inc vision_x
    jmp !tile-
    !rowDone:
    lda vision_y
    cmp vision_max_y
    beq !done+
    inc vision_y
    jmp !row-
    !done:
    rts
}

// Trace integer sight coordinates until an opaque intermediate tile blocks them.
line_of_sight:
{
    lda robot_x
    sta ray_x
    lda robot_y
    sta ray_y
    lda #1
    sta ray_sx
    sta ray_sy
    lda vision_x
    sec
    sbc robot_x
    bcs !dx+
    eor #%11111111
    clc
    adc #1
    dec ray_sx
    dec ray_sx
    !dx:
    sta ray_dx
    lda vision_y
    sec
    sbc robot_y
    bcs !dy+
    eor #%11111111
    clc
    adc #1
    dec ray_sy
    dec ray_sy
    !dy:
    sta ray_dy
    lda ray_dx
    sec
    sbc ray_dy
    sta ray_err
    !advance:
    lda ray_x
    cmp vision_x
    bne !step+
    lda ray_y
    cmp vision_y
    bne !step+
    clc
    rts
    !step:
    lda ray_err
    asl
    sta ray_e2
    // Signed e2 > -dy.
    lda #0
    sec
    sbc ray_dy
    eor #%10000000
    sta ray_compare
    lda ray_e2
    eor #%10000000
    cmp ray_compare
    bcc !yStep+
    beq !yStep+
    lda ray_err
    sec
    sbc ray_dy
    sta ray_err
    lda ray_x
    clc
    adc ray_sx
    sta ray_x
    !yStep:
    lda ray_dx
    eor #%10000000
    sta ray_compare
    lda ray_e2
    eor #%10000000
    cmp ray_compare
    bcs !test+
    lda ray_err
    clc
    adc ray_dx
    sta ray_err
    lda ray_y
    clc
    adc ray_sy
    sta ray_y
    !test:
    lda ray_x
    cmp vision_x
    bne !opaque+
    lda ray_y
    cmp vision_y
    beq !visible+
    !opaque:
    ldx ray_y
    lda row12, x
    clc
    adc ray_x
    tay
    ldx robot_room
    lda live_lo, x
    sta data_ptr
    lda live_hi, x
    sta data_ptr+1
    lda (data_ptr), y
    tax
    lda tile_opaque, x
    bne !blocked+
    jmp !advance-
    !blocked:
    sec
    rts
    !visible:
    clc
    rts
}
