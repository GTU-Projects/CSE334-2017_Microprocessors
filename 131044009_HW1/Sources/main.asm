;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************
;*                                                               *
;*                   HASAN MEN - 131044009                       *
;*                                                               *
;*                       CSE334 - HW1                            *
;*                                                               *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU $4000  ; absolute address to place my code/constant data
EQU_START   EQU $1200  ; memory address of eqation

            ORG RAMStart
N1I:        DC.W 0; INTEGER PART OF NUM1
N1D:        DC.B 0; DECIMAL PART OF NUM1
N2I:        DC.W 0; INTEGER PART1 OF NUM2
N2D:        DC.B 0; DECIMAL PART OF NUM2
INDEX:      DC.B 0; index for integer part1

SHIFT_SIZE: DC.B 0; 2 -> shift with *10 --> 20

ITEM1:      DC.B 0; cast value part1
ITEM2:      DC.B 0; cast value part2

INT_PART:   DC.W 0; number(16bit max) which will be multiplied with 10
INT_NUM:    DC.W 0; result(16bit max) of multiply operation

DEC_PART:   DC.B 0; number(8bit max) which will be multiplied with 10
DEC_NUM:    DC.B 0; result(16bit max) of multiply operation

OPERATOR:   DC.B 0;

DEC_CARRY1: DC.B 0; carry status
DEC_CARRY2: DC.B 0

RES_DEC:    DC.B 0; decimal part of last result
RES_INT:    DC.W 0; integer part of last result


            ORG EQU_START
            FCC "80.08-40.09="  ; Equation strig
            
; code section
            ORG   ROMStart

Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
                     

            LDX #EQU_START ; regX = #$1200
            
            JSR READ_INT_PART1 ; find integer part1 and store in N1I
            INX                ; pass "." delimiter
            JSR READ_DEC_PART1 ; find decimal part1 and store in N1D
            
            ; pass spaces before operator
PASS_SPACE: 
            LDAA 0,X
            CMPA #$20 ;compara with space
            BEQ PASS_SPACE
            
            STAA OPERATOR  ; store operator
            
            ; pass spaces after operator
PASS_SPACE2:INX
            LDAA 0,X
            CMPA #$20 ;compara with space
            BEQ PASS_SPACE2

            ; CLEAR USED AREAS to USE AGAIN
            CLRA
            CLRB
            STD ITEM1
            STAA INDEX
            STD INT_PART
            STD INT_NUM
            STD DEC_PART
            
 
            JSR READ_INT_PART2 ; find integer part1 and store in N2I 
            INX                ; pass "." delimiter
            JSR READ_DEC_PART2 ; find decimal part2 and store in N2D
            
            LDAA 0,X     ; element which cames after last digit
            CMPA #$3D    ; check "=" sign to continue calculation
            BNE  GO_END  ; close program if "=" there is no "=" sign                                         
                        
            LDAA OPERATOR   ; load operator
            CMPA #$2B       ; if operator is "+", go ADD_NUMBERS part               
            BEQ ADD_NUMBERS
            
SUB_NUMBERS: ;Subtract numbers
            LDAA N1D
            SUBA N2D
            BCC SUB_OK ; N1D < N2D --> take 1 ten from left side(N1I)
            
            LDD N1I
            SUBD #1          ; If N1I < 0 , there is an error
            BCS SHOW_RESULT
            STD N1I
            
            LDAA N1D
            INCA
            SUBA N2D
            
SUB_OK:
            STAA RES_DEC
            
            LDD N1I
            SUBD N2I
            BCS SHOW_RESULT
            
            STD RES_INT
            BRA SHOW_RESULT
     
            
ADD_NUMBERS: ; Add numbers  

            LDAA N1D     ; A = decimalPart1
            ADDA N2D     ; A = A + decimalPart2
            STAA RES_DEC ; store decimal 
            CMPA #100    ; compare num, 100
            BLT ADD_INT_PART ; if overflow no occur, continue to add integer parts
            LDAA #1
            STAA DEC_CARRY2 ; store overflow bit   
            
ADD_INT_PART:
            LDD N1I     ; load number1 integer part
            ADDD N2I    ; load number2 integer part
            BCS SHOW_RESULT ; if there is an overflow, show FF result
            ADDD DEC_CARRY1 ; add carry, if there is
            BCS SHOW_RESULT ; if there is an overflow, show FF result
            STD RES_INT     ; store valid calculation result
            
            
SHOW_RESULT:
            BCC LOAD_RES_INT  ; check carry bit
            LDD #$FFFF        ; D = #$FFFF
            STD RES_INT       ; Store FFFF value

LOAD_RES_INT:
            LDAA #$FF     ; Make portB output
            STAA DDRB
            
            LDD RES_INT   ; load result
            STAB PORTB    ; store result
                  
GO_END:     CALL END      ; end of calculation
            

;
; SUBROUTINE: Read integer part from string until '.' delimiter
; It's saves integer value(0-65535) in N1I
;
READ_INT_PART1:

            LDAA 0,X                                          
                        
            CMPA #$2E ; if find '.'
            BEQ READ_1_DONE        

            SUBA #$30 ; char to integer
            
            STAA ITEM2 ; store integer to memory
            
            LDAA INDEX ; 0.indexte kaydýrmaya gerek yok
            BEQ GO_NEXT
            

            LDAA #10  ; 10la carpacaz
            STAA SHIFT_SIZE ; kac ile carpilacak yukle
            LDD N1I
            STD INT_PART ; Shift edilecek sayiyi tut
            
            LDD #0
            STD INT_NUM
                       
            JSR INT_SHIFTER  ; sayiyi kaydýr
                
GO_NEXT:    
            LDD INT_NUM ; eski sayiyi al
            ADDD ITEM1 ; carpilan sayiya karakteri ekle
            STD N1I                        
            
            LDAA INDEX  ; indexi arttýr
            INCA
            STAA INDEX
            INX ; dizi indexini arttýr
            BRA READ_INT_PART1 ; nokta gorene kadar bu dondu dönecek
            
READ_1_DONE:RTS  ; bitir
            

; SUBROUTINE: Read decimal part from string which first index stored in X register
; decimal part can be 2 digit
; stores value in N2D            
READ_DEC_PART1:
            LDAA 0,X
            SUBA #$30
            
            INX ; sýradaki karakteri al
            
            STAA DEC_PART
            
            LDAA #0
            STAA DEC_NUM
                        
            LDAA #10
            STAA SHIFT_SIZE
            
            JSR  DEC_SHIFTER            
            LDAA  DEC_NUM
            
            LDAB  0,X
            CMPB #$2E ; "." CHECK
            BEQ READ_DEC_PART1_END
            CMPB #$2B ; "+" check
            BEQ READ_DEC_PART1_END
            CMPB #$2D ; "-" check
            BEQ READ_DEC_PART1_END
            CMPB #$20 ; " " space check
            BEQ READ_DEC_PART1_END

            SUBB #$30
            ABA
            INX 
            
READ_DEC_PART1_END:
            STAA N1D
            RTS
            
            
; SUBROUTINE: Read integer part from string until '.' delimiter
; It's saves integer value(0-65535) in N2I            
READ_INT_PART2:
            
            LDAA 0,X
            
            CMPA #$2E ; if find '.'
            BEQ READ_2_DONE        

            SUBA #$30 ; char to integer
            
            STAA ITEM2 ; store integer to memory
           
            LDAA INDEX
            BEQ GO_NEXT2
            
            LDAA #10  ; 10la carpacaz
            STAA SHIFT_SIZE ; kac ile carpilacak yukle
            LDD N2I
            STD INT_PART ; Shift edilecek sayiyi tut
            
            LDD #0
            STD INT_NUM
                       
            JSR INT_SHIFTER  ; sayiyi kaydýr
                
GO_NEXT2:    
            LDD INT_NUM ; eski sayiyi al
            ADDD ITEM1 ; carpilan sayiya karakteri ekle
            STD N2I                        
            
            LDAA INDEX  ; indexi arttýr
            INCA
            STAA INDEX
            INX ; dizi indexini arttýr
            BRA READ_INT_PART2 ; nokta gorene kadar bu dondu dönecek
            
READ_2_DONE:RTS  ; bitir
                        

READ_DEC_PART2:
            LDAA 0,X
            SUBA #$30
            
            INX ; sýradaki karakteri al
            
            STAA DEC_PART
            
            LDAA #0
            STAA DEC_NUM
                        
            LDAA #10
            STAA SHIFT_SIZE
            
            JSR  DEC_SHIFTER            
            LDAA  DEC_NUM
            
            LDAB  0,X
            CMPB #$3D ; " " space check
            BEQ READ_DEC_PART2_END
            CMPB #$20 ; " " space check
            BEQ READ_DEC_PART2_END
            
            SUBB #$30
            ABA
            INX
             
READ_DEC_PART2_END:
            STAA N2D
            RTS


;SUBROUTINE: This routine multiplies an extended integer(16 bit) with *10
; 2222 * 10 = 2220
;
; Saves value in the INT_NUM            
INT_SHIFTER:
            LDAA SHIFT_SIZE ;
            BEQ INT_SHIFTER_DONE ; branch if shift size zero
            
            DECA ; decrement size
            STAA SHIFT_SIZE ; store size
            
            LDD INT_NUM; load number
            ADDD INT_PART; D = D + PART
            STD INT_NUM; N1I = D
            BRA INT_SHIFTER
           
INT_SHIFTER_DONE: RTS


;SUBROUTINE: This routine multiplies an integer(8 bit) with *10
; 22 * 10 = 220
;
; Saves value in the INT_NUM
DEC_SHIFTER:
            LDAA SHIFT_SIZE
            BEQ DEC_SHIFTER_DONE
            
            DECA
            STAA SHIFT_SIZE
            LDAA DEC_NUM   ; decimal parttan sayiyi al
            ADDA DEC_PART    ; carpilacak sayiyi ekle
            STAA DEC_NUM   ; parti guncelle
            BRA DEC_SHIFTER                  
DEC_SHIFTER_DONE: RTS


END:  ; I will jump here to finish program
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
