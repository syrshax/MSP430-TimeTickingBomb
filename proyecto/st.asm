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

			.global	stIni, stTime, stReset

			.bss	SystemTimer, 4			; Asignar 4 bytes en .bss para SystemTimer

;-------------------------------------------------------------------------------
; stIni
;
; Inicializa el SystemTimer.
; Entrada: R12 Entero con el valor del periodo.
;-------------------------------------------------------------------------------
stIni		mov.w	r12,&TA2CCR0							; Configurar el tiempo.
			mov.w	#CCIE,&TA2CCTL0							; Habilitar la interrupci�n de comparaci�n.
			mov.w	#TASSEL__ACLK|MC__UP|TACLR,&TA2CTL		; Fuente de reloj de TA2 ACLK a 32 kHz, modo up y resetear.
			nop
			eint											; Habilitar interrupciones.
			nop
			ret

;-------------------------------------------------------------------------------
; stReset
;
; Reinicia el SystemTimer.
;------------------------------------------------------------------------------
stReset clr.w	&SystemTimer
		clr.w	&SystemTimer+2
		ret


;-------------------------------------------------------------------------------
; stTime
;
; Realiza la lectura del tiempo. Devuelve el valor actual de la variable SystemTimer.
;-------------------------------------------------------------------------------
stTime		nop
			dint							; Deshabilitar interrupciones.
			nop
			mov.w	&SystemTimer,r12		; Mover la parte baja de la variable SystemTimer a R12.
			mov.w	&SystemTimer+2,r13		; Mover la parte alta de la variable SystemTimer a R13.
			nop
			eint							; Habilitar interrupciones.
			nop
			ret

;-------------------------------------------------------------------------------
; stA2ISR
;
; Subrutina de servicio de interrupci�n. Incrementa la variable SystemTimer.
;-------------------------------------------------------------------------------
stA2ISR		add.w	#1,&SystemTimer			; Sumar 1 a la parte baja de la variable SystemTimer para incrementarla.
			addc.w	#0,&SystemTimer+2		; Sumar el posible acarreo a la parte alta de la variable SystemTimer.
			reti

;-------------------------------------------------------------------------------
; Vector de interrupci�n.
;-------------------------------------------------------------------------------
			.sect	TIMER2_A0_VECTOR
			.short	stA2ISR
			.end

