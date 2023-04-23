.486
IDEAL
MODEL small

STACK 100h

;For playing this game set DOSBOX to 7000 cycles
;cycles=7000


;macros

macro DRAW_FULL_BMP
	;mov dx, ?
	push 0
	push 0
	push 320
	push 200
	call DrawPictureBmp
endm DRAW_FULL_BMP

macro PUSH_ALL_BP ; push all registers with using bp
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
endm PUSH_ALL_BP

macro POP_ALL_BP ; pop all registers with using bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
endm POP_ALL_BP

Xpos_Cube = 50

DATASEG
; --------------------------
; Your variables here

	;random
	RndCurrentPos dw start ; random label

	bool_won db 0 ; if the player has the best score we will print his name on the final board

	;start over
	bool_start_over db 0 ; will be changed by the player desicion in the end screen - if pressed yes or no

	; -- player --
	
	;speed
	delay dw 55 ; delay between each frame
	
	;picked color
	;these colors will be picked by the player in the start screen
	OutSideColor db 3fh
	InsideColor db 9h

	
	;name
	NamePlayer db 14, 16 dup (?), '$' ; name of the player which is inserted before starting
	
	;Bonus points
	BonusPointsCounter db ? ; the amount of times the player took a red bonus point
	
	;seconds alive
	counterSeconds db ? ; mini counter for seconds - when hitting 27 one second has past
	seconds dw ? ; the amount of seconds the player has been alive
	
	;score
	FinalScore dw ? ; final score of the player 
	FinalScoreTXT db "xxxx", '$' ; the number above but in text to print in end screen
	
	; -- Cube variables --
	CurrentSize dw 18 ; size of the cube according to each frame - while rotation
	
	; -- loop var --
	IsExit db 0 ; to know if the game has ende
	
	; -- jump vars --
	can_jump db 1 ; will sign if we are falling from a platform
	
	;rotation
	timeInAir db 0 ; to know which frame to print - 18 frames
	;it takes 18 frames to make a full jump
	;so when this timer hits the number 18 it finished the jump
	;each frame will be selected by the number in this var
	
	;directions bools 
	Is_Going_up db ? ; if the cube is currently going up
	Is_Going_down db ? ; if the cube is currently going down
	Is_Falling  db ? ; if the cube is currently falling
	;falling is a state when the cube didnt jump but in air - example: the cube landed on a block and did jump again
	
	;height calculation
	Max_height dw ? ; max height when jumping will be calculated once
	Middle_Height dw ? ; to slow down mid jump
	bool_calc_max_height db 0 ; if we have calculated max height to not repeat
	
	; -- position --
	
	;cube
	Ypos dw 143 ; we only need the ypos because the cube wont change its place on screen only will jump - only changes in the ypos
	
	
	; - blocks - 
	;cube
	
	;we will put in all the objects minus one because we will check if an object is in the map (to know if to draw) by checking if below 301
	;the reason for 301 is because the objects width is 18
	;we will only check if below 301 in unsigned numbers
	Xpos_Blocks dw 5 dup (-1)
	Ypos_Blocks dw 5 dup (?)
	
	
	;Triangle
	Xpos_Triangle dw 5 dup (-1)
	Ypos_Triangle dw 5 dup (?)
	
	;Tower
	
	;when creating towers we will give the height of the tower instead Ypos
	Xpos_Tower dw 5 dup (-1)
	Ypos_Tower dw 5 dup (?) ; ypos is calculated by how many blocks we want
	Height_Tower dw 5 dup (?)
	
	;Bonus Points
	Xpos_Points dw -1
	Ypos_Points dw ?
	
	;levels
	Objects_Placed db ? ; indicates if on the screen there are objects, if not randomize a new level
	CurentLevel db ? ; will be randomized when a level has ended
	
	; -- drawing using matrix --
	;each frame of cube
	matrix_cube   db 18*18 dup (?)
	matrix_cube5  db 20*20 dup (?)
	matrix_cube10 db 21*21 dup (?)
	matrix_cube15 db 22*22 dup (?)
	matrix_cube20 db 23*23 dup (?)
	matrix_cube25 db 24*24 dup (?)
	matrix_cube30 db 24*24 dup (?)
	matrix_cube35 db 25*25 dup (?)
	matrix_cube40 db 25*25 dup (?)
	matrix_cube45 db 25*25 dup (?)
	matrix_cube50 db 25*25 dup (?)
	matrix_cube55 db 25*25 dup (?)
	matrix_cube60 db 24*24 dup (?)
	matrix_cube65 db 24*24 dup (?)
	matrix_cube70 db 23*23 dup (?)
	matrix_cube75 db 22*22 dup (?)
	matrix_cube80 db 21*21 dup (?)
	matrix_cube85 db 19*19 dup (?)
	
	offset_matrix dw ?
	
	;erase cube
	matrix_erase_cube db 25*25 dup (?) ; max sizes of main cube
			
	; - triangle block -
	matrix_triangle db  1,  1,   1,  1,  1,  1,  1,  1,0ffh,0ffh,1,  1,   1,  1,  1,  1,    1,1
					db  1,  1,   1,  1,  1,  1,  1,0ffh,0,0,0ffh,1,   1,  1,  1,  1,    1,1
					db  1,  1,   1,  1,  1,  1,0ffh,0,  0,  0,  0,0ffh, 1,  1,  1,  1,    1,1
					db  1,  1,   1,  1,  1,0ffh, 0,  0,  0,  0,  0,  0,0ffh,1,  1, 1,1,1
					db  1,  1,   1,  1,0ffh,  0,  0,  0,  0,  0,  0,  0, 0,0ffh,1,  1, 1,1
					db   1,  1,  1,0ffh,0, 0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh,1,  1, 1
					db   1,  1,0ffh,0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh, 1, 1
					db   1,0ffh, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh, 1
					db 0ffh,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh
	
	;erasing the triangle
	matrix_erase_triangle db 9*18 dup (?), 9*18 dup (?), 9*18 dup (?), 9*18 dup (?), 9*18 dup (?) ; five triagnles
	
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
	matrix_erase_blocks db 18*18 dup (?), 18*18 dup (?), 18*18 dup (?), 18*18 dup (?), 18*18 dup (?) ; five blocks
	
	;bonus points
	matrix_bonus    db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
					db 0fh,0fh,0fh,0fh,0fh,0fh
	
	;erasing point
	matrix_erase_point db 11*6 dup (?) ; one bonus point
	
	;erase tower
	matrix_erase_tower db 18*18*5 dup (?), 18*18*5 dup (?), 18*18*5 dup (?), 18*18*5 dup (?), 18*18*5 dup (?) ; five towers

	
	
	matrix dw ? ; holds the offset of the mtarix we want to print
	
	
	
	; -- FILES --
	
	; background bmp picture var

    OneBmpLine 	db 320 dup (0)  ; One Color line read buffer
   
    ScrLine 	db 320 + 4 dup (0)  ; One Color line read buffer

	;BMP File data
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	ErrorFile db ?
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ', 0dh, 0ah,'$'
	
	;screens
	FileName_background db 'back.bmp' ,0 ; background - main screen
	FileName_start db 'start.bmp', 0 ; start screen (before start of game)
	FileName_EnterName db 'name.bmp', 0 ; middle button start screen -  enter your name
	FileName_Settings db 'settings.bmp', 0 ; right button in start screen
	FileName_Guide db 'guide.bmp', 0 ; left button in start screen - how to play
	FileName_NameError db 'nameEr.bmp', 0 ; in case no chars have been entered in the name enter we print an error
	FileName_End db 'end.bmp', 0
	
	;cube rotation frames
	;we will only open them ones to transfer to matrix
	;every number is the angle of the cube
	FileName_cube   db 'cube.bmp'  , 0 ; angle 90
	FileName_cube5  db 'cube5.bmp' , 0
	FileName_cube10 db 'cube10.bmp', 0
	FileName_cube15 db 'cube15.bmp', 0
	FileName_cube20 db 'cube20.bmp', 0
	FileName_cube25 db 'cube25.bmp', 0
	FileName_cube30 db 'cube30.bmp', 0
	FileName_cube35 db 'cube35.bmp', 0
	FileName_cube40 db 'cube40.bmp', 0
	FileName_cube45 db 'cube45.bmp', 0
	FileName_cube50 db 'cube50.bmp', 0
	FileName_cube55 db 'cube55.bmp', 0
	FileName_cube60 db 'cube60.bmp', 0
	FileName_cube65 db 'cube65.bmp', 0
	FileName_cube70 db 'cube70.bmp', 0
	FileName_cube75 db 'cube75.bmp', 0
	FileName_cube80 db 'cube80.bmp', 0
	FileName_cube85 db 'cube85.bmp', 0
	
	;scores
	
	FileName_Scores db 'scores.txt', 0 ; the name of the highest score ever
	FileHandleScores dw ? ; the file handle
	ScoreInFile db "xxxx", '$' ; score in file in text
	ScoreInNumbers dw ? ; the score in file converted to number
	ErasePrevName db 13 dup ('x') ; if a player did a new high score
	BestScoreHolder db 14 dup ('$') ; the name of the best player with the highest score
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here

call SettingsGame
	
start_over:

	call StartingGame
	
main_loop:
	call Key_Check
	cmp [IsExit], 1
	je end_game
	
	call GameLoop
	
	jmp main_loop
	
end_game:
	call EndGame
	
	cmp [bool_start_over], 1
	je start_over
	
	call Terminate
	
; --------------------------

exit:
	mov ax, 4c00h
	int 21h


;set the settings of game
proc SettingsGame
	call SetGraphics ; sets to graphics mode
	
	call SetMouseLimits ; set mouse limits of screen
	ret
endp SettingsGame

;checks if the player wanted to play again
;if so check which screen the player picked with the mouse
;when the player finally picked starting screen it will get out of the screen and start the game
;so we will print the background and print the cube
proc StartingGame
	mov [bool_start_over], 0 ; resetting this bool
	
	call MouseShow ; for loading screens
	call Transfer_bmp_matrix ; transfer all frames into matrix after picking the colors
	
	;when the player got here the game has started
	
	call DrawBackground ; drawing the background
	call DrawCube ; drawing the cube
	
	push 500 ; delay before starting the game
	call LoopDelay
	
	ret
endp StartingGame

;picks a random level then moves the cube by the bools
;then counts seconds and delay the game
proc GameLoop
	call PickLevel ; picks a random level
	
	call Cube_Move ; moving the cube according to the bools
	
	call CountSeconds ; counting seconds 
	
	push [delay] ; delay
	call LoopDelay
	ret
endp GameLoop

;checks if our score is higher then the highest score, if so it replaces it
;then print the end screen
;closes the file and gets dos box the control back
proc EndGame
	
	call ChangeScoreHighest ; handles the score using the file
	call End_Screen ; end screen printing and writing and mouse
	
	;now we close the file
	
	mov ah, 3eh
	mov bx, [FileHandleScores]
	int 21h
	
	ret
endp EndGame
	
;calculating the score - each bonus point is 2 more seconds to total
;total seconds + number of bonus point * 2 = score
proc CalcScore
	pusha
	
	;number of bonus point * 2
	xor ax, ax
	mov al, [BonusPointsCounter]
	shl ax, 1 ; multiply by two
	
	add ax, [seconds]

	mov [FinalScore], ax


	popa
	ret
endp CalcScore
	
	
;dealing with the scores
;will move to var "ScoreInNumbers" the score in the file
proc ChangeScoreHighest
	pusha

	;opening file
	mov ah, 3dh
	mov al, 2 ; read and write
	mov dx, offset FileName_Scores
	int 21h
	mov [FileHandleScores], ax
	
	;now we read the number
	mov ah, 3fh ; reading file
	mov dx, offset ScoreInFile ; offset of var we want to copy to
	mov bx, [FileHandleScores]
	mov cx, 4 ; we want to read four chars
	int 21h
	
	;now we want to turn it into a number and move into 
	xor ax, ax
	mov si, offset ScoreInFile ; will serve as offset
	mov cx, 4 ; four chars
	mov bl, 10 ; we will multiply each time by 10
	
@@turnIntoNum:
	xor dx, dx
	mov dl, [byte si]
	sub dl, '0' ; turn into real number (char -> number)
	mul bl ;multiply by ten
	add ax, dx ; add the digit to ax
	inc si
	loop @@turnIntoNum
	
	mov [ScoreInNumbers], ax
	
	;now we will get our score
	call CalcScore
	
	;now we will put the highest score
	call SetHighScore

	popa
	ret
endp ChangeScoreHighest

;we will compare the two scores
;if our score is higher then the highest then we put our in the var "ScoreInNumbers" and change it to text and put it in "ScoreInFile"
proc SetHighScore
	pusha

	mov ax, [FinalScore] ; our score
	
	cmp ax, [ScoreInNumbers] ; the best score
	
	jbe @@end ; if our score is equal or below the highest score
	
	mov [bool_won], 1
	
	mov [ScoreInNumbers], ax
	
	;now we need to copy it to the text form
	mov si, offset ScoreInFile + 3 ;go to the end of var
	mov cx, 4
	mov bx, 10 ; to div every time by ten
@@change_to_text:
	xor dx, dx
	div bx
	add dl, '0'
	mov [byte si], dl ; put the modulu in si
	dec si
	loop @@change_to_text
	
	mov ah, 42h
	mov al, 0
	mov cx, 0
	mov dx, 0
	mov bx, [FileHandleScores]
	int 21h
	
	;now we will write those to the file
	;writing the score
	mov ah, 40h
	mov dx, offset ScoreInFile
	mov bx, [FileHandleScores]
	mov cx, 4
	int 21h
	
	;writing the name
	mov ah, 40h
	mov dx, offset NamePlayer + 2
	mov bx, [FileHandleScores]
	xor cx, cx
	mov cl, [NamePlayer + 1] ; the length of the name
	int 21h
	
	;erase the remaining parts of the name
	mov ax, 14
	sub ax, cx
	mov cx, ax
	mov ah, 40h
	mov dx, offset ErasePrevName
	mov bx, [FileHandleScores]
	int 21h


@@end:
	popa
	ret
endp SetHighScore

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


;counts seconds and stores them in the var seconds
proc CountSeconds
	
	inc [counterSeconds]
	cmp [counterSeconds], 27 ; one second
	jne @@cont
	inc [seconds]
	mov [counterSeconds], 0
@@cont:

	ret
endp CountSeconds

;sets the limit for starting screens
proc SetMouseLimits
	pusha

	mov ax, 7 ; set limits of mouse - X
	mov cx, 17 ; min
	mov dx, 292 ; max
	shl cx, 1
	shl dx, 1
	int 33h
	
	mov ax, 8 ; set limits of mouse - Y
	mov cx, 24 ; min
	mov dx, 162 ; max
	int 33h

	popa
	ret
endp SetMouseLimits

;for loading screen
proc MouseShow
	pusha
	
@@main_screen:

	mov ax, 2 ; hide mouse
	int 33h
	
	call DrawStartScreen ; draw the start screen

	mov ax, 1 ; show mouse
	int 33h
	
	mov ax, 1
	int 33h

@@wait_for_left:
	mov ax, 3
	int 33h
	
	;check if middle button
	shr cx, 1
	cmp bx, 1
	jne @@wait_for_left
	
	cmp cx, 120
	jb @@check2
	
	cmp cx, 190
	ja @@check2
	
	cmp dx, 90
	jb @@check2
	
	cmp dx, 150
	ja @@check2
	
	;if it got here it means we have pressed on the start button
	call Name_Screen
	jmp @@end
	
@@check2:
	;check if left button
	
	cmp cx, 40
	jb @@check3
	
	cmp cx, 83
	ja @@check3
	
	cmp dx, 100
	jb @@check3
	
	cmp dx, 137
	ja @@check3
	
	call Guiding_Screen
	jmp @@main_screen
	
@@check3:
	
	;check if right button
	cmp cx, 231
	jb @@wait_for_left
	
	cmp cx, 274
	ja @@wait_for_left
	
	cmp dx, 100
	jb @@wait_for_left
	
	cmp dx, 137
	ja @@wait_for_left
	
	call Settings_Screen
	jmp @@main_screen
	
@@end:
	popa
	ret
endp MouseShow

;will show how to play the game and will check if the mouse hit the "back" sign
proc Guiding_Screen
	pusha

	mov ax, 2
	int 33h
	
	mov dx, offset FileName_Guide
	DRAW_FULL_BMP
	
	mov ax, 1
	int 33h
	
@@check_click:
	mov ax, 3
	int 33h
	
	cmp bx, 1
	jne @@check_click
	shr cx, 1
	
	;check if go back
	cmp cx, 21
	jb @@check_click
	
	cmp cx, 63
	ja @@check_click
	
	cmp dx, 27
	jb @@check_click
	
	cmp dx, 46
	ja @@check_click

	popa
	ret
endp Guiding_Screen

proc Settings_Screen
	pusha
	
	mov ax, 2
	int 33h
	
	mov dx, offset FileName_Settings
	DRAW_FULL_BMP
	
	mov ax, 1
	int 33h
	
@@check_click:
	mov ax, 3
	int 33h
	
	cmp bx, 1
	jne @@check_click
	shr cx, 1
	
	cmp dx, 143
	ja @@check_speed_game
	
	;check if go back
	cmp cx, 21
	jb @@check_outer_color
	
	cmp cx, 63
	ja @@check_outer_color
	
	cmp dx, 27
	jb @@check_outer_color
	
	cmp dx, 46
	ja @@check_outer_color
	
	jmp @@end ; finish the page
	
@@check_outer_color:
	cmp cx, 45
	jb @@check_inner_color
	
	cmp cx, 275
	ja @@check_inner_color
	
	cmp dx, 60
	jb @@check_click ; if the y is below then it cant be anything
	
	cmp dx, 80
	ja @@check_inner_color
	
	;if it got here one of the outer colors were pressed
	;we will check what color was pressed
	dec dx
    mov ah, 0dh ; check color
    mov bh, 0
    int 10h
	inc dx
	
	cmp al, 0beh ; if it the green color between blocks
	je @@check_click
	
	;if it got here it means one of the colors was pressed so then we will just pass it to the out color
	mov [OutSideColor], al
	jmp @@check_click
	
@@check_inner_color:
	
	cmp dx, 120
	ja @@check_speed_game
	
	dec dx
	mov ah, 0dh ; check color
    mov bh, 0
    int 10h
	inc dx
	
	cmp al, 0beh ; if it the green color between blocks
	je @@check_click
	
	;if it got here it means one of the colors was pressed so then we will just pass it to the out color
	mov [InsideColor], al
	jmp @@check_click

@@check_speed_game:
	
	cmp dx, 145
	jb @@check_click
	
	cmp dx, 159
	ja @@check_click
	
	;if not in those ranges it means we are not on the blocks
	
	;slow button
	
	cmp cx, 32
	jb @@check_click
	
	cmp cx, 93
	ja @@normal
	
	; if it got here we pressed on the slow button
	
	mov [delay], 60 ; slow speed
	jmp @@check_click
	
@@normal:

	;normal speed
	
	cmp cx, 205
	ja @@fast
	
	;dont touch the delay becuase we are on the normal speed
	jmp @@check_click
	
@@fast:
	cmp cx, 288
	ja @@check_click
	
	mov [delay], 50
	jmp @@check_click
@@end:
	popa
	ret
endp Settings_Screen

;after hitting the start sign, it will ask for the players' name
proc Name_Screen
	pusha
	
	mov ax, 2 ; hide mouse
	int 33h
	
	mov dx, offset FileName_EnterName
	DRAW_FULL_BMP
	
	mov ax, 1 ; show mouse
	int 33h

@@check_click: ;check if left click was on the name enter
	mov ax, 3
	int 33h
	
	cmp bx, 1
	jne @@check_click
	shr cx, 1
	
	cmp cx, 89
	jb @@cont
	
	cmp cx, 226
	ja @@cont
	
	cmp dx, 79
	jb @@cont
	
	cmp dx, 105
	ja @@cont
	
	;if it got here it means we have pressed on the start button
	call Enter_Name
	jmp @@end
	
@@cont:
	
	;check if got back
	cmp cx, 21
	jb @@check_click
	
	cmp cx, 63
	ja @@check_click
	
	cmp dx, 27
	jb @@check_click
	
	cmp dx, 46
	ja @@check_click
	
	;if it got here it means the player has pressed back button
	mov ax, 2
	int 33h
	call MouseShow
	

@@end:
	popa
	ret
endp Name_Screen

proc End_Screen
	pusha

	mov dx, offset FileName_End ; draw the picture
	DRAW_FULL_BMP
	
	;we need to print our score
	call WriteScore
	
	;show mouse
	mov ax, 1
	int 33h
	
	mov ax, 1
	int 33h
	
	;check mouse
	
@@check_mouse:
	mov ax, 3 ; get mouse details
	int 33h
	
	cmp bx, 1
	jne @@check_mouse ; if didnt get any left clicks
	shr cx, 1
	
	;check if NO
	cmp dx, 135
	jb @@check_mouse
	
	cmp dx, 150
	ja @@check_mouse
	
	cmp cx, 245
	jb @@yes
	
	cmp cx, 275
	ja @@check_mouse
	
	jmp @@end
	
@@yes:
	cmp cx, 39
	jb @@check_mouse
	
	cmp cx, 83
	ja @@check_mouse
	
	call Reset
	
@@end:
	popa
	ret
endp End_Screen

;reset all vars if a player has picked the "yes" button in the end screen
proc Reset

	mov [NamePlayer], 14
	mov [NamePlayer + 1], ?
	mov [NamePlayer + 2], ?
	mov [NamePlayer + 3], ?
	mov [NamePlayer + 4], ?
	mov [NamePlayer + 5], ?
	mov [NamePlayer + 6], ?
	mov [NamePlayer + 7], ?
	mov [NamePlayer + 8], ?
	mov [NamePlayer + 9], ?
	mov [NamePlayer + 10], ?
	mov [NamePlayer + 11], ?
	mov [NamePlayer + 12], ?
	mov [NamePlayer + 13], ?
	mov [NamePlayer + 14], ?
	mov [NamePlayer + 15], ?
	mov [NamePlayer + 16], '$'

	mov [bool_won], 0
	
	;Bonus points
	mov [BonusPointsCounter], ?
	
	;seconds alive
	mov [counterSeconds], ?
	mov [seconds], ?
	
	;score
	mov [FinalScore], ?
	mov [FinalScoreTXT],  'x'
	mov [FinalScoreTXT + 1], 'x'
	mov [FinalScoreTXT + 2], 'x'
	mov [FinalScoreTXT + 3], 'x'
	mov [FinalScoreTXT + 4], '$'
	
	; -- Cube variables --
	
	; -- loop var --
	mov [IsExit], 0
	
	; -- jump vars --
	mov [can_jump], 1 ; will sign if we are falling from a platform
	
	;rotation
	mov [timeInAir], 0
	
	;directions bools 
	mov [Is_Going_up], ?
	mov [Is_Going_down], ?
	mov [Is_Falling], ?
	
	;height calculation
	mov [Max_height], ? ; max height when jumping will be calculated once
	mov [Middle_Height], ? ; to slow down mid jump
	mov [bool_calc_max_height], 0 ; if we have calculated max height to not repeat
	
	; -- position --
	
	;cube
	mov [Ypos], 143
	
	mov [Objects_Placed], ?
	mov [CurentLevel], ?
	
	mov [bool_start_over], 1
	
	mov [Xpos_Blocks], -1
	mov [Xpos_Blocks + 1], -1
	mov [Xpos_Blocks + 2], -1
	mov [Xpos_Blocks + 3], -1
	mov [Xpos_Blocks + 4], -1
	mov [Ypos_Blocks], -1
	mov [Ypos_Blocks + 1], -1
	mov [Ypos_Blocks + 2], -1
	mov [Ypos_Blocks + 3], -1
	mov [Ypos_Blocks + 4], -1
	
	
	;Triangle
	mov [Xpos_Triangle], -1
	mov [Xpos_Triangle + 1], -1
	mov [Xpos_Triangle + 2], -1
	mov [Xpos_Triangle + 3], -1
	mov [Xpos_Triangle + 4], -1
	mov [Ypos_Triangle], -1
	mov [Ypos_Triangle + 1], -1
	mov [Ypos_Triangle + 2], -1
	mov [Ypos_Triangle + 3], -1
	mov [Ypos_Triangle + 4], -1
	
	;Tower
	mov [Xpos_Tower], -1
	mov [Xpos_Tower + 1], -1
	mov [Xpos_Tower + 2], -1
	mov [Xpos_Tower + 3], -1
	mov [Xpos_Tower + 4], -1
	
	mov [Ypos_Tower], -1
	mov [Ypos_Tower + 1], -1
	mov [Ypos_Tower + 2], -1
	mov [Ypos_Tower + 3], -1
	mov [Ypos_Tower + 4], -1
	
	mov [Height_Tower], -1
	mov [Height_Tower + 1], -1
	mov [Height_Tower + 2], -1
	mov [Height_Tower + 3], -1
	mov [Height_Tower + 4], -1
	
	;Bonus Points
	mov [Xpos_Points], -1
	mov [Ypos_Points], -1
	
	mov [delay], 55
	
	mov [OutSideColor], 3fh
	mov [InsideColor], 9h
	
	;hide mouse
	mov ax, 2
	int 33h
	ret
endp Reset

;returns to text mode
proc Terminate
	push ax
	mov ax,2	;returns the screen to text mode.
	int 10h
	
	mov ax, 4C00h ; returns control to dos
  	int 21h
	pop ax
	ret
endp Terminate

;writes all scores in end screen
proc WriteScore
;our score
	;we will change the place of the writing
	mov ah, 2
	xor bh, bh
	mov dl, 25
	mov dh, 7
	int 10h
	
	call ChangeScoreToTXT
	
	mov dx, offset FinalScoreTXT ; now we print
	mov ah, 9
	int 21h
	
;Best Score
	mov ah, 2
	xor bh, bh
	mov dl, 25
	mov dh, 8
	int 10h
	
	mov dx, offset ScoreInFile ; highest score
	mov ah, 9
	int 21h
	
;now we print the holder
	mov ah, 2
	xor bh, bh
	mov dl, 17
	mov dh, 10
	int 10h
	
	mov dl, '"'
	mov ah, 2
	int 21h
	
	cmp [bool_won], 1
	je @@write_player_name
	
	mov dx, offset BestScoreHolder
	
@@read:
	mov ah, 3fh
	mov bx, [FileHandleScores]
	mov cx, 1
	int 21h
	mov si, dx
	inc dx
	cmp [byte si], 'x'
	jne @@read
	
	mov [byte si], '$'
	
	mov ah, 9
	mov dx, offset BestScoreHolder
	int 21h
	jmp @@end
	
@@write_player_name:
	
	xor bx, bx
	mov bl, [NamePlayer + 1]
	add bl, 2
	mov [NamePlayer + bx], '$'
	
	mov ah, 9
	mov dx, offset NamePlayer + 2
	int 21h
	
@@end:
	mov dl, '"'
	mov ah, 2
	int 21h
	ret
endp WriteScore

;takes our final score and turn it into text to print in final screen
;puts it in "FinalScoreTXT"
proc ChangeScoreToTXT
	pusha
	
	mov ax, [FinalScore]

	mov si, offset FinalScoreTXT + 3 ;go to the end of var
	mov cx, 4
	mov bx, 10 ; to div every time by ten
@@change_to_text:
	xor dx, dx
	div bx
	add dl, '0'
	mov [byte si], dl ; put the modulu in si
	dec si
	loop @@change_to_text

	popa
	ret
endp ChangeScoreToTXT

;================================================
; Description -  draws a picture of start screen
; INPUT: None
; OUTPUT: BMP picture on screen
; Register Usage: None
;================================================
proc DrawStartScreen
	pusha
	mov dx, offset FileName_start ; start screen
	DRAW_FULL_BMP
	popa
	ret
endp DrawStartScreen

;================================================
; Description -  draws a picture of background screen
; INPUT: None
; OUTPUT: BMP picture on screen
; Register Usage: None
;================================================
proc DrawBackground
	pusha
	mov dx, offset FileName_background
	DRAW_FULL_BMP
	popa
	ret
endp DrawBackground


;================================================
; Description -  in the name screen it requirs a name to be entered, so we will check if any chars have been entered, if not print an error msg
; INPUT: any sort of chars and then enter
; OUTPUT: name stored in DS
; Register Usage: None
;================================================
proc Enter_Name
	pusha
	jmp @@Get_name
	
@@print_Error:
	mov dx, offset FileName_NameError
	push 35
	push 110
	push 250
	push 13
	call DrawPictureBmp
	
	

	;hide mouse to now enter name
@@Get_name:
	mov ax, 2
	int 33h
	
	;moving the keyboard
	mov ah, 2
	xor bh, bh
	mov dh, 11
	mov dl, 12
	int 10h
	
	;getting the name
	mov ah, 0ah
	mov dx, offset NamePlayer
	int 21h
	
	cmp [NamePlayer + 2], 13
	je @@print_Error
	
	;getting back to normal
	mov ah, 2
	xor bh, bh
	xor dx, dx
	int 10h


	popa
	ret
endp Enter_Name
;================================================
; Description -  draws cube using bmp and Xpos and Ypos variables
; INPUT: None
; OUTPUT: bmp drawn on screen
; Register Usage: None
;================================================


;draw all shapes

;cube - using bmp
proc DrawCube
	pusha
	
	;pick size
	;picks a bmp by the seconds of the cube in the air
	call Pick_matrix_by_height
	push bx ; save dx after we save the background
	
	;di = Ypos * 320 + Xpos (place on screen)
	
	mov ax, [Ypos] ; we use matrix to erase
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, Xpos_Cube
	
	;size
	mov cx, [CurrentSize] ; rows
	mov dx, [CurrentSize] ; cols
	
	call Copy_Background_Cube ; we will copy the background firstly
	
	pop bx
	;for printing bmp we need - Xpos, Ypos, Height, Width - Through stack
	mov [matrix], bx
	call putMatrixInScreen
	;print
	
	popa
	ret
endp DrawCube

;for rotation - we check the height and then pick the right frame for it
;returns in dx and offset of the file we want to print
proc Pick_matrix_by_height
	
	cmp [timeInAir], 0 ; if timer is zero we need to print the 90 degrees even if not on ground
	je @@90_deg
	
	cmp [can_jump], 0 ; if on ground or block
	je @@in_air
	
@@90_deg:
	mov [timeInAir], 0
	mov [CurrentSize], 18
	mov bx, offset matrix_cube
	jmp @@print

@@in_air:
	mov al, [timeInAir]
	
	cmp al, 1
	je @@5_deg
	
	cmp al, 2
	je @@10_deg

	cmp al, 3
	je @@15_deg

	cmp al, 4
	je @@20_deg

	cmp al, 5
	je @@25_deg

	cmp al,  6
	je @@30_deg

	cmp al, 7
	je @@35_deg

	cmp al, 8
	je @@40_deg
	
	cmp al, 9
	je @@45_deg
	
	cmp al, 10
	je @@50_deg
	
	cmp al, 11
	je @@55_deg

	cmp al, 12
	je @@60_deg

	cmp al, 13
	je @@65_deg

	cmp al, 14
	je @@70_deg

	cmp al, 15
	je @@75_deg

	cmp al, 16
	je @@80_deg

	jmp @@85_deg ; if it got here it got to be 17
	
@@5_deg:
	mov [CurrentSize], 20 ; the sizes of the image
	mov bx, offset matrix_cube5
	jmp @@print
	
@@10_deg:
	mov [CurrentSize], 21
	mov bx, offset matrix_cube10
	jmp @@print
	
@@15_deg:
	mov [CurrentSize], 22
	mov bx, offset matrix_cube15
	jmp @@print
	
@@20_deg:
	mov [CurrentSize], 23
	mov bx, offset matrix_cube20
	jmp @@print
	
@@25_deg:
	mov [CurrentSize], 24
	mov bx, offset matrix_cube25
	jmp @@print
	
@@30_deg:
	mov [CurrentSize], 24
	mov bx, offset matrix_cube30
	jmp @@print
	
@@35_deg:
	mov [CurrentSize], 25
	mov bx, offset matrix_cube35
	jmp @@print
	
@@40_deg:
	mov [CurrentSize], 25
	mov bx, offset matrix_cube40
	jmp @@print
	
@@45_deg:
	mov [CurrentSize], 25
	mov bx, offset matrix_cube45
	jmp @@print
	
@@50_deg:
	mov [CurrentSize], 25
	mov bx, offset matrix_cube50
	jmp @@print	
	
@@55_deg:
	mov [CurrentSize], 25
	mov bx, offset matrix_cube55
	jmp @@print	
	
@@60_deg:
	mov [CurrentSize], 24
	mov bx, offset matrix_cube60
	jmp @@print	
	
@@65_deg:
	mov [CurrentSize], 24
	mov bx, offset matrix_cube65
	jmp @@print
	
@@70_deg:
	mov [CurrentSize], 23
	mov bx, offset matrix_cube70
	jmp @@print
	
@@75_deg:
	mov [CurrentSize], 22
	mov bx, offset matrix_cube75
	jmp @@print	
	
@@80_deg:
	mov [CurrentSize], 21
	mov bx, offset matrix_cube80
	jmp @@print
	
@@85_deg:
	mov [CurrentSize], 19
	mov bx, offset matrix_cube85


@@print:
	inc [timeInAir]
	cmp [timeInAir], 18 ; if equal to ten mak it zero
	jb @@end
	
	mov [timeInAir], 0
	
@@end:
	ret
endp Pick_matrix_by_height

;we will draw the saved background on the cube to erase it
proc Erase_Cube
	pusha
	mov ax, [Ypos]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, Xpos_Cube
	
	mov cx, [CurrentSize]
	mov dx, [CurrentSize]
	
	mov bx, offset matrix_erase_cube
	mov [matrix], bx
	
	call putMatrixInScreen
	popa
	ret
endp Erase_Cube

proc Copy_Background_Cube
	pusha
	
	;the other parameters are calculated before
	mov cx, [CurrentSize]
	mov dx, [CurrentSize]
	
	mov bx, offset matrix_erase_cube ; the data will be stored here
	mov [matrix], bx
	
	call putMatrixInData
	popa
	ret
endp Copy_Background_Cube

;block - we need to check where is the cube to know how to print it
;goes through every block and draws if on screen
proc DrawBlock
	pusha
	
	xor si, si
	xor bp, bp
	mov cx, 5
@@drawAllBlocks:
	push cx
	cmp [Xpos_Blocks + si], 301 ; if this is out of screen dont draw
	ja @@end_loop
	
	
	;now we calculate the place
	mov ax, [Ypos_Blocks + si]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Blocks + si]
	
	mov cx, 18
	mov dx, 18
	
	;firstly we will copy the background
	;because the cube vars take 324 bytes we need to use different register - bp
	mov bx, offset matrix_erase_blocks	; the data will be stored in this var
	add bx, bp ; offset add by bp
	mov [matrix], bx
	
	call putMatrixInData
	
	mov bx, offset matrix_blocks
	mov [matrix], bx 
	
	call putMatrixInScreen
	
@@end_loop:
	add bp, 324 ; the other block
	add si, 2
	pop cx
	loop @@drawAllBlocks
	
	popa
	ret
endp DrawBlock

;will print the saved background on the screen and by doing this it will erase the block
;will check if the block is alive and then print its save background
proc Erase_Block
	pusha

	xor si, si
	mov cx, 5
	xor bp, bp
@@drawAllBlocks:
	push cx
	cmp [Xpos_Blocks + si], 301 ; if this is out of screen dont draw
	ja @@end_loop
	
	
	;now we calculate the place
	mov ax, [Ypos_Blocks + si]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Blocks + si]
	
	mov cx, 18
	mov dx, 18
	
	mov bx, offset matrix_erase_blocks
	add bx, bp
	mov [matrix], bx 
	
	call putMatrixInScreen
	
@@end_loop:
	add bp, 324 ; the other block
	add si, 2
	pop cx
	loop @@drawAllBlocks

	popa
	ret
endp Erase_Block

;draws blocks using the stack - mainly for drawing towers
;[bp + 4] = x
;[bp + 6] = y
proc DrawBlock_Stack
	PUSH_ALL_BP
	
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
	POP_ALL_BP
	ret 4
endp DrawBlock_Stack


proc Draw_Triangle
	pusha
	
	xor si, si
	xor bp, bp
	mov cx, 5
@@drawTriangles:
	push cx
	cmp [Xpos_Triangle + si], 301 ; if this is out of screen dont draw
	ja @@end_loop
	
	
	; di = 320 * Ypos + Xpos
	mov ax, [Ypos_Triangle + si]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Triangle + si]
	
	mov cx, 9 ; rows
	mov dx, 18 ; cols
	
	mov bx, offset matrix_erase_triangle ; the data will be stored in this var
	add bx, bp
	mov [matrix], bx
	
	call putMatrixInData ; we will copy the background before drawing
	
	mov bx, offset matrix_triangle
	mov [matrix], bx

	call putMatrixInScreen
	
@@end_loop:
	add bp, 162
	add si, 2
	pop cx
	loop @@drawTriangles
	
	popa
	ret
endp Draw_Triangle

;will check if a triangle is on map, if yes print it
proc Erase_Triangle
	pusha
	
	xor si, si
	xor bp, bp
	mov cx, 5
@@drawTriangles:
	push cx
	
	cmp [Xpos_Triangle + si], 301 ; if this is out of screen dont draw
	ja @@end_loop
	
	
	; di = 320 * Ypos + Xpos
	mov ax, [Ypos_Triangle + si]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Triangle + si]
	
	mov cx, 9 ; rows
	mov dx, 18 ; cols
	
	mov bx, offset matrix_erase_triangle ; the data will be stored in this var
	add bx, bp
	mov [matrix], bx
	
	call putMatrixInScreen ; we will copy the background before drawing
	
@@end_loop:
	add bp, 162
	add si, 2
	pop cx
	loop @@drawTriangles

	popa
	ret
endp Erase_Triangle

;================================================
; Description -  draws a tower of blocks
; INPUT: cx - how many blocks we want, Xpos_Tower - will indicate where we want it
; OUTPUT: tower of blocks on screen
; Register Usage: None
;================================================
proc Draw_Tower
	pusha
	
	xor si, si
	xor bp, bp
	mov cx, 5
@@drawAllTowers:
	push cx
	cmp [Xpos_Tower + si], 301
	ja @@end_loop
	
	;we will save the tower height
	mov cx, [Height_Tower + si]
	
	;firstly we will calculate the ypos
	;how - (height of the platfrom)161 - cx * 18 = Ypos_Tower
	
	;18 * cx = ax
	mov ax, 18
	mul cx
	
	;161 - ax = bx
	mov bx, 161
	sub bx, ax
	
	mov [Ypos_Tower + si], bx
	
	call Copy_Background_Tower ; firstly we will copy the background
	
	;because cx has the number of blocks we want we can use it in a loop
@@draw_blocks: ; basically it draws the tower block by block from top to down
	push bx ; push y
	push [Xpos_Tower + si] ; push x
	
	call DrawBlock_Stack ; then draw it
	add bx, 18 ; add to y to draw the next block
	loop @@draw_blocks
@@end_loop:
	add si, 2
	add bp, 1620 ; a whole tower
	pop cx
	loop @@drawAllTowers
	
	popa
	ret
endp Draw_Tower

;we have a copy background var that holds 1620 bytes - for maximum height of five blocks
proc Copy_Background_Tower
	pusha
	
	mov ax, [Ypos_Tower + si] ; Ypos
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Tower + si] ; Xpos
	
	;the height of the tower is
	;cx = 18 * [Height_Tower] = height (columns)
	mov ax, [Height_Tower + si]
	mov cx, 18
	mul cx
	
	mov cx, ax
	mov dx, 18
	
	mov bx, offset matrix_erase_tower
	add bx, bp ; add to which tower we are saving the background
	mov [matrix], bx
	call putMatrixInData

	popa
	ret
endp Copy_Background_Tower

;goes each block and paints on it his background
proc Erase_Tower
	pusha
	
	xor si, si
	xor bp, bp
	mov cx, 5
@@eraseAllTowers:
	push cx
	cmp [Xpos_Tower + si], 301
	ja @@end_loop
	
	mov ax, [Ypos_Tower + si]
	mov bx, 320
	mul bx
	
	mov di, ax
	add di, [Xpos_Tower + si]
	
	;calculation of what to put in cx where using putMatrixInScreen
	
	mov ax, [Height_Tower + si]
	mov cx, 18
	mul cx
	
	mov cx, ax
	mov dx, 18
	
	mov bx, offset matrix_erase_tower
	add bx, bp
	mov [matrix], bx
	call putMatrixInScreen 
	
@@end_loop:
	add si, 2
	add bp, 1620
	pop cx
	loop @@eraseAllTowers
	
	popa
	ret
endp Erase_Tower

proc DrawPoint
	pusha
	
	cmp [Xpos_Points], 310
	ja @@end

	;calculating the place
	mov ax, [Ypos_Points]
	mov bx, 320
	mul bx

	mov di, ax
	add di, [Xpos_Points]
	
	mov cx, 11 ; height
	mov dx, 6 ; width

	call Copy_Background_Points ; copy the background
	
	mov bx, offset matrix_bonus ; now we change it to draw
	mov [matrix], bx
	
	call putMatrixInScreen ; drawing
	
@@end:
	popa
	ret
endp DrawPoint

proc Copy_Background_Points

	mov bx, offset matrix_erase_point
	mov [matrix], bx
	call putMatrixInData

	ret
endp Copy_Background_Points

proc Erase_point
	pusha
	
	cmp [Xpos_Points], 310
	ja @@end

	;calculating the place
	mov ax, [Ypos_Points]
	mov bx, 320
	mul bx

	mov di, ax
	add di, [Xpos_Points]
	
	mov cx, 11 ; rows
	mov dx, 6 ; col
	
	mov bx, offset matrix_erase_point
	mov [matrix], bx
	call putMatrixInScreen


@@end:
	popa
	ret
endp Erase_point

;================================================
; Description -  checks two keys - space and escape
; INPUT: key on keyboard
; OUTPUT: activates other function in case space is pressed, in case escape it ends the game
; Register Usage: None
;================================================
proc Key_Check
	pusha
	push ds
	
	mov ax, 3
	int 33h
	
	cmp bx, 1 ; check if left mouse clicked
	je @@jump
	
	in al, 60h
	
	cmp al, 1h
	je @@exit_game
	
	cmp al, 39h ; space
	je @@jump
	
	jmp @@end
	
@@exit_game:
	mov [IsExit], 1
	jmp @@end
	
@@jump:
	cmp [can_jump], 0
	je @@end ; if the bool 'can_jump' equals to one it means we are in the air so if mid air another jump was asked we wont confirm it
	mov [Is_Going_up], 1

@@end:
	push ax
	mov al,00h
	out 60h,al
	pop ax
	pop ds
	popa
	ret
endp Key_Check

;================================================
; Description -  checks if there is white or black under the cube - if yes there is floor
; INPUT: None
; OUTPUT: al will be one if there is floor under us
; Register Usage: None
;================================================
proc Check_floor_Under

	cmp [Ypos], 143
	je @@floor

	mov ah, 0dh
	mov cx, Xpos_Cube
	mov dx, [Ypos]
	add dx, [CurrentSize] ; down left
	int 10h
	cmp al, 0ffh ; check if white
	je @@floor
	
	cmp al, 0
	je @@floor
	
	add cx, [CurrentSize]
	add cx, 2
	int 10h
	cmp al, 0ffh ; check if white
	je @@floor
	
	cmp al, 0
	je @@floor
	
	sub cx, 12
	int 10h
	cmp al, 0ffh ; check if white
	je @@floor
	
	cmp al, 0
	je @@floor
	
	
	;did not see floor
	
	xor al, al
	jmp @@end

@@floor:
	mov al, 1

@@end:
	ret
endp Check_floor_Under

;check if our cube has hit any moving objects
proc Check_Hit
	pusha
	
	call Check_Point ; check if we hit a bonus point
	
	call Check_Blocks ; check if we died by blocks
	cmp al, 1
	je @@end_game
	
	;and we want to check if we hit a triangle
	call Check_Triangle ; if we died by a triangle
	cmp al, 1
	je @@end_game

	; if not it means nothing happend 
	jmp @@end
	
@@end_game:
	mov [IsExit], 1
	
@@end:
	popa
	ret
endp Check_Hit

;check if we are about to hit a point
proc Check_Point
	pusha
	
	;we will check x and y
	
	mov ax, [Xpos_Points] ; all sides of the cube 
	mov bx, [Ypos_Points]
	mov si, ax
	add si, 8 ;end of point X
	sub ax, 4
	mov di, bx
	add di, 13 ; end of point Y
	sub bx, 4
	
	mov cx, Xpos_Cube
	add cx, [CurrentSize]
	add cx, 7 ; a little bit forward of cube
	mov dx, [Ypos]
	
	;right up point of cube
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	;down right side of cube
	add dx, 9
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point

	add dx, 6
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	add dx, 8
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	add dx, 4
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub cx, 6 ; now we go backwards but still under the cube
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub cx, 6
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub cx, 6
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub cx, 6
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub cx, 3
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub dx, [CurrentSize]
	sub dx, 7
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	add cx, 6
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	add cx, 6
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	
	jmp @@end

@@catch_point:
	inc [BonusPointsCounter] ; sign that we hit a bonus point
	call Erase_point
	mov [Xpos_Points], -1

@@end:
	popa
	ret
endp Check_Point

;we get the cube X and Y from the registers cx and dx
;ax -left side of objects, si - right side of the objects, bx - upper side, di - down side
;retun bp 1 if we hit bonus point
proc CheckIsInPoint
	
	xor bp, bp
	;check X
	
	cmp cx, ax ; left side of point
	jb @@end ;  if below we are left to the point
	
	cmp cx, si ; right side of point
	ja @@end ; if above we are right to the point
	
	;check Y
	
	cmp dx, bx ; up side of the point
	jb @@end ; above the point
	
	cmp dx, di ; down side of the point
	ja @@end; below the point
	
	;if it got here we are in the point
	inc bp

@@end:
	ret
endp CheckIsInPoint

;if we hit blocks al will be one
proc Check_Blocks
	;we will use the 25 numbers because the maximun size of the cube is 25*25 while rotation
	;we will check three pixels to the right up and down
	mov ah,0Dh
	mov cx, Xpos_Cube
	mov dx, [Ypos]
	sub dx, 5
	sub cx, 4
	cmp [can_jump], 1 ; we wont check up if we dont go up
	je @@cont
	int 10H ; AL = COLOR
	cmp al, 0ffh ; check white
	je @@end_game
	
	cmp al, 0
	je @@end_game
	
@@cont:
	add dx, 5 ; right wall up
	add cx, [CurrentSize]
	add cx, 3
	int 10h
	cmp al, 0ffh ; check white
	je @@end_game

	add dx, [CurrentSize]
	dec dx
	int 10h
	cmp al, 0ffh ; check white
	je @@end_game
	
	;now we go down
	mov cx, Xpos_Cube ; right wall down
	mov dx, [Ypos]
	add cx, [CurrentSize]	;here we will check normal sides
	add dx, [CurrentSize]
	dec dx ; not on floor
	int 10H ; AL = COLOR
	cmp al, 0ffh ; check white
	je @@end_game

	inc cx
	int 10h
	cmp al, 0ffh ; check white
	je @@end_game

	inc cx
	int 10h
	cmp al, 0ffh ; check white
	je @@end_game
	
	cmp al, 0
	je @@end_game
	
	;now we go up
	cmp [can_jump], 1
	je @@end
	mov cx, Xpos_Cube
	mov dx, [Ypos]
	add cx, [CurrentSize]	;right wall up - above cube
	dec dx
	int 10H ; AL = COLOR
	cmp al, 0ffh ; check white
	je @@end_game
	
	dec dx
	int 10h
	cmp al, 0ffh
	je @@end_game
	
	sub cx, 9
	int 10h
	cmp al, 0ffh
	je @@end_game
	
	sub cx, 9
	int 10h
	cmp al, 0ffh
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
;this will check all triangle at once
proc Check_Triangle

	xor si, si
@@checkEachTriangle:
	
	mov ax, [Xpos_Triangle + si]
	cmp ax, 301
	ja @@end_loop
	
	;we will check two points - left down and right down (collision check)
	
	;save triangle place
	mov ax, [Xpos_Triangle + si] ; left side of triangle
	mov bx, [Ypos_Triangle + si] ; top of triangle
	
	;side of triangle
	mov di, ax 
	add di, 19 ;end of triangle in x
	
	mov bp, bx
	add bp, 8 ; end of triangle in y
	
	;left down
	mov cx, Xpos_Cube
	mov dx, [Ypos]
	add dx, [CurrentSize]
	
	sub di, 4
	cmp cx, ax
	jb @@check2 ; if below it means our left side of the cube is not on the triangle - to his left side
	
	cmp cx, di
	ja @@check2 ; if above it means our left side of the cube is not on the triangle - to ihs right side
	
	;if we got here it means our x is in the triangle x area
	;now we need to check the y
	
	cmp dx, bx
	jb @@check2 ; if below it means we are above the triangle
	
	cmp dx, bp
	ja @@check2
	
	;if it got here it means we are on the triangle
	jmp @@end_game
	
	;right side
@@check2:
	add cx, [CurrentSize]
	sub cx, 4
	;we need to check couple of x before the triangle and infront
	add di, 4
	sub ax, 3
	
	;now we will just copy the above
	cmp cx, ax
	jb @@check3 ;if the cube is left to the triangle
	
	cmp cx, di
	ja @@check3 ; if the cube is right to the triangle
	
	cmp dx, bx
	jb @@check3 ; if the cube is above the triangle
	
	cmp dx, bp
	ja @@check3
	
	;if it got here it means we are in the triangle
	jmp @@end_game
	
@@check3:
	sub cx, 10
	
	;now we will just copy the above
	cmp cx, ax
	jb @@end_loop ;if the cube is left to the triangle
	
	cmp cx, di
	ja @@end_loop ; if the cube is right to the triangle
	
	cmp dx, bx
	jb @@end_loop ; if the cube is above the triangle
	
	cmp dx, bp
	ja @@end_loop
	
	;if it got here it means we are in the triangle
	jmp @@end_game
	
	
@@end_loop:
	add si, 2
	cmp si, 8 ; five objects
	jb @@checkEachTriangle
	
	

@@end_check:
	xor al, al
	jmp @@end
	
@@end_game:
	mov al, 1
	mov [IsExit], 1
	
@@end:
	ret
endp Check_Triangle

;in case the jump has ended and we are not on the floor
;this will check if we have floor under us while falling from a block - when not jumpimg
proc Check_Fall
	pusha

	;we need to go down - no floor
	mov [Is_Falling], 1
	mov [can_jump], 0
	add [Ypos], 6
	cmp [Ypos], 137
	ja @@hit_floor
	jmp @@end
	
@@hit_floor:
	
	mov [Ypos], 143
	mov [can_jump], 1 ; we can jump again - in case we are falling we will cancel the jump movement so when when stop falling we cant jump
	mov [Is_Falling], 0
	mov [Is_Going_down], 0
	
@@end:
	popa
	ret
endp Check_Fall

;================================================
; Description -  goes up until going 30 vertical up
; INPUT: None
; OUTPUT: cube goes up
; Register Usage: None
;================================================
proc Cube_Ascend
	pusha
	
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
	popa
	ret
endp Cube_Ascend


;================================================
; Description -  goes down when there is not white under the cube
; INPUT: None
; OUTPUT: cube goes down
; Register Usage: None
;================================================
proc Descending
	pusha
	
	add [Ypos], 9
	
	call Check_Triangle
	cmp al, 1
	je @@end
	
	call Check_floor_Under
	cmp al, 1
	je @@end_jump
	
	jmp @@end

@@end_jump:
	mov [can_jump], 1
	mov [Is_Going_down], 0 ; finished going down
	
@@end:
	popa
	ret
endp Descending

;checks if we are on cube - only be used after finishing a jump
proc Check_Where_Cube
	push dx
	cmp [Is_Going_up], 1
	je @@end

	cmp [Is_Going_down], 1 ; if we are still jumping
	je @@end

	;now if it got here we landed after a jump
	;to check if we are on ground we need to add our size to the ypos and check if it is equal to 161 - floor height
	mov dx, [Ypos]
	add dx, [CurrentSize]
	
	cmp dx, 161 ; the y it supposed to be while on floor
	jb @@above_ground
	
	jmp @@on_ground

@@above_ground:
	
	call Check_floor_Under
	cmp al, 0 ; in the air - no floor
	je @@falling
	
	mov [can_jump], 1
	jmp @@end
	
@@falling:
	mov [Is_Falling], 1
	jmp @@end
	
@@on_ground:
	mov [Is_Going_up], 0
	mov [Is_Going_down], 0

@@end:
	pop dx
	ret
endp Check_Where_Cube

;main function of the cube
;checks the state of the cube with bools, and starts each function
proc Cube_Move
	pusha
	
	call Check_Hit
	cmp [IsExit], 1
	je @@end
	
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
	call Check_Hit ; if we got into a block or triangle and died
	
	
@@end:
	popa
	ret
endp Cube_Move

;picks a random level each time a level has ended
proc PickLevel
	pusha
	
	;if even the last level has ended
	cmp [Objects_Placed], 1 ; if a level is in screen then dont create another level
	je @@put_level
	
	mov bl, 1 ; min level
	mov bh, 7 ; max numbers of levels
	call RandomByCs
	;now al has the number of the level
	mov [CurentLevel], al
	
@@put_level:
	mov al, [CurentLevel]
	
	cmp al, 1
	je @@level_one
	
	cmp al, 2
	je @@level_two
	
	cmp al, 3
	je @@level_three
	
	cmp al, 4
	je @@level_four
	
	cmp al, 5
	je @@level_five
	
	cmp al, 6
	je @@level_six
	
	cmp al, 7
	je @@level_seven
	
@@level_one:
	call Level_One
	jmp @@end
	
@@level_two:
	call Level_Two
	jmp @@end
	
@@level_three:
	call Level_Three
	jmp @@end
	
@@level_four:
	call Level_Four
	jmp @@end
	
@@level_five:
	call Level_Five
	jmp @@end
	
@@level_six:
	call Level_Six
	jmp @@end
	
@@level_seven:
	call Level_Seven
	jmp @@end
	
	
@@end:
	popa
	ret
endp PickLevel
;
;
;		
;       █
; █     █     ▲
proc Level_One
	cmp [Objects_Placed], 1 ; check if we already placed the objects
	je @@move_objects
	
	mov [Objects_Placed], 1 ; signs that we are putting the objects in place
	mov [Height_Tower], 2 ; height of three blocks of tower
	mov [Xpos_Blocks], 400 ; first block
	mov [Ypos_Blocks], 143
	
	mov [Xpos_Triangle], 660 ; last triangle
	mov [Ypos_Triangle], 152
	
	mov [Xpos_Tower], 520 ; the tower
	
	call Draw_All ; we need to draw the objects first to erase them after
	
@@move_objects:
	call Erase_All
	
	sub [Xpos_Triangle], 5
	cmp [Xpos_Triangle], 64000
	ja @@end_level
	sub [Xpos_Tower],5
	sub [Xpos_Blocks], 5
	
	call Draw_All
	jmp @@end
	
@@end_level:
	mov [Objects_Placed], 0
	
@@end:
	ret
endp Level_One
;
;               
;        		•
;        █		█
; ▲      █		       ▲
proc Level_Two
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1 ; signs that we are putting the objects in place
	mov [Xpos_Triangle], 360 ; first triangle
	mov [Ypos_Triangle], 152
	mov [Xpos_Tower], 490 ; the tower
	mov [Height_Tower], 2 ; height of 3 blocks
	mov [Xpos_Blocks], 580 ; floating block
	mov [Ypos_Blocks], 125
	mov [Xpos_Points], 586 ; bonus point above block
	mov [Ypos_Points], 110
	mov [Xpos_Triangle + 2], 710 ; last triangle
	mov [Ypos_Triangle + 2], 152
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, 5

	sub [Xpos_Triangle], ax
	sub [Xpos_Triangle + 2], ax
	cmp [Xpos_Triangle + 2], 64000
	ja @@end_level
	
	sub [Xpos_Tower], ax
	sub [Xpos_Blocks], ax
	sub [Xpos_Points], ax
	
	call Draw_All
	jmp @@end
	
@@end_level:	
	mov [Objects_Placed], 0

@@end:
	ret
endp Level_Two

;
;                      •
;                      
;  ▲            █      
;  █     ▲▲     █
proc Level_Three
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	mov [Xpos_Blocks], 320 ; first block
	mov [Ypos_Blocks], 143
	mov [Xpos_Triangle], 320 ; first triangle above block
	mov [Ypos_Triangle], 134
	mov [Xpos_Triangle + 2], 440 ; second triangle before third triangle
	mov [Ypos_Triangle + 2], 152
	mov [Xpos_Triangle + 4], 460 ; third triangle
	mov [Ypos_Triangle + 4], 152
	mov [Xpos_Tower], 590
	mov [Height_Tower], 2 ; tower of 2 blocks
	mov [Xpos_Points], 656 ; bonus point
	mov [Ypos_Points], 92
	
	call Draw_All
	
@@move_objects:
	
	call Erase_All
	
	mov ax, 6
	
	sub [Xpos_Blocks], ax
	sub [Xpos_Triangle], ax
	sub [Xpos_Triangle + 2], ax
	sub [Xpos_Triangle + 4], ax
	sub [Xpos_Tower], ax
	sub [Xpos_Blocks + 2], ax
	sub [Xpos_Points], ax
	cmp [Xpos_Points], 64000
	ja @@end_level
	
@@draw:
	call Draw_All
	jmp @@end
	
@@end_level:
	cmp [Xpos_Tower], 64000 ; if we ate the bonus point before the level has ended ot will finish the level - so we will check if the tower has exited the screen
	jb @@draw
	mov [Objects_Placed], 0
	
	@@end:
	ret
endp Level_Three

;
;          
;       █   ▲
;       █   █  █ 
;  █    █      █  ▲
proc Level_Four
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	mov [Xpos_Blocks], 330 ; first block
	mov [Ypos_Blocks], 143
	mov [Xpos_Tower], 395 ; first tower
	mov [Height_Tower], 3
	mov [Xpos_Blocks + 2], 455 ; second floating block
	mov [Ypos_Blocks + 2], 125
	mov [Xpos_Triangle], 455 ; floating triangle
	mov [Ypos_Triangle], 116
	mov [Xpos_Tower + 2], 505 ; second tower
	mov [Height_Tower + 2], 2 ; height of two blocks
	mov [Xpos_Triangle + 2], 545 ; second triangle
	mov [Ypos_Triangle + 2], 152
	
	sub [delay], 7
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, 5
	sub [Xpos_Blocks], ax
	sub [Xpos_Blocks + 2], ax
	sub [Xpos_Tower], ax
	sub [Xpos_Tower + 2], ax
	sub [Xpos_Triangle], ax
	sub [Xpos_Triangle + 2], ax
	cmp [Xpos_Triangle + 2], 64000
	ja @@end_level
	
	call Draw_All
	jmp @@end

@@end_level:
	mov [Objects_Placed], 0
	add [delay], 7

@@end:
	ret
endp Level_Four

;
;
;        ▲     
;        █     █
;   ▲█         █      ▲
proc Level_Five
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	mov [Xpos_Triangle], 330 ; first triangle
	mov [Ypos_Triangle], 152
	mov [Xpos_Blocks], 350 ; first block
	mov [Ypos_Blocks], 143
	mov [Xpos_Blocks + 2], 420 ; second floating block
	mov [Ypos_Blocks + 2], 125
	mov [Xpos_Triangle + 2], 420;second floating triangle
	mov [Ypos_Triangle + 2], 116
	mov [Xpos_Tower], 515 ; tower
	mov [Height_Tower], 2
	mov [Xpos_Triangle + 4], 590
	mov [Ypos_Triangle + 4], 152
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, 5
	sub [Xpos_Triangle], ax
	sub [Xpos_Blocks], ax
	sub [Xpos_Blocks + 2], ax
	sub [Xpos_Triangle + 2], ax
	sub [Xpos_Tower], ax
	sub [Xpos_Triangle + 4], ax
	cmp [Xpos_Triangle + 4], 64000
	ja @@end_level
	
	call Draw_All
	jmp @@end
	
@@end_level:
	mov [Objects_Placed], 0
@@end:
	ret
endp Level_Five

;
;
;      •
;   █         █
;   █   ██▲   █
proc Level_Six
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	mov [Xpos_Tower], 330 ; first tower
	mov [Height_Tower], 2
	mov [Xpos_Points], 405 ; bonus point
	mov [Ypos_Points], 85
	mov [Xpos_Blocks], 455 ; first block
	mov [Ypos_Blocks], 143
	mov [Xpos_Blocks + 2], 474 ; second block
	mov [Ypos_Blocks + 2], 143
	mov [Xpos_Triangle], 435 ; first triangle
	mov [Ypos_Triangle], 152
	mov [Xpos_Tower + 2], 580 ; second tower
	mov [Height_Tower + 2], 2
	
	sub [delay], 4
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, 5
	sub [Xpos_Tower], ax
	sub [Xpos_Points], ax
	sub [Xpos_Blocks], ax
	sub [Xpos_Blocks + 2], ax
	sub [Xpos_Triangle], ax
	sub [Xpos_Tower + 2], ax
	cmp [Xpos_Tower + 2], 6400
	ja @@end_level
	
	
	call Draw_All
	jmp @@end
@@end_level:
	mov [Objects_Placed], 0
	add [delay], 4
@@end:
	ret
endp Level_Six

;
;
;            █
;   █        █
;   █  ▲▲ █  █
proc Level_Seven
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	
	mov [Xpos_Tower], 330 ; first tower
	mov [Height_Tower], 2
	mov [Xpos_Triangle], 380 ; first triangle
	mov [Ypos_Triangle], 152
	mov [Xpos_Triangle + 2], 400 ; second triangle
	mov [Ypos_Triangle + 2], 152
	mov [Xpos_Blocks], 455 ; first block
	mov [Ypos_Blocks], 143
	mov [Xpos_Tower + 2], 560
	mov [Height_Tower + 2], 3
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, 5
	sub [Xpos_Tower], ax
	sub [Xpos_Blocks], ax
	sub [Xpos_Triangle], ax
	sub [Xpos_Triangle + 2], ax
	sub [Xpos_Tower + 2], ax
	cmp [Xpos_Tower + 2], 6400
	ja @@end_level
	
	
	call Draw_All
	jmp @@end
@@end_level:
	mov [Objects_Placed], 0
@@end:
	ret
endp Level_Seven

proc Draw_All
	call Draw_Tower
	call Draw_Triangle
	call DrawBlock
	call DrawPoint
	ret
endp Draw_All

proc Erase_All
	call Erase_Tower
	call Erase_point
	call Erase_Triangle
	call Erase_Block
	ret
endp Erase_All

;will take all the frames of rotation and turn them into matrix
proc Transfer_bmp_matrix
	;90 degrees
	mov [CurrentSize], 18
	mov bx, offset matrix_cube
	mov [offset_matrix], bx
	mov dx, offset FileName_cube
	call CopyBmp
	
	;5 degrees
	mov [CurrentSize], 20
	mov bx, offset matrix_cube5
	mov [offset_matrix], bx
	mov dx, offset FileName_cube5
	call CopyBmp
		
	;10 degrees
	mov [CurrentSize], 21
	mov bx, offset matrix_cube10
	mov [offset_matrix], bx
	mov dx, offset FileName_cube10
	call CopyBmp
	
	;15 degrees
	mov [CurrentSize], 22
	mov bx, offset matrix_cube15
	mov [offset_matrix], bx
	mov dx, offset FileName_cube15
	call CopyBmp
	
	;20 degrees
	mov [CurrentSize], 23
	mov bx, offset matrix_cube20
	mov [offset_matrix], bx
	mov dx, offset FileName_cube20
	call CopyBmp
	
	;25 degrees
	mov [CurrentSize], 24
	mov bx, offset matrix_cube25
	mov [offset_matrix], bx
	mov dx, offset FileName_cube25
	call CopyBmp
	
	;30 degrees
	mov [CurrentSize], 24
	mov bx, offset matrix_cube30
	mov [offset_matrix], bx
	mov dx, offset FileName_cube30
	call CopyBmp
	
	;35 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube35
	mov [offset_matrix], bx
	mov dx, offset FileName_cube35
	call CopyBmp
	
	;40 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube40
	mov [offset_matrix], bx
	mov dx, offset FileName_cube40
	call CopyBmp
	
	;45 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube45
	mov [offset_matrix], bx
	mov dx, offset FileName_cube45
	call CopyBmp
	
	;50 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube50
	mov [offset_matrix], bx
	mov dx, offset FileName_cube50
	call CopyBmp
	
	;55 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube55
	mov [offset_matrix], bx
	mov dx, offset FileName_cube55
	call CopyBmp
	
	;60 degrees
	mov [CurrentSize], 24
	mov bx, offset matrix_cube60
	mov [offset_matrix], bx
	mov dx, offset FileName_cube60
	call CopyBmp
	
	;65 degrees
	mov [CurrentSize], 24
	mov bx, offset matrix_cube65
	mov [offset_matrix], bx
	mov dx, offset FileName_cube65
	call CopyBmp
	
	;70 degrees
	mov [CurrentSize], 23
	mov bx, offset matrix_cube70
	mov [offset_matrix], bx
	mov dx, offset FileName_cube70
	call CopyBmp
	
	;75 degrees
	mov [CurrentSize], 22
	mov bx, offset matrix_cube75
	mov [offset_matrix], bx
	mov dx, offset FileName_cube75
	call CopyBmp
	
	;80 degrees
	mov [CurrentSize], 21
	mov bx, offset matrix_cube80
	mov [offset_matrix], bx
	mov dx, offset FileName_cube80
	call CopyBmp
	
	;85 degrees
	mov [CurrentSize], 19
	mov bx, offset matrix_cube85
	mov [offset_matrix], bx
	mov dx, offset FileName_cube85
	call CopyBmp
	
	mov [CurrentSize], 18
	ret
endp Transfer_bmp_matrix

proc printAxDec  
	   
       push bx
	   push dx
	   push cx
	           	   
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_next_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_next_to_stack

	   cmp ax,0
	   jz pop_next_from_stack  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next_from_stack: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next_from_stack

	   pop cx
	   pop dx
	   pop bx
	   
       ret
endp printAxDec 

;bmp files


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

;for making it matrix
proc CopyBmp near
		 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	

	call MatrixBMP
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp CopyBmp

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
	
	mov ax, 0A000h ; the offset we want to transfer
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


;this will be used for transfering the picture from bmp to matrix
proc MatrixBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, ds ; we will make es to ds and make di the offset of var we want to copy the picture to
	mov es, ax
	
	mov cx,[CurrentSize]
	
 
	mov ax,[CurrentSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	xor dx, dx
	mov di, [offset_matrix]
	mov ax, [CurrentSize]
	mul ax
	add di, ax
	add di, [CurrentSize]
	
@@NextLine:
	push cx
	push dx
	
	;fix matrix becuasewe draw it upside down
	;move di to last line then up it each loop cycle
	
	sub di, [CurrentSize]
	sub di, [CurrentSize]
	 
	; small Read one line
	mov ah,3fh
	mov cx,[CurrentSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[CurrentSize]  
	mov si,offset ScrLine
	
	;we will create rep movsb but we will check if its outside wall or inside wall
@@rep_movsb:
	mov al, [ds:si]
	cmp al, 3fh ; outside wall 
	je @@out_wall
	
	cmp al, 9h; inside wall
	je @@in_wall
	jmp @@putcolor
	
@@out_wall:
	mov al, [OutSideColor]
	jmp @@putcolor
	
@@in_wall:
	mov al, [InsideColor]
	
@@putcolor:
	mov [es:di], al
	inc si
	inc di
	loop @@rep_movsb
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret 
endp MatrixBMP 

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

;matrix

; in dx how many cols 
; in cx how many rows
; in matrix - the bytes
; in di start byte in screen (0 64000 -1)

proc putMatrixInScreen
	pusha
	
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
	cmp al, 1
	je @@end ; if it is equal to one we need to skip it
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
	
	popa
    ret
endp putMatrixInScreen

; in dx how many cols 
; in cx how many rows
; in matrix - the offset of the var we want to copy to
; in di start byte in screen (0 64000 -1)
proc putMatrixInData
	pusha
	
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
	mov [byte ds:si], al
	inc si
	inc di
	loop @@copy_data
	
	sub di,dx
	add di, 320
	
	
	pop cx
	loop @@NextRow
	
	

	
	popa
    ret
endp putMatrixInData 

; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. Bl = min (from 0) , BH , Max (till 255)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        Al - rnd num from bl to bh  (example 50 - 150)
; More Info:
; 	Bl must be less than Bh 
; 	in order to get good random value again and agin the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCs
    push es
	push si
	push di
	
	mov ax, 40h
	mov	es, ax
	
	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP
 
	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
RandLoop: ;  generate random number 
	mov ax, [es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)
	xor al, ah ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	cmp di,(EndOfCsLbl - start - 1)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop
	
	add al,bl  ; add the lower limit to the rnd num
		 
@@ExitP:	
	pop di
	pop si
	pop es
	ret
endp RandomByCs

; make mask acording to bh size 
; output Si = mask put 1 in all bh range
; example  if bh 4 or 5 or 6 or 7 si will be 7
; 		   if Bh 64 till 127 si will be 127
Proc MakeMask    
    push bx

	mov si,1
    
@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop bx
	ret
endp  MakeMask

EndOfCsLbl:
END start