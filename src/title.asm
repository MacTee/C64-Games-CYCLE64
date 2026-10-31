// User-supplied packed assets, resident in VIC bank 2 ($8000-$bfff).
// Character rows 0-7 / bitmap rows 8-21 / character rows 22-24.
init_title:
    lda #0
    sta $d011
    sta title_irq_stage
    sta $d010
    sta $d01b
    sta $d01c
    ldx #0
!colors:
    .for(var p=0;p<3;p++) {
        lda title_colors+p*$100,x
        sta $d800+p*$100,x
    }
    lda title_colors+744,x
    sta $dae8,x
    inx
    bne !colors-
    // Catch phrase: "The facility forgets, but you remember" in row 6.
    // Extend the supplied font for the catch phrase and keyboard prompt.
    ldx #47
!glyph:
    lda tagline_glyphs,x
    sta $8800+$6c*8,x
    dex
    bpl !glyph-
    ldx #39
!tagline:
    lda tagline_codes,x
    sta $8000+6*40,x
    lda #14
    sta $d800+6*40,x
    dex
    bpl !tagline-
    // Replace the whole prompt row, including the original asset's wording.
    ldx #39
!prompt:
    lda prompt_codes,x
    sta $8000+22*40,x
    lda $d800+22*40+10
    sta $d800+22*40,x
    dex
    bpl !prompt-
    // Center the full author/tool credit in the existing bottom credit row.
    ldx #39
!creditGlyph:
    lda credit_glyphs,x
    sta $8800+$72*8,x
    dex
    bpl !creditGlyph-
    ldx #39
!credit:
    lda credit_codes,x
    sta $8000+24*40,x
    lda title_colors+24*40+15
    sta $d800+24*40,x
    dex
    bpl !credit-
    lda #$fe
    sta $83f8
    sta $87f8
    lda #$fd
    sta $83f9
    sta $87f9
    lda #160
    sta $d000
    sta $d002
    lda #174
    sta $d001
    sta $d003
    lda #7
    sta $d027
    lda #0
    sta $d028
    lda #3
    sta $d017
    sta $d01d
    sta $d015
    lda $dd00
    and #$fc
    ora #1
    sta $dd00
    lda #$02
    sta $d018
    lda #$08
    sta $d016
    lda #$1b
    sta $d011
    lda #$7f
    sta $dc0d
    lda $dc0d
    lda #<title_irq
    sta $0314
    lda #>title_irq
    sta $0315
    lda #112
    sta $d012
    lda #1
    sta $d019
    sta $d01a
    rts

render_title:
    // Raster IRQ presents the preloaded matrices. Never clear title colors.
    rts

// Keep the short polling loops on the same page: a taken branch crossing a
// page adds a cycle and would shift the boundary when unrelated code grows.
.align $100
title_irq:
    lda #1
    sta $d019
    lda title_irq_stage
    beq !middle+
    cmp #1
    beq !bottom+
    // Bottom border: restore top text for the next frame.
    lda #$02
    sta $d018
    lda #$08
    sta $d016
    lda #$1b
    sta $d011
    lda #0
    sta title_irq_stage
    lda #112
    sta $d012
    jsr sound_frame
    jmp $ea31 // KERNAL keyboard/jiffy once per PAL frame
!middle:
    lda #114
!waitMiddle:
    cmp $d012
    bne !waitMiddle-
    ldx #8
!delayMiddle:
    dex
    bne !delayMiddle-
    lda #$18
    sta $d018
    sta $d016
    lda #$3b
    sta $d011
    lda #1
    sta title_irq_stage
    lda #224
    sta $d012
    jmp $ea81
!bottom:
    ldy #$1b
    lda #226
!waitBottom:
    cmp $d012
    bne !waitBottom-
    ldx #10 // Keep the complete last bitmap scanline through the right edge.
!delayBottom:
    dex
    bne !delayBottom-
    // Change BMM before the next badline's fetch, after the previous line's
    // last visible pixel. Preloading Y saves the two critical setup cycles.
    sty $d011
    lda #$02
    sta $d018
    lda #$08
    sta $d016
    lda #2
    sta title_irq_stage
    lda #250
    sta $d012
    jmp $ea81

leave_title:
    sei
    lda #0
    sta $d015
    sta $d017
    sta $d01d
    lda #1
    sta $d019
    sta $d01a
    lda #250
    sta $d012
    lda #<music_irq
    sta $0314
    lda #>music_irq
    sta $0315
    lda $dc0d
    lda $dd00
    ora #3
    sta $dd00
    lda #$1c
    sta $d018
    lda #$08
    sta $d016
    // Blank until the first text page is drawn, so no title data flashes.
    lda #$0b
    sta $d011
    cli
    rts

// Title charset codes for the catch phrase, one row of 40 cells.
// T h e _ f a c i l i t y _ f o r g e t s , _ b u t _ y o u _ r e m e m b e r
tagline_codes:
    .byte $00
    .byte $6c,$6d,$55,$00
    .byte $51,$4b,$4c,$4d,$4e,$4d,$4f,$50,$00
    .byte $51,$52,$53,$54,$55,$4f,$56,$57,$00
    .byte $5a,$58,$4f,$00
    .byte $50,$52,$58,$00
    .byte $53,$55,$59,$55,$59,$5a,$55,$53
    .byte $00
.assert "Tagline fills one row", *-tagline_codes, 40
// "T" and "h" in the style of the supplied lowercase glyphs.
tagline_glyphs:
    .byte $7c,$10,$10,$10,$10,$10,$10,$00
    .byte $40,$40,$78,$44,$44,$44,$44,$00
    .byte $44,$64,$54,$4c,$44,$44,$44,$00 // N
    .byte $44,$44,$28,$10,$10,$10,$10,$00 // Y
    .byte $44,$48,$50,$60,$50,$48,$44,$00 // K
    .byte $3c,$40,$40,$40,$40,$40,$3c,$00 // C
// "PRESS SPACE TO START", centred in one row of title charset codes.
prompt_codes:
    .fill 10,0
    .byte $5f,$60,$61,$62,$62,$00,$62,$5f,$66,$71,$61,$00,$6c,$65,$00,$62,$6c,$66,$60,$6c
    .fill 10,0
.assert "Keyboard prompt fills one row", *-prompt_codes, 40

// By MacTee, Opus 5.5 & Sol 6.1: 29 cells, five left / six right padding.
credit_codes:
    .fill 5,0
    .byte $6a,$50,$00,$6b,$4b,$4c,$64,$55,$55,$57,$00
    .byte $65,$72,$58,$56,$00,$73,$5b,$73,$00,$74,$00
    .byte $62,$52,$4e,$00,$75,$5b,$76
    .fill 6,0
.assert "Credit fills one centered row", *-credit_codes, 40
credit_glyphs:
    .byte $00,$00,$78,$44,$78,$40,$40,$00 // p
    .byte $7c,$40,$78,$04,$04,$44,$38,$00 // 5
    .byte $30,$48,$50,$20,$54,$48,$34,$00 // &
    .byte $1c,$20,$40,$78,$44,$44,$38,$00 // 6
    .byte $10,$30,$10,$10,$10,$10,$38,$00 // 1
