INCLUDE macros.inc
EXTRN filename:BYTE
EXTRN flag_direction_temp:BYTE    ;0->up 1->down 2->left 3->right
EXTRN xc_Car:WORD
EXTRN yc_Car:WORD

;times of reduce the blue car image is 11,     times of reduce the red car image is 11

public CAR

; public Screen
;---------------------------------------
.MODEL SMALL

;---------------------------------------
.DATA

; backGround  db      'Grass.bin',0
; BackGround_size equ 320*200
; backGround_buffer db BackGround_size dup(?)
; GROUND_HEIGHT equ 200
; GROUND_WIDTH equ 320


buffer_size equ 35
buffer db buffer_size dup(?)

errtext db "YOUR ERROR MESSAGE", 10, "$"

start_Xtemp      dw      155
start_Ytemp      dw      100

CAR_HEIGHT equ 3;YOUR HEIGHT
CAR_WIDTH equ 2;YOUR WIDTH

SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
;---------------------------------------
.code

;description
; Screen      proc    far
;     mov ah, 03Dh
;     mov al, 0 ; open attribute: 0 - read-only, 1 - write-only, 2 -read&write
;     mov dx, offset backGround ; ASCIIZ filename to open
;     int 21h

;     ;jc error_exit       ; Jump if carry flag set (error)

;     mov bx, AX
;     mov ah, 03Fh
;     mov cx, BackGround_size ; number of bytes to read
;     mov dx, offset backGround_buffer ; were to put read data
;     int 21h


;     ; Check for errors
;     ;jc error_exit       ; Jump if carry flag set (error)

;     mov ah, 3Eh         ; DOS function: close file
;     INT 21H
        
;     MOV AX, 0A000h 
;     MOV ES, AX

;     mov si,offset backGround_buffer
;     mov di,0
;     call drawScreen

;     ret
; Screen endp

; ;description
; drawScreen PROC
;         MOV DX,GROUND_HEIGHT

;     REPEAT_BACK:
;     MOV CX,GROUND_WIDTH
;     DRAW_PIXELS_BACK:
;         ; Check if the byte at [SI] is 250 TO SKIP IT
;         mov AH,BYTE PTR [SI]
;         CMP BYTE PTR [SI], 250
;         JE SKIP_DRAW_BACK

;         ; Draw the pixel
;         MOVSB        ;increment di after moving car pixel from si to di(screen) and point (x,y) is top left in BACK movement
;         JMP DECC_BACK

;         SKIP_DRAW_BACK:
;         INC DI
;         INC SI

;         DECC_BACK:
;         DEC CX
        

;         JNZ DRAW_PIXELS_BACK

;     ADD DI,SCREEN_WIDTH - GROUND_WIDTH
;     DEC DX
;     JNZ REPEAT_BACK

;     RET

; drawScreen ENDP

CAR PROC FAR
    ;call Clear_old
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    mov ah, 03Dh
    mov al, 0 ; open attribute: 0 - read-only, 1 - write-only, 2 -read&write
    mov dx, offset filename ; ASCIIZ filename to open
    int 21h

    ;jc error_exit       ; Jump if carry flag set (error)

    mov bx, AX
    mov ah, 03Fh
    mov cx, buffer_size ; number of bytes to read
    mov dx, offset buffer ; were to put read data
    int 21h


    ; Check for errors
    ;jc error_exit       ; Jump if carry flag set (error)

    mov ah, 3Eh         ; DOS function: close file
    INT 21H

    cmp flag_direction_temp,0
    jnz not_Up
    ;dec word ptr yc_Car
    mov bx,word ptr xc_Car
    sub bx,CAR_WIDTH
    mov start_Xtemp,bx
    mov bx,word ptr yc_Car
    sub bx,CAR_HEIGHT
    mov start_ytemp,bx   

    not_Up:
    cmp flag_direction_temp,1
    jnz not_Down
    ;inc word ptr yc_Car
    mov bx,word ptr xc_Car
    add bx,CAR_WIDTH
    mov start_Xtemp,bx
    mov bx,word ptr yc_Car
    add bx,CAR_HEIGHT
    mov start_ytemp,bx   

    not_down:
    cmp flag_direction_temp,3
    jnz not_Left
    ;dec word ptr xc_Car
    mov bx,word ptr xc_Car
    sub bx,CAR_HEIGHT
    mov start_Xtemp,bx
    mov bx,word ptr yc_Car
    add bx,CAR_WIDTH
    mov start_ytemp,bx   
    add start_Xtemp,6
    sub start_Ytemp,4


    not_Left:
    cmp flag_direction_temp,2
    jnz not_Right
    ;inc word ptr xc_Car
    mov bx,word ptr xc_Car
    add bx,CAR_HEIGHT
    mov start_Xtemp,bx
    mov bx,word ptr yc_Car
    sub bx,CAR_WIDTH
    mov start_ytemp,bx
    sub start_Xtemp,6
    add start_Ytemp,4

    not_Right:


    mov bx,320
    mov ax,start_Ytemp
    mul bx
    add ax,start_Xtemp
    MOV DI,ax
    MOV AX, 0A000h 
    MOV ES, AX
    
    ;dec X2_temp
    ;dec Y2_temp
    ;drawCar X1_temp,Y1_temp,X2_temp,Y2_temp,01h

    MOV SI,offset buffer

    cmp flag_direction_temp,0
    jnz not_Drawup
    CALL drawImageUP
    jmp exit
    not_Drawup:
    cmp flag_direction_temp,1
    jnz not_Drawdown
    CALL drawImageDown
    jmp exit
    not_Drawdown:
    cmp flag_direction_temp,2
    jnz not_Drawleft
    CALL drawImageLeft
    jmp exit
    not_Drawleft:
    CALL drawImageRight

    exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    RET 

CAR ENDP



drawImageUP PROC
    ;MOV SI,offset buffer
    
    MOV DX,2*CAR_HEIGHT+1

    REPEAT_UP:
    MOV CX,2*CAR_WIDTH+1
    DRAW_PIXELS_UP:
        ; Check if the byte at [SI] is 250 TO SKIP IT
        mov AH,BYTE PTR [SI]
        CMP BYTE PTR [SI], 250
        JE SKIP_DRAW_UP

        ; Draw the pixel
        MOVSB        ;increment di after moving car pixel from si to di(screen) and point (x,y) is top left in up movement
        JMP DECC_UP

        SKIP_DRAW_UP:
        INC DI
        INC SI

        DECC_UP:
        DEC CX
        

        JNZ DRAW_PIXELS_UP

    ADD DI,SCREEN_WIDTH - (2*CAR_WIDTH+1)
    DEC DX
    JNZ REPEAT_UP

    RET
drawImageUP ENDP

drawImageDown PROC
    ;MOV SI,offset buffer
    
    MOV DX,2*CAR_HEIGHT+1
    REPEAT_DOWN:
    MOV CX,2*CAR_WIDTH+1
    DRAW_PIXELS_DOWN:
        ; Check if the byte at [SI] is 250 TO SKIP IT
        mov AH,BYTE PTR [SI]
        CMP BYTE PTR [SI], 250
        JE SKIP_DRAW_DOWN

        ; Draw the pixel
        MOVSB       ;increment di after moving car pixel from si to di(screen)
        sub di,2    ;as in down movement the point (x,y) in bottom right and subtract two (one for increment due to MOVSB and one for move to The place before it)
        JMP DECC_DOWN

        SKIP_DRAW_DOWN:
        DEC DI
        INC SI

        DECC_DOWN:
        DEC CX

        JNZ DRAW_PIXELS_DOWN

    SUB DI,SCREEN_WIDTH - (2*CAR_WIDTH+1)
    DEC DX
    JNZ REPEAT_DOWN

    RET

drawImageDown ENDP

drawImageRight PROC

    ;MOV SI,offset buffer
    
    MOV DX, 2*CAR_HEIGHT+1
    REPEAT_RIGHT:
    MOV CX, 2*CAR_WIDTH+1
    DRAW_PIXELS_RIGHT:
        ; Check if the byte at [SI] is 250 TO SKIP IT
        mov AH,BYTE PTR [SI]
        CMP BYTE PTR [SI], 250
        JE SKIP_DRAW_RIGHT

        ; Draw the pixel
        MOVSB       ;increment di after moving car pixel from si to di(screen) and ponit (x,y) is top right in right movement
        add di,SCREEN_WIDTH-1
        JMP DECC_RIGHT

        SKIP_DRAW_RIGHT:
        add di,SCREEN_WIDTH
        INC SI

        DECC_RIGHT:
        DEC CX

        JNZ DRAW_PIXELS_RIGHT

    SUB DI,SCREEN_WIDTH * (2*CAR_WIDTH+1) +1
    DEC DX
    JNZ REPEAT_RIGHT

    RET

drawImageRight ENDP

drawImageLeft PROC
    ;MOV SI,offset buffer
    
    MOV DX, 2*CAR_HEIGHT+1
    REPEAT_LEFT:
    MOV CX, 2*CAR_WIDTH+1
    DRAW_PIXELS_LEFT:
        ; Check if the byte at [SI] is 250 TO SKIP IT
        mov AH,BYTE PTR [SI]
        CMP BYTE PTR [SI], 250
        JE SKIP_DRAW_LEFT

        ; Draw the pixel
        MOVSB       ;increment di after moving car pixel from si to di(screen) and ponit (x,y) is bottom left in left movement
        sub di,SCREEN_WIDTH +1
        JMP DECC_LEFT

        SKIP_DRAW_LEFT:
        sub di,SCREEN_WIDTH
        INC SI

        DECC_LEFT:
        DEC CX

        JNZ DRAW_PIXELS_LEFT

    add DI,SCREEN_WIDTH * (2*CAR_WIDTH+1) +1
    DEC DX
    JNZ REPEAT_LEFT

    RET

drawImageLeft ENDP

END 


