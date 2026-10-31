// 12x10 immutable geometry. reset_physical copies all rooms to live_tiles,
// where gates, doors and hatches open for one loop. Entities are separate data.
// Rooms: 0 Dock, 1 Workshop, 2 Security hub (Sector 01, the tutorial),
// 3 Junction, 4 Archive (Sector 02), 5 Reactor control, 6 Cooling (Sector 03),
// 7 Service duct, 8 Stasis refuge (sealed, map only).
rooms_start:
room_a:
.byte 1,1,1,1,1,1,1,1,1,1,1,1
.byte 1,0,0,0,0,0,1,0,0,0,4,1
.byte 1,0,0,0,0,0,1,0,0,0,0,1
.byte 1,0,0,0,0,0,1,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,3
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,0,0,0,1,0,0,0,0,1
.byte 1,2,0,0,0,0,1,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,2,1
.byte 1,1,1,1,1,1,1,1,20,1,1,1
room_b:
.byte 1,1,1,1,1,1,1,1,1,1,1,1
.byte 1,0,0,0,0,0,1,2,0,0,0,1
.byte 1,0,0,0,0,0,1,0,0,0,0,1
.byte 1,17,0,0,0,0,1,4,0,0,0,1
.byte 3,0,0,0,0,0,0,0,0,0,0,3
.byte 1,16,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,1,1,5,1,1,1,1,1,1,1,1
room_c:
.byte 1,1,1,1,1,1,1,1,1,1,1,1
.byte 1,0,0,0,1,0,0,0,0,0,0,1
.byte 1,0,0,0,1,0,0,0,0,0,0,1
.byte 1,0,0,0,1,0,0,0,0,0,0,1
.byte 3,0,0,0,5,0,0,0,0,0,0,1
.byte 1,0,0,0,1,0,0,0,0,0,0,1
.byte 1,0,0,0,1,0,0,0,0,0,0,1
.byte 1,0,0,0,1,0,0,0,2,4,0,1
.byte 1,0,0,0,1,0,0,0,0,0,0,1
.byte 1,1,1,1,1,1,1,1,1,1,1,1
room_d:
.byte 1,1,1,3,1,1,1,1,1,1,1,1
.byte 1,0,0,0,0,0,0,0,0,0,23,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,5
.byte 1,12,12,12,12,12,12,12,12,12,1,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,4,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,2,2,0,0,0,0,0,0,1
.byte 1,1,1,1,1,1,21,1,1,1,1,1
room_e:
.byte 1,1,1,1,1,1,1,1,1,1,1,1
.byte 1,0,0,0,1,0,0,0,0,4,0,1
.byte 1,0,0,0,1,0,0,0,0,0,2,1
.byte 1,0,0,0,1,0,0,0,0,0,0,1
.byte 3,0,0,0,1,0,0,0,0,23,0,1
.byte 1,0,0,0,1,1,1,1,1,1,1,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,19,0,1
.byte 1,23,2,0,0,0,0,0,0,0,0,1
.byte 1,1,1,1,1,1,1,1,1,1,1,1
room_f:
.byte 1,1,1,1,1,1,3,1,1,1,1,1
.byte 1,0,0,0,0,25,0,0,0,0,0,1
.byte 1,0,1,1,1,25,0,0,0,0,4,1
.byte 1,0,1,18,1,25,0,0,0,0,0,1
.byte 20,0,0,0,0,25,0,0,0,0,0,21
.byte 1,0,0,0,0,25,0,0,0,0,0,1
.byte 1,0,0,0,0,25,0,1,1,0,0,1
.byte 1,0,0,0,0,25,0,1,1,0,0,1
.byte 1,0,0,0,0,25,0,0,0,0,0,1
.byte 1,1,1,1,1,1,3,1,1,1,1,1
room_g:
.byte 1,1,1,1,1,1,3,1,1,1,1,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,1,0,1,0,0,0,1,0,1,1
.byte 1,12,12,12,12,12,12,12,12,12,12,1
.byte 1,0,1,0,1,0,0,0,1,0,1,1
.byte 1,12,12,12,12,12,12,12,12,12,12,1
.byte 1,0,1,0,1,0,0,0,1,0,1,1
.byte 1,12,12,12,12,12,12,12,12,12,12,1
.byte 1,4,0,0,0,0,0,0,0,0,4,1
.byte 1,1,1,1,1,1,1,1,1,1,1,1
room_h:
.byte 1,1,1,1,1,1,1,1,3,1,1,1
.byte 1,1,1,1,1,1,1,1,0,1,1,1
.byte 1,1,1,1,1,1,1,1,0,1,1,1
.byte 1,1,0,0,0,0,0,0,0,1,1,1
.byte 1,1,0,1,1,1,1,1,1,1,1,1
.byte 1,1,0,1,1,1,1,1,1,1,1,1
.byte 1,1,0,0,0,0,0,0,0,0,0,1
.byte 1,1,1,1,1,1,1,1,1,1,0,1
.byte 1,1,1,1,1,1,1,1,1,1,0,1
.byte 1,1,1,1,1,1,1,1,1,1,20,1
room_r:
.byte 1,1,1,1,1,1,1,1,1,1,1,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,22,0,22,0,22,0,22,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 21,0,22,0,22,0,22,0,22,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,22,0,22,0,22,0,22,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,0,0,0,0,0,0,0,0,0,0,1
.byte 1,1,1,1,1,1,1,1,1,1,1,1
rooms_end:
.assert "Nine rooms of 120 tiles", rooms_end-rooms_start, ROOM_COUNT*120

// Exits trigger on entering a boundary marker. The landing tile is passable
// floor. A gate or hatch that opens to TILE_EXIT uses this table too.
exit_from_room: .byte 0,1,1,2,0,7,1,3,3,4,3,5,5,6,5,7
exit_from_index: .byte 59,48,59,48,116,8,111,3,59,48,114,6,114,6,48,118
exit_to_room: .byte 1,0,2,1,7,0,3,1,4,3,5,3,6,5,7,5
exit_to_x: .byte 1,10,1,10,8,8,3,3,1,10,6,6,6,6,10,1
exit_to_y: .byte 4,4,4,4,1,8,1,8,4,4,1,8,1,8,8,4
.const EXIT_COUNT=16
room_lo: .fill ROOM_COUNT,<(rooms_start+i*120)
room_hi: .fill ROOM_COUNT,>(rooms_start+i*120)
live_lo: .fill ROOM_COUNT,<(live_tiles+i*120)
live_hi: .fill ROOM_COUNT,>(live_tiles+i*120)
discovery_lo: .fill ROOM_COUNT,<(discovered+i*120)
discovery_hi: .fill ROOM_COUNT,>(discovered+i*120)
// Header: sector number per room.
room_sector: .byte 1,1,1,2,2,3,3,1,3
row12: .fill 10,i*12
// Cargo 0 and 2 are energy cells, cargo 3 is the spare control chip on rack 01.
// Cargo 1 is the local Archive vault cell; cargo 3 is the control chip.
initial_cargo_room: .byte 0,4,3,1
initial_cargo_x: .byte 5,5,2,1
initial_cargo_y: .byte 2,1,2,5
// The east dock socket is no mission socket. A cell on it powers the duct hatch.
.const HATCH_SOCKET_X=10
.const HATCH_SOCKET_Y=8

// Devices: READ gives dev_read (a record), ACCESS acts by dev_kind.
// dev_cred = credential bits that ACCESS needs (0 = none). dev_param = the tile
// that an opened gate or hatch becomes. dev_hidden: 1 = SCAN finds it,
// 2 = only a FEEDBACK-enhanced SCAN
// finds it. dev_power: live socket mask required by READ and LINK.
dev_room: .byte 1,1,2,2,0,3,3,3,4,4,4,5,5,5,6,6,1,4,0,7
dev_index: .byte 43,37,52,93,116,85,22,59,21,93,97,34,39,48,97,106,111,57,22,118
dev_read: .byte 1,2,0,14,0,3,4,0,6,11,5,8,9,0,12,10,0,7,13,0
dev_kind: .byte 0,KIND_PROG,KIND_GATE,0,KIND_HATCH,0,0,KIND_GATE,0,KIND_LINK,0,0,KIND_REACTOR,KIND_HATCH,0,0,KIND_GATE,0,0,KIND_HATCH
dev_cred: .byte 0,0,CRED_ORBIT,0,CRED_ORBIT,0,0,CRED_VECTOR,0,0,0,0,0,0,0,0,CRED_ZENITH,0,0,0
dev_param: .byte 0,0,TILE_FLOOR,0,TILE_EXIT,0,0,TILE_EXIT,0,0,0,0,0,TILE_EXIT,0,0,TILE_EXIT,0,0,TILE_EXIT
dev_hidden: .byte 1,0,0,0,1,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0
dev_power: .byte 2,0,0,16,0,0,0,0,128,32,32,0,0,0,0,0,0,128,1,0
dev_fw: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,FW_FEEDBACK
