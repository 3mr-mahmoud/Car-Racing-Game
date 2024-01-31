drawRow MACRO x1,x2,y,color     ;draw a row for car or clear a row for path
    local newPixel,moveline
    mov cx,x1
    mov dx,y
    newPixel:
    cmp cx,x2    
    jg moveline
    mov al,color
    mov ah,0ch
    int 10h
    inc cx
    jmp newPixel
    moveline:
ENDM drawRow    

draw_col Macro cl1,ro1,ro2,color    ;draw a col for car or clear a col for path
    local drowUpDown
    mov cx,cl1
    mov dx ,ro1
    mov al ,color
    mov ah, 0CH
drowUpDown: int 10h
    inc dx
    cmp dx ,ro2
    jle drowUpDown
EndM draw_col

drawCar Macro cl1,row1,cl2,row2,color
    local draw
    mov si,cl1
    draw: draw_col si,row1,row2,color
    inc si
    cmp si,cl2
    jle draw  
EndM drawCar

initialCar MACRO y1Car,y2Car,x1Car,x2Car,speedCar,colorCar,flagdirection,car_name
    mov y1_CarTemp,y1Car
    mov y2_CarTemp,y2Car
    mov x1_CarTemp,x1Car
    mov x2_CarTemp,x2Car
    mov speed_CarTemp,speedCar
    mov color_CarTemp,colorCar
    mov flag_direction_temp,flagdirection

    push si
    push di
    push cx

    mov cx,ds
    mov es,cx
    mov si,offset car_name
    mov di,offset filename
    mov cx,12
    REP MOVSB
    pop cx
    pop di
    pop si  
ENDM

copy_Car MACRO from ,to
    push si
    push di
    push cx

    mov cx,ds
    mov es,cx
    mov si,offset from
    mov di,offset to
    mov cx,5
    REP MOVSW
    mov cx,27
    REP MOVSB

    pop cx
    pop di
    pop si
    
ENDM




showmes macro str
                   mov     ah,09h
                   lea     dx,str
                   int     21h
                   endm    showmes

showchar macro str
                   mov     ah,02h
                   mov     dl,str
                   int     21h
                   endm    showchar

shownum macro str
                   mov     ah,0
                   mov     al,str
                   mov     bl,10
                   div     bl
  
                   mov     LeftDigit,al
                   mov     RightDigit,ah
                   add     LeftDigit,48        ;leftDigit  Ascii
                   add     RightDigit,48       ;rightDigit Ascii
                
                   mov     dl,LeftDigit
                   mov     ah,2
                   int     21h
               
  
                   mov     dl,RightDigit
                   mov     ah,2
                   int     21h
                    endm     shownum                   


