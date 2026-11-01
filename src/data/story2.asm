// CYCLE 64 - Additional reactor-story and control-image text.

// Second story text block ($3800-$3fff, after the runtime character set).
// Same body format as pages.asm: one zero-terminated line per row, at most
// 36 characters, optional colour prefix, BODY_END at the end.

// Log 13: the worker's note on the dock terminal. Needs power from M1.
rt_dock:
    .text "DOCK BAY NOTE"; .byte 0
rb_dock:
    .text "WORKER NOTE, DOCK BAY"; .byte 0
    .byte 0
    .text "THE OLD WORKSHOP TERMINAL STILL"; .byte 0
    .text "RUNS 'STUCK IN TIME'. GOOD GAME."; .byte 0
    .text "I HID IT BEHIND A WALL PANEL SO"; .byte 0
    .text "THE SUPERVISOR WON'T SEE IT."; .byte 0
    .byte 0
    .text "SCAN NEAR THE PANEL TO FIND IT."; .byte 0
    .text "IT NEEDS WORKSHOP SOCKET POWER."; .byte 0
    .byte 0
    .text "- R."; .byte 0
    .byte BODY_END

// Log 14: the security hub terminal behind the ORBIT gate. Gives ZENITH.
rt_hub:
    .text "SECURITY CAMERA LOG"; .byte 0
rb_hub:
    .text "SECURITY HUB CAMERA LOG"; .byte 0
    .byte 0
    .text "LAST MOVEMENT: STAFF WENT SOUTH"; .byte 0
    .text "IN GROUPS. NONE CAME BACK."; .byte 0
    .byte 0
    .text "SECTOR 02 ACCESS SUSPENDED."; .byte 0
    .text "JUNCTION ACCESS CODE: ZENITH."; .byte 0
    .byte 0
    .text "ZENITH OPENS THE WORKSHOP SOUTH"; .byte 0
    .text "GATE TO THE POWER JUNCTION."; .byte 0
    .byte BODY_END

// Message 3 (record 17): Sector 01 secured. M2 and ZENITH.
rb_sector01:
    .text "ZENITH IS NOW ON RECORD."; .byte 0
    .text "THE CODE OPENS THE WORKSHOP"; .byte 0
    .text "SOUTH GATE TO SECTOR 02."; .byte 0
    .byte 0
    .text "THE POWER JUNCTION LIES BEYOND."; .byte 0
    .text "EXPECT ACTIVE DEFENSES."; .byte 0
    .byte BODY_END
