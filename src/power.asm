// CYCLE 64 - Socket occupancy, live power, powered visibility and equipment appearance.

// Live power is derived from actual cell positions. No delivery consumes a cell.
socket_room:
    .byte 0, 1, 3, 3, 2, 4, 0, 4
socket_x:
    .byte 1, 7, 3, 4, 8, 2, 10, 10
socket_y:
    .byte 7, 1, 8, 8, 7, 8, 8, 2
socket_bit:
    .byte 1, 2, 4, 8, 16, 32, 64, 128
room_power_bits:
    .byte 65, 2, 16, 12, 160, 0, 0, 0, 0

// Recompute socket power after cargo moves; retained as the public delivery hook.
record_delivery:
{
    jmp refresh_power
}

// Derive socket occupancy, gate state, lighting and mission events from cargo positions.
refresh_power:
{
    lda powered_mask
    sta scratch+16
    lda #0
    sta powered_mask
    ldy #SOCKET_COUNT-1
    !socket:
    ldx #CARGO_CHIP-1
    !cell:
    lda cargo_room, x
    cmp socket_room, y
    bne !nextCell+
    lda cargo_x, x
    cmp socket_x, y
    bne !nextCell+
    lda cargo_y, x
    cmp socket_y, y
    bne !nextCell+
    lda powered_mask
    ora socket_bit, y
    sta powered_mask
    !nextCell:
    dex
    bpl !cell-
    dey
    bpl !socket-
    // The boundary is the door itself, and becomes the exit only with two cells.
    lda #TILE_DOOR
    ldx powered_mask
    txa
    and #%00001100
    cmp #12
    bne !closed+
    lda #TILE_EXIT
    bne !door+
    !closed:
    lda #TILE_DOOR
    !door:
    sta live_tiles+DOOR_ROOM*120+DOOR_INDEX
    lda powered_mask
    and #%01000000
    bne !hatchLive+
    lda #TILE_HATCH
    sta live_tiles+116
    !hatchLive:
    // Room layouts learned while lit remain on the map; live lighting does not.
    ldx #ROOM_COUNT-1
    !room:
    lda powered_mask
    and room_power_bits, x
    beq !nextRoom+
    stx scratch+17
    lda discovery_lo, x
    sta data_ptr
    lda discovery_hi, x
    sta data_ptr+1
    ldy #119
    !tile:
    cpx #4
    bne !reveal+
    // Main socket and vault socket reveal only their own region.
    tya
    jsr archive_region_power
    beq !nextTile+
    !reveal:
    lda #1
    sta (data_ptr), y
    !nextTile:
    dey
    bpl !tile-
    !nextRoom:
    dex
    bpl !room-
    lda powered_mask
    and #%00000001
    beq !doorMission+
    lda scratch+16
    and #%00000001
    bne !doorMission+
    ldx #MISSION_DOCK
    lda elapsed
    clc
    adc #1
    jsr record_mission
    !doorMission:
    lda powered_mask
    and #%00001100
    cmp #12
    bne !powerEvent+
    lda scratch+16
    and #%00001100
    cmp #12
    beq !powerEvent+
    ldx #MISSION_DOOR
    lda elapsed
    clc
    adc #1
    jsr record_mission
    !powerEvent:
    lda powered_mask
    cmp scratch+16
    beq !done+
    // Inspection conveys power removal without claiming that a device stays on.
    lda #INS_POWER_CHANGED
    sta event_arg
    lda #EV_INSPECT
    jsr raise_event
    !done:
    rts
}

// Return A = dock-hatch power bit, with Z set when its socket is empty.
hatch_powered:
{
    lda powered_mask
    and #%01000000
    rts
}

// Rendering: whole powered rooms except the independent archive vault.
room_powered:
{
    ldx view_room
    lda powered_mask
    and room_power_bits, x
    rts
}

// Return a nonzero A when the currently rendered map tile has live lighting.
map_tile_lit:
{
    lda map_powered
    beq !no+
    lda view_room
    cmp #4
    bne !yes+
    lda render_index
    jmp archive_region_power
    !yes:
    lda #1
    rts
    !no:
    lda #0
    rts
}

// Known powered data equipment dims again as soon as its cell is removed.
equipment_live_color:
{
    lda render_tile
    cmp #TILE_PANEL
    beq !done+
    ldx #DEV_COUNT-1
    !device:
    lda dev_room, x
    cmp view_room
    bne !next+
    lda dev_index, x
    cmp render_index
    bne !next+
    lda dev_power, x
    beq !done+
    and powered_mask
    bne !done+
    lda #11
    sta render_color
    rts
    !next:
    dex
    bpl !device-
    !done:
    rts
}
