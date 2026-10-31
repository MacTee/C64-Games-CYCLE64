// No display dependencies. Reset never writes persistent session storage.
session_init:
    lda #0
    tax
!clear:
    .for (var p=0;p<5;p++) {
        sta persistent_start+p*$100,x
    }
    inx
    bne !clear-
    lda #255
    ldx #MISSION_COUNT-1
!best:
    sta best_ticks,x
    sta best_lines,x
    dex
    bpl !best-
    rts
reset_ephemeral_world:
    jsr reset_physical
    lda #0
    sta elapsed
    sta ip
    sta substep
    sta cycles_left
    sta halt_reason
    sta delivered_run
    sta new_best
    sta delivery_event
    sta knowledge_event
    sta new_record
    lda program_len
    sta run_lines
    jsr reveal_normal
    rts
// Rebuilds the facility: live tiles, robots, cargo and the chip.
reset_physical:
    lda #<rooms_start
    sta data_ptr
    lda #>rooms_start
    sta data_ptr+1
    lda #<live_tiles
    sta screen_ptr
    lda #>live_tiles
    sta screen_ptr+1
    ldx #>(ROOM_COUNT*120)
    ldy #0
!page:
    lda (data_ptr),y
    sta (screen_ptr),y
    iny
    bne !page-
    inc data_ptr+1
    inc screen_ptr+1
    dex
    bne !page-
!rest:
    lda (data_ptr),y
    sta (screen_ptr),y
    iny
    cpy #<(ROOM_COUNT*120)
    bne !rest-
    lda #START_ROOM
    sta robot_room
    lda #START_X
    sta robot_x
    lda #START_Y
    sta robot_y
    lda #VAULT_ROOM
    sta other_room
    lda #VAULT_X
    sta other_x
    lda #VAULT_Y
    sta other_y
    lda #255
    sta held
    sta other_held
    lda #0
    sta linked
    sta chip_state
    sta image_authorized
    sta ending_kind
    sta powered_mask
    ldx #CARGO_COUNT-1
!cargo:
    lda initial_cargo_room,x
    sta cargo_room,x
    lda initial_cargo_x,x
    sta cargo_x,x
    lda initial_cargo_y,x
    sta cargo_y,x
    dex
    bpl !cargo-
    rts
// A=direction N/E/S/W. Carry set means outside the room.
adjacent_target:
    tax
    lda robot_room
    sta target_room
    lda robot_x
    clc
    adc delta_x,x
    sta target_x
    lda robot_y
    clc
    adc delta_y,x
    sta target_y
    jmp target_lookup
// Reads the live tile at target_room/x/y. Leaves data_ptr on the live room.
target_lookup:
    lda target_x
    cmp #12
    bcs !bad+
    lda target_y
    cmp #10
    bcs !bad+
    tax
    lda row12,x
    clc
    adc target_x
    sta target_index
    tay
    ldx target_room
    lda live_lo,x
    sta data_ptr
    lda live_hi,x
    sta data_ptr+1
    lda (data_ptr),y
    sta target_tile
    clc
    rts
!bad:
    sec
    rts
// Carry set when the target tile or the parked robot blocks the way.
target_passable:
    ldx target_tile
    lda tile_solid,x
    bne !blocked+
    lda target_room
    cmp other_room
    bne !ok+
    lda target_x
    cmp other_x
    bne !ok+
    lda target_y
    cmp other_y
    beq !blocked+
!ok:
    clc
    rts
!blocked:
    sec
    rts
// Return X=cargo ID, carry clear for loose cargo at target.
find_cargo:
    ldx #CARGO_COUNT-1
!next:
    lda cargo_room,x
    cmp target_room
    bne !skip+
    lda cargo_x,x
    cmp target_x
    bne !skip+
    lda cargo_y,x
    cmp target_y
    bne !skip+
    clc
    rts
!skip:
    dex
    bpl !next-
    sec
    rts
// Return X=device at target_room/target_index, carry clear when found.
find_device:
    ldx #DEV_COUNT-1
!next:
    lda dev_room,x
    cmp target_room
    bne !skip+
    lda dev_index,x
    cmp target_index
    beq !found+
!skip:
    dex
    bpl !next-
    sec
    rts
!found:
    clc
    rts
// One tile in the direction of A. Used by MOVE and twice per cycle by BOOST.
world_move_dir:
    jsr adjacent_target
    bcs !wall+
    jsr target_passable
    bcs !wall+
    jsr find_cargo
    bcc !wall+
    lda target_tile
    cmp #TILE_EXIT
    bne !cargo+
    jsr resolve_exit
    bcs !wall+
!cargo:
    jsr find_cargo
    bcc !wall+
    lda target_room
    sta robot_room
    lda target_x
    sta robot_x
    lda target_y
    sta robot_y
    lda robot_room
    cmp #3
    bne !reveal+
    ldx #MISSION_JUNCTION
    lda elapsed
    clc
    adc #1
    jsr record_mission
!reveal:
    jsr reveal_normal
    rts
!wall:
    lda #HALT_WALL
    sta action_error
    rts
resolve_exit:
    // The Junction south door blocks passage in both directions.
    lda target_room
    cmp #5
    bne !searchStart+
    lda target_index
    cmp #6
    bne !searchStart+
    lda powered_mask
    and #12
    cmp #12
    beq !searchStart+
    sec
    rts
!searchStart:
    ldx #EXIT_COUNT-1
!search:
    lda exit_from_room,x
    cmp target_room
    bne !next+
    lda exit_from_index,x
    cmp target_index
    bne !next+
    lda exit_to_room,x
    sta target_room
    lda exit_to_x,x
    sta target_x
    lda exit_to_y,x
    sta target_y
    jsr target_lookup
    jmp target_passable
!next:
    dex
    bpl !search-
    sec
    rts
// Junction/Cooling use 4 ON / 4 OFF; Reactor uses 8 ON / 2 OFF.
// A robot on an active laser tile halts. Called after every action.
laser_check:
    lda elapsed
    ldx robot_room
    ldy robot_y
    jsr laser_phase
    bcc !safe+
    ldx robot_room
    lda live_lo,x
    sta data_ptr
    lda live_hi,x
    sta data_ptr+1
    ldx robot_y
    lda row12,x
    clc
    adc robot_x
    tay
    lda (data_ptr),y
    cmp #TILE_LASER
    beq !hit+
    cmp #TILE_LASER_V
    bne !safe+
!hit:
    sta target_tile
    lda robot_room
    sta target_room
    lda robot_x
    sta target_x
    lda robot_y
    sta target_y
    lda #HALT_LASER
    sta action_error
!safe:
    rts
world_pick:
    lda held
    cmp #255
    bne !holding+
    lda active_dir
    jsr adjacent_target
    bcs !none+
    jsr find_cargo
    bcs !none+
    stx held
    lda #254
    sta cargo_room,x
    jmp refresh_power
!holding:
    lda #HALT_HOLDING
    bne !error+
!none:
    lda #HALT_NO_CARGO
!error:
    sta action_error
    rts
// Loose cargo stays on empty floor; sockets keep their delivery behavior.
world_drop:
    lda held
    cmp #255
    beq !empty+
    lda active_dir
    jsr adjacent_target
    bcs !blocked+
    lda target_tile
    cmp #TILE_REACTOR
    bne !floor+
    lda held
    cmp #CARGO_CHIP
    bne !blocked+
    jmp install_chip
!floor:
    lda target_tile
    beq !freeTile+
    cmp #TILE_SOCKET
    bne !blocked+
!freeTile:
    jsr target_passable
    bcs !blocked+
    jsr find_cargo
    bcc !blocked+
    ldx held
    lda target_room
    sta cargo_room,x
    lda target_x
    sta cargo_x,x
    lda target_y
    sta cargo_y,x
    lda #255
    sta held
    jsr record_delivery
    rts
!empty:
    lda #HALT_EMPTY
    bne !error+
!taken:
    lda #HALT_TAKEN
    bne !error+
!blocked:
    // Keep cargo in hand when the destination is unsuitable or occupied.
    lda #HALT_BLOCKED
!error:
    sta action_error
    rts
// LINK: the uplink in the direction of active_dir moves the single control
// channel to the parked robot. Only one LINK per loop.
world_link:
    lda active_dir
    jsr adjacent_target
    bcs !none+
    jsr find_device
    bcs !none+
    lda dev_kind,x
    cmp #KIND_LINK
    bne !none+
    lda dev_power,x
    and powered_mask
    beq !offline+
    lda linked
    bne !busy+
    inc linked
    // robot_room/x/y/held and other_room/x/y/held are two 4-byte records.
    ldx #3
!swap:
    lda robot_room,x
    ldy other_room,x
    sta other_room,x
    tya
    sta robot_room,x
    dex
    bpl !swap-
    lda #EV_LINK
    jsr raise_event
    jmp reveal_normal
!none:
    lda #HALT_NO_UPLINK
    bne !error+
!busy:
    lda #HALT_CHANNEL
    bne !error+
!offline:
    lda #HALT_OFFLINE
!error:
    sta action_error
    rts
// A=event. The footer shows each new event once.
raise_event:
    sta knowledge_event
    inc event_seq
    rts
delta_x: .byte 0,1,0,255
delta_y: .byte 255,0,1,0
// Per tile: blocks movement, and blocks sight.
tile_solid: .byte 0,1,0,0,1,1,0,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0
tile_opaque: .byte 0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0
