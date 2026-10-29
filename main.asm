%macro print_text 2
    mov ecx, %1
    mov edx, %2
    call print_proc
%endmacro

section .data
    prompt_msg   db "Enter number of units: "
    prompt_len   equ $ - prompt_msg

    cor_header   db 10, "========================================", 10
                 db "    CERTIFICATE OF REGISTRATION (COR)   ", 10
                 db "========================================", 10
    header_len   equ $ - cor_header

    unit_msg     db "Units Enrolled : "
    unit_len     equ $ - unit_msg

    rate_msg     db "Rate per Unit  : PHP 5,000.00", 10
    rate_len     equ $ - rate_msg

    total_msg    db "Total Tuition  : PHP "
    total_len    equ $ - total_msg

    newline      db 10
    newline_len  equ $ - newline

section .bss
    input_buffer resb 10
    units_val    resd 1
    total_val    resd 1
    out_buf      resb 16

section .text
    global _start

_start:
    print_text prompt_msg, prompt_len

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 10
    int 0x80

    mov esi, input_buffer
    xor eax, eax
.parse:
    movzx ecx, byte [esi]
    cmp ecx, '0'
    jl .done_parse
    cmp ecx, '9'
    jg .done_parse
    sub ecx, '0'
    imul eax, eax, 10
    add eax, ecx
    inc esi
    jmp .parse
.done_parse:
    mov [units_val], eax

    mov edx, 1000
    mul edx
    mov [total_val], eax

    mov edi, out_buf + 15
    mov byte [edi], 0
    mov ecx, 10
    xor esi, esi
.convert:
    xor edx, edx
    div ecx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc esi

    test eax, eax
    jz .done_conv
    
    mov edx, esi
    cmp edx, 3
    jne .convert
    dec edi
    mov byte [edi], ','
    xor esi, esi
    jmp .convert

.done_conv:
    mov ebx, edi

    print_text cor_header, header_len
    
    print_text unit_msg, unit_len
    mov ecx, input_buffer
.len_loop:
    mov al, [ecx]
    cmp al, 10
    je .len_done
    cmp al, 13
    je .len_done
    test al, al
    je .len_done
    inc ecx
    jmp .len_loop
.len_done:
    sub ecx, input_buffer
    mov edx, ecx
    mov ecx, input_buffer
    call print_proc
    print_text newline, newline_len

    print_text rate_msg, rate_len

    print_text total_msg, total_len
    mov edx, out_buf + 15
    sub edx, ebx
    mov ecx, ebx
    call print_proc
    print_text newline, newline_len

    mov eax, 1
    xor ebx, ebx
    int 0x80

print_proc:
    push ebx
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop ebx
    ret