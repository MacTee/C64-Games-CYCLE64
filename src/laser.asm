// A=cycle, X=room, Y=laser row. A=cycles until phase change, carry set when laser is ON.
laser_phase:
    cpx #6
    bne !standard+
    cpy #3
    beq !cool3+
    cpy #5
    beq !cool5+
!standard:
    cpx #5
    beq !reactor+
    and #7
    cmp #4
    bcs !off4+
    eor #3
    clc
    adc #1
    sec
    rts
!off4:
    and #3
    eor #3
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
    eor #7
    clc
    adc #1
    sec
    rts
!off2:
    eor #$ff
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
    eor #$ff
    clc
    adc #4
    sec
    rts
!off3:
    eor #$ff
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
    eor #$ff
    clc
    adc #6
    sec
    rts
!off5:
    eor #$ff
    clc
    adc #8
    clc
    rts