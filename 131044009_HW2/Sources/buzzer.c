#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include <string.h>
#include "buzzer.h"

unsigned char segments[10]={0b00111111,0b00000110,0b01011011,0b01001111,0b01100110,0b01101101,0b01111101,0b00000111,0b01111111,0b01101111};


void MSDelay(unsigned int itime)
{
  unsigned int i,j;
  for(i=0;i<itime;i++)
    for(j=0;j<4000;j++);    //1 msec. tested using Scope
}


unsigned char isSerialOpen;

unsigned int counter;
unsigned int freq=0;
unsigned int toggleState=0;
unsigned int currentTone=0;
unsigned int t=0; // time
unsigned int tofNum=0; // number of overflows


// TC5 Interrupt
interrupt (((0x10000-Vtimch5)/2)-1) void TC5_ISR(void){
  TC5 = TCNT + freq;
  ++toggleState;
  
  if(toggleState==2){
    toggleState=0;
    //++currentTone;
    //PORTB=currentTone;
  }
  TFLG1 = TFLG1 | TFLG1_C5F_MASK;
}


// TIMER OVERFLOW INTERRUPT
interrupt (((0x10000-Vtimovf)/2)-1) void TOF_ISR(void){
  ++tofNum;
  
  //PORTB=t;
  if(tofNum==counter){
    tofNum=0;
    ++t;
  }
  
  TFLG2 = TFLG2 | TFLG2_TOF_MASK;
}  
 
void buzzMelody(unsigned int melody[],unsigned int size, unsigned int tempo[], unsigned int time){

  unsigned int i;

  DDRT = 0x20;

  TIOS =0x20;
  TCTL1=0x04;
  TIE=0x20; // Timer Interrupt Enable for output compare

  PTP=0b11110111; // 4th 7segment

  toggleState=0;
  currentTone=0; 

  if(isSerialOpen){
    freq = FREQ_SERIAL/melody[currentTone];
    counter=62; 
  }
  else{
    
    freq = FREQ_NORMAL/melody[currentTone];
    counter=366;
  }

  TFLG2 |= TFLG2_TOF_MASK;
  TC5=TCNT+ freq;        

  TSCR1=0x80; // timer enable
  TSCR2=0x80; // timer overflow interrupt enable, no prescaler

  __asm CLI;

  while(t<time){
    PORTB=segments[t];
    //PORTB=currentTone;
    if(melody[currentTone]!=0){
      if(isSerialOpen)
        freq = FREQ_SERIAL/melody[currentTone];
      else
        freq = FREQ_NORMAL/melody[currentTone];

    }
    if(isSerialOpen)
      MSDelay((1000/12)*10/10); 
    else MSDelay((1000/12)*15/10);
    ++currentTone;
    if(currentTone>=size)
      currentTone=0; 
  }

  TSCR1=0x0;
  PTT=0;
  DDRT=0;
  TIE=0x00; 
}


void hornMix(){
  
  

}

char inputMsg[]="\n\r-------------\n\rEnter song ID.\n\r00.All Three song.\n\r01.Mario\n\r10.Pirates\n\r11.Rick Roll\n\rInput:";
char invCmdMsg[]="\n\r-------------\n\rInvalid Sond ID!!\n\r";



void choiceMusic(unsigned int val){

  unsigned int size;
  switch(val){
    
    case 0:{
      PORTB=segments[0];
      buzzMelody(melodyMario,MARIO_MELODY_SIZE,tempos,5);
      size = sizeof(melodyPirates)/sizeof(int);
      buzzMelody(melodyPirates,size,tempos,5);
      buzzMelody(melodyRickRolled,RICK_ROLLED_MELODY_SIZE,tempos,5);   
    } break;
    case 1:{
      PORTB=segments[1];
  	  buzzMelody(melodyMario,MARIO_MELODY_SIZE,tempos,15);
      
    } break;
    case 2:{
      PORTB=segments[2];
      size = sizeof(melodyPirates)/sizeof(int);
      buzzMelody(melodyPirates,size,tempos,15);
    } break;
    case 3:{
      PORTB=segments[3];
  	  buzzMelody(melodyRickRolled,RICK_ROLLED_MELODY_SIZE,tempos,15);
    } break;
  
  
  }
}

void startMusicBox(){

  unsigned int num1,num2;
  unsigned int i;
  unsigned int size;
  DDRB=0xFF;
  DDRP=0xFF;
  
 

  for(;;){
  
    toggleState=0;
    currentTone=0;
    t=0; // time
    tofNum=0; // number of overflows
      
    isSerialOpen = PTH & 0x80; // read most significant bit - pth7
  	  
  	if(isSerialOpen){
  	
  	    SCI0BDH=0x0;  
        SCI0BDL=26;  // set baudrate 9600
        SCI0CR1=0x0;
        SCI0CR2=0x0C; // receive-transmit enable
        SCI0DRH=0x0;  // data high empty
  	    
  	    for(i=0;i<strlen(inputMsg);++i){
  	      while(!(SCI0SR1 & SCI0SR1_TDRE_MASK));
  	      SCI0DRL= inputMsg[i];
  	    }
  	    
  	    // read song id from serial
  	    while(!(SCI0SR1 & SCI0SR1_RDRF_MASK));
  	    num1 = SCI0DRL;
  	    while(!(SCI0SR1 & SCI0SR1_RDRF_MASK));
  	    num2 = SCI0DRL;
  	    
  	    if(num1=='0' && num2=='0'){  // all
  	      choiceMusic(0);
  	    }else if(num1=='0' && num2=='1'){  // mario
  	      choiceMusic(1);
  	    }else if(num1=='1' && num2=='0'){  // pirates
  	      choiceMusic(2);
  	    }else if(num1=='1' && num2=='1'){  // rick rolled
  	      choiceMusic(3);
  	    }else{ // invalid input              
  	      for(i=0;i<strlen(invCmdMsg);++i){
  	        while(!(SCI0SR1 & SCI0SR1_TDRE_MASK));
  	        SCI0DRL= invCmdMsg[i];
  	      }
  	      PORTB=0x0;
  	    }
  	    
  	  }else{
    	  int val = PTH & 0x3; // just take 0-1 pth switches
        PORTB=segments[val];
        choiceMusic(val);
  	  }
  }
   
}
