//;-----------------------------------------------------------------
//; ALBERTO VERGARA
//; Grupo: L5
//;-----------------------------------------------------------------
/*
 * lcd.h
 *
 *  Created on: 29 nov. 2021
 *      Author: albervf
 */

#ifndef LCD_H_
#define LCD_H_
void lcdIni (void);
unsigned int lcda2seg (char c);
void lcdLPutc (char c);
void lcdRPutc (char c);
void lcdClearAll (void);
void lcdClear (void);
void lcdBat (unsigned char b);
void lcdPtos (unsigned int b);
void lcdHor (unsigned int b);
void lcdMin (unsigned int b);
void lcdSeg (unsigned int b);
#endif /* LCD_H_ */
