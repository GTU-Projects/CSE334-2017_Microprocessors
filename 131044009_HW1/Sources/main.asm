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
INDEX1:     DC.B 0; index for integer part1
SHIFT_AMT:  DC.B 0; shift amount
SHIFT_CON:  DC.W 0; shift CONSTANT

ITEM1:      DC.B 0; cast edilen sayi
ITEM2:      DC.B 0; cast edilen sayi devamý



            ORG EQU_START
            FCC "188.52 - 58647.13="
            


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
                     

            LDX #EQU_START ; regX = #$1200
            
            CLRA
            STAA INDEX1; set integer part1 index
            
            
            JSR READ_UNTIL_DOT1
            
            BRA END
            
            
            


READ_UNTIL_DOT1:

            LDAA 0,X
            
            CMPA #$2E ; if find '.'
            BEQ READ_1_DONE        

            SUBA #$30 ; char to integer
            
            STAA ITEM2 ; store integer to memory
            
            LDAA INDEX1 ; 0.indexte kaydýrmaya gerek yok
            BEQ GO_NEXT
            

            LDAA #9  ; 10la carpacaz
            STAA SHIFT_AMT ; kac ile carpilacak yukle
            LDD N1I
            STD SHIFT_CON            
            JSR SHIFT_NUMBER  ; sayiyi kaydýr
            
            
            
GO_NEXT:    
            LDD N1I ; eski sayiyi al
            ADDD ITEM1 ; carpilan sayiya karakteri ekle
            STD N1I                        
            
            LDAA INDEX1  ; indexi arttýr
            INCA
            STAA INDEX1
            INX ; dizi indexini arttýr
            BRA READ_UNTIL_DOT1 ; nokta gorene kadar bu dondu dönecek
            
READ_1_DONE:RTS  ; bitir
            
            
SHIFT_NUMBER:
 
            LDAA SHIFT_AMT
            BEQ SHIFT_DONE ; branch if shift zero
            
            DECA ; decrement amount
            STAA SHIFT_AMT ; store amount
            
            LDD N1I  ; load number
            ADDD SHIFT_CON ; D = D + NUMBER
            STD N1I  ; N1I = D
            BRA SHIFT_NUMBER
           
SHIFT_DONE: RTS
            

            


 END:

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
