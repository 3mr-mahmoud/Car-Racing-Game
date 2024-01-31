INCLUDE macros.inc

EXTRN countSeconds:BYTE
EXTRN countMinutes:BYTE
EXTRN playerPoints1:BYTE
EXTRN playerPoints2:BYTE
EXTRN x1_Car1:WORD
EXTRN y1_Car1:WORD
EXTRN score1:BYTE
EXTRN score2:BYTE
EXTRN Name1:BYTE
EXTRN Name2:BYTE
EXTRN powerType1:BYTE
EXTRN powerType2:BYTE
EXTRN seconds:BYTE
EXTRN calledstatusbefore:BYTE
EXTRN FinishTime:BYTE
EXTRN ClearGamerOver:BYTE
EXTRN LeftDigit:BYTE
EXTRN RightDigit:BYTE
EXTRN TimeIsFinsihed:BYTE

EXTRN generateGameData:BYTE
public drawStatusBar,CHAR,printChatChar1,printChatChar2
.model HUGE
.stack 256h
.data
    ;FinishTime     db "Game Over$"
    ;ClearGamerOver db "         $"
     chatY    equ 23 
     cursor1X    equ 3
     cursor2X    equ 23
     c1Size     db 0
     c2Size     db 0
     CHAR       db ?
     maxSize   equ   15
     emptystring  db maxSize dup(" "),"$"
    score       db "Score:",'$'
.code

printChatChar1 proc far
mov ax,@data
mov ds,ax
                   cmp CHAR,8
                   jne skipbackspace1
                   cmp c1Size,0
                   jz  exit_1
                   dec c1Size
                   mov     bh,0
                   mov     ah,2
                   mov     dl,cursor1X
                   add dl,c1Size
                   mov     dh,chatY
                   int     10h
                   mov dl,' '
                   mov ah, 2
                   int 21h
             exit_1:  
                ret
skipbackspace1:   cmp   CHAR,13
                  je   clear1
                  cmp c1Size,maxSize
                  jne   skipclear1
   clear1:              

                   mov     bh,0
                   mov     ah,2
                   mov     dl,cursor1X
                   mov     dh,chatY
                   int     10h
                  showmes emptystring
                  mov c1Size,0
                  cmp   CHAR,13
                  jne   skipclear1
                  ret
skipclear1:
                   mov     bh,0
                   mov     ah,2
                   mov     dl,cursor1X
                   add     dl,c1Size
                   mov     dh,chatY
                   int     10h
                   mov dl,CHAR
                   mov ah, 2
                   int 21h
                   inc c1Size

ret
printChatChar1 endp

printChatChar2 proc far
mov ax,@data
mov ds,ax
                   cmp CHAR,8
                   jne skipbackspace2
                   cmp c2Size,0
                   jz  exit_2
                   dec c2Size
                   mov     bh,0
                   mov     ah,2
                   mov     dl,cursor2X
                   add     dl,c2Size
                   mov     dh,chatY
                   int     10h
                   mov dl,' '
                   mov ah, 2
                   int 21h
     exit_2:              
                ret
skipbackspace2:   cmp   CHAR,13
                  je   clear2
                  cmp c2Size,maxSize
                  jne   skipclear2
   clear2:   
                   mov     bh,0
                   mov     ah,2
                   mov     dl,cursor2X
                   mov     dh,chatY
                   int     10h
                  showmes emptystring
                  mov c2Size,0
                  cmp   CHAR,13
                  jne   skipclear2
                  ret
skipclear2:
                   mov     bh,0
                   mov     ah,2
                   mov     dl,cursor2X
                   add     dl,c2Size
                   mov     dh,chatY
                   int     10h
                   mov dl,CHAR
                   mov ah, 2
                   int 21h
                   inc c2Size

ret
printChatChar2 endp

drawpower proc
mov  ah,0ch
cmp byte ptr [bx],0 ; if powerType is zero set to black i.e no power up
mov al,0
je  skipcolorset
mov  al,09h ;start color to range from light blue to Light Magenta
add  al,byte ptr [bx]
sub  al,2
skipcolorset:

; drawing star center line
mov bh,5
sub dx,2
drawcenter:
int 10h
inc dx
dec bh
jnz drawcenter
; drawing star right line 1
inc cx
mov bh,3
sub dx,3  ; reset to the midpoint
sub dx,1
drawrightline:
int 10h
inc dx
dec bh
jnz drawrightline 

inc cx
sub dx,2 ; reset to the midpoint
int 10h ; draw last right pixel
; drawing star left line 1
sub cx,3 
mov bh,3
sub dx,1
drawleftline:
int 10h
inc dx
dec bh
jnz drawleftline
dec cx
sub dx,2 ;reset to midpoint
int 10h ; draw last left pixel


ret
   
drawpower endp



drawStatusBar proc far

                   mov     ax,@data
                   mov     ds,ax

    cmp calledstatusbefore,1
    je skipinitialdrawings
    mov calledstatusbefore,1
    
    ;---------------------------------------Screen Coloring------------------------------------------------;
               
    ;--------------------------------------status-----------------------------------------------------------;
   
                   ; mov     ah, 2ch
                   ;int     21h
                   ;mov     seconds, dh
                   ;mov calledstatusbefore,1
    drawStatus:                                ;starting from row 171
                   mov     ax, 0A000h
                   mov     es,ax
                   mov     di,51520
                   mov     al,0fh
                   mov     cx,320
                   rep     stosb

                mov     ax, 0A000h
                   mov     es,ax
                   mov     di,51840
                   mov     al,0h
                   mov     cx,8960
                   rep     stosb


            
                 mov     bh,0
                   mov     ah,2
                   mov     dl,3
                   mov     dh,21
                   int     10h

                   showmes Name1

                   mov     bh,0
                   mov     ah,2
                   mov     dl,29
                   mov     dh,21
                   int     10h
                
                   showmes Name2
                        
skipinitialdrawings:

                   cmp     countMinutes,0
                   jnz     MinutesGreater
                   cmp     countSeconds,0
                   jne      MinutesGreater
                   jmp TimeEnd
    MinutesGreater:
                   mov     ah, 2ch
                   int     21h
                   cmp     dh, seconds

                   

                   jne      skip
                   
                    ret
                   skip:
                    
                   

                   mov     seconds, dh
                   mov     ah, 2
                   mov     dl, countSeconds
               
                   cmp     countSeconds,0
                   jne     continue
                   mov     countSeconds,59
                   dec     countMinutes
  
               
    continue:    
                  
                   cmp generateGameData,1
                   je  take1
                   lea bx, powerType2
                   jmp skiptake1
   take1:          lea bx, powerType1
   skiptake1:      mov cx,90
                   mov dx,172
                   call drawpower

                   

                   mov dx,178
                   mov  ah,0ch
                   mov cx,20
                   mov bl,100
                    mov  al,00
                   drawscore1back:
                    int 10h
                    inc cx
                    dec bl
                    jnz drawscore1back
                    mov cx,20
                    cmp score1,0
                    je skipdraw1
                    mov bl,score1
                    mov  al,0FH
                    drawscore1:
                    int 10h
                    inc cx
                    dec bl
                    jnz drawscore1
skipdraw1:
                   
                   
                   cmp generateGameData,1
                   je  take2
                   lea bx, powerType1
                   jmp skiptake2
   take2:          lea bx, powerType2
   skiptake2:      mov cx,300
                   mov dx,172
                   call drawpower

mov dx,178
                   mov  ah,0ch
                   mov cx,220
                   mov bl,100
                    mov  al,00
                   drawscore2back:
                    int 10h
                    inc cx
                    dec bl
                    jnz drawscore2back
                    mov cx,220
                    cmp score2,0
                    je skipdraw2
                    mov bl,score2
                    mov  al,0FH
                    drawscore2:
                    int 10h
                    inc cx
                    dec bl
                    jnz drawscore2
skipdraw2:

                    jmp     twoDigit
    
    twoDigit:      
               
                   mov     bh,0
                   mov     ah,2
                   mov     dl,18
                   mov     dh,20
                   int     10h
               
                   mov     dl,48
                   int     21h
                   mov     dl,countMinutes
                   add     dl,48
                   int     21h
               
                   mov     dl,58
                   int     21h
               
              
                   mov     ah,0
                   mov     al,countSeconds
                   mov     bl,10
                   div     bl
  
                   mov     LeftDigit,al
                   mov     RightDigit,ah
                   add     LeftDigit,48        ;leftDigit  Ascii
                   add     RightDigit,48       ;rightDigit Ascii
                
                   mov     dl,LeftDigit
                   mov     ah,2
                   int     21h
               
  
                   mov     dl,RightDigit
                   mov     ah,2
                   int     21h
                   dec     countSeconds
                   ret
               
                   
              
               
    TimeEnd:       
                   mov     bh,0
                   mov     ah,2
                   mov     dl,18
                   mov     dh,20
                   int     10h
               
                   mov     dl,48
                   int     21h
                   mov     dl,countMinutes
                   add     dl,48
                   int     21h
               
                   mov     dl,58
                   int     21h
               
                   mov     dl,48
                   int     21h
               
                   mov     dl, countSeconds
                   add     dl,48
                   int     21h
                    mov TimeIsFinsihed,1
                   ret
drawStatusBar endp






end