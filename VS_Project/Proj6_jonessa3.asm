TITLE Low-Level I/O Procedures     (Proj6_jonessa3.asm)

; Author: Sam Jones
; Last Modified: 6/1/2022
; OSU email address: jonessa3@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: Project 6         Due Date: 6/5/2022
; Description: This program asks for a signed number and takes in a string
;			   of user input. It then validates the input and stores it in
;			   a memory location. This is repeated 10 times. The program
;			   then displays the list of valid numbers entered, the sum of
;			   valid numbers, and the truncated average of valid numbers

INCLUDE Irvine32.inc

; MACROS

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints a string which is stored in a specified memory location
;
; Preconditions: 
;
; Receives:
;	toDisplay	  = OFFSET of string to be displayed
;
; Returns: 
; ---------------------------------------------------------------------------------

mDisplayString MACRO toDisplay:REQ
  push	EDX
  mov	EDX,  toDisplay
  call	Writestring
  pop	EDX
ENDM

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt, then gets the user's keyboard input and stores it in a memory
;	location.
;
; Preconditions: 
;
; Receives:
;	inputPrompt	  = OFFSET of the string containing the prompt (ref, input)
;	stringStorage =	Location where the user entered string will be stored (ref,
;					output)
;	maxLength	  = The maxiumum length allowed for the input string provided by
;					the user (value, input)
;	bytesRead	  = The number of bytes read from user input (value, output)
;
; Returns:
;	stringStorage = user entered string
;	bytesRead	  = The number of bytes read from user input
; ---------------------------------------------------------------------------------

mGetString	MACRO inputPrompt:REQ, stringStorage:REQ, bytesRead:REQ
  push	EDX
  push	ECX
  push	EAX

  ; Display prompt
  mDisplayString  inputPrompt

  ; call ReadString to get user input
  mov	EDX,  stringStorage
  mov	ECX,  MAX_STRING_LEN
  call	ReadString

  ; Store number of characters entered in bytesRead
  mov	bytesRead,	EAX

  pop	EAX
  pop	ECX
  pop	EDX
ENDM

; (insert constant definitions here)

NUM_VALUES = 10
MAX_STRING_LEN = 13

.data
; Text
intro			BYTE	"Designing Low-Level I/O Procedures	  by Sam Jones",0
desc_1			BYTE	"Please provide 10 signed decimal integers. Each number must fit inside a 32-bit register.",0
desc_2			BYTE	"When you are finished entering your numbers, this program will display a list of your integers,",0
desc_3			BYTE	"their sum, and their truncated average value.",0
prompt			BYTE	"Please enter a signed number: ",0
error			BYTE	"ERROR: Invalid Input. Please enter a signed integer that will fit in a 32-bit register.",0
numList			BYTE	"You entered the following numbers: ",0
numSum			BYTE	"The sum of these numbers is: ",0
numAvg			BYTE	"The truncated average of these numbers is: ",0
goodbye			BYTE	"Thanks for using my program! Goodbye!",0
comma			BYTE	", ",0

; User entered values
userString		BYTE	MAX_STRING_LEN DUP(0)
values			SDWORD	NUM_VALUES DUP(?)

; Calculated data
sum				SDWORD	?
avg				SDWORD	?
convertedString	BYTE	MAX_STRING_LEN DUP(0)

; Helper data
byteCount		DWORD	?
valuesType		DWORD	TYPE values
numDigits		DWORD	?
workingNum		SDWORD	?

.code
main PROC
  ; -------------------------------------------------------------------------------
  ; Print program title and description
  ; -------------------------------------------------------------------------------
  mDisplayString  OFFSET intro
  call	CrLf
  call	CrLf

  mDisplayString  OFFSET desc_1
  call	CrLf
  mDisplayString  OFFSET desc_2
  call	CrLf
  mDisplayString  OFFSET desc_3
  call	CrLf
  call	CrLf

  ; -------------------------------------------------------------------------------
  ; Get NUM_VALUES inputs from the user, convert them to a numerical value,
  ;	  validate that the number is within parameters, and store the value in the
  ;	  'values' array
  ; -------------------------------------------------------------------------------

  ; store 'values' in EDI and prepare ECX for the loop
  mov	EDI,  OFFSET values
  mov	ECX,  NUM_VALUES

  ; Start a loop to get NUM_VALUES valid ints from user input
_inputLoop:
  ;	  call ReadVal
  push	OFFSET error
  push	OFFSET byteCount
  push	OFFSET userString
  push	OFFSET prompt
  push	EDI
  call	ReadVal

  ;	  increment EDI to next index of 'values' (register indirect addressing)
  add	EDI,  valuesType

  ;	  loop
  loop	_inputLoop

  call	CrLf
  ; -------------------------------------------------------------------------------
  ; Loop through each value in the 'values' array, add the value to 'sum', convert
  ;	  the value to a string, and print it to the screen 
  ; -------------------------------------------------------------------------------

  ; Print the title for the list of values
  mDisplayString  OFFSET numList

  ; store 'values' in EDI and prepare ECX for loop
  mov	EDI,  OFFSET values
  mov	ECX,  NUM_VALUES

  ; Start a loop to print NUM_VALUES values from 'values' array
_outputLoop:
  ;	  Add value in EDI to Sum
  mov	EAX,  [EDI]
  add	sum,  EAX

  ;	initialize numDigits to 0
  mov	numDigits,	0

  ;	  call WriteVal
  push	OFFSET convertedString
  push	OFFSET numDigits
  push	[EDI]
  call	WriteVal

  ;	if ECX > 1, print a comma
  cmp	ECX,  1
  jle	_continueLoop
  mDisplayString  OFFSET comma

_continueLoop:
  ;	  increment EDI (register indirect addressing)
  add	EDI,  valuesType

  ;	  loop
  loop	_outputLoop

  call	CrLf
  ; -------------------------------------------------------------------------------
  ; Calculate the average value, and then print Sum and Avg to the screen with
  ;	  the proper titles
  ; -------------------------------------------------------------------------------

  ; Calculate truncated avg (sum / NUM_VALUES)
  mov	EAX,  sum
  mov	EBX,  NUM_VALUES
  cdq
  idiv	EBX
  mov	avg,  EAX

  ;	print tile for sum
  mDisplayString  OFFSET numSum

  ;	initialize numDigits to 0
  mov	numDigits,	0

  ; call WriteVal on sum
  push	OFFSET convertedString
  push	OFFSET numDigits
  push	sum
  call	WriteVal
  call	CrLf

  ; print title for avg
  mDisplayString  OFFSET numAvg

  ;	initialize numDigits to 0
  mov	numDigits,	0

  ; call WriteVal on avg
  push	OFFSET convertedString
  push	OFFSET numDigits
  push	avg
  call	WriteVal
  call	CrLf

  call	CrLf
  ; -------------------------------------------------------------------------------
  ; Print goodbye message and end the program
  ; -------------------------------------------------------------------------------
  mDisplayString  OFFSET goodbye
  call	CrLf


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ADDITIONAL PROCEDURES

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Reads a value from user input as a string of ASCII characters, converts the
;	string to a numeric value representation (SDWORD) validating along the way, and
;	stores the validated value in a memory variable
;
; Preconditions: mGetString should be a macro defined to get user input in the form 
;	of a string of digits
;
; Postconditions: 
;	Registers Modified: All modified registers are restored by the procedure
;
; Receives: 
;	memory variable ([EBP + 8]) = location where the validated number will be stored 
;								  (output, reference)
;	prompt ([EBP + 12])			= Prompt to tell the user what to enter (input, ref)
;	user string	([EBP + 16])	= OFFSET of the memory location to store the user's
;								  entered string
;	byte count ([EBP + 20])		= Location where the number of bytes read will be
;								  stored
;	error message ([EBP + 24])	= OFFSET of the error message for invalid input
;	mGetString					= A macro that gets user input in the form of a
;								  string of ASCII characters
;
; Returns: memory variable with the validated number stored in it
; ---------------------------------------------------------------------------------

ReadVal	PROC
  ; preserve registers
  push  EBP
  mov	EBP,  ESP
  push	EDI
  push	EAX
  push	EBX
  push	ECX
  push	ESI
  push	EDX

  ; invoke mGetString
_getInput:
  mov	EDI,  [EBP + 20]
  mGetString  [EBP + 12], [EBP + 16], [EDI]

  ; -------------------------------------------------------------------------------
  ; Run an initial validation to see if the number of characters entered could
  ;	  possibly be within the required range
  ; -------------------------------------------------------------------------------

  ;	Move the number of characters entered into EAX for comparison
  mov	EAX,  [EDI]

  ; If the number of characters in the string = 0, print an error message and get new input
  cmp	EAX,  0
  je	_error

  ; If the number of characters in the string is > 11, then the string is too long (this accounts for the 10 characters in 2,147,483,64(7/8) and the sign indicator (+/-))
  cmp	EAX,  11
  jg	_error

  ; -------------------------------------------------------------------------------
  ; Create two loops that runs a number of times equal to the number of characters 
  ;	  entered in the user entered string. One loop will handle positive numbers, 
  ;	  and the other will handle negative numbers. 
  ;	  
  ;	This will convert the string to its numerical value representation, and check
  ;	  the overflow flag as it goes to  make sure the number stays within the
  ;	  required range.
  ; -------------------------------------------------------------------------------

  ; Prep ECX and EDI for the loop 
  mov	ECX,  [EDI]
  mov	EDI,  [EBP + 8]

  ; move user entered string into ESI, and prepare for string primitive operations
  mov	ESI,  [EBP + 16]
  cld

  ; Check the first character for a sign indication and jump to the appropriate location based on this information
  lodsb
  cmp	AL,	45
  je	_fixLoopNeg
  cmp	AL,	43
  je	_fixLoopPos
  sub	ESI,  1
  jmp	_convertPos

  ; -------------------------------------------------------------------------------
  ; Positive number handling
  ; numerical representation = 10 * [EDI] + (AL - 48)
  ; -------------------------------------------------------------------------------
_fixLoopPos:
  ; Decrement ECX to adjust for removing sign indicator
  sub	ECX,  1

_convertPos:
  ;	Clear EAX
  mov	EAX,  0

  ; Check to see if the character is 48 <= AL <= 57
  lodsb
  cmp	AL,	48
  jl	_charError
  cmp	AL,	57
  jg	_charError

  ; Get the numerical value of the character and push it to the stack
  sub	EAX,  48
  push	EAX

  ; Get the current value in the memory for the final numerical representation, multiply it by 10, and put it back in it's memory location
  mov	EAX,  [EDI]
  mov	EBX,  10  
  imul	EBX
  jo	_charError																	  ; Jump to _error and restart input if there is overflow
  mov	[EDI],	EAX

  ; Get the numerical value of the current character and add it to the value stored in the final memory location
  pop	EAX
  add	[EDI],	EAX
  jo	_charError																	  ; Jump to _error and restart input if there is overflow

  loop	_convertPos
  jmp	_end

  ; -------------------------------------------------------------------------------
  ; Negative number handling
  ; numerical representation = 10 * [EDI] - (AL - 48) 
  ;	  where [EDI] is negative (accomplished with _convertNeg)
  ; -------------------------------------------------------------------------------
_fixLoopNeg:
  ; Decrement ECX to adjust for removing sign indicator and for first char being handled outside of the loop
  sub	ECX,  2

_convertNeg:																		  ; The numerical value of the first character must be converted to negative for the algorithm to work, so this is done outside of the loop
  ; Clear EAX
  mov	EAX,  0

  ; Check to see if the character is 48 <= AL <= 57
  lodsb
  cmp	AL,	48
  jl	_charError
  cmp	AL,	57
  jg	_charError

  ; Get the numerical value of the first char, make it negative, and store it in [EDI]
  sub	EAX,  48
  mov	EBX,  -1
  imul	EBX
  mov	[EDI],	EAX

  ; if ECX = 0, jump to the end
  cmp	ECX,  0
  jz	_end

_negLoop:
  ; Clear EAX
  mov	EAX,  0

  ; Check to see if the character is 48 <= AL <= 57
  lodsb
  cmp	AL,	48
  jl	_charError
  cmp	AL,	57
  jg	_charError

  ; get the numerical value of the char and push it to the stack
  sub	EAX,  48
  push	EAX

  ; Get the current value in the memory for the final numerical representation, multiply it by 10, and put it back in it's memory location
  mov	EAX,  [EDI]
  mov	EBX,  10  
  imul	EBX
  jo	_charError																	  ; Jump to _charError and restart input if there is overflow
  mov	[EDI],	EAX
  
  ; Get the numerical value of the current character and subtract it to the value stored in the final memory location
  pop	EAX
  sub	[EDI],	EAX
  jo	_charError																	  ; Jump to _charError and restart input if there is overflow

  loop	_negLoop
  jmp	_end


  ; -------------------------------------------------------------------------------
  ; Error paths
  ; -------------------------------------------------------------------------------
_charError:
  ; If input was found to be invalid in the middle of converting the string, reset [EDI] to 0
  mov	EBX,  0
  mov	[EDI],	EBX

_error:
  ; print error message
  mDisplayString  [EBP + 24]
  call	CrLf

  ; get new input
  jmp	_getInput

  ; -------------------------------------------------------------------------------
  ; End procedure
  ; -------------------------------------------------------------------------------

_end:
  ; balance the stack
  pop	EDX
  pop	ESI
  pop	ECX
  pop	EBX
  pop	EAX
  pop	EDI
  pop	EBP

  RET	20
readVal	ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal 
;
; Converts a numeric SDWORD value to a string of ASCII digits, and prints the
;	string to output
;
; Preconditions: the memory variable where the numeric SDWORD value is stored
;	should be pushed to the stack. mDisplayString should be a macro defined to
;	print a string of ASCII characters to output
;
; Postconditions: number of digits must be set to 0 to begin
;	Registers Modified:
;
; Receives: 
;	number variable ([EBP + 8])	  = number to be converted to ASCII digits (value)
;	number of digits ([EBP + 12]) =	location of variable to store the number of
;									digits in the number to be converted
;	storage variable ([EBP + 16]) =	loction of the array to store the chars of the
;									converted number
;
;	mDisplayString				  = A macro that prints a string of ASCII digits to
;								  output
;
; Returns: None
; ---------------------------------------------------------------------------------

WriteVal  PROC
  ;	Preserve registers
  push	EBP
  mov	EBP,  ESP
  push	EDI
  push	ESI
  push	EAX
  push	EDX
  push	EBX
  push	ECX

  ; -------------------------------------------------------------------------------
  ; Get the amount of digits in the number to be converted
  ; -------------------------------------------------------------------------------

  ;	Store the number in ECX and put memory storage location for number of digits in EDI
  mov	ECX,  [EBP + 8]
  mov	EDI,  [EBP + 12]

_getNumDigits:
  ;	Increment the number of digits
  mov	EAX,  [EDI]
  inc	EAX
  mov	[EDI],	EAX

  ;	divide ECX / 10
  mov	EAX,  ECX
  mov	EBX,  10
  cdq
  idiv	EBX

  ;	store the result back in ECX and discard the remainder
  mov	ECX,  EAX
  cmp	ECX,  0
  jnz	_getNumDigits

  ; store the destination character array in EDI
  mov	EDI,  [EBP + 16]

  ;	If the number is positive, jump to positive handling
  mov	EBX,  [EBP + 8]
  cmp	EBX,  0
  jge	_positiveConversion


  ; -------------------------------------------------------------------------------
  ; Prepare a negative number to be put through the conversion loop by prepending
  ;	  a '-' to the destination character array, and converting the first digit
  ;	  of the number to an ASCII character
  ; -------------------------------------------------------------------------------

  ; Clear the direction flag
  cld

  ;	move '-' to AL and add it to the char array at the beginning
  mov	AL,	45																		  ;	45 is the ASCII code for '-'
  stosb

  ;	Move EDI forward by the amount of digits in the number
  mov	EBX,  [EBP + 12]
  add	EDI,  [EBX]

  ;	Set the direction flag (move backwards through EDI)
  std

  ; Add a zero to EDI to make sure string is null terminated
  mov	AL,	0
  stosb

  ;	Convert the first digit outside of the loop
  ; Store original number in ESI
  mov	EAX,  [EBP + 8]
  mov	ESI,  EAX

  ;	divide the number (ESI) by -10
  cdq
  mov	EAX,  ESI
  mov	EBX,  -10
  idiv	EBX

  ;	store the value of the number / -10 back in ESI
  mov	ESI,  EAX

  ;	get the remainder and add 48
  neg	EDX
  add	EDX,  48

  ;	store this in AL and move it to the char array (EDI)
  mov	EAX,  0
  mov	EAX,  EDX
  stosb

  ;	Set ECX to the number of digits - 1
  mov	EBX,  [EBP + 12]
  mov	ECX,  [EBX]
  dec	ECX

  ;	Jump to the loop if ECX > 0
  cmp	ECX,  0
  jz	_display
  jmp	_conversionLoop


  ; -------------------------------------------------------------------------------
  ; Prepare a positive number to be put through the conversion loop 
  ; -------------------------------------------------------------------------------
_positiveConversion:
  ; Store original number in ESI
  mov	EAX,  [EBP + 8]
  mov	ESI,  EAX

  ;	Move EDI forward by the amount of digits in the number
  mov	EBX,  [EBP + 12]
  add	EDI,  [EBX]

  ;	Set the direction flag (move backwards through EDI)
  std

  ; Add a zero to EDI to make sure string is null terminated
  mov	AL,	0
  stosb

  ;	Set ECX to the number of digits
  mov	EBX,  [EBP + 12]
  mov	ECX,  [EBX]

  ; -------------------------------------------------------------------------------
  ; Convert each digit of the number to an ASCII character and add it to the string
  ;	  by dividing the base number by 10, storing the dividend as the new base
  ;	  number, and adding 48 to the remainder and adding it to the string
  ; -------------------------------------------------------------------------------
_conversionLoop:
  ;	divide the number (ESI) by 10
  cdq
  mov	EAX,  ESI
  mov	EBX,  10
  idiv	EBX

  ;	store the value of the number / 10 back in ESI
  mov	ESI,  EAX

  ;	get the remainder and add 48
  add	EDX,  48

  ;	store this in AL and move it to the char array (EDI)
  mov	EAX,  0
  mov	EAX,  EDX
  stosb

  loop	_conversionLoop

_display:
  ;	Call mDisplayString on the char array
  mDisplayString  [EBP + 16]

  ; Balance stack
  pop	ECX
  pop	EBX
  pop	EDX
  pop	EAX
  pop	ESI
  pop	EDI
  pop	EBP

  RET	12
WriteVal  ENDP

END main
