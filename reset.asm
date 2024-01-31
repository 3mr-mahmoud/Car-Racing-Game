EXTRN    pressedButton:BYTE 
  
EXTRN    calledstatusbefore:BYTE 
EXTRN    countSeconds:BYTE 
EXTRN    countMinutes:BYTE 

EXTRN    playerPoints1:BYTE 
EXTRN    playerPoints2:BYTE 

EXTRN    TimeIsFinsihed:BYTE 

EXTRN    generateGameData:BYTE

EXTRN    points:BYTE 
EXTRN    road_x:WORD                 
EXTRN    road_y:WORD                 
EXTRN    chosen_points:BYTE           
EXTRN    chosen_points_arr:BYTE 
EXTRN    last_move_direction:BYTE 
EXTRN    first_direction:BYTE 
EXTRN    curr_x:WORD                  
EXTRN    curr_y:WORD                 
EXTRN    items:WORD                   
EXTRN    items_x:WORD                
EXTRN    items_y:WORD                 
EXTRN    items_type:BYTE
EXTRN    score1:BYTE
EXTRN    score2:BYTE

EXTRN    x1_Car1:WORD                                        ;x1,x2,y1,y2
EXTRN    x2_Car1:WORD                 
EXTRN    y1_Car1:WORD                 
EXTRN    y2_Car1:WORD                 
EXTRN    speed_Car1:WORD              
EXTRN    left_Car1:BYTE 
EXTRN    right_Car1:BYTE 
EXTRN    up_Car1:BYTE 
EXTRN    down_Car1:BYTE 
EXTRN    powerType1:BYTE 
EXTRN    speedUp_Car1:BYTE                     ;first:status of press the key (t) of this action,  second:status of activation of this action,   third:finish second of activation
EXTRN    speedDown_Car1:BYTE                      ;first:status of press the key (y) of this action,  second:status of activation of this action,   third:finish second of activation
EXTRN    genObs_Car1:BYTE                        ;first: flag showing status of press the key (u) of this action, second:status of activation of this action
EXTRN    passObs_Car1:BYTE                        ;first:status of press the key (i) of this action,  second:status of activation of this action
EXTRN    prevState_passObs1:BYTE 
EXTRN    curState_Car1:BYTE

EXTRN    x1_Car2:WORD                                        ;x1,x2,y1,y2
EXTRN    x2_Car2:WORD                 
EXTRN    y1_Car2:WORD                 
EXTRN    y2_Car2:WORD                 
EXTRN    speed_Car2:WORD              
EXTRN    color_Car2:BYTE 
EXTRN    left_Car2:BYTE 
EXTRN    right_Car2:BYTE 
EXTRN    up_Car2:BYTE 
EXTRN    down_Car2:BYTE 
EXTRN    powerType2:BYTE 
EXTRN    speedUp_Car2:BYTE                     ;first:status of press the key (m) of this action,  second:status of activation of this action,   third:finish second of activation
EXTRN    speedDown_Car2:BYTE                   ;first:status of press the key (,) of this action,  second:status of activation of this action,   third:finish second of activation
EXTRN    genObs_Car2:BYTE                        ;first: flag showing status of press the key (.) of this action, second:status of activation of this action,
EXTRN    passObs_Car2:BYTE                        ;first:status of press the key (/) of this action,  second:status of activation of this action
EXTRN    prevState_passObs2:BYTE  
EXTRN    curState_Car2:BYTE  


    ;;;;variables for copying;;;;;;;;;;;;;;
EXTRN    x1_CarTemp:WORD                                    ;x1,x2,y1,y2
EXTRN    x2_CarTemp:WORD              
EXTRN    y1_CarTemp:WORD              
EXTRN    y2_CarTemp:WORD              
EXTRN    speed_CarTemp:WORD          
EXTRN    color_CarTemp:BYTE 
EXTRN    left_CarTemp:BYTE 
EXTRN    right_CarTemp:BYTE 
EXTRN    up_CarTemp:BYTE 
EXTRN    down_CarTemp:BYTE 
EXTRN    powerTypeTemp:BYTE 
EXTRN    speedUp_CarTemp:BYTE                      ;first:status of press the key (t) of this action,  second:status of activation of this action,   third:finish second of activation
EXTRN    speedDown_CarTemp:BYTE                  ;first:status of press the key (y) of this action,  second:status of activation of this action,   third:finish second of activation
EXTRN    genObs_CarTemp:BYTE                        ;first: flag showing status of press the key (u) of this action, second:status of activation of this action
EXTRN    passObs_CarTemp:BYTE                        ;first:status of press the key (i) of this action,  second:status of activation of this action
EXTRN    prevState_passObsTemp:BYTE  
EXTRN    curState_CarTemp:BYTE  
EXTRN    check_if_color:BYTE  
EXTRN    generateGameData:BYTE
EXTRN   item_color:BYTE

public reset

EXTRN chatAbility:BYTE
EXTRN gameAbility:BYTE
EXTRN invitedToChat:BYTE
EXTRN invitedToGame:BYTE

.model HUGE
.stack 256h

maxpoints equ 60
.code

reset proc far
mov score1,0
mov score2,0
mov pressedButton, 0
mov calledstatusbefore, 0
mov countSeconds,0
mov countMinutes, 2
mov generateGameData,0
mov TimeIsFinsihed, 0
mov points, 0
mov chosen_points,2
lea si,chosen_points_arr
mov cx,maxpoints
resetchosenpts:
mov byte ptr [si],0
inc si
loop resetchosenpts

mov chosen_points_arr,1
mov chosen_points_arr+maxpoints-1,1

mov chatAbility,0
mov gameAbility,0
mov invitedToChat,0
mov invitedToGame,0


mov last_move_direction, 2
mov first_direction, 4
mov curr_x,30
mov curr_y,100
mov items, 0
mov x1_Car1,0                      
mov x2_Car1,0
mov y1_Car1,0
mov y2_Car1,0
mov speed_Car1, 0
mov right_Car1, 0
mov up_Car1, 0
mov down_Car1, 0
mov powerType1, 0
mov speedUp_Car1, 0
mov speedUp_Car1+1, 0
mov speedUp_Car1+2, 0
mov speedDown_Car1, 0
mov speedDown_Car1+1, 0
mov speedDown_Car1+2, 0
mov genObs_Car1, 0
mov passObs_Car1, 0
mov prevState_passObs1, 0
mov curState_Car1, 0
mov x1_Car2,0
mov x2_Car2,0
mov y1_Car2,0
mov y2_Car2,0
mov speed_Car2, 0
mov color_Car2,0
mov left_Car2, 0
mov right_Car2, 0
mov up_Car2, 0
mov down_Car2, 0
mov powerType2, 0
mov speedUp_Car2, 0
mov speedUp_Car2+1, 0
mov speedUp_Car2+2, 0
mov speedDown_Car2, 0
mov speedDown_Car2+1, 0
mov speedDown_Car2+2, 0
mov genObs_Car2, 0
mov passObs_Car2, 0
mov prevState_passObs2, 0
mov curState_Car2, 0
mov x1_CarTemp,00
mov x2_CarTemp,0
mov y1_CarTemp,0
mov y2_CarTemp,0
mov speed_CarTemp, 0
mov color_CarTemp,0
mov left_CarTemp, 0
mov right_CarTemp, 0
mov up_CarTemp, 0
mov down_CarTemp, 0
mov powerTypeTemp, 0
mov speedUp_CarTemp, 0
mov speedUp_CarTemp+1, 0
mov speedUp_CarTemp+2, 0

mov speedDown_CarTemp, 0
mov speedDown_CarTemp+1, 0
mov speedDown_CarTemp+2, 0
mov genObs_CarTemp, 0
mov genObs_CarTemp+1, 0
mov passObs_CarTemp, 0
mov passObs_CarTemp+1, 0
mov prevState_passObsTemp, 0
mov curState_CarTemp, 0
mov check_if_color, 0

mov item_color,0

mov generateGameData,0
ret
reset endp
end