.macro TextAt(row,col,label,color) {
    lda #<label
    sta text_ptr
    lda #>label
    sta text_ptr+1
    ldx #row
    ldy #col
    lda #color
    jsr print_at
}
.macro FieldAt(row,col,label,color,end) {
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
.macro Ptr(label) {
    lda #<label
    sta text_ptr
    lda #>label
    sta text_ptr+1
}
.macro Append(label) {
    lda #<label
    sta text_ptr
    lda #>label
    sta text_ptr+1
    jsr buf_text
}
