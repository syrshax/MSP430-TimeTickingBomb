/*
 * msp430ports.h
 *
 *  Created on: 7 dic. 2017
 *      Author: albverf
 */

#ifndef MSP430PORTS_H_
#define MSP430PORTS_H_

//L�mites de los puertos procesables en la tabla de puertos
#define MINP    0               //Primer puerto de los procesables
#define MAXP   10               //�ltimo puerto de los procesables

//Offset de los registros de configuraci�n respecto de la direcci�n base de los puertos
#define PIN        0
#define POUT       2
#define PDIR       4
#define PREN       6
#define PSEL0   0x0A
#define PSEL1   0x0C
#define PSELC   0x16
#define PIES    0x18
#define PIE     0x1A
#define PIFG    0x1C

#endif /* MSP430PORTS_H_ */
