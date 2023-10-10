//;-----------------------------------------------------------------
//; Alberto Vergara
//; Grupo: L5
//;-----------------------------------------------------------------
/*
 *
 *  Created on: 27 ene. 2022
 *      Author: albervf
 */

#include <msp430.h> 
#include "cs.h"
#include "lcd.h"
#include "st.h"
#include "lpiu.h"
#include "teclado.h"
#include "msp430fr6989.h"
#include "pt.h"



#define FTA2        32768           // Frecuencia del reloj del TA2 en Hz.
#define FLcd        2               // Frecuencia de la tarea del lcd en Hz.
#define FBat        2              // Frecuencia de la tarea de la bater�a en Hz.
#define Firq        80            // Frecuencia de la interrupci�n en Hz.
#define FLed        5               // Frecuencia de la tarea de los led en Hz.
#define FPtos       2               // Frecuencia de la tarea de los puntos que dividen el reloj en Hz.
#define periodo     FTA2/Firq-1     // CCR0
#define perLcd      Firq/FLcd       // Periodo del lcd.
#define perLed      Firq/FLed        // Periodo de la bater�a a la frecuencia de 5 Hz.
#define perBat_2Hz  Firq/FBat       // Periodo de la bater�a a la frecuencia de 2 Hz.
#define perBat_4Hz  Firq/(FBat*2)   // Periodo de la bater�a a la frecuencia de 4 Hz.
#define perPass  Firq/(FBat*4)  // Periodo de la bater�a a la frecuencia de 8 Hz.
#define perBat_16Hz Firq/(FBat*8)   // Periodo de la bater�a a la frecuencia de 16 Hz.
#define perCorza     Firq/FPtos       // Periodo de los puntos a la frecuencia de 2 Hz.
#define perReloj    Firq/FReloj     // Periodo del reloj a la frecuencia de 1 Hz.
#define FReloj      1               // Frecuencia de la tarea del Reloj
#define frefresco   Firq/FReloj
#define perPass     perLcd*2

void countdownreal (void);
void cuenta(void);
void pass (void);
void passwordOk (void);
void pinta (void);

static unsigned int estado = 0;

static unsigned long ProxCuenta = 0; // Variable de la pr�xima ejecuci�n de la tareaReloj.
static unsigned long ProxCorazon = 0;  // Variable de la pr�xima ejecuci�n de la tareaBat.
static unsigned long ProxPintar = 0; // Variable de la pr�xima ejecuci�n de la tareaLcd.
static unsigned long ProxPassword = 0;
static unsigned int pass1 = 0;
static unsigned int pass2 = 0;
static unsigned int pulsar = 0;



static unsigned int countdown = 0;



void countdownreal (void){

    if(stTime() >= ProxCuenta)

        {

            ProxCuenta+=perReloj;
            countdown--;
            lcdHor(countdown);

    }

}

void corazon (unsigned int estado)
{
    if(stTime() >= ProxCorazon){
        ProxCorazon+=perCorza;

    if (estado !=  0){
        lcdCoraOff();
    }
        else  {
            lcdCora();
        }

    }
}




void pinta (void){

    if(stTime() >= ProxPintar)                // Si toca realizar la tareaLcd, la ejecuta.
        {
        ProxPintar += perLcd;
        lcdLPutc(kbGetc());


        }
}


void passwordOk (void){

    if(stTime() >= ProxPassword){
        ProxPassword += perPass;

    }

}

void pass (void){

    if (pulsar==0){
        pass1 = kbGetc();
        if(pulsar==0 && pass1=='1'){
         lcdClearAll();
         estado = 0;
        }
    }
}

void signal (void){

    if (kbGetc() !=0){
        estado = 1;
    }

}

void outta (void){

    if (kbGetc()=='A'){
        estado = 0;
        lcdClearAll();
    }
}



/**
 * main.c
 */

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;   // Desactivar el perro guardi�n.
    PM5CTL0 &= ~LOCKLPM5;       // Desbloquear los puertos de E/S.

    puerto_t S1;

    csIniLf();                  // Inicializar la pantalla.
    lcdIni();                   // Inicializar el reloj del sistema.
    stIni(periodo);             // Inicializar el SystemTimer y ajustar el valor del tic.
    ledIni1();                  // Inicializar el led1.
    ledIni2();                  // Inicializar el led2.
    kbIni();                    // Iniciar teclado.

   // unsigned int sS1; // ESTA VARIABLE INDICARA EN QUE ESTADO ESTAMOS, SI 0, ESTADO PAUSA, SI 1, ESTADO PARA INTRODUCIR COSAS, SI 2, ESTADO GUAY, SI 3 ESTADO DE ALARMA!!!!!!!!

while(1) {

          switch (estado){

          case 0: // estado de reposo

              lcdCora(); //encedemos corazon por ASM

              if (kbGetc() !=0){

                     estado = 1;
                     stReset(); // Reiniciamos los relojes y los estados de las cuentas ya que empezamos nuevo ciclo
                     countdown = 24; // Aqui seleccionamos el valor de nuestra cuenta atras. Esta creado ya que hize test con diferentes tiempos. De ayuda.
                     ProxCuenta=0;
                     ProxPintar=0;
                     ProxPassword=0;
              }

              break;

          case 1:   // estado de meter numeros

             lcdCoraOff();
             pinta();
             countdownreal();
             lcdPtosOn();
             passwordOk();





             if (countdown==0){ //Si la cuenta atras termina, volvemos al estado 0 en esete caso y limpiamos pantalla con funcion ASM.
                 estado = 0;
                 lcdClearAll();
             }


             break;

          case 2:

              break;

          case 3: // estado de alarma...�

              break;



          }

    }

}









