  EXTRN  points:BYTE
  EXTRN  road_x:WORD
  EXTRN   road_y:WORD
  EXTRN   items:WORD
  EXTRN   items_x:WORD
  EXTRN   items_y:WORD
  EXTRN   items_type:byte
  EXTRN   movedownflag:byte
  EXTRN   chosen_points:byte
  EXTRN   chosen_points_arr:byte
  EXTRN   sendData:BYTE
  EXTRN   receivedData:BYTE
  EXTRN   SEND:FAR
  EXTRN   RECEIVE:FAR
  PUBLIC randPower
  .model HUGE
  .stack 256
  .data
  half_road_width     equ 7
  road_width          equ  18
  road_part_length    equ 35
  generatedPower        equ 1
  maxpoints equ 60
  rand1               DW 0 
  rand2               DW 0
.code
randPower proc far
mov ax,@DATA
mov ds,ax
 ; mark last point as chosen
mov si,offset chosen_points_arr
mov ah,0
mov al,points
add si,ax
dec si
mov byte ptr [si],1
 ; mark last point as chosen
mov al,points
cmp chosen_points,al
JNE  continue
ret
continue:
  
mov  ah,2ch
int  21h
mov  al,dl
mov  ah,0
mov  bh,road_width
sub bh,9
div  bh    ;get reminder of dl in ah (0 - (road width - twice the power up width+1))
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


random:  ; select a random point
mov si,offset road_x
mov di,offset road_y
add si,2   ; escape first point 
add di,2   ; escape first point

mov  ah,2ch
int  21h
mov  al,dl
mov  ah,0

mov  bh,points   ;excluding first point and last point
sub bh,2
div  bh    ;get reminder of dl in ah (0- (maxpoints-2))
mov bx, offset chosen_points_arr+1 ; escape first point
mov al,ah  
mov ah,0
mov cl,points
mov ch,0
lea dx,chosen_points_arr  
add dx,cx
dec dx ; get address of last element
add bx, ax ; add to pointer the random value to move bytes
mov cx,5 ; check the next 5
check5:
cmp bx,dx
je random ; if reached last element go to select another random index
cmp byte ptr [bx],0  
JE cont ; if point is not chosen continue doing the procedure
inc bx
add si,2
add di,2
loop check5
jmp random

cont:
mov byte ptr [bx],1 ; set this point as chosen
inc chosen_points
add si,ax  ; add two times to move by words
add si,ax
add di,ax
add di,ax

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
JE  generatevertical
JNE generatehorizontal


generatevertical:         ; this means this road part is vertical

sub cx,half_road_width
add cx,5   ; make a gap 5 pixel between x and road border (cx is the midpoint of road)
add cx,rand1 ; add the generated random value to position the obstacle
cmp movedownflag,1
JE  movedown
sub dx,10   ; add 10 to make sure it never collides with the first section of this road part
sub dx,rand2  ; go up
jmp escapemovedown
movedown:
add dx,10     ; add 10 to make sure it never collides with the first section of this road part
add dx,rand2  ; go down
escapemovedown:
JMP next

generatehorizontal:      ; this means this road part is horizontal

sub dx,half_road_width
add dx,5  ; make a gap 5 pixel between y and road border (dx is the midpoint of road)
add dx,rand1
add cx,10  ; add 10 to make sure it never collides with the first section of this road part
add cx,rand2
next:
mov si,offset items_x
mov di,offset items_y

add si,items     ; add two times to move by words
add si,items
add di,items     ; add two times to move by words
add di,items
mov [si],cx  ; save the generated data
mov [di],dx  ; save the generated data

; generates random types from 2 to 5
mov  ah,2ch 
int  21h
mov  al,dl
mov  ah,0
mov  bh,4 ; 4 power up types
div  bh                      ;get reminder of dl in ah (0 upto 3)
mov al,2
add al,ah ; add the remainder to al 
mov bx,offset items_type
add bx,items
mov byte ptr [bx],al  ; save the generated data
inc items

ret

randPower endp

end