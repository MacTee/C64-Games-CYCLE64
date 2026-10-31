// Mix v5, adapted from the supplied standalone player. PAL raster IRQ owns
// the clock; voice 1 belongs to effects while sound_timer is nonzero.
music_start:
music_init:
    lda #0
    ldx #7
!clear:
    sta music_state,x
    dex
    bpl !clear-
    sta $d417
    lda #1
    sta music_enabled
    sta music_note_clock
    sta music_arp_clock
    ldx #13
!setup:
    lda music_setup,x
    sta $d407,x
    dex
    bpl !setup-
    lda #15
    sta $d418
    rts

music_toggle:
    php
    sei
    lda music_enabled
    beq !on+
    lda #0
    sta music_enabled
    sta $d40b
    sta $d412
    lda sound_timer
    bne !done+
    lda #0
    sta $d404
    beq !done+
!on:
    jsr music_init
!done:
    plp
    rts

music_irq:
    lda #1
    sta $d019
    jsr sound_frame
    jmp $ea31

music_frame:
    lda music_enabled
    beq !done+
    lda music_drum_ticks
    beq !step+
    dec music_drum_ticks
    bne !step+
    jsr music_restore_bass
!step:
    dec music_note_clock
    bne !arp+
    lda #15
    sta music_note_clock
    jsr music_new_step
!arp:
    dec music_arp_clock
    bne !done+
    lda #5
    sta music_arp_clock
    jsr music_new_arp
!done:
    rts

music_new_step:
    ldx music_step
    stx music_active_step
    lda music_lead,x
    cmp #254
    beq !bass+
    tax
    lda #$40
    sta $d40b
    cpx #0
    beq !bass+
    lda music_freq_lo,x
    sta $d407
    lda music_freq_hi,x
    sta $d408
    lda #$41
    sta $d40b
!bass:
    lda music_active_step
    lsr
    bcs !drums+
    tax
    lda music_bass,x
    sta music_bass_note
    jsr music_restore_bass
!drums:
    lda music_active_step
    and #7
    cmp #4
    beq !hit+
    lda music_active_step
    and #31
    cmp #30
    bne !next+
!hit:
    jsr music_trigger_drum
!next:
    inc music_step
    lda music_step
    and #63
    sta music_step
    rts

music_trigger_drum:
    lda sound_timer
    bne !done+
    lda #3
    sta music_drum_ticks
    lda #$10
    sta $d404
    lda #$02
    sta $d405
    lda #$01
    sta $d406
    lda #0
    sta $d400
    lda #$48
    sta $d401
    lda #$81
    sta $d404
!done:
    rts

music_restore_bass:
    lda sound_timer
    bne !done+
    lda #0
    sta music_drum_ticks
    // Use triangle while retriggering: normal bass notes must not introduce
    // tiny noise bursts between the ten intentional drum accents.
    lda #$10
    sta $d404
    lda #$02
    sta $d405
    lda #$a5
    sta $d406
    ldx music_bass_note
    lda music_freq_lo,x
    sta $d400
    lda music_freq_hi,x
    sta $d401
    lda #$11
    sta $d404
!done:
    rts

music_new_arp:
    lda music_active_step
    lsr
    lsr
    lsr
    and #3
    sta music_chord
    asl
    clc
    adc music_chord
    clc
    adc music_arp_part
    tax
    lda music_arp,x
    tax
    lda music_freq_lo,x
    sta $d40e
    lda music_freq_hi,x
    sta $d40f
    inc music_arp_part
    lda music_arp_part
    cmp #3
    bcc !done+
    lda #0
    sta music_arp_part
!done:
    rts

music_setup:
    .byte 0,0,0,8,$40,$22,$84,0,0,0,6,$41,$12,$84
music_state:
music_note_clock: .byte 0
music_arp_clock: .byte 0
music_step: .byte 0
music_active_step: .byte 0
music_arp_part: .byte 0
music_chord: .byte 0
music_drum_ticks: .byte 0
music_bass_note: .byte 0
music_enabled: .byte 0

#import "data/music-v5.asm"
music_end:
.print "Mix v5 player/song/state: " + (music_end-music_start) + " bytes"
