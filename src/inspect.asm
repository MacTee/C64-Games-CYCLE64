// READ always describes the adjacent tile. Powered data devices also open logs.


world_read:
    lda active_dir
    jsr adjacent_target
    bcc !inside+
    lda #INS_EDGE
    jmp inspect_event
!inside:
    jsr find_cargo
    bcs !device+
    cpx #CARGO_CHIP
    beq !chip+
    lda target_tile
    cmp #TILE_SOCKET
    beq !loaded+
    lda #TILE_CELL
    jmp inspect_event
!loaded:
    lda #TILE_SOCKET_CELL
    jmp inspect_event
!chip:
    lda #TILE_CHIP
    ldy chip_state
    beq !chipText+
    lda #INS_CHIP_READY
!chipText:
    jmp inspect_event
!device:
    jsr find_device
    bcs inspect_geometry
    lda dev_hidden,x
    beq !visible+
    lda dev_found,x
    bne !visible+
    lda #TILE_PANEL
    jmp inspect_event
!visible:
    lda dev_power,x
    beq !record+
    and powered_mask
    bne !record+
    lda target_tile
    cmp #TILE_LIBRARY
    beq !libraryOff+
    cmp #TILE_UPLINK
    beq !uplinkOff+
    lda #INS_TERMINAL_OFF
    jmp inspect_event
!libraryOff:
    lda #INS_LIBRARY_OFF
    jmp inspect_event
!uplinkOff:
    lda #INS_UPLINK_OFF
    jmp inspect_event
!record:
    lda dev_read,x
    beq inspect_geometry
    cmp #REC_SERVICE
    bne !learn+
    ldy firmware
    tya
    and #FW_FEEDBACK
    bne !service+
    lda #INS_MODULE_DIAG
    jmp inspect_event
!service:
    lda #REC_SERVICE
!learn:
    jmp learn_record

inspect_geometry:
    lda target_room
    cmp other_room
    bne !tile+
    lda target_x
    cmp other_x
    bne !tile+
    lda target_y
    cmp other_y
    bne !tile+
    lda #TILE_ROBOT
    jmp inspect_event
!tile:
    lda target_tile
    cmp #TILE_SOCKET
    beq !socket+
    cmp #TILE_LASER
    beq !laser+
    cmp #TILE_LASER_V
    beq !laser+
    cmp #TILE_HATCH
    beq !hatch+
    cmp #TILE_DOOR
    bne !describe+
    ldx target_room
    cpx #DOOR_ROOM
    bne !describe+
    lda #INS_JUNCTION_DOOR
!describe:
    jmp inspect_event
!socket:
    ldy #SOCKET_COUNT-1
!findSocket:
    lda socket_room,y
    cmp target_room
    bne !nextSocket+
    lda socket_x,y
    cmp target_x
    bne !nextSocket+
    lda socket_y,y
    cmp target_y
    beq !socketText+
!nextSocket:
    dey
    bpl !findSocket-
    lda #TILE_SOCKET
    jmp inspect_event
!socketText:
    lda socket_description,y
    jmp inspect_event
!laser:
    lda elapsed
    ldx target_room
    ldy target_y
    jsr laser_phase
    php
    cpx #6
    bne !ordinaryLaser+
    lda #INS_COOL3_ON
    cpy #3
    beq !coolingState+
    lda #INS_COOL5_ON
    cpy #5
    beq !coolingState+
    lda #INS_COOL7_ON
!coolingState:
    plp
    bcs !laserDescription+
    clc
    adc #1
!laserDescription:
    jmp inspect_event
!ordinaryLaser:
    plp
    lda #TILE_LASER
    bcs inspect_event
    lda #TILE_LASER_OFF
    bcc inspect_event
!hatch:
    ldx target_room
    cpx #0
    bne !duct+
    jsr hatch_powered
    beq !noPower+
    lda credentials
    and #CRED_ORBIT
    beq !orbit+
    lda #INS_HATCH_LIVE
    bne inspect_event
!noPower:
    lda #TILE_HATCH
    bne inspect_event
!orbit:
    lda #INS_HATCH_ORBIT
    bne inspect_event
!duct:
    cpx #7
    bne !plain+
    lda firmware
    and #FW_FEEDBACK
    bne !ready+
    lda #INS_HATCH_FEEDBACK
    bne inspect_event
!ready:
    lda #INS_HATCH_LIVE
    bne inspect_event
!plain:
    lda #INS_HATCH_LIVE
inspect_event:
    sta event_arg
    lda #EV_INSPECT
    jmp raise_event

socket_description: .byte INS_DOCK_SOCKET,INS_WORKSHOP_SOCKET,INS_JUNCTION_SOCKET,INS_JUNCTION_SOCKET,INS_HUB_SOCKET,INS_ARCHIVE_SOCKET,INS_HATCH_SOCKET,INS_VAULT_SOCKET
inspection_names:
.word it_floor,it_wall,it_socket,it_exit,it_terminal,it_gate,it_unused6,it_unused7,it_panel,it_robot,it_cell,it_fog,it_laser,it_robot_cell,it_laser_off,it_chip
.word it_rack,it_programmer,it_reactor,it_uplink,it_hatch,it_door,it_stasis,it_library,it_exit,it_laser,it_laser_off,it_loaded
.word it_edge,it_offline,it_library_off,it_uplink_off,it_hatch_ready,it_orbit,it_feedback,it_diag,it_chip_ready,it_power
.word it_dock_socket,it_workshop_socket,it_junction_socket,it_hub_socket,it_archive_socket,it_hatch_socket
.word it_junction_door
.word it_vault_socket
.word it_cool3_on,it_cool3_off,it_cool5_on,it_cool5_off,it_cool7_on,it_cool7_off
it_floor: .text "EMPTY FLOOR"; .byte 0
it_wall: .text "WALL: IMPASSABLE"; .byte 0
it_socket: .text "EMPTY POWER SOCKET"; .byte 0
it_exit: .text "EXIT: WALK ONTO IT"; .byte 0
it_terminal: .text "TERMINAL ONLINE"; .byte 0
it_gate: .text "SEALED GATE: ACCESS WITH CODE"; .byte 0
it_unused6: .text "EMPTY FLOOR"; .byte 0
it_unused7: .text "EMPTY FLOOR"; .byte 0
it_panel: .text "SEALED PANEL: SCAN NEARBY"; .byte 0
it_robot: .text "PARKED ROBOT: LINK TO CONTROL"; .byte 0
it_cell: .text "BATTERY CELL: PICK IT UP"; .byte 0
it_fog: .text "UNMAPPED TILE"; .byte 0
it_laser: .text "LASER ON: DO NOT CROSS"; .byte 0
it_robot_cell: .text "ROBOT CARRYING CARGO"; .byte 0
it_laser_off: .text "LASER OFF: SAFE THIS CYCLE"; .byte 0
it_chip: .text "CONTROL CHIP: NOT PROGRAMMED"; .byte 0
it_rack: .text "STORAGE RACK: EMPTY"; .byte 0
it_programmer: .text "PROGRAMMER: ACCESS WITH CHIP"; .byte 0
it_reactor: .text "REACTOR MODULE: DROP CHIP"; .byte 0
it_uplink: .text "UPLINK ONLINE: USE LINK"; .byte 0
it_hatch: .text "HATCH: NEEDS POWER AND ACCESS"; .byte 0
it_door: .text "SEALED DOOR: LOCKED FROM INSIDE"; .byte 0
it_stasis: .text "STASIS POD: OCCUPIED, ALIVE"; .byte 0
it_library: .text "FIRMWARE LIBRARY ONLINE"; .byte 0
it_loaded: .text "POWERED SOCKET: CELL REMOVABLE"; .byte 0
it_edge: .text "FACILITY BOUNDARY: NO TILE"; .byte 0
it_offline: .text "TERMINAL OFFLINE: ADD A CELL"; .byte 0
it_library_off: .text "FIRMWARE OFFLINE: ADD A CELL"; .byte 0
it_uplink_off: .text "UPLINK OFFLINE: ADD A CELL"; .byte 0
it_hatch_ready: .text "HATCH READY: ACCESS TO OPEN"; .byte 0
it_orbit: .text "POWERED HATCH: CODE ORBIT"; .byte 0
it_feedback: .text "HATCH: FEEDBACK REQUIRED"; .byte 0
it_diag: .text "MODULE: FEEDBACK TO READ DATA"; .byte 0
it_chip_ready: .text "CONTROL CHIP: IMAGE PROGRAMMED"; .byte 0
it_power: .text "SOCKET POWER UPDATED"; .byte 0
it_dock_socket: .text "SOCKET: POWERS DOCK TERMINAL"; .byte 0
it_workshop_socket: .text "SOCKET: WORKSHOP TERMINAL POWER"; .byte 0
it_junction_socket: .text "TWO SOCKETS: LIGHTS AND DOOR"; .byte 0
it_hub_socket: .text "SOCKET: POWERS HUB CAMERA LOG"; .byte 0
it_archive_socket: .text "SOCKET: FIRMWARE AND UPLINK"; .byte 0
it_hatch_socket: .text "SOCKET: POWERS DOCK HATCH"; .byte 0
it_junction_door: .text "SEALED DOOR: NEEDS BOTH CELLS"; .byte 0
it_vault_socket: .text "SOCKET: VAULT TERMINAL AND FW"; .byte 0
