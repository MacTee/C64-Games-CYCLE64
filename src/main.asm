// CYCLE 64 - Resident PRG layout, startup, frame dispatch and presentation bookkeeping.

// One resident PRG. VM/world never call the renderer or keyboard.
// Public routine/data labels remain global for the engine harness and tools;
// each routine's brace scope keeps its branch labels local.
.encoding "screencode_upper"
#import "constants.asm"
#import "macros.asm"
BasicUpstart2(start)
* = $0900 "Story text"
#import "data/pages.asm"
#import "data/records.asm"
story_text_end:
.assert "Story text stays below the character set", story_text_end <= $3000, true

* = $3000 "Runtime character set"
    .fill $800, 0
* = $3800 "Story text 2"
#import "data/story2.asm"
#import "help.asm"
#import "vault-light.asm"
#import "laser.asm"
#import "music.asm"
story_text2_end:
.assert "Story text 2 stays below the code", story_text2_end <= $4000, true
* = $4000 "Code and tables"
// Initialize banking, graphics, world state, music and the title screen.
start:
{
    // The engine harness owns its stack and interrupt setup under RAM banking.
    #if ENGINE_TESTS
    sei
    lda #$35
    sta $01
    jmp test_start
    #endif
    // Main-thread arithmetic assumes binary mode; game I/O and ROM remain visible.
    sei
    cld
    lda #$37
    sta $01
    lda #0
    sta $d020
    sta $d021
    sta $d015
    lda $dd00
    ora #%00000011
    sta $dd00
    jsr init_charset
    lda #$1c
    sta $d018
    lda #$1b
    sta $d011
    lda #8
    sta $d016
    jsr session_init
    jsr editor_init
    jsr reset_ephemeral_world
    jsr music_init
    lda #0
    sta help_open
    sta frame_count
    lda #MODE_TITLE
    sta mode
    lda #25
    sta title_delay
    lda #0
    sta $c6                                                 // Discard BASIC/autostart's remaining keyboard buffer.
    jsr init_title
    lda #DIRTY_ALL
    sta dirty
    // init_title has installed the IRQ vector and acknowledged its sources.
    cli
    // Fall through to main_loop; scopes do not emit instructions.
}

// Poll one PAL frame, handle keyboard input and advance an unpaused program.
main_loop:
{
    jsr wait_frame
    inc blink_count
    jsr clock_blink
    lda title_delay
    beq !input+
    dec title_delay
    !input:
    jsr $ffe4
    beq !noKey+
    jsr dispatch_key
    !noKey:
    // A text page pauses the run. No cycles pass while it shows.
    lda help_open
    bne !draw+
    lda mode
    cmp #MODE_RUN
    bne !draw+
    inc frame_count
    lda frame_count
    cmp #15
    bcc !draw+
    lda #0
    sta frame_count
    jsr vm_tick
    jsr after_tick
    lda dirty
    ora #DIRTY_PARTS
    sta dirty
    !draw:
    lda dirty
    beq main_loop
    jsr render
    lda #0
    sta dirty
    jmp main_loop
}

// Keys redraw every region unless handle_key narrows key_dirty.
dispatch_key:
{
    pha
    lda #DIRTY_PARTS
    sta key_dirty
    lda #0
    sta map_note
    pla
    jsr handle_key
    lda dirty
    ora key_dirty
    sta dirty
    rts
}

// Waits for raster line 256, the start of the lower border. Raster bit 8 stays
// set for 56 lines, so a raster IRQ on any single line cannot hide the edge.
// Timing: PAL raster bit 8; interrupts may run, so no single raster line is assumed.
wait_frame:
{
    !leave:
    bit $d011
    bmi !leave-
    !wait:
    bit $d011
    bpl !wait-
    rts
}

// Presentation bookkeeping after each logical cycle. The engine stays display-free.
after_tick:
{
    jsr sound_action
    jsr check_transmissions
    lda halt_reason
    cmp #HALT_LASER
    bne !records+
    jmp reset_after_laser
    !records:
    // Show the triggering facility log before any resulting Command messages.
    // Each page pauses the run without consuming a cycle.
    lda show_record
    bne !record+
    jsr first_unread
    beq !shown+
    txa
    !record:
    sta view_rec
    lda #0
    sta show_record
    lda #PAGE_RECORD
    sta help_open
    lda dirty
    ora #DIRTY_ALL
    sta dirty
    !shown:
    // msg_fresh: this cycle produced the footer message. The program-end
    // pause shows it instead of its own hint.
    lda #0
    sta msg_fresh
    lda delivery_event
    beq !event+
    jsr note_delivery
    !event:
    lda event_seq
    cmp seen_event
    beq !halt+
    sta seen_event
    lda #1
    sta run_msg
    sta msg_fresh
    !halt:
    lda halt_reason
    bne !halted+
    // The last line just finished: pause now, not one key press later.
    lda cycles_left
    bne !done+
    lda ip
    cmp program_len
    bcc !done+
    lda #HALT_END
    sta halt_reason
    !halted:
    cmp #HALT_END
    bne !freeze+
    // Program end with cycles left: pause on the next empty line.
    // The player can add lines, then continue with F1 or F3.
    lda #MODE_STEP
    sta mode
    lda ip
    sta cursor
    jmp editor_scroll
    !freeze:
    // Keep the failed target for the map marker and the failure message.
    // The world stays frozen, also at cycle 64, until RETURN or F7 resets it.
    lda target_room
    sta fail_room
    lda target_x
    sta fail_x
    lda target_y
    sta fail_y
    lda target_tile
    sta fail_tile
    lda #MODE_HALT
    sta mode
    lda halt_reason
    cmp #HALT_CLOCK
    bne !ending+
    // A final-cycle READ shows its log and queued Command messages first.
    lda help_open
    cmp #PAGE_RECORD
    beq !done+
    jmp show_reset_notice
    !ending:
    lda halt_reason
    cmp #HALT_ENDING
    bne !done+
    // The installed chip decided the ending. Show its page.
    lda ending_kind
    bne !bad+
    lda story_flags
    ora #FLAG_SECURED
    sta story_flags
    !bad:
    lda ending_kind
    clc
    adc #PAGE_END_GOOD
    sta help_open
    lda dirty
    ora #DIRTY_ALL
    sta dirty
    jmp sound_ending
    !done:
    rts
}

// A delivery powers its mission socket. Note the first new one this run.
note_delivery:
{
    lda delivery_event
    sec
    sbc #1
    sta last_delivery
    lda elapsed
    sta last_delivery_cycle
    lda #2
    sta run_msg
    lda #1
    sta msg_fresh
    rts
}

bit_mask:
    .byte 1, 2, 4, 8
#import "data/rooms.asm"
#import "world.asm"
#import "vm.asm"
#import "missions.asm"
#import "vision.asm"
#import "editor.asm"
#import "render.asm"
#import "title.asm"
#import "sound.asm"
#import "data/cooling-read.asm"
#if ENGINE_TESTS
#import "../tests/engine-tests.asm"
#endif
code_end:
.assert "Code must remain below title buffers", code_end < $8000, true

#if ENGINE_TESTS
.label title_colors                = $9000
#else
* = $8000 "Title text matrix"
.import binary "data/title/cycle64_split_title_text_screen.bin"
* = $8400 "Title bitmap color matrix"
.import binary "data/title/cycle64_split_title_bitmap_screen.bin"
* = $8800 "Title character set"
.import binary "data/title/cycle64_split_title_charset.bin"
* = $9000 "Title color RAM source"
title_colors:
.import binary "data/title/cycle64_split_title_color_ram.bin"
#endif
* = $9400 "Power and tile inspection"
#import "power.asm"
#import "mission-progress.asm"
#import "inspect.asm"
#import "loop-reset.asm"
extension_end:
.assert "Extension stays below title bitmap", extension_end <= $a000, true
* = $a000 "Title multicolor bitmap (RAM under BASIC ROM)"
.import binary "data/title/cycle64_split_title_bitmap.bin"
#import "data/title_robot.asm"
* = $c000 "Persistent session state"
persistent_start:
discovered:
    .fill ROOM_COUNT*120, 0
credentials:
    .byte 0
mission_done:
    .fill MISSION_COUNT, 0
best_ticks:
    .fill MISSION_COUNT, 255
best_lines:
    .fill MISSION_COUNT, 255
best_loops:
    .fill MISSION_COUNT, 0
room_known:
    .fill ROOM_COUNT, 0
dev_found:
    .fill DEV_COUNT, 0
rec_known:
    .fill RECORD_COUNT+1, 0
firmware:
    .byte 0
story_flags:
    .byte 0
image:
    .fill IMAGE_SLOTS, 0
program_len:
    .byte 0
program_op:
    .fill 32, 0
program_arg:
    .fill 32, 0
program_dir:
    .fill 32, 0
persistent_end:
.assert "Persistent data fits five pages", persistent_end <= $c500, true
* = $c500 "Ephemeral world and VM"
ephemeral_start:
live_tiles:
    .fill ROOM_COUNT*120, 0
robot_room:
    .byte 0
robot_x:
    .byte 0
robot_y:
    .byte 0
held:
    .byte 255
// The parked robot. LINK swaps it with the active robot.
other_room:
    .byte 0
other_x:
    .byte 0
other_y:
    .byte 0
other_held:
    .byte 255
linked:
    .byte 0
cargo_room:
    .fill CARGO_COUNT, 0
cargo_x:
    .fill CARGO_COUNT, 0
cargo_y:
    .fill CARGO_COUNT, 0
// Live socket occupancy bits, recomputed from physical cell positions.
powered_mask:
    .byte 0
chip_state:
    .byte 0
image_authorized:
    .byte 0
ending_kind:
    .byte 0
new_record:
    .byte 0
elapsed:
    .byte 0
ip:
    .byte 0
substep:
    .byte 0
active_op:
    .byte 0
active_arg:
    .byte 0
active_dir:
    .byte 0
cycles_left:
    .byte 0
halt_reason:
    .byte 0
run_lines:
    .byte 0
delivered_run:
    .byte 0
new_best:
    .byte 0
delivery_event:
    .byte 0
event_seq:
    .byte 0
event_arg:
    .byte 0
visible_now:
    .fill 120, 0
ephemeral_end:
.assert "Ephemeral data fits below the UI page", ephemeral_end <= $ca00, true
* = $ca00 "UI and scratch"
mode:
    .byte 0
dirty:
    .byte 0
frame_count:
    .byte 0
cursor:
    .byte 0
scroll_top:
    .byte 0
view_room:
    .byte 0
help_open:
    .byte 0
key:
    .byte 0
target_room:
    .byte 0
target_x:
    .byte 0
target_y:
    .byte 0
target_index:
    .byte 0
target_tile:
    .byte 0
action_error:
    .byte 0
scratch:
    .fill 32, 0
render_row:
    .byte 0
render_col:
    .byte 0
render_tile:
    .byte 0
render_color:
    .byte 0
render_index:
    .byte 0
render_x:
    .byte 0
render_y:
    .byte 0
panel_line:
    .byte 0
text_color:
    .byte 0
number_temp:
    .byte 0
sound_timer:
    .byte 0
sound_kind:
    .byte 0
title_delay:
    .byte 0
title_irq_stage:
    .byte 0
vision_radius:
    .byte 0
vision_min_x:
    .byte 0
vision_max_x:
    .byte 0
vision_min_y:
    .byte 0
vision_max_y:
    .byte 0
vision_x:
    .byte 0
vision_y:
    .byte 0
ray_x:
    .byte 0
ray_y:
    .byte 0
ray_dx:
    .byte 0
ray_dy:
    .byte 0
ray_sx:
    .byte 0
ray_sy:
    .byte 0
ray_err:
    .byte 0
ray_e2:
    .byte 0
ray_compare:
    .byte 0
knowledge_event:
    .byte 0
// Render and HUD bookkeeping. Not part of the engine state.
key_dirty:
    .byte 0
blink_count:
    .byte 0
loop_count:
    .byte 0
run_msg:
    .byte 0
seen_event:
    .byte 0
delivered_mask:
    .byte 0
last_delivery:
    .byte 0
last_delivery_cycle:
    .byte 0
fail_room:
    .byte 0
fail_x:
    .byte 0
fail_y:
    .byte 0
fail_tile:
    .byte 0
field_end:
    .byte 0
field_col:
    .byte 0
field_width:
    .byte 0
buf_pos:
    .byte 0
fmt_sub:
    .byte 0
fmt_op:
    .byte 0
fmt_index:
    .byte 0
panel_index:
    .byte 0
msg_buf:
    .fill 41, 0
// Text pages: intro is set from the title until help closes.
intro:
    .byte 0
cursor_row:
    .byte 0
cursor_col:
    .byte 0
tile_char:
    .byte 0
msg_fresh:
    .byte 0
// 1 after M found no other known room. The next key clears it.
map_note:
    .byte 0
// A record stored in the last cycle, shown by after_tick (0 = none).
show_record:
    .byte 0
// 1 while render_map draws a room that a delivery powered in this loop.
map_powered:
    .byte 0
// Record viewer and reactor image editor.
view_rec:
    .byte 0
img_slot:
    .byte 0
img_state:
    .byte 0
img_choice:
    .byte 0
img_msg:
    .byte 0
img_arg:
    .byte 0
ending_page:
    .byte 0
ui_end:
.assert "UI data fits one page", ui_end <= $cb00, true
* = $cb00 "Auxiliary text"
#import "data/mission-hints.asm"
#import "data/reactor-hints.asm"
auxiliary_end:
.assert "Auxiliary text leaves test status untouched", auxiliary_end <= $cf00, true
