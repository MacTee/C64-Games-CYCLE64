// CYCLE 64 - Shared VM, world, UI and zero-page constants; no storage is emitted.

.const MODE_PLAN                   = 0
.const MODE_RUN                    = 1
.const MODE_STEP                   = 2
.const MODE_HALT                   = 3
.const MODE_TITLE                  = 4
.const OP_N                        = 0
.const OP_E                        = 1
.const OP_S                        = 2
.const OP_W                        = 3
.const OP_PICK                     = 4
.const OP_DROP                     = 5
.const OP_WAIT                     = 6
.const OP_SCAN                     = 7
.const OP_READ                     = 8
.const OP_ACCESS                   = 9
.const HALT_END                    = 1
.const HALT_WALL                   = 3
.const HALT_NO_CARGO               = 4
.const HALT_HOLDING                = 5
.const HALT_EMPTY                  = 6
.const HALT_BLOCKED                = 7
.const HALT_CLOCK                  = 8
.const HALT_ABORT                  = 9
.const HALT_NO_TERMINAL            = 10
.const HALT_CREDENTIAL             = 11
.const HALT_NO_LOCK                = 12
.const TILE_FLOOR                  = 0
.const TILE_WALL                   = 1
.const TILE_SOCKET                 = 2
.const TILE_EXIT                   = 3
.const TILE_TERMINAL               = 4
.const TILE_GATE                   = 5
.const TILE_PORT                   = 6
.const TILE_AUTH                   = 7
.const TILE_PANEL                  = 8
.const ROOM_COUNT                  = 9
// Main-thread scratch pointers; each label owns two bytes. Callers cannot
// retain pointer contents across helpers or BASIC/KERNAL calls.
.label data_ptr                    = $f7
.label text_ptr                    = $f9
.label screen_ptr                  = $fb
.label color_ptr                   = $fd
.const TILE_ROBOT                  = 9
.const TILE_CELL                   = 10
.const TILE_FOG                    = 11
.const TILE_ROBOT_CELL             = 13
.const CHAR_HLINE                  = 192
.const CHAR_VLINE                  = 193
// Screen regions that render redraws. DIRTY_FULL also clears and draws the frame.
.const DIRTY_HEADER                = %00000001
.const DIRTY_MAP                   = %00000010
.const DIRTY_PROGRAM               = %00000100
.const DIRTY_INFO                  = %00001000
.const DIRTY_FOOTER                = %00010000
.const DIRTY_PARTS                 = %00011111
.const DIRTY_FULL                  = %10000000
.const DIRTY_ALL                   = %10011111
.const CHAR_CASE                   = 194
.const CHAR_GLASS                  = 202
.const CHAR_LED                    = 206
.const CHAR_CURSOR                 = 160
// Text pages shown over the game. help_open holds the page, 0 = game screen.
.const PAGE_HELP                   = 1
.const PAGE_BRIEF1                 = 2
.const PAGE_BRIEF2                 = 3
// Text page body bytes: a colour prefix ($f0+colour) and the end marker.
.const BODY_WHITE                  = $f1
.const BODY_YELLOW                 = $f7
.const BODY_GREY                   = $ff
.const BODY_END                    = $e0
// Story pages. PAGE_RECORD and PAGE_IMAGE draw their bodies at run time.
.const PAGE_RECORD                 = 4
.const PAGE_IMAGE                  = 5
.const PAGE_END_GOOD               = 6
.const PAGE_END_SHUT               = 7
.const PAGE_END_RELEASE            = 8
// Firmware commands.
.const OP_BOOST                    = 10
.const OP_LINK                     = 11
.const OP_COUNT                    = 12
.const OP_EMPTY                    = $ff
// Story halts. HALT_ENDING is not a failure: it opens an ending page.
.const HALT_LASER                  = 13
.const HALT_NO_UPLINK              = 14
.const HALT_CHANNEL                = 15
.const HALT_NO_CHIP                = 16
.const HALT_NO_IMAGE               = 17
.const HALT_CHIP_BLANK             = 18
.const HALT_R_POWER                = 19
.const HALT_R_FIELD                = 20
.const HALT_R_INERT                = 21
.const HALT_ENDING                 = 22
// Tiles 12-23. Tiles 14 and 15 are glyphs only. Tiles 16-23 use characters 208-239.
.const TILE_LASER                  = 12
.const TILE_LASER_OFF              = 14
.const TILE_CHIP                   = 15
.const TILE_RACK                   = 16
.const TILE_PROGRAMMER             = 17
.const TILE_REACTOR                = 18
.const TILE_UPLINK                 = 19
.const TILE_HATCH                  = 20
.const TILE_DOOR                   = 21
.const TILE_STASIS                 = 22
.const TILE_LIBRARY                = 23
.const TILE_COUNT                  = 28
// Display only: an exit in a north or south wall. Never in the room data.
.const TILE_EXIT_V                 = 24
.const TILE_LASER_V                = 25
.const TILE_LASER_V_OFF            = 26
.const TILE_SOCKET_CELL            = 27
// Device kinds for ACCESS, LINK and DROP.
.const KIND_GATE                   = 1
.const KIND_HATCH                  = 3
.const KIND_PROG                   = 4
.const KIND_LINK                   = 5
.const KIND_REACTOR                = 6
.const DEV_COUNT                   = 20
// Credential and firmware bits.
.const CRED_ORBIT                  = %00000001
.const CRED_VECTOR                 = %00000010
// ZENITH, from the security hub terminal, opens the workshop south gate.
.const CRED_ZENITH                 = %00000100
.const START_ROOM                  = 0
.const START_X                     = 3
.const START_Y                     = 1
.const FW_PULSE                    = %00000001
.const FW_ROUTE                    = %00000010
.const FW_FEEDBACK                 = %00000100
// story_flags bits.
.const FLAG_TRUTH                  = %00000001
.const FLAG_OBJECTIVE              = %00000010
.const FLAG_REFUGE                 = %00000100
.const FLAG_SECURED                = %00001000
// Records 1-24. Record 0 in the viewer is the mission log.
.const RECORD_COUNT                = 24
// Records 1-14 are facility logs, 15-24 are Command transmissions.
.const LOG_COUNT                   = 14
.const FIRST_TRANSMISSION          = 15
.const REC_REFUGE                  = 6
// Cargo 3 is the control chip. Mission records are independent of cargo IDs.
.const CARGO_COUNT                 = 4
.const CARGO_CHIP                  = 3
.const MISSION_COUNT               = 5
.const MISSION_DOCK                = 0
.const MISSION_HUB                 = 1
.const MISSION_JUNCTION            = 2
.const MISSION_DOOR                = 3
.const MISSION_REACTOR             = 4
.const DOOR_ROOM                   = 3
.const DOOR_INDEX                  = 114
.const SOCKET_COUNT                = 8
.const REFUGE_ROOM                 = 8
// The dormant archive unit that LINK transfers control to.
.const VAULT_ROOM                  = 4
.const VAULT_X                     = 7
.const VAULT_Y                     = 2
// Knowledge events shown in the footer during a run.
.const EV_SCAN                     = 1
.const EV_RECORD                   = 2
.const EV_GATE                     = 3
.const EV_DUCT                     = 5
.const EV_ECHO                     = 6
.const EV_HATCH                    = 7
.const EV_POWER                    = 8
.const EV_LINK                     = 9
.const EV_CHIP                     = 10
// Reactor image: up to six commands. Outcomes of reactor_eval.
.const IMAGE_SLOTS                 = 6
.const RC_FEEDBACK                 = 1
.const RC_PULSE                    = 2
.const RC_ROUTE                    = 3
.const RC_RESET_OFF                = 4
.const RC_SHUTDOWN                 = 5
.const OUT_GOOD                    = 0
.const OUT_SHUTDOWN                = 1
.const OUT_RELEASE                 = 2
.const OUT_POWER                   = 3
.const OUT_FIELD                   = 4
.const OUT_INERT                   = 5
.const BODY_RED                    = $fa
// Help page IDs are independent of their displayed order.
.const PAGE_LEGEND                 = 9
.const PAGE_EDITOR                 = 10
.const PAGE_LOOP_RESET             = 11
.const PAGE_ROBOT_DESTROYED        = 12
.const HALT_EDIT                   = 31
.const EV_ROOM                     = 11
// The reactor service record needs FEEDBACK diagnostics to be read.
.const REC_SERVICE                 = 9
.const HALT_NO_DIAG                = 23
// ACCESS at the reactor module with the chip in hand: the chip goes in with DROP.
.const HALT_USE_DROP               = 24
// ACCESS at the module without the chip, and ACCESS at a sealed door.
.const HALT_SEALED_MODULE          = 25
.const HALT_DOOR_POWER             = 26
.const HALT_DOOR_INSIDE            = 27
// DROP onto a tile that already holds cargo.
.const HALT_TAKEN                  = 28
// READ at a terminal without power, ACCESS at the dock hatch without power.
.const HALT_OFFLINE                = 29
.const HALT_HATCH_POWER            = 30
// Device 4 is the duct hatch in the dock south wall.
.const DEV_DOCK_HATCH              = 4
// A cell on the east dock socket: no load yet, or the hatch has power.
.const EV_NO_LOAD                  = 12
.const EV_HATCH_LIVE               = 13
.const EV_INSPECT                  = 14
.const HALT_FIRMWARE               = 32
// A page redraw without a clear: the image editor redraws only its slots.
.const DIRTY_SLOTS                 = %01000000
.const INS_EDGE                    = 28
.const INS_TERMINAL_OFF            = 29
.const INS_LIBRARY_OFF             = 30
.const INS_UPLINK_OFF              = 31
.const INS_HATCH_LIVE              = 32
.const INS_HATCH_ORBIT             = 33
.const INS_HATCH_FEEDBACK          = 34
.const INS_MODULE_DIAG             = 35
.const INS_CHIP_READY              = 36
.const INS_POWER_CHANGED           = 37
.const INS_DOCK_SOCKET             = 38
.const INS_WORKSHOP_SOCKET         = 39
.const INS_JUNCTION_SOCKET         = 40
.const INS_HUB_SOCKET              = 41
.const INS_ARCHIVE_SOCKET          = 42
.const INS_HATCH_SOCKET            = 43
.const INS_JUNCTION_DOOR           = 44
.const INS_VAULT_SOCKET            = 45
.const INS_COOL3_ON                = 46
.const INS_COOL5_ON                = 48
.const INS_COOL7_ON                = 50
