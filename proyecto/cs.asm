;-----------------------------------------------------------------
; ALBERTO VERGARA
; Grupo: L5
;-----------------------------------------------------------------
;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

			.global	csIniLf

;--------------------------------------------------------------------------------
; csIniFl
;
; Configurar el reloj que necesita el m�dulo LCD para funcionar.
;--------------------------------------------------------------------------------
csIniLf		bis.b	#BIT4,&PJSEL0			; Asociar pines de LFXT al m�dulo primario.
			mov.b	#0xA5,&CSCTL0_H			; Desbloquear los registros del m�dulo CS.
			bic.b	#LFXTOFF,&CSCTL4		; Habilitar el oscilador LFXT.
Clear		bic.b	#LFXTOFFG,&CSCTL5		; Borrar el flag de fallo en el oscilador LFXT.
			bic.b	#OFIFG,&SFRIFG1			; Borrar el flag de fallo.
			bit.b	#LFXTOFFG,&CSCTL5		; Est� la oscilaci�n estable?
			jnz		Clear					; ... no, borrar de nuevo los flags.
			bic.b	#ENSTFCNT1,&CSCTL5		; ... s�, deshabilitar el contador de fallo de inicio para LFXT.
			mov.b	#0,&CSCTL0_H			; Bloquear los registros del m�dulo CS.
			ret
