IDEAL
MODEL small

BMP_WIDTH = 320
BMP_HEIGHT = 200

STACK 100h

;file names
FILE_NAME_IN  equ 'back.bmp'
FILE_NAME_START equ 'start.bmp'


;macros
macro PUSH_ALL ; push all registers
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
endm PUSH_ALL

macro POP_ALL ; pop all registers
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
endm POP_ALL

macro DRAW_FULL_BMP
	;mov dx, ?
	push 0
	push 0
	push 320
	push 200
	call DrawPictureBmp
endm DRAW_FULL_BMP

macro PUSH_ALL_BP
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
endm PUSH_ALL_BP

macro POP_ALL_BP
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
endm POP_ALL_BP

DATASEG
; --------------------------
; Your variables here
	; -- Cube variables --
	
	; -- loop var --
	IsExit db 0
	
	; -- jump vars --
	can_jump db 1 ; will sign if we are falling from a platform
	
	;rotation
	timeInAir db 0
	
	;directions bools 
	Is_Going_up db ?
	Is_Going_down db ?
	Is_Falling  db ?
	
	;height calculation
	Max_height dw ? ; max height when jumping will be calculated once
	Middle_Height dw ? ; to slow down mid jump
	bool_calc_max_height db 0 ; if we have calculated max height to not repeat
	
	
	bool_landed_block db 0 ; if landed on block
	Is_On_Block db 0 ; if is now on block
	
	; -- position --
	
	;cube
	Xpos dw 50
	Ypos dw 143
	
	
	; - blocks - 
	;cube
	
	Xpos_Blocks dw 270
	Ypos_Blocks dw 143
	Blocks_Alive db 1
	
	
	;Triangle
	Xpos_Triangle dw 447
	Ypos_Triangle dw 152
	Triangle_Alive db 1
	
	;Tower
	Xpos_Tower dw 320
	Ypos_Tower dw ? ; ypos is calculated by how many blocks we want
	Height_Tower dw ?
	Tower_Alive db 1
	
	; -- drawing using matrix --
	
	;erasing cube
	matrix_erase_cube db 324 dup (?)
			
	; - triangle block -
	matrix_triangle db  -2,  -2,   -2,  -2,  -2,  -2,  -2,  -2,0ffh,0ffh,-2,  -2,   -2,  -2,  -2,  -2,    -2,-2
					db  -2,  -2,   -2,  -2,  -2,  -2,  -2,0ffh,0,0,0ffh,-2,   -2,  -2,  -2,  -2,    -2,-2
					db  -2,  -2,   -2,  -2,  -2,  -2,0ffh,0,  0,  0,  0,0ffh, -2,  -2,  -2,  -2,    -2,-2
					db  -2,  -2,   -2,  -2,  -2,0ffh, 0,  0,  0,  0,  0,  0,0ffh,-2,  -2, -2,-2,-2
					db  -2,  -2,   -2,  -2,0ffh,  0,  0,  0,  0,  0,  0,  0, 0,0ffh,-2,  -2, -2,-2
					db   -2,  -2,  -2,0ffh,0, 0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh,-2,  -2, -2
					db   -2,  -2,0ffh,0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh, -2, -2
					db   -2,0ffh, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh, -2
					db 0ffh,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh
	
	;erasing the triangle
	matrix_erase_triangle db 162 dup (?)
	
	; -- blocks --
	matrix_blocks  db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,0   ,   0,   0,   0,   0,   0,0ffh
					db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	;erasing block
	matrix_erase_blocks db 324 dup (?)
	;erase tower
	
	matrix_erase_tower db 324 dup (?)
	matrix_erase_tower1 db 324 dup (?)
	matrix_erase_tower2 db 324 dup (?)
	matrix_erase_tower3 db 324 dup (?)
	matrix_erase_tower4 db 324 dup (?)

	
	
	matrix dw ? ; holds the offset of the mtarix we want to print
	
	
	
	; -- FILES --
	
	; background bmp picture var

    OneBmpLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
   
    ScrLine 	db BMP_WIDTH + 4 dup (0)  ; One Color line read buffer

	;BMP File data
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	ErrorFile db ?
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ',FILE_NAME_IN, 0dh, 0ah,'$'
	
	FileName_background db 'back.bmp' ,0
	FileName_start db 'start.bmp', 0
	FileName_cube db 'cube.bmp', 0
	
	;cube rotation frames
	FileName_cube10 db 'cube10.bmp', 0
	FileName_cube20 db 'cube20.bmp', 0
	FileName_cube30 db 'cube30.bmp', 0
	FileName_cube40 db 'cube40.bmp', 0
	FileName_cube50 db 'cube50.bmp', 0
	FileName_cube60 db 'cube60.bmp', 0
	FileName_cube70 db 'cube70.bmp', 0
	FileName_cube80 db 'cube80.bmp', 0
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here

	call SetGraphics
	
	
	call DrawStartScreen
	
	;mouse show
	call MouseShow
	
	call DrawBackground
	call DrawBlock
	call DrawCube
	call Draw_Triangle
	mov cx, 3
	mov [Height_Tower], cx
	call Draw_Tower
	
	xor ax, ax
	int 16h
	
	draw:
	call Key_Check
	
	cmp [IsExit], 1
	je cont
	;call DrawBackground
	
	;erase
	call Erase_Block
	call Erase_Triangle
	call Erase_Tower
	
	sub [Xpos_Triangle], 5
	
	sub [Xpos_Tower],5
	
	sub [Xpos_Blocks], 5
	
	mov cx, [Height_Tower]
	call Draw_Tower
	
	call DrawBlock
	
	call Draw_Triangle
	
	call Cube_Move
	
	push 70 ; ms
	call LoopDelay
	jmp draw
	
	cont:
; --------------------------

exit:
	mov ax, 4c00h
	int 21h

;delay by ms - through stack

proc LoopDelay
	push bp
	mov bp, sp
	push cx

	mov cx, [bp + 4]
	@@self1:
	push cx
	mov cx, 3000
	@@self2:
	loop @@self2
	pop cx
	loop @@self1
	pop cx
	pop bp
	
	ret 2
endp LoopDelay

proc MouseShow
	PUSH_ALL

	mov ax, 1
	int 33h

	@@wait_for_left:
	mov ax, 3
	int 33h
	
	shr cx, 1
	cmp bx, 1
	jne @@wait_for_left
	
	cmp cx, 120
	jb @@wait_for_left
	
	cmp cx, 190
	ja @@wait_for_left
	
	cmp dx, 90
	jb @@wait_for_left
	
	cmp dx, 150
	ja @@wait_for_left
	
	mov ax, 2
	int 33h

	POP_ALL
	ret
endp MouseShow

;BMP pictures opening proc - 254 lines

proc OpenShowBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call  ShowBmp
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile
 

; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile


proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette

 
proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine
	;rep movsb ; Copy line to the screen
	@@put_screen:
	mov al, [ds:si]
	cmp al, 1
	je @@dont_draw
	mov [es:di], al
	@@dont_draw:
	inc di
	inc si
	loop @@put_screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 

	

; Read 54 bytes the Header
proc PutBmpHeader	near					
	mov ah,40h
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp PutBmpHeader
 



proc PutBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	mov ah,40h
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp PutBmpPalette


;================================================
; Description -  draws a bmp picture
; INPUT: stack - order of push - x, y, col size, row size and dx needs to be the offset of file name
; OUTPUT: picture on screen in visual mode
; Register Usage: None
;================================================
proc DrawPictureBmp
	PUSH_ALL_BP
	
	mov ax, [bp + 10];x
	mov bx, [bp + 8];y
	mov cx, [bp + 6]; length
	mov si, [bp + 4]; height
	
	mov [BmpLeft],ax
	mov [BmpTop],bx
	mov [BmpColSize], cx
	mov [BmpRowSize] ,si
	
	call OpenShowBmp
	cmp [ErrorFile],1
	jne @@cont 
	jmp exitError
@@cont:

	
    jmp @@end
	
exitError:
	mov ax,2
	int 10h
	
    mov dx, offset BmpFileErrorMsg
	mov ah,9
	int 21h
	
	@@end:
	POP_ALL_BP
	ret 8
endp DrawPictureBmp	
	
;BMP pictures end

;================================================
; Description -  sets to graphics mode
; INPUT: None
; OUTPUT: dos box set to graphics mode
; Register Usage: None
;================================================
proc SetGraphics
	push ax
	mov ax, 13h
	int 10h
	pop ax
	ret
endp SetGraphics

; in dx how many cols 
; in cx how many rows
; in matrix - the bytes
; in di start byte in screen (0 64000 -1)

proc putMatrixInScreen
	PUSH_ALL
	
	mov ax, 0A000h
	mov es, ax
	cld
	
	push dx
	mov ax,cx
	mul dx
	mov bp,ax
	pop dx
	
	
	mov si,[matrix]
	
@@NextRow:	
	push cx
	
	mov cx, dx
	
	@@draw_line:	; Copy line to the screen
	mov al, [byte ds:si]
	cmp al, -2
	je @@end ; if it is equal to minus one we need to skip it
	mov [byte es:di], al
	@@end:
	inc si
	inc di
	loop @@draw_line
	
	sub di,dx
	add di, 320
	
	
	pop cx
	loop @@NextRow
	
	
endProc:	
	
	POP_ALL
    ret
endp putMatrixInScreen

; in dx how many cols 
; in cx how many rows
; in matrix - the offset of the var we want to copy to
; in di start byte in screen (0 64000 -1)
proc putMatrixInData
	PUSH_ALL
	
	mov ax, 0A000h
	mov es, ax
	cld
	
	push dx
	mov ax,cx
	mul dx
	mov bp,ax
	pop dx
	
	
	mov si,[matrix]
	
@@NextRow:	
	push cx
	
	mov cx, dx
	
	@@copy_data:	; Copy line to the screen
	mov al, [byte es:di]
	cmp al, -2
	je @@end ; if it is equal to minus one we need to skip it
	mov [byte ds:si], al
	@@end:
	inc si
	inc di
	loop @@copy_data
	
	sub di,dx
	add di, 320
	
	
	pop cx
	loop @@NextRow
	
	

	
	POP_ALL
    ret
endp putMatrixInData
;================================================
; Description -  draws cube using putMatrixInScreen and Xpos and Ypos variables
; INPUT: None
; OUTPUT: matrix1 drawn on screen
; Register Usage: None
;================================================


;draw all shapes

;cube - using matrix in screen
proc DrawCube
	PUSH_ALL
	
	;di = Ypos * 320 + Xpos (place on screen)
	
	mov ax, [Ypos]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos]
	
	;size
	mov cx, 18 ; rows
	mov dx, 18 ; cols
	
	call Copy_Background_Cube ; we will copy the background firstly
	
	;put a bmp picture of cube
	call Pick_bmp_by_height
	
	POP_ALL
	ret
endp DrawCube

;for rotation - we check the height and then print the picture
proc Pick_bmp_by_height
	PUSH_ALL
	
	dec [Ypos]
	push [Xpos]
	push [Ypos]
	inc [Ypos]
	mov ax, 18
	push ax
	push ax
	
	cmp [timeInAir], 0 ; if timer is zero we need to print the 90 degrees even if not on ground
	je @@90_deg
	
	cmp [can_jump], 0 ; if on ground or block
	je @@in_air
	
	@@90_deg:
	mov [timeInAir], 0
	mov dx, offset FileName_cube
	jmp @@print

	@@in_air:
	
	cmp [timeInAir], 1
	je @@10_deg
	
	cmp [timeInAir], 2
	je @@20_deg

	cmp [timeInAir], 3
	je @@30_deg

	cmp [timeInAir], 4
	je @@40_deg

	cmp [timeInAir], 5
	je @@50_deg

	cmp [timeInAir], 6
	je @@60_deg

	cmp [timeInAir], 7
	je @@70_deg

	cmp [timeInAir], 8
	je @@80_deg
	
	@@10_deg:
	mov dx, offset FileName_cube10
	jmp @@print
	
	@@20_deg:
	mov dx, offset FileName_cube20
	jmp @@print
	
	@@30_deg:
	mov dx, offset FileName_cube30
	jmp @@print
	
	@@40_deg:
	mov dx, offset FileName_cube40
	jmp @@print
	
	@@50_deg:
	mov dx, offset FileName_cube50
	jmp @@print	
	
	@@60_deg:
	mov dx, offset FileName_cube60
	jmp @@print	
	
	@@70_deg:
	mov dx, offset FileName_cube70
	jmp @@print	
	
	@@80_deg:
	mov dx, offset FileName_cube80


	@@print:
	inc [timeInAir]
	cmp [timeInAir], 9 ; if equal to ten mak it zero
	jb @@end
	
	mov [timeInAir], 0
	
	@@end:
	call DrawPictureBmp

	POP_ALL
	ret
endp Pick_bmp_by_height

;we will draw the saved background on the cube to erase it
proc Erase_Cube
	PUSH_ALL
	mov ax, [Ypos]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos]
	
	mov cx, 18
	mov dx, 18
	
	mov bx, offset matrix_erase_cube
	mov [matrix], bx
	
	call putMatrixInScreen
	POP_ALL
	ret
endp Erase_Cube

proc Copy_Background_Cube
	PUSH_ALL
	
	;the other parameters are calculated before
	
	mov bx, offset matrix_erase_cube ; the data will be stored here
	mov [matrix], bx
	
	call putMatrixInData
	POP_ALL
	ret
endp Copy_Background_Cube

;block - we need to check where is the cube to know how to print it
;we will print it with thirds - so it will enter smoothly into screen form right
proc DrawBlock
	PUSH_ALL
	
	cmp [Xpos_Blocks], 301 ; if this is out of screen dont draw
	ja @@kill_block
	
	mov [Blocks_Alive], 1
	
	;now we calculate the place
	mov ax, [Ypos_Blocks]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Blocks]
	
	mov cx, 18
	mov dx, 18
	
	;firstly we will copy the background
	call Copy_Background_Blocks
	
	mov bx, offset matrix_blocks
	mov [matrix], bx 
	
	call putMatrixInScreen
	jmp @@end
	
	@@kill_block:
	mov [Blocks_Alive], 0
	
	@@end:
	POP_ALL
	ret
endp DrawBlock


proc Erase_Block
	PUSH_ALL

	cmp [Blocks_Alive], 0
	je @@end

	mov ax, [Ypos_Blocks]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Blocks]
	
	mov cx, 18
	mov dx, 18
	
	mov bx, offset matrix_erase_blocks
	mov [matrix], bx
	
	call putMatrixInScreen

	@@end:
	POP_ALL
	ret
endp Erase_Block


;move background to var

proc Copy_Background_Blocks
	PUSH_ALL
	
	mov bx, offset matrix_erase_blocks ; the data will be stored in this var
	mov [matrix], bx
	
	call putMatrixInData

	POP_ALL
	ret
endp Copy_Background_Blocks

;draws blocks using the stack - mainly for drawing towers
;[bp + 4] = x
;[bp + 6] = y
proc DrawBlock_Stack
	PUSH_ALL_BP
	
	cmp [word bp + 4], 301 ; if this is out of screen dont draw
	ja @@kill_block
	
	mov [Blocks_Alive], 1
	
	;now we calculate the place
	mov ax, [word bp + 6]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [word bp + 4]
	
	mov cx, 18
	mov dx, 18
	
	mov bx, offset matrix_blocks
	mov [matrix], bx
	
	call putMatrixInScreen
	jmp @@end
	
	@@kill_block:
	mov [Blocks_Alive], 0
	
	@@end:
	POP_ALL_BP
	ret 4
endp DrawBlock_Stack


proc Draw_Triangle
	PUSH_ALL
	
	cmp [Xpos_Triangle], 301 ; if this is out of screen dont draw
	ja @@kill_triangle
	
	mov [Triangle_Alive], 1
	
	; di = 320 * Ypos + Xpos
	mov ax, [Ypos_Triangle]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Triangle]
	
	mov cx, 9 ; rows
	mov dx, 18 ; cols
	
	call Copy_Background_Triangle ; we will copy the background before drawing
	
	mov bx, offset matrix_triangle
	mov [matrix], bx

	call putMatrixInScreen
	jmp @@end
	
	@@kill_triangle:
	mov [Triangle_Alive], 0

	@@end:
	POP_ALL
	ret
endp Draw_Triangle


proc Erase_Triangle
	PUSH_ALL

	cmp [Triangle_Alive], 0 ; if it is out of bound dont erase or draw
	je @@end

	mov ax, [Ypos_Triangle]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Triangle]
	
	mov cx, 9
	mov dx, 18
	
	mov bx, offset matrix_erase_triangle
	mov [matrix], bx
	
	call putMatrixInScreen

	@@end:
	POP_ALL
	ret
endp Erase_Triangle


;move background to var

proc Copy_Background_Triangle
	PUSH_ALL
	
	mov bx, offset matrix_erase_triangle ; the data will be stored in this var
	mov [matrix], bx
	
	call putMatrixInData

	POP_ALL
	ret
endp Copy_Background_Triangle

;================================================
; Description -  draws a tower of blocks
; INPUT: cx - how many blocks we want, Xpos_Tower - will indicate where we want it
; OUTPUT: tower of blocks on screen
; Register Usage: None
;================================================
proc Draw_Tower
	PUSH_ALL
	
	
	cmp [Xpos_Tower], 301
	ja @@kill_tower
	
	;we will save the tower height
	mov cx, [Height_Tower]
	mov [Tower_Alive], 1
	
	;firstly we will calculate the ypos
	;how - (height of the platfrom)161 - cx * 18 = Ypos_Tower
	
	;18 * cx = ax
	mov ax, 18
	mul cx
	
	;161 - ax = bx
	mov bx, 161
	sub bx, ax
	
	mov [Ypos_Tower], bx
	
	xor si, si
	
	;because cx has the number of blocks we want we can use it in a loop
	@@draw_blocks:
	push bx
	push [Xpos_Tower]
	
	call Copy_Background_Tower ; firstly we will copy the background
	
	call DrawBlock_Stack ; then draw it
	add bx, 18 ; add to y to draw the next block
	inc si ; increase the counter of which block are we on - for copy background
	loop @@draw_blocks
	jmp @@end
	
	
	@@kill_tower:
	mov [Tower_Alive], 0
	
	@@end:
	POP_ALL
	ret
endp Draw_Tower

;copy one by one the tower blocks to different vars
proc Copy_Background_Tower
	PUSH_ALL_BP
	
	;si holds which block are we on
	
	mov ax, [bp + 6] ; Ypos
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [bp + 4] ; Xpos
	
	mov cx, 18
	mov dx, 18
	
	call put_bx_offsetmatrix
	
	mov [matrix], bx
	call putMatrixInData

	POP_ALL_BP
	ret
endp Copy_Background_Tower

; put in bx the offset of the var by the register si
; in si we have the nu,ber of the block we want to copy
proc put_bx_offsetmatrix

	cmp si, 0
	je @@first_block
	
	cmp si, 1
	je @@second_block
	
	cmp si, 2
	je @@third_block
	
	cmp si, 3
	je @@fourth_block
	
	jmp @@fifth_block
	
	@@first_block:
	mov bx, offset matrix_erase_tower ; the data will be stored in this var
	jmp @@end
	@@second_block:
	mov bx, offset matrix_erase_tower1
	jmp @@end
	@@third_block:
	mov bx, offset matrix_erase_tower2
	jmp @@end
	@@fourth_block:
	mov bx, offset matrix_erase_tower3
	jmp @@end
	@@fifth_block:
	mov bx, offset matrix_erase_tower4
	
	
	@@end:
	ret
endp put_bx_offsetmatrix

;goes each block and paints on it his background
proc Erase_Tower
	PUSH_ALL
	
	cmp [Tower_Alive], 0 ; check if even alive
	je @@end

	xor si, si
	mov ax, [Ypos_Tower]
	
	@@erase_blocks:
	;calculation of place
	push ax
	mov bx, 320
	mul bx
	mov di, ax
	add di, [Xpos_Tower]
	mov cx, 18
	mov dx, 18
	
	;now we need to put in bx the offset of the var that hold the background
	call put_bx_offsetmatrix
	mov [matrix], bx
	
	
	call putMatrixInScreen ; draw background
	inc si
	pop ax
	add ax, 18
	cmp si, [Height_Tower]
	jb @@erase_blocks


	@@end:
	POP_ALL
	ret
endp Erase_Tower

;================================================
; Description -  draws a picture of start screen
; INPUT: None
; OUTPUT: BMP picture on screen
; Register Usage: None
;================================================
proc DrawStartScreen
	PUSH_ALL
	mov dx, offset FileName_start ; start screen
	DRAW_FULL_BMP
	POP_ALL
	ret
endp DrawStartScreen

;================================================
; Description -  draws a picture of background screen
; INPUT: None
; OUTPUT: BMP picture on screen
; Register Usage: None
;================================================
proc DrawBackground
	PUSH_ALL
	mov dx, offset FileName_background
	DRAW_FULL_BMP
	POP_ALL
	ret
endp DrawBackground

;================================================
; Description -  checks two keys - space and escape
; INPUT: key on keyboard
; OUTPUT: activates other function in case space is pressed, in case escape it ends the game
; Register Usage: None
;================================================
proc Key_Check
	PUSH_ALL

	mov ah, 1h
	int 16h
	
	jz @@end ; in case not pressed we check if we are jumping
	
	
	mov ah, 0
	int 16h

	cmp ah, 1h
	je @@exit_game
	
	cmp ah, 39h ; space
	je @@jump
	
	jmp @@end
	
	@@exit_game:
	mov [IsExit], 1
	jmp @@end
	
	@@jump:
	cmp [can_jump], 1
	jne @@end
	mov [Is_Going_up], 1

	@@end:	
	POP_ALL
	ret
endp Key_Check

;al will be one if there is a floor under us
proc Check_white_Under
	;left buttom check
	mov ah,0Dh
	mov cx,[Xpos]
	mov dx, [Ypos]
	add dx, 18	
	int 10H ; AL = COLOR
	cmp al, 0ffh ; check white
	je @@floor
	
	;right buttom check
	mov ah,0Dh
	mov cx,[Xpos]
	mov dx, [Ypos]
	add dx, 18
	add cx, 17
	int 10H ; AL = COLOR
	cmp al, 0ffh ; check white
	je @@floor
	
	;did not see floor
	
	xor al, al
	jmp @@end

	@@floor:
	mov al, 1

	@@end:
	ret
endp Check_white_Under


proc Check_Right
	PUSH_ALL
	
	call Check_Blocks
	cmp al, 1
	je @@end_game
	
	;and we want to check if we hit a triangle
	call Check_Triangle
	cmp al, 1
	je @@end_game

	
	jmp @@end
	
	@@end_game:
	mov [IsExit], 1
	
	
	@@end:
	POP_ALL
	ret
endp Check_Right

;if we hit blocks al will be one
proc Check_Blocks
	;we will check three pixels to the right up and down
	mov ah,0Dh
	mov cx,[Xpos]
	mov dx, [Ypos]
	add cx, 18	
	int 10H ; AL = COLOR
	cmp al, 0ffh ; check white
	je @@end_game
	
	mov ah, 0dh
	inc cx
	int 10h
	cmp al, 0ffh ; check white
	je @@end_game

	mov ah, 0dh
	inc cx
	int 10h
	cmp al, 0ffh ; check white
	je @@end_game
	
	;now we go down
	mov ah,0Dh
	mov cx,[Xpos]
	mov dx, [Ypos]
	add cx, 18	
	add dx, 17
	int 10H ; AL = COLOR
	cmp al, 0ffh ; check white
	je @@end_game

	mov ah, 0dh
	inc cx
	int 10h
	cmp al, 0ffh ; check white
	je @@end_game

	mov ah, 0dh
	inc cx
	int 10h
	cmp al, 0ffh ; check white
	je @@end_game
	
	xor al, al
	jmp @@end
	
	@@end_game:
	mov al, 1
	@@end:
	ret
endp Check_Blocks

;if we hit a triange al will be one
;we will check left side down and right side down
proc Check_Triangle
	
	;we will check two points - left down and right down (collision check)
	
	;save triangle place
	mov ax, [Xpos_Triangle] ; left side of triangle
	mov bx, [Ypos_Triangle] ; top of triangle
	
	;side of triangle
	mov di, ax 
	add di, 17 ;end of triangle in x
	
	mov si, bx
	add si, 8 ; end of triangle in y
	
	;left down
	mov cx, [Xpos]
	mov dx, [Ypos]
	add dx, 18
	
	sub di, 4
	cmp cx, ax
	jb @@check2 ; if below it means our left side of the cube is not on the triangle - to his left side
	
	cmp cx, di
	ja @@check2 ; if above it means our left side of the cube is not on the triangle - to ihs right side
	
	;if we got here it means our x is in the triangle x area
	;now we need to check the y
	
	cmp dx, bx
	jb @@check2 ; if below it means we are above the triangle
	
	;we can't really be under a triangle so we dont need to check under
	
	;if it got here it means we are on the triangle
	jmp @@end_game
	
	;right side
	@@check2:
	add cx, 17
	add di, 4
	sub ax, 3
	
	;now we will just copy the above
	cmp cx, ax
	jb @@end_check ;if the cube is left to the triangle
	
	cmp cx, di
	ja @@end_check ; if the cube is right to the triangle
	
	cmp dx, bx
	jb @@end_check ; if the cube is above the triangle
	
	;if it got here it means we are in the triangle
	jmp @@end_game
	
	

	@@end_check:
	xor al, al
	jmp @@end
	
	@@end_game:
	mov al, 1
	
	@@end:
	ret
endp Check_Triangle

proc Check_Black_Right
	mov ah,0Dh
	mov cx,[Xpos]
	mov dx, [Ypos]
	add cx, 18	
	add dx, 17
	int 10H ; AL = COLOR
	cmp al, 0; check white
	je @@end_game

	mov ah, 0dh
	inc cx
	int 10h
	cmp al, 0 ; check white
	je @@end_game

	mov ah, 0dh
	inc cx
	int 10h
	cmp al, 0; check white
	je @@end_game
	
	xor al, al
	jmp @@end
	
	@@end_game:
	mov al, 1
	
	@@end:
	ret
endp Check_Black_Right

;in cx will be the x
proc Check_Black_Down
	;we will only check one dot under the cube, of more it will confuse with landing on blocks
	mov ah,0Dh
	mov dx, [Ypos]
	add dx, 18
	int 10H ; AL = COLOR
	cmp al, 0ffh; check white
	je @@end_game
	
	cmp al, 0 ; black
	je @@end_game
	
	mov ah, 0dh
	add dx, 3
	int 10H ; AL = COLOR
	cmp al, 0ffh; check white
	je @@end_game
	
	cmp al, 0 ; black
	je @@end_game
	
	mov ah, 0dh
	inc dx
	int 10h
	cmp al, 0ffh
	je @@end_game
	
	cmp al, 0
	je @@end_game
	

	xor al, al
	jmp @@end
	
	@@end_game:
	mov al, 1
	@@end:
	ret
endp Check_Black_Down

;in case the jump has ended and we are not on the floor
;this will check if we have floor under us while falling from a block - when not jumpimg
proc Check_Fall
	PUSH_ALL
	
	call Check_white_Under
	cmp al, 1 ; if we have floor under
	je @@check_hit_floor ; then check if it is the floor
	

	;we need to go down - no floor
	mov [Is_Falling], 1
	mov [bool_landed_block], 1
	mov [Is_On_Block], 0
	mov [can_jump], 0
	add [Ypos], 6
	jmp @@end
	
	@@check_hit_floor:
	cmp [Ypos], 143 ; if it is the floor end the fall
	jne @@end
	
	;did hit floor
	mov [can_jump], 1 ; we can jump again - in case we are falling we will cancel the jump movement so when when stop falling we cant jump
	mov [Is_Falling], 0
	mov [bool_landed_block], 0 ; reset bools
	mov [Is_On_Block], 0
	mov [Is_Going_down], 0
	
	@@end:
	POP_ALL
	ret
endp Check_Fall

;================================================
; Description -  goes up until going 30 vertical up
; INPUT: None
; OUTPUT: cube goes up
; Register Usage: None
;================================================
proc Cube_Ascend
	PUSH_ALL
	
	cmp [Is_Going_up], 0 ; checks if we even go up
	je @@end ; if not go to end
	
	mov [Is_Falling], 0
	mov [can_jump], 0
	
	cmp [bool_calc_max_height], 1; if already we calculated the max height
	je @@go_up
	;calculating max height - ypos - 54
	mov ax, [Ypos]
	sub ax, 48 ; middle height
	
	mov [Middle_Height], ax
	
	sub ax, 6 ; top height
	mov [Max_height], ax
	mov [bool_calc_max_height], 1 ; signs that we calculated it
	
	@@go_up:
	mov ax, [Max_height]
	mov [Is_Going_up], 1 ; signs that we are going up
	
	cmp [Ypos], ax ; if our ypos is smaller then the max ypos we should stop jumping
	jbe @@stop_up
	
	mov ax, [Middle_Height]
	cmp [Ypos], ax ; checks if a past the middle part
	jbe @@slow
	
	;if we havn't reached the point
	sub [Ypos], 6
	jmp @@end
	
	@@slow:
	
	sub [Ypos], 3
	jmp @@end
	
	@@stop_up:
	mov [Is_Going_up], 0 ; signs that we stop ascending
	mov [Is_Going_down], 1 ; we now can go down - this can't be controlled by the player, only the game controlls this bool
	mov [bool_calc_max_height], 0
	mov [can_jump], 0
	
	@@end:
	POP_ALL
	ret
endp Cube_Ascend


;================================================
; Description -  goes down when there is not white under the cube
; INPUT: None
; OUTPUT: cube goes down
; Register Usage: None
;================================================
proc Descending
	PUSH_ALL

	call Check_white_Under
	cmp al, 1
	je @@end_jump
	
	;to not go through the floor we will reduce the falling speed to one when close to the floors
	cmp [Ypos], 153 ; if below continue to reducde by nine
	jb @@down_nine
	
	inc [Ypos]
	
	call Check_white_Under ; checking twice to not loop twice
	cmp al, 1
	je @@end_jump
	
	jmp @@end
	
	@@down_nine:
	add [Ypos], 9
	
	call Check_white_Under
	cmp al, 1
	je @@end_jump
	
	jmp @@end

	@@end_jump:
	mov [can_jump], 1
	mov [Is_Going_down], 0 ; finished going down
	
	@@end:
	POP_ALL
	ret
endp Descending

;checks if we are on cube - only be used after finishing a jump
proc Check_Where_Cube

	cmp [Is_Going_up], 1
	je @@end

	cmp [Is_Going_down], 1 ; if we are still jumping
	je @@end

	;now if it got here we landed after a jump
	
	cmp [Ypos], 143 ; the y it supposed to be while on floor
	jb @@above_ground
	
	jmp @@on_ground

	@@above_ground:
	
	call Check_white_Under
	cmp al, 0 ; in the air - no floor
	je @@falling
	
	mov [Is_On_Block], 1
	mov [can_jump], 1
	mov [bool_landed_block], 1
	jmp @@end
	
	@@falling:
	mov [Is_Falling], 1
	mov [Is_On_Block], 0
	mov [bool_landed_block], 0
	jmp @@end
	
	@@on_ground:
	mov [Is_On_Block], 0
	mov [bool_landed_block], 0
	mov [Is_Going_up], 0
	mov [Is_Going_down], 0

	@@end:
	ret
endp Check_Where_Cube

;main function of the cube
;checks the state of the cube with bools, and starts each function
proc Cube_Move
	PUSH_ALL
	
	call Check_Where_Cube
	
	cmp [Is_Going_up], 1 ; if we go up then continue ascending
	je @@jump
	
	cmp [Is_Going_down], 1 ; if we go down then countinue descending
	je @@go_down
	
	cmp [Is_Falling], 1 ; if we landed on block then we need to fall
	je @@fall
	
	jmp @@end_move
	
	@@jump:
	call Erase_Cube
	call Cube_Ascend
	call DrawCube
	jmp @@end_move
	
	@@go_down:
	call Erase_Cube
	call Descending
	call DrawCube
	jmp @@end_move
	
	@@fall:
	call Erase_Cube
	call Check_Fall
	call DrawCube
	
	@@end_move:
	
	call Check_Where_Cube
	call Check_Right ; if we got into a block and died
	
	
	@@end:
	POP_ALL
	ret
endp Cube_Move

END start


