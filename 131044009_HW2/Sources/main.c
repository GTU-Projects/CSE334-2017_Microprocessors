#include <hidef.h>      /* common defines and macros */
#include "derivative.h"      /* derivative-specific definitions */
#include <string.h>
//#include "buzzer.h"

unsigned char segments[10]={0b00111111,0b00000110,0b01011011,0b01001111,0b01100110,0b01101101,0b01111101,0b00000111,0b01111111,0b01101111};

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

//int isSerialOpen;

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

unsigned char isSerialOpen;


void main(void) {

  unsigned char i=0;
  unsigned char num1,num2;
  
 // char inputMsg[]="\n\r-------------\n\rEnter song ID.\n\r00.All Three song.\n\r01.Mario\n\r10.Pirates\n\r11.Rick Roll\n\rInput:";
 // char invCmdMsg[]="\n\r-------------\n\rInvalid Sond ID!!\n\r";
	
	
	DDRB=0xFF; // led-7segment output
	DDRP=0xFF; // buzzer and output compare
	DDRH=0x00; // swithes input
	
  //PTP=0xFE;
  //EnableInterrupts;
  //hornRickRolled();
  hornPirates();
  //hornMario();
  
  //for(;;)
  //  toftest();	

  /*for(;;){
    

    isSerialOpen = PTH & 0x80; // read most significant bit - pth7
  	  
  	if(isSerialOpen){
  	
  	    SCI0BDH=0x0;  // set baudrate 9600
        SCI0BDL=26;
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
  	      PORTB=segments[0];
  	      hornMix();
  	    }else if(num1=='0' && num2=='1'){  // mario
  	      PORTB=segments[1];
  	      hornMario();
  	    }else if(num1=='1' && num2=='0'){  // pirates
  	      PORTB=segments[2];
  	      hornPirates();
  	    
  	    }else if(num1=='1' && num2=='1'){  // rick rolled
  	      PORTB=segments[3];
  	      hornRickRolled();
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
        if(val==0)
          hornMix();
        else if(val==1)
          hornMario();
        else if(val==2){
          for(;;)
            hornPirates();  
        }
        else if(val==3)
          hornRickRolled();
        else PORTB=0;
       
  	  }
  }  */
	  	   
}

