// The starting program only explores: one step south, a SCAN that shows the
// first cell, one step east to stand next to it. The program-end pause
// invites the next lines (PICK E).
.const DEMO_LINES=3
editor_init:
    lda #DEMO_LINES
    sta program_len
    ldx #DEMO_LINES-1
!copy:
    lda demo_op,x
    sta program_op,x
    lda demo_arg,x
    sta program_arg,x
    lda #OP_E
    sta program_dir,x
    dex
    bpl !copy-
    lda #0
    sta cursor
    sta scroll_top
    rts
demo_op: .byte OP_S,OP_SCAN,OP_E
demo_arg: .byte 1,1,1

handle_key:
    // C64 shifted letters produce $c1..$da; accept them too.
    cmp #$c1
    bcc !case+
    cmp #$db
    bcs !case+
    and #$7f
!case:
    sta key
    cmp #135 // F5: global music toggle; effects remain enabled.
    bne !mode+
    jmp music_toggle
!mode:
    lda mode
    cmp #MODE_TITLE
    bne !normal+
    lda key
    cmp #32
    bne !titleReturn+
    lda title_delay
    bne !titleReturn+
    jsr leave_title
    lda #DIRTY_ALL
    sta key_dirty
    lda #MODE_PLAN
    sta mode
    lda robot_room
    sta view_room
    // New game: briefing 1, briefing 2, help, then the game.
    lda #PAGE_BRIEF1
    sta help_open
    lda #1
    sta intro
!titleReturn:
    rts
!normal:
    lda help_open
    beq !game+
    // SPACE confirms text pages; in the game it steps one cycle.
    lda key
    cmp #32
    bne !page+
    lda #13
    sta key
!page:
    jmp page_key
!game:
    lda key
!help:
    cmp #72 // H
    bne !logs+
    lda #DIRTY_ALL
    sta key_dirty
    lda #PAGE_EDITOR
    sta help_open
    rts
!logs:
    cmp #86 // V: console records, at any time like help
    bne !image+
    lda #DIRTY_ALL
    sta key_dirty
    lda #0
    sta view_rec
    lda #PAGE_RECORD
    sta help_open
    rts
!image:
    // K: the reactor control image, in PLAN after the reactor service record.
    cmp #75
    bne !global+
    lda mode
    bne !global+
    lda story_flags
    and #FLAG_OBJECTIVE
    beq !global+
    lda #DIRTY_ALL
    sta key_dirty
    lda #0
    sta img_state
    lda #PAGE_IMAGE
    sta help_open
    rts
!global:
    // M while a program runs or pauses: the map needs PLAN. Say so.
    lda key
    cmp #77
    bne !f7+
    lda mode
    beq !f7+
    cmp #MODE_HALT
    beq !f7+
    lda #2
    sta map_note
    lda #DIRTY_FOOTER
    sta key_dirty
    rts
!f7:
    lda key
    cmp #136 // F7: abort and reset
    bne !run+
    jmp reset_loop
!run:
    cmp #133 // F1
    bne !step+
    jsr can_retry_halt
    beq !runMode+
    jsr prepare_error_edit
!runMode:
    lda mode
    cmp #MODE_STEP
    beq !resume+
    jsr begin_run
!resume:
    jsr continue_end
    lda #MODE_RUN
    sta mode
    lda #0
    sta frame_count
    rts
!step:
    cmp #134 // F3 / SPACE: one logical cycle
    beq !doStep+
    cmp #32
    bne !editGate+
!doStep:
    jsr can_retry_halt
    beq !stepMode+
    jsr prepare_error_edit
!stepMode:
    lda mode
    cmp #MODE_PLAN
    beq !freshStep+
    cmp #MODE_HALT
    bne !oneStep+
!freshStep:
    jsr begin_run
!oneStep:
    jsr continue_end
    lda #MODE_STEP
    sta mode
    jsr vm_tick
    jsr after_tick
    rts
!editGate:
    lda mode
    beq !edit+
    jsr end_pause
    beq !halted+
!edit:
    jmp editor_key
!halted:
    lda mode
    cmp #MODE_HALT
    bne !done+
    jsr can_retry_halt
    beq !finished+
    jsr prepare_error_edit
    lda key
    cmp #13
    beq !done+
    jsr editor_key
    lda #DIRTY_PARTS
    sta key_dirty
    rts
!finished:
    lda key
    cmp #13
    bne !done+
    jmp reset_loop
!done:
    rts

// A failed action pauses the program while the physical loop still has time.
can_retry_halt:
    lda mode
    cmp #MODE_HALT
    bne !no+
    lda elapsed
    cmp #64
    bcs !no+
    ldx halt_reason
    lda halt_is_failure,x
    rts
!no:
    lda #0
    rts

prepare_error_edit:
    lda #0
    sta cycles_left
    sta substep
    sta action_error
    lda #HALT_EDIT
    sta halt_reason
    lda #MODE_STEP
    sta mode
    lda ip
    sta cursor
    lda #DIRTY_PARTS
    sta key_dirty
    jmp editor_scroll

// Ends the loop: the facility resets, and the editor shows the start state.
// RETURN after a final halt and F7 at any time. Records not viewed yet
// open in the viewer, the first one first.
reset_loop:
    // After a failed line, the editor cursor goes to that line.
    jsr run_failed
    beq !world+
    lda ip
    cmp program_len
    bcs !world+
    sta cursor
!world:
    jsr reset_ephemeral_world
    jsr sound_rewind
    lda #MODE_PLAN
    sta mode
    lda robot_room
    sta view_room
    jsr first_unread
    beq !scroll+
    stx view_rec
    lda #PAGE_RECORD
    sta help_open
    lda #DIRTY_ALL
    sta key_dirty
!scroll:
    jmp editor_scroll
// Command reacts after each cycle: a transmission is stored (not viewed yet)
// when both of its conditions are met. A condition is a byte AND mask != 0.
check_transmissions:
    ldx #RECORD_COUNT-FIRST_TRANSMISSION
!next:
    lda trans_a_lo,x
    sta data_ptr
    lda trans_a_hi,x
    sta data_ptr+1
    ldy #0
    lda (data_ptr),y
    and trans_a_mask,x
    beq !skip+
    lda trans_b_lo,x
    sta data_ptr
    lda trans_b_hi,x
    sta data_ptr+1
    lda (data_ptr),y
    and trans_b_mask,x
    beq !skip+
    lda rec_known+FIRST_TRANSMISSION,x
    bne !skip+
    lda #2
    sta rec_known+FIRST_TRANSMISSION,x
!skip:
    dex
    bpl !next-
    lda #0
    rts
// Transmissions 15-24. Condition A and condition B (B repeats A when there is
// only one condition).
trans_a_lo: .byte <mission_done,<credentials,<(mission_done+1),<(rec_known+3),<firmware,<(mission_done+3),<(rec_known+8),<(rec_known+6),<(rec_known+9),<(rec_known+9)
trans_a_hi: .byte >mission_done,>credentials,>(mission_done+1),>(rec_known+3),>firmware,>(mission_done+3),>(rec_known+8),>(rec_known+6),>(rec_known+9),>(rec_known+9)
trans_a_mask: .byte 1,CRED_ORBIT,1,$ff,FW_PULSE,1,$ff,$ff,$ff,$ff
trans_b_lo: .byte <mission_done,<credentials,<credentials,<(rec_known+3),<firmware,<(mission_done+3),<(rec_known+8),<(rec_known+6),<(rec_known+8),<(rec_known+10)
trans_b_hi: .byte >mission_done,>credentials,>credentials,>(rec_known+3),>firmware,>(mission_done+3),>(rec_known+8),>(rec_known+6),>(rec_known+8),>(rec_known+10)
trans_b_mask: .byte 1,CRED_ORBIT,CRED_ZENITH,$ff,FW_PULSE,1,$ff,$ff,$ff,$ff
// Returns X = first record not viewed yet, Z clear when there is one.
first_unread:
    ldx #1
!test:
    lda rec_known,x
    cmp #2
    beq !found+
    inx
    cpx #RECORD_COUNT+1
    bne !test-
    lda #0
    rts
!found:
    lda #1
    rts

// Continues an end-of-program or corrected-command pause in the same loop.
continue_end:
    lda halt_reason
    cmp #HALT_END
    beq !clear+
    cmp #HALT_EDIT
    bne !done+
!clear:
    lda #0
    sta halt_reason
    lda program_len
    sta run_lines
!done:
    rts

// SPACE/RETURN advances pages; RUN/STOP skips the briefing to help.
// LEFT/RIGHT switches help pages; SPACE/RETURN or H returns to the game.
// The game state behind the page does not change.
page_key:
    lda help_open
    cmp #PAGE_ROBOT_DESTROYED
    bne !clockReset+
    jmp dismiss_laser_notice
!clockReset:
    cmp #PAGE_LOOP_RESET
    bne !shortcuts+
    // Consume the acknowledging key without also editing or starting a run.
    lda #0
    sta help_open
    lda #DIRTY_ALL
    sta key_dirty
    jmp reset_loop
!shortcuts:
    jsr help_shortcuts
    bcc !normal+
    rts
!normal:
    lda help_open
    cmp #PAGE_RECORD
    bne !image+
    jmp record_key
!image:
    cmp #PAGE_IMAGE
    bne !ending+
    jmp image_key
!ending:
    cmp #PAGE_LEGEND
    beq !intro+
    cmp #PAGE_EDITOR
    beq !intro+
    cmp #PAGE_END_GOOD
    bcc !intro+
    // An ending page: RETURN reconnects the console to a fresh loop.
    lda key
    cmp #13
    beq !reconnect+
    lda #0
    sta key_dirty
    rts
!reconnect:
    lda #0
    sta help_open
    lda #DIRTY_ALL
    sta key_dirty
    jmp reset_loop
!intro:
    lda key
    cmp #13
    beq !next+
    cmp #72 // H
    beq !close+
    // Either arrow navigates Editor, Commands and Tiles.
    cmp #29
    beq !navigate+
    cmp #157
    bne !stop+
!navigate:
    jsr navigate_help
    bcc !ignore+
    bcs !redraw+
!stop:
    cmp #3 // RUN/STOP
    bne !ignore+
    lda help_open
    cmp #PAGE_EDITOR
    beq !ignore+
    lda #PAGE_EDITOR
    sta help_open
    bne !redraw+
!next:
    lda help_open
    cmp #PAGE_BRIEF1
    bne !brief2+
    lda #PAGE_BRIEF2
    sta help_open
    bne !redraw+
!brief2:
    cmp #PAGE_BRIEF2
    bne !close+
    lda #PAGE_EDITOR
    sta help_open
    bne !redraw+
!close:
    lda help_open
    cmp #PAGE_LEGEND
    beq !leave+
    cmp #PAGE_EDITOR
    beq !leave+
    cmp #PAGE_HELP
    bne !ignore+
!leave:
    lda #0
    sta help_open
    sta intro
!redraw:
    lda #DIRTY_ALL
    sta key_dirty
    rts
!ignore:
    lda #0
    sta key_dirty
    rts

// Returns A=1 (Z clear) while a program runs or steps, else A=0.
in_run:
    lda mode
    cmp #MODE_RUN
    beq !yes+
    cmp #MODE_STEP
    beq !yes+
    lda #0
    rts
!yes:
    lda #1
    rts
// Record viewer: LEFT/RIGHT browse the mission log (0) and the known records.
// RETURN shows the next record not viewed yet, then returns to the game.
// V or RUN/STOP return at once. F1 can resume a running or stepping program;
// RETURN first shows every queued message, then returns to the same run.
record_key:
    lda #DIRTY_ALL
    sta key_dirty
    jsr in_run
    beq !keys+
    lda key
    cmp #133
    beq !close+
!keys:
    lda key
    cmp #29
    beq !right+
    cmp #157
    beq !left+
    cmp #13
    bne !other+
    jsr first_unread
    beq !close+
    stx view_rec
    rts
!other:
    cmp #86
    beq !close+
    cmp #3
    beq !close+
    // F1, F3 and F7 close the viewer and act at once.
    cmp #133
    beq !act+
    cmp #134
    beq !act+
    cmp #136
    beq !act+
    lda #0
    sta key_dirty
    rts
!close:
    lda #0
    sta help_open
    lda halt_reason
    cmp #HALT_CLOCK
    bne !closed+
    jmp show_reset_notice
!closed:
    rts
!act:
    lda #0
    sta help_open
    lda key
    jsr handle_key
    lda key_dirty
    ora #DIRTY_ALL
    sta key_dirty
    rts
!right:
    ldx view_rec
!up:
    inx
    cpx #RECORD_COUNT+1
    bcc !known+
    ldx #0
!known:
    txa
    beq !show+
    lda rec_known,x
    beq !up-
!show:
    stx view_rec
    rts
!left:
    ldx view_rec
!down:
    dex
    bpl !knownLeft+
    ldx #RECORD_COUNT
!knownLeft:
    txa
    beq !show-
    lda rec_known,x
    beq !down-
    stx view_rec
    rts

// Only automatic cycle exhaustion calls this; F7/reset_loop bypass it.
show_reset_notice:
    lda #PAGE_LOOP_RESET
show_reset_page:
    sta help_open
    lda #DIRTY_ALL
    sta key_dirty
    lda dirty
    ora #DIRTY_ALL
    sta dirty
    rts

// Reactor image editor. img_state 0 = edit, 1 = hard error shown,
// 2 = warning with EXECUTE? YES / NO (default NO).
image_key:
    lda #DIRTY_ALL
    sta key_dirty
    lda img_state
    cmp #2
    beq !confirm+
    cmp #1
    bne !edit+
    // Any key acknowledges a hard error.
    lda #0
    sta img_state
    rts
!confirm:
    lda key
    cmp #29
    beq !toggle+
    cmp #157
    beq !toggle+
    cmp #89 // Y
    beq !yes+
    cmp #78 // N
    beq !no+
    cmp #13
    bne !done+
    lda img_choice
    bne !yes+
!no:
    lda #0
    sta img_state
!done:
    rts
!toggle:
    lda img_choice
    eor #1
    sta img_choice
    rts
!yes:
    jmp authorize_image
!edit:
    // Slot and command changes redraw only the slots.
    lda #DIRTY_SLOTS
    sta key_dirty
    ldx img_slot
    lda key
    cmp #145
    beq !slotUp+
    cmp #17
    beq !slotDown+
    cmp #29
    beq !next+
    cmp #157
    beq !prev+
    cmp #20
    beq !clear+
    cmp #13
    beq !check+
    cmp #75 // K
    beq !close+
    cmp #3
    beq !close+
    lda #0
    sta key_dirty
    rts
!close:
    lda #DIRTY_ALL
    sta key_dirty
    lda #0
    sta help_open
    rts
!slotUp:
    dex
    bpl !slot+
    ldx #IMAGE_SLOTS-1
!slot:
    stx img_slot
    rts
!slotDown:
    inx
    cpx #IMAGE_SLOTS
    bcc !slot-
    ldx #0
    beq !slot-
!next:
    lda image,x
    clc
    adc #1
    cmp #RC_SHUTDOWN+1
    bcc !store+
    lda #0
!store:
    sta image,x
    rts
!prev:
    lda image,x
    sec
    sbc #1
    bcs !store-
    lda #RC_SHUTDOWN
    bne !store-
!clear:
    lda #0
    beq !store-
!check:
    lda #DIRTY_ALL
    sta key_dirty
    jsr image_check
    rts

// Firmware check before RUN. Hard errors return to editing. A dangerous or
// incompatible order asks EXECUTE? with NO selected. A clean image runs.
image_check:
    ldx #IMAGE_SLOTS-1
    lda #0
    sta img_arg
!scan:
    lda image,x
    beq !nextSlot+
    inc img_arg
    tay
    lda image_needs,y
    beq !nextSlot+
    and firmware
    bne !nextSlot+
    sty img_arg
    lda #1
    sta img_msg
    sta img_state
    rts
!nextSlot:
    dex
    bpl !scan-
    lda img_arg
    bne !eval+
    lda #0
    sta img_msg
    lda #1
    sta img_state
    rts
!eval:
    jsr reactor_eval
    tax
    lda outcome_warning,x
    beq authorize_image
    sta img_msg
    lda #0
    sta img_choice
    lda #2
    sta img_state
    rts
// YES, or no warning: authorize the image and start the robot program.
authorize_image:
    lda #0
    sta img_state
    sta help_open
    lda #DIRTY_ALL
    sta key_dirty
    jsr begin_run
    lda #1
    sta image_authorized
    lda #MODE_RUN
    sta mode
    lda #0
    sta frame_count
    rts
// Firmware bit each reactor command needs (0 = always available).
image_needs: .byte 0,FW_FEEDBACK,FW_PULSE,FW_ROUTE,0,0
// Warning per outcome: 0 = none, else the warning text index.
outcome_warning: .byte 0,1,2,3,3,0

// A fresh experiment: reset the world and count the loop for the HUD.
begin_run:
    jsr reset_ephemeral_world
    lda loop_count
    cmp #99
    bcs !counted+
    inc loop_count
!counted:
    lda #0
    sta run_msg
    sta delivered_mask
    lda event_seq
    sta seen_event
    rts

editor_key:
    // Edits change only the program list and the info rows.
    lda #(DIRTY_PROGRAM+DIRTY_INFO)
    sta key_dirty
    lda key
    cmp #145
    bne !down+
    lda cursor
    beq !locked+
    dec cursor
    jmp editor_scroll
!down:
    cmp #17
    bne !plan+
    jmp editor_next
!plan:
    lda mode
    beq !map+
    // Paused at the program end: lines that already ran stay unchanged.
    lda cursor
    cmp ip
    bcs !delete+
!locked:
    rts
!map:
    lda key
    cmp #77 // M: inspect a discovered room without changing world state
    bne !delete+
    lda #DIRTY_PARTS
    sta key_dirty
    ldx view_room
!room:
    inx
    cpx #ROOM_COUNT
    bcc !known+
    ldx #0
!known:
    lda room_known,x
    beq !room-
    // Only one room known: say so instead of showing the same map.
    cpx view_room
    bne !view+
    lda #1
    sta map_note
!view:
    stx view_room
    rts
!delete:
    lda key
    cmp #20
    bne !insert+
    jmp editor_delete
!insert:
    cmp #73 // I
    beq !doInsert+
    cmp #148
    bne !commit+
!doInsert:
    jmp editor_insert
!commit:
    cmp #13
    bne !arg+
    jsr editor_coalesce
    jmp editor_next
!arg:
    ldx cursor
    cpx program_len
    bcs !command+
    lda key
    cmp #29
    beq !right+
    cmp #157
    beq !left+
    cmp #43
    beq !plus+
    cmp #45
    beq !minus+
    cmp #49
    bcc !command+
    cmp #58
    bcs !command+
    sec
    sbc #48
    sta program_arg,x
!done:
    rts
!right:
    // A move or WAIT has no direction to turn: RIGHT raises its count.
    jsr arrow_count
    bcs !plus+
    inc program_dir,x
    lda program_dir,x
    and #3
    sta program_dir,x
    rts
!left:
    // A move or WAIT: LEFT lowers its count.
    jsr arrow_count
    bcs !minus+
    dec program_dir,x
    lda program_dir,x
    and #3
    sta program_dir,x
    rts
!plus:
    lda program_arg,x
    cmp #15
    bcs !done-
    inc program_arg,x
    rts
!minus:
    lda program_arg,x
    cmp #2
    bcc !done-
    dec program_arg,x
    rts
!command:
    ldx #OP_COUNT-1
!search:
    lda command_keys,x
    cmp key
    beq !found+
    dex
    bpl !search-
    rts
!found:
    // BOOST needs PULSE firmware, LINK needs ROUTE.
    lda command_firmware,x
    beq !free+
    and firmware
    beq !return+
!free:
    stx scratch
    ldx cursor
    cpx #32
    bcs !return+
    cpx program_len
    bcc !set+
    inc program_len
!set:
    lda scratch
    sta program_op,x
    lda #1
    sta program_arg,x
    sta program_dir,x
!return:
    rts
// X = line. Carry set when LEFT/RIGHT change the count of that line: a move
// (NORTH, EAST, SOUTH, WEST) or WAIT. Other lines turn their direction.
arrow_count:
    lda program_op,x
    cmp #OP_PICK
    bcc !yes+
    cmp #OP_WAIT
    beq !yes+
    clc
    rts
!yes:
    sec
    rts
command_keys: .byte 78,69,83,87,80,68,84,67,82,65,66,76
command_firmware: .byte 0,0,0,0,0,0,0,0,0,0,FW_PULSE,FW_ROUTE

editor_next:
    lda cursor
    cmp program_len
    bcs editor_scroll
    cmp #31
    bcs editor_scroll
    inc cursor
editor_scroll:
    lda cursor
    cmp scroll_top
    bcs !bottom+
    sta scroll_top
!bottom:
    sec
    sbc scroll_top
    cmp #12
    bcc !return+
    lda cursor
    sec
    sbc #11
    sta scroll_top
!return:
    rts

editor_insert:
    lda program_len
    cmp #32
    bcs !return+
    tax
!shift:
    cpx cursor
    beq !insert+
    lda program_op-1,x
    sta program_op,x
    lda program_arg-1,x
    sta program_arg,x
    lda program_dir-1,x
    sta program_dir,x
    dex
    jmp !shift-
!insert:
    lda #OP_EMPTY
    sta program_op,x
    lda #1
    sta program_arg,x
    sta program_dir,x
    inc program_len
!return:
    rts
editor_delete:
    ldx cursor
    cpx program_len
    bcs !return+
    dec program_len
!shift:
    cpx program_len
    bcs !return+
    lda program_op+1,x
    sta program_op,x
    lda program_arg+1,x
    sta program_arg,x
    lda program_dir+1,x
    sta program_dir,x
    inx
    jmp !shift-
!return:
    rts
// Commit merges the selected MOVE with the preceding MOVE when possible.
// Cursor navigation alone deliberately preserves a split for debugging.
editor_coalesce:
    ldx cursor
    beq !return+
    lda mode
    beq !plan+
    // At the program end pause, never merge into a line that already ran.
    cpx ip
    beq !return+
!plan:
    cpx program_len
    bcs !return+
    lda program_op,x
    cmp #4
    bcs !return+
    cmp program_op-1,x
    bne !return+
    lda program_arg,x
    clc
    adc program_arg-1,x
    cmp #10
    bcs !return+
    sta program_arg-1,x
    jsr editor_delete
    dec cursor
!return:
    rts
