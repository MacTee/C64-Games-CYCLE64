// Help-only rendering uses the spare space after the second story block.
navigate_help:
    ldx #2
!find:
    lda help_order,x
    cmp help_open
    beq !found+
    dex
    bpl !find-
    clc
    rts
!found:
    lda key
    cmp #29
    bne !left+
    lda help_next,x
    bne !store+
!left:
    lda help_prev,x
!store:
    sta help_open
    sec
    rts
help_order: .byte PAGE_EDITOR,PAGE_HELP,PAGE_LEGEND
help_next: .byte PAGE_HELP,PAGE_LEGEND,PAGE_EDITOR
help_prev: .byte PAGE_LEGEND,PAGE_EDITOR,PAGE_HELP

// Honor the help page's control bar. Briefings and ending pages keep their
// own input rules. Resuming a running program must not start a fresh loop.
help_shortcuts:
    lda help_open
    cmp #PAGE_EDITOR
    beq !help+
    cmp #PAGE_HELP
    beq !help+
    cmp #PAGE_LEGEND
    bne !ignore+
!help:
    lda key
    cmp #86
    beq !route+
    cmp #133
    beq !route+
    cmp #134
    beq !route+
    cmp #136
    bne !ignore+
!route:
    lda #0
    sta help_open
    sta intro
    lda key
    cmp #133
    bne !dispatch+
    lda mode
    cmp #MODE_RUN
    beq !done+
!dispatch:
    lda key
    jsr handle_key
!done:
    lda #DIRTY_ALL
    sta key_dirty
    sec
    rts
!ignore:
    clc
    rts

// X=row. Complete F-key tokens and standalone H/V get yellow ink.
highlight_control_row:
    jsr screen_position
    ldy #1
!char:
    lda (screen_ptr),y
    cmp #6
    bne !help+
    cpy #39
    beq !next+
    iny
    lda (screen_ptr),y
    cmp #49
    bcc !notKey+
    cmp #58
    bcs !notKey+
    lda #7
    sta (color_ptr),y
    dey
    sta (color_ptr),y
    iny
    bne !next+
!notKey:
    dey
    jmp !next+
!help:
    cmp #8
    beq !letter+
    cmp #22
    bne !next+
!letter:
    cpy #39
    beq !previous+
    iny
    lda (screen_ptr),y
    cmp #32
    beq !afterHelp+
    dey
    jmp !next+
!afterHelp:
    dey
!previous:
    dey
    lda (screen_ptr),y
    cmp #32
    beq !keyHelp+
    iny
    jmp !next+
!keyHelp:
    iny
    lda #7
    sta (color_ptr),y
!next:
    iny
    cpy #40
    bne !char-
    rts

draw_editor_help:
    :TextAt(4,3,eh_up,15)
    :TextAt(6,3,eh_key1,15)
    :TextAt(7,3,eh_key2,15)
    :TextAt(9,3,eh_param1,15)
    :TextAt(10,3,eh_param2,15)
    :TextAt(12,3,eh_insert,15)
    :TextAt(14,3,eh_delete,15)
    :TextAt(16,3,eh_next,15)
    :TextAt(19,3,eh_logs,15)
    :TextAt(21,2,hc_play,12)
    ldx #21
    jsr highlight_control_row
    :TextAt(4,25,editor_text,3)
    :TextAt(5,25,program_text,12)
    lda program_len
    ldx #5
    ldy #33
    jsr number_at
    // Help has a ten-row preview; keep its focus visible independently of
    // the game's twelve-row viewport without changing the editor scroll.
    lda scroll_top
    sta scratch+19
    jsr focus_line
    sec
    sbc scroll_top
    cmp #10
    bcc !preview+
    jsr focus_line
    sec
    sbc #9
    sta scratch+19
!preview:
    lda #0
    sta panel_line
!line:
    lda panel_line
    clc
    adc scratch+19
    sta panel_index
    lda panel_line
    clc
    adc #6
    sta render_row
    jsr buf_clear
    lda panel_index
    cmp #32
    bcs !print+
    clc
    adc #1
    jsr buf_num2
    lda #32
    jsr buf_char
    ldx panel_index
    cpx program_len
    bcs !empty+
    lda #0
    sta fmt_sub
    jsr buf_instr
    jmp !print+
!empty:
    :Append(rc_0)
!print:
    lda #38
    sta field_end
    ldx render_row
    ldy #25
    lda #12
    jsr print_buf
    jsr focus_line
    cmp panel_index
    bne !next+
    ldx render_row
    jsr screen_position
    ldy #25
!highlight:
    lda (screen_ptr),y
    ora #$80
    sta (screen_ptr),y
    lda #7
    sta (color_ptr),y
    iny
    cpy #38
    bne !highlight-
!next:
    inc panel_line
    lda panel_line
    cmp #10
    bne !line-
    ldx #16
    jsr screen_position
    ldy #25
!rule:
    lda #CHAR_HLINE
    sta (screen_ptr),y
    lda #12
    sta (color_ptr),y
    iny
    cpy #38
    bne !rule-
    rts
