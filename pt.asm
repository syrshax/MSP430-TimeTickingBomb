;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
; M�dulo: pt.asm
; Fecha: Dec 7, 2021
; Author: albervf
;-------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430.h"       ; Con cdecls, incluimos cabeceras de C en esamblador, por lo que podemos crear funciones en .h y pasarlas a asm para trabajar con ellas.
            .cdecls C,LIST,"msp430ports.h"
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

			.global ptConfigura
			.global	ptLee
			.global	ptEscribe
			.global TabBits
			.global TabPuertos	; los globals son para referenciar etiquetas de este archivo para usarlas en mi programa.



ptConfigura				push r4
						push r5
						clr.w r5
						clr.w r4
						cmp.w #-1, r12
						jz ERROR
						cmp.w #11, r12
						jz ERROR		;en r12 entra el tipo de puerto, en r13 entra el bit del puerto .1, .2, .3... hasta 7 solamente. y en r14 entra si un 1 o 0 en la polaridad.
						mov.w r12, r11 ;copiamos el puerto en r11 para modificar.
						rla.w r11 ;ajustamos el offset del puerto para coincidir con nuestra tabla de msp430ports.asm
						mov.w TabPuertos(r11),r11 ;ya tenemos el el numero d puerto. Supongamos r12 = 1, 1*2 = 2, direccion $2 offset de tabla, que indica puerto P1.
						mov.b TabBits(r13), r15 ;copiamos para modificar.
						;and.w #000000000000111b, r15 ;enmascaramos todos los bits excepto los 3 ultimos (111), tenemos en r15 esa mascara.

						bic.b r15,PSEL0(r11)
						bic.b r15,PSEL1(r11)
						bic.b r15,PDIR(r11)
						bic.b r15,POUT(r11)
						bic.b r15,PIN(r11)
						bic.b r15,PIES(r11)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Aqui empezamos a chekear los bits desde el 0 1, hasta el 5....;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

						mov.w r14,r5 ;guardo copia en r5 que modificaremos
confmod01				and.w #0000000000000011b,r5 ;conservo solo bit 0 y 1, primera comprobacion
						cmp.w #0000000000000001b,r5
						jz mod011
						cmp.w #0000000000000010b, r5
						jz mod012
						cmp.w #0000000000000011b, r5
						jz mod013
						jmp confmod23
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MODOS DE SELECCION PUERTO E/S ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mod011					bic.b r15,PSEL0(r11)
						bis.b r15,PSEL1(r11)
						jmp confmod23
mod012					bis.b r15,PSEL0(r11)
						bic.b r15,PSEL1(r11)
						jmp confmod23
mod013					bis.b r15,PSEL0(r11)
						bis.b r15,PSEL1(r11)


confmod23				mov.w r14,r5 ; VOLVEMOS A COPIAR EL VALOR DE R14 A R5, Y ENMASCARAMOS OTRA VEZ.
						and.w #0000000000001100b,r5			;conservamos solo el 2 y 3
						cmp.w #0000000000000100b,r5 ;ENTRADA PULLUP
						jz mod231
						cmp.w #0000000000001000b,r5 ;ENTRADA PULLDOWN
						jz mod232
						cmp.w #0000000000001100b,r5 ;PUERTO SALIDA
						jz mod233
						jmp confmod4

mod231					bic.b r15,PDIR(r11)
						bis.b r15,PREN(r11)
						bis.b r15,POUT(r11) ;config de entrada pullup
						;cmp.w #0000000000000001b,PSEL0(r11)	;con esto comprobamos si estamos en un modo distinto del 00
						;jz confmod4	; que estariamos en E/S, al hacer tst, solamente cuando es 0 continuamos, si es
						;cmp.w #0000000000000010b,PSELC(r11)
						;jz confmod4
						jmp confmod4		; diferente de 0, saltamos, ya que jnz, (jump not zero = salto no zero)
mod232					bis.b r15,PREN(r11) ;config de entrada pulldown
						bic.b r15,POUT(r11)
						cmp.b #0000000000000001b,PSEL0(r11)	;con esto comprobamos si estamos en un modo distinto del 00
						jz	endconfig 		; que estariamos en E/S, al hacer tst, solamente cuando es 0 continuamos, si es
						cmp.b #0000000000000010b,PSEL1(r11)
						jz endconfig
						jmp confmod4
mod233					bis.b r15,PDIR(r11) ;config puerto como salida
						;cmp.b #0000000000000011b,PSELC(r11)
						;jnz	endconfig
						jmp confmod4


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;																																				;
;; AQUI HACEMOS... MIRAMOS LA POLARIDAD PRIMERO, SI LA POLARIDAD ES 0, QUIERE DECIR ALTA, POR LO QUE PON Y POFF PONEN A 1 Y 0 EN SALIDA/ENTRADA	;
;; 																																				;
;; SI POR EL CONTRARIO, EL BIT 5 ES 1, PON Y POFF SON 0 Y 1, PON PONE UN 0 EN LA SALIDA Y POFF UN 1 EN LA SALIDA/ENTRADA						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
confmod4				mov.w r14,r5
						and.w #0000000000100000b,r5				;; SE CHEKEA POLARIDAD ANTES
						tst.b r5 ;quiere decir polaridad ALTA.

						jz polALTA ;sino esta en ALTA... ESTA EN BAJA.

						bis.b r15,PIES(r11)
						mov.w r14,r5
						and.w #0000000000010000b,r5
						cmp.w #0000000000010000b,r5
						jz enOFFBAJA

						bis.b r15,PIN(r11) ;AQUI EL POFF SERIA PONERLOS EN 1
						bis.b r15,POUT(r11)
						mov.w #0000000000100000b,r5

						jmp endconfig

enOFFBAJA				bic.b r15,PIN(r11) ; aqui el PON SERIA PONERLOS A 0
						bic.b r15,POUT(r11)
						mov.w #0000000000100000b,r5
						jmp endconfig



polALTA					bic.b r15,PIES(r11)
						mov.w r14,r5
						and.w #0000000000010000b,r5
						cmp.w #0000000000010000b,r5
						jz enON

						bic.b r15,PIN(r11) ; aqui el POFF SERIA PONERLOS A 0
						bic.b r15,POUT(r11)
						mov.w #0000000000000000b,r5
						jmp endconfig

enON					bis.b r15,PIN(r11) ;AQUI EL PON SERIA PONERLOS EN 1
						bis.b r15,POUT(r11)
						mov.w #0000000000000000b,r5
						jmp endconfig

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EL BIT 5 ESTA EN R5, YA CONFIGURADO PREVIAMENTE SU RESPECTIVA POLARIDAD DEPENDIENDO DE DONDE ESTES								;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;endconfigalfa			mov.w r14,r5
;						and.w #0000000000100000b,r5				;; se guarda la polaridad.

endconfig				clr.w r4
						bis.w r5,r4 ;sumo el bit de polaridad, que acaba de estar en r5, justo en la linea de arriba.
						rla.w r4
						rla.w r4 ;muevo 2 veces r4, por lo que estoy en el bit 7 mi polaridad
						mov.w r12,r5 ;el contenido de PUERTO, lo muevo a r5, por lo que r5=r12,
						rla.w r5
						rla.w r5
						rla.w r5
						bis.w r5,r4 ;sumo a r5, r13
						bis.w r13,r4	;sumo a r4 (que estaba solamente ocupado el bit 7, r5, que estan los bits del 6 al 3 (4)
						mov.w r4,r12 ;muevo el contenido de r4, a r12, por lo que copio r4 en r12...
destackend				pop r5
						pop r4

						ret


ERROR					mov.w	#0x00FF, r12
						jmp		destackend
						nop


;;;;;;;;;;;;;;;;;
; CONFIG PTLEE ;;
;;;;;;;;;;;;;;;;;

ptLee			cmp.b #0xFF, r12 ;Si tenemos esto, tenemos error, no hacemos nada
				jz nothingburger
				mov.b r12,r13
				mov.b r12,r15

				and.b #00000111b,r13
				mov.b TabBits(r13),r13
				mov.b r12,r14
				sxt r14
				and.w #0000000001111000b,r14
				rra r14
				rra r14
				;rra r14
				mov.w TabPuertos(r14),r14


				and.b #10000000b,r12
				cmp.b #0x80,r12 ;quiere decir polaridad negativa
				jz leeBAJA

				bit.b r13,POUT(r14)
				jz send0
				bit.b r13, PIN(r14)
				jz send0
				jmp send1


leeBAJA			bit.b r13, POUT(r14)
				jz send1
				bit.b r13,PIN(r14)
				jz send1
				jmp send0

send0			mov.w #0,r12
				jmp nothingburger

send1			mov.w #1,r12
				jmp nothingburger

nothingburger 	ret



;;;;;;;;;;;;;;;;;;;;;
; CONFIG PTESCRIBE ;;
;;;;;;;;;;;;;;;;;;;;;


ptEscribe		cmp.b #0xFF, r12 ;Si tenemos esto, tenemos error, no hacemos nada
				jz nothingburger2


				mov.b r12,r14
				mov.b r12,r15
				and.b #00000111b, r14
				mov.b TabBits(r14),r14
				sxt r15
				and.w #0000000001111000b,r15
				rra r15
				rra r15
				mov.w TabPuertos(r15),r15

				tst.w r13
				jz Apagar

Encender		and.b #10000000,r12
				cmp.b #10000000,r12 ; se enmascara y se ve si la polaridad esta NEGATIVA
				jz negativa
				bis.b r14,PIN(r15)	; se enciende con POLARIDAD POSITIVA
				bis.b r14,POUT(r15)
				ret
negativa		bic.b r14,PIN(r15)
				bic.b r14,POUT(r15)
				ret

Apagar			and.b #10000000,r12
				cmp.b #10000000,r12
				jz negativaapagar ;se enmasscara y se ve la polaridad NEGATIVA
				bic.b r14,PIN(r15) ;se apagan, POLARIDAD POSITIVA BIT 5 = 0
				bic.b r14,POUT(r15)
				ret

negativaapagar	bis.b r14,PIN(r15)	; se apagan con POLARIDAD NEGATIVA
				bis.b r14,POUT(r15)
				ret



nothingburger2 ret







