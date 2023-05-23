;																			              Geometry Dash
.486
IDEAL
MODEL small

STACK 100h

;For playing this game set DOSBOX to 10000 cycles
;cycles=10000

;================================================
; Description -  draws a full BMP picture on screen
; INPUT: DX needs to be set for the offset of the file name
; OUTPUT: Full BMP picture on screen
; Register Usage: None
;================================================
macro DRAW_FULL_BMP
	;mov dx, ?
	push 0
	push 0
	push 320
	push 200
	call DrawPictureBmp
endm DRAW_FULL_BMP

; -- const variables --
;Cube
Xpos_Cube = 50 ; the Xpos of the cube won't change in this whole game so we will make it a const

Cube_Max_Size = 25*25 ; the cube reg size is 18*18 but while rotating it changes, so we will put the max size it can get

;Objetcs
Max_Objects = 5 ; blocks and triangles can appear max five times in one level

Max_Objects_Towers = 3 ; drawing and erasing a tower takes time so the max towers will be three and not five to make the game feels smooth

;Triangle
Triangle_Size = 9*18 ; triangle height of 9 by width of 18

;Blocks
Block_Size = 18*18 ; block height 18 by width of 18

;Bonus point
Bonus_Point_Size = 11*6 ; bonus point height 11 by width of 6

;Tower
Tower_Size = 18*18*5 ; 18*18 = one block, this multiplied by five means maximum of five block
;A tower is built from blocks stacked upon eachother therefore we will draw it block by block but erase it like a full objects

Starting_Pos = -1 ; the defult X of all the objects is minus because if it is zero it still counts like it is in the screen

;bmp
Max_Bmp_Width = 320 ; the max bmp width is 320 so it will work on every picture we want to print to the screen

;speed objects
MovingObjectsXSpeed = 5 ; in level speed all of the objects will move five X to the left (minus five X)

;Xpos to check - of above the objects is out of the screen
OutOfScreenX = 64000 ; this don't need to be the specific number we just want to check if below zero (we can also check by signed numbers)

DATASEG
; --------------------------

;random
RndCurrentPos dw start ; random label

; -- player --

;score
bool_won db ? ; if the player has the best score we will print his name on the final board

;start over
bool_start_over db ? ; will be changed by the player desicion in the end screen - if pressed yes or no

;speed
delay dw 80 ; delay between each frame
SaveDelay dw 80 ; when resetting the game, the delay will not allways be the original because the levels change the delay, so we will save it in another variable and when resetting we will use it

;picked color
;these colors will be picked by the player in the start screen
OutSideColor db 3fh ; defult yellow outside color
InsideColor db 9h ; dufult light blue inside color

;name
NamePlayer db 14, 16 dup (?), '$' ; name of the player which is inserted before starting

;Bonus points
BonusPointsCounter db ? ; the amount of times the player took a red bonus point

;seconds alive
counterSeconds db ? ; mini counter for seconds - when hitting 27 one second has past
seconds dw ? ; the amount of seconds the player has been alive

;score
PlayerScoreRealNum dw ? ; final score of the player 
PlayerScoreTXT db "xxxx", '$' ; the number above but in text to print in end screen

; -- Cube variables --
CurrentSize dw 18 ; size of the cube according to each frame - while rotation

; -- loop var --
IsExit db ? ; to know if the game has ende

; -- jump vars --
can_jump db 1 ; will sign if we are falling from a platform

;rotation in air
timeInAir db ? ; to know which frame to print - 18 frames
;it takes 18 frames to make a full jump
;so when this timer hits the number 18 it finished the jump
;each frame will be selected by the number in this var

;directions bools 
Is_Going_up db ? ; if the cube is currently going up
Is_Going_down db ? ; if the cube is currently going down
Is_Falling  db ? ; if the cube is currently falling
;falling is a state when the cube didnt jump but in air - example: the cube landed on a block and did jump again

;height calculation for jumping
Max_height dw ? ; max height when jumping will be calculated once
Middle_Height dw ? ; to slow down mid jump
bool_calc_max_height db ? ; if we have calculated max height to not repeat

; -- position --

;cube
Ypos dw 143 ; we only need the ypos because the cube wont change its place on screen only will jump - only changes in the ypos

; -- blocks --

;we will put in all the objects minus one -1 because we will check if an object is in the map (to know if to draw) by checking if below 301
;the reason for 301 is because the objects width is 18
;we will only check if below 301 in unsigned numbers
;when an objects goes from right to left its Xpos will eventully be 0fffh - so we will only draw an objects if is in 0 - 301 (x range)
Xpos_Blocks dw Max_Objects dup (Starting_Pos) ; five blocks Xpos set to minus one
Ypos_Blocks dw Max_Objects dup (?) ; five blocks Ypos set to ?


; -- Triangle --
Xpos_Triangle dw Max_Objects dup (Starting_Pos) ; five triangles Xpos set to minus one
Ypos_Triangle dw Max_Objects dup (?) ; five triangles Ypos set to ?

; -- Tower --
;when creating towers we will give the height of the tower instead Ypos
Xpos_Tower dw Max_Objects_Towers dup (Starting_Pos) ; three towers Xpos set to minus one
Ypos_Tower dw Max_Objects_Towers dup (?) ; three towers Ypos to set to ?
Height_Tower dw Max_Objects_Towers dup (?) ; three towers number of block set to ?

; -- Bonus Points --
Xpos_Points dw Starting_Pos ; one bonus point Xpos set to minus one
Ypos_Points dw ? ; one bonus point Ypos set to ?

; -- levels --
Objects_Placed db ? ; indicates if on the screen there are objects, if not randomize a new level
CurentLevel db ? ; will be randomized when a level has ended

; -- drawing using matrix --

; -- cube --

;these frames will be created only after the name of the player has been inserted (only when the game really starts), up until then this data will be left empty
matrix_cube5  db 20*20 dup (?) ; 5°
matrix_cube10 db 21*21 dup (?) ; 10°
matrix_cube15 db 22*22 dup (?) ; 15°
matrix_cube20 db 23*23 dup (?) ; 20°
matrix_cube25 db 24*24 dup (?) ; 25°
matrix_cube30 db 24*24 dup (?) ; 30°
matrix_cube35 db 25*25 dup (?) ; 35°
matrix_cube40 db 25*25 dup (?) ; 40°
matrix_cube45 db 25*25 dup (?) ; 45°
matrix_cube50 db 25*25 dup (?) ; 50°
matrix_cube55 db 25*25 dup (?) ; 55°
matrix_cube60 db 24*24 dup (?) ; 60°
matrix_cube65 db 24*24 dup (?) ; 65°
matrix_cube70 db 23*23 dup (?) ; 70°
matrix_cube75 db 22*22 dup (?) ; 75°
matrix_cube80 db 21*21 dup (?) ; 80°
matrix_cube85 db 19*19 dup (?) ; 85°
matrix_cube   db 18*18 dup (?) ; 90°

;erase cube
matrix_erase_cube db Cube_Max_Size dup (?) ; max sizes of main cube

; -- triangle block --
;to create a triangle we have to make an invisble color - this color will be 1
matrix_triangle db  1,  1,   1,  1,  1,  1,  1,  1,0ffh,0ffh,1,  1,   1,  1,  1,  1,    1,1 ; paint bytes of triangle matrix
				db  1,  1,   1,  1,  1,  1,  1,0ffh,0,0,0ffh,1,   1,  1,  1,  1,    1,1
				db  1,  1,   1,  1,  1,  1,0ffh,0,  0,  0,  0,0ffh, 1,  1,  1,  1,    1,1
				db  1,  1,   1,  1,  1,0ffh, 0,  0,  0,  0,  0,  0,0ffh,1,  1, 1,1,1
				db  1,  1,   1,  1,0ffh,  0,  0,  0,  0,  0,  0,  0, 0,0ffh,1,  1, 1,1
				db   1,  1,  1,0ffh,0, 0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh,1,  1, 1
				db   1,  1,0ffh,0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh, 1, 1
				db   1,0ffh, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh, 1
				db 0ffh,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,0ffh

;erasing the triangle
matrix_erase_triangle db Triangle_Size dup (?), Triangle_Size dup (?), Triangle_Size dup (?), Triangle_Size dup (?), Triangle_Size dup (?) ; five background bytes vars to save the background of the triangles

; -- blocks --
;black cube inside white cube
matrix_blocks   db 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh ; paint bytes of block matrix
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
matrix_erase_blocks db Block_Size dup (?), Block_Size dup (?), Block_Size dup (?), Block_Size dup (?), Block_Size dup (?) ; five background bytes vars to save the background of the blocks

; -- bonus points --
matrix_bonus db Bonus_Point_Size dup (0fh) ; paint bytes of bonus point matrix

;erasing point
matrix_erase_point db Bonus_Point_Size dup (?) ; one bacgkround bytes var to save the bacgkround of the bonus points

; towers dont have matrix to paint because it uses the blocks matrix to paint itself block by block from up to down

;erase tower
matrix_erase_tower db Tower_Size dup (?), Tower_Size dup (?), Tower_Size dup (?) ; three bacgkround bytes var to save the bacgkround of the towers

matrix dw ? ; holds the offset of the mtarix we want to print

; -- FILES --

ScrLine db Max_Bmp_Width dup (?)  ; Saves one line from the picture file in this var and then prints it on screen

;BMP File data
FileHandle dw ?
Header db 54 dup(?) ; first 54 bytes of the bmp file - Header
Palette db 400h dup (?) ; second 1024 bytes the bmp file - 256 * 4 color (every color has four colors (RGB + null))
;after that the picture itself is the data after reading the Header and the Palette

;place on screen
BmpLeft dw ? ; the Xpos of the bmp file picture on screen
BmpTop dw ? ; the Ypos of the bmp file picture on screen
BmpColSize dw ? ; the width of the bmp file picture on screen
BmpRowSize dw ? ; the height of the bmp file picture on screen

;errors
ErrorFile db ?
BmpFileErrorMsg db 'Error At Opening Bmp File ', 0dh, 0ah,'$' ; BMP error msg with the file name

;screens
FileName_background db 'back.bmp' ,0 ; background - main screen
FileName_start db 'start.bmp', 0 ; start screen (before start of game)
FileName_EnterName db 'name.bmp', 0 ; middle button start screen -  enter your name
FileName_Settings db 'settings.bmp', 0 ; right button in start screen
FileName_Guide db 'guide.bmp', 0 ; left button in start screen - how to play
FileName_NameError db 'nameEr.bmp', 0 ; in case no chars have been entered in the name enter we print an error
FileName_End db 'end.bmp', 0 ; end screen after died or after pressed ESC

;cube rotation frames
;we will only open them ones to transfer to matrix
;every number is the angle of the cube
FileName_cube5  db 'cube5.bmp' , 0 ; 5°
FileName_cube10 db 'cube10.bmp', 0 ; 10°
FileName_cube15 db 'cube15.bmp', 0 ; 15°
FileName_cube20 db 'cube20.bmp', 0 ; 20°
FileName_cube25 db 'cube25.bmp', 0 ; 25°
FileName_cube30 db 'cube30.bmp', 0 ; 30°
FileName_cube35 db 'cube35.bmp', 0 ; 35°
FileName_cube40 db 'cube40.bmp', 0 ; 40°
FileName_cube45 db 'cube45.bmp', 0 ; 45°
FileName_cube50 db 'cube50.bmp', 0 ; 50°
FileName_cube55 db 'cube55.bmp', 0 ; 55°
FileName_cube60 db 'cube60.bmp', 0 ; 60°
FileName_cube65 db 'cube65.bmp', 0 ; 65°
FileName_cube70 db 'cube70.bmp', 0 ; 70°
FileName_cube75 db 'cube75.bmp', 0 ; 75°
FileName_cube80 db 'cube80.bmp', 0 ; 80°
FileName_cube85 db 'cube85.bmp', 0 ; 85°
FileName_cube   db 'cube.bmp'  , 0 ; 90°

;scores

FileName_Scores db 'scores.txt', 0 ; the name of the highest score ever
FileHandleScores dw ? ; the file handle

ScoreInFile db "xxxx", '$' ; score in file in text
ScoreFileRealNum dw ? ; the score in file converted to number

ErasePrevName db 13 dup ('x') ; if a player did a new high score (this is set to 13 because a player can't play the game without at least one char in his name)
FileScoreHolder db 14 dup ('$') ; the name of the best player with the highest score
	
;In graphics modes, the screen contents around the current mouse cursor position are ANDed with the screen mask and then XORed with the cursor mask
;screen mask ->
;1 - don't touch, 0 - draw (it will draw black without the cursor mask because we force it to be black with AND)
MouseMask 	dw 1111111111111111b
			dw 1111111111111111b
			dw 1000000000000001b
			dw 1000000000000001b
			dw 1001110000111001b
			dw 1001110000111001b
			dw 1001110000111001b
			dw 1000000000000001b
			dw 1000000000000001b
			dw 1000000000000001b
			dw 1001111111111001b
			dw 1001111111111001b
			dw 1000000000000001b
			dw 1000000000000001b
			dw 1111111111111111b
			dw 1111111111111111b
;cursor mask ->
;we will put a color on the cursor mask
;0 - don't touch, 1 - put color (because we are doing XOR it will make all the zeros from before to ones)
			dw 0000000000000000b
			dw 0000000000000000b
			dw 0111111111111110b
			dw 0111111111111110b
			dw 0110001111000110b
			dw 0110001111000110b
			dw 0110001111000110b
			dw 0111111111111110b
			dw 0111111111111110b
			dw 0111111111111110b
			dw 0110000000000110b
			dw 0110000000000110b
			dw 0111111111111110b
			dw 0111111111111110b
			dw 0000000000000000b
			dw 0000000000000000b
; --------------------------

CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
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
	
	cmp [bool_start_over], 1 ; if the player decided to start the game again
	je start_over
; --------------------------
exit:
	call clearkeyboardbuffer ; erase all the keys from buffer

	mov ax,2	;returns the screen to text mode
	int 10h
	
	mov ax, 4c00h ; gets dos box the control
	int 21h
; --------------------------

;================================================
; Description -  sets dos box to graphics mode and set mouse limits in X and Y and changes the mouse cursor
; INPUT: None
; OUTPUT: Graphics mode and new mouse settings
; Register Usage: None
;================================================
proc SettingsGame
	call SetGraphics ; sets to graphics mode
	
	call SetMouse ; set mouse limits of screen and changes cursor
	ret
endp SettingsGame

;================================================
; Description -  shows starting screens, after the player entered his name in "name screen" all the frame of the cube will be tranfered to matrix in DS
;				 After that it will draw the background of the game and draw the static position of the cube
; INPUT: None
; OUTPUT: Start screens and game screen and cube matrix on screen
; Register Usage: None
;================================================
proc StartingGame
	mov [bool_start_over], 0 ; we will assume that the player does not want to play again, if he chooses to play again this bar will be reset in the reset function
	
	call MouseShow ; for loading screens
	call Transfer_bmp_matrix ; transfer all frames into matrix after picking the colors
	
	;when the player got here the game has started
	
	call DrawBackground ; drawing the background
	call DrawCube ; drawing the cube
	
	push 500 ; delay before starting the game
	call LoopDelay
	
	ret
endp StartingGame

;================================================
; Description -  Picks a random level and plays it, moves the cube according to the bools and counts seconds
;				 And makes a delay
; INPUT: None
; OUTPUT: Generating random level and moves the cube
; Register Usage: None
;================================================
proc GameLoop
	call PickLevel ; picks a random level
	
	call Cube_Move ; moving the cube according to the bools
	
	call CountSeconds ; counting seconds 
	
	push [delay] ; delay
	call LoopDelay
	ret
endp GameLoop

;================================================
; Description -  calculates the player score and compare it to the highest score saved in "score.txt" file - if higher changes the name and score
;				 Then prints the end screen and writes all the score - player score, highest score, and highest score holder
;				 (if the player did the highest score his name and score will show up as the highest)
; INPUT: None
; OUTPUT: End screen shows up
; Register Usage: None
;================================================
proc EndGame
	pusha
	
	call ChangeScoreHighest ; handles the score using the file
	call End_Screen ; end screen printing and writing and mouse
	
	;now we close the file
	
	mov ah, 3eh
	mov bx, [FileHandleScores]
	int 21h
	
	popa
	ret
endp EndGame
	
;================================================
; Description -  calculates the player score - seconds + bonus_points * 2
; INPUT: None
; OUTPUT: Player score saved in DS - "PlayerScoreRealNum"
; Register Usage: None
;================================================
proc CalcScore
	pusha
	
	;number of bonus point * 2
	xor ax, ax
	mov al, [BonusPointsCounter]
	shl ax, 1 ; multiply by two
	
	add ax, [seconds]

	mov [PlayerScoreRealNum], ax ; save in var

	popa
	ret
endp CalcScore

;================================================
; Description -  takes the score in file and turns it into a real number, after that it compares our calculated score to the file score and declares the highest
; INPUT: None
; OUTPUT: real number of file in "ScoreFileRealNum" and the highest score in file
; Register Usage: None
;================================================
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
	
	mov [ScoreFileRealNum], ax
	
	;now we will get our score
	call CalcScore
	
	;now we will put the highest score
	call SetHighScore

	popa
	ret
endp ChangeScoreHighest

;================================================
; Description -  compares player score with file score, if higher it puts player score in file and his name, if less - does nothing
; INPUT: None
; OUTPUT: highest score and the name of the holder saved in file "score.txt"
; Register Usage: None
;================================================
proc SetHighScore
	pusha

	mov ax, [PlayerScoreRealNum] ; our score
	
	cmp ax, [ScoreFileRealNum] ; the best score
	
	jbe @@end ; if our score is equal or below the highest score
	
	mov [bool_won], 1 ; if not it means we "won" the best time
	
	mov [ScoreFileRealNum], ax ; move our score to the best score
	
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
	
	;put the pointer to the start of the file because we moved it while reading from it
	mov ah, 42h
	xor al, al
	xor cx, cx
	xor dx, dx
	mov bx, [FileHandleScores]
	int 21h
	
	;now we will write those to the file
	;writing the score
	mov ah, 40h
	mov dx, offset ScoreInFile ; because we changed from before it now holds the best time
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

;================================================
; Description -  delays the program according to the number that was pushed in stack
;				 this delay is not by milliseconds because the game is meant to be played in 10000 cycles
; INPUT: Number of delay time in stack
; OUTPUT: System delayed by the requsted time
; Register Usage: None
;================================================
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


;================================================
; Description -  counts the seconds, every 37 cycles the a second has passed
; INPUT: None
; OUTPUT: number of seconds of time this function was used
; Register Usage: None
;================================================
proc CountSeconds
	
	inc [counterSeconds] ; count every frame
	cmp [counterSeconds], 37 ; 37 frames equals to one second
	jne @@cont
	inc [seconds]
	mov [counterSeconds], 0
@@cont:

	ret
endp CountSeconds

;================================================
; Description -  sets the mouse for start of the game, sets the mouse limits (min and max y and x), and changes the cursor to look like a cube
; INPUT: None
; OUTPUT: new mouse limits and new mouse cursor
; Register Usage: None
;================================================
proc SetMouse
	pusha

	mov ax, 7 ; set limits of mouse - X
	mov cx, 25 ; min
	mov dx, 294 ; max
	shl cx, 1
	shl dx, 1
	int 33h
	
	mov ax, 8 ; set limits of mouse - Y
	mov cx, 31 ; min
	mov dx, 171 ; max
	int 33h
	
	call ChangeCursor ; set mouse cursor

	popa
	ret
endp SetMouse

;================================================
; Description -  masks the mouse cursor with "MouseMask" var in DS - using int 33h, 9
; INPUT: None
; OUTPUT: new mouse cursor
; Register Usage: None
;================================================
proc ChangeCursor
    push bx cx ax dx
	
	push ds
	pop es ; because it transfers to ES:DX
	
	mov ax, 9 ; int 33h, 9 can change the mouse cursor
	
	; we will put our actual cursor in the middle of the cube
    mov bx, 8 ; horizontal hot spot
    mov cx, 8 ; vertical hot spot
    mov dx, offset MouseMask
    int 33h
	
    pop dx ax cx bx
    ret
endp ChangeCursor

;================================================
; Description -  for starting the game, it checks which of the three buttons was pressed by the mouse
; INPUT: None
; OUTPUT: new screen according to the player press
; Register Usage: None
;================================================
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
	cmp si, 1 ; if si is one it means the player chose the back arrow
	je @@main_screen
	jmp @@end ; if not it means he chose entered his name
	
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

;================================================
; Description -  shows a guide on how to play the game, and checks if the player wants to go back
; INPUT: None
; OUTPUT: Guiding BMP picture
; Register Usage: None
;================================================
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

;================================================
; Description -  shows a settings screen, and checks which of the settings the player picked - the colors of the walls and the speed of the game
; INPUT: None
; OUTPUT: changes in the settings of the game according to the player
; Register Usage: None
;================================================
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
	jb @@check_random_color
	
	cmp cx, 275
	ja @@check_click
	
	cmp dx, 60
	jb @@check_click ; if the y is below then it cant be anything
	
	cmp dx, 80
	ja @@check_inner_color
	
	;if it got here one of the outer colors were pressed
	;we will check what color was pressed
	;hide mouse
	add dx, 3
    mov ah, 0dh ; check color
    mov bh, 0
    int 10h
	sub dx, 3
	
	cmp al, 0beh ; if it the green color between blocks
	je @@check_click
	
	;if it got here it means one of the colors was pressed so then we will just pass it to the out color
	mov [OutSideColor], al
	jmp @@check_click
	
@@check_random_color: ; to check if the player pressed the random color settings
	cmp cx, 18
	jb @@check_click
	
	cmp cx, 35
	ja @@check_click
	
	cmp dx, 65
	jb @@check_click
	
	cmp dx, 75
	ja @@check_random_inner
	
	call RandomColor
	mov [OutSideColor], al
	jmp @@check_click
	
@@check_random_inner:
	cmp dx, 105
	jb @@check_click
	
	cmp dx, 115
	ja @@check_click
	
	call RandomColor
	mov [InsideColor], al
	jmp @@check_click
	
@@check_inner_color:
	
	cmp dx, 120
	ja @@check_speed_game
	
	add dx, 3
    mov ah, 0dh ; check color
    mov bh, 0
    int 10h
	sub dx, 3
	
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
	
	mov [delay], 85 ; slow speed
	mov [SaveDelay], 85 ; save it
	jmp @@check_click
	
@@normal:

	;normal speed
	
	cmp cx, 205
	ja @@fast
	
	mov [delay], 80
	mov [SaveDelay], 80 ; save it
	jmp @@check_click
	
@@fast:
	cmp cx, 288
	ja @@check_click
	
	mov [delay], 75
	mov [SaveDelay], 75 ; save it
	jmp @@check_click
@@end:
	popa
	ret
endp Settings_Screen

;================================================
; Description -  will generate a random number between 0-256 (number of colors) and put in al this number
; INPUT: None
; OUTPUT: The number of the color in register AL
; Register Usage: AL
;================================================
proc RandomColor
	push bx
	
	mov bl, 0 ; lowest number of color
	mov bh, 0ffh ; heighest number of color
	
	call RandomByCs
	
	pop bx
	ret
endp RandomColor

;================================================
; Description -  before starting the game, it will require to enter the name of the player, so here we check if the player pressed the name enter area
; INPUT: None
; OUTPUT: Hides mouse after pressing the name area
; Register Usage: None
;================================================
proc Name_Screen
	push ax dx bx cx
	
	mov ax, 2 ; hide mouse
	int 33h
	
	mov dx, offset FileName_EnterName
	DRAW_FULL_BMP
	
	mov ax, 1 ; show mouse
	int 33h
	
	xor si, si
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
	mov si, 1
@@end:
	pop cx bx dx ax
	ret
endp Name_Screen

;================================================
; Description -  shows the end screen and writes the score and name to the screen and checks if the player wants to play again
; INPUT: None
; OUTPUT: Scores and name on screen 
; Register Usage: None
;================================================
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

;================================================
; Description -  Resets all the vars that the game need to function - this will be only used if the player chose to play again
; INPUT: None
; OUTPUT: All DS vars that the game uses reseted
; Register Usage: None
;================================================
proc Reset
	push ax si
	
	mov [NamePlayer], 14
	xor si, si
	inc si
@@reset:
	mov [NamePlayer + si], ?
	inc si
	cmp si, 16
	jb @@reset
	mov [NamePlayer + si], '$'

	mov [bool_won], 0
	
	;Bonus points
	mov [BonusPointsCounter], ?
	
	;seconds alive
	mov [counterSeconds], ?
	mov [seconds], ?
	
	;score
	mov [PlayerScoreRealNum], ?
	mov [PlayerScoreTXT],  'x'
	mov [PlayerScoreTXT + 1], 'x'
	mov [PlayerScoreTXT + 2], 'x'
	mov [PlayerScoreTXT + 3], 'x'
	mov [PlayerScoreTXT + 4], '$'
	
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
	
	xor si, si
@@reset_pos: ; reset the position of the blocks and triangles
	mov [Xpos_Blocks + si], Starting_Pos
	mov [Xpos_Triangle + si], Starting_Pos
	inc si
	cmp si, 5
	jb @@reset_pos
	
	;Tower
	xor si, si
@@reset_Tower: ; reset the position of the towers
	mov [Xpos_Tower + si], Starting_Pos
	inc si
	cmp si, 3
	jb @@reset_Tower
	
	;Bonus Points
	mov [Xpos_Points], Starting_Pos
	mov [Ypos_Points], Starting_Pos
	
	mov ax, [SaveDelay]
	mov [delay], ax
	
	;hide mouse
	mov ax, 2
	int 33h
	
	pop si ax
	ret
endp Reset

;================================================
; Description -  Writes all scores and best holder to the right place on screen
; INPUT: None
; OUTPUT: scores and name on screen
; Register Usage: None
;================================================
proc WriteScore
;our score
	;we will change the place of the writing
	mov ah, 2
	xor bh, bh
	mov dl, 25
	mov dh, 7
	int 10h
	
	call ChangeScoreToTXT
	
	mov dx, offset PlayerScoreTXT ; now we print
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
	
	mov dl, '"' ; to make it look like a name we will print " "
	mov ah, 2
	int 21h
	
	cmp [bool_won], 1 ; we will see if the player has the best time
	je @@write_player_name ; if so write the players' name to the screen
	;if not write the file name to the screen
	mov dx, offset FileScoreHolder
	
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
	mov dx, offset FileScoreHolder
	int 21h
	jmp @@end
	
@@write_player_name:
	
	xor bx, bx
	mov bl, [NamePlayer + 1] ; get the length of the name
	add bl, 2 ; add two because of the starting digits when using int 21h, 0ah 
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

;================================================
; Description -  Takes the player score and turn it into readable number and put it in var
; INPUT: None
; OUTPUT: Four bytes in "PlayerScoreTXT" in DS
; Register Usage: None
;================================================
proc ChangeScoreToTXT
	pusha
	
	mov ax, [PlayerScoreRealNum]

	mov si, offset PlayerScoreTXT + 3 ;go to the end of var
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
	
	call clearkeyboardbuffer
	
	mov ax, 2
	int 33h
	
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
; Description -  clear keyboard buffer - because using ports we need the keyboard buffer so it wont print the keys in the name area or after the game has ended
; INPUT: None
; OUTPUT: keyboard buffer in memory cleared
; Register Usage: None
;================================================
proc clearkeyboardbuffer
	push es
	
	push 0
	pop es
	mov [word es:041ah], 0 ; pointer on the start of the buffer
	mov	[word es:041ch], 0 ; pointer on the tail of the buffer
	
	pop	es
	ret
endp clearkeyboardbuffer
;================================================
; Description -  draws cube using bmp and Xpos and Ypos variables
; INPUT: None
; OUTPUT: bmp drawn on screen
; Register Usage: None
;================================================

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
	mov [matrix], bx
	call putCubeInScreen
	;print
	
	popa
	ret
endp DrawCube

;================================================
; Description -  picks the right frame/matrix relying on the cube situation
; INPUT: None
; OUTPUT: offset of the var that holds our matrix frame in bx
; Register Usage: None
;================================================
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
	
	mov [timeInAir], 0 ; start the timer from start
	
@@end:
	ret
endp Pick_matrix_by_height

;================================================
; Description -  draws the saved background on the cube
; INPUT: None
; OUTPUT: background drawn and by that "erasing" the cube
; Register Usage: None
;================================================
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
	
	call putCubeInScreen
	
	popa
	ret
endp Erase_Cube

;================================================
; Description -  gets the sizes of the cube and calls another function that transfers the data on screen to data in DS
; INPUT: None
; OUTPUT: Saved background of cube in DS
; Register Usage: None
;================================================
proc Copy_Background_Cube
	pusha
	
	;the other parameters are calculated before
	mov cx, [CurrentSize]
	mov dx, [CurrentSize]
	
	mov bx, offset matrix_erase_cube ; the data will be stored here
	mov [matrix], bx
	
	call putCubeInData
	
	popa
	ret
endp Copy_Background_Cube

;================================================
; Description -  checks if the block is on screen, if yes draws the cube and save their background - goes one by one and checks their X position
; INPUT: None
; OUTPUT: blocks drawn on screen and their saved background
; Register Usage: None
;================================================
proc DrawBlock
	pusha
	
	xor si, si ; pointer to memory on X of the blocks
	xor bp, bp ; pointer to memory of the background of each block
	mov cx, Max_Objects ; max five objects
@@drawAllBlocks:
	push cx ; save cx
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
	add bp, 324 ; jump to the next block
	add si, 2 ; because we are dealing with words
	pop cx
	loop @@drawAllBlocks
	
	popa
	ret
endp DrawBlock

;================================================
; Description -  prints the saved background on the position
; INPUT: None
; OUTPUT: "erases" the cube from screen
; Register Usage: None
;================================================
proc Erase_Block
	pusha

	xor si, si ; pointer to memory on X of the blocks
	xor bp, bp ; pointer to memory of the background of each block
	mov cx, Max_Objects ; max five objects
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
	add bp, 324 ; jump to the next block
	add si, 2 ; dealing with words
	pop cx
	loop @@drawAllBlocks

	popa
	ret
endp Erase_Block

;================================================
; Description -  gets the X and Y from stack and prints a block, this is used for printing towers when needing to print multiple blocks one by one
; INPUT:
;[bp + 4] = x
;[bp + 6] = y
; OUTPUT: blocks drawn on X and Y position on screen
; Register Usage: None
;================================================
proc DrawBlock_Stack
	push bp
	mov bp, sp
	push ax bx cx dx si di
	
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
	
	pop di si dx cx bx ax bp
	ret 4
endp DrawBlock_Stack

;================================================
; Description -  Checks each triangle and sees if they are on screen, if yes draw and save the background
; INPUT: None
; OUTPUT: saved background and print triangle on screen
; Register Usage: None
;================================================
proc Draw_Triangle
	pusha
	
	xor si, si ; pointer to memory on X of the triangles
	xor bp, bp ; pointer to memory of the background of each triangle
	mov cx, Max_Objects ; max five objects
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
	add bx, bp ; add bp to get the right triangle background
	mov [matrix], bx
	
	call putMatrixInData ; we will copy the background before drawing
	
	mov bx, offset matrix_triangle
	mov [matrix], bx

	call putCubeInScreen
	
@@end_loop:
	add bp, 162 ; jump to the next triangles
	add si, 2 ; dealing with words
	pop cx
	loop @@drawTriangles
	
	popa
	ret
endp Draw_Triangle

;================================================
; Description -  checks all the triangles and sees if they are on screen, if so print the saved background
; INPUT: None
; OUTPUT: offset of the var that holds our matrix frame in bx
; Register Usage: None
;================================================
proc Erase_Triangle
	pusha
	
	xor si, si ; pointer to memory on X of the triangles
	xor bp, bp ; pointer to memory of the background of each triangle
	mov cx, Max_Objects ; max five objects
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
	add bp, 162 ; jump to the next triangle
	add si, 2 ; dealing with words
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
	
	xor si, si ; pointer to memory on X of the towers
	xor bp, bp ; pointer to memory of the background of each towers
	mov cx, Max_Objects_Towers ; max three objects
@@drawAllTowers:
	push cx ; save cx
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
	add si, 2 ; dealing with words
	add bp, 1620 ; jump to the next tower
	pop cx
	loop @@drawAllTowers
	
	popa
	ret
endp Draw_Tower

;================================================
; Description - copies the background of the tower in one big var, takes the X and Y and copies the bacgkround
; INPUT: None
; OUTPUT: Var in DS which holds the bacgkround of the whole tower
; Register Usage: None
;================================================
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

;================================================
; Description - checks if the X of each tower is on screen, if so prints its saved background
; INPUT: None
; OUTPUT: erases the tower from the screen
; Register Usage: None
;================================================
proc Erase_Tower
	pusha
	
	xor si, si ; pointer to memory on X of the towers
	xor bp, bp ; pointer to memory of the background of each towers
	mov cx, Max_Objects_Towers ; max three objects
@@eraseAllTowers:
	push cx ; save cx
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
	add si, 2 ; dealing with words
	add bp, 1620 ; jump to the next tower
	pop cx
	loop @@eraseAllTowers
	
	popa
	ret
endp Erase_Tower

;================================================
; Description - draw the point on the X and Y on screen
; INPUT: None
; OUTPUT: draw the point matrix on screen
; Register Usage: None
;================================================
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
	
	call putCubeInScreen ; drawing
	
@@end:
	popa
	ret
endp DrawPoint

;================================================
; Description - copies the bacgkround of the point
; INPUT: None
; OUTPUT: saved bacgkround as a matrix in DS
; Register Usage: None
;================================================
proc Copy_Background_Points

	mov bx, offset matrix_erase_point
	mov [matrix], bx
	call putMatrixInData

	ret
endp Copy_Background_Points

;================================================
; Description - prints the saved background on point
; INPUT: None
; OUTPUT: "erases" the point from screen
; Register Usage: None
;================================================
proc Erase_point
	pusha
	
	cmp [Xpos_Points], 310 ; if not in screen
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
	call putCubeInScreen


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
	
	mov ax, 3
	int 33h
	
	cmp bx, 1 ; check if left mouse clicked
	je @@jump
	
	in al, 60h ; read the key port to AL
	
	cmp al, 1h ; ESC
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
	
	push 0a000h
	pop es
	
	mov bx, 320
	mov ax, [Ypos]
	add ax, [CurrentSize]
	mul bx
	mov di, ax
	add di, Xpos_Cube
	sub di, 2
	mov al, 0ffh ; check if white
	scasb
	je @@floor
	
	mov al, 0 ; check if black
	scasb
	je @@floor
	
	add di, [CurrentSize]
	add di, 4
	mov al, 0ffh ; check if white
	scasb
	je @@floor
	
	mov al, 0 ; check if black
	scasb
	je @@floor
	
	sub di, 15
	mov al, 0ffh ; check if white
	scasb
	je @@floor
	
	mov al, 0 ; check if black
	scasb
	je @@floor
	;did not see floor
@@no_floor:
	
	xor al, al
	jmp @@end

@@floor:
	call Check_Triangle ; check if it saw a triangle
	cmp al, 1
	je @@exit_game
	mov al, 1
	jmp @@end
	
@@exit_game:
	xor al, al
	mov [IsExit], 1

@@end:
	ret
endp Check_floor_Under

;================================================
; Description - calls multiple functions to check if we hit a bonus point or died
; INPUT: None
; OUTPUT: if the player has hit a block or triangle the game will end, if it hit a bonus point the counter will go up
; Register Usage: None
;================================================
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

;================================================
; Description - goes through multiple x and y points on that close to the cube and checks if this is in the point range
; INPUT: None
; OUTPUT: if we hit the bonus point the counter will go up
; Register Usage: None
;================================================
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
	add cx, 6 ; a little bit forward of cube
	mov dx, [Ypos]
	add dx, 3
	
	;right up point of cube
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	;down right side of cube
	add dx, 9
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	add dx, 8
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	cmp [Is_Falling], 1
	je @@skip_under

	add dx, 8
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub cx, 6 ; now we go backwards but still under the cube
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub cx, 10
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	sub cx, 12
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
@@skip_under:
	
	mov dx, [CurrentSize]
	sub dx, 3
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	add cx, 10
	call CheckIsInPoint
	cmp bp, 1
	je @@catch_point
	
	jmp @@end

@@catch_point:
	inc [BonusPointsCounter] ; sign that we hit a bonus point
	call Erase_point
	call PrintPoints
	mov [Xpos_Points], Starting_Pos

@@end:
	popa
	ret
endp Check_Point

;================================================
; Description - moves to AX the total bonus points catched and prints it
; INPUT: None
; OUTPUT: number of points printed to screen
; Register Usage: None
;================================================
proc PrintPoints
	push ax bx
	
	mov ah, 2 ; move the pointer to the same place each time
	xor bh, bh
	mov dl, 1
	mov dh, 1
	int 10h

	xor ax, ax
	mov al, [BonusPointsCounter]
	call printAxDec ; print the total points

	pop bx ax
	ret
endp PrintPoints

;================================================
; Description - checks if the given x and y is in the range you give it
; INPUT:
;		we get the cube X and Y from the registers cx and dx
;		ax -left side of objects, si - right side of the objects, bx - upper side, di - down side
;
; OUTPUT: retun bp 1 if we hit bonus point if not bp is zero
; Register Usage: None
;================================================
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

;================================================
; Description - checks if right infront of us there is black or white, if so it means we died
; INPUT: None
; OUTPUT: if we died it will simble with a bool that we died
; Register Usage: None
;================================================
proc Check_Blocks
	;we will use the 25 numbers because the maximun size of the cube is 25*25 while rotation
	;we will check three pixels to the right up and down
	push 0a000h
	pop es
	
	mov cx, Xpos_Cube
	mov dx, [Ypos]
	add cx, [CurrentSize]
	add cx, 3
	
	mov ax, dx
	mov bx, 320
	mul bx
	mov di, ax
	add di, cx ; right to the cube up
	
	mov al, 0 ; check black
	scasb ; cmp [es:di], al
	je @@end_game
	
	;now we go down
	add di, 5*320
	scasb
	je @@end_game

	add di, 320*4
	scasb
	je @@end_game
	
	add di, 320*8
	scasb ; check black
	je @@end_game
	
	xor al, al
	jmp @@end
	
@@end_game:
	mov al, 1
@@end:
	ret
endp Check_Blocks

;================================================
; Description - will check if one of a the walls is in the triangle range of x and y - because the cube moves fast we will make the range of the triangle a little bit bigger
; INPUT: None
; OUTPUT: if we hit a triange al will be one
; Register Usage: None
;================================================
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
	add bp, 10 ; end of triangle in y
	
	;left down
	mov cx, Xpos_Cube
	mov dx, [Ypos]
	add dx, [CurrentSize]
	add dx, 2
	
	sub di, 2
	cmp cx, ax
	jbe @@check2 ; if below it means our left side of the cube is not on the triangle - to his left side
	
	cmp cx, di
	jae @@check2 ; if above it means our left side of the cube is not on the triangle - to ihs right side
	
	;if we got here it means our x is in the triangle x area
	;now we need to check the y
	
	cmp dx, bx
	jbe @@check2 ; if below it means we are above the triangle
	
	cmp dx, bp
	jae @@check2
	
	;if it got here it means we are on the triangle
	jmp @@end_game
	
	;right side
@@check2:
	add cx, [CurrentSize]
	;we need to check couple of x before the triangle and infront
	add di, 4
	sub ax, 3
	
	;now we will just copy the above
	cmp cx, ax
	jbe @@check3 ;if the cube is left to the triangle
	
	cmp cx, di
	jae @@check3 ; if the cube is right to the triangle
	
	cmp dx, bx
	jbe @@check3 ; if the cube is above the triangle
	
	cmp dx, bp
	jae @@check3
	
	;if it got here it means we are in the triangle
	jmp @@end_game
	
@@check3:
	sub cx, 16
	
	;now we will just copy the above
	cmp cx, ax
	jbe @@end_loop ;if the cube is left to the triangle
	
	cmp cx, di
	jae @@end_loop ; if the cube is right to the triangle
	
	cmp dx, bx
	jbe @@end_loop ; if the cube is above the triangle
	
	cmp dx, bp
	jae @@end_loop
	
	;if it got here it means we are in the triangle
	jmp @@end_game
	
	
@@end_loop:
	add si, 2
	cmp si, 8 ; five objects
	jbe @@checkEachTriangle
	
	

@@end_check:
	xor al, al
	jmp @@end
	
@@end_game:
	mov al, 1
	mov [IsExit], 1
	
@@end:
	ret
endp Check_Triangle

;================================================
; Description - in case the jump has ended and we are not on the floor, this will check if we have floor under us while falling from a block - when not jumpimg
; INPUT: None
; OUTPUT: if we are in the air it will keep on descending, of it detects floor it will stop falling
; Register Usage: None
;================================================
proc Check_Fall
	pusha
	;we need to go down - no floor
	mov [can_jump], 0
	add [Ypos], 6
	
	call Check_floor_Under
	cmp al, 1
	je @@hit_ground
	cmp [IsExit], 1
	je @@end
	
	jmp @@end
	
@@hit_ground:
	mov dx, [Ypos]
	cmp dx, 136
	ja @@ground
	
	cmp dx, 118
	ja @@block
	
	cmp dx, 100
	ja @@two_blocks
	
	cmp dx, 82
	ja @@three_blocks

@@ground:
	mov [Ypos], 143
	jmp @@cont
@@block:
	mov [Ypos], 125
	jmp @@cont
@@two_blocks:
	mov [Ypos], 107
	jmp @@cont
@@three_blocks:
	mov [Ypos], 89
@@cont:
	mov [can_jump], 1 ; we can jump again - in case we are falling we will cancel the jump movement so when when stop falling we cant jump
	mov [Is_Falling], 0
	mov [Is_Going_down], 0
	
@@end:
	popa
	ret
endp Check_Fall

;================================================
; Description - will check for the color black above the cube - only be used when going up
; INPUT: None
; OUTPUT: if there is black above us while jumping it will simble that the player has died
; Register Usage: None
;================================================
proc Check_Above
	push 0a000h
	pop es
	
	;getting di to be the location on screen
	mov bx, 320
	mov ax, [Ypos]
	mul bx
	mov di, ax
	add di, Xpos_Cube
	
	sub di, 320 * 3 ; three rows up
	xor al, al ; check black
	scasb ; cmp [es:di], al
	je @@exit_game
	
	
	mov bx, [CurrentSize]
	dec di
	shr bx, 1 ; go to the middle
	add di, bx
	scasb
	je @@exit_game
	
	add di, bx
	scasb
	je @@exit_game
	
	shr bx, 1
	add di, 320 * 4
	add di, bx
	scasb
	je @@exit_game
	
	jmp @@end
@@exit_game:
	mov [IsExit], 1
	
@@end:
	ret
endp Check_Above

;================================================
; Description -  firstly, it will see if it already calculated the maximum height from the point of jumping
;				it will also calculate the middle height, until the middle height it will go at a certain speed, if above the middle height it will slow the speed of ascending
; INPUT: None
; OUTPUT: Cubes' Ypos goes down
; Register Usage: None
;================================================
proc Cube_Ascend
	pusha
	
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
	call Check_Above
	cmp [IsExit], 1
	je @@end
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
; Description -  goes down when there is not white under the cube - only be used after the ascend part has finished
; INPUT: None
; OUTPUT: Cubes' Ypos goes up
; Register Usage: None
;================================================
proc Descending
	pusha
	
	add [Ypos], 9
	
	call Check_floor_Under
	cmp al, 1
	je @@end_jump
	
	jmp @@end

@@end_jump:
	mov [can_jump], 1 ; to symble that we can jump again
	mov [Is_Going_down], 0 ; finished going down
	
@@end:
	popa
	ret
endp Descending

;================================================
; Description - works with the bool "Is_Falling", it will check in case we are not jumping where the cube is - on a block or in the air
; INPUT: None
; OUTPUT: if we are not jumping and in the air it will symbolise that we are currently falling
; Register Usage: None
;================================================
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
	
	mov [can_jump], 1 ; if we have floor under we will sign that we can jump again
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

;================================================
; Description - checks each boolean and works with it, it will do one of the three moves - ascend, descend, fall
;				it will erase the cube, move it, then draw it, after it will check if we died and if we are falling
; INPUT: None
; OUTPUT: changes the Ypos of the cube according to the booleans
; Register Usage: None
;================================================
proc Cube_Move
	pusha
	
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

	cmp [IsExit], 1
	je @@end
	call Check_Where_Cube
	call Check_Hit ; if we got into a block or triangle and died
	
	
@@end:
	popa
	ret
endp Cube_Move

;================================================
; Description - Generating a random (the number of levels), then proceeds to play the level, when a level has ended it will generate again a random number
; INPUT: None
; OUTPUT: runs the current level
; Register Usage: None
;================================================
proc PickLevel
	pusha
	
	;if even the last level has ended
	cmp [Objects_Placed], 1 ; if a level is in screen then dont create another level
	je @@put_level
	
	mov bl, 1 ; min level
	mov bh, 14 ; max numbers of levels
	call RandomByCs
	;now al has the number of the level
	mov [CurentLevel], al ; save the current level
	
@@put_level:
	mov al, [CurentLevel] ; get the current level

	cmp al, 1 ; check which level are we on
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
	
	cmp al, 8
	je @@level_eight
	
	cmp al, 9
	je @@level_nine
	
	cmp al, 10
	je @@level_ten
	
	cmp al, 11
	je @@level_eleven
	
	cmp al, 12
	je @@level_twelve
	
	cmp al, 13
	je @@level_thirteen
	
	cmp al, 14
	je @@level_fourteen
	
@@level_one: ; play the level that we are currently on
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
	
@@level_eight:
	call Level_Eight
	jmp @@end

@@level_nine:
	call Level_Nine
	jmp @@end
	
@@level_ten:
	call Level_Ten
	jmp @@end
	
@@level_eleven:
	call Level_Eleven
	jmp @@end
	
@@level_twelve:
	call Level_Twelve
	jmp @@end
	
@@level_thirteen:
	call Level_Thirteen
	jmp @@end
	
@@level_fourteen:
	call Level_Fourteen
	jmp @@end
	
@@end:
	popa
	ret
endp PickLevel

;=========================================================================================================================================================================================================
;          																		       -- Level Structure --
;
; - Check if the objects have already been placed
; *If yes continue
; *If not place all the objects in the right X and Y, after that draw them (in order to erase them after)
;
; - Erase all objects
; - Sub from every objects on this level the MovingObjectsXSpeed (5) from its Xpos
; - Compare if the last object on this level has went out of the map
; *If yes jump to end level and declare that objects are not currently on screen (its signs that we can generate another random level)
; *If not draw all objects and continue
;
; Note: Some level may require more of the cpu (when using many objects) so when the level is generated we will lower the delay and when the level has ended we will return the delay
;
; Rare cases: When the last object is a bonus point we cant just check if the bonus point X is out of screen because when a player eats the bonus point the X of it will go out of the screen
;             This will cause problems when the player has eaten a bonus point and there are objects on screen because the game will think the level has ended
;             To solve this we will check if the bonus point and the objects that can be visible with it while the player has eaten it are out of screen (if not out of screen continue playing the level)
;=========================================================================================================================================================================================================

;We will declare the height of objects for the levels
;We will set consts to the ypos of every object
;The only thing thats gonna be manualy controlled is the xpos

;Blocks - block size is 18 * 18 so we will take the height and sub 18 to make it seem like it is on the floor
BlocksFloorHeight = 161 - 18
BlocksOneAboveGroundHeight = (161 - 18) - 18
BlocksTwoAboveGroundHeight = (161 - 18) - 18 * 2
BlocksThreeAboveGroundHeight = (161 - 18) - 18 * 3
BlocksFourAboveGroundHeight = (161 - 18) - 18 * 4

;Triangles - triangle size is 9 * 18 so we will take the height and sub 9 to make it seem like it is on the floor
TrianglesFloorHeight = BlocksFloorHeight + 9
TrianglesOneAboveGroundHeight = BlocksOneAboveGroundHeight + 9
TrianglesTwoAboveGroundHeight = BlocksTwoAboveGroundHeight + 9
TrianglesThreeAboveGroundHeight = BlocksThreeAboveGroundHeight + 9
TrianglesFourAboveGroundHeight = BlocksFourAboveGroundHeight + 9

;Towers dont have height so we don't need to make consts for them
;Points also don't need because it is one objects and can be in many places

;
;
;		
;       █
; █     █     ▲
proc Level_One
	cmp [Objects_Placed], 1 ; check if we already placed the objects
	je @@move_objects
	
	mov [Objects_Placed], 1 ; declare that we are putting the objects in place
	mov [Height_Tower], 2 ; height of three blocks of tower
	mov [Xpos_Blocks], 400 ; first block
	mov [Ypos_Blocks], BlocksFloorHeight
	
	mov [Xpos_Triangle], 660 ; last triangle
	mov [Ypos_Triangle], TrianglesFloorHeight
	
	mov [Xpos_Tower], 520 ; the tower
	
	call Draw_All ; we need to draw the objects first to erase them after
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	
	call MoveObjects
	
	cmp [Xpos_Triangle], OutOfScreenX
	ja @@end_level

	call Draw_All
	jmp @@end
	
@@end_level:
	mov [Objects_Placed], 0 ; declare that the level has ended
	
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
	mov [Ypos_Triangle], TrianglesFloorHeight
	mov [Xpos_Tower], 490 ; the tower
	mov [Height_Tower], 2 ; height of 3 blocks
	mov [Xpos_Blocks], 580 ; floating block
	mov [Ypos_Blocks], BlocksOneAboveGroundHeight
	mov [Xpos_Points], 586 ; bonus point above block
	mov [Ypos_Points], 110
	mov [Xpos_Triangle + 2], 710 ; last triangle
	mov [Ypos_Triangle + 2], TrianglesFloorHeight
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed

	call MoveObjects
	cmp [Xpos_Triangle + 2], OutOfScreenX
	ja @@end_level
	

	
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
	mov [Ypos_Blocks], BlocksFloorHeight
	mov [Xpos_Triangle], 320 ; first triangle above block
	mov [Ypos_Triangle], TrianglesOneAboveGroundHeight
	mov [Xpos_Triangle + 2], 440 ; second triangle before third triangle
	mov [Ypos_Triangle + 2], TrianglesFloorHeight
	mov [Xpos_Triangle + 4], 460 ; third triangle
	mov [Ypos_Triangle + 4], TrianglesFloorHeight
	mov [Xpos_Tower], 590
	mov [Height_Tower], 2 ; tower of 2 blocks
	mov [Xpos_Points], 656 ; bonus point
	mov [Ypos_Points], 92
	
	call Draw_All
	
@@move_objects:
	
	call Erase_All
	
	mov ax, 6 ; because the triangle on the block is very hard to pass we will speed this level
	
	call MoveObjects
	cmp [Xpos_Points], OutOfScreenX
	ja @@end_level
	
@@draw:
	call Draw_All
	jmp @@end
	
@@end_level:
	cmp [Xpos_Tower], OutOfScreenX ; if we ate the bonus point before the level has ended ot will finish the level - so we will check if the tower has exited the screen
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
	mov [Ypos_Blocks], BlocksFloorHeight
	mov [Xpos_Tower], 395 ; first tower
	mov [Height_Tower], 3
	mov [Xpos_Blocks + 2], 455 ; second floating block
	mov [Ypos_Blocks + 2], BlocksOneAboveGroundHeight
	mov [Xpos_Triangle], 455 ; floating triangle
	mov [Ypos_Triangle], TrianglesTwoAboveGroundHeight
	mov [Xpos_Tower + 2], 505 ; second tower
	mov [Height_Tower + 2], 2 ; height of two blocks
	mov [Xpos_Triangle + 2], 545 ; second triangle
	mov [Ypos_Triangle + 2], TrianglesFloorHeight
	
	sub [delay], 7 ; this level has lots of objects, so we have to lower the delay for it to be at the normal speed
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Triangle + 2], OutOfScreenX
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
	mov [Ypos_Triangle], TrianglesFloorHeight
	mov [Xpos_Blocks], 350 ; first block
	mov [Ypos_Blocks], BlocksFloorHeight
	mov [Xpos_Blocks + 2], 420 ; second floating block
	mov [Ypos_Blocks + 2], BlocksOneAboveGroundHeight
	mov [Xpos_Triangle + 2], 420;second floating triangle
	mov [Ypos_Triangle + 2], TrianglesTwoAboveGroundHeight
	mov [Xpos_Tower], 515 ; tower
	mov [Height_Tower], 2
	mov [Xpos_Triangle + 4], 590
	mov [Ypos_Triangle + 4], TrianglesFloorHeight
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Triangle + 4], OutOfScreenX
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
	mov [Ypos_Blocks], BlocksFloorHeight
	mov [Xpos_Blocks + 2], 474 ; second block
	mov [Ypos_Blocks + 2], BlocksFloorHeight
	mov [Xpos_Triangle], 435 ; first triangle
	mov [Ypos_Triangle], TrianglesFloorHeight
	mov [Xpos_Tower + 2], 580 ; second tower
	mov [Height_Tower + 2], 2
	
	sub [delay], 4
	
	call Draw_All
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Tower + 2], OutOfScreenX
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
	mov [Ypos_Triangle], TrianglesFloorHeight
	mov [Xpos_Triangle + 2], 400 ; second triangle
	mov [Ypos_Triangle + 2], TrianglesFloorHeight
	mov [Xpos_Blocks], 455 ; first block
	mov [Ypos_Blocks], BlocksFloorHeight
	mov [Xpos_Tower + 2], 560
	mov [Height_Tower + 2], 3
	
	call Draw_All
	
	sub [delay], 5
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Tower + 2], OutOfScreenX
	ja @@end_level
	
	
	call Draw_All
	jmp @@end
@@end_level:
	mov [Objects_Placed], 0
	add [delay], 5
@@end:
	ret
endp Level_Seven

;
;
;
;     █       █
;     █   •   █
proc Level_Eight
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	
	mov [Xpos_Tower], 320 ; first tower
	mov [Height_Tower], 2
	mov [Xpos_Points], 380 ; first bonus point
	mov [Ypos_Points], 145
	mov [Xpos_Tower + 2], 440 ; second tower
	mov [Height_Tower + 2], 2
	
	call Draw_All
	
	sub [delay], 5
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Tower + 2], OutOfScreenX
	ja @@end_level
	
	
	call Draw_All
	jmp @@end
@@end_level:
	mov [Objects_Placed], 0
	add [delay], 5
@@end:
	ret
endp Level_Eight

;
;
;        █    ▲
;   █         █ 
;             █
proc Level_Nine
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	
	mov [Xpos_Blocks], 330 ; first block
	mov [Ypos_Blocks], BlocksOneAboveGroundHeight
	mov [Xpos_Blocks + 2], 420 ; second block
	mov [Ypos_Blocks + 2], BlocksTwoAboveGroundHeight
	mov [Xpos_Tower], 500 ; first tower
	mov [Height_Tower], 2
	mov [Xpos_Triangle], 500 ; first triangle on block
	mov [Ypos_Triangle], TrianglesTwoAboveGroundHeight
	
	call Draw_All
	
	sub [delay], 6
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Tower], OutOfScreenX
	ja @@end_level
	
	
	call Draw_All
	jmp @@end
@@end_level:
	mov [Objects_Placed], 0
	add [delay], 6
@@end:
	ret
endp Level_Nine

;            •
;            █
;       █
;   █
;   █            ▲
proc Level_Ten
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	
	mov [Xpos_Tower], 330 ; first tower
	mov [Height_Tower], 2
	mov [Xpos_Blocks], 410 ; first block
	mov [Ypos_Blocks], BlocksTwoAboveGroundHeight
	mov [Xpos_Blocks + 2], 495 ; second block
	mov [Ypos_Blocks + 2], BlocksThreeAboveGroundHeight
	mov [Xpos_Points], 501 ; bonus point
	mov [Ypos_Points], 74
	mov [Xpos_Triangle], 580 ; first triangle
	mov [Ypos_Triangle], TrianglesFloorHeight
	
	call Draw_All
	
	sub [delay], 8
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Triangle], OutOfScreenX
	ja @@end_level
	
	
	call Draw_All
	jmp @@end
@@end_level:
	mov [Objects_Placed], 0
	add [delay], 8
@@end:
	ret
endp Level_Ten

; Notice that in this level it is impossible to take the bonus point, if you take it you will die
;               █
;        █   •  
;        █
;    █   █
;        █      ▲
proc Level_Eleven
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	
	mov [Xpos_Blocks], 330 ; first block
	mov [Ypos_Blocks], BlocksOneAboveGroundHeight
	mov [Xpos_Tower], 400 ; first tower
	mov [Height_Tower], 4
	mov [Xpos_Points], 450 ; first bonus point
	mov [Ypos_Points], 100
	mov [Xpos_Blocks + 2], 495 ; second block
	mov [Ypos_Blocks + 2], BlocksFourAboveGroundHeight
	mov [Xpos_Triangle], 495 ; first triangle
	mov [Ypos_Triangle], TrianglesFloorHeight
	
	call Draw_All
	
	sub [delay], 8
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Triangle], OutOfScreenX
	ja @@end_level
	
	
	call Draw_All
	jmp @@end
@@end_level:
	mov [Objects_Placed], 0
	add [delay], 8
@@end:
	ret
endp Level_Eleven

;
;              •
;              █
;      █      
;   ▲  █  █

proc Level_Twelve
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	
	mov [Xpos_Triangle], 330 ; first triagnle
	mov [Ypos_Triangle], TrianglesFloorHeight
	mov [Xpos_Tower], 420 ; first tower
	mov [Height_Tower], 2
	mov [Xpos_Blocks], 470 ; first block
	mov [Ypos_Blocks], BlocksFloorHeight
	mov [Xpos_Blocks + 2], 535 ; first block
	mov [Ypos_Blocks + 2], BlocksTwoAboveGroundHeight
	mov [Xpos_Points], 541 ; first bonus point
	mov [Ypos_Points], 92
	
	call Draw_All
	
	sub [delay], 4
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Points], OutOfScreenX
	ja @@end_level

@@cont:	
	call Draw_All
	jmp @@end
@@end_level:
	cmp [Xpos_Blocks + 2], OutOfScreenX
	jb @@cont
	
	mov [Objects_Placed], 0
	add [delay], 4
@@end:
	ret
endp Level_Twelve

;
;               •
;               █
;  █       █    
;  ▲   █   █
proc Level_Thirteen
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	mov [Xpos_Triangle], 330
	mov [Ypos_Triangle], TrianglesFloorHeight ; first triangle on floor
	mov [Xpos_Blocks], 330
	mov [Ypos_Blocks], BlocksOneAboveGroundHeight ; first block floating in air above triangle
	mov [Xpos_Blocks + 2], 420
	mov [Ypos_Blocks + 2], BlocksFloorHeight ; second block on ground
	mov [Xpos_Tower], 490
	mov [Height_Tower], 2 ; first tower height of 2 blocks
	mov [Xpos_Blocks + 4], 590
	mov [Ypos_Blocks + 4], BlocksTwoAboveGroundHeight ; third block floating in air
	mov [Xpos_Points], 596
	mov [Ypos_Points], 92 ; first bonus point above block
	
	call Draw_All
	
	sub [delay], 5
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Blocks + 4], OutOfScreenX
	ja @@end_level

@@cont:	
	call Draw_All
	jmp @@end
@@end_level:
	mov [Objects_Placed], 0
	add [delay], 5
@@end:
	ret
endp Level_Thirteen

;
;
;           ▲      •
;   █     █ █ █
;   █           ▲
proc Level_Fourteen
	cmp [Objects_Placed], 1
	je @@move_objects
	
	mov [Objects_Placed], 1
	mov [Xpos_Tower], 330  ; first tower of two blocks
	mov [Height_Tower], 2
	mov [Xpos_Blocks], 410 ; first floating block
	mov [Ypos_Blocks], BlocksOneAboveGroundHeight
	mov [Xpos_Blocks + 2], 410 + 40 ; second floating block
	mov [Ypos_Blocks + 2], BlocksOneAboveGroundHeight
	mov [Xpos_Triangle], 410 + 40 ; first triangle above block
	mov [Ypos_Triangle], TrianglesTwoAboveGroundHeight
	mov [Xpos_Blocks + 4], 410 + 40 + 40 ; third floating block
	mov [Ypos_Blocks + 4], BlocksOneAboveGroundHeight
	mov [Xpos_Triangle + 2], 560 ; second triangle on ground
	mov [Ypos_Triangle + 2], TrianglesFloorHeight
	mov [Xpos_Points], 580 ; bonus point in air
	mov [Ypos_Points], 143 - 18 - 50
	
	call Draw_All
	
	sub [delay], 4
	
@@move_objects:
	call Erase_All
	
	mov ax, MovingObjectsXSpeed
	call MoveObjects
	cmp [Xpos_Points], OutOfScreenX
	ja @@end_level

@@cont:	
	call Draw_All
	jmp @@end
@@end_level:
	cmp [Xpos_Triangle + 2], OutOfScreenX ; in case we ate the bonus point but the triangle still shows on screen
	jb @@cont
	mov [Objects_Placed], 0
	add [delay], 4
@@end:
	ret
endp Level_Fourteen

;================================================
; Description - move all objects on screen to the left
; INPUT: the speed in AX
; OUTPUT: objects Xpos move left
; Register Usage: None
;================================================
proc MoveObjects
	push si cx
	
	xor si, si
	mov cx, 5 ; five blocks and triangles
@@move_blocks_triangles:
	cmp [Xpos_Blocks + si], OutOfScreenX ; check if block is alive
	ja @@cont
	
	sub [Xpos_Blocks + si], ax
@@cont:
	cmp [Xpos_Triangle + si], OutOfScreenX ; check if triangle is alive
	ja @@rep
	
	sub [Xpos_Triangle + si], ax
@@rep:
	add si, 2 ; dealing with words
	loop @@move_blocks_triangles
	
	
	xor si, si
	mov cx, 3 ; three towers
@@move_towers:
	cmp [Xpos_Tower + si], OutOfScreenX ; check if tower is alive
	ja @@rep1
	
	sub [Xpos_Tower + si], ax
@@rep1:
	add si, 2 ; dealing with words
	loop @@move_towers
	
	cmp [Xpos_Points], OutOfScreenX
	ja @@end
	
	sub [Xpos_Points], ax
	
@@end:

	pop cx si
	ret
endp MoveObjects

;================================================
; Description - draw all the objects that are currently on screen
; INPUT: None
; OUTPUT: objects drawn on screen
; Register Usage: None
;================================================
proc Draw_All
	call Draw_Tower
	call Draw_Triangle
	call DrawBlock
	call DrawPoint
	ret
endp Draw_All

;================================================
; Description - erase all the objects that are currently on screen
; INPUT: None
; OUTPUT: objects erased on screen
; Register Usage: None
;================================================
proc Erase_All
	call Erase_Tower
	call Erase_point
	call Erase_Triangle
	call Erase_Block
	ret
endp Erase_All

;================================================
; Description - the frames of the cube are stored in BMP files, after the name of the player was entered it will tranfer every frame to matrix in memory
; INPUT: None
; OUTPUT: every frame of the cube is saved in DS
; Register Usage: None
;================================================
proc Transfer_bmp_matrix
	;90 degrees
	mov [CurrentSize], 18 ; size of frame
	mov bx, offset matrix_cube ; the offset of the matrix we need the frame to be in
	mov [matrix], bx ; put it in matrix var in DS
	mov dx, offset FileName_cube ; the name offset of the file name
	call CopyBmp ; copy to DS
	
	;5 degrees
	mov [CurrentSize], 20
	mov bx, offset matrix_cube5
	mov [matrix], bx
	mov dx, offset FileName_cube5
	call CopyBmp
	
	;10 degrees
	mov [CurrentSize], 21
	mov bx, offset matrix_cube10
	mov [matrix], bx
	mov dx, offset FileName_cube10
	call CopyBmp
	
	;15 degrees
	mov [CurrentSize], 22
	mov bx, offset matrix_cube15
	mov [matrix], bx
	mov dx, offset FileName_cube15
	call CopyBmp
	
	;20 degrees
	mov [CurrentSize], 23
	mov bx, offset matrix_cube20
	mov [matrix], bx
	mov dx, offset FileName_cube20
	call CopyBmp
	
	;25 degrees
	mov [CurrentSize], 24
	mov bx, offset matrix_cube25
	mov [matrix], bx
	mov dx, offset FileName_cube25
	call CopyBmp
	
	;30 degrees
	mov [CurrentSize], 24
	mov bx, offset matrix_cube30
	mov [matrix], bx
	mov dx, offset FileName_cube30
	call CopyBmp
	
	;35 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube35
	mov [matrix], bx
	mov dx, offset FileName_cube35
	call CopyBmp
	
	;40 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube40
	mov [matrix], bx
	mov dx, offset FileName_cube40
	call CopyBmp
	
	;45 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube45
	mov [matrix], bx
	mov dx, offset FileName_cube45
	call CopyBmp
	
	;50 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube50
	mov [matrix], bx
	mov dx, offset FileName_cube50
	call CopyBmp
	
	;55 degrees
	mov [CurrentSize], 25
	mov bx, offset matrix_cube55
	mov [matrix], bx
	mov dx, offset FileName_cube55
	call CopyBmp
	
	;60 degrees
	mov [CurrentSize], 24
	mov bx, offset matrix_cube60
	mov [matrix], bx
	mov dx, offset FileName_cube60
	call CopyBmp
	
	;65 degrees
	mov [CurrentSize], 24
	mov bx, offset matrix_cube65
	mov [matrix], bx
	mov dx, offset FileName_cube65
	call CopyBmp
	
	;70 degrees
	mov [CurrentSize], 23
	mov bx, offset matrix_cube70
	mov [matrix], bx
	mov dx, offset FileName_cube70
	call CopyBmp
	
	;75 degrees
	mov [CurrentSize], 22
	mov bx, offset matrix_cube75
	mov [matrix], bx
	mov dx, offset FileName_cube75
	call CopyBmp
	
	;80 degrees
	mov [CurrentSize], 21
	mov bx, offset matrix_cube80
	mov [matrix], bx
	mov dx, offset FileName_cube80
	call CopyBmp
	
	;85 degrees
	mov [CurrentSize], 19
	mov bx, offset matrix_cube85
	mov [matrix], bx
	mov dx, offset FileName_cube85
	call CopyBmp
	
	mov [CurrentSize], 18
	ret
endp Transfer_bmp_matrix

;================================================
; Description - shows a bmp picture on screen according to the vars
; INPUT: The size of the picture and the place on screen in DS vars - "BmpRowSize", BmpRowSize", "BmpTop", "BmpLeft" and in the DX the offset of the file name
; OUTPUT: BMP picture on screen
; Register Usage: None
;================================================
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

;================================================
; Description - transfers a bmp picture to memory, by doing all the procedures but instead of putting it on screen we will put it in data
; INPUT: The offset of the matrix we want to copy to in - "matrix", the the size of the picture in "CurrentSize" and the offset of the File name in DX
; OUTPUT: BMP picture stored in DS
; Register Usage: None
;================================================
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

;================================================
; Description - closes a file with DX offset of the file
; INPUT: offset of the file name in dx
; OUTPUT: closes the file
; Register Usage: None
;================================================
proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile
 
;================================================
; Description - opens a file, if didnt manage to open (carry flag equals one) it will sign that it didnt manage to open
; INPUT: offset of the file name in dx
; OUTPUT: open the file
; Register Usage: None
;================================================
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

;================================================
; Description - read the first 54 bytes from the Bmp picture - the header
; INPUT: offset of the file name in dx
; OUTPUT: Header stored in DS
; Register Usage: None
;================================================
proc ReadBmpHeader	near					
	push cx dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx cx
	ret
endp ReadBmpHeader

;================================================
; Description - reads the bmp pallete and store it in memeory
; INPUT: offset of the file name in dx
; OUTPUT: 1024 bytes in DS - 256 * 4
; Register Usage: None
;================================================
proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx cx
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
; takes each color from the bmp pallete we copied and puts it in 3c9h port
; each color consists 0-255 of green red and black, so to store all of them in one byte we will lower the resolution (dividing by four)
proc CopyBmpPalette near
	push cx dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h ; because you can't reach to port above byte with free number, so we need to put the number of the port in dx then we can reach it
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
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null (invisble color))				
	loop CopyNextColor
	
	pop dx cx
	
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
	push cx dx
	
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
	rep movsb ; Copy line to the screen
	
	pop dx cx
	
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 

;================================================
; Description - reads line by line the content inside of the bmp picture, and store it in DS upside down
; INPUT: "matrix" - offset of var, "CurrentSize" - size of the cube in the frame, DX the offset of the bmp picture
; OUTPUT: bmp picture stored in memory
; Register Usage: None
;================================================
;this will be used for transfering the picture from bmp to matrix
proc MatrixBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; saving the lines from bottom to top.
	push cx
	
	push ds ; we will make es to ds and make di the offset of var we want to copy the picture to
	pop es
	
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
	mov di, [matrix]
	mov ax, [CurrentSize]
	mul ax
	add di, ax ; we will put di at the end of the matrix
	add di, [CurrentSize] ; now we will put the pointer one line after the matrix
	
@@NextLine:
	push cx
	
	;fix matrix becuase draw it upside down
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
	lodsb
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
	stosb
	loop @@rep_movsb
	
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret 
endp MatrixBMP 

;================================================
; Description -  draws a bmp picture on the right place on screen, if something didn't work it will sign that and won't print the picture and print an error message
; INPUT: stack - order of push - x, y, col size, row size and dx needs to be the offset of file name
; OUTPUT: picture on screen in visual mode
; Register Usage: None
;================================================
proc DrawPictureBmp
	push bp
	mov bp, sp
	push ax bx cx dx si di
	
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
	
	pop di si dx cx bx ax bp
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

;================================================
; Description - for using an objects that has even number of width (bacuse we can use rep movsw), it will put the given matrix on screen
; INPUT: "matrix" - offset of matrix, CX col size, DX row size and DI place on screen
; OUTPUT: puts the matrix bytes on screen
; Register Usage: None
;================================================
proc putMatrixInScreen
	pusha
	
	mov ax, 0A000h
	mov es, ax ; point to screen memory (graphics mode)
	cld ; clear direction flag
	
	mov si,[matrix]
	
@@NextRow:	
	push cx ; save cx
	
	mov cx, dx
	sub cx, 2 ; because of the width of the objects in this game (18), when using movsd (doubleword) we need the width to be divided by four
			  ; so we will sub cx 2 and divide it by four so it will do movsd only four times
	shr cx, 2
	rep movsd
	movsw ; this will be the remaining 2 bytes because we took 2 bytes to use movsd
	
	sub di,dx ; go down a line
	add di, 320
	
	
	pop cx
	loop @@NextRow	
	
	popa
    ret
endp putMatrixInScreen

;================================================
; Description - for using an objects that has even number of width (bacuse we can use rep movsw), it will put the given matrix in data
; INPUT: "matrix" - offset of matrix, CX col size, DX row size and DI place on screen
; OUTPUT: puts the matrix bytes in data
; Register Usage: None
;================================================
proc putMatrixInData
	pusha
	push ds ; save the used registers
	push es
	
	mov ax, 0A000h
	mov es, ax ; point to graphics memory
	cld ; clear direction flag

	mov si,[matrix]
	
	;for saving the background faster we will switch the registers for enabling rep movsw and rep movsd
	;normal movsb/movsw/movsd will work by doing [es:di] = [ds:si]
	;in asm 8086 there is not any op for this function so we will just switch the registers to be able to transfer data fast
	push es
	push ds
	
	pop es
	pop ds
	
	xchg si, di ; switch si and di
@@NextRow:	
	push cx ; save cx
	
	mov cx, dx
	sub cx, 2 ; because of the width of the objects in this game (18), when using movsd (doubleword) we need the width to be divided by four
			  ; so we will sub cx 2 and divide it by four so it will do movsd only four times
	shr cx, 2
	rep movsd
	movsw ; this will be the remaining 2 bytes because we took 2 bytes to use movsd
	
	sub si,dx ; going down a line
	add si, 320
	
	
	pop cx
	loop @@NextRow
	
	pop es
	pop ds
	popa
    ret
endp putMatrixInData

;================================================
; Description - for using an objects that has either an invisble color or has odd number of width, it will put the given matrix on screen
; INPUT: "matrix" - offset of matrix, CX col size, DX row size and DI place on screen
; OUTPUT: puts the matrix bytes on screen
; Register Usage: None
;================================================
proc putCubeInScreen
	pusha
	
	mov ax, 0A000h
	mov es, ax
	cld
	
	mov si,[matrix]
	
@@NextRow:
	push cx
	
	mov cx, dx
	
@@draw_line:	; Copy line to the screen
	lodsb
	cmp al, 1
	je @@end ; if it is equal to one we need to skip it
	stosb
	dec di
@@end:
	inc di
	loop @@draw_line
	
	sub di,dx
	add di, 320
	
	
	pop cx
	loop @@NextRow	
	
	popa
    ret
endp putCubeInScreen

;================================================
; Description - for using an objects that has either an invisble color or has odd number of width, it will put the given matrix in data
; INPUT: "matrix" - offset of matrix, CX col size, DX row size and DI place on screen
; OUTPUT: puts the matrix bytes in data
; Register Usage: None
;================================================
proc putCubeInData
	pusha
	
	mov ax, 0A000h
	mov es, ax
	cld
	
	mov si,[matrix]
	
@@NextRow:	
	push cx
	
	mov cx, dx
@@copy_data:	; Copy line to the screen
	mov al, [es:di]
	mov [ds:si], al
	inc si
	inc di
	loop @@copy_data
	
	sub di,dx
	add di, 320
	
	pop cx
	loop @@NextRow

	popa
    ret
endp putCubeInData

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
    push es si di
	
	mov ax, 40h
	mov	es, ax
	
	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP
 
	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
RandLoop: ;  generate random number 
	mov ax, [word es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)
	xor al, ah ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di ; change the place of rnd label
	cmp di,(EndOfCsLbl - start - 1) ; see if it reached the end
	jb @@Continue ; if not continue
	mov di, offset start ; if yes move the rnd label to the start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop
	
	add al,bl  ; add the lower limit to the rnd num
		 
@@ExitP:	
	pop di si es
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
	shr bh,1 ; divide by two
	cmp bh,0 ; see if zero
	jz @@EndProc ; if yes go to end
	
	shl si,1 ; multiple si by two
	inc si ; add si one
	; in binary this will just move all the bits to the left and make the first zero to one
	
	jmp @@again ; repeat
	
@@EndProc:
    pop bx
	ret
endp  MakeMask

;================================================
; Description - prints in ascii chars the number in ax - base 10
; INPUT: Number in AX
; OUTPUT: print on screen ax content
; Register Usage: None
;================================================
proc printAxDec
	push bx dx cx
	
	mov cx,0   ; will count how many time we did push 
	mov bx,10  ; the divider

put_next_to_stack:
	xor dx,dx ; make dx zero for div
	div bx ; divide by ten
	add dl, '0' ; make the modulue a real number
	; dl is the current LSB digit 
	; we cant push only dl so we push all dx
	push dx ; save the ascii char in stack
	inc cx
	cmp ax,9   ; check if it is the last time to div
	jg put_next_to_stack ; if above continue to push every digit
	cmp ax,0
	jz pop_next_from_stack  ; jump if ax was totally 0
	add al,30h  ; if got to last digit make it a real number and print it
	mov dl, al  ; because we use this interrupt the char needs to be in dl
	mov ah, 2h
	int 21h        ; show first digit MSB

pop_next_from_stack: 
	pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	mov dl, al
	mov ah, 2h
	int 21h        ; show all rest digits
	loop pop_next_from_stack ; will do it cx times - cx is the counter so the amount of digits
	
	pop cx dx bx
	ret
endp printAxDec 

EndOfCsLbl:
END start