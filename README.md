<h1 align="center">Low Level I/O Procedures</h1>

<p align="center">This program asks for a signed number and takes in a string of user input. It then validates the input and stores it in a memory location. This is repeated 10 times. The program then displays the list of valid numbers entered, the sum of valid numbers, and the truncated average of valid numbers</p>


## About

In this project, I used MASM to write an IA-32 assembly program that takes user input as a string, converts the string to numeric form, performs mathematical operations on those numeric values, converts the results of those operations back to a string, and prints the string to output. This was done using custom macros and procedures. The Irvine32 library was used sparingly.

## Goals and Requirements

The purpose of this assignment is to showcase my ability to design, implement, and call low-level I/O prodecures, as was as implement and use macros. 

### The description the program is as follows:
* Implement and test two **macros** for string processing. These macros should use Irvine's `ReadString` to get input from the user, and `WriteString` to display output.
    * `mGetString`: Display a prompt, then get the user's keyboard input into a memory location.
    * `mDisplayString`: Print the string which is stored in a specified memory location
* Implement and test two **procedures** for signed integers which use string primitve instructions
    * `ReadVal`:
        1. Invoke `mGetString` to get user input in the form of a string of digits
        2. Convert, using string primitives, the string of ASCII digits to its numeric value representation, validating if the user's input
        3. Store this value in a memory variable
    * `WriteVal`:
        1. Convert a numeric value to a string of ASCII digits
        2. Invoke `mDisplayString` to print the ASCII representation of the value to output
* Write a test program which uses the `ReadVal` and `WriteVal` procedures to:
    1. Get 10 valid integers from the user
    2. Store these numeric values in an array
    3. Display the integers, their sum, and their truncated average

### The requirements of the program are as follows:
* User's numeric input must be validated manually
    * Input must be read as a string and converted to numeric form
    * If the user enters non-digits other than an indication of sign (+/-), an empty string, or the number is too large for 32-bit registers, an error message is displayed and the number discarded
* `ReadInt`, `ReadDec`, `WriteInt`, and `WriteDec` are **not allowed** in this program
* Conversion routines must appropriately use the `LODSB` and/or `STOSB` operators for dealing with strings
* All procedure parameters must be passed on the runtime stack using the **STDCall** calling convention, and strings must be passed by reference
* Prompts, indentifying strings, and other memory locations must be passed by address to the macros
* Used registers must be saved and restored by the called procedures and macros
* The stack frame must be cleaned up by the **called** procedure
* Procedures must not reference data segment variables by name (aside from `main`)
* The program must use _Register Indirect_ addressing for integer array elements, and _Base + Offset_ addressing for accessing parameters on the runtime stack

## What I Learned

## Installation

1. 
2.
3.
4.

## Contributions

## Project Status

## Credits

