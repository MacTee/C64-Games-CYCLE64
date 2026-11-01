// CYCLE 64 - Static briefing, help, ending and reactor-image text.

// Text pages on the terminal screen: briefing 1, briefing 2 and help.
// Briefings use the approved text-overhaul v2 copy.
// A body is one zero-terminated line per row from row 3, at most 36 characters.
// An optional first byte $f0+colour changes the line colour (default light blue).
// The byte BODY_END ends the body. The BODY_ constants are in constants.asm.

// Indexed by page - 1: help, briefing 1, briefing 2, record viewer and image
// editor (drawn at run time), good ending, shutdown ending, release ending,
// tile legend (the second help page).
page_head_lo:
    .byte <hd_help, <hd_brief1, <hd_brief2, 0, 0, <hd_good, <hd_lost, <hd_lost, <hd_legend, <hd_editor_help
page_head_hi:
    .byte >hd_help, >hd_brief1, >hd_brief2, 0, 0, >hd_good, >hd_lost, >hd_lost, >hd_legend, >hd_editor_help
page_head_color:
    .byte 3, 3, 3, 3, 3, 7, 10, 10, 3, 3
page_num_lo:
    .byte <pg_2, <pg_brief1, <pg_brief2, 0, 0, <empty_text, <empty_text, <empty_text, <pg_3, <pg_1
page_num_hi:
    .byte >pg_2, >pg_brief1, >pg_brief2, 0, 0, >empty_text, >empty_text, >empty_text, >pg_3, >pg_1
page_body_lo:
    .byte <body_help, <body_brief1, <body_brief2, 0, 0, <body_good, <body_shut, <body_release, <body_legend, <body_editor_help
page_body_hi:
    .byte >body_help, >body_brief1, >body_brief2, 0, 0, >body_good, >body_shut, >body_release, >body_legend, >body_editor_help

hd_good:
    .text "CYCLE 64   CONTAINMENT SECURED"; .byte 0
hd_lost:
    .text "CYCLE 64   LINK LOST"; .byte 0
hd_brief1:
    .text "CYCLE 64   MISSION BRIEFING"; .byte 0
hd_brief2:
    .text "CYCLE 64   OPERATION ORDERS"; .byte 0
hd_help:
    .text "CYCLE 64   ROP COMMANDS"; .byte 0
pg_1:
    .text "1/3"; .byte 0
pg_2:
    .text "2/3"; .byte 0
pg_3:
    .text "3/3"; .byte 0
pg_brief1:
    .text "1/2"; .byte 0
pg_brief2:
    .text "2/2"; .byte 0
plate_text:
    .text " ROP LINK CONSOLE "; .byte 0
ft_next:
    .text "SPACE: NEXT     RUN/STOP: SKIP"; .byte 0
ft_to_help:
    .text "SPACE: HELP     RUN/STOP: SKIP"; .byte 0
ft_start:
    .text "SPACE: START   LEFT/RIGHT: NAVIGATE"; .byte 0
.assert "Help start footer fits", *-ft_start-1 <= 35, true
ft_legend_start:
    .text "SPACE: START   LEFT/RIGHT: NAVIGATE"; .byte 0
ft_legend_back:
    .text "SPACE: BACK    LEFT/RIGHT: NAVIGATE"; .byte 0
hd_legend:
    .text "CYCLE 64   FACILITY TILES"; .byte 0
ft_back:
    .text "SPACE: BACK    LEFT/RIGHT: NAVIGATE"; .byte 0

body_brief1:
    .text "FACILITY ALPHA IS TRAPPED INSIDE"; .byte 0
    .text "A TEMPORAL ANOMALY."; .byte 0
    .byte 0
    .text "EVERY 64 CYCLES, ITS PHYSICAL"; .byte 0
    .text "STATE RESETS TO THE START."; .byte 0
    .byte 0
    .text "A PHASE BARRIER BLOCKS ENTRY."; .byte 0
    .text "NO PERSON OR CARGO CAN PASS."; .byte 0
    .byte 0
    .text "ONLY THIS CONSOLE KEEPS RECORDS"; .byte 0
    .text "BETWEEN LOOPS. AN OLD MAINTENANCE"; .byte 0
    .text "LINK STILL REACHES THE ROBOTS."; .byte 0
    .byte 0
    .text "YOU ARE OUR BEST ROP ENGINEER."; .byte 0
    .text "WE NEED YOUR HELP."; .byte 0
    .byte 0
    .text "THE EXPERIMENT IS CLASSIFIED."; .byte 0
    .text "YOUR CLEARANCE IS LIMITED."; .byte 0
    .byte BODY_END

body_brief2:
    .text "THE EXPERIMENT DRAWS MOST OF THE"; .byte 0
    .text "REACTOR'S POWER. OTHER SECTORS"; .byte 0
    .text "RUN ON EMERGENCY RESERVES."; .byte 0
    .byte 0
    .text "LOCKDOWN IS ACTIVE. EXPECT"; .byte 0
    .text "SEALED GATES AND ARMED LASERS."; .byte 0
    .byte 0
    .text "RESTORE POWER TO THE SECTORS."; .byte 0
    .text "REACH REACTOR CONTROL."; .byte 0
    .text "CUT THE REACTOR OUTPUT."; .byte 0
    .byte 0
    .text "COMMAND BELIEVES THIS MAY END"; .byte 0
    .text "THE LOOP. WE CANNOT BE CERTAIN."; .byte 0
    .byte 0
    .text "ONLY ONE ROBOT CAN BE CONTROLLED."; .byte 0
    .text "THE OLD LINK CANNOT SUPPORT"; .byte 0
    .text "LIVE CONTROL."; .byte 0
    .byte 0
    .text "UPLOAD A ROP PROGRAM. THEN RUN."; .byte 0
    .byte BODY_END

// The command table is drawn in columns by draw_commands.
body_help:
    .byte BODY_END

hc_key:
    .text "KEY"; .byte 0
hc_command:
    .text "COMMAND"; .byte 0
hc_param:
    .text "PARAM"; .byte 0
hc_cycles:
    .text "CYCLES"; .byte 0
hc_move:
    .text "MOVE"; .byte 0
hc_key_move:
    .text "N/E/S/W"; .byte 0
hc_key_wait:
    .text "T"; .byte 0
hc_key_pick:
    .text "P"; .byte 0
hc_key_drop:
    .text "D"; .byte 0
hc_key_read:
    .text "R"; .byte 0
hc_key_access:
    .text "A"; .byte 0
hc_key_scan:
    .text "C"; .byte 0
hc_key_boost:
    .text "B"; .byte 0
hc_key_link:
    .text "L"; .byte 0
hc_num:
    .text "1-15"; .byte 0
hc_dir:
    .text "DIR"; .byte 0
hc_none:
    .text "NONE"; .byte 0
hc_dir_num:
    .text "DIR+NUM"; .byte 0
hc_tile:
    .text "1/TILE"; .byte 0
hc_count:
    .text "1/COUNT"; .byte 0
hc_one:
    .text "1"; .byte 0
hc_two:
    .text "2"; .byte 0
hc_half:
    .text "HALF*"; .byte 0
hc_param_note:
    .text "PARAM CHANGE: LEFT / RIGHT KEYS"; .byte 0
.assert "Parameter instruction fits", *-hc_param_note-1 <= 37, true
hc_num_note:
    .text "*BOOST ROUNDS UP"; .byte 0
hc_music_note:
    .text "F5: MUSIC ON/OFF (SFX STAY ON)"; .byte 0
hc_access_note:
    .text "ACCESS: USES RIGHT CODE IF FOUND"; .byte 0
hc_fw_note:
    .text "BOOST/LINK: NEEDS FIRMWARE UPGRADE"; .byte 0
hc_play:
    .text "F1 RUN F3 STEP F7 RESET V LOGS H HELP"; .byte 0
.assert "Help controls fit inside casing", *-hc_play-1 <= 37, true
hc_keys_lo:
    .byte <hc_key_move, <hc_key_wait, <hc_key_pick, <hc_key_drop, <hc_key_read, <hc_key_access, <hc_key_scan, <hc_key_boost, <hc_key_link
hc_keys_hi:
    .byte >hc_key_move, >hc_key_wait, >hc_key_pick, >hc_key_drop, >hc_key_read, >hc_key_access, >hc_key_scan, >hc_key_boost, >hc_key_link
hc_names_lo:
    .byte <hc_move, <nm_wait, <nm_pick, <nm_drop, <nm_read, <nm_access, <nm_scan, <nm_boost, <nm_link
hc_names_hi:
    .byte >hc_move, >nm_wait, >nm_pick, >nm_drop, >nm_read, >nm_access, >nm_scan, >nm_boost, >nm_link
hc_params_lo:
    .byte <hc_num, <hc_num, <hc_dir, <hc_dir, <hc_dir, <hc_dir, <hc_none, <hc_dir_num, <hc_dir
hc_params_hi:
    .byte >hc_num, >hc_num, >hc_dir, >hc_dir, >hc_dir, >hc_dir, >hc_none, >hc_dir_num, >hc_dir
hc_costs_lo:
    .byte <hc_tile, <hc_count, <hc_one, <hc_one, <hc_two, <hc_one, <hc_two, <hc_half, <hc_two
hc_costs_hi:
    .byte >hc_tile, >hc_count, >hc_one, >hc_one, >hc_two, >hc_one, >hc_two, >hc_half, >hc_two

// All 21 tile explanations are drawn on the second help page.
body_legend:
    .byte BODY_END

hd_editor_help:
    .text "CYCLE 64   CODE EDITOR"; .byte 0
body_editor_help:
    .byte BODY_END
eh_up:
    .text "UP/DOWN: SELECT LINE"; .byte 0
eh_key1:
    .text "COMMAND KEY: ADD OR"; .byte 0
eh_key2:
    .text "REPLACE INSTRUCTION"; .byte 0
eh_param1:
    .text "LEFT/RIGHT: CHANGE"; .byte 0
eh_param2:
    .text "PARAMETER VALUE"; .byte 0
eh_insert:
    .text "I: INSERT EMPTY LINE"; .byte 0
eh_delete:
    .text "DEL: REMOVE LINE"; .byte 0
eh_next:
    .text "RETURN: NEXT"; .byte 0
eh_logs:
    .text "V: VIEW MISSION LOG"; .byte 0
ctl_error:
    .text "RETURN: EDIT  F1 RETRY  F7 RESET H HELP"; .byte 0
edit_pause_text:
    .text "EDIT COMMAND. F1 CONTINUES"; .byte 0
