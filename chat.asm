EXTRN Name1:byte
EXTRN Name2:byte

EXTRN SEND:FAR
EXTRN sendData:byte

public chat

.model HUGE 
.data 
str db 190 dup('$')
ind db 0 
line db 80 dup('-'),'$'
spa db 160 dup(' '),'$'
you db 'you:','$'

bool db 1 
char db 0d,'$'
x db 0 
y db 0
myx db 0 
myy db 19 
mes db 0dh,'$'
.code 

setCursor proc 
    mov dh , y ;   
    mov dl ,x  ;  
    mov ah,2 
    mov bh,0
    int 10h 
    
    ret
setCursor endp

setMyCursor proc 
    mov dh , myy ;   
    mov dl ,myx  ;  
    mov ah,2 
    mov bh,0
    int 10h     
    ret
setMyCursor endp

scroll proc
; scroll by 3 lines
    mov ah,6       ; function 6
    mov al,3     ; scroll by 1 line    
    mov bh,7       ; normal video attribute         
    mov ch,0       ; upper left Y
    mov cl,0       ; upper left X
    mov dh,16      ; lower right Y
    mov dl,79      ; lower right X 
    int 10h

    ret
scroll endp


delete PROC
    cmp ind,0
    je ign 
    dec myx 
    call setMyCursor 
    mov spa[1],'$'
    mov ah,9
    mov dx ,offset spa
    int 21h
    mov spa[1],' '
    
    call setMyCursor
    
    mov bl ,ind
    mov bh , 0
    mov str[bx],'$'
    dec ind
    ign:

    ret 
delete ENDP

send_str PROC
    mov SI , offset str
send_strl:
    LODSB ;
    mov bl,al    

    mov dx ,3FDH
    check_thr:
    in al ,dx
    AND al ,00100000b
    jz check_thr
    mov dx ,3F8H
    mov al,bl
    out dx ,al

    cmp bl,'$' 
    je end_send_str 
                   
    jmp send_strl  
end_send_str:
   
    ret 
send_str ENDP

printmsg proc
    mov x , 0  
    cmp y,14
    jl here
    call scroll
    ;update the cursor
    mov y , 14
    mov x ,0  

    here:
    call  setCursor
    mov ah,9
    mov dx ,offset Name1
    int 21h
    
    inc y
    mov x,0  
    call setCursor
    mov ah,9
    mov dx ,offset str
    int 21h

    call send_str

    ;delete the mesage part
    mov myx ,0 
    mov myy ,19
    call setMyCursor
    mov ah,9
    mov dx ,offset spa
    int 21h
    mov myx ,0 
    mov myy ,19

    ; str =($)
    mov bx, 0
    mov cx , 180
    lo:
    mov str[bx],'$'
    inc bx
    dec cx
    loop lo

    mov ind , 0 

    inc y 
    inc y 

    ret
printmsg endp

printpl2name proc 
;start position of recieved mesage is (x=13)
    mov x ,40d
    cmp y,16d
    jl here3
    call scroll

    mov y ,14d
    mov x,40d
    here3:
    ;set the cursor postion
    call setCursor  

    ;print P2name 
    mov ah,9
    mov dx ,offset Name2
    int 21h
    ;set the cursor to the new line 
    inc y   
    mov x,40   
    call setCursor 
    mov bool , 0  

    ret 
printpl2name    endp



chat proc far 
;     mov ax,@data 
;     mov ds,ax 
; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; clear the screen
    mov ax ,0003h   ; clear the scren
    int 10h         ; clear the scren

    ; change to txt mode
    mov al,3  
    mov ah ,0 
    int 10
    ;print initale lines
    mov x,0
    mov y,21
    call setCursor    
    mov ah,9
    mov dx , offset line
    int 21h
    mov x,0
    mov y,17
    call setCursor    
    mov ah,9
    mov dx , offset line
    int 21h
    mov  y,18 ;   
    mov x ,0  ;  
    call setCursor
    ;cout<< "P1name:"
    mov ah,9
    mov dx ,offset Name1
    int 21h
    mov x, 0 
    mov y, 0  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    ;;infinte loop of the chat 
    infint:

    ;check for preesed key to input the message 
    mov ah,1
    int 16h
    jz jmpchecker2

; check for esc
    mov ah,0
    int 16h
    cmp ah,1h
    je  jmpchecker3  

    ;set the cursor to cin >> the mes 
    call setMyCursor  
    
    ;get key preesed 
    
    
    cmp al , 8d
    jne con6 
    ; add delete proc 
     call delete
     jmp no_prnt 
    con6:  

    mov bl,ind 
    mov bh , 0 
    mov str[bx],al 
    inc ind 
    
    mov char , al 
    mov ah,9
    mov dx ,offset char
    int 21h

    inc myx 


    jmp cont3
jmpchecker:
jmp infint
    cont3:

jmp cont4
jmpchecker2:
jmp rec
    cont4:


jmp cont5
jmpchecker3:
jmp escape
    cont5:  

mov al ,char 
cmp al,0dh 
jne con7
call printmsg
con7:

no_prnt:
; inc the y pos after the mes is insertes and printed
    
    
rec:

    ;Check that Data Ready
	mov dx , 3FDH		; Line Status Register
	in al , dx 
  	AND al , 1
  	JZ jmpchecker
    ; print the player name for the first time 
    and bool,1
    jz no_pr 
    call printpl2name
    no_pr:     

    ;If Ready read the VALUE in Receive data register
  		mov dx , 03F8H
  		in al , dx 
  		mov char , al
        cmp al,1
        jz exit

    call setCursor 

    cmp char,0dh 
    je no_print
    mov ah ,9
    mov dx,offset char
    int 21h
    inc x
    no_print:
    cmp x,80
    jl cont1
    mov x,40d 
    inc y
    cont1:
    cmp y,17d
    jl here1
    ; scroll by 3 lines
    call scroll

    ;update the cursor
    mov y ,14d
    mov x ,40d 
    call setCursor 
    here1:    
    

    cmp char,'$'
    je end_rec

    jmp rec
 end_rec: 
    ; inc the y pos after the mes is insertes and printed
    inc y
    inc y  
    mov x , 0   
    mov bool,1
    jmp infint
    escape:
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    mov sendData,1
    call SEND

    exit:
    RET
    
    
chat endp   

end 