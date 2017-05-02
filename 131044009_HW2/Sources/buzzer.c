#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include <string.h>
#include "buzzer.h"


void MSDelay(unsigned int itime)
{
  unsigned int i,j;
  for(i=0;i<itime;i++)
    for(j=0;j<325;j++);    //1 msec. tested using Scope
}


unsigned int freq;
unsigned int h;
unsigned int toggleState;

interrupt (((0x10000-Vtimch5)/2)-1) void TC5_ISR(void){
  TC5+=freq;
  TFLG1 |= TFLG1_C5F_MASK;
  ++toggleState;
  if(toggleState==2){
    toggleState=0;
  }
}


void hornPirates(){
  
  unsigned int i;
  unsigned int size;
  
  DDRT = 0x20;
  //DDRB = 0xFF;
  
  TSCR1=0x80;
  TSCR2=0x00;
  
  TIOS =0x20;
  TCTL1=0x04;
  
  TIE=0x20; // Timer Interrupt Enable for output compare
  
  i=0;
  toggleState=0;
  size = sizeof(melodyMario)/sizeof(unsigned int);
  
  TC5=TCNT+ FREQ_NORMAL/melodyPirates[i];
  while(1){
      freq = FREQ_NORMAL/melodyPirates[i];
      MSDelay(2000);
      //PORTB=i;
      ++i;
      if(i>size)
        i=0;
  }
}


void hornMario(){

  unsigned int i;
  unsigned int size;
  
  DDRT = 0x20;
  //DDRB = 0xFF;
  
  TSCR1=0x80;
  TSCR2=0x00;
  
  TIOS =0x20;
  TCTL1=0x04; // toggle pin
  
  TIE=0x20; // Timer Interrupt Enable for output compare
  
  i=0;
  toggleState=0;
  size = sizeof(melodyMario)/sizeof(unsigned int);
  TC5=TCNT+ FREQ_NORMAL/melodyMario[i];
  while(1){
      freq = FREQ_NORMAL/melodyMario[i];
      MSDelay(1500);
      //PORTB=i;
      ++i;
      if(i>size)
        i=0;
  }
}


void hornRickRolled(){
  
  unsigned int i;
  unsigned int size;
  
  DDRT = 0x20;
  //DDRB = 0xFF;
  
  TSCR1=0x80;
  TSCR2=0x00;
  
  TIOS =0x20;
  TCTL1=0x04; // toggle pin
  
  TIE=0x20; // Timer Interrupt Enable for output compare
  
  i=0;
  toggleState=0;
  size = sizeof(melodyRickRolled)/sizeof(unsigned int);
  TC5=TCNT+ FREQ_NORMAL/melodyRickRolled[i];
  while(1){
      freq = FREQ_NORMAL/melodyRickRolled[i];
      MSDelay(3000);
      //PORTB=freq%255;
      ++i;
      if(i>size)
        i=0;
  }

}

void hornMix(){
}
