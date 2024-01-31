EXTRN  points:byte
  EXTRN  items:byte
  EXTRN  items_x:WORD
  EXTRN   items_y:WORD
  EXTRN   items_type:byte ; 0 horizontal-obs 1 vertical-obs 2 powerup 3 hidden
  EXTRN   counter:byte
  PUBLIC drawItems
  road_part_length    equ 35
  .model HUGE
.code
drawpower proc
mov  ah,0ch
mov  al,09h ;start color to range from light blue to 
add  al,byte ptr [bx]
sub  al,2

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
mov dx,[di]  ; reset to the midpoint
sub dx,1
drawrightline:
int 10h
inc dx
dec bh
jnz drawrightline 

inc cx
mov dx,[di]
int 10h ; draw last right pixel
; drawing star left line 1
sub cx,3 
mov bh,3
mov dx,[di]  ; reset to the midpoint
sub dx,1
drawleftline:
int 10h
inc dx
dec bh
jnz drawleftline
dec cx
mov dx,[di]
int 10h ; draw last left pixel

ret
   
drawpower endp


drawItems proc far
mov bl,items
mov counter,bl
mov si,offset items_x
mov di,offset items_y
mov bx,offset items_type


drawloop:
mov cx,[si]
mov dx,[di]
push bx
cmp byte ptr [bx],7 ; ignore item donnot drawit
je next
sub dx,2 ; move from center 2 pixels up
cmp byte ptr [bx],6 ; hide the item
mov  ah,0ch
mov  al,0Fh
JE hideit_
add dx,2

cmp byte ptr [bx],2
JGE drawpowerup ; power obs types are 2,3,4,5

cmp byte ptr [bx],1
mov  ah,0ch
mov  al,02h
mov bl,2 ; make the obstacle 2 pixels thick
JE  drawvertical
JNE drawhorizontal

drawhorizontal:
mov cx,[si]
sub cx,3
mov bh,5
drawhh:
int  10h
inc cx
dec bh
JNZ drawhh
inc dx
dec bl
JNZ drawhorizontal
JMP next

jmp rt
drawloop0: jmp drawloop
rt:

drawvertical:
mov dx,[di]
sub dx,3
mov bh,5
drawwv:
int  10h
inc dx
dec bh
JNZ drawwv
inc cx
dec bl
JNZ drawvertical 
JMP next

drawpowerup:
call drawpower
JMP next

hideit_:
mov bl,5 ; draw a box with 5 pixels height
hideit:
mov cx,[si]
sub cx,2
mov bh,5
drawHideWidth:
int  10h
inc cx
dec bh
JNZ drawHideWidth
inc dx
dec bl
JNZ hideit

next:
add si,2
add di,2
pop bx
cmp al,0Fh ; hide color
jne skipignore
mov byte ptr [bx],7 ; ignore it next time
skipignore:
inc bx
dec counter
JNZ drawloop0

ret
drawItems endp
end
