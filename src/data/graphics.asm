// CYCLE 64 - Tile, frame and extended glyph bitmaps used by the runtime character set.

// Four 8x8 characters per 16x16 logical tile, TL/TR/BL/BR.
// Loaded to characters 64-127. Shapes follow _docs/cycle64_sample_screen_320x200.png.
tile_graphics:
// 0 Floor: 2x2 dot in the tile centre
    .byte 0, 0, 0, 0, 0, 0, 0, $01, 0, 0, 0, 0, 0, 0, 0, $80
    .byte $01, 0, 0, 0, 0, 0, 0, 0, $80, 0, 0, 0, 0, 0, 0, 0
// 1 Wall: thick frame with a cross
    .byte $ff, $ff, $c0, $c0, $c8, $c4, $c2, $c1, $ff, $ff, $03, $03, $13, $23, $43, $83
    .byte $c1, $c2, $c4, $c8, $c0, $c0, $ff, $ff, $83, $43, $23, $13, $03, $03, $ff, $ff
// 2 Socket: frame with an inner box and a tick
    .byte $00, $7f, $40, $40, $4f, $48, $48, $48, $00, $fe, $02, $02, $f2, $1a, $12, $32
    .byte $4a, $49, $48, $4f, $40, $40, $7f, $00, $32, $52, $92, $f2, $02, $02, $fe, $00
// 3 Exit: open passage with a two-way arrow
    .byte $ff, $ff, 0, 0, 0, $08, $10, $3f, $ff, $ff, 0, 0, 0, $10, $08, $fc
    .byte $3f, $10, $08, 0, 0, 0, $ff, $ff, $fc, $08, $10, 0, 0, 0, $ff, $ff
// 4 Terminal: console with screen and keyboard line
    .byte $00, $00, $3f, $20, $2f, $28, $28, $28, $00, $00, $fc, $04, $f4, $14, $54, $14
    .byte $2f, $20, $20, $27, $20, $3f, $00, $00, $f4, $04, $04, $e4, $04, $fc, $00, $00
// 5 Gate: barred frame
    .byte $ff, $ff, $d9, $d9, $d9, $d9, $d9, $d9, $ff, $ff, $9b, $9b, $9b, $9b, $9b, $9b
    .byte $d9, $d9, $d9, $d9, $d9, $d9, $ff, $ff, $9b, $9b, $9b, $9b, $9b, $9b, $ff, $ff
// 6 Roboport: double ring
    .byte $00, $00, $07, $18, $20, $43, $44, $44, $00, $00, $e0, $18, $04, $c2, $22, $22
    .byte $44, $44, $43, $20, $18, $07, $00, $00, $22, $22, $c2, $04, $18, $e0, $00, $00
// 7 Authorization console: frame with a keyhole
    .byte $00, $00, $3f, $20, $21, $23, $23, $21, $00, $00, $fc, $04, $84, $c4, $c4, $84
    .byte $21, $21, $23, $20, $20, $3f, $00, $00, $84, $84, $c4, $04, $04, $fc, $00, $00
// 8 Sealed panel: small framed cross
    .byte $00, $00, $3f, $30, $2f, $2c, $2a, $29, $00, $00, $fc, $0c, $f4, $34, $54, $94
    .byte $29, $2a, $2c, $2f, $30, $3f, $00, $00, $94, $54, $34, $f4, $0c, $fc, $00, $00
// 9 Robot: the first robot design. Antenna, visor, arms and feet.
    .byte 1, 1, 7, 15, 24, 27, 27, 24, 128, 128, 224, 240, 24, 216, 216, 24
    .byte 15, 7, 31, 45, 45, 12, 12, 30, 240, 224, 248, 180, 180, 48, 48, 120
// 10 Cell: battery with three bars
    .byte $00, $7f, $31, $31, $31, $31, $31, $31, $00, $fe, $8c, $8c, $8c, $8c, $8c, $8c
    .byte $31, $31, $31, $31, $31, $31, $7f, $00, $8c, $8c, $8c, $8c, $8c, $8c, $fe, $00
// 11 Fog: one dim dot
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, $80, 0, 0, 0, 0, 0, 0, 0
// 12 Laser, active: a bright beam with a dotted glow
    .byte 0, 0, 0, 0, 0, $aa, 0, $ff, 0, 0, 0, 0, 0, $aa, 0, $ff
    .byte $ff, 0, $55, 0, 0, 0, 0, 0, $ff, 0, $55, 0, 0, 0, 0, 0
// 13 Robot carrying a cell: the first robot with a solid body block.
    .byte 1, 1, 7, 15, 24, 27, 27, 24, 128, 128, 224, 240, 24, 216, 216, 24
    .byte 15, 7, 31, 47, 47, 12, 12, 30, 240, 224, 248, 244, 244, 48, 48, 120
// 14 Laser, idle: a dotted line
    .byte 0, 0, 0, 0, 0, 0, 0, $11, 0, 0, 0, 0, 0, 0, 0, $11
    .byte $44, 0, 0, 0, 0, 0, 0, 0, $44, 0, 0, 0, 0, 0, 0, 0
// 15 Control chip: body, die and pins
    .byte 0, 0, $0a, $3f, $30, $37, $37, $30, 0, 0, $50, $fc, $0c, $ec, $ec, $0c
    .byte $37, $37, $30, $3f, $0a, 0, 0, 0, $ec, $ec, $0c, $fc, $50, 0, 0, 0

// Characters 192 and 193: one-pixel horizontal and vertical rules.
line_graphics:
    .byte 0, 0, 0, $ff, 0, 0, 0, 0
    .byte $10, $10, $10, $10, $10, $10, $10, $10
// Characters 194-201: terminal casing. Rounded outer corners, a black groove
// and a thin lip next to the glass. Order: TL, top, TR, left, right, BL, bottom, BR.
    .byte $1f, $7f, $7f, $ff, $ff, $ff, $fc, $fd
    .byte $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff
    .byte $f8, $fe, $fe, $ff, $ff, $ff, $3f, $bf
    .byte $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd
    .byte $bf, $bf, $bf, $bf, $bf, $bf, $bf, $bf
    .byte $fd, $fc, $ff, $ff, $ff, $7f, $7f, $1f
    .byte $ff, $00, $ff, $ff, $ff, $ff, $ff, $ff
    .byte $bf, $3f, $ff, $ff, $ff, $fe, $fe, $f8
// Characters 202-205: rounded glass corners. Order: TL, TR, BL, BR.
    .byte $e0, $c0, $80, 0, 0, 0, 0, 0
    .byte $07, $03, $01, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, $80, $c0, $e0
    .byte 0, 0, 0, 0, 0, $01, $03, $07
// Character 206: power LED. The black cell around it reads as a recess.
    .byte 0, 0, $18, $3c, $3c, $18, 0, 0
line_graphics_end:

// Tiles 16-23 in characters 208-239, same TL/TR/BL/BR order.
tile_graphics2:
// 16 Storage rack: frame and shelves with boxes
    .byte $ff, $80, $9c, $9c, $80, $ff, $80, $80, $ff, $01, $01, $39, $39, $ff, $01, $01
    .byte $8e, $8e, $ff, $80, $80, $80, $80, $ff, $01, $01, $ff, $01, $71, $71, $01, $ff
// 17 Programmer: console with a screen and an empty chip socket
    .byte 0, $7f, $40, $5f, $51, $51, $5f, $40, 0, $fe, $02, $fa, $8a, $8a, $fa, $02
    .byte $40, $47, $44, $44, $47, $40, $7f, 0, $02, $e2, $22, $22, $e2, $02, $fe, 0
// 18 Reactor control module: two rings and a core
    .byte $07, $18, $20, $47, $48, $90, $91, $93, $e0, $18, $04, $e2, $12, $09, $89, $c9
    .byte $93, $91, $90, $48, $47, $20, $18, $07, $c9, $89, $09, $12, $e2, $04, $18, $e0
// 19 Uplink: mast with signal arcs
    .byte $00, $40, $90, $a4, $a9, $a9, $a5, $91, $00, $02, $09, $25, $95, $95, $a5, $89
    .byte $81, $01, $01, $01, $03, $07, $0f, $00, $80, $80, $80, $80, $c0, $e0, $f0, $00
// 20 Service hatch: grate in a heavy frame
    .byte $ff, $ff, $c0, $d5, $c0, $d5, $c0, $d5, $ff, $ff, $03, $57, $03, $57, $03, $57
    .byte $c0, $d5, $c0, $d5, $c0, $c0, $ff, $ff, $03, $57, $03, $57, $03, $03, $ff, $ff
// 21 Sealed door: hazard stripes
    .byte $ff, $ff, $87, $0f, $1e, $3c, $78, $f0, $ff, $ff, $87, $0f, $1e, $3c, $78, $f0
    .byte $e1, $c3, $87, $0f, $1e, $3c, $ff, $ff, $e1, $c3, $87, $0f, $1e, $3c, $ff, $ff
// 22 Stasis pod: capsule
    .byte $03, $0c, $10, $27, $28, $28, $28, $28, $c0, $30, $08, $e4, $14, $14, $14, $14
    .byte $28, $28, $28, $27, $10, $0c, $03, $00, $14, $14, $14, $e4, $08, $30, $c0, $00
// 23 Firmware library: cartridge with a label
    .byte $00, $7f, $41, $5d, $5d, $41, $7f, $40, $00, $fe, $82, $ba, $ba, $82, $fe, $02
    .byte $4f, $48, $4f, $40, $7f, $12, $12, $00, $f2, $12, $f2, $02, $fe, $48, $48, $00
tile_graphics2_end:
.assert "Eight story tiles", tile_graphics2_end-tile_graphics2, 256
// 24 Exit in a north or south wall: tile 3 turned, walls left and right and
// an up-down arrow. Characters 240-243. render_map draws it for exits in
// map rows 0 and 9.
tile_exit_v:
    .byte $c0, $c0, $c1, $c3, $c5, $c1, $c1, $c1, $03, $03, $83, $c3, $a3, $83, $83, $83
    .byte $c1, $c1, $c1, $c5, $c3, $c1, $c0, $c0, $83, $83, $83, $a3, $c3, $83, $03, $03
// 25 Vertical laser, active. Characters 244-247.
    .byte $05, $01, $01, $05, $01, $01, $05, $01, $a0, $80, $80, $a0, $80, $80, $a0, $80
    .byte $01, $05, $01, $01, $05, $01, $01, $05, $80, $a0, $80, $80, $a0, $80, $80, $a0
// 26 Vertical laser, idle. Characters 248-251.
    .byte $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00, $80, $00, $00, $00, $80
    .byte $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00, $80, $00, $00, $00, $80
// 27 Cell seated in a socket: battery body above a separate docking base.
    .byte $00, $07, $1f, $10, $15, $15, $15, $15, $00, $e0, $f8, $08, $a8, $a8, $a8, $a8
    .byte $15, $10, $1f, $00, $7f, $40, $7f, $00, $a8, $08, $f8, $00, $fe, $02, $fe, $00
.assert "Four extended tile glyphs", *-tile_exit_v, 128
