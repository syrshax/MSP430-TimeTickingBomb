;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; M�dulo: msp430ports.asm
; Fecha: 23 oct. 2018
; Author: ayboc
;-------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430.h"       ; Include device header file
            .cdecls C,LIST,"msp430ports.h"  ; Include device header file
            
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

			.global TabPuertos, TabBits

TabPuertos	.short	PJIN
			.short	P1IN
			.short	P2IN
			.short	P3IN
			.short	P4IN
			.short	P5IN
			.short	P6IN
			.short	P7IN
			.short	P8IN
			.short	P9IN
			.short	P10IN

TabBits		.byte	BIT0
			.byte	BIT1
			.byte	BIT2
			.byte	BIT3
			.byte	BIT4
			.byte	BIT5
			.byte	BIT6
			.byte	BIT7
