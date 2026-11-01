// CYCLE 64 - Facility records, Command transmissions and their text-pointer tables.

// Console records: logs 1-14 (read by READ at terminals and libraries) and
// Command transmissions 15-24. Logs 13-14 and message 3 are in story2.asm.
// Same body format as pages.asm. Revised dialogue follows the approved v2
// text-overhaul package; Command's sender label is rendered once per page.
rec_title_lo:
    .byte <empty_text_p, <rt_1, <rt_2, <rt_3, <rt_4, <rt_5, <rt_6, <rt_7, <rt_8, <rt_9, <rt_10, <rt_11, <rt_12, <rt_dock, <rt_hub
    .byte <rt_13, <rt_14, <rt_15, <rt_16, <rt_17, <rt_18, <rt_19, <rt_20, <rt_21, <rt_22
rec_title_hi:
    .byte >empty_text_p, >rt_1, >rt_2, >rt_3, >rt_4, >rt_5, >rt_6, >rt_7, >rt_8, >rt_9, >rt_10, >rt_11, >rt_12, >rt_dock, >rt_hub
    .byte >rt_13, >rt_14, >rt_15, >rt_16, >rt_17, >rt_18, >rt_19, >rt_20, >rt_21, >rt_22
rec_body_lo:
    .byte <empty_text_p, <rb_1, <rb_2, <rb_3, <rb_4, <rb_5, <rb_6, <rb_7, <rb_8, <rb_9, <rb_10, <rb_11, <rb_12, <rb_dock, <rb_hub
    .byte <rb_13, <rb_14, <rb_sector01, <rb_16, <rb_17, <rb_18, <rb_19, <rb_20, <rb_21, <rb_22
rec_body_hi:
    .byte >empty_text_p, >rb_1, >rb_2, >rb_3, >rb_4, >rb_5, >rb_6, >rb_7, >rb_8, >rb_9, >rb_10, >rb_11, >rb_12, >rb_dock, >rb_hub
    .byte >rb_13, >rb_14, >rb_sector01, >rb_16, >rb_17, >rb_18, >rb_19, >rb_20, >rb_21, >rb_22
empty_text_p:
    .byte 0
rt_1:
    .text "MAINTENANCE LOG"; .byte 0
rt_2:
    .text "WORKSHOP PROGRAMMER"; .byte 0
rt_3:
    .text "SECURITY RECORD"; .byte 0
rt_4:
    .text "PULSE LIBRARY"; .byte 0
rt_5:
    .text "ROUTE LIBRARY"; .byte 0
rt_6:
    .text "EVACUATION ORDER"; .byte 0
rt_7:
    .text "FEEDBACK LIBRARY"; .byte 0
rt_8:
    .text "CONTAINMENT STATUS"; .byte 0
rt_9:
    .text "REACTOR SERVICE RECORD"; .byte 0
rt_10:
    .text "OPERATING NOTES"; .byte 0
rt_11:
    .text "ARCHIVE UPLINK"; .byte 0
rt_12:
    .text "DIRECTOR'S FINAL ENTRY"; .byte 0
rt_13:
    .text "COMMAND: FIRST CELL"; .byte 0
rt_14:
    .text "COMMAND: ORBIT"; .byte 0
rt_15:
    .text "COMMAND: SECTOR 01"; .byte 0
rt_16:
    .text "COMMAND: BEFORE THE RESET"; .byte 0
rt_17:
    .text "COMMAND: FIRMWARE"; .byte 0
rt_18:
    .text "COMMAND: JUNCTION POWER"; .byte 0
rt_19:
    .text "COMMAND: ORDER SUSPENDED"; .byte 0
rt_20:
    .text "COMMAND: THEY ARE ALIVE"; .byte 0
rt_21:
    .text "COMMAND: NEW ORDERS"; .byte 0
rt_22:
    .text "COMMAND: ONE LOOP"; .byte 0

rb_1:
    .text "SECTOR 01 MAINTENANCE LOG"; .byte 0
    .byte 0
    .text "SECTOR POWER DISCONNECTED."; .byte 0
    .text "REASON: CENTRAL SECURITY DIRECTIVE."; .byte 0
    .text "NO EQUIPMENT FAILURE DETECTED."; .byte 0
    .byte 0
    .text "ALL SECTION DOORS SEALED BY ORDER."; .byte 0
    .text "MAINTENANCE STAFF RECALLED."; .byte 0
    .byte 0
    .byte BODY_WHITE; .text "MAINTENANCE OVERRIDE CODE: ORBIT"; .byte 0
    .byte 0
    .byte BODY_GREY; .text "ORBIT OPENS THE SECURITY HUB GATE."; .byte 0
    .byte BODY_END
rb_2:
    .text "MAINTENANCE PROGRAMMER"; .byte 0
    .byte 0
    .text "STATUS: ONLINE"; .byte 0
    .text "CONTROL CHIP: MISSING"; .byte 0
    .byte BODY_WHITE; .text "SPARE CHIP: STORAGE RACK 01"; .byte 0
    .text "FIRMWARE IMAGE: UNAVAILABLE"; .byte 0
    .byte 0
    .byte BODY_GREY; .text "HOLD A CHIP, THEN ACCESS THE"; .byte 0
    .byte BODY_GREY; .text "PROGRAMMER TO WRITE AN IMAGE."; .byte 0
    .byte BODY_END
command_label:
    .text "COMMAND TO ROP ENGINEER"; .byte 0
rb_2_late:
    .text "MAINTENANCE PROGRAMMER"; .byte 0
    .byte 0
    .text "STATUS: ONLINE"; .byte 0
    .text "SPARE CHIP: STORAGE RACK 01"; .byte 0
    .text "REACTOR PROGRAM: AVAILABLE"; .byte 0
    .byte 0
    .text "PRESS K IN PLAN TO EDIT THE"; .byte 0
    .text "REACTOR CONTROL PROGRAM."; .byte 0
    .text "AUTHORIZING STARTS THE ROBOT RUN."; .byte 0
    .byte 0
    .text "PICK THE BLANK CHIP, THEN ACCESS"; .byte 0
    .text "THIS PROGRAMMER TO WRITE IT."; .byte 0
    .byte BODY_END

rb_3:
    .text "FACILITY SECURITY LOG"; .byte 0
    .byte 0
    .text "ALERT LEVEL: MAXIMUM."; .byte 0
    .text "ISSUED BEFORE THE FIRST RESET."; .byte 0
    .text "AUTOMATED DEFENSES ACTIVE."; .byte 0
    .text "PRIORITY: CONTAINMENT."; .byte 0
    .byte 0
    .text "JUNCTION: 4 CYCLES ON, 4 OFF."; .byte 0
    .text "COOLING: 3 GRIDS, DIFFERENT TIMINGS."; .byte 0
    .text "READ EACH GRID FOR ITS TIMING."; .byte 0
    .text "CROSS ONLY WHEN THE GRID IS OFF."; .byte 0
    .byte 0
    .text "ARCHIVE ACCESS CODE: VECTOR"; .byte 0
    .byte BODY_END
rb_4:
    .text "ROP FIRMWARE LIBRARY"; .byte 0
    .text "MODULE: PULSE CONTROL"; .byte 0
    .text "SOURCE: REACTOR ENGINEERING"; .byte 0
    .text "ROBOT COMPATIBILITY: YES"; .byte 0
    .byte 0
    .byte BODY_WHITE; .text "NEW COMMAND: BOOST (KEY B)"; .byte 0
    .byte BODY_WHITE; .text "MOVES UP TO 2 TILES PER CYCLE."; .byte 0
    .byte BODY_WHITE; .text "THE COUNT IS THE DISTANCE:"; .byte 0
    .byte BODY_WHITE; .text "BOOST E 3 = 3 TILES IN 2 CYCLES."; .byte 0
    .byte 0
    .byte BODY_YELLOW; .text "FIRMWARE STORED"; .byte 0
    .byte BODY_END
rb_5:
    .text "ROP FIRMWARE LIBRARY"; .byte 0
    .text "MODULE: ROUTE CONTROL"; .byte 0
    .text "SOURCE: REACTOR ENGINEERING"; .byte 0
    .text "ROBOT COMPATIBILITY: YES"; .byte 0
    .byte 0
    .byte BODY_WHITE; .text "NEW COMMAND: LINK (KEY L)"; .byte 0
    .byte BODY_WHITE; .text "MOVE THE CONTROL CHANNEL TO THE"; .byte 0
    .byte BODY_WHITE; .text "ROBOT BEHIND AN UPLINK. 2 CYCLES."; .byte 0
    .byte 0
    .byte BODY_YELLOW; .text "FIRMWARE STORED"; .byte 0
    .byte BODY_END
rb_6:
    .text "PERSONNEL EVACUATION ORDER"; .byte 0
    .byte 0
    .text "ALL STAFF TO THE EMERGENCY REFUGE."; .byte 0
    .text "DO NOT LEAVE THE FACILITY."; .byte 0
    .text "STASIS CHAMBERS: 31 OCCUPIED."; .byte 0
    .byte 0
    .text "REACTOR OUTPUT IS DIVERTED."; .byte 0
    .text "DO NOT RESTORE NORMAL OUTPUT."; .byte 0
    .byte 0
    .byte BODY_WHITE; .text "REFUGE LOCATION: SECTOR 03,"; .byte 0
    .byte BODY_WHITE; .text "EAST OF REACTOR CONTROL."; .byte 0
    .byte BODY_WHITE; .text "ACCESS SEALED."; .byte 0
    .byte 0
    .byte BODY_GREY; .text "THE REFUGE IS NOW ON YOUR MAP (M)."; .byte 0
    .byte BODY_END
rb_7:
    .text "ROP FIRMWARE LIBRARY"; .byte 0
    .text "MODULE: FEEDBACK CONTROL"; .byte 0
    .text "SOURCE: REACTOR ENGINEERING"; .byte 0
    .text "ROBOT COMPATIBILITY: YES"; .byte 0
    .byte 0
    .text "SCAN NOW DETECTS SHIELDED HATCHES."; .byte 0
    .text "RANGE UNCHANGED: 3 TILES."; .byte 0
    .text "READ UNLOCKS SEALED SERVICE DATA."; .byte 0
    .byte 0
    .text "RECHECK THE SEALED DOCK PANEL."; .byte 0
    .byte 0
    .text "FIRMWARE STORED"; .byte 0
    .byte BODY_END
rb_8:
    .text "REACTOR SAFETY MONITOR"; .byte 0
    .byte 0
    .text "TEMPORAL QUARANTINE ACTIVE."; .byte 0
    .text "RESET INTERVAL: 64 CYCLES."; .byte 0
    .text "PHASE BREACH CONTAINED."; .byte 0
    .byte 0
    .text "REACTOR OUTPUT FEEDS THE"; .byte 0
    .text "CONTAINMENT FIELD AND THE BARRIER."; .byte 0
    .text "THE RESET STOPS THE BREACH FROM"; .byte 0
    .text "GROWING PAST ITS CRITICAL POINT."; .byte 0
    .byte 0
    .byte BODY_RED; .text "WARNING: FULL REACTOR SHUTDOWN"; .byte 0
    .byte BODY_RED; .text "WILL TERMINATE CONTAINMENT."; .byte 0
    .byte BODY_END
rb_9:
    .text "REACTOR CONTROL REQUIRES"; .byte 0
    .text "A NEW PROGRAMMED CHIP."; .byte 0
    .byte 0
    .text "COMPATIBLE PROGRAMMER:"; .byte 0
    .text "SECTOR 01 - MAINTENANCE WORKSHOP."; .byte 0
    .text "BLANK CHIP: STORAGE RACK 01."; .byte 0
    .byte 0
    .text "REACTOR CONTROL SHARES THE"; .byte 0
    .text "ROBOTS' ROP LIBRARIES:"; .byte 0
    .text "PULSE, ROUTE AND FEEDBACK."; .byte 0
    .byte 0
    .text "RETURN TO THE WORKSHOP."; .byte 0
    .text "PROGRAM THE CHIP AND DELIVER IT"; .byte 0
    .text "IN THE SAME 64-CYCLE LOOP."; .byte 0
    .byte BODY_END
rb_10:
    .text "FIELD OPERATING NOTES"; .byte 0
    .byte 0
    .text "REGULATE OUTPUT BEFORE"; .byte 0
    .text "OVERCLOCKING THE PROCESSOR."; .byte 0
    .byte 0
    .text "ONLY AN OVERCLOCKED PROCESSOR"; .byte 0
    .text "CAN REROUTE THE FIELD COILS."; .byte 0
    .byte 0
    .text "CONTRACT THE FIELD BEFORE"; .byte 0
    .text "TURNING TEMPORAL QUARANTINE OFF."; .byte 0
    .byte 0
    .text "FEEDBACK REGULATES."; .byte 0
    .text "PULSE OVERCLOCKS."; .byte 0
    .text "ROUTE CONTRACTS."; .byte 0
    .byte BODY_END
rb_11:
    .text "ARCHIVE UPLINK 02"; .byte 0
    .byte 0
    .text "LINKED UNIT: VAULT MAINTENANCE"; .byte 0
    .text "STATUS: DORMANT, CHANNEL FREE"; .byte 0
    .text "VAULT ACCESS: SEALED"; .byte 0
    .byte 0
    .byte BODY_GREY; .text "A LINK COMMAND HERE MOVES THE"; .byte 0
    .byte BODY_GREY; .text "CONTROL CHANNEL TO THE VAULT UNIT."; .byte 0
    .byte BODY_GREY; .text "IT NEEDS ROUTE FIRMWARE."; .byte 0
    .byte BODY_END

rb_12:
    .text "FACILITY DIRECTOR - FINAL ENTRY"; .byte 0
    .byte 0
    .text "THE BREACH GROWS FASTER THAN WE"; .byte 0
    .text "CAN CONTAIN IT. ONE OPTION LEFT."; .byte 0
    .byte 0
    .text "WE LOCK THE FACILITY IN A 64-CYCLE"; .byte 0
    .text "LOOP. THE BREACH NEVER REACHES ITS"; .byte 0
    .text "CRITICAL POINT. NEITHER DO WE."; .byte 0
    .text "ALL STAFF TO STASIS."; .byte 0
    .byte 0
    .byte BODY_WHITE; .text "ONE DAY SOMEONE OUTSIDE WILL FIND"; .byte 0
    .byte BODY_WHITE; .text "THE OLD MAINTENANCE LINK. TO YOU:"; .byte 0
    .byte BODY_WHITE; .text "DO NOT CUT THE POWER. SHRINK THE"; .byte 0
    .byte BODY_WHITE; .text "FIELD. THEN LET US OUT."; .byte 0
    .byte 0
    .byte BODY_YELLOW; .text "THE FACILITY FORGETS. YOU WILL"; .byte 0
    .byte BODY_YELLOW; .text "HAVE TO REMEMBER FOR US."; .byte 0
    .byte BODY_END

// Command transmissions, records 15-24 (labels rb_13-rb_22, message 3 is
// rb_sector01 in story2.asm). after_tick stores them as soon as their conditions
// in trans_* (editor.asm) are met, and the log viewer opens them.
rb_13:
    .text "THE DOCK SOCKET IS LIVE."; .byte 0
    .text "FIRST AUXILIARY POWER RESTORED"; .byte 0
    .text "IN SECTOR 01."; .byte 0
    .byte 0
    .text "THE NEXT RESET WILL CLEAR IT AGAIN."; .byte 0
    .text "YOUR PROGRESS IS ON RECORD."; .byte 0
    .byte 0
    .text "EXPLORE EAST. CHECK THE WORKSHOP."; .byte 0
    .byte BODY_END
rb_14:
    .text "OUR FILES CALL THE OUTAGE AN"; .byte 0
    .text "ACCIDENT. YOUR LOG SAYS IT WAS"; .byte 0
    .text "ORDERED. WHY?"; .byte 0
    .byte 0
    .text "ORBIT OPENS THE SECURITY HUB GATE."; .byte 0
    .text "CHECK THE CAMERAS FOR ANSWERS."; .byte 0
    .byte BODY_END
rb_16:
    .text "MAXIMUM ALERT WAS DECLARED"; .byte 0
    .text "BEFORE THE FIRST RESET."; .byte 0
    .byte 0
    .text "THE FACILITY WAS SEALED FIRST."; .byte 0
    .text "SOMEONE KNEW WHAT WAS COMING."; .byte 0
    .byte 0
    .text "THE EXPERIMENT FILES ARE STILL"; .byte 0
    .text "BEYOND OUR CLEARANCE."; .byte 0
    .byte 0
    .text "VECTOR OPENS THE ARCHIVE."; .byte 0
    .byte BODY_END
rb_17:
    .text "PULSE WORKS ON THE ROBOT."; .byte 0
    .text "THE REACTOR AND ROBOTS SHARE"; .byte 0
    .text "THE SAME ROP CORE. INTERESTING."; .byte 0
    .byte 0
    .text "BOOST SAVES CYCLES ON LONG ROUTES."; .byte 0
    .text "OLD ROUTES MAY BE WORTH REVISITING."; .byte 0
    .byte BODY_END
rb_18:
    .text "BOTH JUNCTION CELLS ARE LIVE."; .byte 0
    .text "THE REACTOR DOOR STAYS OPEN ONLY"; .byte 0
    .text "WHILE BOTH SOCKETS ARE POWERED."; .byte 0
    .byte 0
    .text "REACH REACTOR CONTROL."; .byte 0
    .text "READ ITS STATUS BEFORE SHUTDOWN."; .byte 0
    .byte BODY_END
rb_19:
    .text "STOP. DO NOT CUT REACTOR POWER."; .byte 0
    .byte 0
    .text "THE LOOP IS NOT A FAULT."; .byte 0
    .text "IT IS TEMPORAL QUARANTINE."; .byte 0
    .text "THE STAFF ACTIVATED IT TO"; .byte 0
    .text "CONTAIN THE BREACH."; .byte 0
    .byte 0
    .text "WE DIDN'T KNOW."; .byte 0
    .text "THE SHUTDOWN ORDER IS CANCELLED."; .byte 0
    .byte 0
    .text "FIND A WAY TO PRESERVE THE FIELD."; .byte 0
    .byte BODY_END
rb_20:
    .text "31 STAFF ARE ALIVE IN STASIS,"; .byte 0
    .text "EAST OF REACTOR CONTROL."; .byte 0
    .byte 0
    .text "EACH RESET RETURNS THEM TO THE"; .byte 0
    .text "SAME MOMENT. THEY DEPEND ON THE"; .byte 0
    .text "CONTAINMENT FIELD."; .byte 0
    .byte 0
    .text "DO NOT LET IT FAIL."; .byte 0
    .byte BODY_END
rb_21:
    .text "NEW ORDERS: KEEP THE REACTOR ON."; .byte 0
    .byte 0
    .text "CONTRACT THE FIELD AROUND THE"; .byte 0
    .text "BREACH, THEN END THE RESET."; .byte 0
    .byte 0
    .text "A NEW CONTROL CHIP IS REQUIRED."; .byte 0
    .text "THE COMPATIBLE PROGRAMMER IS IN"; .byte 0
    .text "THE SECTOR 01 MAINTENANCE WORKSHOP."; .byte 0
    .byte 0
    .text "THE COOLING PLANT HOLDS THE"; .byte 0
    .text "OPERATING NOTES. STUDY THEM FIRST."; .byte 0
    .byte BODY_END
rb_22:
    .text "YOU HAVE THE OPERATING NOTES."; .byte 0
    .text "THE FINAL TASK MUST FIT ONE LOOP."; .byte 0
    .byte 0
    .text "TAKE THE SPARE CHIP FROM"; .byte 0
    .text "STORAGE RACK 01 IN THE WORKSHOP."; .byte 0
    .text "PROGRAM IT, THEN DELIVER IT TO"; .byte 0
    .text "REACTOR CONTROL."; .byte 0
    .byte 0
    .text "THE CHIP WILL RESET WITH THE"; .byte 0
    .text "FACILITY. YOUR PLAN WILL NOT."; .byte 0
    .byte 0
    .text "THE DOCK MAY HIDE A SHORTER ROUTE."; .byte 0
    .byte BODY_END

// Ending pages.
body_good:
    .text "REACTOR CONTROL IMAGE ACCEPTED."; .byte 0
    .byte 0
    .text "FEEDBACK, PULSE, ROUTE: THE FIELD"; .byte 0
    .text "CONTRACTS AROUND THE BREACH."; .byte 0
    .text "RESET OFF: QUARANTINE RELEASED."; .byte 0
    .byte 0
    .byte BODY_WHITE; .text "THE NEXT CYCLE IS CYCLE 65."; .byte 0
    .byte 0
    .text "COMMAND: REFUGE SIGNAL RECEIVED."; .byte 0
    .text "31 HEARTBEATS. RESCUE TEAMS ARE"; .byte 0
    .text "MOVING IN. THE BREACH STAYS"; .byte 0
    .text "CONTAINED, AND NOW IT CAN BE"; .byte 0
    .text "STUDIED. THANK YOU, ENGINEER."; .byte 0
    .byte 0
    .byte BODY_YELLOW; .text "THE FACILITY FORGETS,"; .byte 0
    .byte BODY_YELLOW; .text "BUT YOU REMEMBER."; .byte 0
    .byte BODY_END
body_shut:
    .text "FULL REACTOR SHUTDOWN EXECUTED."; .byte 0
    .byte 0
    .text "REACTOR OUTPUT: ZERO."; .byte 0
    .text "TEMPORAL QUARANTINE: OFFLINE."; .byte 0
    .text "CONTAINMENT FIELD: NO POWER."; .byte 0
    .text "PHASE BARRIER: COLLAPSING."; .byte 0
    .byte 0
    .text "THE LOOP HAS ENDED."; .byte 0
    .text "SO HAS THE CONTAINMENT."; .byte 0
    .byte 0
    .byte BODY_RED; .text "SIGNAL LOST."; .byte 0
    .byte 0
    .byte BODY_GREY; .text "RETURN RESTORES THE LAST LOOP"; .byte 0
    .byte BODY_GREY; .text "FROM THE CONSOLE RECORDS."; .byte 0
    .byte BODY_END
body_release:
    .text "TEMPORAL QUARANTINE RELEASED."; .byte 0
    .byte 0
    .text "CONTAINMENT FIELD: NOT CONTRACTED."; .byte 0
    .text "FIELD STABILITY: FAILING."; .byte 0
    .text "PHASE BREACH: EXPANDING."; .byte 0
    .byte 0
    .text "THE RESET HELD THE BREACH IN PLACE."; .byte 0
    .text "NOW NOTHING DOES."; .byte 0
    .byte 0
    .byte BODY_RED; .text "SIGNAL LOST."; .byte 0
    .byte 0
    .byte BODY_GREY; .text "RETURN RESTORES THE LAST LOOP"; .byte 0
    .byte BODY_GREY; .text "FROM THE CONSOLE RECORDS."; .byte 0
    .byte BODY_END

// Reactor image editor: command names, hard errors and warnings.
rc_names_lo:
    .byte <rc_0, <rc_1, <rc_2, <rc_3, <rc_4, <rc_5
rc_names_hi:
    .byte >rc_0, >rc_1, >rc_2, >rc_3, >rc_4, >rc_5
rc_0:
    .text "--"; .byte 0
rc_1:
    .text "FEEDBACK"; .byte 0
rc_2:
    .text "PULSE"; .byte 0
rc_3:
    .text "ROUTE"; .byte 0
rc_4:
    .text "RESET OFF"; .byte 0
rc_5:
    .text "SHUTDOWN"; .byte 0
im_head:
    .text "CYCLE 64   REACTOR CONTROL IMAGE"; .byte 0
im_intro:
    .text "COMMANDS RUN FROM TOP TO BOTTOM."; .byte 0
im_help1:
    .text "UP/DOWN SLOT   LEFT/RIGHT COMMAND"; .byte 0
im_help2:
    .text "DEL CLEAR      RETURN AUTHORIZE"; .byte 0
im_help3:
    .text "AUTHORIZE STARTS THE ROBOT PROGRAM."; .byte 0
im_check:
    .text "REACTOR FIRMWARE CHECK"; .byte 0
im_error:
    .text "ERROR:"; .byte 0
im_warning:
    .text "WARNING:"; .byte 0
im_empty:
    .text "IMAGE EMPTY"; .byte 0
im_missing:
    .text "MISSING FIRMWARE IMAGE:"; .byte 0
im_any:
    .text "ANY KEY: BACK TO EDITING"; .byte 0
im_execute:
    .text "EXECUTE?"; .byte 0
im_yes:
    .text "YES"; .byte 0
im_no:
    .text "NO"; .byte 0
im_slash:
    .text "/"; .byte 0
im_shut1:
    .text "IRREVERSIBLE FULL SHUTDOWN"; .byte 0
im_shut2:
    .text "THIS CANNOT BE UNDONE"; .byte 0
im_shut3:
    .text "WILL TERMINATE CONTAINMENT"; .byte 0
im_danger:
    .text "DANGEROUS COMMAND ORDER"; .byte 0
im_incompat:
    .text "INCOMPATIBLE COMMAND ORDER"; .byte 0
im_failure:
    .text "POSSIBLE SYSTEM FAILURE"; .byte 0
ft_image:
    .text "RETURN: AUTHORIZE   K: BACK"; .byte 0
ft_confirm:
    .text "LEFT/RIGHT: CHOOSE   RETURN: CONFIRM"; .byte 0
ft_browse:
    .text "LEFT/RIGHT: BROWSE   RETURN: BACK"; .byte 0
ft_next_log:
    .text "LEFT/RIGHT: BROWSE   RETURN: NEXT NEW"; .byte 0
ft_reconnect:
    .text "RETURN: BACK TO THE CONSOLE"; .byte 0
// Mission log page.
ml_head:
    .text "CYCLE 64   MISSION LOG"; .byte 0
ml_names_lo:
    .byte <ml_1, <ml_2, <ml_3, <ml_4, <ml_5
ml_names_hi:
    .byte >ml_1, >ml_2, >ml_3, >ml_4, >ml_5
ml_1:
    .text "M1 POWER AND EXPLORE THE DOCK"; .byte 0
ml_2:
    .text "M2 UNLOCK SECURITY HUB OFFICE"; .byte 0
ml_3:
    .text "M3 ENTER THE POWER JUNCTION"; .byte 0
ml_4:
    .text "M4 POWER SECURITY DOOR"; .byte 0
ml_5:
    .text "M5 TURN OFF REACTOR"; .byte 0
ml_done:
    .text "DONE"; .byte 0
ml_open:
    .text "OPEN"; .byte 0
ml_best:
    .text " BEST "; .byte 0
ml_cycles:
    .text " CYCLES"; .byte 0
ml_no_time:
    .text " BEST -- CYCLES  -- LINES LOOP --"; .byte 0
ml_loop:
    .text " LOOP "; .byte 0
ml_secured:
    .text "SECURED"; .byte 0
ml_lost:
    .text "LOST"; .byte 0
ml_hint:
    .text "HINT: "; .byte 0
ml_codes:
    .text "CODES:"; .byte 0
ml_lines:
    .text " LINES"; .byte 0
ml_logs:
    .text "LOGS STORED: "; .byte 0
ml_of:
    .text "/14"; .byte 0
ml_fw:
    .text "FIRMWARE:"; .byte 0
ml_fw_names_lo:
    .byte <rc_2, <rc_3, <rc_1
ml_fw_names_hi:
    .byte >rc_2, >rc_3, >rc_1
log_text:
    .text "LOG "; .byte 0
msg_text:
    .text "MSG "; .byte 0
