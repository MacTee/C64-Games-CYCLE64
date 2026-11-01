// CYCLE 64 - Character graphics, dirty-region redraws, text formatting and modal screens.

// Copy the character ROM into RAM and install the custom runtime glyphs.
// Precondition: IRQs disabled. Temporarily banks character ROM with $01 = $33, then restores $37.
// Clobbers: A/X and flags; copies into the runtime charset at $3000..$37ff.
init_charset:
{
    lda #$33
    sta $01
    ldx #0
    !copy:
    .for (var p = 0; p < 8; p++)
    {
        lda $d000+p*$100, x
        sta $3000+p*$100, x
    }
    inx
    bne !copy-
    lda #$37
    sta $01
    // Tile glyphs replace the unused PETSCII graphics in characters 64-127.
    // Characters 128-191 stay reverse text for the highlight bar.
    ldx #0
    !custom:
    lda tile_graphics, x
    sta $3200, x
    lda tile_graphics+$100, x
    sta $3300, x
    inx
    bne !custom-
    ldx #(line_graphics_end-line_graphics-1)
    !lines:
    lda line_graphics, x
    sta $3600, x
    dex
    bpl !lines-
    // Tiles 16-23 in characters 208-239.
    ldx #0
    !story:
    lda tile_graphics2, x
    sta $3680, x
    inx
    bne !story-
    // The north/south exit (tile 24) in characters 240-243.
    ldx #127
    !exit:
    lda tile_exit_v, x
    sta $3780, x
    dex
    bpl !exit-
    rts
}

// Redraws only the regions flagged in dirty. Each region overwrites its own
// cells in place, so the screen is cleared only for DIRTY_FULL.
render:
{
    lda mode
    cmp #MODE_TITLE
    bne !help+
    jmp render_title
    !help:
    lda help_open
    cmp #PAGE_LOOP_RESET
    beq !resetBox+
    cmp #PAGE_ROBOT_DESTROYED
    bne !textPage+
    !resetBox:
    // Keep the modal active throughout the background redraw.
    jsr render_game
    jmp render_reset_box
    !textPage:
    lda help_open
    beq render_game
    lda dirty
    bmi !page+
    // An edit in the image editor redraws its slots without a clear.
    and #DIRTY_SLOTS
    beq !done+
    lda help_open
    cmp #PAGE_IMAGE
    bne !done+
    jmp image_slots
    !page:
    jsr clear_screen
    jmp render_page
    !done:
    rts
}

// Redraw the selected game regions and update the clock blink.
render_game:
{
    lda mode
    beq !full+
    lda robot_room
    sta view_room
    !full:
    lda dirty
    bpl !header+
    jsr clear_screen
    jsr render_frame
    lda #$1b
    sta $d011
    lda #DIRTY_PARTS
    sta dirty
    !header:
    lda dirty
    and #DIRTY_HEADER
    beq !map+
    jsr render_header
    !map:
    lda dirty
    and #DIRTY_MAP
    beq !program+
    jsr render_map
    !program:
    lda dirty
    and #DIRTY_PROGRAM
    beq !info+
    jsr render_program
    !info:
    lda dirty
    and #DIRTY_INFO
    beq !footer+
    jsr render_info
    !footer:
    lda dirty
    and #DIRTY_FOOTER
    beq !blink+
    jsr render_footer
    !blink:
    jmp clock_blink
}

// Static labels and rules. Values inside the labels are written later.
render_frame:
{
    :TextAt(0, 1, title_text, 3)
    :TextAt(0, 11, sector_text, 12)
    :TextAt(0, 23, clock_text, 10)
    ldx #38
    !rule:
    lda #CHAR_HLINE
    sta $0400+40, x
    lda #12
    sta $d800+40, x
    dex
    bne !rule-
    ldx #3
    !column:
    jsr screen_position
    ldy #25
    lda #CHAR_VLINE
    sta (screen_ptr), y
    lda #12
    sta (color_ptr), y
    inx
    cpx #23
    bne !column-
    :TextAt(2, 30, loop_text, 12)
    :TextAt(3, 27, editor_text, 3)
    :TextAt(4, 27, program_text, 15)
    // Twelve editor rows followed by the compact inventory panel.
    ldx #12
    !panelRule:
    lda #CHAR_HLINE
    sta $0400+17*40+27, x
    lda #12
    sta $d800+17*40+27, x
    dex
    bpl !panelRule-
    rts
}

// Draw sector, cycle, power and loop information above the map.
render_header:
{
    ldx view_room
    lda #48
    sta $0400+18
    lda room_sector, x
    ora #%00110000
    sta $0400+19
    lda #64
    sec
    sbc elapsed
    ldx #0
    ldy #35
    jsr number_at
    ldx view_room
    lda room_name_lo, x
    sta text_ptr
    lda room_name_hi, x
    sta text_ptr+1
    lda #29
    sta field_end
    ldx #2
    ldy #1
    lda #15
    jsr print_field
    jsr grid_status
    lda loop_count
    ldx #2
    ldy #35
    jmp number_at
}

// In a room with a laser grid: "GRID ON  3" after the room name, the phase
// and the cycles until it changes.
grid_status:
{
    ldx view_room
    lda room_has_grid, x
    beq !done+
    cpx #6
    bne !single+
    :TextAt(2, 17, cooling_grids_text, 12)
    rts
    !single:
    jsr buf_clear
    jsr laser_cycle
    ldx view_room
    ldy render_y
    jsr laser_phase
    pha
    bcs !on+
    :Append(grid_off_text)
    lda #12
    bne !count+
    !on:
    :Append(grid_on_text)
    lda #2
    !count:
    sta text_color
    pla
    jsr buf_num
    lda #29
    sta field_end
    ldx #2
    ldy #17
    lda text_color
    jmp print_buf
    !done:
    rts
}

// Returns A = the cycle whose laser phase the map shows: the next cycle, or
// the cycle that failed when a laser stopped the robot.
laser_cycle:
{
    lda mode
    cmp #MODE_HALT
    bne !next+
    lda halt_reason
    cmp #HALT_LASER
    bne !next+
    lda elapsed
    sec
    sbc #1
    rts
    !next:
    lda elapsed
    rts
}

// Flashes the cycle counter when 12 or fewer cycles remain.
// On a text page, flashes the terminal cursor instead.
clock_blink:
{
    lda mode
    cmp #MODE_TITLE
    beq !done+
    lda help_open
    cmp #PAGE_LOOP_RESET
    bcs !done+
    lda help_open
    beq !clock+
    !cursor:
    ldx cursor_row
    beq !done+
    jsr screen_position
    ldy cursor_col
    lda #14
    sta (color_ptr), y
    lda blink_count
    and #%00010000
    beq !off+
    lda #CHAR_CURSOR
    sta (screen_ptr), y
    rts
    !off:
    lda #32
    sta (screen_ptr), y
    rts
    !clock:
    jsr objective_blink
    lda #64
    sec
    sbc elapsed
    cmp #13
    bcs !calm+
    lda blink_count
    and #%00010000
    beq !calm+
    lda #1
    bne !paint+
    !calm:
    lda #10
    !paint:
    ldx #16
    !cell:
    sta $d800+23, x
    dex
    bpl !cell-
    !done:
    rts
}

// The planning map marks the workshop programmer while the chip objective is
// open: it flashes white in room B (screen rows 9-10, columns 3-4).
objective_blink:
{
    lda mode
    bne !done+
    lda view_room
    cmp #1
    bne !done+
    lda story_flags
    and #(FLAG_OBJECTIVE+FLAG_SECURED)
    cmp #FLAG_OBJECTIVE
    bne !done+
    lda blink_count
    and #%00010000
    beq !calm+
    lda #1
    bne !paint+
    !calm:
    lda #13
    !paint:
    sta $d800+9*40+3
    sta $d800+9*40+4
    sta $d800+10*40+3
    sta $d800+10*40+4
    !done:
    rts
}

// Clear screen RAM and initialize all character colors.
clear_screen:
{
    ldx #0
    !loop:
    lda #32
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #15
    sta $d800, x
    sta $d900, x
    sta $da00, x
    sta $db00, x
    inx
    bne !loop-
    rts
}

// X=row, Y=col. Text uses zero-terminated C64 screen codes.
// Input: X = 0..24; Y = column (preserved). Returns row-base pointers.
// Clobbers: A and flags; writes screen_ptr/color_ptr ($fb..$fe).
screen_position:
{
    lda screen_lo, x
    sta screen_ptr
    sta color_ptr
    lda screen_hi, x
    sta screen_ptr+1
    clc
    adc #$d4
    sta color_ptr+1
    rts
}

// Returns Y = number of characters printed.
// Input: text_ptr = screen-code string; X/Y = row/column; A = color.
// Returns: Y = printed length. Clobbers: A, flags, screen_ptr/color_ptr, text_color.
print_at:
{
    sta text_color
    jsr screen_position
    tya
    clc
    adc screen_ptr
    sta screen_ptr
    sta color_ptr
    bcc !start+
    inc screen_ptr+1
    inc color_ptr+1
    !start:
    ldy #0
    !loop:
    lda (text_ptr), y
    beq !done+
    sta (screen_ptr), y
    lda text_color
    sta (color_ptr), y
    iny
    bne !loop-
    !done:
    rts
}

// X=row, Y=col, A=colour, field_end=first column after the field.
// Prints text_ptr, then spaces to field_end.
print_field:
{
    sta text_color
    sty field_col
    lda field_end
    sec
    sbc field_col
    sta field_width
    lda text_color
    jsr print_at
    !pad:
    cpy field_width
    bcs !done+
    lda #32
    sta (screen_ptr), y
    lda text_color
    sta (color_ptr), y
    iny
    bne !pad-
    !done:
    rts
}

// Prints msg_buf as a field. Same arguments as print_field.
print_buf:
{
    pha
    :Ptr(msg_buf)
    pla
    jmp print_field
}

// Print A = 0..99 as two screen-code digits at row X, column Y.
number_at:
{
    sta number_temp
    jsr screen_position
    ldx #0
    !tens:
    lda number_temp
    cmp #10
    bcc !write+
    sec
    sbc #10
    sta number_temp
    inx
    bne !tens-
    !write:
    txa
    clc
    adc #48
    sta (screen_ptr), y
    iny
    lda number_temp
    clc
    adc #48
    sta (screen_ptr), y
    rts
}

// Text builder for msg_buf. Every append keeps a zero terminator.
buf_clear:
{
    lda #0
    sta buf_pos
    sta msg_buf
    rts
}

// A=screen code. Preserves Y.
// Input: A = screen code; caller must leave room for a byte and terminator.
// Returns: A = 0, X = new buffer length; preserves Y. Writes buf_pos/msg_buf.
buf_char:
{
    ldx buf_pos
    sta msg_buf, x
    inx
    lda #0
    sta msg_buf, x
    stx buf_pos
    rts
}

// Append zero-terminated text_ptr to the current message buffer.
buf_text:
{
    ldy #0
    !loop:
    lda (text_ptr), y
    beq !done+
    jsr buf_char
    iny
    bne !loop-
    !done:
    rts
}

// A=0..99. Two digits.
buf_num2:
{
    jsr split_tens
    pha
    txa
    clc
    adc #48
    jsr buf_char
    pla
    clc
    adc #48
    jmp buf_char
}

// A=0..99. No leading zero.
buf_num:
{
    jsr split_tens
    pha
    txa
    beq !ones+
    clc
    adc #48
    jsr buf_char
    !ones:
    pla
    clc
    adc #48
    jmp buf_char
}

// A in. Returns X=tens, A=ones.
// Input: A = 0..99. Returns: A = ones, X = tens; preserves Y. Flags clobbered.
// CMP establishes carry before SBC in the subtraction loop; decimal mode must be clear.
split_tens:
{
    ldx #0
    !loop:
    cmp #10
    bcc !done+
    sbc #10
    inx
    bne !loop-
    !done:
    rts
}

// X=program line, fmt_sub=substep to show (0 = none).
// Appends e.g. "EAST 5", "EAST 3/5", "PICK E", "SCAN 1/2". Max 10 characters.
buf_instr:
{
    stx fmt_index
    lda program_op, x
    cmp #OP_EMPTY
    bne !command+
    :Append(rc_0)
    rts
    !command:
    sta fmt_op
    cmp #OP_BOOST
    bne !move+
    jmp buf_boost
    !move:
    cmp #4
    bcs !name+
    // NORTH/SOUTH with a two-digit substep do not fit: use the letter.
    and #%00000001
    bne !name+
    lda fmt_sub
    cmp #10
    bcc !name+
    ldx fmt_op
    lda direction_chars, x
    jsr buf_char
    jmp !args+
    !name:
    lda fmt_op
    jsr buf_op_name
    !args:
    lda fmt_op
    cmp #4
    bcc !count+
    cmp #OP_WAIT
    beq !count+
    cmp #OP_SCAN
    beq !scan+
    lda #32
    jsr buf_char
    ldx fmt_index
    lda program_dir, x
    tax
    lda direction_chars, x
    jmp buf_char
    !scan:
    lda fmt_sub
    beq !done+
    lda #32
    jsr buf_char
    lda fmt_sub
    jsr buf_num
    lda #47
    jsr buf_char
    lda #2
    jmp buf_num
    !count:
    lda #32
    jsr buf_char
    lda fmt_sub
    beq !total+
    jsr buf_num
    lda #47
    jsr buf_char
    !total:
    ldx fmt_index
    lda program_arg, x
    jmp buf_num
    !done:
    rts
}

// "BOOST E 5", and while it runs "BST E3/5" or "BST E12/15".
buf_boost:
{
    lda fmt_sub
    bne !short+
    :Append(nm_boost)
    jmp !dir+
    !short:
    :Append(nm_bst)
    !dir:
    lda #32
    jsr buf_char
    ldx fmt_index
    lda program_dir, x
    tax
    lda direction_chars, x
    jsr buf_char
    lda fmt_sub
    bne !sub+
    lda #32
    jsr buf_char
    jmp !total+
    !sub:
    jsr buf_num
    lda #47
    jsr buf_char
    !total:
    ldx fmt_index
    lda program_arg, x
    jmp buf_num
}

// A=opcode. Appends its long name.
buf_op_name:
{
    asl
    tax
    lda op_long, x
    sta text_ptr
    lda op_long+1, x
    sta text_ptr+1
    jmp buf_text
}

// Returns A=1 (Z clear) when the run halted on a failure.
run_failed:
{
    lda mode
    cmp #MODE_HALT
    bne !no+
    ldx halt_reason
    lda halt_is_failure, x
    rts
    !no:
    lda #0
    rts
}

// Returns A=1 (Z clear) while a run waits at the program end for new lines.
end_pause:
{
    lda mode
    cmp #MODE_STEP
    bne !no+
    lda halt_reason
    cmp #HALT_END
    beq !yes+
    cmp #HALT_EDIT
    bne !no+
    !yes:
    lda #1
    rts
    !no:
    lda #0
    rts
}

// Returns A = highlighted line: the editor cursor in PLAN and at the program
// end pause, else the instruction pointer.
focus_line:
{
    lda mode
    beq !cursor+
    jsr end_pause
    bne !cursor+
    lda ip
    rts
    !cursor:
    lda cursor
    rts
}

// Draw known and currently visible room tiles, cargo and the robot.
render_map:
{
    jsr room_powered
    sta map_powered
    lda #0
    sta render_index
    sta render_y
    !row:
    lda #0
    sta render_x
    !tile:
    ldx view_room
    lda live_lo, x
    sta data_ptr
    lda live_hi, x
    sta data_ptr+1
    ldy render_index
    lda (data_ptr), y
    sta render_tile
    tax
    lda tile_colors, x
    sta render_color
    // A delivered cell powers its room for this loop: equipment lights up.
    jsr map_tile_lit
    beq !unlit+
    lda tile_lit, x
    beq !unlit+
    sta render_color
    !unlit:
    cpx #TILE_WALL
    bne !discovery+
    // Every third wall diagonal is a light blue pillar.
    lda render_x
    clc
    adc render_y
    !mod3:
    cmp #3
    bcc !pillar+
    sbc #3
    jmp !mod3-
    !pillar:
    cmp #0
    bne !discovery+
    lda #14
    sta render_color
    !discovery:
    ldx view_room
    lda discovery_lo, x
    sta data_ptr
    lda discovery_hi, x
    sta data_ptr+1
    ldy render_index
    lda (data_ptr), y
    bne !known+
    lda #TILE_FOG
    sta render_tile
    lda #11
    sta render_color
    jmp !draw+
    !known:
    jsr mask_tile
    jsr equipment_live_color
    ldy render_index
    lda view_room
    cmp robot_room
    bne !dim+
    lda visible_now, y
    bne !entities+
    !dim:
    // Remembered geometry keeps its colour. Remembered floor is dim.
    // Cargo shows only as a dim marker at its known start position, and only
    // while it is still there in this loop: a picked or moved cell has none.
    lda render_tile
    bne !source+
    lda #11
    sta render_color
    !source:
    ldx #CARGO_COUNT-1
    !sourceLoop:
    lda cargo_room, x
    cmp view_room
    bne !nextSource+
    lda cargo_x, x
    cmp render_x
    bne !nextSource+
    lda cargo_y, x
    cmp render_y
    bne !nextSource+
    jsr cargo_tile
    sta render_tile
    lda #11
    sta render_color
    !nextSource:
    dex
    bpl !sourceLoop-
    jmp !parked+
    !entities:
    ldx #CARGO_COUNT-1
    !cargo:
    lda cargo_room, x
    cmp view_room
    bne !next+
    lda cargo_x, x
    cmp render_x
    bne !next+
    lda cargo_y, x
    cmp render_y
    bne !next+
    jsr cargo_tile
    sta render_tile
    lda cargo_color, x
    sta render_color
    !next:
    dex
    bpl !cargo-
    lda robot_room
    cmp view_room
    bne !parked+
    lda robot_x
    cmp render_x
    bne !parked+
    lda robot_y
    cmp render_y
    bne !parked+
    lda #TILE_ROBOT
    ldx held
    cpx #255
    beq !robot+
    lda #TILE_ROBOT_CELL
    !robot:
    sta render_tile
    lda #7
    sta render_color
    jmp !mark+
    !parked:
    // The parked robot (the vault unit, or robot A after a LINK) is grey.
    lda other_room
    cmp view_room
    bne !mark+
    lda other_x
    cmp render_x
    bne !mark+
    lda other_y
    cmp render_y
    bne !mark+
    lda #TILE_ROBOT
    sta render_tile
    lda #15
    sta render_color
    !mark:
    // The tile that caused a failure is light red until the halt is acknowledged.
    jsr run_failed
    beq !draw+
    ldx halt_reason
    lda halt_marks, x
    beq !draw+
    lda fail_room
    cmp view_room
    bne !draw+
    lda fail_x
    cmp render_x
    bne !draw+
    lda fail_y
    cmp render_y
    bne !draw+
    lda #10
    sta render_color
    !draw:
    // An exit in the top or bottom row points up and down.
    lda render_tile
    cmp #TILE_EXIT
    bne !place+
    lda render_y
    beq !vertical+
    cmp #9
    bne !place+
    !vertical:
    lda #TILE_EXIT_V
    sta render_tile
    !place:
    lda render_y
    asl
    clc
    adc #3
    tax
    lda render_x
    asl
    clc
    adc #1
    tay
    jsr draw_tile
    inc render_index
    inc render_x
    lda render_x
    cmp #12
    beq !rowDone+
    jmp !tile-
    !rowDone:
    inc render_y
    lda render_y
    cmp #10
    beq !done+
    jmp !row-
    !done:
    rts
}

// Known tile: an undiscovered hidden device shows as a sealed panel, and a
// laser shows its state for the cycle from laser_cycle.
mask_tile:
{
    lda render_tile
    cmp #TILE_LASER
    beq !laser+
    cmp #TILE_LASER_V
    beq !laser+
    cmp #TILE_TERMINAL
    beq !hidden+
    cmp #TILE_HATCH
    bne !done+
    !hidden:
    ldx #DEV_COUNT-1
    !device:
    lda dev_room, x
    cmp view_room
    bne !next+
    lda dev_index, x
    cmp render_index
    beq !found+
    !next:
    dex
    bpl !device-
    rts
    !found:
    lda dev_hidden, x
    beq !done+
    lda dev_found, x
    bne !done+
    lda #TILE_PANEL
    sta render_tile
    lda tile_colors+TILE_PANEL
    sta render_color
    !done:
    rts
    !laser:
    jsr laser_cycle
    ldx view_room
    ldy render_y
    jsr laser_phase
    bcs !done-
    lda render_tile
    cmp #TILE_LASER_V
    beq !vertical+
    lda #TILE_LASER_OFF
    bne !off+
    !vertical:
    lda #TILE_LASER_V_OFF
    !off:
    sta render_tile
    lda #11
    sta render_color
    rts
}

// A loaded socket uses a combined socket-and-cell drawing, including on the map.
cargo_tile:
{
    lda render_tile
    cmp #TILE_SOCKET
    bne !loose+
    cpx #CARGO_CHIP
    beq !loose+
    lda #TILE_SOCKET_CELL
    rts
    !loose:
    lda cargo_glyph, x
    rts
}

// X=screen row, Y=screen column of the top-left character.
// Draws render_tile in render_color as 2x2 characters.
// Tiles 0-15 use characters 64-127, tiles 16-23 use characters 208-239.
draw_tile:
{
    jsr screen_position
    lda render_tile
    asl
    asl
    clc
    adc #64
    ldx render_tile
    cpx #16
    bcc !low+
    adc #79                                                 // Carry is set: +80.
    !low:
    sta tile_char
    sta (screen_ptr), y
    clc
    adc #1
    iny
    sta (screen_ptr), y
    lda render_color
    sta (color_ptr), y
    dey
    sta (color_ptr), y
    lda screen_ptr
    clc
    adc #40
    sta screen_ptr
    sta color_ptr
    bcc !bottom+
    inc screen_ptr+1
    inc color_ptr+1
    !bottom:
    lda tile_char
    clc
    adc #2
    sta (screen_ptr), y
    clc
    adc #1
    iny
    sta (screen_ptr), y
    lda render_color
    sta (color_ptr), y
    dey
    sta (color_ptr), y
    rts
}

// Twelve visible lines in rows 5-16. Format "NN NAME ARG", max 13 columns.
render_program:
{
    lda program_len
    ldx #4
    ldy #35
    jsr number_at
    lda mode
    beq !lines+
    jsr end_pause
    bne !lines+
    lda ip
    cmp #12
    bcc !first+
    sbc #11
    jmp !scroll+
    !first:
    lda #0
    !scroll:
    sta scroll_top
    !lines:
    lda #0
    sta panel_line
    !line:
    lda panel_line
    clc
    adc scroll_top
    sta panel_index
    lda panel_line
    clc
    adc #5
    sta render_row
    jsr buf_clear
    lda panel_index
    cmp #32
    bcs !blank+
    clc
    adc #1
    jsr buf_num2
    lda #32
    jsr buf_char
    ldx panel_index
    cpx program_len
    bcs !empty+
    jsr line_substep
    ldx panel_index
    jsr buf_instr
    lda #15
    bne !print+
    !empty:
    lda #45
    jsr buf_char
    lda #45
    jsr buf_char
    !blank:
    lda #12
    !print:
    ldx #40
    stx field_end
    ldx render_row
    ldy #27
    jsr print_buf
    jsr focus_line
    cmp panel_index
    bne !next+
    ldx render_row
    jsr highlight_row
    !next:
    inc panel_line
    lda panel_line
    cmp #12
    beq !done+
    jmp !line-
    !done:
    rts
}

// Sets fmt_sub to the substep when panel_index is the executing line.
line_substep:
{
    lda #0
    sta fmt_sub
    lda mode
    beq !done+
    lda panel_index
    cmp ip
    bne !done+
    lda cycles_left
    bne !show+
    jsr run_failed
    beq !done+
    !show:
    lda substep
    sta fmt_sub
    !done:
    rts
}

// X=row. Reverse bar over columns 27-39: yellow, or light red after a failure.
highlight_row:
{
    jsr screen_position
    jsr run_failed
    beq !normal+
    lda #10
    bne !colour+
    !normal:
    lda #7
    !colour:
    sta text_color
    ldy #27
    !bar:
    lda (screen_ptr), y
    ora #%10000000
    sta (screen_ptr), y
    lda text_color
    sta (color_ptr), y
    iny
    cpy #40
    bne !bar-
    rts
}

// Compact panel below the twelve-line editor.
render_info:
{
    jsr buf_clear
    :Append(hud_logs)
    jsr count_records
    jsr buf_num2
    :Append(hud_log_total)
    ldx #18
    jsr hud_print
    jsr buf_clear
    :Append(hud_codes)
    lda credentials
    ldx #3
    ldy #0
    !bit:
    lsr
    bcc !next+
    iny
    !next:
    dex
    bne !bit-
    tya
    jsr buf_num2
    :Append(hud_code_total)
    ldx #19
    jsr hud_print
    jsr buf_clear
    :Append(fw_text)
    ldx #0
    !fw:
    lda firmware
    and bit_mask, x
    beq !noFw+
    lda fw_letters, x
    jsr buf_char_x
    !noFw:
    inx
    cpx #3
    bne !fw-
    ldx #20
    jsr hud_print
    jsr buf_clear
    :Append(hud_inv)
    ldx #0
    lda held
    cmp #255
    beq !cargo+
    inx
    cmp #CARGO_CHIP
    bne !cargo+
    inx
    lda chip_state
    beq !cargo+
    inx
    !cargo:
    lda cargo_text_lo, x
    sta text_ptr
    lda cargo_text_hi, x
    sta text_ptr+1
    jsr buf_text
    ldx #21
}

// Print the current HUD buffer at its selected panel row.
hud_print:
{
    lda #40
    sta field_end
    ldy #27
    lda #13
    jmp print_buf
}

// buf_char, but preserves X.
buf_char_x:
{
    stx number_temp
    jsr buf_char
    ldx number_temp
    rts
}

// Build the full access-code names in story order for text-buffer callers.
// The compact HUD counts credentials separately; this helper emits their names.
build_codes:
{
    jsr buf_clear
    :Append(hud_codes)
    ldx #0
    !code:
    stx scratch+15
    lda credentials
    and code_bits, x
    beq !next+
    lda code_names_lo, x
    sta text_ptr
    lda code_names_hi, x
    sta text_ptr+1
    jsr buf_text
    lda #32
    jsr buf_char
    !next:
    ldx scratch+15
    inx
    cpx #3
    bne !code-
    rts
}

code_bits:
    .byte CRED_ORBIT, CRED_ZENITH, CRED_VECTOR
code_names_lo:
    .byte <code_orbit, <code_zenith, <code_vector
code_names_hi:
    .byte >code_orbit, >code_zenith, >code_vector
// Returns A = number of stored facility logs (excludes Command transmissions).
count_records:
{
    lda #0
    ldx #LOG_COUNT
    !loop:
    ldy rec_known, x
    beq !next+
    clc
    adc #1
    !next:
    dex
    bne !loop-
    rts
}

// Row 23: failure (full width), or event / delivery / mission plus status.
render_footer:
{
    jsr render_controls
    jsr run_failed
    beq !normal+
    jsr build_failure
    lda #40
    sta field_end
    ldx #23
    ldy #1
    lda #10
    jmp print_buf
    !normal:
    // READ resolves after two cycles. Do not leave a previous offline/event
    // message on screen while the first half of the current READ is pending.
    lda halt_reason
    bne !paused+
    lda active_op
    cmp #OP_READ
    bne !paused+
    lda cycles_left
    cmp #1
    bne !paused+
    jsr buf_clear
    :Append(reading_text)
    lda #3
    jmp !left+
    !paused:
    jsr end_pause
    beq !messages+
    lda halt_reason
    cmp #HALT_EDIT
    bne !endProgram+
    jsr buf_clear
    :Append(edit_pause_text)
    lda #13
    jmp !left+
    !endProgram:
    // A message from the last executed cycle has priority over the hint.
    lda msg_fresh
    bne !runMsg+
    jsr buf_clear
    // All 32 lines used: no line can be added.
    lda program_len
    cmp #32
    bcs !full+
    :Append(end_program_text)
    lda #13
    jmp !left+
    !full:
    :Append(full_program_text)
    lda #10
    jmp !left+
    !messages:
    lda mode
    beq !mission+
    !runMsg:
    lda run_msg
    cmp #1
    beq !event+
    cmp #2
    beq !delivery+
    !mission:
    jsr buf_clear
    lda #13
    jmp !left+
    !event:
    jsr buf_clear
    lda knowledge_event
    cmp #EV_ROOM
    bne !record+
    // First visit: "JUNCTION: THE GRID IS HUMMING"
    ldx event_arg
    lda arrival_lo, x
    sta text_ptr
    lda arrival_hi, x
    sta text_ptr+1
    jsr buf_text
    lda #3
    jmp !left+
    !record:
    cmp #EV_INSPECT
    bne !log+
    lda event_arg
    asl
    tax
    lda inspection_names, x
    sta text_ptr
    lda inspection_names+1, x
    sta text_ptr+1
    jsr buf_text
    lda #13
    jmp !left+
    !log:
    cmp #EV_RECORD
    bne !named+
    // "SECURITY RECORD STORED"
    ldx event_arg
    lda rec_title_lo, x
    sta text_ptr
    lda rec_title_hi, x
    sta text_ptr+1
    jsr buf_text
    :Append(stored_text)
    lda #13
    jmp !left+
    !named:
    asl
    tax
    lda event_names, x
    sta text_ptr
    lda event_names+1, x
    sta text_ptr+1
    jsr buf_text
    lda #13
    jmp !left+
    !delivery:
    jsr build_delivery
    lda #7
    !left:
    // Messages use columns 1-29. Column 30 stays a gap before the status.
    ldx #31
    stx field_end
    ldx #23
    ldy #1
    jsr print_buf
    jsr status_text
    ldx #40
    stx field_end
    ldx #23
    ldy #31
    jmp print_field
}

// Row 24 names the keys that work now. A running program cannot be edited,
// and a halted loop resets with RETURN.
render_controls:
{
    lda mode
    beq !plan+
    cmp #MODE_HALT
    beq !halt+
    jsr end_pause
    bne !plan+
    :Ptr(ctl_run)
    lda #15
    bne !print+
    !halt:
    jsr can_retry_halt
    beq !finished+
    :Ptr(ctl_error)
    jmp !gray+
    !finished:
    :Ptr(ctl_halt)
    lda #15
    bne !print+
    !plan:
    :Ptr(controls_text)
    lda #15
    !print:
    !gray:
    // Highlight key tokens after printing the descriptions in gray.
    lda #12
    ldx #40
    stx field_end
    ldx #24
    ldy #1
    jsr print_field
    ldx #24
    jmp highlight_control_row
}

// Sets text_ptr to the status word. Returns A = colour.
// PLAN shows no word, except MAP while another room is browsed.
// After M: ONLY ROOM (no other room known) or PLAN ONLY (not in PLAN).
status_text:
{
    lda map_note
    cmp #2
    bne !mode0+
    :Ptr(st_plan_only)
    lda #7
    rts
    !mode0:
    lda mode
    beq !plan+
    lda new_best
    beq !mode+
    :Ptr(st_best)
    lda #7
    rts
    !mode:
    lda mode
    cmp #MODE_RUN
    bne !step+
    :Ptr(st_run)
    lda #3
    rts
    !step:
    cmp #MODE_STEP
    bne !halt+
    jsr end_pause
    bne !paused+
    :Ptr(st_step)
    lda #3
    rts
    !paused:
    :Ptr(st_paused)
    lda #3
    rts
    !halt:
    :Ptr(st_loop_end)
    lda #3
    rts
    !plan:
    lda map_note
    beq !browse+
    :Ptr(st_one_room)
    lda #7
    rts
    !browse:
    lda view_room
    cmp robot_room
    beq !ready+
    :Ptr(st_map)
    lda #3
    rts
    !ready:
    :Ptr(empty_text)
    lda #3
    rts
}

// Completion notice for the mission just recorded.
build_delivery:
{
    jsr buf_clear
    lda #13
    jsr buf_char
    lda last_delivery
    clc
    adc #1
    jsr buf_num
    // The lights come on in the Dock: "M1 AZIZ, LIGHT! 09C 07L".
    lda last_delivery
    bne !plain+
    :Append(aziz_text)
    jmp !cycles+
    !plain:
    :Append(delivered_text)
    !cycles:
    lda last_delivery_cycle
    jsr buf_num2
    :Append(t_space)
    lda run_lines
    jsr buf_num2
    lda #12
    jmp buf_char
}

// "LINE 04: WALL AT EAST 4/5", "LINE 02: PICK W: NO CARGO".
// The cycle budget is not a line error: "NO CYCLES LEFT - RETURN RESETS".
build_failure:
{
    jsr buf_clear
    lda halt_reason
    cmp #HALT_CLOCK
    bne !action+
    :Append(clock_fail_text)
    rts
    !action:
    :Append(line_text)
    lda ip
    clc
    adc #1
    jsr buf_num2
    :Append(colon_text)
    lda active_op
    cmp #OP_BOOST
    beq !moving+
    cmp #4
    bcs !interaction+
    !moving:
    // A move names the cause first, then the line with its substep.
    ldx fail_tile
    lda move_block_text, x
    asl
    tax
    lda move_block_names, x
    sta text_ptr
    lda move_block_names+1, x
    sta text_ptr+1
    jsr buf_text
    !at:
    :Append(at_text)
    lda substep
    sta fmt_sub
    ldx ip
    jmp buf_instr
    !interaction:
    lda #0
    sta fmt_sub
    ldx ip
    jsr buf_instr
    :Append(colon_text)
    lda halt_reason
    asl
    tax
    lda fail_names, x
    sta text_ptr
    lda fail_names+1, x
    sta text_ptr+1
    jmp buf_text
}

// Text page help_open on the terminal screen: heading, rule, body and the
// input hint below the casing. Unblanks the display that leave_title blanked.
render_page:
{
    jsr draw_terminal
    ldx #35
    !rule:
    lda #CHAR_HLINE
    sta $0400+80+2, x
    lda #6
    sta $d800+80+2, x
    dex
    bpl !rule-
    lda #0
    sta cursor_row
    lda #3
    sta render_row
    lda help_open
    cmp #PAGE_RECORD
    bne !image+
    jmp render_record
    !image:
    cmp #PAGE_IMAGE
    bne !static+
    jmp render_image
    !static:
    ldx help_open
    lda page_head_lo-1, x
    sta text_ptr
    lda page_head_hi-1, x
    sta text_ptr+1
    lda page_head_color-1, x
    ldx #1
    ldy #3
    jsr print_at
    ldx help_open
    lda page_num_lo-1, x
    sta text_ptr
    lda page_num_hi-1, x
    sta text_ptr+1
    ldx #1
    ldy #35
    lda #1
    jsr print_at
    ldx help_open
    lda page_body_lo-1, x
    sta data_ptr
    lda page_body_hi-1, x
    sta data_ptr+1
    jsr print_body
    lda help_open
    cmp #PAGE_EDITOR
    bne !commands+
    jsr draw_editor_help
    jmp !helpFooter+
    !commands:
    cmp #PAGE_HELP
    bne !brief+
    jsr draw_commands
    !helpFooter:
    :TextAt(20, 3, hc_music_note, 15)
    lda #0
    sta cursor_row
    lda intro
    beq !back+
    :TextAt(24, 3, ft_start, 7)
    jmp page_show
    !back:
    :TextAt(24, 3, ft_back, 7)
    jmp page_show
    !brief:
    cmp #PAGE_LEGEND
    bne !brief1+
    jsr draw_legend2
    lda #0
    sta cursor_row
    lda intro
    beq !legendBack+
    :TextAt(24, 3, ft_legend_start, 7)
    jmp page_show
    !legendBack:
    :TextAt(24, 3, ft_legend_back, 7)
    jmp page_show
    !brief1:
    cmp #PAGE_BRIEF1
    bne !brief2+
    :TextAt(24, 3, ft_next, 7)
    jmp page_show
    !brief2:
    cmp #PAGE_BRIEF2
    bne !ending+
    :TextAt(24, 3, ft_to_help, 7)
    jmp page_show
    !ending:
    :TextAt(24, 3, ft_reconnect, 7)
}

// Draw the selected static page body and its navigation footer.
page_show:
{
    lda #$1b
    sta $d011
    rts
}

// data_ptr = body. Prints one line per row from render_row, column 3.
// The terminal cursor follows the last printed text.
print_body:
{
    !line:
    ldy #0
    lda (data_ptr), y
    cmp #BODY_END
    beq !done+
    ldx #14
    cmp #$f0
    bcc !plain+
    and #%00001111
    tax
    inc data_ptr
    bne !plain+
    inc data_ptr+1
    !plain:
    lda data_ptr
    sta text_ptr
    lda data_ptr+1
    sta text_ptr+1
    txa
    ldx render_row
    ldy #3
    jsr print_at
    tya
    beq !advance+
    clc
    adc #3
    sta cursor_col
    lda render_row
    sta cursor_row
    !advance:
    tya
    sec
    adc data_ptr
    sta data_ptr
    bcc !nextRow+
    inc data_ptr+1
    !nextRow:
    inc render_row
    jmp !line-
    !done:
    rts
}

// Record viewer: view_rec 0 is the mission log, 1..RECORD_COUNT are stored records.
render_record:
{
    ldx view_rec
    bne !record+
    jsr render_mission_log
    jmp !footer+
    !record:
    lda rec_title_lo, x
    sta text_ptr
    lda rec_title_hi, x
    sta text_ptr+1
    // Facility logs have a cyan heading and "LOG 03", Command transmissions
    // a yellow heading and "MSG 03".
    lda #3
    cpx #FIRST_TRANSMISSION
    bcc !heading+
    lda #7
    !heading:
    ldx #1
    ldy #3
    jsr print_at
    jsr buf_clear
    lda view_rec
    cmp #FIRST_TRANSMISSION
    bcs !message+
    :Append(log_text)
    lda view_rec
    jmp !number+
    !message:
    :Append(msg_text)
    lda view_rec
    sec
    sbc #LOG_COUNT
    !number:
    jsr buf_num2
    lda #40
    sta field_end
    ldx #1
    ldy #31
    lda #1
    jsr print_buf
    lda view_rec
    cmp #FIRST_TRANSMISSION
    bcc !body+
    :TextAt(3, 3, command_label, 7)
    lda #5
    sta render_row
    !body:
    ldx view_rec
    cpx #2
    bne !normalBody+
    lda rec_known+9
    beq !normalBody+
    lda #<rb_2_late
    sta data_ptr
    lda #>rb_2_late
    bne !bodyHigh+
    !normalBody:
    lda rec_body_lo, x
    sta data_ptr
    lda rec_body_hi, x
    !bodyHigh:
    sta data_ptr+1
    jsr print_body
    // Shown once: the record is now viewed.
    ldx view_rec
    lda #1
    sta rec_known, x
    !footer:
    jsr first_unread
    beq !resume+
    :TextAt(24, 3, ft_next_log, 7)
    jmp page_show
    !resume:
    // A record read during a run: RETURN goes back to the run.
    jsr in_run
    beq !planned+
    :TextAt(24, 3, ft_to_run, 7)
    jmp page_show
    !planned:
    :TextAt(24, 3, ft_browse, 7)
    jmp page_show
}

// Missions with their best results, the open goal, logs and firmware.
render_mission_log:
{
    :TextAt(1, 3, ml_head, 3)
    ldx #2
    jsr draw_help_rule
    lda #0
    sta panel_index
    !mission:
    ldx panel_index
    txa
    asl
    clc
    adc #3
    sta render_row
    lda ml_names_lo, x
    sta text_ptr
    lda ml_names_hi, x
    sta text_ptr+1
    ldx render_row
    ldy #3
    lda #14
    jsr print_at
    ldx panel_index
    lda mission_done, x
    beq !open+
    cpx #MISSION_REACTOR
    bne !done+
    cmp #2
    beq !lost+
    :Ptr(ml_secured)
    jmp !endingStatus+
    !lost:
    :Ptr(ml_lost)
    !endingStatus:
    ldy #30
    bne !status+
    !done:
    :Ptr(ml_done)
    ldy #33
    bne !status+
    !open:
    :Ptr(ml_open)
    ldy #33
    lda #7
    bne !statusColor+
    !status:
    lda #13
    !statusColor:
    ldx render_row
    jsr print_at
    jsr buf_clear
    ldx panel_index
    lda mission_done, x
    beq !noTime+
    :Append(ml_best)
    ldx panel_index
    lda best_ticks, x
    jsr buf_num2
    :Append(ml_cycles)
    lda #32
    jsr buf_char
    lda #32
    jsr buf_char
    ldx panel_index
    lda best_lines, x
    jsr buf_num2
    :Append(ml_lines)
    :Append(ml_loop)
    ldx panel_index
    lda best_loops, x
    jsr buf_num2
    jmp !time+
    !noTime:
    :Append(ml_no_time)
    !time:
    lda #38
    sta field_end
    ldx render_row
    inx
    ldy #3
    lda #12
    jsr print_buf
    inc panel_index
    lda panel_index
    cmp #MISSION_COUNT
    beq !hint+
    jmp !mission-
    !hint:
    :TextAt(14, 3, ml_hint, 7)
    jsr build_mission
    lda #38
    sta field_end
    ldx #14
    ldy #9
    lda #7
    jsr print_buf
    jsr buf_clear
    :Append(ml_logs)
    jsr count_records
    jsr buf_num2
    :Append(ml_of)
    lda #38
    sta field_end
    ldx #17
    ldy #3
    lda #14
    jsr print_buf
    :TextAt(19, 3, ml_fw, 14)
    :TextAt(19, 22, ml_codes, 14)
    lda #0
    sta panel_index
    !libraries:
    ldx panel_index
    lda firmware
    and bit_mask, x
    beq !unknownFw+
    lda ml_fw_names_lo, x
    sta text_ptr
    lda ml_fw_names_hi, x
    sta text_ptr+1
    jmp !firmware+
    !unknownFw:
    :Ptr(rc_0)
    !firmware:
    lda panel_index
    clc
    adc #20
    tax
    ldy #5
    lda #13
    jsr print_at
    ldx panel_index
    lda credentials
    and code_bits, x
    beq !unknownCode+
    lda code_names_lo, x
    sta text_ptr
    lda code_names_hi, x
    sta text_ptr+1
    jmp !code+
    !unknownCode:
    :Ptr(rc_0)
    !code:
    lda panel_index
    clc
    adc #20
    tax
    ldy #24
    lda #13
    jsr print_at
    inc panel_index
    lda panel_index
    cmp #3
    bne !libraries-
    rts
}

// Reactor control image: six slots, then help, a hard error, or a warning
// with EXECUTE? YES / NO.
render_image:
{
    :TextAt(1, 3, im_head, 3)
    :TextAt(3, 3, im_intro, 15)
    jsr image_slots
    jmp image_rest
}

// The six slots and, while editing, what the selected command does.
image_slots:
{
    ldx #0
    !slot:
    stx panel_index
    jsr buf_clear
    lda panel_index
    clc
    adc #1
    jsr buf_num
    lda #32
    jsr buf_char
    lda #32
    jsr buf_char
    ldx panel_index
    lda image, x
    tax
    lda rc_names_lo, x
    sta text_ptr
    lda rc_names_hi, x
    sta text_ptr+1
    jsr buf_text
    lda #20
    sta field_end
    lda panel_index
    clc
    adc #5
    tax
    ldy #5
    lda #1
    jsr print_buf
    lda img_state
    bne !nextSlot+
    lda panel_index
    cmp img_slot
    bne !nextSlot+
    // Reverse bar on the selected slot.
    clc
    adc #5
    tax
    jsr screen_position
    ldy #5
    !bar:
    lda (screen_ptr), y
    ora #%10000000
    sta (screen_ptr), y
    lda #7
    sta (color_ptr), y
    iny
    cpy #20
    bne !bar-
    !nextSlot:
    ldx panel_index
    inx
    cpx #IMAGE_SLOTS
    bne !slot-
    lda img_state
    bne !done+
    ldx img_slot
    lda image, x
    tax
    lda rc_info_lo, x
    sta text_ptr
    lda rc_info_hi, x
    sta text_ptr+1
    lda #38
    sta field_end
    ldx #18
    ldy #3
    lda #1
    jmp print_field
    !done:
    rts
}

// Draw reactor-image help, validation errors or the execution confirmation.
image_rest:
{
    lda img_state
    bne !check+
    :TextAt(13, 3, im_help1, 15)
    :TextAt(14, 3, im_help2, 15)
    :TextAt(16, 3, im_help3, 14)
    :TextAt(24, 3, ft_image, 7)
    jmp page_show
    !check:
    :TextAt(13, 3, im_check, 1)
    lda img_state
    cmp #2
    beq !warning+
    :TextAt(15, 3, im_error, 10)
    lda img_msg
    bne !missing+
    :TextAt(16, 3, im_empty, 10)
    jmp !any+
    !missing:
    :TextAt(16, 3, im_missing, 10)
    ldx img_arg
    lda rc_names_lo, x
    sta text_ptr
    lda rc_names_hi, x
    sta text_ptr+1
    ldx #17
    ldy #3
    lda #10
    jsr print_at
    !any:
    :TextAt(24, 3, im_any, 7)
    jmp page_show
    !warning:
    :TextAt(15, 3, im_warning, 7)
    ldx img_msg
    lda warn1_lo-1, x
    sta text_ptr
    lda warn1_hi-1, x
    sta text_ptr+1
    ldx #16
    ldy #3
    lda #7
    jsr print_at
    ldx img_msg
    lda warn2_lo-1, x
    sta text_ptr
    lda warn2_hi-1, x
    sta text_ptr+1
    // Before the containment record, the shutdown warning keeps the secret.
    cpx #1
    bne !second+
    lda story_flags
    and #FLAG_TRUTH
    beq !second+
    :Ptr(im_shut3)
    !second:
    ldx #17
    ldy #3
    lda #7
    jsr print_at
    :TextAt(19, 3, im_execute, 1)
    :TextAt(19, 14, im_yes, 1)
    :TextAt(19, 18, im_slash, 1)
    :TextAt(19, 20, im_no, 1)
    // Reverse the chosen answer.
    ldx #19
    jsr screen_position
    ldy #20
    ldx #2
    lda img_choice
    beq !mark+
    ldy #14
    ldx #3
    !mark:
    lda (screen_ptr), y
    ora #%10000000
    sta (screen_ptr), y
    lda #7
    sta (color_ptr), y
    iny
    dex
    bne !mark-
    :TextAt(24, 3, ft_confirm, 7)
    jmp page_show
}

// What each reactor command does, in the words of the operating notes.
rc_info_lo:
    .byte <ri_0, <ri_1, <ri_2, <ri_3, <ri_4, <ri_5
rc_info_hi:
    .byte >ri_0, >ri_1, >ri_2, >ri_3, >ri_4, >ri_5
ri_0:
    .text "EMPTY SLOT. LEFT/RIGHT CHOOSES."; .byte 0
ri_1:
    .text "FEEDBACK REGULATES THE OUTPUT."; .byte 0
ri_2:
    .text "PULSE OVERCLOCKS THE PROCESSOR."; .byte 0
ri_3:
    .text "ROUTE CONTRACTS THE FIELD COILS."; .byte 0
ri_4:
    .text "RESET OFF RELEASES THE QUARANTINE."; .byte 0
ri_5:
    .text "SHUTDOWN CUTS ALL REACTOR OUTPUT."; .byte 0
warn1_lo:
    .byte <im_shut1, <im_danger, <im_incompat
warn1_hi:
    .byte >im_shut1, >im_danger, >im_incompat
warn2_lo:
    .byte <im_shut2, <im_failure, <im_failure
warn2_hi:
    .byte >im_shut2, >im_failure, >im_failure

// Terminal casing around the whole screen: purple on the lit top and left
// sides, blue on the shaded bottom and right sides. Row 23 carries the
// nameplate and the power LED. Row 24 stays free for the input hint.
draw_terminal:
{
    ldx #39
    !edges:
    lda #CHAR_CASE+1
    sta $0400, x
    lda #CHAR_CASE+6
    sta $0400+23*40, x
    lda #4
    sta $d800, x
    lda #6
    sta $d800+23*40, x
    dex
    bpl !edges-
    ldx #1
    !sides:
    jsr screen_position
    ldy #0
    lda #CHAR_CASE+3
    sta (screen_ptr), y
    lda #4
    sta (color_ptr), y
    ldy #39
    lda #CHAR_CASE+4
    sta (screen_ptr), y
    lda #6
    sta (color_ptr), y
    inx
    cpx #23
    bne !sides-
    lda #CHAR_CASE
    sta $0400
    lda #CHAR_CASE+2
    sta $0400+39
    lda #CHAR_CASE+5
    sta $0400+23*40
    lda #CHAR_CASE+7
    sta $0400+23*40+39
    lda #CHAR_GLASS
    sta $0400+40+1
    lda #CHAR_GLASS+1
    sta $0400+40+38
    lda #CHAR_GLASS+2
    sta $0400+22*40+1
    lda #CHAR_GLASS+3
    sta $0400+22*40+38
    lda #4
    sta $d800+40+1
    sta $d800+40+38
    lda #6
    sta $d800+22*40+1
    sta $d800+22*40+38
    // Nameplate in reverse characters: black letters on a light blue plate.
    ldx #0
    !plate:
    lda plate_text, x
    beq !led+
    ora #%10000000
    sta $0400+23*40+3, x
    lda #14
    sta $d800+23*40+3, x
    inx
    bne !plate-
    !led:
    lda #CHAR_LED
    sta $0400+23*40+36
    lda #13
    sta $d800+23*40+36
    rts
}

// Draw one help-table column; scratch+4 selects the entry, render_row its row.
// Clobbers A/X/Y, flags, text_ptr, screen_ptr/color_ptr and text_color.
.macro CommandColumn(lo, hi, col, color)
{
    ldx scratch+4
    lda lo, x
    sta text_ptr
    lda hi, x
    sta text_ptr+1
    ldx render_row
    ldy #col
    lda #color
    jsr print_at
}

// Draw command keys, names, parameters, cycle costs and firmware notes.
draw_commands:
{
    :TextAt(3, 3, hc_key, 3)
    :TextAt(3, 12, hc_command, 3)
    :TextAt(3, 22, hc_param, 3)
    :TextAt(3, 31, hc_cycles, 3)
    ldx #4
    jsr draw_help_rule
    ldx #14
    jsr draw_help_rule
    ldx #8
    !row:
    stx scratch+4
    txa
    clc
    adc #5
    sta render_row
    :CommandColumn(hc_keys_lo, hc_keys_hi, 3, 7)
    :CommandColumn(hc_names_lo, hc_names_hi, 12, 1)
    :CommandColumn(hc_params_lo, hc_params_hi, 22, 15)
    :CommandColumn(hc_costs_lo, hc_costs_hi, 31, 3)
    ldx scratch+4
    dex
    bpl !row-
    :TextAt(15, 3, hc_param_note, 15)
    :TextAt(16, 3, hc_access_note, 15)
    :TextAt(17, 3, hc_fw_note, 15)
    :TextAt(18, 3, hc_num_note, 12)
    :TextAt(21, 2, hc_play, 12)
    ldx #21
    jmp highlight_control_row
}

// X=row. The rule leaves the terminal's side casing intact.
draw_help_rule:
{
    jsr screen_position
    ldy #37
    !cell:
    lda #CHAR_HLINE
    sta (screen_ptr), y
    lda #6
    sta (color_ptr), y
    dey
    cpy #1
    bne !cell-
    rts
}

// X = last legend entry, scratch+4 = first. Draws the entries X down to it.
draw_legend_from:
{
    !legend:
    stx scratch
    lda legend_tile, x
    sta render_tile
    lda legend_color, x
    sta render_color
    lda legend_col, x
    tay
    lda legend_row, x
    tax
    jsr draw_tile
    ldx scratch
    lda legend_label_lo, x
    sta text_ptr
    lda legend_label_hi, x
    sta text_ptr+1
    lda legend_col, x
    clc
    adc #3
    tay
    lda legend_row, x
    tax
    lda #15
    jsr print_at
    ldx scratch
    cpx scratch+4
    beq !done+
    dex
    jmp !legend-
    !done:
    rts
}

// Three columns for the nine basics, then two for twelve advanced tiles.
draw_legend2:
{
    ldx #9
    jsr draw_help_rule
    lda #0
    sta scratch+4
    ldx #18
    jmp draw_legend_from
}

screen_lo:
    .fill 25, <($0400+i*40)
screen_hi:
    .fill 25, >($0400+i*40)
// Tile colours: floor, wall, socket, exit, terminal, gate, port, auth,
// panel, robot, cell, fog, laser, robot with cargo, laser off, chip,
// rack, programmer, reactor, uplink, hatch, door, stasis pod, library.
tile_colors:
    .byte 12, 4, 3, 15, 13, 10, 14, 8, 14, 7, 7, 11, 2, 7, 11, 5, 15, 13, 10, 3, 8, 15, 14, 5, 15, 2, 11, 7
// Colour of powered equipment (0 = unchanged): socket, terminal, roboport,
// port console, programmer, uplink, firmware library.
tile_lit:
    .byte 0, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 7
// Per halt reason: is it a failure, and does it mark the target tile.
halt_is_failure:
    .byte 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1
halt_marks:
    .byte 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1
direction_chars:
    .text "NESW"
op_long:
    .word nm_north, nm_east, nm_south, nm_west, nm_pick, nm_drop, nm_wait, nm_scan, nm_read, nm_access, nm_boost, nm_link
nm_north:
    .text "NORTH"; .byte 0
nm_east:
    .text "EAST"; .byte 0
nm_south:
    .text "SOUTH"; .byte 0
nm_west:
    .text "WEST"; .byte 0
nm_pick:
    .text "PICK"; .byte 0
nm_drop:
    .text "DROP"; .byte 0
nm_wait:
    .text "WAIT"; .byte 0
nm_scan:
    .text "SCAN"; .byte 0
nm_read:
    .text "READ"; .byte 0
nm_access:
    .text "ACCESS"; .byte 0
nm_boost:
    .text "BOOST"; .byte 0
nm_bst:
    .text "BST"; .byte 0
nm_link:
    .text "LINK"; .byte 0
title_text:
    .text "CYCLE 64"; .byte 0
sector_text:
    .text "SECTOR "; .byte 0
clock_text:
    .text "CYCLES LEFT   /64"; .byte 0
loop_text:
    .text "LOOP   "; .byte 0
rn_0:
    .text "MAINTENANCE DOCK"; .byte 0
rn_1:
    .text "MAINTENANCE WORKSHOP"; .byte 0
rn_2:
    .text "SECURITY HUB"; .byte 0
rn_3:
    .text "POWER JUNCTION"; .byte 0
rn_4:
    .text "RECORDS ARCHIVE"; .byte 0
rn_5:
    .text "REACTOR CONTROL"; .byte 0
rn_6:
    .text "COOLING PLANT"; .byte 0
rn_7:
    .text "SERVICE DUCT"; .byte 0
rn_8:
    .text "STASIS REFUGE (SEALED)"; .byte 0
room_name_lo:
    .byte <rn_0, <rn_1, <rn_2, <rn_3, <rn_4, <rn_5, <rn_6, <rn_7, <rn_8
room_name_hi:
    .byte >rn_0, >rn_1, >rn_2, >rn_3, >rn_4, >rn_5, >rn_6, >rn_7, >rn_8
editor_text:
    .text "CODE EDITOR"; .byte 0
program_text:
    .text "PROGRAM   /32"; .byte 0
empty_text:
    .byte 0

cargo_text_lo:
    .byte <cg_none, <cg_cell, <cg_blank, <cg_ready
cargo_text_hi:
    .byte >cg_none, >cg_cell, >cg_blank, >cg_ready
cg_none:
    .text "NONE"; .byte 0
cg_cell:
    .text "CELL"; .byte 0
cg_blank:
    .text "CHIP--"; .byte 0
cg_ready:
    .text "CHIP OK"; .byte 0
code_orbit:
    .text "ORBIT"; .byte 0
code_zenith:
    .text "ZENITH"; .byte 0
code_vector:
    .text "VECTOR"; .byte 0
hud_logs:
    .text "LOGS  "; .byte 0
hud_log_total:
    .text "/14"; .byte 0
hud_codes:
    .text "CODES "; .byte 0
hud_code_total:
    .text "/03"; .byte 0
hud_inv:
    .text "INV   "; .byte 0
fw_text:
    .text "FW "; .byte 0
fw_letters:
    .text "PRF"
// Map glyph and colour per cargo: three cells, then the control chip.
cargo_glyph:
    .byte TILE_CELL, TILE_CELL, TILE_CELL, TILE_CHIP
cargo_color:
    .byte 7, 7, 7, 5
controls_text:
    .text "F1 RUN F3 STEP F7 RESET V LOGS H HELP"; .byte 0
ctl_run:
    .text "F1 RUN F3 STEP F7 RESET V LOGS H HELP"; .byte 0
ctl_halt:
    .text "RETURN: RESET TO EDIT  F1 RERUN  H HELP"; .byte 0
grid_on_text:
    .text "GRID ON  "; .byte 0
grid_off_text:
    .text "GRID OFF "; .byte 0
cooling_grids_text:
    .text "3 GRIDS"; .byte 0
// Rooms with a laser grid: the Power Junction and the Cooling Plant.
room_has_grid:
    .byte 0, 0, 0, 1, 0, 1, 1, 0, 0
// Mission hints in story order: the first condition whose byte AND mask is 0
// gives the hint. The last text is shown when every condition is met.
// Sector 01: M1 lights the dock, the dock note, the workshop terminal on
// power (ORBIT), the hub camera log (ZENITH), the workshop south gate.
goal_secured:
    .text "CONTAINMENT SECURED"; .byte 0
t_slash:
    .text "C/"; .byte 0
delivered_text:
    .text " COMPLETE "; .byte 0
aziz_text:
    .text " AZIZ, LIGHT! "; .byte 0
t_space:
    .text "C "; .byte 0
stored_text:
    .text " STORED"; .byte 0
reading_text:
    .text "READING... 1/2"; .byte 0
st_best:
    .text "NEW BEST"; .byte 0
st_paused:
    .text "PAUSED"; .byte 0
st_loop_end:
    .text "LOOP END"; .byte 0
end_program_text:
    .text "PROGRAM END. ADD LINES OR F7"; .byte 0
full_program_text:
    .text "PROGRAM FULL (32). F7 RESETS"; .byte 0
st_run:
    .text "RUNNING"; .byte 0
st_step:
    .text "STEP"; .byte 0
st_map:
    .text "MAP"; .byte 0
st_one_room:
    .text "ONLY ROOM"; .byte 0
st_plan_only:
    .text "PLAN ONLY"; .byte 0
ft_to_run:
    .text "RETURN/F1: BACK TO THE RUN"; .byte 0
line_text:
    .text "LINE "; .byte 0
colon_text:
    .text ": "; .byte 0
at_text:
    .text " AT "; .byte 0
clock_fail_text:
    .text "NO CYCLES LEFT - RETURN RESETS"; .byte 0
// A blocked move names the tile: 0 blocked, 1 wall, 2 gate, 3 laser, 4 door.
move_block_text:
    .byte 0, 1, 0, 0, 1, 2, 0, 1, 1, 0, 0, 0, 3, 0, 0, 0, 1, 1, 1, 1, 1, 4, 1, 1, 0, 3, 0, 0
move_block_names:
    .word blocked_text, wall_text, gate_closed_text, laser_text, door_text
wall_text:
    .text "WALL"; .byte 0
blocked_text:
    .text "BLOCKED"; .byte 0
gate_closed_text:
    .text "GATE CLOSED"; .byte 0
laser_text:
    .text "LASER"; .byte 0
door_text:
    .text "DOOR SEALED"; .byte 0
fail_names:
    .word empty_text, empty_text, empty_text, empty_text, fl_cargo, fl_hold, fl_empty, fl_block, empty_text, empty_text, fl_read, fl_cred, fl_lock
    .word fl_laser, fl_uplink, fl_channel, fl_nochip, fl_noimage, fl_blank, fl_power, fl_field, fl_inert, empty_text, fl_diag, fl_drop
    .word fl_sealed, fl_door_power, fl_inside, fl_taken, fl_offline, fl_hatch, empty_text, fl_firmware
fl_cargo:
    .text "NO CARGO"; .byte 0
fl_hold:
    .text "HAND FULL"; .byte 0
fl_empty:
    .text "EMPTY HAND"; .byte 0
fl_block:
    .text "BLOCKED"; .byte 0
fl_read:
    .text "NO READABLE TERMINAL"; .byte 0
fl_cred:
    .text "CREDENTIAL UNKNOWN"; .byte 0
fl_lock:
    .text "NO ACCESS CONSOLE"; .byte 0
fl_laser:
    .text "LASER ACTIVE"; .byte 0
fl_uplink:
    .text "NO UPLINK"; .byte 0
fl_channel:
    .text "CHANNEL IN USE"; .byte 0
fl_nochip:
    .text "NO CHIP IN HAND"; .byte 0
fl_noimage:
    .text "NO AUTHORIZED IMAGE"; .byte 0
fl_blank:
    .text "CHIP NOT PROGRAMMED"; .byte 0
fl_power:
    .text "POWER DEFICIT"; .byte 0
fl_field:
    .text "FIELD UNSTABLE"; .byte 0
fl_inert:
    .text "QUARANTINE STILL ON"; .byte 0
fl_diag:
    .text "MODULE NEEDS FEEDBACK"; .byte 0
fl_drop:
    .text "DROP THE CHIP HERE"; .byte 0
fl_sealed:
    .text "SEALED MODULE: READ"; .byte 0
fl_door_power:
    .text "DOOR NEEDS BOTH CELLS"; .byte 0
fl_inside:
    .text "SEALED FROM INSIDE"; .byte 0
fl_taken:
    .text "CARGO ALREADY THERE"; .byte 0
fl_offline:
    .text "TERMINAL OFFLINE"; .byte 0
fl_hatch:
    .text "HATCH HAS NO POWER"; .byte 0
fl_firmware:
    .text "FEEDBACK REQUIRED"; .byte 0
event_names:
    .word empty_text, ev_scan, empty_text, ev_gate, empty_text, ev_duct, ev_echo, ev_hatch, ev_power, ev_link, ev_chip, empty_text, ev_no_load, ev_hatch_live
ev_scan:
    .text "TERMINAL FOUND - READ IT"; .byte 0
ev_gate:
    .text "GATE OPEN FOR THIS LOOP"; .byte 0
ev_duct:
    .text "DIAGNOSTIC: DUCT FOUND"; .byte 0
ev_echo:
    .text "PANEL ECHO UNCLEAR"; .byte 0
ev_hatch:
    .text "DUCT OPEN FOR THIS LOOP"; .byte 0
ev_power:
    .text "POWER RESTORED - DOOR OPEN"; .byte 0
ev_link:
    .text "CONTROL LINKED TO VAULT UNIT"; .byte 0
ev_chip:
    .text "CONTROL CHIP PROGRAMMED"; .byte 0
ev_no_load:
    .text "NO LOAD ON THIS SOCKET"; .byte 0
ev_hatch_live:
    .text "DUCT HATCH HAS POWER"; .byte 0
// Room arrival lines, shown once on the first visit of each room.
arrival_lo:
    .byte <ar_0, <ar_1, <ar_2, <ar_3, <ar_4, <ar_5, <ar_6, <ar_7, <ar_8
arrival_hi:
    .byte >ar_0, >ar_1, >ar_2, >ar_3, >ar_4, >ar_5, >ar_6, >ar_7, >ar_8
ar_0:
    .text "DOCK: ROBOT LINK IS LIVE"; .byte 0
ar_1:
    .text "WORKSHOP: TOOLS LEFT MID-JOB"; .byte 0
ar_2:
    .text "HUB: ALARM LIGHTS STILL RED"; .byte 0
ar_3:
    .text "JUNCTION: THE GRID IS HUMMING"; .byte 0
ar_4:
    .text "ARCHIVE: FILES, BUT NO PEOPLE"; .byte 0
ar_5:
    .text "REACTOR: OUTPUT 98% DIVERTED"; .byte 0
ar_6:
    .text "COOLING: FROST ON THE PIPES"; .byte 0
ar_7:
    .text "DUCT: A CRAWLWAY TO THE CORE"; .byte 0
ar_8:
    .text "REFUGE: SEALED"; .byte 0
// All entries fit above the nameplate on help page 2.
legend_row:
    .byte 3, 3, 3, 5, 5, 5, 7, 10, 10, 12, 12, 14, 14, 16, 16, 18, 18, 20, 20
legend_col:
    .byte 3, 15, 27, 3, 15, 27, 3, 3, 21, 3, 21, 3, 21, 3, 21, 3, 21, 3, 21
legend_tile:
    .byte TILE_ROBOT, TILE_CELL, TILE_SOCKET, TILE_WALL, TILE_GATE, TILE_EXIT, TILE_TERMINAL
    .byte TILE_LASER, TILE_LASER_OFF, TILE_PANEL, TILE_HATCH, TILE_DOOR, TILE_LIBRARY, TILE_UPLINK, TILE_RACK, TILE_CHIP, TILE_PROGRAMMER, TILE_REACTOR, TILE_STASIS
legend_color:
    .byte 7, 7, 3, 4, 10, 15, 13, 2, 11, 14, 8, 15, 5, 3, 15, 5, 13, 10, 14
legend_label_lo:
    .byte <lg_robot, <lg_cell, <lg_socket, <lg_wall, <lg_gate, <lg_exit, <lg_terminal
    .byte <lg_laser, <lg_laser_off, <lg_panel, <lg_hatch, <lg_door, <lg_library, <lg_uplink, <lg_rack, <lg_chip, <lg_programmer, <lg_reactor, <lg_stasis
legend_label_hi:
    .byte >lg_robot, >lg_cell, >lg_socket, >lg_wall, >lg_gate, >lg_exit, >lg_terminal
    .byte >lg_laser, >lg_laser_off, >lg_panel, >lg_hatch, >lg_door, >lg_library, >lg_uplink, >lg_rack, >lg_chip, >lg_programmer, >lg_reactor, >lg_stasis
lg_laser:
    .text "LASER ON"; .byte 0
lg_laser_off:
    .text "LASER OFF"; .byte 0
lg_panel:
    .text "SEALED PANEL"; .byte 0
lg_hatch:
    .text "DUCT HATCH"; .byte 0
lg_door:
    .text "SEALED DOOR"; .byte 0
lg_library:
    .text "FIRMWARE"; .byte 0
lg_uplink:
    .text "UPLINK"; .byte 0
lg_rack:
    .text "STORAGE RACK"; .byte 0
lg_chip:
    .text "CONTROL CHIP"; .byte 0
lg_programmer:
    .text "PROGRAMMER"; .byte 0
lg_reactor:
    .text "REACTOR MODULE"; .byte 0
lg_stasis:
    .text "STASIS POD"; .byte 0
lg_robot:
    .text "ROBOT"; .byte 0
lg_cell:
    .text "CELL"; .byte 0
lg_socket:
    .text "SOCKET"; .byte 0
lg_wall:
    .text "WALL"; .byte 0
lg_gate:
    .text "GATE"; .byte 0
lg_exit:
    .text "EXIT"; .byte 0
lg_terminal:
    .text "TERMINAL"; .byte 0

#import "data/graphics.asm"
