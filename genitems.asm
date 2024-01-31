  EXTRN  points:byte
  EXTRN  road_x:WORD
  EXTRN   road_y:WORD
  EXTRN   items:WORD
  EXTRN   items_x:WORD
  EXTRN   items_y:WORD
  EXTRN   items_type:byte ; 0 horizontal-obs, 1-vertical-obs 2-powerup 3-hidden 4-ignore
  EXTRN   counter:byte
  EXTRN   movedownflag:byte
  PUBLIC generateItems
  .model HUGE
  .data
  half_road_width     equ 7
  road_width          equ  18
  road_part_length    equ 35
  maxpoints equ 60
  rand1               DW 0 
  rand2               DW 0
.code

defineType proc
push dx
push cx
cmp al,2   
JL escapesettingobs ; if last time it was obs i.e less than 2 then make it power up this time
mov al,bl  ;set it the obs type sent in bl
jmp nex
escapesettingobs:
; make random power up type
; generates random types from 2 to 5
mov  ah,2ch 
int  21h
mov  al,dl
mov  ah,0
mov  bh,4 ; 4 power up types
div  bh                      ;get reminder of dl in ah (0 upto 3)
mov al,2
add al,ah ; add the remainder to al 

nex:
pop cx
pop dx
ret
defineType endp


generateItems proc far
mov ax,@DATA
mov ds,ax    
mov si,offset road_x
mov di,offset road_y
add si,2   ; escape first point 
add di,2   ; escape first point
mov bl,points 
mov counter,bl
sub counter,2  ; make it (points - 2) times
mov al,2   ; 0-1 make first item on track power up 2 make first item obstacle

itemsloop:
push ax

MOV CX, 0H       ; High word of delay time
                MOV DX, 0FFFFH    ; Low word of delay time (3500 in hexadecimal)
                MOV AH, 86H     ; BIOS Wait function
                INT 15H          ; Call BIOS interrupt 15H

mov  ah,2ch
int  21h
mov  al,dl
mov  ah,0
mov  bh,road_width
sub  bh,9
div  bh    ;get reminder of dl in ah (0 - (road width - twice the item width))
mov al,ah  
mov ah,0                   
mov rand1,ax 
mov  ah,2ch
int  21h
mov  al,dl
mov  ah,0
mov  bh,10 ; put half road part length after removing half road width (15px)
div  bh                      ;get reminder of dl in ah (0 upto half road part length)
mov al,ah  
mov ah,0                   
mov rand2,ax
pop ax

mov movedownflag,0
mov dx,[di+2]
cmp [di],dx       ; compare with the next y coordinate (word)
JL  setmovedown
jmp escapemovedownset
setmovedown:
mov movedownflag,1
escapemovedownset:
mov cx,[si+2]  ;get the next x coordinate
cmp [si],cx    ;compare it with the current
mov cx,[si]
mov dx,[di]
push si
push di
JE  generatevertical
JNE generatehorizontal

itemsloop_:
jmp itemsloop

generatevertical:         ; this means this road part is vertical
mov bl,0  ; make the type obstacle horizontal 
call defineType
sub cx,half_road_width
add cx,5   ; make a gap 5 pixel between x and road border (cx is the midpoint of road)
add cx,rand1 ; add the generated random value to position the obstacle
cmp movedownflag,1
JE  movedown
sub dx,rand2  ; go up
jmp escapemovedown
movedown:
add dx,rand2  ; go down
escapemovedown:
JMP next

generatehorizontal:      ; this means this road part is horizontal
mov bl,1  ; make the type obstacle vertical 
call defineType
sub dx,half_road_width
add dx,5  ; make a gap 5 pixel between y and road border (dx is the midpoint of road)
add dx,rand1
add cx,rand2
next:
mov si,offset items_x
mov di,offset items_y
mov bx,offset items_type
add si,items     ; add two times to move by words
add si,items
add di,items     ; add two times to move by words
add di,items
add bx,items
mov [si],cx  ; save the generated data
mov [di],dx  ; save the generated data
mov [bx],al  ; save the generated data
pop di
pop si        ;go to next road points
add si,2
add di,2
inc items
dec counter
JNZ itemsloop_


ret

generateItems endp

end