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

			.global	lcdIni, lcda2seg, lcdLPutc, lcdRPutc, lcdClearAll, lcdClear, lcdClearNum, lcdBat, lcdPtos, lcdHor, lcdMin, lcdSeg, lcdCora, lcdCoraOff,lcdPtosOn

A1_L		.equ	LCDM10					; Byte bajo del d�gito 1.
A1_H		.equ	LCDM11					; Byte alto del d�gito 1.
A2_L		.equ	LCDM6					; Byte bajo del d�gito 2.
A2_H		.equ	LCDM7					; Byte alto del d�gito 2.
A3_L		.equ	LCDM4					; Byte bajo del d�gito 3.
A3_H		.equ	LCDM5					; Byte alto del d�gito 3.
A4_L		.equ	LCDM19					; Byte bajo del d�gito 4.
A4_H		.equ	LCDM20					; Byte alto del d�gito 4.
A5_L		.equ	LCDM15					; Byte bajo del d�gito 5.
A5_H		.equ	LCDM16					; Byte alto del d�gito 5.
A6_L		.equ	LCDM8					; Byte bajo del d�gito 6.
A6_H		.equ	LCDM9					; Byte alto del d�gito 6.

BAT_A		.equ	LCDM18					; Byte A de la bater�a (B5 B3 B1 BATT - - - -).
BAT_B		.equ	LCDM14					; Byte B de la bater�a (B6 B4 B2 [  ] - - - -).

;-------------------------------------------------------------------------------
; lcdIni
;
; Inicializa la pantalla para que pueda ser usada.
;-------------------------------------------------------------------------------
lcdIni		mov.w	#LCDDIV__32|LCD4MUX|LCDLP,&LCDCCTL0		; Frecuencia de trabajo del LCD de 1 kHz usando divisor de 32 kHz, modo de funcionamiento 4 mux y bajo consumo.
			mov.w	#VLCD_2_60|LCDREXT|LCDCPEN,&LCDCVCTL	; Tensi�n de la bomba de carga de 2'6 V, tensiones V2 a V4 generadas internamente disponibles externamente y habilitaci�n de la bomba de carga.
			bis.w	#LCDCPCLKSYNC,&LCDCCPCTL				; Sincronizaci�n del reloj de la bomba de carga con el reloj interno de la CPU.
			bis.w	#LCDS4|LCDS6|LCDS7|LCDS8|LCDS9|LCDS10|LCDS11|LCDS12|LCDS13|LCDS14|LCDS15,&LCDCPCTL0			; Habilitar segmentos de LCD.
			bis.w 	#LCDS16|LCDS17|LCDS18|LCDS19|LCDS20|LCDS21|LCDS27|LCDS28|LCDS29|LCDS30|LCDS31,&LCDCPCTL1	; Habilitar segmentos de LCD.
			bis.w	#LCDS35|LCDS36|LCDS37|LCDS38|LCDS39,&LCDCPCTL2												; Habilitar segmentos de LCD.
			bis.w	#LCDCLRM|LCDCLRBM,&LCDCMEMCTL			; Borrar todos los registros de memoria de v�deo y parpadeo del LCD.
			bis.w	#LCDON,&LCDCCTL0						; M�dulo LCD encendido.

;-------------------------------------------------------------------------------
; lcda2seg
;
; Obtiene el c�digo de 14 segmentos de un car�cter ASCII imprimible de la entrada. Devuelve FFFF si el car�cter est� fuera de rango.
; Entradas: R12 Car�cter ASCII imprimible (c�digos 32 a 127).
; Salidas: R12 C�digo de 14 segmentos o FFFF si el car�cter est� fuera de rango.
;-------------------------------------------------------------------------------
lcda2seg	cmp.b	#128,r12				; El c�digo del car�cter es mayor que 127?
			jc		FueraRango				; ... s�, el car�cter est� fuera de rango.
			sub.b	#32,r12					; ... no, el c�digo del car�cter es menor que 32?
			jnc		FueraRango				; ... s�, el car�cter est� fuera de rango.
			rla.b	r12						; ... no, multiplicar por 2 para obtener un desplazamiento de 2 bytes por car�cter.
			mov.w	Tab14Seg(r12),r12		; Leer el c�digo del car�cter de la tabla de 14 segmentos.
			jmp		lcda2segFin
FueraRango	mov.w	#0xFFFF,r12				; Devolver FFFF por estar el car�cter fuera de rango.
lcda2segFin	ret

;-------------------------------------------------------------------------------
; lcdLPutc
;
; Desplaza el contendio de la pantalla un car�cter a la izquierda y escribe c en el d�gito de la derecha.
; Obtiene el car�cter c desde la llamada a lcda2seg. Si el car�cter est� fuera de rango, no hace nada.
;-------------------------------------------------------------------------------
lcdLPutc	call	#lcda2seg				; Obtener la representaci�n del car�cter en 14 segmentos.
			cmp.w	#0xFFFF,r12				; El car�cter est� fuera de rango?
			jz		lcdLPutcFin				; ... s�, salir de la subrutina sin realizar ning�n cambio.
			clr.w	r13						; ... no, limpiar el registro R13 para desplazar los caracteres.

			; Mover el d�gito 2 al d�gito 1.
;			mov.b 	&LCDM6,&LCDM10			; Mover el byte bajo del d�gito 2 al byte bajo del d�gito 1.
;			and.b	#BIT2|BIT0,&LCDM11		; Enmascarar el byte alto del d�gito 1 para conservar los s�mbolos.
;			mov.b	&LCDM7,r13				; Mover el byte alto del d�gito 2 a R13.
;			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 2 transferido a R13.
;			bis.b	r13,&LCDM11				; Mover el byte alto del d�gito 2 transferido a R13 al byte alto del d�gito 1.

			; Mover el d�gito 3 al d�gito 2.
;			mov.b	&LCDM4,&LCDM6			; Mover el byte bajo del d�gito 3 al byte bajo del d�gito 2.
;			and.b	#BIT2|BIT0,&LCDM7		; Enmascarar el byte alto del d�gito 2 para conservar los s�mbolos.
;			mov.b	&LCDM5,r13				; Mover el byte alto del d�gito 3 a R13.
;			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 3 transferido a R13.
;			bis.b 	r13,&LCDM7				; Mover el byte alto del d�gito 3 transferido a R13 al byte alto del d�gito 2.

			; Mover el d�gito 4 al d�gito 3.
			mov.b	&LCDM19,&LCDM4			; Mover el byte bajo del d�gito 4 al byte bajo del d�gito 3.
			and.b	#BIT2|BIT0,&LCDM5		; Enmascarar el byte alto del d�gito 3 para conservar los s�mbolos.
			mov.b	&LCDM20,r13				; Mover el byte alto del d�gito 4 a R13.
			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 4 transferido a R13.
			bis.b	r13,&LCDM5				; Mover el byte alto del d�gito 4 transferido a R13 al byte alto del d�gito 3.

			; Mover el d�gito 5 al d�gito 4.
			mov.b	&LCDM15,&LCDM19			; Mover el byte bajo del d�gito 5 al byte bajo del d�gito 4.
			and.b	#BIT2|BIT0,&LCDM20		; Enmascarar el byte alto del d�gito 4 para conservar los s�mbolos.
			mov.b	&LCDM16,r13				; Mover el byte alto del d�gito 5 a R13.
			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 5 transferido a R13.
			bis.b	r13,&LCDM20				; Mover el byte alto del d�gito 5 transferido a R13 al byte alto del d�gito 4.

			; Mover el d�gito 6 al d�gito 5.
			mov.b	&LCDM8,&LCDM15			; Mover el byte bajo del d�gito 6 al byte bajo del d�gito 5.
			and.b	#BIT2|BIT0,&LCDM16		; Enmascarar el byte alto del d�gito 5 para conservar los s�mbolos.
			mov.b	&LCDM9,r13				; Mover el byte alto del d�gito 6 a R13.
			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 6 transferido a R13.
			bis.b	r13,&LCDM16				; Mover el byte alto del d�gito 6 transferido a R13 al byte alto del d�gito 5.

			; Mover el nuevo car�cter al d�gito 6.
			mov.b	r12,&LCDM8				; Mover el byte bajo del nuevo car�cter al byte bajo del d�gito 6.
			and.b	#BIT2|BIT0,&LCDM9		; Enmascarar el byte alto del d�gito 6 para conservar los s�mbolos.
			swpb	r12						; Permutar los bytes de R12.
			bic.b	#BIT2|BIT0,r12			; Borrar los bits de s�mbolos del byte alto del nuevo car�cter, permutado con anterioridad.
			bis.b	r12,&LCDM9				; Mover el byte alto del nuevo car�cter al byte alto del d�gito 6.

lcdLPutcFin	ret

;-------------------------------------------------------------------------------
; lcdRPutc
;
; Desplaza el contendio de la pantalla un car�cter a la derecha y escribe c en el d�gito de la izquierda.
; Obtiene el car�cter c desde la llamada a lcda2seg. Si el car�cter est� fuera de rango, no hace nada.
;-------------------------------------------------------------------------------
lcdRPutc	call	#lcda2seg				; Obtener la representaci�n del car�cter en 14 segmentos.
			cmp.w	#0xFFFF,r12				; El car�cter est� fuera de rango?
			jz		lcdRPutcFin				; ... s�, salir de la subrutina sin realizar ning�n cambio.
			clr.w	r13						; ... no, limpiar el registro R13 para desplazar los caracteres.

			; Mover el d�gito 5 al d�gito 6.
			mov.b 	&A5_L,&A6_L				; Mover el byte bajo del d�gito 5 al byte bajo del d�gito 6.
			and.b	#BIT2|BIT0,&A6_H		; Enmascarar el byte alto del d�gito 6 para conservar los s�mbolos.
			mov.b	&A5_H,r13				; Mover el byte alto del d�gito 5 a R13.
			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 5 transferido a R13.
			bis.b	r13,&A6_H				; Mover el byte alto del d�gito 5 transferido a R13 al byte alto del d�gito 6.

			; Mover el d�gito 4 al d�gito 5.
			mov.b	&A4_L,&A5_L				; Mover el byte bajo del d�gito 4 al byte bajo del d�gito 5.
			and.b	#BIT2|BIT0,&A5_H		; Enmascarar el byte alto del d�gito 5 para conservar los s�mbolos.
			mov.b	&A4_H,r13				; Mover el byte alto del d�gito 4 a R13.
			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 4 transferido a R13.
			bis.b 	r13,&A5_H				; Mover el byte alto del d�gito 4 transferido a R13 al byte alto del d�gito 5.

			; Mover el d�gito 3 al d�gito 4.
			mov.b	&A3_L,&A4_L				; Mover el byte bajo del d�gito 3 al byte bajo del d�gito 4.
			and.b	#BIT2|BIT0,&A4_H		; Enmascarar el byte alto del d�gito 4 para conservar los s�mbolos.
			mov.b	&A3_H,r13				; Mover el byte alto del d�gito 3 a R13.
			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 3 transferido a R13.
			bis.b	r13,&A4_H				; Mover el byte alto del d�gito 3 transferido a R13 al byte alto del d�gito 4.

			; Mover el d�gito 2 al d�gito 3.
			mov.b	&A2_L,&A3_L				; Mover el byte bajo del d�gito 2 al byte bajo del d�gito 3.
			and.b	#BIT2|BIT0,&A3_H		; Enmascarar el byte alto del d�gito 3 para conservar los s�mbolos.
			mov.b	&A2_H,r13				; Mover el byte alto del d�gito 2 a R13.
			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 2 transferido a R13.
			bis.b	r13,&A3_H				; Mover el byte alto del d�gito 2 transferido a R13 al byte alto del d�gito 3.

			; Mover el d�gito 1 al d�gito 2.
			mov.b	&A1_L,&A2_L				; Mover el byte bajo del d�gito 1 al byte bajo del d�gito 2.
			and.b	#BIT2|BIT0,&A2_H		; Enmascarar el byte alto del d�gito 2 para conservar los s�mbolos.
			mov.b	&A1_H,r13				; Mover el byte alto del d�gito 1 a R13.
			bic.b	#BIT2|BIT0,r13			; Borrar los bits de s�mbolos del byte alto del d�gito 1 transferido a R13.
			bis.b	r13,&A2_H				; Mover el byte alto del d�gito 1 transferido a R13 al byte alto del d�gito 2.

			; Mover el nuevo car�cter al d�gito 1.
			mov.b	r12,&A1_L				; Mover el byte bajo del nuevo car�cter al byte bajo del d�gito 1.
			and.b	#BIT2|BIT0,&A1_H		; Enmascarar el byte alto del d�gito 1 para conservar los s�mbolos.
			swpb	r12						; Permutar los bytes de R12.
			bic.b	#BIT2|BIT0,r12			; Borrar los bits de s�mbolos del byte alto del nuevo car�cter, permutado con anterioridad.
			bis.b	r12,&A1_H				; Mover el byte alto del nuevo car�cter al byte alto del d�gito 1.

lcdRPutcFin	ret

;-------------------------------------------------------------------------------
; lcdClearAll
;
; Borra el contenido de la pantalla.
;-------------------------------------------------------------------------------
lcdClearAll	bis.w	#LCDCLRM|LCDCLRBM,&LCDCMEMCTL			; Borrar todos los registros de memoria de v�deo y parpadeo del LCD.
			ret

;-------------------------------------------------------------------------------
; lcdClear
;
; Borra los d�gitos de la pantalla.
;-------------------------------------------------------------------------------
lcdClear	clr.b	A1_L					; Borrar el byte bajo del d�gito 1.
			clr.b	A1_H					; Borrar el byte alto del d�gito 1.
			clr.b	A2_L					; Borrar el byte bajo del d�gito 2.
			clr.b	A2_H					; Borrar el byte alto del d�gito 2.
			clr.b	A3_L					; Borrar el byte bajo del d�gito 3.
			clr.b	A3_H					; Borrar el byte alto del d�gito 3.
			clr.b	A4_L					; Borrar el byte bajo del d�gito 4.
			clr.b	A4_H					; Borrar el byte alto del d�gito 4.
			clr.b	A5_L					; Borrar el byte bajo del d�gito 5.
			clr.b	A5_H					; Borrar el byte alto del d�gito 5.
			clr.b	A6_L					; Borrar el byte bajo del d�gito 6.
			clr.b 	A6_H					; Borrar el byte alto del d�gito 6.
			ret


;-------------------------------------------------------------------------------
; lcdBat
;
; Establece el estado de las barras del indicador de nivel de bater�a.
;-------------------------------------------------------------------------------
lcdBat		cmp.b	#0,r12					; Est� activo el segmento B1?
			jz		TurnOnB1				; ... s�, encender el segmento B1.
			cmp.b	#1,r12					; ... no, est� activo el segmento B2?
			jz		TurnOnB2				; ... s�, encender el segmento B2.
			cmp.b	#2,r12					; ... no, est� activo el segmento B3?
			jz		TurnOnB3				; ... s�, encender el segmento B3.
			cmp.b	#3,r12					; ... no, est� activo el segmento B4?
			jz		TurnOnB4				; ... s�, encender el segmento B4.
			cmp.b	#4,r12					; ... no, est� activo el segmento B5?
			jz		TurnOnB5				; ... s�, encender el segmento B5.
			cmp.b	#5,r12					; ... no, est� activo el segmento B6?
			jz		TurnOnB6				; ... s�, encender el segmento B6.
			jmp		lcdBatFin				; ... no, salir de la subrutina sin realizar ning�n cambio.

TurnOnB1	mov.b	#BIT4|BIT5,&BAT_A		; Encender el segmento B1 de la bater�a.
			mov.b 	#BIT4,&BAT_B
			jmp		lcdBatFin
TurnOnB2	mov.b	#BIT4,&BAT_A			; Encender el segmento B2 de la bater�a.
			mov.b	#BIT4|BIT5,&BAT_B
			jmp		lcdBatFin
TurnOnB3	mov.b	#BIT4|BIT6,&BAT_A		; Encender el segmento B3 de la bater�a.
			mov.b	#BIT4,&BAT_B
			jmp		lcdBatFin
TurnOnB4	mov.b	#BIT4,&BAT_A			; Encender el segmento B4 de la bater�a.
			mov.b	#BIT4|BIT6,&BAT_B
			jmp		lcdBatFin
TurnOnB5	mov.b	#BIT4|BIT7,&BAT_A		; Encender el segmento B5 de la bater�a.
			mov.b	#BIT4,&BAT_B
			jmp		lcdBatFin
TurnOnB6	mov.b	#BIT4,&BAT_A			; Encender el segmento B6 de la bater�a.
			mov.b	#BIT4|BIT7,&BAT_B

lcdBatFin	ret



;-------------------------------------------------------------------------------
; lcdHor
;
; Estado de las horas.
;-------------------------------------------------------------------------------
lcdHor		cmp.b	#0,r12					; Est� activo la hora0?
			jz		TurnOnH0				; ... s�, encender hora 0.
			cmp.b	#1,r12					; ... no, est� activa la hora 1?
			jz		TurnOnH1				; ... s�, encender la hora 1.
			cmp.b	#2,r12					; ... no, est� est� activa la hora 2?
			jz		TurnOnH2				; ... s�, encender la hora 2.
			cmp.b	#3,r12					; ... no, est� est� activa la hora 3?
			jz		TurnOnH3				; ... s�, encender la hora 3.
			cmp.b	#4,r12					; ... no, est� activa la hora 4?
			jz		TurnOnH4				; ... s�, encender la hora 4.
			cmp.b	#5,r12					; ... no, est� activa la hora5?
			jz		TurnOnH5				; ... s�, encender la hora 5.
			cmp.b	#6,r12					; ... no, est� activa la hora 6?
			jz		TurnOnH6				; ... s�,encender la hora 6.
			cmp.b	#7,r12
			jz		TurnOnH7
			cmp.b	#8,r12
			jz		TurnOnH8
			cmp.b	#9,r12
			jz		TurnOnH9
			cmp.b	#10,r12
			jz		TurnOnH10
			cmp.b	#11,r12
			jz		TurnOnH11
			cmp.b	#12,r12
			jz		TurnOnH12
			cmp.b	#13,r12
			jz		TurnOnH13
			cmp.b	#14,r12
			jz		TurnOnH14
			cmp.b	#15,r12
			jz		TurnOnH15
			cmp.b	#16,r12
			jz		TurnOnH16
			cmp.b	#17,r12
			jz		TurnOnH17
			cmp.b	#18,r12
			jz		TurnOnH18
			cmp.b	#19,r12
			jz		TurnOnH19
			cmp.b	#20,r12
			jz		TurnOnH20
			cmp.b	#21,r12
			jz		TurnOnH21
			cmp.b	#22,r12
			jz		TurnOnH22
			cmp.b	#23,r12
			jz		TurnOnH23
			jmp		lcdHorFin				; ... no, salir de la subrutina sin realizar ning�n cambio.

TurnOnH0	clr.b	&LCDM11			;primero borramos para que no haya conflicto
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10  ; poner 00h
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM6
			jmp		lcdHorFin
TurnOnH1	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10	;01h
			mov.b	#BIT6|BIT5,&LCDM6
			jmp		lcdHorFin
TurnOnH2	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10 ;poner 02h
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH3	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10	;03h
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH4	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10 ;poner 04h
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH5	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10	;05h
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH6	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10 ;poner 06h
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH7	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10	;07h
			mov.b	#BIT7|BIT6|BIT5,&LCDM6
			jmp		lcdHorFin
TurnOnH8	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10 ;poner 08h
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH9	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			;mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM10	;09h
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH10	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10 ;poner 10h
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM6
			jmp		lcdHorFin
TurnOnH11	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10	;11h
			mov.b	#BIT6|BIT5,&LCDM6
			jmp		lcdHorFin
TurnOnH12	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10 ;poner 12h
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH13	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10	;13h
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH14	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10 ;poner 14h
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH15	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10	;15h
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH16	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10;poner 16h
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH17	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10	;17h
			mov.b	#BIT7|BIT6|BIT5,&LCDM6
			jmp		lcdHorFin
TurnOnH18	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10 ;poner 18h
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH19	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT6|BIT5,&LCDM10	;19h
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH20	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM10 ;poner 20h
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM6
			jmp		lcdHorFin
TurnOnH21	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM10 ;poner 21h
			mov.b	#BIT6|BIT5,&LCDM6
			jmp		lcdHorFin
TurnOnH22	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM10 ;poner 22h
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin
TurnOnH23	clr.b	&LCDM11
			clr.b	&LCDM10
			clr.b	&LCDM7
			clr.b	&LCDM6
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM10 ;poner 23h
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM6
			jmp		lcdHorFin

lcdHorFin	ret

;-------------------------------------------------------------------------------
; lcdMin
;
; Estado de los minutos.
;-------------------------------------------------------------------------------
lcdMin
			cmp.b	#0,r12					; Est� activo el minuto 0?
			jz		TurnOnMin0				; ... s�, encender min 0.
			cmp.b	#1,r12					; ... no, est� activa el minuto 1?
			jz		TurnOnMin1				; ... s�, encender el minuto 1.
			cmp.b	#2,r12					; ... no, est� est� activa el minuto 2?
			jz		TurnOnMin2				; ... s�, encender el minuto 2.
			cmp.b	#3,r12					; ... no, est� est� activa el minuto 3?
			jz		TurnOnMin3				; ... s�, encender el minuto 3.
			cmp.b	#4,r12					; ... no, est� activa el minuto 4?
			jz		TurnOnMin4				; ... s�, encender el minuto 4.
			cmp.b	#5,r12					; ... no, est� activa el minuto5?
			jz		TurnOnMin5				; ... s�, encender el minuto 5.
			cmp.b	#6,r12					; ... no, est� activa el minuto 6?
			jz		TurnOnMin6				; ... s�,encender el minuto 6.
			cmp.b	#7,r12
			jz		TurnOnMin7
			cmp.b	#8,r12
			jz		TurnOnMin8
			cmp.b	#9,r12
			jz		TurnOnMin9
			cmp.b	#10,r12
			jz		TurnOnMin10
			cmp.b	#11,r12
			jz		TurnOnMin11
			cmp.b	#12,r12
			jz		TurnOnMin12
			cmp.b	#13,r12
			jz		TurnOnMin13
			cmp.b	#14,r12
			jz		TurnOnMin14
			cmp.b	#15,r12
			jz		TurnOnMin15
			cmp.b	#16,r12
			jz		TurnOnMin16
			cmp.b	#17,r12
			jz		TurnOnMin17
			cmp.b	#18,r12
			jz		TurnOnMin18
			cmp.b	#19,r12
			jz		TurnOnMin19
			cmp.b	#20,r12
			jz		TurnOnMin20
			cmp.b	#21,r12
			jz		TurnOnMin21
			cmp.b	#22,r12
			jz		TurnOnMin22
			cmp.b	#23,r12
			jz		TurnOnMin23
			cmp.b	#24,r12
			jz		TurnOnMin24
			cmp.b	#25,r12
			jz		TurnOnMin25
			cmp.b	#26,r12
			jz		TurnOnMin26
			cmp.b	#27,r12
			jz		TurnOnMin27
			cmp.b	#28,r12
			jz		TurnOnMin28
			cmp.b	#29,r12
			jz		TurnOnMin29
			cmp.b	#30,r12
			jz		TurnOnMin30
			cmp.b	#31,r12
			jz		TurnOnMin31
			cmp.b	#32,r12
			jz		TurnOnMin32
			cmp.b	#33,r12
			jz		TurnOnMin33
			cmp.b	#34,r12
			jz		TurnOnMin34
			cmp.b	#35,r12
			jz		TurnOnMin35
			cmp.b	#36,r12
			jz		TurnOnMin36
			cmp.b	#37,r12
			jz		TurnOnMin37
			cmp.b	#38,r12
			jz		TurnOnMin38
			cmp.b	#39,r12
			jz		TurnOnMin39
			cmp.b	#40,r12
			jz		TurnOnMin40
			cmp.b	#41,r12
			jz		TurnOnMin41
			cmp.b	#42,r12
			jz		TurnOnMin42
			cmp.b	#43,r12
			jz		TurnOnMin43
			cmp.b	#44,r12
			jz		TurnOnMin44
			cmp.b	#45,r12
			jz		TurnOnMin45
			cmp.b	#46,r12
			jz		TurnOnMin46
			cmp.b	#47,r12
			jz		TurnOnMin47
			cmp.b	#48,r12
			jz		TurnOnMin48
			cmp.b	#49,r12
			jz		TurnOnMin49
			cmp.b	#50,r12
			jz		TurnOnMin50
			cmp.b	#51,r12
			jz		TurnOnMin51
			cmp.b	#52,r12
			jz		TurnOnMin52
			cmp.b	#53,r12
			jz		TurnOnMin53
			cmp.b	#54,r12
			jz		TurnOnMin54
			cmp.b	#55,r12
			jz		TurnOnMin55
			cmp.b	#56,r12
			jz		TurnOnMin56
			cmp.b	#57,r12
			jz		TurnOnMin57
			cmp.b	#58,r12
			jz		TurnOnMin58
			cmp.b	#59,r12
			jz		TurnOnMin59
			jmp		lcdMinFin				; ... no, salir de la subrutina sin realizar ning�n cambio.

TurnOnMin0	clr.b	&LCDM20     ;primero borramos para que no haya conflicto
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4 ;poner 00min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM19
			jmp		lcdMinFin
TurnOnMin1  clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4	;01min
			mov.b	#BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin2	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4 ;poner 02min
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin3	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4	;03min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin4	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4 ;poner 04min
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin5	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4	;05min
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin6	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4 ;poner 06min
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin7	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4	;07min
			mov.b	#BIT7|BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin8	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4 ;poner 08min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin9	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM4	;09min
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin10	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4 ;poner 10min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM19
			jmp		lcdMinFin
TurnOnMin11	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4	;11min
			mov.b	#BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin12	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4 ;poner 12min
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin13	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4	;13min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin14	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4 ;poner 14min
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin15	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4	;15min
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin16	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4;poner 16min
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin17	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4	;17min
			mov.b	#BIT7|BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin18	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4 ;poner 18min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin19	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5,&LCDM4	;19min
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin20	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 20min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM19
			jmp		lcdMinFin
TurnOnMin21	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 21min
			mov.b	#BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin22	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 22min
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin23	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 23min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin24	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 24min
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin25	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 25min
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin26	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 26min
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin27	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 27min
			mov.b	#BIT7|BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin28	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 28min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin29	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM4 ;poner 29min
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin30	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 30min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM19
			jmp		lcdMinFin
TurnOnMin31	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 31min
			mov.b	#BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin32	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 32min
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin33	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 33min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin34	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 34min
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin35	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 35min
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin36	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 36min
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin37	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 37min
			mov.b	#BIT7|BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin38	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 38min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin39	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM4 ;poner 39min
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin40 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 40min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM19
			jmp		lcdMinFin
TurnOnMin41	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 41min
			mov.b	#BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin42	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 42min
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin43	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 43min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin44	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 44min
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin45	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 45min
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin46	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 46min
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin47	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 47min
			mov.b	#BIT7|BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin48	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 48min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin49	clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM4 ;poner 49min
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin50 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 40min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM19
			jmp		lcdMinFin
TurnOnMin51 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 51min
			mov.b	#BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin52 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 52min
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin53 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 53min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin54 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 54min
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin55 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 55min
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin56 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 56min
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin57 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 57min
			mov.b	#BIT7|BIT6|BIT5,&LCDM19
			jmp		lcdMinFin
TurnOnMin58 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 58min
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
TurnOnMin59 clr.b	&LCDM20
			clr.b	&LCDM19
			clr.b	&LCDM5
			clr.b	&LCDM4
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM4 ;poner 59min
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM19
			jmp		lcdMinFin
lcdMinFin	ret
;-------------------------------------------------------------------------------
; lcdSeg
;
; Estado de los segundos.
;-------------------------------------------------------------------------------
lcdSeg
			cmp.b	#0,r12					; Est� activo el segundo 0?
			jz		TurnOnSeg0				; ... s�, encender seg 0.
			cmp.b	#1,r12					; ... no, est� activa el segundo 1?
			jz		TurnOnSeg1				; ... s�, encender el segundo 1.
			cmp.b	#2,r12					; ... no, est� est� activa el segundo 2?
			jz		TurnOnSeg2				; ... s�, encender el segundo 2.
			cmp.b	#3,r12					; ... no, est� est� activa el segundo 3?
			jz		TurnOnSeg3				; ... s�, encender el segundo 3.
			cmp.b	#4,r12					; ... no, est� activa el segundo 4?
			jz		TurnOnSeg4				; ... s�, encender el segundo 4.
			cmp.b	#5,r12					; ... no, est� activa el segundo 5?
			jz		TurnOnSeg5				; ... s�, encender el segundo 5.
			cmp.b	#6,r12					; ... no, est� activa el segundo 6?
			jz		TurnOnSeg6				; ... s�,encender el segundo 6.
			cmp.b	#7,r12
			jz		TurnOnSeg7
			cmp.b	#8,r12
			jz		TurnOnSeg8
			cmp.b	#9,r12
			jz		TurnOnSeg9
			cmp.b	#10,r12
			jz		TurnOnSeg10
			cmp.b	#11,r12
			jz		TurnOnSeg11
			cmp.b	#12,r12
			jz		TurnOnSeg12
			cmp.b	#13,r12
			jz		TurnOnSeg13
			cmp.b	#14,r12
			jz		TurnOnSeg14
			cmp.b	#15,r12
			jz		TurnOnSeg15
			cmp.b	#16,r12
			jz		TurnOnSeg16
			cmp.b	#17,r12
			jz		TurnOnSeg17
			cmp.b	#18,r12
			jz		TurnOnSeg18
			cmp.b	#19,r12
			jz		TurnOnSeg19
			cmp.b	#20,r12
			jz		TurnOnSeg20
			cmp.b	#21,r12
			jz		TurnOnSeg21
			cmp.b	#22,r12
			jz		TurnOnSeg22
			cmp.b	#23,r12
			jz		TurnOnSeg23
			cmp.b	#24,r12
			jz		TurnOnSeg24
			cmp.b	#25,r12
			jz		TurnOnSeg25
			cmp.b	#26,r12
			jz		TurnOnSeg26
			cmp.b	#27,r12
			jz		TurnOnSeg27
			cmp.b	#28,r12
			jz		TurnOnSeg28
			cmp.b	#29,r12
			jz		TurnOnSeg29
			cmp.b	#30,r12
			jz		TurnOnSeg30
			cmp.b	#31,r12
			jz		TurnOnSeg31
			cmp.b	#32,r12
			jz		TurnOnSeg32
			cmp.b	#33,r12
			jz		TurnOnSeg33
			cmp.b	#34,r12
			jz		TurnOnSeg34
			cmp.b	#35,r12
			jz		TurnOnSeg35
			cmp.b	#36,r12
			jz		TurnOnSeg36
			cmp.b	#37,r12
			jz		TurnOnSeg37
			cmp.b	#38,r12
			jz		TurnOnSeg38
			cmp.b	#39,r12
			jz		TurnOnSeg39
			cmp.b	#40,r12
			jz		TurnOnSeg40
			cmp.b	#41,r12
			jz		TurnOnSeg41
			cmp.b	#42,r12
			jz		TurnOnSeg42
			cmp.b	#43,r12
			jz		TurnOnSeg43
			cmp.b	#44,r12
			jz		TurnOnSeg44
			cmp.b	#45,r12
			jz		TurnOnSeg45
			cmp.b	#46,r12
			jz		TurnOnSeg46
			cmp.b	#47,r12
			jz		TurnOnSeg47
			cmp.b	#48,r12
			jz		TurnOnSeg48
			cmp.b	#49,r12
			jz		TurnOnSeg49
			cmp.b	#50,r12
			jz		TurnOnSeg50
			cmp.b	#51,r12
			jz		TurnOnSeg51
			cmp.b	#52,r12
			jz		TurnOnSeg52
			cmp.b	#53,r12
			jz		TurnOnSeg53
			cmp.b	#54,r12
			jz		TurnOnSeg54
			cmp.b	#55,r12
			jz		TurnOnSeg55
			cmp.b	#56,r12
			jz		TurnOnSeg56
			cmp.b	#57,r12
			jz		TurnOnSeg57
			cmp.b	#58,r12
			jz		TurnOnSeg58
			cmp.b	#59,r12
			jz		TurnOnSeg59
			jmp		lcdHorFin				; ... no, salir de la subrutina sin realizar ning�n cambio.

TurnOnSeg0	clr.b	&LCDM15				;primero borramos para que no haya conflicto
			clr.b	&LCDM16
			clr.b	&LCDM9
			clr.b	&LCDM8
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15 ;poner 00seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM8
			jmp		lcdSegFin
TurnOnSeg1	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15	;01seg
			mov.b	#BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg2	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15 ;poner 02seg
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg3	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15	;03seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg4	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15 ;poner 04seg
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg5	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15	;05seg
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg6	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15 ;poner 06seg
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg7	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15	;07seg
			mov.b	#BIT7|BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg8	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15 ;poner 08seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg9	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM15	;09seg
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg10	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15 ;poner 10seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM8
			jmp		lcdSegFin
TurnOnSeg11	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15	;11seg
			mov.b	#BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg12	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15 ;poner 12seg
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg13	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15	;13seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg14	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15 ;poner 14seg
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg15	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15	;15seg
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg16	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15;poner 16seg
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg17	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15	;17seg
			mov.b	#BIT7|BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg18	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15 ;poner 18seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg19	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5,&LCDM15	;19seg
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg20	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 20seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM8
			jmp		lcdSegFin
TurnOnSeg21	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 21seg
			mov.b	#BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg22	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 22seg
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg23	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 23seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg24	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 24seg
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg25	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 25seg
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg26	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 26seg
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg27	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 27seg
			mov.b	#BIT7|BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg28	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 28seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg29	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM15 ;poner 29seg
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg30	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 30seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM8
			jmp		lcdSegFin
TurnOnSeg31	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 31seg
			mov.b	#BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg32	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 32seg
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg33	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 33seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg34	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 34seg
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg35	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 35seg
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg36	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 36seg
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg37	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 37seg
			mov.b	#BIT7|BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg38	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 38seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg39	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM15 ;poner 39seg
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg40 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 40seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM8
			jmp		lcdSegFin
TurnOnSeg41	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 41seg
			mov.b	#BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg42	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 42seg
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg43	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b   #BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 43seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg44	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 44seg
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg45	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 45seg
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg46	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 46seg
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg47	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b   #BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 47seg
			mov.b	#BIT7|BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg48	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 48seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg49	clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM15 ;poner 49seg
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg50 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 40seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2,&LCDM8
			jmp		lcdSegFin
TurnOnSeg51 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 51seg
			mov.b	#BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg52 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 52seg
			mov.b	#BIT7|BIT6|BIT4|BIT3|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg53 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 53seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg54 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 54seg
			mov.b	#BIT6|BIT5|BIT1|BIT2|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg55 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 55seg
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg56 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 56seg
			mov.b	#BIT7|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg57 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 57seg
			mov.b	#BIT7|BIT6|BIT5,&LCDM8
			jmp		lcdSegFin
TurnOnSeg58 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 58seg
			mov.b	#BIT7|BIT6|BIT5|BIT4|BIT3|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
TurnOnSeg59 clr.b	&LCDM15
			clr.b	&LCDM8
			clr.b	&LCDM16
			clr.b	&LCDM9
			mov.b	#BIT7|BIT5|BIT4|BIT2|BIT1|BIT0,&LCDM15 ;poner 59seg
			mov.b	#BIT7|BIT6|BIT5|BIT2|BIT1|BIT0,&LCDM8
			jmp		lcdSegFin
lcdSegFin	ret

;-------------------------------------------------------------------------------
; lcdPtos
;
; Estado de los puntos que separan horas, minutos y segundos.
;-------------------------------------------------------------------------------
lcdPtos		cmp.b	#1,r12		;estan activos?
			jnz		lcdPtosOff  ;...si, apagar
lcdPtosOn	mov.b	#BIT2,&LCDM7	;...no, encender
			;mov.b	#BIT2,&LCDM20
			jmp		lcdPtosFin
lcdPtosOff	clr.b	&LCDM7
			;clr.b	&LCDM20
lcdPtosFin	ret

;-------------------------------------------------------------------------------
; lcdCora
;
; Corazon latente
;-------------------------------------------------------------------------------
;lcdCora			cmp.b	#1,r12 ;activo??
;				jnz lcdCoraOff

lcdCora			mov.b #BIT2,&LCDM3
				jmp lcdCoraFin
lcdCoraOff		clr.b &LCDM3

lcdCoraFin		ret


;-------------------------------------------------------------------------------
; Tab14Seg
;
; Tabla de 14 segmentos. Cada car�cter necesita dos bytes.
; En el bajo se guardan los segmentos A-M y en el alto los siguientes.
; Los bits 0 y 2 del byte alto se usan para otros s�mbolos.
;-------------------------------------------------------------------------------
			;       abcdefgm   hjkpq-n-
Tab14Seg	.byte	00000000b, 00000000b	;Espacio
			.byte	00000000b, 00000000b	;!
			.byte	00000000b, 00000000b	;"
			.byte	00000000b, 00000000b	;#
			.byte	00000000b, 00000000b	;$
			.byte	00000000b, 00000000b	;%
			.byte	00000000b, 00000000b	;&
			.byte	00000000b, 00000000b	;'
			.byte	00000000b, 00000000b	;(
			.byte	00000000b, 00000000b	;)
			.byte	00000011b, 11111010b	;*
			.byte	00000011b, 01010000b	;+
			.byte	00000000b, 00000000b	;,
			.byte	00000011b, 00000000b	;-
			.byte	00000000b, 00000000b	;.
			.byte	00000000b, 00101000b	;/
			;       abcdefgm   hjkpq-n-
			.byte	11111100b, 00101000b	;0
			.byte	01100000b, 00100000b	;1
			.byte	11011011b, 00000000b	;2
			.byte	11110011b, 00000000b	;3
			.byte	01100111b, 00000000b	;4
			.byte	10110111b, 00000000b	;5
			.byte	10111111b, 00000000b	;6
			.byte	10000000b, 00110000b	;7
			.byte	11111111b, 00000000b	;8
			.byte	11100111b, 00000000b	;9
			.byte	00000000b, 00000000b	;:
			.byte	00000000b, 00000000b	;;
			.byte	00000000b, 00100010b	;<
			.byte	00010011b, 00000000b	;=
			.byte	00000000b, 10001000b	;>
			.byte	00000000b, 00000000b	;?
			;       abcdefgm   hjkpq-n-
			.byte	00000000b, 00000000b	;@
			.byte	01100001b, 00101000b	;A
			.byte	11110001b, 01010000b	;B
			.byte	10011100b, 00000000b	;C
			.byte	11110000b, 01010000b	;D
			.byte	10011110b, 00000000b	;E
			.byte	10001110b, 00000000b	;F
			.byte	10111101b, 00000000b	;G
			.byte	01101111b, 00000000b	;H
			.byte	10010000b, 01010000b	;I
			.byte	01111000b, 00000000b	;J
			.byte	00001110b, 00100010b	;K
			.byte	00011100b, 00000000b	;L
			.byte	01101100b, 10100000b	;M
			.byte	01101100b, 10000010b	;N
			.byte	11111100b, 00000000b	;O
			;       abcdefgm   hjkpq-n-
			.byte	11001111b, 00000000b	;P
			.byte	11111100b, 00000010b	;Q
			.byte	11001111b, 00000010b	;R
			.byte	10110111b, 00000000b	;S
			.byte	10000000b, 01010000b	;T
			.byte	01111100b, 00000000b	;U
			.byte	01100000b, 10000010b	;V
			.byte	01101100b, 00001010b	;W
			.byte	00000000b, 10101010b	;X
			.byte	00000000b, 10110000b	;Y
			.byte	10010000b, 00101000b	;Z
			.byte	10011100b, 00000000b	;[
			.byte	00000000b, 10000010b	;\;
			.byte	11110000b, 00000000b	;]
			.byte	01000000b, 00100000b	;^
			.byte	00010000b, 00000000b	;_
			;       abcdefgm   hjkpq-n-
			.byte	00000000b, 10000000b	;`
			.byte	00011010b, 00010000b	;a
			.byte	00111111b, 00000000b	;b
			.byte	00011011b, 00000000b	;c
			.byte	01111011b, 00000000b	;d
			.byte	00011010b, 00001000b	;e
			.byte	10001110b, 00000000b	;f
			.byte	11110111b, 00000000b	;g
			.byte	00101111b, 00000000b	;h
			.byte	00000000b, 00010000b	;i
			.byte	01110000b, 00000000b	;j
			.byte	00000000b, 01110010b	;k
			.byte	00000000b, 01010000b	;l
			.byte	00101011b, 00010000b	;m
			.byte	00100001b, 00010000b	;n
			.byte	00111011b, 00000000b	;o
			;       abcdefgm   hjkpq-n-
			.byte	00001110b, 10000000b	;p
			.byte	11100111b, 00000000b	;q
			.byte	00000001b, 00010000b	;r
			.byte	00010001b, 00000010b	;s
			.byte	00000011b, 01010000b	;t
			.byte	00111000b, 00000000b	;u
			.byte	00100000b, 00000010b	;v
			.byte	00101000b, 00001010b	;w
			.byte	00000000b, 10101010b	;x
			.byte	01110001b, 01000000b	;y
			.byte	00010010b, 00001000b	;z
			.byte	00000000b, 00000000b	;{
			.byte	00000000b, 00000000b	;|
			.byte	00000000b, 00000000b	;}
			.byte	00000000b, 00000000b	;~
			.byte	00000000b, 00000000b	;
