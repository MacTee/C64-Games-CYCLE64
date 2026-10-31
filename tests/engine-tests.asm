// Directed shipping-engine regression tests. Private CPU RAM under KERNAL.
.var test_return_pc=*
*=$e000 "Engine regression harness"
.macro Check(address,value) {
    lda address
    cmp #value
    beq !ok+
    lda test_id
    sta $cf01
    jmp tests_done
!ok:
    inc $cf02
    bne !counted+
    inc $cf03
!counted:
}
.macro Put(address,value) {
    lda #value
    sta address
}
.macro At(room,x,y,dir) {
    :Put(robot_room,room)
    :Put(robot_x,x)
    :Put(robot_y,y)
    :Put(active_dir,dir)
    :Put(action_error,0)
    :Put(show_record,0)
}
.macro CarryCell(id) {
    :Put(held,id)
    :Put(cargo_room+id,254)
}
.macro Fresh() {
    jsr session_init
    jsr editor_init
    jsr reset_ephemeral_world
    :Put(mode,MODE_PLAN)
    :Put(help_open,0)
}
test_start:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    sta $cf00
    sta $cf01
    sta $cf02
    sta $cf03
    :Put(test_id,1)
    :Fresh()
    :Check(robot_x,3)
    :Check(robot_y,1)
    :Check(live_tiles+3*120+114,TILE_DOOR)
    :Check(live_tiles+3*120+102,TILE_FLOOR)
    :Check(live_tiles+3*120+100,TILE_SOCKET)
    :Check(live_tiles+2*120+92,TILE_SOCKET)
    :Check(live_tiles+4*120+98,TILE_SOCKET)
    :Check(live_tiles+3*120+22,TILE_LIBRARY)
    :Check(live_tiles+3*120+85,TILE_TERMINAL)
    :Check(live_tiles+7*120+118,TILE_HATCH)
    // Default program and genuinely empty lines retain their costs.
    inc test_id
    jsr test_run_to_halt
    :Check(elapsed,4)
    :Check(robot_x,4)
    :Check(robot_y,2)
    :Check(halt_reason,HALT_END)
    :Fresh()
    jsr editor_insert
    :Check(program_op,OP_EMPTY)
    :Check(program_len,4)
    jsr test_run_to_halt
    :Check(elapsed,4)
    :Check(robot_x,4)
    // Removed keys do not change program, cursor or physical state.
    inc test_id
    :Fresh()
    :Put(robot_x,4)
    :Put(elapsed,9)
    lda #90
    jsr handle_key
    lda #85
    jsr handle_key
    lda #88
    jsr handle_key
    lda #135
    jsr handle_key
    :Check(program_len,3)
    :Check(robot_x,4)
    :Check(elapsed,9)
    :Check(mode,MODE_PLAN)
    :Put(cursor,11)
    jsr editor_scroll
    :Check(scroll_top,0)
    :Put(cursor,12)
    jsr editor_scroll
    :Check(scroll_top,1)
    // DROP floor, blocked targets and PICK preserve the actual cell.
    inc test_id
    :Fresh()
    :CarryCell(0)
    :At(0,2,5,OP_E)
    jsr world_drop
    :Check(action_error,0)
    :Check(cargo_room,0)
    :Check(cargo_x,3)
    :Check(cargo_y,5)
    :Check(held,255)
    jsr world_pick
    :Check(held,0)
    :Check(cargo_room,254)
    :At(0,5,3,OP_E)
    jsr world_drop
    :Check(action_error,HALT_BLOCKED)
    :Check(held,0)
    // Dock power -> note -> ORBIT; pickup depowers but preserves knowledge.
    inc test_id
    :At(0,2,7,OP_W)
    jsr world_drop
    :Check(powered_mask,1)
    :Check(mission_done,1)
    :Check(cargo_room,0)
    :At(0,9,1,OP_E)
    jsr world_read
    :Check(rec_known+13,2)
    :Check(credentials,0)
    :Check(show_record,13)
    :At(0,2,7,OP_W)
    jsr world_pick
    :Check(powered_mask,0)
    :Check(mission_done,1)
    :Check(held,0)
    :At(0,9,1,OP_E)
    jsr world_read
    :Check(action_error,0)
    :Check(event_arg,INS_TERMINAL_OFF)
    :Check(show_record,0)
    // Workshop requires a cell and a discovered panel; rereads reopen data.
    inc test_id
    :Put(dev_found,1)
    :At(1,7,4,OP_N)
    jsr world_read
    :Check(event_arg,INS_TERMINAL_OFF)
    :Check(rec_known+1,0)
    :At(1,7,2,OP_N)
    jsr world_drop
    :Check(powered_mask,2)
    :Check(mission_done+1,0)
    :At(1,7,4,OP_N)
    jsr world_read
    :Check(show_record,1)
    :Check(credentials,CRED_ORBIT)
    :Put(show_record,0)
    jsr world_read
    :Check(show_record,1)
    :At(1,7,2,OP_N)
    jsr world_pick
    :Check(powered_mask,0)
    // Hub camera is independently powered by its new socket.
    inc test_id
    :At(2,9,6,OP_S)
    jsr world_read
    :Check(event_arg,INS_TERMINAL_OFF)
    :Check(rec_known+14,0)
    :At(2,8,6,OP_S)
    jsr world_drop
    :Check(powered_mask,16)
    :At(2,9,6,OP_S)
    jsr world_read
    :Check(show_record,14)
    :Check(credentials,CRED_ORBIT+CRED_ZENITH)
    :At(2,8,6,OP_S)
    jsr world_pick
    :Check(powered_mask,0)
    :At(2,9,6,OP_S)
    jsr world_read
    :Check(event_arg,INS_TERMINAL_OFF)
    // Junction needs both live cells. One lights it; two open boundary exit.
    inc test_id
    :At(3,2,8,OP_E)
    jsr world_drop
    :Check(powered_mask,4)
    :Check(live_tiles+3*120+114,TILE_DOOR)
    :Check(mission_done+3,0)
    :Check(discovered+3*120+22,1)
    :CarryCell(2)
    :At(3,5,8,OP_W)
    jsr world_drop
    :Check(powered_mask,12)
    :Check(live_tiles+3*120+114,TILE_EXIT)
    :Check(mission_done+3,1)
    :Check(cargo_room+2,3)
    jsr world_pick
    :Check(powered_mask,4)
    :Check(live_tiles+3*120+114,TILE_DOOR)
    :Check(mission_done+3,1)
    :At(5,6,1,OP_N)
    lda #OP_N
    jsr world_move_dir
    :Check(action_error,HALT_WALL)
    :Check(robot_room,5)
    :At(3,5,8,OP_W)
    jsr world_drop
    :At(3,6,8,OP_S)
    lda #OP_S
    jsr world_move_dir
    :Check(robot_room,5)
    :Check(robot_x,6)
    :Check(robot_y,1)
    // Archive power reveals the main room but never the separate vault.
    inc test_id
    :Fresh()
    :At(4,1,7,OP_S)
    jsr world_read
    :Check(event_arg,INS_LIBRARY_OFF)
    :Check(firmware,0)
    :CarryCell(0)
    :At(4,2,7,OP_S)
    jsr world_drop
    :Check(powered_mask,32)
    :Check(discovered+4*120+97,1)
    :Check(discovered+4*120+21,0)
    :Check(discovered+4*120+45,0)
    :Check(discovered+4*120+31,0)
    :At(4,1,7,OP_S)
    jsr world_read
    :Check(firmware,FW_ROUTE)
    :Check(show_record,5)
    :At(4,9,6,OP_S)
    jsr world_read
    :Check(show_record,11)
    jsr world_link
    :Check(linked,1)
    :Check(robot_room,4)
    :Check(robot_x,VAULT_X)
    :Check(robot_y,VAULT_Y)
    // The enlarged vault has its own cell/socket and independent equipment.
    :Check(live_tiles+4*120+17,TILE_FLOOR)
    :Check(live_tiles+4*120+34,TILE_SOCKET)
    :Check(live_tiles+4*120+45,TILE_FLOOR)
    :Check(live_tiles+4*120+57,TILE_LIBRARY)
    :Check(live_tiles+4*120+79,TILE_FLOOR)
    :Check(live_tiles+4*120+93,TILE_UPLINK)
    :Check(cargo_room+1,4)
    :Check(cargo_x+1,5)
    :Check(cargo_y+1,1)
    :Check(discovered+4*120+57,0)
    :At(4,9,3,OP_S)
    jsr world_read
    :Check(event_arg,INS_LIBRARY_OFF)
    :Check(rec_known+7,0)
    :At(4,9,2,OP_N)
    jsr world_read
    :Check(event_arg,INS_TERMINAL_OFF)
    :Check(rec_known+6,0)
    :At(4,5,2,OP_N)
    jsr world_pick
    :Check(held,1)
    :Check(powered_mask,32)
    :At(4,10,3,OP_N)
    jsr world_drop
    :Check(held,255)
    :Check(powered_mask,160)
    :Check(discovered+4*120+57,1)
    :At(4,9,2,OP_N)
    jsr world_read
    :Check(rec_known+6,2)
    :At(4,9,3,OP_S)
    jsr world_read
    :Check(rec_known+7,2)
    :Check(firmware,FW_ROUTE+FW_FEEDBACK)
    :At(4,10,3,OP_N)
    jsr world_pick
    :Check(powered_mask,32)
    :At(4,9,3,OP_S)
    jsr world_read
    :Check(event_arg,INS_LIBRARY_OFF)
    :Check(firmware,FW_ROUTE+FW_FEEDBACK)
    :At(4,6,2,OP_N)
    jsr world_drop
    :Check(powered_mask,32)
    :At(4,2,7,OP_S)
    jsr world_pick
    :Check(powered_mask,0)
    :Put(linked,0)
    :At(4,9,6,OP_S)
    jsr world_link
    :Check(action_error,HALT_OFFLINE)
    :Check(linked,0)
    :At(4,1,7,OP_S)
    jsr world_read
    :Check(event_arg,INS_LIBRARY_OFF)
    // Any actual cell can power Archive; no mission-specific consumption.
    :CarryCell(2)
    :At(4,2,7,OP_S)
    jsr world_drop
    :Check(powered_mask,32)
    :Check(cargo_room+2,4)
    // Dock hatch requires discovery, ORBIT and a cell on its east socket.
    inc test_id
    :Fresh()
    :Put(dev_found+4,1)
    :At(0,8,8,OP_S)
    jsr world_access
    :Check(action_error,HALT_CREDENTIAL)
    :Put(credentials,CRED_ORBIT)
    :Put(action_error,0)
    jsr world_access
    :Check(action_error,HALT_HATCH_POWER)
    :CarryCell(0)
    :At(0,9,8,OP_E)
    jsr world_drop
    :Check(powered_mask,64)
    :At(0,8,8,OP_S)
    jsr world_access
    :Check(action_error,0)
    :Check(live_tiles+116,TILE_EXIT)
    :At(0,9,8,OP_E)
    jsr world_pick
    :Check(powered_mask,0)
    :Check(live_tiles+116,TILE_HATCH)
    // Duct end is a visible FEEDBACK hatch and becomes an exit after ACCESS.
    inc test_id
    :At(7,10,8,OP_S)
    jsr world_read
    :Check(event_arg,INS_HATCH_FEEDBACK)
    jsr world_access
    :Check(action_error,HALT_FIRMWARE)
    :Check(live_tiles+7*120+118,TILE_HATCH)
    :Put(firmware,FW_FEEDBACK)
    :Put(action_error,0)
    jsr world_access
    :Check(action_error,0)
    :Check(live_tiles+7*120+118,TILE_EXIT)
    lda #OP_S
    jsr world_move_dir
    :Check(robot_room,5)
    :Check(robot_x,1)
    :Check(robot_y,4)
    // Eight ON, two OFF, repeated through all 64 cycle samples.
    inc test_id
    :Put(test_cycle,0)
!phase:
    lda test_cycle
    ldx #5
    jsr laser_phase
    lda #0
    rol
    sta test_actual
    ldx test_cycle
    lda test_phase_expected,x
    cmp test_actual
    beq !goodPhase+
    lda test_id
    sta $cf01
    jmp tests_done
!goodPhase:
    inc $cf02
    bne !counted+
    inc $cf03
!counted:
    inc test_cycle
    lda test_cycle
    cmp #64
    bne !phase-
    :At(5,5,4,OP_N)
    :Put(elapsed,7)
    jsr laser_check
    :Check(action_error,HALT_LASER)
    :Put(elapsed,8)
    :Put(action_error,0)
    jsr laser_check
    :Check(action_error,0)
    :Put(elapsed,10)
    jsr laser_check
    :Check(action_error,HALT_LASER)
    :At(3,5,5,OP_N)
    :Put(elapsed,4)
    jsr laser_check
    :Check(action_error,0)
    :Put(elapsed,0)
    jsr laser_check
    :Check(action_error,HALT_LASER)
    // Every tile ID is readable without a failed command or out-of-range table.
    inc test_id
    :Fresh()
    :At(0,3,4,OP_E)
    :Put(test_tile,0)
!readTile:
    lda test_tile
    sta live_tiles+52
    jsr world_read
    :Check(action_error,0)
    :Check(knowledge_event,EV_INSPECT)
    inc test_tile
    lda test_tile
    cmp #TILE_COUNT
    bne !readTile-
    :Put(live_tiles+52,TILE_FLOOR)
    jsr world_read
    :Check(event_arg,TILE_FLOOR)
    :At(0,0,4,OP_W)
    jsr world_read
    :Check(event_arg,INS_EDGE)
    // Failed commands consume their attempt, then editing preserves the loop.
    inc test_id
    :Fresh()
    :Put(program_len,1)
    :Put(program_op,OP_DROP)
    :Put(program_dir,OP_E)
    jsr vm_tick
    jsr after_tick
    :Check(halt_reason,HALT_EMPTY)
    :Check(mode,MODE_HALT)
    :Check(elapsed,1)
    lda #13
    jsr handle_key
    :Check(mode,MODE_STEP)
    :Check(halt_reason,HALT_EDIT)
    :Check(elapsed,1)
    :Check(robot_x,3)
    :Put(program_op,OP_WAIT)
    :Put(program_arg,1)
    lda #134
    jsr handle_key
    :Check(elapsed,2)
    :Check(halt_reason,HALT_END)
    // All full access-code names fit the mission-log field.
    inc test_id
    :Put(credentials,7)
    jsr build_codes
    :Check(buf_pos,26)
    :Check(msg_buf,3)
    :Check(msg_buf+6,15)
    :Check(msg_buf+12,26)
    :Check(msg_buf+19,22)
    :Check(msg_buf+25,32)
    // Show the battery as its own combined glyph, never colour alone.
    :Put(render_tile,TILE_SOCKET)
    ldx #0
    jsr cargo_tile
    sta test_actual
    :Check(test_actual,TILE_SOCKET_CELL)
    :Put(render_tile,TILE_FLOOR)
    jsr cargo_tile
    sta test_actual
    :Check(test_actual,TILE_CELL)
    // Knowing ORBIT and reading terminals does not finish M2; ACCESS does.
    inc test_id
    :Fresh()
    :Check(live_tiles+3*120+92,TILE_FLOOR)
    :Check(live_tiles+3*120+93,TILE_FLOOR)
    :Check(live_tiles+46,TILE_FLOOR)
    :Check(live_tiles+106,TILE_SOCKET)
    :Put(credentials,CRED_ORBIT)
    :Check(mission_done+MISSION_HUB,0)
    :At(2,3,4,OP_E)
    :Put(elapsed,20)
    jsr world_access
    :Check(mission_done+MISSION_HUB,1)
    :Check(best_ticks+MISSION_HUB,21)
    :Check(robot_x,3)
    :Check(live_tiles+2*120+52,TILE_FLOOR)
    // First physical Junction entry, rather than map knowledge or socket power.
    inc test_id
    :Fresh()
    :Put(room_known+3,1)
    :Check(mission_done+MISSION_JUNCTION,0)
    :Put(credentials,CRED_ZENITH)
    :At(1,3,8,OP_S)
    jsr world_access
    :Put(elapsed,9)
    lda #OP_S
    jsr world_move_dir
    :Check(robot_room,3)
    :Check(robot_y,1)
    :Check(mission_done+MISSION_JUNCTION,1)
    :Check(best_ticks+MISSION_JUNCTION,10)
    :Check(mission_done+MISSION_DOOR,0)
    jsr reset_ephemeral_world
    :Check(robot_room,START_ROOM)
    :Check(robot_x,START_X)
    :Check(robot_y,START_Y)
    :Check(mission_done+MISSION_JUNCTION,1)
    // Failed ending time never replaces a secured result, even when faster.
    inc test_id
    :Put(elapsed,11)
    :Put(ending_kind,OUT_SHUTDOWN)
    jsr record_ending
    :Check(mission_done+MISSION_REACTOR,2)
    :Check(best_ticks+MISSION_REACTOR,12)
    :Put(elapsed,49)
    :Put(ending_kind,OUT_GOOD)
    jsr record_ending
    :Check(mission_done+MISSION_REACTOR,1)
    :Check(best_ticks+MISSION_REACTOR,50)
    :Put(elapsed,1)
    :Put(ending_kind,OUT_RELEASE)
    jsr record_ending
    :Check(mission_done+MISSION_REACTOR,1)
    :Check(best_ticks+MISSION_REACTOR,50)
    :Put(elapsed,39)
    :Put(ending_kind,OUT_GOOD)
    jsr record_ending
    :Check(best_ticks+MISSION_REACTOR,40)
    jsr reset_ephemeral_world
    :Check(mission_done+MISSION_REACTOR,1)
    :Check(best_ticks+MISSION_REACTOR,40)
    // Best time, program length and loop number form one coherent record.
    inc test_id
    :Fresh()
    :Put(loop_count,7)
    :Put(program_len,12)
    ldx #MISSION_HUB
    lda #21
    jsr record_mission
    :Check(best_ticks+MISSION_HUB,21)
    :Check(best_lines+MISSION_HUB,12)
    :Check(best_loops+MISSION_HUB,7)
    :Put(loop_count,8)
    :Put(program_len,3)
    lda #24
    jsr record_mission
    :Check(best_ticks+MISSION_HUB,21)
    :Check(best_lines+MISSION_HUB,12)
    :Check(best_loops+MISSION_HUB,7)
    :Put(loop_count,9)
    :Put(program_len,10)
    lda #21
    jsr record_mission
    :Check(best_lines+MISSION_HUB,10)
    :Check(best_loops+MISSION_HUB,9)
    :Put(loop_count,10)
    :Put(program_len,15)
    lda #20
    jsr record_mission
    :Check(best_ticks+MISSION_HUB,20)
    :Check(best_lines+MISSION_HUB,15)
    :Check(best_loops+MISSION_HUB,10)
    jsr reset_ephemeral_world
    :Check(best_loops+MISSION_HUB,10)
    jsr test_read_timing
    jsr test_cooling_grids
    jsr test_immediate_transmissions
    jsr test_terminal_read_pages
    jsr test_loop_reset_box
    jmp tests_done

test_run_to_halt:
    jsr vm_tick
    lda halt_reason
    beq test_run_to_halt
    rts
tests_done:
    lda #$a5
    sta $cf00
test_idle:
    jmp test_idle
test_id: .byte 0
test_cycle: .byte 0
test_tile: .byte 0
test_actual: .byte 0
test_phase_expected: .fill 64,(mod(i,10)<8 ? 1 : 0)
.assert "Test harness fits beneath vectors", * < $ff00,true
* = $8000 "Additional engine checks (title unused in tests)"
test_read_timing:
    // READ resolves once, after its second cycle, and respects cycle 64.
    inc test_id
    :Fresh()
    :Put(program_len,1)
    :Put(program_op,OP_READ)
    :Put(program_dir,OP_S)
    :Put(powered_mask,16)
    :At(2,9,6,OP_S)
    jsr vm_tick
    :Check(elapsed,1)
    :Check(cycles_left,1)
    :Check(rec_known+14,0)
    :Check(show_record,0)
    :Check(credentials,0)
    jsr vm_tick
    :Check(elapsed,2)
    :Check(rec_known+14,2)
    :Check(show_record,14)
    :Check(credentials,CRED_ZENITH)
    :Check(ip,1)
    :Fresh()
    :Put(program_len,1)
    :Put(program_op,OP_READ)
    :Put(program_dir,OP_S)
    :Put(powered_mask,16)
    :At(2,9,6,OP_S)
    :Put(elapsed,63)
    jsr vm_tick
    :Check(elapsed,64)
    :Check(halt_reason,HALT_CLOCK)
    :Check(rec_known+14,0)
    :Check(show_record,0)
    :Check(credentials,0)
    jsr vm_tick
    :Check(rec_known+14,0)
    :Fresh()
    :Put(program_len,1)
    :Put(program_op,OP_READ)
    :Put(program_dir,OP_S)
    :Put(powered_mask,16)
    :At(2,9,6,OP_S)
    :Put(elapsed,62)
    jsr vm_tick
    jsr vm_tick
    :Check(elapsed,64)
    :Check(halt_reason,HALT_CLOCK)
    :Check(rec_known+14,2)
    :Check(show_record,14)
    rts
test_cooling_grids:
    inc test_id
    :Fresh()
    :Put(test_cycle,0)
!cycle:
    lda test_cycle
    ldx #6
    ldy #3
    jsr laser_phase
    lda #0
    rol
    sta test_actual
    ldx test_cycle
    lda test_cool3_expected,x
    cmp test_actual
    beq !row5+
    jmp test_cooling_failed
!row5:
    lda test_cycle
    ldx #6
    ldy #5
    jsr laser_phase
    lda #0
    rol
    sta test_actual
    ldx test_cycle
    lda test_cool5_expected,x
    cmp test_actual
    beq !row7+
    jmp test_cooling_failed
!row7:
    lda test_cycle
    ldx #6
    ldy #7
    jsr laser_phase
    lda #0
    rol
    sta test_actual
    ldx test_cycle
    lda test_cool7_expected,x
    cmp test_actual
    beq !good+
    jmp test_cooling_failed
!good:
    // One assertion for the combined three-grid state at each cycle.
    inc $cf02
    bne !counted+
    inc $cf03
!counted:
    inc test_cycle
    lda test_cycle
    cmp #64
    bne !cycle-
    :At(6,5,3,OP_N)
    :Put(elapsed,3)
    jsr laser_check
    :Check(action_error,0)
    :Put(elapsed,5)
    jsr laser_check
    :Check(action_error,HALT_LASER)
    :At(6,5,5,OP_N)
    :Put(elapsed,5)
    jsr laser_check
    :Check(action_error,0)
    :Put(elapsed,7)
    jsr laser_check
    :Check(action_error,HALT_LASER)
    :At(6,5,7,OP_N)
    :Put(elapsed,7)
    jsr laser_check
    :Check(action_error,0)
    :Put(elapsed,8)
    jsr laser_check
    :Check(action_error,HALT_LASER)
    rts
test_cooling_failed:
    lda test_id
    sta $cf01
    jmp tests_done
test_cool3_expected: .fill 64,(mod(i,5)<3 ? 1 : 0)
test_cool5_expected: .fill 64,(mod(i,7)<5 ? 1 : 0)
test_cool7_expected: .fill 64,(mod(i,8)<4 ? 1 : 0)

test_immediate_transmissions:
    // The real DROP completing M1 opens Command immediately, with power intact.
    inc test_id
    :Fresh()
    :Put(loop_count,1)
    :CarryCell(0)
    :At(0,2,7,OP_W)
    :Put(program_len,2)
    :Put(program_op,OP_DROP)
    :Put(program_dir,OP_W)
    :Put(mode,MODE_RUN)
    jsr vm_tick
    jsr after_tick
    :Check(help_open,PAGE_RECORD)
    :Check(view_rec,15)
    :Check(rec_known+15,2)
    :Check(powered_mask,1)
    :Check(elapsed,1)
    :Check(loop_count,1)
    jsr render_page
    :Check(rec_known+15,1)
    lda #13
    jsr handle_key
    :Check(help_open,0)
    :Check(mode,MODE_RUN)
    :Check(elapsed,1)
    jsr after_tick
    :Check(help_open,0)
    jsr reset_loop
    :Check(help_open,0)
    :Check(rec_known+15,1)

    // READ rewards queue Command behind the source log during the same run.
    inc test_id
    :Fresh()
    :Put(loop_count,1)
    :Put(mode,MODE_RUN)
    :Put(elapsed,9)
    lda #1
    jsr learn_record
    jsr after_tick
    :Check(view_rec,1)
    :Check(show_record,0)
    :Check(rec_known+16,2)
    :Check(help_open,PAGE_RECORD)
    jsr render_page
    lda #13
    jsr handle_key
    :Check(view_rec,16)
    :Check(help_open,PAGE_RECORD)
    jsr render_page
    lda #13
    jsr handle_key
    :Check(help_open,0)
    :Check(mode,MODE_RUN)
    :Check(elapsed,9)
    :Check(loop_count,1)

    // No premature Sector 01 message: both the gate and code are required.
    inc test_id
    :Fresh()
    :Put(loop_count,1)
    :Put(mission_done+1,1)
    jsr after_tick
    :Check(help_open,0)
    :Check(rec_known+17,0)
    :Put(credentials,CRED_ZENITH)
    jsr after_tick
    :Check(view_rec,17)
    :Check(rec_known+17,2)

    // All ten eligible messages are retained, shown in order, and never reset
    // the world or spend time while the player advances through their pages.
    inc test_id
    :Fresh()
    :Put(loop_count,1)
    :Put(mode,MODE_STEP)
    :Put(elapsed,23)
    :Put(mission_done,1)
    :Put(mission_done+1,1)
    :Put(mission_done+3,1)
    :Put(credentials,CRED_ORBIT|CRED_ZENITH)
    :Put(firmware,FW_PULSE)
    :Put(rec_known+3,1)
    :Put(rec_known+6,1)
    :Put(rec_known+8,1)
    :Put(rec_known+9,1)
    :Put(rec_known+10,1)
    jsr after_tick
    :Put(test_cycle,15)
!next:
    lda view_rec
    cmp test_cycle
    beq !correct+
    jmp test_cooling_failed
!correct:
    inc $cf02
    jsr render_page
    lda #13
    jsr handle_key
    inc test_cycle
    lda test_cycle
    cmp #25
    bne !next-
    :Check(help_open,0)
    :Check(mode,MODE_STEP)
    :Check(elapsed,23)
    :Check(loop_count,1)
    jsr after_tick
    :Check(help_open,0)
    jsr reset_loop
    :Check(help_open,0)
    rts
test_terminal_read_pages:
    // A first READ of each powered terminal opens its own log after two cycles,
    // even if its new credential also unlocks a Command message in that cycle.
    inc test_id
    :Fresh()
    :Put(dev_found,1)
    :Put(cargo_room,1)
    :Put(cargo_x,7)
    :Put(cargo_y,1)
    jsr refresh_power
    :At(1,7,4,OP_N)
    :Put(view_room,1)
    :Put(mode,MODE_STEP)
    :Put(program_len,1)
    :Put(program_op,OP_READ)
    :Put(program_dir,OP_N)
    // Leave the offline description as the previous footer, as in a live run.
    :Put(event_arg,INS_TERMINAL_OFF)
    :Put(knowledge_event,EV_INSPECT)
    :Put(run_msg,1)
    lda #32
    jsr dispatch_key
    :Check(elapsed,1)
    :Check(cycles_left,1)
    :Check(help_open,0)
    :Check(rec_known+1,0)
    jsr render_footer
    :Check($0400+23*40+1,18) // READING replaces the stale offline description.
    :Check($0400+23*40+2,5)
    :Check($0400+23*40+12,49) // 1/2
    :Check($0400+23*40+14,50)
    lda #32
    jsr dispatch_key
    :Check(elapsed,2)
    :Check(help_open,PAGE_RECORD)
    :Check(view_rec,1)
    :Check(credentials,CRED_ORBIT)
    :Check(rec_known+16,2)
    jsr render_page
    :Check(rec_known+1,1)
    lda #32
    jsr dispatch_key
    :Check(view_rec,16)
    jsr render_page
    lda #32
    jsr dispatch_key
    :Check(help_open,0)
    :Check(elapsed,2)

    inc test_id
    :Fresh()
    :Put(cargo_room,2)
    :Put(cargo_x,8)
    :Put(cargo_y,7)
    jsr refresh_power
    :At(2,9,6,OP_S)
    :Put(mode,MODE_RUN)
    :Put(program_len,1)
    :Put(program_op,OP_READ)
    :Put(program_dir,OP_S)
    jsr vm_tick
    jsr after_tick
    :Check(help_open,0)
    jsr vm_tick
    jsr after_tick
    :Check(elapsed,2)
    :Check(help_open,PAGE_RECORD)
    :Check(view_rec,14)
    :Check(credentials,CRED_ZENITH)
    jsr render_page
    :Check(rec_known+14,1)
    // Removing power prevents even a known record from opening.
    :Put(help_open,0)
    :Put(cargo_room,254)
    jsr refresh_power
    :Put(ip,0)
    :Put(halt_reason,0)
    jsr vm_tick
    jsr after_tick
    jsr vm_tick
    jsr after_tick
    :Check(help_open,0)
    :Check(knowledge_event,EV_INSPECT)
    :Check(event_arg,INS_TERMINAL_OFF)
    :Check(elapsed,4)
    rts
test_loop_reset_box:
    inc test_id
    :Fresh()
    :Put(loop_count,3)
    :Put(program_len,1)
    :Put(program_op,OP_WAIT)
    :Put(program_arg,1)
    :Put(mode,MODE_STEP)
    :Put(elapsed,63)
    jsr vm_tick
    jsr after_tick
    :Check(elapsed,64)
    :Check(halt_reason,HALT_CLOCK)
    :Check(help_open,PAGE_LOOP_RESET)
    :Check(mode,MODE_HALT)
    jsr render
    :Check(help_open,PAGE_LOOP_RESET)
    :Check($0400+12*40+15,12) // Centered LOOP RESET.
    :Check($0400+12*40+24,20)
    :Check($0400+14*40+13,16) // PRESS ANY KEY.
    :Check($0400+9*40+7,CHAR_HLINE)
    :Check($0400+12*40+7,CHAR_VLINE)
    :Check($d800+12*40+15,7)
    // A command key acknowledges but does not edit the preserved program.
    lda #78
    jsr dispatch_key
    :Check(help_open,0)
    :Check(mode,MODE_PLAN)
    :Check(elapsed,0)
    :Check(robot_x,START_X)
    :Check(robot_y,START_Y)
    :Check(program_op,OP_WAIT)
    :Check(loop_count,3)
    // A player-requested reset has no notification.
    :Put(elapsed,20)
    :Put(mode,MODE_STEP)
    lda #136
    jsr dispatch_key
    :Check(help_open,0)
    :Check(elapsed,0)
    :Check(mode,MODE_PLAN)
    // A run stopped by a failed command before time expires has no box.
    :Put(program_op,OP_PICK)
    :Put(program_dir,OP_N)
    :Put(mode,MODE_STEP)
    jsr vm_tick
    jsr after_tick
    :Check(halt_reason,HALT_NO_CARGO)
    :Check(help_open,0)
    :Check(elapsed,1)

    // A log completed exactly at cycle 64 remains readable before the notice.
    inc test_id
    :Fresh()
    :Put(powered_mask,16)
    :At(2,9,6,OP_S)
    :Put(program_len,1)
    :Put(program_op,OP_READ)
    :Put(program_dir,OP_S)
    :Put(elapsed,62)
    :Put(mode,MODE_RUN)
    jsr vm_tick
    jsr after_tick
    jsr vm_tick
    jsr after_tick
    :Check(halt_reason,HALT_CLOCK)
    :Check(help_open,PAGE_RECORD)
    :Check(view_rec,14)
    jsr render_page
    lda #13
    jsr dispatch_key
    :Check(help_open,PAGE_LOOP_RESET)
    :Check(elapsed,64)
    lda #133
    jsr dispatch_key
    :Check(help_open,0)
    :Check(mode,MODE_PLAN)
    :Check(elapsed,0)
    :Check(rec_known+14,1)
    :Check(credentials,CRED_ZENITH)
    rts
.assert "Extra checks stay below shipping helpers", * < $9400,true
* = test_return_pc
