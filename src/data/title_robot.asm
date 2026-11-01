// CYCLE 64 - Title robot sprite bytes at the fixed VIC-bank sprite addresses.

// Title robot: the first in-game robot drawn at sprite size (24x21, expanded
// to 48x42 on screen). Black silhouette sprite at $bf40, yellow robot at $bf80.
// The silhouette is the yellow shape grown by one pixel, filled across each row.
* = $bf40 "Title outline sprite"
    .byte $00, $3c, $00
    .byte $00, $3c, $00
    .byte $01, $ff, $80
    .byte $07, $ff, $e0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte $3f, $ff, $fc
    .byte $3f, $ff, $fc
    .byte $3f, $ff, $fc
    .byte $3f, $ff, $fc
    .byte $3f, $ff, $fc
    .byte $07, $ff, $e0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte $0f, $ff, $f0
    .byte 0
* = $bf80 "Title yellow sprite"
    .byte $00, $00, $00
    .byte $00, $18, $00
    .byte $00, $18, $00
    .byte $00, $ff, $00
    .byte $03, $ff, $c0
    .byte $07, $00, $e0
    .byte $07, $7e, $e0
    .byte $07, $7e, $e0
    .byte $07, $7e, $e0
    .byte $07, $00, $e0
    .byte $03, $ff, $c0
    .byte $00, $ff, $00
    .byte $07, $ff, $e0
    .byte $1b, $99, $d8
    .byte $1b, $99, $d8
    .byte $1b, $99, $d8
    .byte $03, $81, $c0
    .byte $03, $81, $c0
    .byte $03, $81, $c0
    .byte $07, $e7, $e0
    .byte $00, $00, $00
    .byte 0
