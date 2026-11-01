// CYCLE 64 - Independent power selection for the main archive and its sealed vault.

// A=Archive tile index. Main floor and the expanded x>=5,y<=4 vault
// have independent power. Preserve X/Y for discovery and map drawing.
// Input: A = archive tile index 0..119. Returns: A = matching live power bit (Z = unpowered).
// Preserves X/Y; clobbers flags. No scratch bytes are used.
archive_region_power:
{
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
    and #%10000000
    rts
    !main:
    lda powered_mask
    and #%00100000
    rts
}
