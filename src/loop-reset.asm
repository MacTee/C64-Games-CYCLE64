// A lethal beam ends the loop before the player can retry or send another key.
reset_after_laser:
    lda #MODE_HALT
    sta mode
    lda #0
    sta help_open
    sta show_record
    sta $c6
    jsr reset_loop
    lda #PAGE_ROBOT_DESTROYED
    jmp show_reset_page

// The facility is already reset. Acknowledge without editing or resetting again.
dismiss_laser_notice:
    lda #0
    sta help_open
    jsr first_unread
    beq !done+
    stx view_rec
    lda #PAGE_RECORD
    sta help_open
!done:
    lda #DIRTY_ALL
    sta key_dirty
    rts

render_destroyed_title:
    lda help_open
    cmp #PAGE_ROBOT_DESTROYED
    bne !done+
    :TextAt(10,12,robot_destroyed_text,10)
!done:
    rts
robot_destroyed_text: .text "ROBOT DESTROYED"; .byte 0

render_reset_box:
    ldx #9
!row:
    jsr screen_position
    ldy #7
!column:
    lda #CHAR_HLINE
    cpx #9
    beq !paint+
    cpx #15
    beq !paint+
    lda #CHAR_VLINE
    cpy #7
    beq !paint+
    cpy #32
    beq !paint+
    lda #32
!paint:
    sta (screen_ptr),y
    lda #3
    sta (color_ptr),y
    iny
    cpy #33
    bne !column-
    inx
    cpx #16
    bne !row-
    jsr render_destroyed_title
    :TextAt(12,15,loop_reset_text,7)
    :TextAt(14,13,reset_key_text,12)
    rts
loop_reset_text: .text "LOOP RESET"; .byte 0
reset_key_text: .text "PRESS ANY KEY"; .byte 0

