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
SHIFT_SIZE: DC.B 0; shift edilecek basamak
SHIFT_NUM:     DC.W 0; shift edilecek sayi

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
            STAA SHIFT_SIZE ; kac ile carpilacak yukle
            LDD N1I
            STD SHIFT_NUM ; Shift edilecek sayiyi tut           
            JSR SHIFTER_FUNC  ; sayiyi kaydýr
                
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
            
            
SHIFTER_FUNC:
            LDAA SHIFT_SIZE ;
            BEQ SHIFTER_DONE ; branch if shift size zero
            
            DECA ; decrement size
            STAA SHIFT_SIZE ; store size
            
            LDD N1I  ; load number
            ADDD SHIFT_NUM ; D = D + NUMBER
            STD N1I  ; N1I = D
            BRA SHIFTER_FUNC
           
SHIFTER_DONE: RTS
            

            


 END:

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
