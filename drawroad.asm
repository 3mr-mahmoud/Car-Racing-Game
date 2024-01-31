  EXTRN  points:byte
  EXTRN  road_x:WORD
  EXTRN   road_y:WORD
  EXTRN   counter:byte
  EXTRN   movedownflag:byte
  PUBLIC drawRoad
  half_road_width     equ  9
  road_width          equ  18
  road_part_length    equ 35
  .model HUGE
.code
defineFinishLineColor proc
cmp bl,1            ; make last iteration draw finish line
JNE normalcolor

cmp counter,5
JG firstpart

cmp bh,5
jle  drawstriped
cmp bh,10
jle  normalcolor
cmp bh,15
jle  drawstriped
cmp bh,20
jle  normalcolor
cmp bh,25
jle  drawstriped
jmp normalcolor

firstpart:
cmp counter,10
JG normalcolor
JE drawstriped

cmp bh,5
jle  normalcolor
cmp bh,10
jle  drawstriped
cmp bh,15
jle  normalcolor
cmp bh,20
jle  drawstriped
cmp bh,25
jle  normalcolor

drawstriped:
mov  al,04h
ret

normalcolor:
mov  al,0fh 
ret
defineFinishLineColor endp


drawRoad proc far

mov si,offset road_x
mov di,offset road_y

mov bl,points
dec bl  ; make it (points - 1) times

drawloop:
mov counter,road_part_length+half_road_width
mov movedownflag,0
mov dx,[di+2]
cmp [di],dx
JL  setmovedown
jmp escapemovedownset
setmovedown:
mov movedownflag,1
escapemovedownset:
mov cx,[si+2]  ;get the next x coordinate
cmp [si],cx    ;compare it with the current
mov cx,[si]
mov dx,[di]
mov  ah,0ch
mov  al,0fh
JE  drawvertical
JNE drawhorizontal



drawvertical:
cmp movedownflag,1
JE drawverticalloop ; make it draw one more pixel if it's going up
inc counter
drawverticalloop:
mov cx,[si]
sub cx,half_road_width
mov bh,road_width
drawwv:
call defineFinishLineColor
int  10h
inc cx
dec bh
JNZ drawwv
cmp movedownflag,1
JE  movedown
dec dx
jmp escapemovedown
movedown:
inc dx
escapemovedown:
dec counter
JNZ drawverticalloop
JMP next

drawloop_:
jmp drawloop

drawhorizontal:
mov dx,[di]
sub dx,half_road_width
mov bh,road_width
drawhh:
call defineFinishLineColor
int  10h
inc dx
dec bh
JNZ drawhh
inc cx
dec counter
JNZ drawhorizontal
next:
add si,2
add di,2
dec bl
JNZ drawloop_

ret

drawRoad endp


end