INCLUDE macros.inc
EXTRN pressedButton:BYTE
EXTRN PlayedOnce:BYTE

EXTRN Name1:byte
EXTRN Name2:byte

EXTRN sendData:byte
EXTRN receivedData:byte

public HOME,SEND,printStatus,clear_status,RECEIVE
.MODEL SMALL
.DATA

      enter_username    db    0
      emptystring     db 20 dup(' '),'$'
      userName        db 15,?,15 dup('$')
      invalidusername db 'Invalid User Name','$'
      message1        db 'Please Enter Your Name:','$'
      message1Size    equ $-message1
      ; Name1        db 15,?,15 dup('$')
    
      message3        db 'Press Enter Key to continue','$'

      message4        db 'To Start Chatting press F2','$'

      message5        db 'To start the game press F1','$'

      message6        db 'To end the program press ESC','$'
      NoOneInRoom        db 'There is no Player in the room','$'

      clearStatusMSG  db 80 dup(' '),'$'
      seperatingLine  db 80 dup('-'),'$'
      playerExits           equ 9
.code

printStatus proc FAR
push dx
                     mov ah,2
                     mov dl,0
                     mov dh,22
                     int 10h
                        mov ah,9
                        pop dx
                        int 21h
                        ret
printStatus endp

clear_status proc       FAR

 lea dx,clearStatusMSG
call printStatus
ret
clear_status endp

SEND PROC FAR
                
                        mov        dx , 3FDH
    AG:                 in         al, dx                               ;Read Line Status
                        AND        al , 00100000b
                        JZ         AG
                        mov        dx , 3F8H                            ; Transmit data register
                        mov        al,sendData
                        out        dx , al
                
                        RET
SEND ENDP

RECEIVE PROC FAR
                
                        ;Check that Data Ready
  waitRec:  
      mov dx , 3FDH        ; Line Status Register
      in al , dx 
      AND al , 1
      JZ waitRec
    
    ;If Ready read the VALUE in Receive data register
      mov dx , 03F8H
      in al , dx 
      mov receivedData , al
                
                        RET
RECEIVE ENDP



sendName proc FAR
                        lea dx,NoOneInRoom
                        call printStatus
          
                        mov        bx,0
    send_char:          mov        al,byte ptr Name1[bx]
                        cmp        al,'$'
                        jne        continue_send
                        mov        sendData, al
                        call       SEND
                        RET

    continue_send:      
                        mov        sendData ,al
                        call       SEND

    waiting_success:    
                        CALL       checkExit
                        mov        dx , 3FDH                            ; Line Status Register
                        in         al , dx                              ;chk if i recived something
                        AND        al , 1
                        cmp        al, 1
                        jne        waiting_success                      ;if not continue looping
                        mov        dx , 03F8H                           ;else get character in al|value
                        in         al , dx

                        inc        bx                                   ;update character
                        jmp        send_char

                        ret

sendName endp

checkExit proc
mov ah, 1               ; if click on something
                int 16h                 
                jz skipexit         ;if nothing
                mov ah, 0       
                int 16h
                cmp ah, 1h              ;chk if key pressed = esc
                jne skipexit
                mov sendData, playerExits
                call SEND
                mov ax, 0003h                                  ; clear screen
                int 10H
                MOV      AH, 4CH ;quit
                INT      21H
        skipexit:
                RET

checkExit endp


receiveName proc FAR
                        mov        bx,0
                  wait_receive:
                        mov        dx , 3FDH                            ; Line Status Register
                        in         al , dx
                        AND        al , 1
                        cmp        al,1
                        jne        wait_receive

                         mov dx , 03F8H  ;else get character in al|value
                        in al , dx
                        mov Name2[bx], al
                        inc bx
                        cmp al, '$'
                        jne continue_receive
                        RET
                  continue_receive:
                        mov sendData, 1    ;send acceptance
                        CALL SEND
                        jmp wait_receive
                        RET
receiveName endp

send_receiveName proc FAR

    CALL clear_status
                        mov        dx , 3FDH                            ; Line Status Register
                        in         al , dx
                        AND        al , 1
                        cmp        al,1
                        jne        no_receive
                        call       receiveName
                        call       sendName
                        ret
    no_receive:         
                        call       sendName
                        call       receiveName
                        ret

send_receiveName endp

HOME PROC FAR
                     mov AX,@DATA
                     mov DS,AX
      ; Move cursor to row 9, column 12
                  

                     mov ax,0003h
                     int 10h
                        cmp enter_username,1
                        je Restart

                        
                  
                     mov ah,2
                     mov dl,12
                     mov dh,9
                     int 10h
      ; Displat message3
                     mov ah, 9
                     mov dx, offset message3
                     int 21h
      enteruseragain:
      ; Move cursor to row 10, column 12
                     mov ah,2
                     mov dl,12
                     mov dh,11
                     int 10h
    
      ; Display message1
                     mov ah, 9
                     mov dx, offset message1
                     int 21h
    
      ; Get user name input
                     mov ah,0AH
                     mov dx,offset userName
                     int 21h
      ; check first byte
                     cmp userName+2,65
                     JL  showinvalid                     ; less than 65 invalid
                     cmp userName+2,90
                     JLE continue                        ; greater than 65 and less than or equal 90 continue
      ; greater than 90
                     cmp userName+2,122
                     JG  showinvalid
                     cmp userName+2,97                   ; less than or equal 122 and greater than or equal 97
                     JGE continue
            
    
                 
                 
      showinvalid:   
      ; Move cursor to row 10, column 12
                     mov ah,2
                     mov dl,12+message1Size-1
                     mov dh,11
                     int 10h
      ; remove old name
                     mov ah, 9
                     mov dx, offset emptystring
                     int 21h
      ; move cursor
                     mov ah,2
                     mov dl,12
                     mov dh,6
                     int 10h
      ; display invalid message
                     mov ah, 9
                     mov dx, offset invalidusername
                     int 21h
                     jmp enteruseragain
      continue:      
                  mov enter_username,1
                  mov ax,@data
                  mov es,ax
                  lea si,userName+2
                  lea di,Name1
                  mov cl,userName[1]
                  mov ch,0
                  rep movsb


                  Restart:
                                 
                     mov ax,0003h
                     int 10h

                     mov ah,2
                     mov dl,12
                     mov dh,10
                     int 10h

                     mov ah,9
                     mov dx,offset message4
                     int 21h

                     mov ah,2
                     mov dl,12
                     mov dh,11
                     int 10h

                     mov ah,9
                     mov dx,offset message5
                     int 21h

                     mov ah,2
                     mov dl,12
                     mov dh,12
                     int 10h

                     mov ah,9
                     mov dx,offset message6
                     int 21h

                     mov ah,2
                     mov dl,0
                     mov dh,21
                     int 10h

                     mov ah,9
                     mov dx,offset seperatingLine
                     int 21h
                     
            cmp PlayedOnce,1
            jz no_connection
            call send_receiveName
            call clear_status     

            no_connection:   
ret

      notValid:      
                     mov ah,0
                     int 16h

                     cmp ah, 3Bh
                     je  retButton
                     cmp ah, 3Ch
                     je  retButton
                     cmp ah, 1h
                     je  quit

                     jmp notValid

            

          

      retButton:     
                     mov pressedButton,ah
                     ret
      quit:
      mov ax,0003h
                     int 10h
      MOV AH, 4CH ; service 4CH - exit with a return code
MOV AL, 01  ; your return code
INT 21H

HOME ENDP
END