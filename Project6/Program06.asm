TITLE Program 6          (Program06.asm)

; Author: George Kochera
; Last Modified: 03/15/2020
; OSU email address: kocherag@oregonstate.edu
; Course number/section: CS271-400
; Project Number:6                Due Date: 03/15/2020

; Description: This is the CS271 portfolio project also identified as Program 6. The program takes 10 user inputs
; (adjustable by editing MAX_NUMBER_OF_INPUTS in the global constants section) and saves them to memory as integers.
; During this process, the user input is validated to ensure it meets a few constraints such as being valid 32 bit
; signed integers and also being of the proper format (no invalid characters).
;
; The program then reads all the numbers back out of the array they were stored in, converting them back to strings and
; displaying them on the screen. In addition to this, the sum is displayed as well as the average.
;
; EXTRA CREDIT: Each valid user input will increase the line number so that all valid user inputs are individually numbered.
; A rolling subtotal is displayed after each valid user input.


INCLUDE \Irvine\Lib32\Irvine32.inc

;-----------------------------------------------------------------
;         GLOBAL CONSTANTS (MODIFICATION CHANGES PROGRAM)
;-----------------------------------------------------------------

MAX_NUMBER_OF_INPUTS = 10

;-----------------------------------------------------------------
;                            MACROS
;-----------------------------------------------------------------

getString MACRO prompt_text_address, input_buffer_pointer, input_buffer_counter, input_buffer_size, line_number
;should display a prompt, then get the user’s keyboard input into a memory location
     LOCAL prompt_text_address, input_buffer_pointer, input_buffer_counter, input_buffer_size, line_number
;display the line number for user input (EC1)
     call      CrLf
     mov       eax, [line_number] ; were going to display the current line number for valid user input
     inc       eax ; since the line number is always one more than the number of valid inputs
     call      WriteDec
     mov       al, ' '
     call      WriteChar
     mov       al, '|'
     call      WriteChar
     mov       al, ' '
     call      WriteChar

     mov       edx, [prompt_text_address]
     call      WriteString

;get the input from the user and save it
     mov       edx, [input_buffer_pointer]
     mov       ecx, [input_buffer_size]

     call      ReadString
     mov       ebx, [input_buffer_counter]
     mov       [ebx], eax
ENDM

displayString MACRO memory_address
;should print the string which is stored in a specified memory location.
     LOCAL memory_address
     mov edx, memory_address
     call WriteString
     
ENDM


;------------------------------------------------------------------------------------------------------
;           BEGIN DATA SEGMENT: (p)rompt (v)ariable (f)ile-operations (l)ocal-variables
;------------------------------------------------------------------------------------------------------
.data
p_introduction                BYTE           0dh,0ah,"Program 6 // Portfolio Project",0dh,0ah,
                                             "Designing low-level I/O procedures",0dh,0ah,
                                             "Developed by: George Kochera",0dh,0ah,0
p_instructions                BYTE           0dh,0ah,"Please provide 10 signed decimal integers.",0dh,0ah,
                                             "Each number needs to be small enough to fit inside a 32-bit register.",0dh,0ah,
                                             "After you have finished inputting the raw numbers I will display a",0dh,0ah,
                                             "list of the integers, their sum, and their average value.",0dh,0ah,0

p_ec1                         BYTE           0dh,0ah,80 DUP ("*"),0dh,0ah,
                                             "*                                    EXTRA CREDIT                              *", 0dh,0ah,0
p_ec2                         BYTE           80 DUP ("*"),0dh,0ah,
                                             "*     1) Number each line of user input and display a running subtotal of      *",0dh,0ah,
                                             "*        the user's numbers.                                                   *",0dh,0ah,0
p_ec3                         BYTE           "*                                                                              *",0dh,0ah,
                                             "*                                                                              *",0dh,0ah,
                                             "*                                                                              *",0dh,0ah,0
p_ec4                         BYTE           80 DUP ("*"),0dh,0ah,0
p_enter_signed_number         BYTE           "Please enter a signed number: ",0
p_running_subtotal            BYTE           "Running Subtotal: ",0
p_invalid_number_entered      BYTE           0dh,0ah,"You did not enter a valid number.",0
p_entered_numbers             BYTE           0dh,0ah,"You entered the following numbers:",0dh,0ah,0
p_the_sum_is                  BYTE           0dh,0ah,"The sum of these numbers is: ",0
p_the_average_is              BYTE           0dh,0ah,"The rounded average is: ",0
p_conclusion                  BYTE           0dh,0ah,0dh,0ah,"Thank you for playing! Please come again!",0

v_input_buffer                BYTE           12 DUP (0)
v_input_buffer_size           DWORD          SIZEOF v_input_buffer
v_input_buffer_counter        DWORD          ?

v_master_number_array         DWORD          MAX_NUMBER_OF_INPUTS DUP (0)
v_number_of_valid_inputs      DWORD          0

v_output_buffer               BYTE           12 DUP (0)
v_output_buffer_size          DWORD          SIZEOF v_output_buffer

v_master_string_array         BYTE           MAX_NUMBER_OF_INPUTS DUP (12 DUP (0))

v_sum                         DWORD          ?
v_average                     DWORD          ?

;-----------------------------------------------------------------
;                      BEGIN CODE SEGMENT
;-----------------------------------------------------------------
.code
;-----------------------------------------------------------------
;                        MAIN PROCEDURE
;-----------------------------------------------------------------
;Pre-Conditions: None. Procedure is entry point for execution.

;Post-Conditions: Text displayed on screen via console.

;Registers Affected: All registers are changed and manipulated throughout the 
; execution of this program.

;Description: This is the main procedure. All other procedures are subordinate 
; to this procedure and are called by this procedure or child procedures.

;Parameters:
main PROC

     ; Display the introduction and developer's name.
     push      OFFSET p_introduction
     call      DisplayIntroduction

     ; Display the extra credit statements for the project.
     push      OFFSET p_ec1
     push      OFFSET p_ec2
     push      OFFSET p_ec3
     push      OFFSET p_ec4
     call      DisplayExtraCredit

     ; Display the instructions for the user regarding the program.
     push      OFFSET p_instructions
     call      DisplayInstructions

     ; Start accepting user input.
     push      OFFSET v_sum                       ;(+40)
     push      OFFSET p_running_subtotal          ;(+36)
     push      v_number_of_valid_inputs           ;(+32)
     push      OFFSET p_invalid_number_entered    ;(+28)
     push      v_input_buffer_size                ;(+24)
     push      OFFSET v_input_buffer_counter      ;(+20)
     push      OFFSET v_input_buffer              ;(+16)
     push      OFFSET v_master_number_array       ;(+12)
     push      OFFSET p_enter_signed_number       ;(+8)
     call      ReadVal

     ; Start displaying user input as output.
     push      OFFSET p_the_average_is
     push      OFFSET p_the_sum_is
     push      v_sum
     push      OFFSET p_entered_numbers
     push      OFFSET v_master_string_array
     push      v_number_of_valid_inputs
     push      OFFSET v_master_number_array
     push      OFFSET v_output_buffer
     push      v_output_buffer_size
     call      WriteVal

     ; Display the farewell
     push      OFFSET p_conclusion
     call      Farewell

     ; Terminate the program.
     exit
main ENDP



;-----------------------------------------------------------------
;                        DisplayIntroduction PROCEDURE
;-----------------------------------------------------------------
;Pre-Conditions: Parameters must be pushed to stack in order and by type as listed in parameters section.

;Post-Conditions: Text displayed on screen via console.

;Registers Affected: ebp, esp, edx

;Description: Displays the developer information and brief introduction on the screen.

;Parameters: (+8) introduction ref.
DisplayIntroduction PROC
     push      ebp
     mov       ebp, esp
     mov       edx, [ebp + 8]
     call      WriteString
     pop       ebp
     ret       4
DisplayIntroduction ENDP


;-----------------------------------------------------------------
;                        DisplayInstructions PROCEDURE
;-----------------------------------------------------------------
;Pre-Conditions: Parameters must be pushed to stack in order and by type as listed in parameters section.

;Post-Conditions: Text displayed on screen via console.

;Registers Affected: ebp, esp

;Description: Displays the instructions to the user on the screen.

;Parameters: (+8) instructions text ref.
DisplayInstructions PROC
     push      ebp
     mov       ebp, esp
     mov       edx, [ebp + 8]
     call      WriteString
     pop       ebp
     ret       4
DisplayInstructions ENDP

;-----------------------------------------------------------------
;                        DisplayExtraCredit PROCEDURE
;-----------------------------------------------------------------
;Pre-Conditions: Parameters must be pushed to stack in order and by type specified in parameters section.

;Post-Conditions: Text displayed on screen via console.

;Registers Affected: ebp, esp, edx

;Description: This is the main procedure. All other procedures are subordinate 
; to this procedure and are called by this procedure or child procedures.

;Parameters: (+8) ec4 text ref. (+12) ec3 text ref. (+16) ec2 text ref. (+20) ec1 text ref.
DisplayExtraCredit PROC
     push      ebp
     mov       ebp, esp
     mov       edx, [ebp + 20]
     call      WriteString
     mov       edx, [ebp + 16] 
     call      WriteString    
     mov       edx, [ebp + 12]
     call      WriteString
     mov       edx, [ebp + 8]
     call      WriteString
     pop       ebp
     ret       16
DisplayExtraCredit ENDP

;-----------------------------------------------------------------
;                        ReadVal PROCEDURE
;-----------------------------------------------------------------
;Pre-Conditions: Various parameters must be pushed to stack prior to exectution, see paramters bullet for order and type.

;Post-Conditions: Text is converted from string to integer and saved to an array. Numbers are accpted by standard input.

;Registers Affected: eax, ebx, ecx, edx, ebp, esp, edi, esi

;Description: This procedure uses the getString macro to accept user input and store it in a buffer. The buffer is then validated for valid input and
; to ensure the input is within range (32 bit signed int). Once validated, the buffer is converted to an integer through repeating division by 10 and 
; written to a master number array. Upon completion of this procedure, a quantity of values will be populated in the array (determined by value set
; in code header.

;Parameters: (+4) return pointer ref. (+8) getString prompt string ref. (+12) master array ref. (+16) user input buffer ref. (+20) user input buffer counter ref.
;(+24) input buffer size val. (+28) error message ref. (+32) number of valid inputs val. (+36) running subtotal prompt ref. (+40) sum of inputs ref.
ReadVal PROC
;should invoke the getString macro to get the user’s string of digits. It should then
;convert the digit string to numeric, while validating the user’s input.
     
;preserve the return pointer
     push      ebp
     mov       ebp, esp

;create space for our local variables
     sub esp, 24 ; need 20 bytes for local variables
     mov DWORD PTR [ebp - 24], 0; this will hold the current pointer for our location in the master array, we dont want this to reset
                                ; for each iteration of the loop so we will put it before the loop label

;call the macro to prompty the user for input and read the input
readval_getstring:
     getString [ebp + 8], [ebp + 16], [ebp + 20], [ebp + 24], [ebp + 32]

;set our local variables
     mov DWORD PTR [ebp - 4], 000000000b ; this will be the flag that sets when at least one digit is found
     mov DWORD PTR [ebp - 8], 000000000b ; this will be the flag that sets if the number entered is signed negative
     mov DWORD PTR [ebp - 12], 0 ; this will be the holding variable for our final number
     mov DWORD PTR [ebp - 16], 10 ; this will hold our number 10 used for multiplicaiton
     mov DWORD PTR [ebp - 20], 1; this will hold our multiplication factor used to get our final number



;load entered string for validation
     mov esi, [ebp + 16] ; esi points to the buffer offest
     mov ecx, [ebp + 20] ; ecx points to the number of entered digits/symbols
     mov ecx, [ecx] ; ecx needs to be dereferenced to access the value
     mov ebx, ecx ; copy it to ebx so we can identify the first digit which may be +/-
     cld

; start validating
readval_start_validation:
     lodsb
     cmp ebx, ecx ; see if this is the first digit
     jnz readval_is_not_first_digit_validation
readval_is_first_digit_validation:
     cmp al, 02Bh ; see if the first digit is '+' plus
     jz readval_evaluate_next_digit
     cmp al, 02Dh ; see if the first digit is '-' minus
     jz readval_is_valid_symbol_minus
readval_is_not_first_digit_validation:
     cmp al, 030h ; see if the digit is 0
     jz readval_is_valid_digit
     cmp al, 031h ; see if the digit is 1
     jz readval_is_valid_digit
     cmp al, 032h ; see if the digit is 2
     jz readval_is_valid_digit
     cmp al, 033h ; see if the digit is 3
     jz readval_is_valid_digit
     cmp al, 034h ; see if the digit is 4
     jz readval_is_valid_digit
     cmp al, 035h ; see if the digit is 5
     jz readval_is_valid_digit
     cmp al, 036h ; see if the digit is 6
     jz readval_is_valid_digit
     cmp al, 037h ; see if the digit is 7
     jz readval_is_valid_digit
     cmp al, 038h ; see if the digit is 8
     jz readval_is_valid_digit
     cmp al, 039h ; see if the digit is 9
     jz readval_is_valid_digit
readval_is_not_a_valid_digit:
     mov edx, [ebp + 28] ; load the error message
     push ecx ; preserve the registers
     push ebx ; preserve the registers
     call WriteString ; display the error message on the screen
     pop ebx ; recall the registers
     pop ecx ; recall the registers
     jmp readval_getstring ; go back to the beginning
readval_is_valid_digit:
     inc DWORD PTR [ebp - 4] ; if its a digit increment the quantity of digits
     jmp readval_evaluate_next_digit ; evaluate the next digit
readval_is_valid_symbol_minus:
     inc DWORD PTR [ebp - 8] ; if its a valid -  symbol increment the - symbol flag
readval_evaluate_next_digit:
     loop readval_start_validation ; loop until we have looked at the whole array

readval_verify_numbers_were_entered:
     mov ebx, [ebp - 4] ; make sure at least one non-sybol digit was entered (prevents just a - or + being entered)
     cmp ebx, 1
     jl readval_is_not_a_valid_digit

     mov ecx, [ebp - 4] ; load up the number of digits into ecx

     mov ebx, 1 ; reset the factor we multiply by to 1
     mov [ebp - 20], ebx ; set that memory slot to 1
     std ;reverse the direction flag
     dec esi ; move backward one space to get off the null character at the end of the string
readval_convert_to_number:
     mov eax, 0
     lodsb ; start pulling character out of the string into eax
     xor   eax, 000110000b ;ascii digits are 30-39 in hex so if we eliminate the leading 3, we will be left with the integer representation of the string
     mov   ebx, [ebp - 20]
     imul ebx ; multiply the current position by our current factor

     mov ebx, [ebp - 12] ; get the current full number into a register

     add ebx, eax ; add the result of multiplication to the original number
     jc readval_is_not_a_valid_digit ; if the carry flag sets, the result will not fit in a 32 bit register
     mov [ebp - 12], ebx ; save the new original number
     mov eax, [ebp - 20] ; get our current factor
     imul DWORD PTR [ebp - 16] ; multiply the factor by 10
     mov [ebp - 20], eax ; save the current factor
     loop readval_convert_to_number





readval_apply_sign:
     mov ebx, [ebp - 8] ; determine if the user attempted to enter a signed number
     cmp ebx, 1
     je readval_enforce_valid_32_bit_negative_signed_integer_size ; if the user specifically used the - character at the beginning of input, the number is deemed negative
     jmp readval_enforce_valid_32_bit_positive_signed_integer_size ; otherwise the number stays positive
readval_enforce_valid_32_bit_negative_signed_integer_size:
     mov eax, 080000000h ; we load the lowest possible integer into eax without negation (+2,147,483,648)
     mov ebx, [ebp - 12] ; we load the number the user intered into ebx
     cmp ebx, eax ; compare the two
     ja readval_is_not_a_valid_digit ; since we are using unsigned comparison, we evaluate using jump above, if the number is larger than +2,147,483,648 we discard
     mov eax, [ebp - 12] ; otherwise we take the number the user entered
     neg eax ; twos complement it to make it negative (what the user actually entered)
     mov [ebp - 12], eax ; save it
     jmp readval_number_validated ; number was valid
readval_enforce_valid_32_bit_positive_signed_integer_size:
     mov eax, 07FFFFFFFh ; in the event the number is positive, the largest 32 bit positive signed integer is +2,147,483,647.
     mov ebx, [ebp - 12] ; check it against the number
     cmp ebx, eax
     ja readval_is_not_a_valid_digit ; if the user entered a number greater than +2,147,483,647 discard it.


; once we have a valid number, we need to add it to the array

readval_number_validated:
     mov       eax, [ebp - 12] ; move our validated user input to the eax register
readval_first_number_validated_check:
     mov       ebx, [ebp + 32] ; move the number of validated user inputs to ebx and test it to see if it is the first number
     test      ebx, ebx
     jnz       readval_not_first_number_validated_check
     mov       edi, [ebp + 12] ; move our master array (where numbers will be held) pointer to edi
     jmp       readval_store_validated_number
readval_not_first_number_validated_check:
     mov       edi, [ebp - 24]
readval_store_validated_number:
     cld         ; clear the direction flag to move forward
     stosd
     mov       [ebp - 24], edi ; update the position in our master array (we can always work backward because we track the # of valid inputs)
     inc       DWORD PTR [ebp + 32] ; increment the number of valid inputs

; for EC1 we also need to display the running subtotal
readval_ec1_calculate_setup_running_subtotal:
     mov       esi, [ebp + 12] ; get our array pointer for the location of the valid number master array
     mov       ecx, [ebp + 32] ; get the number of valid inputs we have had
     mov       ebx, 0 ; clear out ebx, we will use this to hold our running subtotal
     cld
readval_ec1_calculate_running_subtotal:
     lodsd 
     add       ebx, eax
     loop      readval_ec1_calculate_running_subtotal ; we iterater throug the master array and keep adding values to ebx starting at 0 to give us the running subtotal

     mov       ecx, 5
readval_ec1_display_running_subtotal_padding:
     mov       al, ' '
     call      WriteChar
     loop      readval_ec1_display_running_subtotal_padding

readval_ec1_display_running_subtotal:
     mov       edx, [ebp + 36] ; put the running subtotal label text in edx
     call      WriteString ; display it 
     mov       eax, ebx ; put the running subtotal in eax
     call      WriteInt ; display the running subtotal
     call      CrLf

readval_save_sum_of_numbers:
     mov       edx, [ebp + 40]
     mov       [edx], ebx

; we need to jump back to the beginning if there are still numbers to enter
     mov       ebx, MAX_NUMBER_OF_INPUTS
     mov       eax, [ebp + 32]
     cmp       eax, ebx ; compare the number of valid inputs we have had with the requested number of inputs (default is 10 unless constant in header is changed)
     jl        readval_getstring

; at this point, we clean up the stack, pop our return pointer and return back to main     
     mov       esp, ebp
     pop       ebp
     ret       36
ReadVal ENDP


;-----------------------------------------------------------------
;                        WriteVal PROCEDURE
;-----------------------------------------------------------------
;Pre-Conditions: Various parameters must be pushed to stack prior to exectution, see paramters bullet for order and type.

;Post-Conditions: Text displayed on screen via console.

;Registers Affected: eax, ebx, ecx, edx, esi, edi, ebp, esp

;Description: This is the WriteVal procedure. It accesses the array sequentially and converts each member of the array from integer to string and then uses
; an implementation of the DisplayString macro to display the strings back on the standard output.

;Parameters: (+8) output buffer size val. (+12) output buffer ref. (+16) master number array ref. (+20) number of valid inputs val. (+24) master string array ref.
; (+28) entered numbers prompt ref. (+32) sum of entered numbers val. (+36) prompt for sum ref. (+40) prompt for average ref.
WriteVal PROC
;should convert a numeric value to a string of digits, and invoke the displayString
;macro to produce the output

; Basic Premise ****
; Take the array of signed integers, iterate through it converting each one back to a string to display on the screen, then use the displayString macro to
; read it from a specific memory location and display it on the screen.

; preserve the return pointer
     push      ebp
     mov       ebp, esp

;create space for our local variables
     sub esp, 44 ; need 44 bytes for local variables
     mov DWORD PTR [ebp - 16], 0 ; this will be our current position in the integer array when reading values from it, we dont want it to reset each loop
     mov DWORD PTR [ebp - 36], 0 ; this will hold our overall progress through the string array by index 0 = 1st number, 1 = 2nd number
     mov DWORD PTR [ebp - 44], 0 ; this will hold the average at the end of the procedure
writeval_begin:
     mov DWORD PTR [ebp - 4], 0 ; this will be the flag for the number being converted is a negative number
     mov DWORD PTR [ebp - 8], 10 ; we need the number ten for incremental divison
     mov DWORD PTR [ebp - 12], 10 ; this will be our divisor
     mov DWORD PTR [ebp - 20], 0 ; this will hold the current number that we are working with that was pulled from the array
     mov DWORD PTR [ebp - 24], 0 ; this will hold the length of the current number we are working on
     mov DWORD PTR [ebp - 28], 0 ; this wiill hold the number of digits we have converted from integers to chars
     mov DWORD PTR [ebp - 32], 0 ; this will hold the current digit we are converting to a string
     mov DWORD PTR [ebp - 40], 12 ; this holds the number 12 used to index correctly through the master string array

; clear the output buffer and ready it for use
     mov ecx, [ebp + 8]
     mov edi, [ebp + 12]
writeval_clear_output_buffer_before_use:
     mov eax, 0
     stosb
     loop writeval_clear_output_buffer_before_use

; get the address of the correct value to pull from the integer array
     mov eax, 4 ; 4 bytes in a dword
     mov ebx, [ebp - 36] ; get our index that we need to read from the integer array
     mov edx, 0 ; 0 out edx for multiplication
     mul ebx ; multiply to get offset 
     mov esi, [ebp + 16] ; load esi with the number array pointer
     add esi, eax ; add the offset to get the correct number from the array
     cld

; start pulling values from the array
     lodsd ; load the first number into eax
     test eax, eax ; determine if the value is signed (negative)
     mov [ebp - 16], esi ; save our current position in the array
     js writeval_convert_number_to_positive_unsigned
     jmp writeval_number_is_already_positive
writeval_convert_number_to_positive_unsigned:
     neg eax ; perform a twos complement on the number
     inc DWORD PTR [ebp-4] ; set the flag indicating that the number was negative
writeval_number_is_already_positive:
     mov [ebp - 20], eax ; save the current number loaded from the array

writeval_determine_number_length:
; now we need to figure out how long the number is....
     inc DWORD PTR [ebp - 24] ; every number is at least one digit, even if it is zero
     mov edx, 0 ; we need to zero out edx for division
     mov ebx, [ebp - 12] ; we need to load our divisor
     mov eax, [ebp - 20] ; load the current number into eax
     div ebx
     cmp eax, 0 ; see if there is a quotient since the user has to enter at least one digit we assume the length of number is one at least
     jg writeval_number_is_longer_than_current_length
     jmp writeval_number_length_done_being_calculated
writeval_number_is_longer_than_current_length:
     mov eax, [ebp - 12] ; we need our current divisor
     mov ebx, [ebp - 8] ; we need our multiplication factor of 10
     mov edx, 0 ; we clear out edx
     mul ebx
     mov [ebp - 12], eax ; we store the new current divisor back in the stack
     jmp writeval_determine_number_length
writeval_number_length_done_being_calculated:

; we now have the length of the current number stored in [ebp - 24]
     inc DWORD PTR [ebp - 24] ; because every integer will have a + or - in front of it, we will increase the total length by one

; first we must setup to begin converting the number to a string
     mov DWORD PTR [ebp - 12], 10; reset our divisor to 10
     mov edi, [ebp + 12] ; we load the output buffer into edi
     add edi, [ebp - 24] ; we then add the length of our string to edi since we will fill the buffer from right to left
     dec edi ; we decrement edi by 1 since we want to start at "index" one less the length of the number
     std ; we are going to fill the buffer backwards
; now we can begin converting the number to a string
writeval_convert_number_to_string:
     inc DWORD PTR [ebp - 28] ; increments each time we convert a digit
     mov eax, [ebp - 20] ; load our number into eax
     mov edx, 0 ; zero out edx to ensure division works correctly
     mov ebx, [ebp - 12] ; load 10 into ebx
     div ebx ; divide number by 10
     mov [ebp - 20], eax ; save the quotient for if we need another round of division
     mov [ebp - 32], edx ; save the remainder which will hold the digit we are working on
     mov eax, [ebp - 24]
     cmp [ebp - 28], eax ; we compare the number of digits converted with the overall length of the string minus the leading character +/-
     jz writeval_append_leading_sign
writeval_convert_integer_to_ascii:
     mov eax, [ebp - 32] ; move the digit to the eax register
     or   al, 000110000b ; digits in ascii are hex 30-39 so we essentially add hex 30
     stosb
     jmp writeval_convert_number_to_string
writeval_append_leading_sign:
     mov eax, [ebp - 4] ; load the flag for negative numbers into eax
     test eax, eax ; if eax is 0, number is positive
     jz writeval_append_plus_sign
writeval_append_negative_sign:
     mov al,'-'
     stosb
     jmp writeval_buffer_filled
writeval_append_plus_sign:
     mov al,'+'
     stosb
writeval_buffer_filled:


; at this point the buffer is filled with the ascii characters which represent the number in string format... buffer is [ebp + 12]

; we need to get the correct position in the destination array
     mov eax, [ebp - 36] ; load the ordinal position were at in the destination array
     mov ebx, [ebp - 40] ; ebx gets loaded with 12
     mul ebx ; multiply the index times 12

; eax now how has the offset were going to need to access the right position in the master string array
     cld
     mov edi, [ebp + 24] ; load the destination with the master string array address
     add edi, eax ; add the offset to edi to get the right position in the array
     mov esi, [ebp + 12] ; move the string buffer address to esi
     mov ecx, 12 ; were moving 12 bytes regardless of number contained
     rep movsb

; at this point the data has been transferred to the array, we now need to do some housekeeping

     inc DWORD PTR [ebp - 36] ; we update the ordinal position
     mov eax, [ebp - 36] ; load eax with the ordinal position
     cmp eax, MAX_NUMBER_OF_INPUTS ; we determine if all the numbers in the array have been transformed to strings
     jge  writeval_done_converting ; if we converted the number of inputs, were done, and we can clean up
     jmp writeval_begin ; if not go back to the beginning and convert the next number
writeval_done_converting:

writeval_setup_begin_showing_numbers:
     mov edx, [ebp + 28] ; display the text telling the user they entered the following numbers
     call WriteString
     call CrLf
    
     mov ecx, MAX_NUMBER_OF_INPUTS
writeval_begin_showing_numbers:
     mov eax, MAX_NUMBER_OF_INPUTS ; put the max number of inputs in eax
     sub eax, ecx ; subtract the current loop iteration from eax to get the indexed position of the array we want to read
     mov ebx, 12 ; 12 is the size in bytes of each block in the array
     mov edx, 0 ; clear out edx to prepare for multiplication
     mul ebx ; multiply to get the right offset
     add eax, [ebp + 24] ; add the address of the string array to get the correct address
     displayString eax ; call display string Macro
     cmp ecx, 1
     je writeval_last_number_in_list
writeval_insert_comma_space:
     mov al, ','
     call WriteChar
     mov al, ' '
     call WriteChar
writeval_last_number_in_list:
     loop writeval_begin_showing_numbers

writeval_done_printing_numbers:
     mov  edx, [ebp + 36] ; display the sum of the numbers prompt
     call WriteString
     mov  eax, [ebp + 32] ; display the sum of the numbers
     call WriteInt

writeval_calculate_average_of_numbers:

     mov eax, [ebp + 32] ; get the sum in eax
     cdq ; sign extend eax
     mov ebx, MAX_NUMBER_OF_INPUTS ; the max number of inputs will serve as the divisor
     idiv ebx
     mov [ebp - 44], eax ; store the average on the stack

writeval_display_average_of_numbers:
     mov edx, [ebp + 40]
     call WriteString
     mov eax, [ebp - 44]
     call WriteInt



; clean up, pop return pointer, and return
     mov  esp, ebp
     pop  ebp
     ret  36
WriteVal ENDP


;-----------------------------------------------------------------
;                        Farewell PROCEDURE
;-----------------------------------------------------------------
;Pre-Conditions: Must push the farewell text string to the stack.

;Post-Conditions: Text displayed on screen via console.

;Registers Affected: edx, ebp, esp

;Description: Displays a farewell message on the screen.

;Parameters: (+8) farewell text ref.
Farewell PROC
     push ebp
     mov ebp, esp

     mov edx, [ebp + 8]
     call WriteString

     pop ebp
     ret 4
Farewell ENDP

END main