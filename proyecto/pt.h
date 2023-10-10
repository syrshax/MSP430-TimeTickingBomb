/*
 * pt.h
 *
 *  Created on: Dec 7, 2021
 *      Author: albervf
 */

#ifndef PT_H_
#define PT_H_

typedef unsigned char puerto_t; //creacion de un tipo de variable nueva llamada puerto_t, tendra 8 bits sin signo. Servira para albergar informacion de nuestros puertos.

puerto_t ptConfigura (int puerto, int bit, int modo);
               //{  // creamos una funcion para configurar nuestro vector tipo puerto_t con 3 variables de entrada tipo int 16 bits

             //   puerto = (puerto<<1);
             //   bit = (000000000000111b && bit);

            //    if (modo && 000000000000001b) {
             //   else
             //   }
             //   else dasd
//}
                                                        // cada una de ellas, servira para introducir valores dentro de nuestra funcion tipo puerto_t.
                                                        //
                                                        //  BTIS            7           6   5   4   3           2   1   0
                                                        //          Activo alta = 1     Puerto a configurar     Que bit del puerto
                                                        //                 baja = 0     PIN, POUT, PREN...      estamos usando: p1.1, p1.2...

int ptLee (puerto_t pt);// Lee variable tipo puerto_T y verifica que esta correcta.



void ptEscribe (puerto_t pt, int valor);



#define PT_ESDIG            (0) //= 0 = ...00000000 bits 0 y 1
#define PT_FUNC1            (1) //= 1 = ...00000001
#define PT_FUNC2            (2) //= 2 = ..00000010
#define PT_FUNC3            (3) //= 3 = ...00000011
#define PT_ENTRADA (0<<2) // si muevo el 0 , 2 posiciones a la derecha, osea multiplicar por 2, 2 veces el 0. = ..000000000 localizamos bits 3 y 2
#define PT_ENTRADA_PULLUP (1<<2) // muevo el 1, dos veces hacia la izquierda, mult x2 dos veces = 4 = ...00000100
#define PT_ENTRADA_PULLDOWN (2<<2) //=  8 = ...0001000
#define PT_SALIDA (3<<2)  //= 12 = ...001100
#define PT_OFF (0<<4) //=  0 = ...0000000 localizamos bit 4
#define PT_ON (1<<4) //= 16 =  ...0010000
#define PT_ACTIVOALTA (0<<5) //= 0 = ...0000000 localizamos bit 5
#define PT_ACTIVOBAJA (1<<5) //= 32 = ...00100000

#endif /* PT_H_ */
