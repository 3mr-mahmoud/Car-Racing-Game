EXTRN x1_Car1:WORD
EXTRN x1_Car2:WORD
EXTRN y1_Car1:WORD
EXTRN y1_Car2:WORD
EXTRN score1:BYTE
EXTRN score2:BYTE
EXTRN  points:BYTE
EXTRN  road_x:WORD
EXTRN  road_y:WORD
EXTRN  generateGameData:BYTE
public updateProgress
.model HUGE
.data
  counter DB 0
  movedownflag       DB  0 
  Xsub             DW  0
  _Xadd               DW  0
  Ysub             DW  0
  Yadd               DW  0
  half_road_width     equ 9
  road_width          equ  18
  road_part_length    equ 35
.code
defineCheckSize proc
mov bl,points
dec bl
cmp counter,bl
je  skipcheck
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
JE  checkvertical
JNE checkhorizontal

checkvertical:
mov _Xadd,half_road_width
mov Xsub,half_road_width
cmp movedownflag,1
je  downCheckSize
mov Yadd,half_road_width
mov Ysub,road_part_length
jmp skipdown
downCheckSize:
mov Yadd,road_part_length
mov Ysub,half_road_width
skipdown:
jmp skipcheck


checkhorizontal:
mov Yadd,half_road_width
mov Ysub,half_road_width
mov _Xadd,road_part_length
mov Xsub,half_road_width

skipcheck: 
ret
defineCheckSize endp


updateProgress proc far
mov ax,@DATA
mov ds,ax

mov counter,0
mov si,offset road_x
mov di,offset road_y 

loopoverpts1:
call defineCheckSize    
mov cx,[si]
sub cx,Xsub
cmp  x1_Car1,cx
jl   next1
mov cx,[si] ; reset
add cx,_Xadd
cmp  x1_Car1,cx
jg   next1

mov cx,[di]
sub cx,Ysub
cmp  y1_Car1,cx
jl   next1
mov cx,[di] ;reset
add cx,Yadd
cmp  y1_Car1,cx
jg   next1


jmp finsih1


next1:
inc counter
add si,2
add di,2
mov bl,counter
cmp bl,points
jne loopoverpts1

finsih1:
mov ah,0
mov al,counter
mov cl,100
mul cl
mov bl,points
div bl
cmp al,0
je skipset1

cmp generateGameData,0
je  setAsScore2
mov score1,al
jmp skipset1
setAsScore2: mov score2,al
skipset1:

mov counter,0
mov si,offset road_x
mov di,offset road_y


loopoverpts2:
call defineCheckSize    
mov cx,[si]
sub cx,Xsub
cmp  x1_Car2,cx
jl   next2
mov cx,[si] ; reset
add cx,_Xadd
cmp  x1_Car2,cx
jg   next2

mov cx,[di]
sub cx,Ysub
cmp  y1_Car2,cx
jl   next2
mov cx,[di] ;reset
add cx,Yadd
cmp  y1_Car2,cx
jg   next2


jmp finsih2


next2:
inc counter
add si,2
add di,2
mov bl,counter
cmp bl,points
jne loopoverpts2

finsih2:
mov ah,0
mov al,counter
mov cl,100
mul cl
mov bl,points
div bl
cmp al,0 
je skipset2

cmp generateGameData,0
je  setAsScore1
mov score2,al
jmp skipset2
setAsScore1: mov score1,al
skipset2:
ret 
updateProgress  endp

end