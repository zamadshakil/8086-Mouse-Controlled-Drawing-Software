; =============================================================
; 8086 Paint Project
; Controls: Left Click=Draw, Right Click=Erase
; Keys: 1-3=Color, +/-=Brush Size, c=Clear, x=Exit
; =============================================================

.MODEL SMALL
.STACK 100H
.DATA
    current_color DB 1
    brush_size    DB 2
    temp_x        DW 0
    temp_y        DW 0
    draw_color    DB 0 

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, 0013H
    INT 10H

    MOV AX, 0
    INT 33H
    CMP AX, 0
    JE EXIT_PROG        

    MOV AX, 1
    INT 33H

MAIN_LOOP:
    MOV AH, 01H
    INT 16H
    JZ CHECK_MOUSE
    
    MOV AH, 00H
    INT 16H
    
    CMP AL, 'x'
    JE EXIT_PROG
    CMP AL, 'c'
    JE CLEAR_SCREEN
    
    CMP AL, '1'
    JE SET_BLUE
    CMP AL, '2'
    JE SET_GREEN
    CMP AL, '3'
    JE SET_RED
    
    CMP AL, '+'
    JE INCREASE_SIZE
    CMP AL, '-'
    JE DECREASE_SIZE
    
    JMP CHECK_MOUSE

INCREASE_SIZE:
    CMP brush_size, 10
    JGE CHECK_MOUSE
    INC brush_size
    JMP CHECK_MOUSE

DECREASE_SIZE:
    CMP brush_size, 1
    JLE CHECK_MOUSE
    DEC brush_size
    JMP CHECK_MOUSE

SET_BLUE:
    MOV current_color, 1
    JMP CHECK_MOUSE
SET_GREEN:
    MOV current_color, 2
    JMP CHECK_MOUSE
SET_RED:
    MOV current_color, 4
    JMP CHECK_MOUSE

CLEAR_SCREEN:
    MOV AX, 0013H
    INT 10H
    MOV AX, 1
    INT 33H
    JMP MAIN_LOOP

CHECK_MOUSE:
    MOV AX, 3
    INT 33H

    TEST BX, 1
    JNZ SETUP_DRAW
    TEST BX, 2
    JNZ SETUP_ERASE
    
    JMP MAIN_LOOP

SETUP_ERASE:
    MOV draw_color, 0
    JMP START_PLOT

SETUP_DRAW:
    MOV AL, current_color
    MOV draw_color, AL
    JMP START_PLOT

START_PLOT:
    SHR CX, 1

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AX, 2
    INT 33H

    POP DX
    POP CX
    POP BX
    POP AX

    MOV AX, 0
    MOV AL, brush_size
    MOV temp_y, AX
    
    MOV AX, DX
    PUSH AX

DRAW_ROW_LOOP:
    MOV AX, 0
    MOV AL, brush_size
    MOV temp_x, AX
    
    PUSH CX

DRAW_PIXEL_LOOP:
    MOV AH, 0CH
    MOV AL, draw_color
    MOV BH, 0
    INT 10H
    
    INC CX
    DEC temp_x
    JNZ DRAW_PIXEL_LOOP

    POP CX
    INC DX
    DEC temp_y
    JNZ DRAW_ROW_LOOP

    POP AX

    MOV AX, 1
    INT 33H

    JMP MAIN_LOOP

EXIT_PROG:
    MOV AX, 0003H
    INT 10H
    MOV AH, 4CH
    INT 21H

MAIN ENDP
END MAIN
