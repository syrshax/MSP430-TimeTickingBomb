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

			.global	ledIni1, ledIni2, swIni1, swIni2, ledSet1, ledSet2, swGet1, swGet2

LED1		.equ	BIT0					; led1 en el bit 0.
LED2		.equ	BIT7					; led2 en el bit 7.
SW1			.equ	BIT1					; sw1 en el bit 1.
SW2			.equ	BIT2					; sw2 en el bit 2.

;-------------------------------------------------------------------------------
; ledIni1
;
; Inicializa el puerto P1.0 como salida con el led1 apagado.
;-------------------------------------------------------------------------------
ledIni1		bic.b	#LED1,&P1OUT			; Led apagado en P1.0.
			bis.b	#LED1,&P1DIR			; P1.0 como salida.
			ret

;-------------------------------------------------------------------------------
; ledIni2
;
; Inicializa el puerto P9.7 como salida con el led2 apagado.
;-------------------------------------------------------------------------------
ledIni2		bic.b	#LED2,&P9OUT			; Led apagado en P9.7.
			bis.b	#LED2,&P9DIR			; P9.7 como salida.
			ret

;-------------------------------------------------------------------------------
; swIni1
;
; Inicializa el puerto P1.1 como entrada con resistencia de pullup para el pulsador sw1.
;-------------------------------------------------------------------------------
swIni1		bis.b	#SW1,&P1OUT				; Resistencia pullup en P1.1.
			bis.b	#SW1,&P1REN				; Resistencia habilitada en P1.1.
			bic.b	#SW1,&P1DIR				; P1.1 como entrada.
			bis.b	#SW1,&P1IES				; P1.1 sensible en flanco de bajada.
			bic.b	#SW1,&P1IFG				; Borrar posible evento en P1.1.
			ret

;-------------------------------------------------------------------------------
; swIni2
;
; Inicializa el puerto P1.1 como entrada con resistencia de pullup para el pulsador sw1.
;-------------------------------------------------------------------------------
swIni2		bis.b	#SW2,&P1OUT				; Resistencia pullup en P1.2.
			bis.b	#SW2,&P1REN				; Resistencia habilitada en P1.2.
			bic.b	#SW2,&P1DIR				; P1.2 como entrada.
			bis.b	#SW2,&P1IES				; P1.2 sensible en flanco de bajada.
			bic.b	#SW2,&P1IFG				; Borrar posible evento en P1.2.
			ret

;-------------------------------------------------------------------------------
; ledSet1
;
; Establece el estado del led1. Aapagado (si estado = 0) o encendido en caso contrario.
;-------------------------------------------------------------------------------
ledSet1		tst.b	r12						; Estado es 0?
			jz		Clearled1				; ... s�, apagar led.
			bis.b	#LED1,&P1OUT			; ... no, encender led.
			jmp		ledSet1Fin

Clearled1	bic.b	#LED1,&P1OUT			; Apagar led.
ledSet1Fin	ret

;-------------------------------------------------------------------------------
; ledSet2
;
; Establece el estado del led2. Aapagado (si estado = 0) o encendido en caso contrario.
;-------------------------------------------------------------------------------
ledSet2		tst.b	r12						; Estado es 0?
			jz		Clearled2				; ... s�, apagar led.
			bis.b	#LED2,&P9OUT			; ... no, encender led.
			jmp		ledSet2Fin

Clearled2	bic.b	#LED2,&P9OUT			; Apagar led.
ledSet2Fin	ret

;-------------------------------------------------------------------------------
; swGet1
;
; Lee el estado del pulsador sw1. Devuelve 0 si el pulsador NO est� pulsado o un n�mero distinto de 0 en caso contrario.
;-------------------------------------------------------------------------------
swGet1		bit.b	#SW1,&P1IFG				; SW1 pulsado?
			jz		Clearsw1				; ... no, devuelve 0.
			bic.b	#SW1,&P1IFG				; ... s�, borrar evento en P1.1.
			mov.w	#1,r12					; Devuelve distinto de 0.
			jmp		swGet1Fin

Clearsw1	clr		r12						; Devuelve 0.
swGet1Fin	ret

;-------------------------------------------------------------------------------
; swGet2
;
; Lee el estado del pulsador sw2. Devuelve 0 si el pulsador NO est� pulsado o un n�mero distinto de 0 en caso contrario.
;-------------------------------------------------------------------------------
swGet2		bit.b	#SW2,&P1IFG				; SW2 pulsado?
			jz		Clearsw2				; ... no, devuelve 0.
			bic.b	#SW2,&P1IFG				; ... s�, borrar evento en P1.2.
			mov.w	#1,r12					; Devuelve distinto de 0.
			jmp		swGet2Fin

Clearsw2	clr		r12						; Devuelve 0.
swGet2Fin	ret
