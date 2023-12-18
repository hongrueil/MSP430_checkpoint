	.include data_model.h
	.cdecls C, LIST, "msp430.h"

	.cdecls C, LIST
	%{
		#include <stdint.h>
	%}
; Can access from linker file
	.global __bss__
    .global __bssEnd__
    .global __data__
    .global __dataEnd__
    .global __stack__
    .global __stackEnd__
; from checkpoint.h
	.global reg_checkpoint
	.global pc_ckt
	.global sram_checkpoint
; .c can use those function through void checkpoint_asm.......
	.def checkpoint_asm
	.def restore_asm
	.def shutdown_asm

PUSH_SECTION_START_END .macro
    push_x  #__stack__
    push_x  #__stackEnd__
    push_x  #__data__
    push_x  #__dataEnd__
    push_x  #__bss__
    push_x  #__bssEnd__
    .endm


DST     .set r10
SRC     .set r9
LEN     .set r8
SECT    .set r5

	.text
	.align 2

checkpoint_asm: .asmfunc
	pushm_x #12, r15

	mov_x r1, reg_checkpoint+4
	mov_x r2, reg_checkpoint+8
	mov_x r3, reg_checkpoint+12
	mov_x r4, reg_checkpoint+16
	mov_x r5, reg_checkpoint+20
	mov_x r6, reg_checkpoint+24
	mov_x r7, reg_checkpoint+28
	mov_x r8, reg_checkpoint+32
	mov_x r9, reg_checkpoint+36
	mov_x r10, reg_checkpoint+40
	mov_x r11, reg_checkpoint+44
	mov_x r12, reg_checkpoint+48
	mov_x r13, reg_checkpoint+52
	mov_x r14, reg_checkpoint+56
	mov_x r15, reg_checkpoint+60

	mov_x #sram_checkpoint,   DST
	PUSH_SECTION_START_END
	mov	   #3,		SECT

BACKUP_SRAM						; will be called 3 times, bss -> data -> stack
    pop_x   LEN
    pop_x   SRC
    sub    SRC,        LEN     ; Length = __xxxEnd__ - __xxx__
WAIT
	movx.b  @SRC+,      0(DST)  ; Write 1st word
    inc     DST                 ; Point to next words
    dec     LEN
    jnz     WAIT                ; Loop while Length > 0
    dec     SECT
    jnz     BACKUP_SRAM         ; Loop while Section > 0

	mov_x pc, &pc_ckt
    popm_x #12, r15
	ret_x
	.endasmfunc
	.align 2


restore_asm: .asmfunc

	pushm_x #12, r15

	mov_x  #sram_checkpoint,   SRC
	PUSH_SECTION_START_END
	mov     #3,     SECT
RESTORE_SRAM
    pop_x   LEN
    pop_x   DST
    sub     DST,    LEN         ; Length = __xxxEnd__ - __xxx__
    rra.w   LEN                 ; Length /= 2
L1
	movx.w  @SRC+,  0(DST)      ; *DST = *(SRC++), word by word
    incd    DST                 ; Point to next words
    dec     LEN
    jnz     L1                  ; Loop while Length > 0

    dec     SECT
    jnz     RESTORE_SRAM        ; Loop while Section > 0


	mov_x reg_checkpoint+4, r1
	nop
	movx.w reg_checkpoint+8, r2
	nop
	mov_x reg_checkpoint+12, r3
	mov_x reg_checkpoint+16, r4
	mov_x reg_checkpoint+20, r5
	mov_x reg_checkpoint+24, r6
	mov_x reg_checkpoint+28, r7
	mov_x reg_checkpoint+32, r8
	mov_x reg_checkpoint+36, r9
	mov_x reg_checkpoint+40, r10
	mov_x reg_checkpoint+44, r11
	mov_x reg_checkpoint+48, r12
	mov_x reg_checkpoint+52, r13
	mov_x reg_checkpoint+56, r14
	mov_x reg_checkpoint+60, r15

	mov_x &pc_ckt, pc
	ret_x
	.endasmfunc

	.align 2



shutdown_asm: .asmfunc
	;bic #GIE, sr
	dint
	nop
	mov.b #PMMPW_H, &PMMCTL0_H
	bis.b #PMMREGOFF, &PMMCTL0_L
	bic.b #SVSHE, &PMMCTL0_L
	mov.b #000h, &PMMCTL0_H
	bis #CPUOFF+OSCOFF+SCG0+SCG1, sr
	nop

	ret_x
	.endasmfunc

	.end





