sound_rewind:
    lda #12
    sta sound_timer
    lda #1
    sta sound_kind
    lda #15
    sta $d418
    lda #$00
    sta $d405
    lda #$a8
    sta $d406
    lda #$21
    sta $d404
    rts
sound_frame:
    lda sound_timer
    beq !music+
    lda sound_kind
    beq !timer+
    lda sound_timer
    asl
    sta $d401
    and #7
    sta $d020
!timer:
    dec sound_timer
    bne !music+
    lda #0
    sta $d020
    lda #$20
    sta $d404
    lda music_enabled
    beq !music+
    jsr music_restore_bass
!music:
    jmp music_frame

// Presentation consumes engine events; engine never touches SID or VIC.
sound_action:
    lda halt_reason
    cmp #HALT_CLOCK
    beq !done+
    cmp #HALT_END
    beq !done+
    lda action_error
    bne !error+
    lda delivery_event
    bne !delivery+
    lda active_op
    cmp #OP_PICK
    beq !pick+
    cmp #OP_SCAN
    beq !scan+
    cmp #OP_READ
    beq !read+
    cmp #OP_ACCESS
    beq !read+
    cmp #OP_LINK
    beq !read+
    cmp #OP_BOOST
    beq !move+
    cmp #4
    bcs !done+
!move:
    lda #8
    bne !play+
!error:
    lda #3
    bne !play+
!delivery:
    lda #48
    bne !play+
!pick:
    lda #24
    bne !play+
!scan:
    lda #16
    bne !play+
!read:
    lda #36
!play:
    tax
    lda #5
    sta sound_timer
    txa
    sta $d401
    lda #0
    sta sound_kind
    sta $d400
    sta $d405
    lda #$80
    sta $d406
    lda #$20
    sta $d404
    lda #$21
    sta $d404
    lda #15
    sta $d418
!done:
    rts

// Ending cues. The good ending is a long high tone. The bad ending is noise
// with the border flicker of the reset cue: the console loses the link.
sound_ending:
    lda #60
    sta sound_timer
    lda #15
    sta $d418
    lda #0
    sta $d400
    lda ending_kind
    bne !lost+
    lda #0
    sta sound_kind
    lda #$09
    sta $d405
    lda #$c9
    sta $d406
    lda #56
    sta $d401
    lda #$10
    sta $d404
    lda #$11
    sta $d404
    rts
!lost:
    lda #1
    sta sound_kind
    lda #$00
    sta $d405
    lda #$f9
    sta $d406
    lda #$80
    sta $d404
    lda #$81
    sta $d404
    rts
