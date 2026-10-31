// A=Archive tile index. Main floor and the expanded x>=5,y<=4 vault
// have independent power. Preserve X/Y for discovery and map drawing.
archive_region_power:
    cmp #60
    bcs !main+
!col:
    cmp #12
    bcc !vault+
    sbc #12
    bcs !col-
!vault:
    cmp #5
    bcc !main+
    lda powered_mask
    and #128
    rts
!main:
    lda powered_mask
    and #32
    rts
