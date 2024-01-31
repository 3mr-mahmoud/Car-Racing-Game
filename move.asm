INCLUDE macros.inc

EXTRN CHAR:BYTE
EXTRN printChatChar2:FAR

EXTRN items:WORD
EXTRN items_x:WORD
EXTRN items_y:WORD
EXTRN items_type:BYTE

EXTRN x1_Car1:WORD
EXTRN x2_Car1:WORD
EXTRN y1_Car1:WORD
EXTRN y2_Car1:WORD
EXTRN speed_Car1:WORD
EXTRN color_Car1:BYTE
EXTRN left_Car1:BYTE
EXTRN right_Car1:BYTE
EXTRN up_Car1:BYTE
EXTRN down_Car1:BYTE
EXTRN genObs_Car1:BYTE
EXTRN passObs_Car1:BYTE
EXTRN receivedMove:BYTE
EXTRN sentMove:BYTE


EXTRN x1_Car2:WORD
EXTRN x2_Car2:WORD
EXTRN y1_Car2:WORD
EXTRN y2_Car2:WORD
EXTRN speed_Car2:WORD
EXTRN color_Car2:BYTE
EXTRN left_Car2:BYTE
EXTRN right_Car2:BYTE
EXTRN up_Car2:BYTE
EXTRN down_Car2:BYTE
EXTRN genObs_Car2:BYTE
EXTRN passObs_Car2:BYTE
EXTRN pressedF4:BYTE

EXTRN x1_CarTemp:WORD
EXTRN x2_CarTemp:WORD
EXTRN y1_CarTemp:WORD
EXTRN y2_CarTemp:WORD
EXTRN speed_CarTemp:WORD
EXTRN color_CarTemp:BYTE
EXTRN left_CarTemp:BYTE
EXTRN right_CarTemp:BYTE
EXTRN up_CarTemp:BYTE
EXTRN down_CarTemp:BYTE
EXTRN powerTypeTemp:BYTE
EXTRN genObs_CarTemp:BYTE
EXTRN passObs_CarTemp:BYTE
EXTRN prevState_passObsTemp:BYTE
EXTRN curState_CarTemp:BYTE


EXTRN nearest_x_power:WORD
EXTRN nearest_y_power:WORD
EXTRN check_center_car:BYTE


EXTRN check_if_color:BYTE
EXTRN flag_direction_temp:BYTE
PUBLIC moveCar,check_move,item_color
PUBLIC xc_Car,yc_Car,culc_center_of_car

public receive_move

EXTRN CAR:FAR

EXTRN SEND:FAR
EXTRN sendData:BYTE


EXTRN generateGameData:BYTE

EXTRN send_powerUps:FAR
EXTRN receive_powerUps:FAR

.model HUGE  
.data
item_color      DB      0
;you must select number of car move  1->car_1  2->car_2
check_call_from_car_color db ?
color_car_to_check db ?
x_car   DW    ?
y_car   DW     ?
position_power_to_car db ?        ;0->up 1->down 2->left 3->right
power_x         DW ?       ;current x-coord to power up
power_y         DW ?       ;current y-coord to power up

xc_Car  dw ?
yc_Car  dw ?
haight_car equ 3
width_car equ 2
pev_x1 dw ?
pev_x2 dw ?
pev_y1 dw ?
pev_y2 dw ?

color_pav equ 8
.code

add_obstacle    proc far
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
inc items
ret
add_obstacle endp

check_not_white_colUD proc FAR
mov check_if_color,0
add si,1   ;y2
check_colors_loop1UD:
mov ah,0dh       
int 10h         ; get color of pixel in CX,DX (al = color)
cmp al,0fh
jnz return_not_white1UD
inc dx  ;y1
cmp dx,si
jnz check_colors_loop1UD
ret
return_not_white1UD: mov check_if_color,1
mov item_color,al
ret
check_not_white_colUD endp

check_not_white_colDU proc FAR
mov check_if_color,0
sub si,1
check_colors_loop1DU:
mov ah,0dh
int 10h         ; get color of pixel in CX,DX (al = color)
cmp al,0fh
jnz return_not_white1DU
dec dx
cmp dx,si
jnz check_colors_loop1DU
ret
return_not_white1DU: mov check_if_color,1
mov item_color,al
ret
check_not_white_colDU endp

check_not_white_rowLR proc FAR
mov check_if_color,0
add si,1
check_colors_loop2LR:
mov ah,0dh
int 10h         ; get color of pixel in CX,DX (al = color)
cmp al,0fh
jnz return_not_white2LR
inc cx
cmp CX,si
jnz check_colors_loop2LR
ret
return_not_white2LR: mov check_if_color,1
mov item_color,al
ret
check_not_white_rowLR endp

check_not_white_rowRL proc FAR
mov check_if_color,0
sub si,1
check_colors_loop2RL:
mov ah,0dh
int 10h         ; get color of pixel in CX,DX (al = color)
cmp al,0fh
jnz return_not_white2RL
dec cx
cmp CX,si
jnz check_colors_loop2RL
ret
return_not_white2RL: mov check_if_color,1
mov item_color,al
ret
check_not_white_rowRL endp

;save the previus coordinate becs if i not move  
save_prev_coord proc far
mov ax,x1_CarTemp
mov pev_x1,ax
mov ax,x2_CarTemp
mov pev_x2,ax
mov ax,y1_CarTemp
mov pev_y1,ax
mov ax,y2_CarTemp
mov pev_y2,ax
ret
save_prev_coord endp

save_temp_coord proc far
mov ax,pev_x1
mov x1_CarTemp,ax
mov ax,pev_x2
mov x2_CarTemp,ax
mov ax,pev_y1
mov y1_CarTemp,ax
mov ax,pev_y2
mov y2_CarTemp,ax
ret
save_temp_coord endp

check_car_around_power_color proc FAR

mov cx,power_x
sub cx,2           ;start from above power up
mov dx,power_y
sub dx,2
mov si,power_x
add si,2

mov check_if_color,0
cmp color_CarTemp,1h
jnz not_car2
mov color_car_to_check,1h
jmp positions
not_car2:
mov color_car_to_check,6h



positions:
cmp position_power_to_car,1
jz to_down
cmp position_power_to_car,2
jz to_left
cmp position_power_to_car,3
jz to_Right

to_up:
check_colors_loop1:
mov ah,0dh      ;                        X, Y     
int 10h         ; get color of pixel in CX,DX (al = color)
cmp al,color_car_to_check
jz found_car
inc cx
cmp cx,si
jnz check_colors_loop1
ret
found_car: mov check_if_color,1
mov item_color,al
ret

to_down:
mov cx,power_x 
sub cx,2
mov dx,power_y    ;start from down power up
add dx,2 
check_colors_loop2:
mov ah,0dh      ;                        X, Y     
int 10h         ; get color of pixel in CX,DX (al = color)
cmp al,color_car_to_check
jz found2_car
inc cx
cmp cx,si
jnz check_colors_loop2
ret
found2_car: mov check_if_color,1
mov item_color,al
ret

to_left:
mov cx,power_x 
sub cx,2
mov dx,power_y    ;start from down power up
sub dx,2
mov si,power_y
add si,2
check_colors_loop3:
mov ah,0dh      ;                        X, Y     
int 10h         ; get color of pixel in CX,DX (al = color)
cmp al,color_car_to_check
jz found3_car
inc dx
cmp dx,si
jnz check_colors_loop3
ret
found3_car: mov check_if_color,1
mov item_color,al
ret

to_Right:
mov cx,power_x 
add cx,2 
mov dx,power_y    ;start from down power up
mov si,power_y
add si,2
sub dx,2
check_colors_loop4:
mov ah,0dh      ;                        X, Y     
int 10h         ; get color of pixel in CX,DX (al = color)
cmp al,color_car_to_check
jz found4_car
inc dx
cmp dx,si
jnz check_colors_loop4
ret
found4_car: mov check_if_color,1
mov item_color,al
ret
check_car_around_power_color endp

get_power_up proc  far

    ;mov ax,@data
    mov ax,ds     
    mov es,ax

    mov di,offset items_type
    mov cx,items
    loo:
    mov al,powerTypeTemp
    REPNE SCASB
    mov bx,2
    mov ax,items 
    sub ax,cx  
    dec ax
    
    cmp cx,0
    jnz Add_past_element 
    
    ;check_past_element
    push bx 
    push cx
    mov cl,powerTypeTemp
    mov bx, offset items_type
    add bx,ax
    cmp byte ptr [bx],cl
    pop cx
    pop bx
    jnz lastt

    Add_past_element: ;not add past element only*
       
    mov si,offset items_x
    mul bl 
    add si,ax
    mov dx,[si]
    mov power_x,dx

    ;indix power I stop
    mov ax,items
    sub ax,cx  
    dec ax

    mov si,offset items_y  
    mul bl 
    add si,ax
    mov dx,[si]
    mov power_y,dx
    push ax
    push dx
    push si
    push cx
    
    jmp as
    ga1:jmp loo
    as:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    call check_car_around_power_color               ; function
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop cx
    pop si
    pop dx
    pop ax
    push si
    cmp check_if_color,1 ;hidden power up
    jnz nothidd
    ; inc powerTypeTemp
    mov ax,items
    sub ax,cx  
    dec ax
    mov si,offset items_type 
    add si,ax 
    mov byte ptr[si],6
    nothidd:
    pop si

    cmp cx,0
    jg ga1
    
    lastt:
ret
get_power_up endp


culc_center_of_car proc FAR
mov ax ,x2_CarTemp
sub ax,x1_CarTemp
mov bl,2
div bl
mov ah,0
add ax,x1_CarTemp
mov xc_Car,ax
mov ax ,y2_CarTemp
sub ax,y1_CarTemp
mov bl,2
div bl
mov ah,0
add ax,y1_CarTemp
mov yc_Car,ax
ret
culc_center_of_car endp




check_around_OR_in_CarTemp       proc  far ;check if around the car an obstacle
mov CX,x1_CarTemp
mov si,x2_CarTemp
mov DX,y1_CarTemp
dec DX
call check_not_white_rowLR    ;check above car from left to right
cmp check_if_color,1
jnz not_above_CarTemp
cmp item_color,2        ;green obstacle
jnz again_above
mov curState_CarTemp,1
ret
again_above:    
xchg cx,si
call check_not_white_rowRL
cmp item_color,2        ;green obstacle
jnz not_above_CarTemp
mov curState_CarTemp,1
ret

not_above_CarTemp:
mov CX,x1_CarTemp
mov si,x2_CarTemp
mov DX,y2_CarTemp
inc DX
call check_not_white_rowLR    ;check below car
cmp check_if_color,1
jnz not_below_CarTemp
cmp item_color,2
jnz again_below
mov curState_CarTemp,1
ret
again_below:    
xchg cx,si
call check_not_white_rowRL
cmp item_color,2        ;green obstacle
jnz not_below_CarTemp
mov curState_CarTemp,1
ret


not_below_CarTemp:
mov CX,x2_CarTemp
mov DX ,y1_CarTemp
mov si ,y2_CarTemp
inc CX
call check_not_white_colUD    ;check right car
cmp check_if_color,1
jnz not_right_CarTemp
cmp item_color,2
jnz again_right
mov curState_CarTemp,1
ret
again_right:    
xchg dx,si
call check_not_white_colDU
cmp item_color,2        ;green obstacle
jnz not_right_CarTemp
mov curState_CarTemp,1
ret


not_right_CarTemp:
mov CX,x1_CarTemp
mov DX ,y1_CarTemp
mov si ,y2_CarTemp
dec CX
call check_not_white_colUD    ;check left car
cmp check_if_color,1
jnz not_left_CarTemp
cmp item_color,2
jnz again_left
mov curState_CarTemp,1
ret
again_left:    
xchg dx,si
call check_not_white_colDU
cmp item_color,2        ;green obstacle
jnz not_left_CarTemp
mov curState_CarTemp,1
ret


not_left_CarTemp:
mov si,offset items_x
mov di,offset items_y
add si,items     ; add two times to move by words
add si,items
add di,items     ; add two times to move by words
add di,items
mov CX,items
check_itemsArray1:
mov DX,[si]
cmp DX,x1_CarTemp
jl next1
cmp DX,x2_CarTemp
jg next1
mov DX,[di]
cmp DX,y1_CarTemp
jl next1
cmp DX,y2_CarTemp
jg next1

mov curState_CarTemp,1
jmp return1

next1:
sub si,2
sub di,2
loop check_itemsArray1

mov curState_CarTemp,0
return1: 
ret
check_around_OR_in_CarTemp endp


moveCar    proc far
push ax
drawCar    x1_CarTemp,y1_CarTemp,x2_CarTemp,y2_CarTemp,color_CarTemp
call culc_center_of_car
pop ax
cmp ah,0    ;al=color,ah=direction      (0,1,2,3) -> (down,up,right,left)
jnz not_movedown
jmp moveDown
not_movedown:    cmp ah,1
jnz not_moveUp
jmp moveUp
not_moveUp:    cmp ah,2
jnz not_moveRight
jmp moveRight
not_moveRight:
jmp moveLeft

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveDown:
push ax
push dx
push si
push cx
    
mov di,speed_CarTemp
cmp di,0        ;check if speed equal = 0

jnz moveDownspeed
    pop cx
    pop si
    pop dx
    pop ax
call culc_center_of_car
call CAR
ret
moveDownspeed:
push ax
call save_prev_coord  ;save the prev coordinate
pop ax
cmp flag_direction_temp,0
jz sd
cmp flag_direction_temp,1
jz sd
mov ax,xc_Car
mov x1_CarTemp,ax
sub x1_CarTemp,width_car
mov x2_CarTemp,ax
add x2_CarTemp,width_car
mov ax,yc_Car
jmp asd
sd: jmp ready3
asd:
mov y1_CarTemp,ax
sub y1_CarTemp,haight_car
mov y2_CarTemp,ax
add y2_CarTemp,haight_car

mov dX,y1_CarTemp
mov CX ,x1_CarTemp
mov si ,x2_CarTemp
call check_not_white_rowLR
cmp item_color,color_pav
jnz ready3
add y1_CarTemp,1
add y2_CarTemp,1
ready3:

mov BX,y2_CarTemp  
inc BX

push di
call check_around_OR_in_CarTemp
pop di
mov DX,BX
mov CX ,x1_CarTemp
mov si ,x2_CarTemp

call check_not_white_rowLR

push DX
push si
push di
push BX

cmp item_color,9H      ;(blue) check power up to get it from type speed up
jnz not1_power9
mov position_power_to_car,0
mov powerTypeTemp,2
call get_power_up
jmp not1_power12

not1_power9:
cmp item_color,0AH      ;(green) check power up to get it from type speed down
jnz not1_power10
mov position_power_to_car,0
mov powerTypeTemp,3
call get_power_up
jmp not1_power12

not1_power10:
cmp item_color,0BH      ;(cyan) check power up to get it from type generate obstacle
jnz not1_power11
mov position_power_to_car,0
mov powerTypeTemp,4
call get_power_up
jmp not1_power12

not1_power11:
cmp item_color,0CH      ;(red) check power up to get it from type pass obstacle
jnz not1_power12
mov position_power_to_car,0
mov powerTypeTemp,5
call get_power_up

not1_power12:
pop bx
pop di
pop si
pop dx


push cx
mov cl,curState_CarTemp
and cl,prevState_passObsTemp       ;if prev = 1 (passing) and current = 1,there is obstacle around or in car then 
mov prevState_passObsTemp,cl
pop cx

cmp check_if_color,1
jnz can_move_down

cmp item_color,2
jz again1
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit1CarTemp
again1:
xchg cx,si
call check_not_white_rowRL
cmp item_color,2
jz skip1
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit1CarTemp

skip1:
cmp prevState_passObsTemp,0
jz no_passing_down
jmp can_move_down

no_passing_down:
cmp passObs_CarTemp,1
jz continue1
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit1CarTemp
continue1:
mov prevState_passObsTemp,1
mov passObs_CarTemp,0

can_move_down:
cmp genObs_CarTemp,1
jnz not_genObs_down    ;genObs_CarTemp = 0 (not active) not generate obstacle due to moving down CarTemp
push di
push BX
push AX
mov CX,x1_CarTemp
add CX,6             ;width car 8 pixels, mid point of obstacle after x1+3
mov dx,y1_CarTemp
mov al,0
call add_obstacle
pop AX
pop BX
pop di
mov genObs_CarTemp,0

not_genObs_down:

drawCar pev_x1,pev_y1,pev_x2,pev_y2,0fh
mov y2_CarTemp,BX
drawCar x1_CarTemp,y1_CarTemp,x2_CarTemp,BX,color_CarTemp

drawRow x1_CarTemp,x2_CarTemp,y1_CarTemp,0fh
mov BX,y1_CarTemp
inc BX
mov y1_CarTemp,BX
dec di
cmp di,0h
mov flag_direction_temp,1
jz exit1CarTemp
jmp moveDownspeed

exit1CarTemp:  
    pop cx
    pop si
    pop dx
    pop ax    
    call culc_center_of_car
    call CAR
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


moveUp:
push ax
push dx
push si
push cx
mov di,speed_CarTemp
cmp di,0        ;check if speed equal = 0

jnz moveUpSpeed
    pop cx
    pop si
    pop dx
    pop ax
call culc_center_of_car
call CAR
ret
moveUpSpeed:
push ax
call save_prev_coord  ;save the prev coordinate
pop ax
cmp flag_direction_temp,0
jz ready2
cmp flag_direction_temp,1
jz ready2
mov ax,xc_Car
mov x1_CarTemp,ax
sub x1_CarTemp,width_car
mov x2_CarTemp,ax
add x2_CarTemp,width_car
mov ax,yc_Car
mov y1_CarTemp,ax
sub y1_CarTemp,haight_car
mov y2_CarTemp,ax
add y2_CarTemp,haight_car
mov DX,y2_CarTemp
mov CX ,x1_CarTemp
mov si ,x2_CarTemp
call check_not_white_rowLR
cmp item_color,color_pav
jnz ready2
sub y1_CarTemp,1
sub y2_CarTemp,1

ready2:
mov BX,y1_CarTemp   
dec BX
push di
call check_around_OR_in_CarTemp
pop di
mov DX,BX
mov CX ,x1_CarTemp
mov si ,x2_CarTemp

call check_not_white_rowLR

push DX
push si
push di
push BX

cmp item_color,9H      ;(blue) check power up to get it from type speed up
jnz not2_power9
mov position_power_to_car,1
mov powerTypeTemp,2
call get_power_up
jmp not2_power12

not2_power9:
cmp item_color,0AH      ;(green) check power up to get it from type speed down
jnz not2_power10
mov position_power_to_car,1
mov powerTypeTemp,3
call get_power_up
jmp not2_power12

not2_power10:
cmp item_color,0BH      ;(cyan) check power up to get it from type generate obstacle
jnz not2_power11
mov position_power_to_car,1
mov powerTypeTemp,4
call get_power_up
jmp not2_power12

not2_power11:
cmp item_color,0CH      ;(red) check power up to get it from type pass obstacle
jnz not2_power12
mov position_power_to_car,1
mov powerTypeTemp,5
call get_power_up

not2_power12:
pop bx
pop di
pop si
pop dx


push cx
mov cl,curState_CarTemp
and cl,prevState_passObsTemp       ;if prev = 1 (passing) and current = 1,there is obstacle around or in car then 
mov prevState_passObsTemp,cl
pop cx

cmp check_if_color,1
jnz can_move_up
cmp item_color,2
jz again2
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit2CarTemp
again2:
xchg cx,si
call check_not_white_rowRL
cmp item_color,2
jz skip2
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit2CarTemp

skip2:
cmp prevState_passObsTemp,0
jz no_passing_up
jmp can_move_up

no_passing_up:
cmp passObs_CarTemp,1
jz continue2
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit2CarTemp
continue2:
mov prevState_passObsTemp,1
mov passObs_CarTemp,0

can_move_up:
cmp genObs_CarTemp,1
jnz not_genObs_up    ;genObs_CarTemp = 0 (not active) not generate obstacle due to moving down CarTemp
push di
push BX
push AX
mov CX,x1_CarTemp
add CX,6             ;width car 8 pixels, mid point of obstacle after x1+3
mov dx,y2_CarTemp
mov al,0
call add_obstacle
pop AX
pop BX
pop di
mov genObs_CarTemp,0
not_genObs_up:

drawCar pev_x1,pev_y1,pev_x2,pev_y2,0fh
mov y1_CarTemp,BX
drawCar x1_CarTemp,y1_CarTemp,x2_CarTemp,y2_CarTemp,color_CarTemp
mov BX,y2_CarTemp
drawRow x1_CarTemp,x2_CarTemp,BX,0fh
dec BX
mov y2_CarTemp,BX
dec di
cmp di,0h
mov flag_direction_temp,0
jz exit2CarTemp

jmp moveUpSpeed

exit2CarTemp:   
    pop cx
    pop si
    pop dx
    pop ax   
    call culc_center_of_car
    call CAR
   ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



moveRight:
push ax
push dx
push si
push cx
    
mov di,speed_CarTemp
cmp di,0        ;check if speed equal = 0

jnz moveRightSpeed
    pop cx
    pop si
    pop dx
    pop ax
call culc_center_of_car
call CAR
ret
moveRightSpeed:
push ax
call save_prev_coord  ;save the prev coordinate
pop ax
;check if change direction
cmp flag_direction_temp,2
jz ready0
cmp flag_direction_temp,3
jz ready0

mov ax,xc_Car
mov x1_CarTemp,ax
sub x1_CarTemp,haight_car
mov x2_CarTemp,ax
add x2_CarTemp,haight_car
mov ax,yc_Car
mov y1_CarTemp,ax
sub y1_CarTemp,width_car
mov y2_CarTemp,ax
add y2_CarTemp,width_car
mov CX,x1_CarTemp
mov DX ,y1_CarTemp
mov si ,y2_CarTemp
call check_not_white_colUD
cmp item_color,color_pav
jnz ready0
add x1_CarTemp,1
add x2_CarTemp,1
ready0:

mov BX,x2_CarTemp   
inc BX

push di
call check_around_OR_in_CarTemp
pop di
mov CX,BX
mov DX ,y1_CarTemp
mov si ,y2_CarTemp

call check_not_white_colUD

push DX
push si
push di
push BX

cmp item_color,9H      ;(blue) check power up to get it from type speed up
jnz not3_power9
mov position_power_to_car,2
mov powerTypeTemp,2
call get_power_up
jmp not3_power12

not3_power9:
cmp item_color,0AH      ;(green) check power up to get it from type speed down
jnz not3_power10
mov position_power_to_car,2
mov powerTypeTemp,3
call get_power_up
jmp not3_power12

not3_power10:
cmp item_color,0BH      ;(cyan) check power up to get it from type generate obstacle
jnz not3_power11
mov position_power_to_car,2
mov powerTypeTemp,4
call get_power_up
jmp not3_power12

not3_power11:
cmp item_color,0CH      ;(red) check power up to get it from type pass obstacle
jnz not3_power12
mov position_power_to_car,2
mov powerTypeTemp,5
call get_power_up

not3_power12:
pop bx
pop di
pop si
pop dx

push cx
mov cl,curState_CarTemp
and cl,prevState_passObsTemp       ;if prev = 1 (passing) and current = 1,there is obstacle around or in car then 
mov prevState_passObsTemp,cl
pop cx

cmp check_if_color,1
jnz can_move_Right
cmp item_color,2
jz again3
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit3CarTemp
again3:
xchg dx,si
call check_not_white_colDU
cmp item_color,2
jz skip3
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit3CarTemp


skip3:
cmp prevState_passObsTemp,0
jz no_passing_Right
jmp can_move_Right

no_passing_Right:
cmp passObs_CarTemp,1
jz continue3
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit3CarTemp
continue3:
mov prevState_passObsTemp,1
mov passObs_CarTemp,0

can_move_Right:
cmp genObs_CarTemp,1
jnz not_genObs_Right    ;genObs_CarTemp = 0 (not active) not generate obstacle due to moving down CarTemp
push di
push BX
push AX
mov DX,y1_CarTemp
add DX,6             ;width car 8 pixels, mid point of obstacle after x1+3
mov CX,x2_CarTemp
mov al,1
call add_obstacle
pop AX
pop BX
pop di
mov genObs_CarTemp,0
not_genObs_Right:
drawCar pev_x1,pev_y1,pev_x2,pev_y2,0fh
mov x2_CarTemp,BX
drawCar x1_CarTemp,y1_CarTemp,x2_CarTemp,y2_CarTemp,color_CarTemp 
mov BX,x1_CarTemp
draw_col BX,y1_CarTemp,y2_CarTemp,0fh
inc BX
mov x1_CarTemp,BX
dec di
cmp di,0h
mov flag_direction_temp,2
jz exit3CarTemp

jmp moveRightSpeed

exit3CarTemp:
    call culc_center_of_car  
    pop cx
    pop si
    pop dx
    pop ax 
    call CAR
ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





moveLeft:
push ax
push dx
push si
push cx
    
mov di,speed_CarTemp
cmp di,0        ;check if speed equal = 0

jnz moveLeftSpeed
    pop cx
    pop si
    pop dx
    pop ax
call culc_center_of_car
call CAR
ret
moveLeftSpeed:
push ax
call save_prev_coord  ;save the prev coordinate
pop ax
cmp flag_direction_temp,2
jz ready1
cmp flag_direction_temp,3
jz ready1

mov ax,xc_Car
mov x1_CarTemp,ax
sub x1_CarTemp,haight_car
mov x2_CarTemp,ax
add x2_CarTemp,haight_car
mov ax,yc_Car
mov y1_CarTemp,ax
sub y1_CarTemp,width_car
mov y2_CarTemp,ax
add y2_CarTemp,width_car
mov CX,x2_CarTemp
mov DX ,y1_CarTemp
mov si ,y2_CarTemp
call check_not_white_colUD
cmp item_color,color_pav
jnz ready1
sub x1_CarTemp,1
sub x2_CarTemp,1
ready1:
mov BX,x1_CarTemp   
dec BX

push di
call check_around_OR_in_CarTemp
pop di
mov CX,BX
mov DX ,y1_CarTemp
mov si ,y2_CarTemp

call check_not_white_colUD

push DX
push si
push di
push BX

cmp item_color,9H      ;(blue) check power up to get it from type speed up
jnz not4_power9
mov position_power_to_car,3
mov powerTypeTemp,2
call get_power_up
jmp not4_power12

not4_power9:
cmp item_color,0AH      ;(green) check power up to get it from type speed down
jnz not4_power10
mov position_power_to_car,3
mov powerTypeTemp,3
call get_power_up
jmp not4_power12

not4_power10:
cmp item_color,0BH      ;(cyan) check power up to get it from type generate obstacle
jnz not4_power11
mov position_power_to_car,3
mov powerTypeTemp,4
call get_power_up
jmp not4_power12

not4_power11:
cmp item_color,0CH      ;(red) check power up to get it from type pass obstacle
jnz not4_power12
mov position_power_to_car,3
mov powerTypeTemp,5
call get_power_up

not4_power12:
pop bx
pop di
pop si
pop dx

push cx
mov cl,curState_CarTemp
and cl,prevState_passObsTemp       ;if prev = 1 (passing) and current = 1,there is obstacle around or in car then 
mov prevState_passObsTemp,cl
pop cx

cmp check_if_color,1
jnz can_move_left
cmp item_color,2
jz again4
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit4CarTemp
again4:
xchg dx,si
call check_not_white_colDU
cmp item_color,2
jz skip4
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit4CarTemp

skip4:
cmp prevState_passObsTemp,0
jz no_passing_left
jmp can_move_left

no_passing_left:
cmp passObs_CarTemp,1
jz continue4
push ax
call save_temp_coord ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pop ax
jmp exit4CarTemp
continue4:
mov prevState_passObsTemp,1
mov passObs_CarTemp,0

can_move_left:
cmp genObs_CarTemp,1
jnz not_genObs_left    ;genObs_CarTemp = 0 (not active) not generate obstacle due to moving down CarTemp
push di
push BX
push AX
mov DX,y1_CarTemp
add DX,6             ;width car 8 pixels, mid point of obstacle after x1+3
mov CX,x2_CarTemp
mov al,1
call add_obstacle
pop AX
pop BX
pop di
mov genObs_CarTemp,0
not_genObs_left:
drawCar pev_x1,pev_y1,pev_x2,pev_y2,0fh
mov x1_CarTemp,BX
drawCar x1_CarTemp,y1_CarTemp,x2_CarTemp,y2_CarTemp,color_CarTemp 
mov BX,x2_CarTemp
draw_col BX,y1_CarTemp,y2_CarTemp,0fh
dec BX
mov x2_CarTemp,BX
dec di
cmp di,0h
mov flag_direction_temp,3
jz exit4CarTemp

jmp moveLeftSpeed

exit4CarTemp:
    pop cx
    pop si
    pop dx
    pop ax
    call culc_center_of_car
    call CAR  
ret
moveCar endp



check_move   proc   FAR     ;this procedure for checking produced keys and released keys and change flags

cmp generateGameData,1      ;check if the current user is who sent or received invitation
jz move_car1

cmp al,4Bh      ;check scan code if press left arrow
jnz not_pressedLeft2
mov left_Car2,1
jmp send2
;mov change_car,0

not_pressedLeft2:    
cmp al,4Dh      ;check scan code if press right arrow
jnz not_pressedRight2
mov right_Car2,1
jmp send2
;mov change_car,0

not_pressedRight2:        
cmp al,48h      ;check scan code if press up arrow
jnz not_pressedUp2
mov up_Car2,1
jmp send2
;mov change_car,0

not_pressedUp2:
cmp al,50h      ;check scan code if press down arrow
jnz not_pressedDown2
mov down_Car2,1
jmp send2
;mov change_car,0

not_pressedDown2:    
cmp  al, 62d
jnz not_
mov pressedF4,1
jmp send2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
not_:
cmp  al,4EH
jnz not_pressPower1
push ax
call send_powerUps
pop ax
jmp send2
not_pressPower1:



jmp skipsend2
send2:
mov sendData,al
call SEND
skipsend2:

ret

move_car1:
cmp al,4Bh      ;check scan code if press left arrow
jnz not_pressedLeft1
mov left_Car1,1
jmp send1
;mov change_car,0

not_pressedLeft1:    
cmp al,4Dh      ;check scan code if press right arrow
jnz not_pressedRight1
mov right_Car1,1
jmp send1
;mov change_car,0

not_pressedRight1:        
cmp al,48h      ;check scan code if press up arrow
jnz not_pressedUp1
mov up_Car1,1
jmp send1
;mov change_car,0

not_pressedUp1:
cmp al,50h      ;check scan code if press down arrow
jnz not_pressedDown1
mov down_Car1,1
jmp send1
;mov change_car,0

not_pressedDown1:   
cmp  al, 62d
jnz not_rec2
mov pressedF4,1
jmp send1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;key of power;;;;;;;;;;;;;;;;;;;;
not_rec2:
cmp  al,4EH
jnz not_pressPower2
push ax
call send_powerUps
pop ax
jmp send1

not_pressPower2:


jmp skipsend1
send1:
mov sendData,al
call SEND
skipsend1:
ret

check_move endp

receive_move   proc   FAR     ;this procedure for checking produced keys and released keys and change flags
; cmp receivedMove,1
; jne cont
; ret
; cont:
mov        dx , 3FDH    ; Line Status Register
in         al , dx      ;chk if i recived something
AND        al , 1 
jnz   start_rec
ret

start_rec:
mov        dx , 03F8H                           ;else get character in al|value
in         al , dx

cmp generateGameData,1      ;check if the current user is who sent or received invitation
jz rec_car2
jmp recieve_car1

rec_car2:
cmp al,4Bh      ;check scan code if press left arrow
jnz not_receiveLeft2
mov left_Car2,1
jmp setmoved2

not_receiveLeft2:    
cmp al,4Dh      ;check scan code if press right arrow
jnz not_receiveRight2
mov right_Car2,1
jmp setmoved2

not_receiveRight2:        
cmp al,48h      ;check scan code if press up arrow
jnz not_receiveUp2
mov up_Car2,1
jmp setmoved2
; ;mov change_car,0

not_receiveUp2:
cmp al,50h      ;check scan code if press down arrow
jnz not_receiveDown2
mov down_Car2,1
jmp setmoved2

not_receiveDown2: 
cmp  al, 62d
jnz not_rec
mov pressedF4,1
jmp setmoved2

not_rec:
cmp  al,4EH
jnz not_receivePower1
push ax
call receive_powerUps
pop ax
jmp setmoved2

not_receivePower1:

not_recDown2: 

mov CHAR,al
call printChatChar2

jmp skipsetmoved2
setmoved2:
mov receivedMove,1
skipsetmoved2:



ret

recieve_car1:
cmp al,4Bh      ;check scan code if press left arrow
jnz not_receiveLeft1
mov left_Car1,1
jmp setmoved1
;mov change_car,0

not_receiveLeft1:    
cmp al,4Dh      ;check scan code if press right arrow
jnz not_receiveRight1
mov right_Car1,1
jmp setmoved1
;mov change_car,0

not_receiveRight1:        
cmp al,48h      ;check scan code if press up arrow
jnz not_receiveUp1
mov up_Car1,1
jmp setmoved1
;mov change_car,0

not_receiveUp1:
cmp al,50h      ;check scan code if press down arrow
jnz not_receiveDown1
mov down_Car1,1
jmp setmoved1
;mov change_car,0

not_receiveDown1:    

cmp  al,4EH
jnz not_receivePower2
push ax
call receive_powerUps
pop ax
jmp setmoved1

not_receivePower2:
cmp  al, 62d
jnz not_rec0
mov pressedF4,1
jmp setmoved1

not_rec0:
mov CHAR,al
call printChatChar2

jmp skipsetmoved1
setmoved1:
mov receivedMove,1
skipsetmoved1:
ret

receive_move endp


end