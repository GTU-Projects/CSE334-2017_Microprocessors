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

unsigned int freq=0;
unsigned int h=0;
unsigned int toggleState=0;
unsigned int currentTone=0;
int timeLimit=5;
unsigned int t=0; // time
unsigned int tofNum=0; // number of overflows


// TC5 Interrupt
interrupt (((0x10000-Vtimch5)/2)-1) void TC5_ISR(void){
  TC5 = TCNT + freq;
  ++toggleState;
  
  if(toggleState==2){
    toggleState=0;
    ++currentTone;
    PORTB=currentTone;
  }
  TFLG1 = TFLG1 | TFLG1_C5F_MASK;
}


// TIMER OVERFLOW INTERRUPT
interrupt (((0x10000-Vtimovf)/2)-1) void TOF_ISR(void){
  ++tofNum;
  
  //PORTB=t;
  if(tofNum==366){
    tofNum=0;
    ++t;
  }
  
  TFLG2 = TFLG2 | TFLG2_TOF_MASK;
}  
 


void hornMario(){

  unsigned int i=0;
  unsigned int size;
  
  DDRT = 0x20;
  DDRB = 0xFF;
  DDRP = 0xFF;
  
  
  

  TIOS =0x20; // pt5 outout
  TCTL1=0x04; // toggle pt5 pin
  TIE=0x20; // Timer Interrupt Enable for output compare  
  
  PTP=0b11110111; // 4th 7segment
  
  toggleState=0;
  currentTone=0; 
  size = sizeof(melodyMario)/sizeof(unsigned int);

  freq = FREQ_NORMAL/melodyMario[currentTone];
  
  TFLG2 |= TFLG2_TOF_MASK;
  TC5=TCNT+ freq;        
  
  TSCR1=0x80; // timer enable
  TSCR2=0x80; // timer overflow interrupt enable, no prescaler
  __asm CLI;
  
  while(t<=timeLimit){
    //PORTB=segments[t];
   // PORTB=;
    if(melodyMario[currentTone]!=0){
      freq = FREQ_NORMAL/melodyMario[currentTone];
    }
    MSDelay(1500);  
    if(currentTone>=50)
      currentTone=0; 
  }
  
  TSCR1=0x0;
  PTT=0;
  DDRT=0;
  TIE=0x00; 
  
  for(;;){
    PORTB=3;
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
  tofNum=0;
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

void hornRickRolled(){
  
  unsigned int i=0;
  unsigned int size;
  
  DDRT = 0x20;
  //DDRB = 0xFF;
  
  TSCR1=0x80;
  TSCR2=0x00;
  
  TIOS =0x20;
  TCTL1=0x04; // toggle pin
  
  TIE=0x20; // Timer Interrupt Enable for output compare

  toggleState=0;
  size = sizeof(melodyRickRolled)/sizeof(unsigned int);
  TC5=TCNT+ FREQ_NORMAL/melodyRickRolled[i];
  while(1){
      PORTB=segments[i%10];
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

