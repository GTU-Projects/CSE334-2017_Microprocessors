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

INT_PART    DC.W 0; 10 ile carpim sonuclarýnýn yazýlacagý yer
INT_NUM     DC.W 0; 10 ile carpilacak int sayi

DEC_PART    DC.B 0; 10 ile carpim sonuclarýnýn yazýlacagý yer
DEC_NUM     DC.B 0; 10 ile carpilacak decimal sayi

OPERATOR    DC.B 0;



            ORG EQU_START
            FCC "58647.52 - 58647.13="
            


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
                     

 
            LDX #EQU_START ; regX = #$1200
            
            CLRA
            STAA INDEX1; set integer part1 index
            
            
            ;LDX #$1204
            ;LDAA 0,X
            JSR READ_INT_PART1
            INX
            JSR READ_DEC_PART1
            INX
            INX
            LDAA 0,X
            STAA OPERATOR
            INX
            INX
            
            CLRA
            STAA ITEM1
            STAA ITEM2
            STAA INDEX1
            
            JSR READ_INT_PART2
            INX
            JSR READ_DEC_PART2
            
            CALL END
            


READ_INT_PART1:

            LDAA 0,X
            
            CMPA #$2E ; if find '.'
            BEQ READ_1_DONE        

            SUBA #$30 ; char to integer
            
            STAA ITEM2 ; store integer to memory
            
            LDAA INDEX1 ; 0.indexte kaydýrmaya gerek yok
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
            
            LDAA INDEX1  ; indexi arttýr
            INCA
            STAA INDEX1
            INX ; dizi indexini arttýr
            BRA READ_INT_PART1 ; nokta gorene kadar bu dondu dönecek
            
READ_1_DONE:RTS  ; bitir
            
            
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
            SUBB #$30
            
            ABA 
            STAA N1D
            RTS
            
            
            
READ_INT_PART2:
            
            LDAA 0,X
            
            CMPA #$2E ; if find '.'
            BEQ READ_2_DONE        

            SUBA #$30 ; char to integer
            
            STAA ITEM2 ; store integer to memory
           
            STAA INDEX1
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
            
            LDAA INDEX1  ; indexi arttýr
            INCA
            STAA INDEX1
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
            SUBB #$30
            
            ABA 
            STAA N2D
            RTS








END:
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
