// CYCLE 64 - Logical-cycle laser timing shared by collision checks and rendering.

// A=cycle, X=room, Y=laser row. A=cycles until phase change, carry set when laser is ON.
// Input: A = logical cycle, X = room, Y = laser row; decimal mode must be clear.
// Returns: A = cycles until phase change, C = 1 when ON; preserves X/Y.
laser_phase:
{
    cpx #6
    bne !standard+
    cpy #3
    beq !cool3+
    cpy #5
    beq !cool5+
    !standard:
    cpx #5
    beq !reactor+
    and #%00000111
    cmp #4
    bcs !off4+
    eor #%00000011
    clc
    adc #1
    sec
    rts
    !off4:
    and #%00000011
    eor #%00000011
    clc
    adc #1
    clc
    rts
    !reactor:
    cmp #10
    bcc !phase+
    sbc #10
    bcs !reactor-
    !phase:
    cmp #8
    bcs !off2+
    eor #%00000111
    clc
    adc #1
    sec
    rts
    !off2:
    eor #%11111111
    clc
    adc #11
    clc
    rts

    // Cooling row 3: 3 ON / 2 OFF, period 5.
    !cool3:
    cmp #5
    bcc !phase3+
    sbc #5
    bcs !cool3-
    !phase3:
    cmp #3
    bcs !off3+
    eor #%11111111
    clc
    adc #4
    sec
    rts
    !off3:
    eor #%11111111
    clc
    adc #6
    clc
    rts
    // Cooling row 5: 5 ON / 2 OFF, period 7.
    !cool5:
    cmp #7
    bcc !phase5+
    sbc #7
    bcs !cool5-
    !phase5:
    cmp #5
    bcs !off5+
    eor #%11111111
    clc
    adc #6
    sec
    rts
    !off5:
    eor #%11111111
    clc
    adc #8
    clc
    rts
}
