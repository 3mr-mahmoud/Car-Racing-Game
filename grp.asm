  EXTRN  points:byte
  EXTRN  road_x:WORD
  EXTRN   road_y:WORD
  EXTRN   last_move_direction:byte
  EXTRN   first_direction:byte
  EXTRN   gonext:byte
  EXTRN   curr_x:WORD
  EXTRN   curr_y:WORD
  PUBLIC generateRoadPoints
  half_road_width     equ  9
  road_width          equ  18
road_part_length    equ 35
maxpoints           equ 60
.model HUGE
.code
checknext proc
               cmp  al,15
               jl   checkdown
               cmp  al,30
               jl   checkup
               jmp  checkright
  checkdown:   
               mov bx,curr_y
               add  bx,road_part_length+half_road_width
               cmp  bx,170
               JGE  clear_gonext
               JL   set_gonext
                
  checkup:     
               mov bx,curr_y
               sub  bx,road_part_length+half_road_width
               cmp  bx,0                    ; 3 > 0
               JLE  clear_gonext
               JG   set_gonext
  checkright:    
               mov bx,curr_x
               add  bx,road_part_length+half_road_width
               cmp  bx,300              ; 3 > 320
               JGE  clear_gonext
               JL   set_gonext
  set_gonext:  
               mov  gonext,1
               ret
  clear_gonext:
               mov  gonext,0
               ret
checknext endp


generateRoadPoints proc far
               mov  si,offset road_x
               mov  di,offset road_y
               mov  cx,curr_x
               mov  dx,curr_y
               mov  [si],cx          ; save first x coordinate
               mov  [di],dx          ; save first y coordinate
               add  si,2             ; goto next word
               add  di,2             ; goto next word
               inc points
       
  random:      
                MOV CX, 0H       ; High word of delay time
                MOV DX, 0FFFFH    ; Low word of delay time (3500 in hexadecimal)
                MOV AH, 86H     ; BIOS Wait function
                INT 15H          ; Call BIOS interrupt 15H
               cmp  points,maxpoints
               JE   finish_
               cmp points,0 ; if no points so far just continue
               je cont 
               ;check if I can't go anywhere
               cmp  last_move_direction,2
               je   check_up_down
              ;check right
              mov al,40 ; more than 30 and less than 99 to check if I can go right
              mov gonext,0
              call checknext
              cmp gonext,1
              je cont ; if i can go right then continue
              cmp  last_move_direction,0 ; I need to check right and down only
              je   check_down
              ;check up
check_up_down:mov al,20 ; more than 15 and less than 30 to check if I can go up
              mov gonext,0
              call checknext
              cmp gonext,1 
              je cont ; if i can go up then continue

              cmp  last_move_direction,1 ; I need to check right and up only
              je   finish_

              ;  check down
check_down:  mov al,10 ;  less than 15 to check if I can go down
              mov gonext,0
              call checknext
              cmp gonext,1 
              je cont ; if i can go down then continue
              jmp finish_

cont:
               ; get random number by getting current ms
               mov  ah,2ch
               int  21h
               mov  al,dl  ; al < 30  move down , 30 <= al < 60 move up , 60 <= al < 99 move right
               ;mov  ah,0
               ;mov  bh,3
               ;div  bh                      ;get reminder of dl in ah (0,1,2) -> (down,up,right)

               mov  gonext,0
               call checknext
               cmp  gonext,0
               je   random
               jmp skip
    finish_: jmp  finish
    skip:  
               cmp  last_move_direction,1
               je   escapedown
               cmp  al,15
               jl   down
  escapedown:  
               cmp  last_move_direction,0
               je   escapeup
               cmp  al,30
               jl   up
  escapeup:    
               cmp  last_move_direction,2
               je   escaperight
               cmp  al,99
               jle   right
  escaperight:
               jmp  random
      
  down:        
               add curr_y,road_part_length
               mov  ah,0
               jmp  savepoint
  up:
               cmp  al,15
               jl   escaperight ; if escaped from down and went to up make it get another random       
               sub curr_y,road_part_length
               mov  ah,1
               jmp  savepoint
  right:       
               cmp  al,30
               jl   escaperight ; if escaped from up and went to right make it get another random
               add curr_x,road_part_length
               mov  ah,2
               jmp  savepoint
  savepoint:
              cmp points, 1
              jne escapesavefirstdir
              mov first_direction, ah
              escapesavefirstdir:
              mov last_move_direction,ah
               mov  cx,curr_x
               mov  dx,curr_y
               mov  [si],cx          ; save x coordinate
               mov  [di],dx          ; save y coordinate
               add  si,2
               add  di,2
               inc  points
               jmp  random
  finish:
               ret

generateRoadPoints endp
; check if my next direction is out of my screen boundaries
end