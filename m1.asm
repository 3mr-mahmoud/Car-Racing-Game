INCLUDE macros.inc
EXTRN item_color: byte
EXTRN drawStatusBar:FAR
EXTRN reset:FAR
public countSeconds,countMinutes,playerPoints1,playerPoints2,Name1,Name2,calledstatusbefore,seconds,FinishTime,ClearGamerOver

EXTRN CHAR:BYTE
EXTRN printChatChar1:FAR

EXTRN moveCar: FAR
EXTRN check_move: FAR
EXTRN receive_move:FAR
; EXTRN powerUps:FAR
EXTRN activatePowers:FAR

EXTRN HOME:FAR
public pressedButton
public sendData,receivedData


EXTRN generateRoadPoints:FAR
EXTRN drawRoad:FAR
EXTRN generateItems:FAR
EXTRN drawItems:FAR
EXTRN randPower:FAR
EXTRN drawPavement:FAR
EXTRN chat:FAR
EXTRN SEND:FAR
EXTRN RECEIVE:FAR
EXTRN printStatus:FAR
EXTRN clear_status:FAR

EXTRN updateProgress:FAR

PUBLIC points,road_x,road_y,last_move_direction,gonext,counter,movedownflag,first_direction,curr_x,curr_y,items,items_x,items_y,items_type,chosen_points,chosen_points_arr


PUBLIC x1_Car1,x2_Car1,y1_Car1,y2_Car1,speed_Car1,color_Car1,left_Car1,right_Car1,up_Car1,down_Car1,powerType1 ,speedUp_Car1,speedDown_Car1,genObs_Car1,passObs_Car1
PUBLIC x1_Car2,x2_Car2,y1_Car2,y2_Car2,speed_Car2,color_Car2,left_Car2,right_Car2,up_Car2,down_Car2,powerType2,speedUp_Car2,speedDown_Car2,genObs_Car2,passObs_Car2

PUBLIC x1_CarTemp,x2_CarTemp,y1_CarTemp,y2_CarTemp,speed_CarTemp,color_CarTemp,left_CarTemp,right_CarTemp,up_CarTemp,down_CarTemp,powerTypeTemp,speedUp_CarTemp
PUBLIC speedDown_CarTemp,genObs_CarTemp,passObs_CarTemp,prevState_passObsTemp,curState_CarTemp
PUBLIC prevState_passObs1,prevState_passObs2,curState_Car1,curState_Car2
PUBLIC duration,check_if_color

PUBLIC nearest_x_power,nearest_y_power,check_center_car,flag_direction_temp

PUBLIC LeftDigit,RightDigit,PlayedOnce,TimeIsFinsihed


public score1,score2,generateGameData,pressedF4

public chatAbility,gameAbility,invitedToChat,invitedToGame

EXTRN CAR:FAR
; EXTRN Screen:FAR
EXTRN xc_Car:WORD
EXTRN yc_Car:WORD
EXTRN culc_center_of_car:FAR
public filename,flag_direction_temp
public sentMove,receivedMove

.model HUGE
.stack 256h
.data
    pressedF4             db  0
    sentMove              db  0
    receivedMove          db  0

    sendData              db  0
    receivedData          db  0
    receiveGeneratedPower db  0
    chatAbility           db  0
    invitedToChat         db  0
    gameAbility           db  0
    invitedToGame         db  0
    generateGameData      db  0

    background_color      db  78
    LeftDigit             db  0
    RightDigit            db  0
    pressedButton         db  0
   
    calledstatusbefore    db  0
    seconds               db  ?
    randPowerCalledAt     db  0                                          ; to make randpower called one time each 5 seconds
    countSeconds          db  10
    countMinutes          db  0

    playerPoints1         db  0
    playerPoints2         db  0

    Name1                 db  15 dup('$')
    Name2                 db  15 dup('$')
    PlayedOnce            db  0
    TimeIsFinsihed        db  0
    sentChatInvitaion     db  "You have sent chat invitation to : $"
    gotChatInvitaion      db  'You have got chat invitation from : $'
    sentGameInvitaion     db  "You have sent game invitation to : $"
    gotGameInvitaion      db  'You have got game invitation from : $'
    FinishTime            db  "Game Over$"
    ClearGamerOver        db  "         $"


    maxpoints             equ 60
    points                DB  0
    road_x                DW  maxpoints+1 DUP(?)
    road_y                DW  maxpoints+1 DUP(?)
    chosen_points         DB  2                                          ; don't choose first point and last point
    chosen_points_arr     DB  1,maxpoints-2 DUP(0),1
    last_move_direction   DB  2
    first_direction       DB  4
    gonext                DB  0
    counter               DB  0
    movedownflag          DB  0
    curr_x                DW  30                                         ; start point
    curr_y                DW  100                                        ; end point
    items                 DW  0
    items_x               DW  maxpoints+30 DUP(?)
    items_y               DW  maxpoints+30 DUP(?)
    items_type            DB  maxpoints+30 DUP(?)                        ; 0 horizontal-obs 1 vertical-obs 2 powerup

    x1_Car1               DW  100                                        ;x1,x2,y1,y2
    x2_Car1               DW  110
    y1_Car1               DW  115
    y2_Car1               DW  125
    speed_Car1            DW  3
    color_Car1            DB  6h                                         ;brown
    left_Car1             DB  0
    right_Car1            DB  0
    up_Car1               DB  0
    down_Car1             DB  0
    powerType1            DB  2                                          ;0 => no power,  2=>speed up,     3=>speed down,     4=>generate obstacle        ,5=>pass obstacle
    ;;; key (t) for avtivation power up
    speedUp_Car1          DB  0,0                                        ;first:status of activation of this action,   second:finish second of activation
    speedDown_Car1        DB  0,0                                        ;first:status of activation of this action,   second:finish second of activation
    genObs_Car1           DB  0                                          ;status of activation of this action,
    passObs_Car1          DB  0                                          ;status of activation of this action
    prevState_passObs1    DB  0                                          ;flag for showing if car1 start passing through obstacle before
    curState_Car1         DB  0                                          ;flag for showing if there is obstacle around or in car1
    flag_direction_1      db  ?                                          ;0->up 1->down  2->right  3->left
    filename_red          DB  'Car_red.bin',0
    score1                DB  0


    x1_Car2               DW  0                                          ;x1,x2,y1,y2
    x2_Car2               DW  0
    y1_Car2               DW  0
    y2_Car2               DW  0
    speed_Car2            DW  0
    color_Car2            DB  1h                                         ;blue
    left_Car2             DB  0
    right_Car2            DB  0
    up_Car2               DB  0
    down_Car2             DB  0
    powerType2            DB  2                                          ;0 => no power,  2=>speed up,     3=>speed down,     4=>generate obstacle        ,5=>pass obstacle
    ;;; key (m) for avtivation power up
    speedUp_Car2          DB  0,0                                        ;first:status of activation of this action,   second:finish second of activation
    speedDown_Car2        DB  0,0                                        ;first:status of activation of this action,   second:finish second of activation
    genObs_Car2           DB  0                                          ;status of activation of this action,
    passObs_Car2          DB  0                                          ;status of activation of this action
    prevState_passObs2    DB  0                                          ;flag for showing if car2 start passing through obstacle before
    curState_Car2         DB  0                                          ;flag for showing if there is obstacle around or in car2
    flag_direction_2      db  ?                                          ;0->up 1->down  2->right  3->left
    filename_blue         DB  'Car_blu.bin',0
    score2                DB  0


    ;;;;variables for copying;;;;;;;;;;;;;;
    x1_CarTemp            DW  100                                        ;x1,x2,y1,y2
    x2_CarTemp            DW  110
    y1_CarTemp            DW  115
    y2_CarTemp            DW  125
    speed_CarTemp         DW  1
    color_CarTemp         DB  9h
    left_CarTemp          DB  0
    right_CarTemp         DB  0
    up_CarTemp            DB  0
    down_CarTemp          DB  0
    powerTypeTemp         DB  2                                          ;0 => no power,  2=>speed up,     3=>speed down,     4=>generate obstacle        ,5=>pass obstacle
    speedUp_CarTemp       DB  0,0                                        ;first:status of activation of this action,   second:finish second of activation
    speedDown_CarTemp     DB  0,0                                        ;first:status of activation of this action,   second:finish second of activation
    genObs_CarTemp        DB  0                                          ;status of activation of this action,
    passObs_CarTemp       DB  0                                          ;status of activation of this action
    prevState_passObsTemp DB  0                                          ;flag for showing if CarTemp start passing through obstacle before
    curState_CarTemp      DB  0                                          ;flag for showing if there is obstacle around or in CarTemp
    flag_direction_temp   db  ?                                          ;0->up 1->down  2->right  3->left
    filename              DB  12 DUP(0)

    testMSG               db  "TEST$"
    emptystring           db  "faf $"

    nearest_x_power       DW  ?
    nearest_y_power       dw  ?
    check_center_car      db  ?

    check_if_color        DB  0



    duration              equ 5

    inviteGame            equ 3
    acceptGame            equ 5

    inviteChat            equ 4
    acceptChat            equ 2
    playerExits           equ 9
    generatedPower        equ 1
.code
sendGameData proc
                        mov        bl,points
                        mov        sendData,bl
                        call       SEND
                        
                        add        bl,points
                        lea        si,road_x

    send_x:             mov        bh,byte ptr [si]
                        mov        sendData,bh
                        call       SEND
                        inc        si
                        dec        bl
                        jnz        send_x

                        mov        bl,points
                        add        bl,points
                        lea        si,road_y
    send_y:             mov        bh,byte ptr [si]
                        mov        sendData,bh
                        call       SEND
                        inc        si
                        dec        bl
                        jnz        send_y

                        mov        bl,first_direction
                        mov        sendData,bl
                        call       SEND

    ; receive road items
                        mov        bx,items
                        mov        sendData,bl
                        call       SEND
                        
                        add        bx,items
                        lea        si,items_x

    senditem_x:         mov        bh,byte ptr [si]
                        mov        sendData,bh
                        call       SEND
                        inc        si
                        dec        bl
                        jnz        senditem_x

                        mov        bx,items
                        add        bx,items
                        lea        si,items_y
    senditem_y:         mov        bh,byte ptr [si]
                        mov        sendData,bh
                        call       SEND
                        inc        si
                        dec        bl
                        jnz        senditem_y

                        mov        bx,items
                        lea        si,items_type
    senditem_types:     mov        bh,byte ptr [si]
                        mov        sendData,bh
                        call       SEND
                        inc        si
                        dec        bl
                        jnz        senditem_types

                        ret
sendGameData endp

receiveGameData proc

                        call       RECEIVE
                        mov        al,receivedData
                        mov        points,al

                        mov        bh,points
                        add        bh,points
                        lea        si,road_x
    receiveXPts:        
                        call       RECEIVE
                        mov        al,receivedData

                        mov        byte ptr [si],al
                        inc        si
                        dec        bh
                        jnz        receiveXPts


                        mov        bh,points
                        add        bh,points
                        lea        si,road_y
    receiveYPts:        
                        call       RECEIVE
                        mov        al,receivedData
                        
                        mov        byte ptr [si],al
                        inc        si
                        dec        bh
                        jnz        receiveYPts

                        call       RECEIVE
                        mov        al,receivedData
                        mov        first_direction,al
    ; receive items count
                        call       RECEIVE
                        mov        al,receivedData
                        mov        ah,0
                        mov        items,ax

                        mov        bx,items
                        add        bx,items
                        lea        si,items_x
    receiveXitems:      
                        call       RECEIVE
                        mov        al,receivedData
                        
                        mov        byte ptr [si],al
                        inc        si
                        dec        bl
                        jnz        receiveXitems

    ; receive items y

                        mov        bx,items
                        add        bx,items
                        lea        si,items_y
    receiveYitems:      
                        call       RECEIVE
                        mov        al,receivedData
                        
                        mov        byte ptr [si],al
                        inc        si
                        dec        bl
                        jnz        receiveYitems
    ; receive Item Types
                        mov        bx,items
                        lea        si,items_type
    receivetypeitems:   
                        call       RECEIVE
                        mov        al,receivedData
                        
                        mov        byte ptr [si],al
                        inc        si
                        dec        bl
                        jnz        receivetypeitems

                        ret
receiveGameData endp
setConfig proc
    ; Set Divisor Latch Access Bit
                        mov        dx,3fbh                              ; Line Control Register
                        mov        al,10000000b                         ;Set Divisor Latch Access Bit
                        out        dx,al                                ;Out it
    ;Set LSB byte of the Baud Rate Divisor Latch register.
                        mov        dx,3f8h
                        mov        al,18h
                        out        dx,al
    ;Set MSB byte of the Baud Rate Divisor Latch register.
                        mov        dx,3f9h
                        mov        al,00h
                        out        dx,al
    ; Set port configuration
                        mov        dx,3fbh
                        mov        al,00011011b
                        out        dx,al

                        ret

setConfig endp

main proc far
                        mov        ax,@data
                        mov        ds,ax
    start:              
                        call       reset

                        call       setConfig
                    
                        call       HOME
                        mov        PlayedOnce,1



    mainLoop:           
                        mov        ah, 1
                        int        16h
                        jz         _start_receive                       ;if pressed nothing
                        mov        ah, 0
                        int        16h
    checkF2:            cmp        ah,03ch                              ; check F2
                        jne        checkF1
                        cmp        chatAbility,0                        ; if I didn't receive invitaion before
                        je         sendChatInvite
                        mov        sendData,acceptChat
                        call       SEND
                        call       chat
                        call       Home

                        

                        mov        chatAbility,0                        ; got  chat invitation
                        mov        invitedToChat,0                      ; invited someone to chat
                        jmp        mainLoop
    sendChatInvite:     mov        sendData,inviteChat
                        call       SEND
                        lea        dx,sentChatInvitaion
                        call       printStatus
                        push       ax
                        lea        dx,Name2
                        mov        ah,9
                        int        21h
                        pop        ax
                        mov        invitedToChat,1                      ; invited someone to chat
                        jmp        start_receive
    shrtMnLoop:         jmp        mainLoop
    
    checkF1:            cmp        ah,03bh                              ; check f1
                        jne        checkExit
                        cmp        gameAbility,0
                        je         sendGameInvite
                        mov        sendData,acceptGame
                        call       SEND
                        
                        jmp        start_game

                        jmp        mainLoop

    _start_receive:     jmp        start_receive

    sendGameInvite:     
                        mov        generateGameData,1
                        mov        sendData,inviteGame
                        call       SEND
                        call       clear_status
                        lea        dx,sentGameInvitaion
                        call       printStatus
    ; showmes     Name1
                        push       ax
                        lea        dx,Name2
                        mov        ah,9
                        int        21h
                        pop        ax
                        jmp        start_receive
    checkExit:          cmp        ah, 1h
                        jne        start_receive
                        mov        sendData, playerExits
                        CALL       SEND
                        mov        PlayedOnce,0
                        jmp        quit
    start_receive:      mov        dx , 3FDH                            ; Line Status Register
                        in         al , dx                              ;chk if i recived something
                        AND        al , 1
                        cmp        al, 1
                        jne        shrtMnLoop                           ;if not continue looping
                        mov        dx , 03F8H                           ;else get character in al|value
                        in         al , dx
                        cmp        al, inviteGame                       ;if another player send game inv
                        jne        chkAcceptGame                        ;if not  check another player accepted game invitation
                        lea        dx, gotGameInvitaion
                        CALL       printStatus
                        push       ax
                        lea        dx,Name2
                        mov        ah,9
                        int        21h
                        pop        ax
                        mov        gameAbility, 1                       ;can player
                        jmp        shrtMnLoop
    chkAcceptGame:      cmp        al, acceptGame                       ;if player accept invite
                        jne        checkSendChat
                        jmp        start_game
    checkSendChat:      cmp        al, inviteChat                       ;if another player send chat invitation
                        jne        chkAcceptChat                        ;if not check player accept chat invitaion
                        lea        dx, gotChatInvitaion
                        CALL       printStatus
                        push       ax
                        lea        dx,Name2
                        mov        ah,9
                        int        21h
                        pop        ax
                        mov        chatAbility, 1                       ; I got chat invitation
    shrtMnLoop2:        jmp        mainLoop
    chkAcceptChat:      cmp        al, acceptChat                       ; if player accept invite
                        jne        chkIfExite
                        CALL       chat                                 ;start chat
                        CALL       HOME
                        

                        mov        chatAbility,0
                        mov        invitedToChat, 0
                        jmp        shrtMnLoop2
    chkIfExite:         cmp        al, playerExits
                        jne        shrtMnLoop2
                        mov        PlayedOnce,0
                        jmp        start
                        jmp        shrtMnLoop2







    quit:               
                        mov        ax,0003h
                        int        10h
                        MOV        AH, 4CH                              ; service 4CH - exit with a return code
                        MOV        AL, 01                               ; your return code
                        INT        21H


    start_game:         
                        mov        ax,13h
                        int        10h

    ; inline chat

                                  
                        cmp        generateGameData,0
                        je         receiveData
                        call       generateRoadPoints
                        call       generateItems
                        call       sendGameData
                        jmp        startGame
    receiveData:        
                        call       receiveGameData


    startGame:          
                        call       drawPavement
                        call       drawRoad
                        call       drawItems

                        cmp        first_direction ,0
                        jz         drdown
                        cmp        first_direction ,1
                        jnz        not_up
                        jmp        drup
    not_up:             
                        jmp        drright

    drdown:             initialCar 103,109,23,27,1,6,1,filename_red
                        
                        copy_Car   x1_CarTemp,x1_Car1
                        call       culc_center_of_car
                        call       CAR
                        initialCar 103,109,30,34,1,1,1,filename_blue
                        
                        copy_Car   x1_CarTemp,x1_Car2
                        call       culc_center_of_car
                        call       CAR
                        jmp        toDrawCars
    drup:               
                        initialCar 93,99,23,27,1,6,0,filename_red
                        
                        copy_Car   x1_CarTemp,x1_Car1
                        call       culc_center_of_car
                        call       CAR
                        initialCar 93,99,30,34,1,1,0,filename_blue
                        
                        copy_Car   x1_CarTemp,x1_Car2
                        call       culc_center_of_car
                        call       CAR
                        jmp        toDrawCars
    drright:            
                        initialCar 93,99,30,34,1,6,2,filename_red
                       
                        copy_Car   x1_CarTemp,x1_Car1
                        call       culc_center_of_car
                        call       CAR
                        initialCar 103,109,30,34,1,1,2,filename_blue
                       
                        copy_Car   x1_CarTemp,x1_Car2
                        call       culc_center_of_car
                        call       CAR
    
    toDrawCars:         

    check:              
                        mov        receivedMove,0

                        call       receive_move
                           
                        
                        mov        ah, 1
                        int        16h
                        jz         cont_game                            ;if pressed nothing
                        mov        ah, 0
                        int        16h
                        cmp        al,13                                ; send enter
                        je         sendchatdata
                        cmp        al,8                                 ; send backspace
                        je         sendchatdata
                        cmp        al,20h                               ; send space
                        je         sendchatdata
                        cmp        al,65
                        JL         cont_game                            ; less than 65 invalid
                        cmp        al,90
                        JLE        sendchatdata                         ; greater than 65 and less than or equal 90 valid
    ; greater than 90
                        cmp        al,122
                        JG         cont_game
                        cmp        al,97                                ; less than or equal 122 and greater than or equal 97 valid
                        JGE        sendchatdata
                        jmp        cont_game
    sendchatdata:       
                        mov        sendData,al
                        call       SEND
                        mov        CHAR,al
                        call       printChatChar1
                 
    cont_game:          
    ;call       receive_move
                        cmp        pressedF4,1
                        jz         stop212
                        jnz        no_stop
                       
    stop212:            call       updateProgress
                        call       drawStatusBar
                        jmp        final

                        
                        
    no_stop:            call       updateProgress
                        call       drawStatusBar

                        


    ;generate random powerup each 5 seconds
                        mov        al, countSeconds
                        cmp        al,randPowerCalledAt                 ; to handle when they are called many times in same cycle
                        je         skipmakingrandpower
                        mov        ah,0
                        mov        bl,5
                        div        bl
                        cmp        ah,0                                 ;remainder = 0 then seconds is multiple of 5
                        jne        skipmakingrandpower
                        mov        al, countSeconds
                        mov        randPowerCalledAt,al                 ; update last call second
                        call       receive_move
    ; call       randPower
                        call       receive_move
    skipmakingrandpower:

                        
                        cmp        TimeIsFinsihed,1
                        jne        cont

                        jmp        final_2

    cont:               in         al,60h
                        call       check_move
                        call       activatePowers
                        call       receive_move
                        call       activatePowers
        
                        cmp        left_Car2,1                          ;check if flag of left of car2 (pressed or not)
                        jnz        not_move_left2
                        mov        ax,0300h
                        copy_Car   x1_Car2,x1_CarTemp
                        call       moveCar
                        copy_Car   x1_CarTemp,x1_Car2
                        mov        left_Car2,0

                        copy_Car   x1_Car1,x1_CarTemp
                        call       culc_center_of_car
                        call       CAR

                        cmp        item_color,4d
                        jnz        not_move_left2
                        inc        playerPoints2
    final_2:                                                            ;;IMPORTANTTTTTTTTTTTTTTTTTTTTTTT
                        jmp        final


    not_move_left2:     
                        cmp        right_Car2,1                         ;check if flag of right of car2 (pressed or not)
                        jnz        not_move_right2
                        mov        ax,0200h
                        copy_Car   x1_Car2,x1_CarTemp
                        call       moveCar
                        copy_Car   x1_CarTemp,x1_Car2
                        mov        right_Car2,0
                        copy_Car   x1_Car1,x1_CarTemp
                        call       culc_center_of_car
                        call       CAR
    ; copy_Car   x1_CarTemp,x1_Car1
                        
                        cmp        item_color,4d
                        jnz        not_move_right2
                        inc        playerPoints2
                        jmp        final



    not_move_right2:    
                        cmp        up_Car2,1                            ;check if flag of up of car2 (pressed or not)
                        jnz        not_move_up2
                        mov        ax,0100h
                        copy_Car   x1_Car2,x1_CarTemp
                        call       moveCar
                        copy_Car   x1_CarTemp,x1_Car2
                        mov        up_Car2,0
                        copy_Car   x1_Car1,x1_CarTemp
                        call       culc_center_of_car
                        call       CAR
    ; copy_Car   x1_CarTemp,x1_Car1
                    
                        cmp        item_color,4d
                        jnz        not_move_up2
                        inc        playerPoints2
                        jmp        final



    not_move_up2:       
                        cmp        down_Car2,1                          ;check if flag of down of car2 (pressed or not)
                        jnz        not_move_down2
                        mov        ax,0000h
                        copy_Car   x1_Car2,x1_CarTemp
                        call       moveCar
    ;call       culc_center_of_car
    ;call       CAR
                        copy_Car   x1_CarTemp,x1_Car2
                        mov        down_Car2,0
                        copy_Car   x1_Car1,x1_CarTemp
                        call       culc_center_of_car
                        call       CAR
    ; copy_Car   x1_CarTemp,x1_Car1
                        
                        
                        cmp        item_color,4d
                        jnz        not_move_down2
                        inc        playerPoints2
                        jmp        final

                        jmp        not_move_down2

    ;final21: jmp final

    not_move_down2:     
                        cmp        left_Car1,1                          ;check if flag of left of car1 (pressed or not)
                        jnz        not_move_left1
                        mov        ax,0300h
                        copy_Car   x1_Car1,x1_CarTemp
    ;drawCar    x1_Car2,y1_Car2,x2_Car2,y2_Car2,color_Car2
                        call       moveCar
    ;call       CAR
                        copy_Car   x1_CarTemp,x1_Car1
                        mov        left_Car1,0
                        
                        copy_Car   x1_Car2,x1_CarTemp
                        call       culc_center_of_car
                        call       CAR
    ; copy_Car   x1_CarTemp,x1_Car2
                        
                        cmp        item_color,4d
                        jnz        not_move_left1
                        inc        playerPoints1
                        jmp        final


    not_move_left1:     
                        cmp        right_Car1,1                         ;check if flag of right of car1 (pressed or not)
                        jnz        not_move_right1
                        mov        ax,0200h
                        copy_Car   x1_Car1,x1_CarTemp
                        call       moveCar
                        
                        copy_Car   x1_CarTemp,x1_Car1
                        mov        right_Car1,0
                        copy_Car   x1_Car2,x1_CarTemp
                        call       culc_center_of_car
                        call       CAR
    ; copy_Car   x1_CarTemp,x1_Car2
                        
                        cmp        item_color,4d
                        jnz        not_move_right1
                        inc        playerPoints1
                        jmp        final



    not_move_right1:    
                        cmp        up_Car1,1                            ;check if flag of up of car1 (pressed or not)
                        jnz        not_move_up1
                        mov        ax,0100h
                        copy_Car   x1_Car1,x1_CarTemp
                        call       moveCar
                        copy_Car   x1_CarTemp,x1_Car1
                        mov        up_Car1,0
                        copy_Car   x1_Car2,x1_CarTemp
                        call       culc_center_of_car
                        call       CAR
    ; copy_Car   x1_CarTemp,x1_Car2

                        cmp        item_color,4d
                        jnz        not_move_up1
                        inc        playerPoints1
                        jmp        final



    not_move_up1:       
                        cmp        down_Car1,1                          ;check if flag of down of car1 (pressed or not)
                        jnz        not_move_down1
                        mov        ax,0000h
                        copy_Car   x1_Car1,x1_CarTemp
    ;drawCar    x1_Car1,y1_Car1,x2_Car1,y2_Car1,color_Car1
                        call       moveCar
                        
    ;call       CAR
                        copy_Car   x1_CarTemp,x1_Car1
                        mov        down_Car1,0
                        copy_Car   x1_Car2,x1_CarTemp
                        call       culc_center_of_car
                        call       CAR
    ; copy_Car   x1_CarTemp,x1_Car2
                        
                        cmp        item_color,4d
                        jnz        not_move_down1
                        inc        playerPoints1
                        jmp        final



    not_move_down1:     
                        in         al,60h
    ; call       powerUps
                        call       activatePowers
                        call       drawItems

    ;delay
                        mov        cx, 0
                        mov        dx, 30000
                        mov        ah, 86h
                        int        15h                                  ; param is cx:dx (in microseconds)

                        

                        jmp        check


    final:              
                        mov        pressedF4,0
                        mov        bh,0
                        mov        ah,2
                        mov        dl,16
                        mov        dh,12
                        int        10h
                        showmes    FinishTime

                                

                        mov        bh,0
                        mov        ah,2
                        mov        dl,18
                        mov        dh,0
                        int        10h

                        shownum    playerPoints1


                        mov        bh,0
                        mov        ah,2
                        mov        dl,20
                        mov        dh,0
                        int        10h

                        mov        ah,9                                 ;Display
                        mov        bh,0                                 ;Page 0
                        mov        al,58
                        mov        cx,1h
                        mov        bl,0Fh                               ;Green (A) on white(F) background
                        int        10h


                        mov        bh,0
                        mov        ah,2
                        mov        dl,21
                        mov        dh,0
                        int        10h
                    
                        shownum    playerPoints2

                        mov        PlayedOnce,1
                        mov        gameAbility,0
                        mov        invitedToGame,0
    ; make delay 5 seconds
                        mov        ah,2ch
                        int        21H                                  ; dh seconds
                        mov        dl,0
                        mov        si,dx                                ; save dh in si
                        mov        di,5                                 ; wait 5 seconds
    delayexit:          
                        mov        ah,2ch
                        int        21H
                        mov        dl,0
                        cmp        si,dx                                ; dh seconds
                        je         skipchangetime
                        mov        si,dx
                        dec        di
    skipchangetime:     
                        cmp        di,0
                        jne        delayexit
                  
                        jmp        start

                    
                    
main endp
end main