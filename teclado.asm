//;-----------------------------------------------------------------
//; Alberto Vergara
//; Grupo: L5
//;-----------------------------------------------------------------
/*
 *
 *  Created on: 7 ene. 2021
 *      Author: albervf
 */
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

			.global	kbIni, kbScan, kbGetc
			.bss	Tecla,1

FACLK		.equ	32768					;frecuencia reloj TA2 en HZ
FST			.equ	80						;frecuanecia de las interrupciones en HZ
FREBOT		.equ	100						;frecuencia de los rebotes en HZ
CCR0		.equ	FACLK/FST-1				;CCR0
EsperRebot	.equ	FACLK/FREBOT-1			;CCR1

;Asignar nombres a los puertos por columnas y filas para programar m�s f�cil
L0			.equ	BIT2					;el bit 2 a la fila 0
L1			.equ	BIT7					;el bit 7 a la fila 1
L2			.equ	BIT4					;el bit 4 a la fila 2
L3			.equ	BIT5					;el bit 5 a la fila 3
C0			.equ	BIT0					;el bit 0 a la columna 0
C1			.equ	BIT3					;el bit 3 a la columna 1
C2			.equ	BIT3					;el bit 3 a la columna 2
C3			.equ	BIT2					;el bit 3 a la columna 3

;-------------------------------------------------------------------------------
;kbIni
;
;Inicializa los puertos del teclado, poniendo las se�ales de las columnas como salidas y con
;valor 0 y las de las l�neas como entradas con resistencia de pullup e interrupciones activas en
;el flanco de bajada.
;-------------------------------------------------------------------------------
kbIni
			bis.b	#C0,&P2DIR	;todos en modo salida
			bis.b	#C1,&P9DIR
			bis.b	#C2,&P4DIR
			bis.b	#C3,&P9DIR
			bic.b	#C0,&P2OUT	;un 0 en la salida
			bic.b	#C1,&P9OUT
			bic.b	#C2,&P4OUT
			bic.b	#C3,&P9OUT

			bic.b	#L0,&P3DIR	;modo entrada
			bic.b	#L1,&P4DIR
			bic.b	#L2,&P2DIR
			bic.b	#L3,&P2DIR
			bis.b	#L0,&P3OUT	;resistencia pullup
			bis.b	#L1,&P4OUT
			bis.b	#L2,&P2OUT
			bis.b	#L3,&P2OUT
			bis.b	#L0,&P3REN	;resistencia activada
			bis.b	#L1,&P4REN
			bis.b	#L2,&P2REN
			bis.b	#L3,&P2REN
			bis.b	#L0,&P3IES	;activar flanco de bajada
			bis.b	#L1,&P4IES
			bis.b	#L2,&P2IES
			bis.b	#L3,&P2IES
			bic.b	#L0,&P3IFG	;desactivar interrupciones
			bic.b	#L1,&P4IFG
			bic.b	#L2,&P2IFG
			bic.b	#L3,&P2IFG
			bis.b	#L0,&P3IE	;activar interrupciones
			bis.b	#L1,&P4IE
			bis.b	#L2,&P2IE
			bis.b	#L3,&P2IE

			nop
			eint
			nop
			ret

;-------------------------------------------------------------------------------
;kbScan
;
;Devuelve el c�digo ASCII de la tecla pulsada. Internamente, la subrutina calcula el c�digo
;de la tecla pulsada (un n�mero entre 0 y 15) con el que direccionar� una tabla de conversi�n
;a ASCII (TabTeclas). Si no hay ninguna tecla pulsada o si se han pulsado varias a las vez,
;devuelve 0 (NUL). Antes de salir deja todas las columnas activas.
;-------------------------------------------------------------------------------
kbScan
			clr.w	r12			;valor en ASCII tecla pulsada
			clr.w	r13			;linea en la que estoy
			clr.w	r14			;columna en la que estoy
			clr.w	r15			;cantidad de teclas que he pulsado

			bic.b	#C0,&P2DIR	;todo en modo entrada para desactivar
			bic.b	#C1,&P9DIR
			bic.b	#C2,&P4DIR
			bic.b	#C3,&P9DIR
			bis.b	#C0,&P2OUT	;resistencia pullup
			bis.b	#C1,&P9OUT
			bis.b	#C2,&P4OUT
			bis.b	#C3,&P9OUT
			bis.b	#C0,&P2REN	;resistencia activada
			bis.b	#C1,&P9REN
			bis.b	#C2,&P4REN
			bis.b	#C3,&P9REN

			bic.b	#C0,&P2REN	;desactivar resistencia interna
			bis.b	#C0,&P2DIR	;columna 0 en modo salida
			bic.b	#C0,&P2OUT	;0 a la salida
			jmp		kbScanL0	;vamos a ver si hay algo pulsado en la columna





;dessactivamos primero la columna anterior para evitar fallo y con las demas igual aunque no lo ponga
kbScanLeeC0	bic.b	#C0,&P2DIR
			bis.b	#C0,&P2REN
			bis.b	#C0,&P2OUT
			bis.b	#C1,&P9DIR	;vamos a activar la columna 1, en modo salida
			bic.b	#C1,&P9OUT	;salida a 0
			bic.b	#C1,&P9REN	;deshabilitar resistencia
			inc.b	r14			;r14=1 columna
			jmp 	kbScanL0	;leer todas las lineas de la columna 1

kbScanLeeC1	bic.b	#C1,&P9DIR
			bis.b	#C1,&P9REN
			bis.b	#C1,&P9OUT
			bis.b	#C2,&P4DIR	;vamos a activar la columna 2, en modo salida
			bic.b	#C2,&P4OUT	;salida a 0
			bic.b	#C2,&P4REN	;deshabilitar resistencia
			inc.b	r14			;r14=2 columna
			jmp 	kbScanL0	;leer todas las lineas de la columna 2

kbScanLeeC2	bic.b	#C2,&P4DIR
			bis.b	#C2,&P4REN
			bis.b	#C2,&P4OUT
			bis.b	#C3,&P9DIR	;vamos a activar la columna 3, en modo salida
			bic.b	#C3,&P9OUT	;salida a 0
			bic.b	#C3,&P9REN	;deshabilitar resistencia
			inc.b	r14			;r14=3 columna
			jmp 	kbScanL0	;leer todas las lineas de la columna 3

kbScanLeeC3	bic.b	#C3,&P9DIR
			bis.b	#C3,&P9REN
			bis.b	#C3,&P9OUT
			mov.b	TabTeclas(r12),r12	;dar valor en r12
			cmp.b	#2,r15				;dos o mas teclas pulsadas?
			jc		kbScan2OMas			;...si, devuelve 0
			tst.b	r15					;hay alguna pulsada
			jnz		kbScanFinal			;...si, delvolver en ASCII
kbScan2OMas	clr.w	r12					;...no, da un 0
			jmp		kbScanFinal


kbScanL0	bit.b	#L0,&P3IN	;esta pulsada la tecla de la linea 0?
			jnz		kbScanL1	;...no, siguiente linea
			mov.b	#0,r13		;indicamos que la tecla pulsada esta en la linea 0
			jmp		kbScanLeeNu	;numero de la tecla en ASCII

kbScanL1	bit.b	#L1,&P4IN	;esta pulsada la tecla de la linea 1?
			jnz		kbScanL2	;...no, siguiente linea
			mov.b	#1,r13		;indicamos que la tecla pulsada esta en la linea 1
			jmp		kbScanLeeNu	;numero de la tecla en ASCII

kbScanL2	bit.b	#L2,&P2IN	;esta pulsada la tecla de la linea 2?
			jnz		kbScanL3	;...no, siguiente linea
			mov.b	#2,r13		;indicamos que la tecla pulsada esta en la linea 2
			jmp		kbScanLeeNu	;numero de la tecla en ASCII

kbScanL3	bit.b	#L3,&P2IN	;esta pulsada la tecla de la linea 3?
			jnz		kbScanSigCol;...no, siguiente columna
			mov.b	#3,r13		;indicamos que la tecla pulsada esta en la linea 3
			jmp		kbScanLeeNu	;numero de la tecla en ASCII

			;aqui lerremo el el numero de la tecla pulsada y veremos si en las siguientes filas se pulsa alguna tecla
kbScanLeeNu	mov.b	r13,r12		;llamamos a r13 por el numero de la linea que estoy
			rla.b	r12
			rla.b	r12
			add.b	r14,r12		;sumo la linea con la columna y doy el numero
			inc.b	r15			;incremento el contador de teclas pulsadas
			cmp.b	#0,r13		;la siguiente linea es la 1�?
			jz		kbScanL1	;...si, voy revisarla
			cmp.b	#1,r13		;...no, la siguiente linea es la 2�?
			jz		kbScanL2	;...si, voy a revisarla
			cmp.b 	#2,r13		;...no, la siguiente linea es la 3�?
			jz		kbScanL3	;terminar

kbScanSigCol cmp.b	#0,r14		;la C1 es la siguiente?
			 jz		kbScanLeeC0	;...si, vamos a comprobarla
			 cmp.b	#1,r14		; ... no, la C2 es la siguiente?
			 jz		kbScanLeeC1	; ... s�, vamos a comprobarla
			 cmp.b	#2,r14		; ... no, la C3 es la siguiente?
			 jz		kbScanLeeC2	; ... s�, vamos comprobrarla
			 jmp	kbScanLeeC3	; ... no, terminamos

kbScanFinal	bis.b	#C0,&P2DIR	;en modo salida
			bis.b	#C1,&P9DIR	;en modo salida
			bis.b	#C2,&P4DIR	;en modo salida
			bis.b	#C3,&P9DIR	;en modo salida
			bic.b	#C0,&P2OUT	;0 a la salida
			bic.b	#C1,&P9OUT	;0 a la salida
			bic.b	#C2,&P4OUT	;0 a la salida
			bic.b	#C3,&P9OUT	;0 a la salida
			ret

;-------------------------------------------------------------------------------
; TabTeclas
;
; Tabla de conversi�n de la tecla pulsada a c�digo ASCII.
;-------------------------------------------------------------------------------
TabTeclas	.byte	"1"						; Tecla 0
			.byte	"2"						; Tecla 1
			.byte	"3"						; Tecla 2
			.byte	"C"						; Tecla 3
			.byte	"4"						; Tecla 4
			.byte	"5"						; Tecla 5
			.byte	"6"						; Tecla 6
			.byte	"D"						; Tecla 7 (era D)
			.byte	"7"						; Tecla	8
			.byte	"8"						; Tecla 9
			.byte	"9"						; Tecla 10
			.byte	"E"						; Tecla 11
			.byte	"A"						; Tecla 12
			.byte	"0"						; Tecla 13
			.byte	"B"						; Tecla 14
			.byte	"F"						; Tecla 15 (era F)

;-------------------------------------------------------------------------------
;kbGetc
;
;Devuelve la tecla almacenada en el buffer de teclado (variable interna Tecla) y
;vac�a dicho buffer escribiendo NUL en el mismo
;-------------------------------------------------------------------------------
kbGetc		mov.b	&Tecla,r12 ;tecla almacenada
			clr.w	&Tecla	   ;vacia el buffer
			ret

;--------------------------------------------------------------------------------
; kbISR
;
; Subrutina de servicio de interrupci�n de l�nea
;--------------------------------------------------------------------------------
kbISR		bic.b	#L0,&P3IFG	;borrar posibles flags
			bic.b	#L1,&P4IFG
			bic.b	#L2,&P2IFG
			bic.b	#L3,&P2IFG
			bic.b	#L0,&P3IE	;deshabilitar interrupciones
			bic.b	#L1,&P4IE
			bic.b	#L2,&P2IE
			bic.b	#L3,&P2IE

			push.w	r4

			mov.w	#EsperRebot,r4					;r4 = Tiempo de rebote (en tics de TA2).
			mov.w	#CAP|CM_1|CCIS_2,&TA2CCTL1		;modo captura, flanco de subida y entrada 0.
			mov.w	#CAP|CM_1|CCIS_3,&TA2CCTL1		;modo captura, flanco de subida y entrada 1.
			add.w	&TA2CCR1,r4						;r4 = Tiempo de rebote + Instante de lectura.
			cmp.w	#CCR0+1,r4						;se ha desbordado el tiempo?
			jnc		kbISRSeg						;...no,seguir.
			sub.w	#CCR0+1,r4						;...si. Mantener por debajo de CCR0.
kbISRSeg	mov.w	r4,&TA2CCR1						;programar tiempo de rebote.
			mov.w	#CCIE,&TA2CCTL1					;modo comparaci�n, habilitar la interrupci�n de comparaci�n y borrar posible evento pendiente.

			pop.w	r4
			reti

;--------------------------------------------------------------------------------
; kbRebote
;
; Subrutina de servicio de interrupci�n secundaria del TimerA2 (CCR1).
;--------------------------------------------------------------------------------
kbRebote	bic.b	#CCIFG|CCIE,&TA2CCTL1	; Borrar posible evento pendiente y deshabilitar la interrupci�n.

			push.w	r11
			push.w	r12
			push.w	r13
			push.w	r14
			push.w	r15

			call	#kbScan					;hacer un barrido del teclado.
			tst.b	r12
			jz		NoTecla
			mov.b	r12,&Tecla				;guardar el valor devuelto en la variable Tecla.

NoTecla		bic.b	#L0,&P3IFG				;borrar posible evento
			bic.b	#L1,&P4IFG				;borrar posible evento
			bic.b	#L2,&P2IFG				;borrar posible evento
			bic.b	#L3,&P2IFG			    ;borrar posible evento

			bis.b	#L0,&P3IE				;interrupci�n habilitada
			bis.b	#L1,&P4IE				;interrupci�n habilitada
			bis.b	#L2,&P2IE			    ;interrupci�n habilitada
			bis.b	#L3,&P2IE				;interrupci�n habilitada

			pop.w	r15
			pop.w	r14
			pop.w	r13
			pop.w	r12
			pop.w	r11
			reti


;-------------------------------------------------------------------------------
; Vectores de interrupci�n.
;-------------------------------------------------------------------------------
			.sect	TIMER2_A1_VECTOR
			.short	kbRebote
			.sect	PORT2_VECTOR
			.short	kbISR
			.sect	PORT3_VECTOR
			.short	kbISR
			.sect	PORT4_VECTOR
			.short	kbISR
			.end






