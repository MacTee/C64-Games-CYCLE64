// CYCLE 64 - Rendering macros for text pointers, positioned text and message buffers.

// Print the zero-terminated label at row/col in color.
// Clobbers: A/Y, flags, text_ptr, screen_ptr/color_ptr and text_color; X = row.
.macro TextAt(row, col, label, color)
{
    lda #<label
    sta text_ptr
    lda #>label
    sta text_ptr+1
    ldx #row
    ldy #col
    lda #color
    jsr print_at
}

// Print label and pad to end (exclusive); otherwise the TextAt contract applies.
// Also writes field_end/field_col/field_width.
.macro FieldAt(row, col, label, color, end)
{
    lda #end
    sta field_end
    lda #<label
    sta text_ptr
    lda #>label
    sta text_ptr+1
    ldx #row
    ldy #col
    lda #color
    jsr print_field
}

// Load text_ptr from label. Clobbers: A and N/Z; preserves X/Y and carry.
.macro Ptr(label)
{
    lda #<label
    sta text_ptr
    lda #>label
    sta text_ptr+1
}

// Append label to msg_buf. Clobbers: A/X/Y, flags, text_ptr, buf_pos/msg_buf.
.macro Append(label)
{
    lda #<label
    sta text_ptr
    lda #>label
    sta text_ptr+1
    jsr buf_text
}
