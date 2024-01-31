EXTRN speed_Car1:WORD
EXTRN powerType1 :BYTE
EXTRN speedUp_Car1:BYTE
EXTRN speedDown_Car1:BYTE
EXTRN genObs_Car1:BYTE
EXTRN passObs_Car1:BYTE

EXTRN speed_Car2:WORD
EXTRN powerType2:BYTE
EXTRN speedUp_Car2:BYTE
EXTRN speedDown_Car2:BYTE
EXTRN genObs_Car2:BYTE
EXTRN passObs_Car2:BYTE

EXTRN generateGameData:BYTE
EXTRN SEND:FAR
EXTRN sendData:BYTE

PUBLIC send_powerUps,receive_powerUps,activatePowers
.model HUGE
.data
duration    equ     5
normal_speed    equ     1
max_speed   equ     3
min_speed   equ     0

.code

activatePowers      proc    far
    cmp speedUp_Car2,1
    jnz not_deactive_speedUp2
    mov ah,2ch
    int 21h 
    mov ah,speedUp_Car2+1
    cmp dh,ah
    jnz not_deactive_speedUp2
    mov speedUp_Car2,0
    mov speed_Car2,normal_speed      ;amount of speed decreasing of the same car
    ;mov change_car,0

not_deactive_speedUp2:
    cmp speedDown_Car2,1
    jnz not_deactive_speedDown2
    mov ah,2ch
    int 21h 
    mov ah,speedDown_Car2+1
    cmp dh,ah
    jnz not_deactive_speedDown2
    mov speedDown_Car2,0
    mov speed_Car1,normal_speed      ;amount of speed decreasing of the another car
    ;mov change_car,0

not_deactive_speedDown2:    

; activation_car1:
;;;;;;;;;;;;check activation of car1;;;;;;;;;;;;;;;;

    cmp speedUp_Car1,1
    jnz not_deactive_speedUp1
    mov ah,2ch
    int 21h 
    mov ah,speedUp_Car1+1
    cmp dh,ah
    jnz not_deactive_speedUp1
    mov speedUp_Car1,0
    mov speed_Car1,normal_speed      ;amount of speed decreasing of the same car
    ;mov change_car,0

not_deactive_speedUp1:
    cmp speedDown_Car1,1
    jnz not_deactive_speedDown1
    mov ah,2ch
    int 21h 
    mov ah,speedDown_Car1+1
    cmp dh,ah
    jnz not_deactive_speedDown1
    mov speedDown_Car1,0
    mov speed_Car2,normal_speed      ;amount of speed decreasing of the another car
    ;mov change_car,0

not_deactive_speedDown1:

ret

activatePowers      endp


send_powerUps    proc far
    ;;;;;;;;;;;power Ups for car2;;;;;;;;;;;;
    cmp al,4EH      ;check if I press the key m (activation the last power for car2)
    jz exist_press2
    ret
    exist_press2:

    cmp generateGameData,1
    jnz powers_car2
    jmp powers_car1

    powers_car2:
    cmp powerType2,0
    jnz check_type2
    ret

    check_type2:
    cmp powerType2,2
    jnz not_speedUp2
    mov powerType2,0
    add speed_Car2,1       ;amount of speed increasing of the same car
    mov ah,2ch
    int 21h
    push ax
    mov al,dh
    mov ah,0
    add al,duration
    mov dh,60
    div dh
    mov speedUp_Car2,1
    mov speedUp_Car2+1,ah
    pop ax
    ;mov change_car,0
    cmp speed_Car2,max_speed
    jle stop_point2
    mov speed_Car2,max_speed
    ret

    not_speedUp2:
    cmp powerType2,3
    jnz not_speedDown2
    mov powerType2,0
    sub speed_Car1,1       ;amount of speed decreasing of the another car
    mov ah,2ch
    int 21h
    push ax
    mov al,dh
    mov ah,0
    add al,duration
    mov dh,60
    div dh
    mov speedDown_Car2,1
    mov speedDown_Car2+1,ah
    pop ax
    ;mov change_car,0
    cmp speed_Car1,min_speed
    jge stop_point2
    mov speed_Car1,min_speed
    ret

    stop_point2: ret

    not_speedDown2:
    cmp powerType2,4
    jnz not_genObs2
    mov powerType2,0
    mov genObs_Car2,1
    ;mov change_car,0
    ret


    not_genObs2:
    cmp powerType2,5
    jnz exit33
    mov powerType2,1
    mov passObs_Car2,1
    ;mov change_car,0
    exit33:
    ret


    
    ;;;;;;;;;;;power Ups for car1;;;;;;;;;;;;
    powers_car1:
    cmp powerType1,0
    jnz check_type1
    ret

    check_type1:
    cmp powerType1,2
    jnz not_speedUp1
    mov powerType1,0
    add speed_Car1,1       ;amount of speed increasing of the same car
    mov ah,2ch
    int 21h
    push ax
    mov al,dh
    mov ah,0
    add al,duration
    mov dh,60
    div dh
    mov speedUp_Car1,1
    mov speedUp_Car1+1,ah
    pop ax
    ;mov change_car,0
    cmp speed_Car1,max_speed
    jle exit11
    mov speed_Car1,max_speed
    exit11:
    ret 

    not_speedUp1:
    cmp powerType1,3
    jnz not_speedDown1
    mov powerType1,0
    sub speed_Car2,1       ;amount of speed decreasing of the another car
    mov ah,2ch
    int 21h
    push ax
    mov al,dh
    mov ah,0
    add al,duration
    mov dh,60
    div dh
    mov speedDown_Car1,1
    mov speedDown_Car1+1,ah
    pop ax
    ;mov change_car,0
    cmp speed_Car2,min_speed
    jge exit22
    mov speed_Car2,min_speed
    exit22:
    ret

    not_speedDown1:
    cmp powerType1,4
    jnz not_genObs1
    mov powerType1,0
    mov genObs_Car1,1
    ;mov change_car,0
    ret


    not_genObs1:
    cmp powerType1,5
    jnz exit44
    mov powerType1,1
    ;mov change_car,0
    mov passObs_Car1,1
    exit44:
ret
send_powerUps endp

receive_powerUps    proc far
    ;;;;;;;;;;;power Ups for car2;;;;;;;;;;;;
    cmp al,4EH      ;check if I receive the key m (activation the last power for car2)
    jz exist_recei2
    ret
    exist_recei2:

    cmp generateGameData,1
    jz powers_rec_car2
    jmp powers_rec_car1

    powers_rec_car2:
    cmp powerType2,0
    jnz check_type2_rec
    ret

    check_type2_rec:
    cmp powerType2,2
    jnz not_speedUp2_rec
    mov powerType2,0
    add speed_Car2,1       ;amount of speed increasing of the same car
    mov ah,2ch
    int 21h
    push ax
    mov al,dh
    mov ah,0
    add al,duration
    mov dh,60
    div dh
    mov speedUp_Car2,1
    mov speedUp_Car2+1,ah
    pop ax
    ;mov change_car,0
    cmp speed_Car2,max_speed
    jle stop_point21
    mov speed_Car2,max_speed
    ret

    not_speedUp2_rec:
    cmp powerType2,3
    jnz not_speedDown2_rec
    mov powerType2,0
    sub speed_Car1,1       ;amount of speed decreasing of the another car
    mov ah,2ch
    int 21h
    push ax
    mov al,dh
    mov ah,0
    add al,duration
    mov dh,60
    div dh
    mov speedDown_Car2,1
    mov speedDown_Car2+1,ah
    pop ax
    ;mov change_car,0
    cmp speed_Car1,min_speed
    jge stop_point21
    mov speed_Car1,min_speed
    ret

    stop_point21: ret

    not_speedDown2_rec:
    cmp powerType2,4
    jnz not_genObs2_rec
    mov powerType2,0
    mov genObs_Car2,1
    ;mov change_car,0
    ret


    not_genObs2_rec:
    cmp powerType2,5
    jnz exit55
    mov powerType2,1
    mov passObs_Car2,1
    ;mov change_car,0
    exit55:
    ret


    
    ;;;;;;;;;;;power Ups for car1;;;;;;;;;;;;
    powers_rec_car1:
    cmp powerType1,0
    jnz check_type1_rec
    ret

    check_type1_rec:
    cmp powerType1,2
    jnz not_speedUp1_rec
    mov powerType1,0
    add speed_Car1,1       ;amount of speed increasing of the same car
    mov ah,2ch
    int 21h
    push ax
    mov al,dh
    mov ah,0
    add al,duration
    mov dh,60
    div dh
    mov speedUp_Car1,1
    mov speedUp_Car1+1,ah
    pop ax
    ;mov change_car,0
    cmp speed_Car1,max_speed
    jle exit12
    mov speed_Car1,max_speed
    exit12:
    ret 

    not_speedUp1_rec:
    cmp powerType1,3
    jnz not_speedDown1_rec
    mov powerType1,0
    sub speed_Car2,1       ;amount of speed decreasing of the another car
    mov ah,2ch
    int 21h
    push ax
    mov al,dh
    mov ah,0
    add al,duration
    mov dh,60
    div dh
    mov speedDown_Car1,1
    mov speedDown_Car1+1,ah
    pop ax
    ;mov change_car,0
    cmp speed_Car2,min_speed
    jge exit21
    mov speed_Car2,min_speed
    exit21:
    ret

    not_speedDown1_rec:
    cmp powerType1,4
    jnz not_genObs1_rec
    mov powerType1,0
    mov genObs_Car1,1
    ;mov change_car,0
    ret


    not_genObs1_rec:
    cmp powerType1,5
    jnz exit66
    mov powerType1,1
    ;mov change_car,0
    mov passObs_Car1,1
exit66:
ret
receive_powerUps endp


end