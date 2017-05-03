#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include <string.h>
//#include "buzzer.h"

/*
 * Precondions: 
 *  -- XTAL: 48MHZ - Controller: 24MHz
 *  -- Prescaler(TSCR2 |= 0x07) : 2^7 = 128
 */
void delayTsec(unsigned char t){
  unsigned char i=0,j=0;
  
  TFLG2 |= 0x80;
  for(i=0;i<t;++i){
    for(j=0;j<3;++j){
      while(!(TFLG2 & TFLG2_TOF_MASK)); // 350ms
      TFLG2 |= 0x80; // clear timer overflow flag
    }
  }


}
// ms delay
void delay10Tms(int t){

  unsigned char i=0,j=0;
  
  TSCR1=0x80;
  TSCR2=0x07;
  
  TFLG2 |= 0x80;
  for(i=0;i<t;++i){
    for(j=0;j<4;++j){
      while(!(TFLG2 & TFLG2_TOF_MASK)); // 2.73ms
      TFLG2 |= 0x80; // clear timer overflow flag
    }
  }
  //TSCR1=0x00;
  TSCR2=0x00;
  
}


void main(void) {

  startMusicBox();
	  	   
}

