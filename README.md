# ASM+ for DCPU

ASM+ is an assembly-like programming language for the DCPU-16. It currently
supports functions without arguments and printing, but will eventually support
variables, argument passing, conditionals, loops, etc.

Here's the obligatory "Hello, world" example:

```
FUNC main
  PRINT "Hello, world"
ENDFUNC
```

Compile the program like this:

    $ ruby -Ilib bin/dcc-compile < source_file

Assembly is printed to STDOUT. Run with your favourite emulator.

## Syntax

* Indentation is optional
* One statement per line
* A statement is an uppercase keyword followed by optional arguments
* Available keywords:
  * `FUNC`    --  Create a function. Takes one argument, the function name
  * `ENDFUNC` --  End the function body. Takes no arguments. Each `FUNC` must
                  have a matching `ENDFUNC`.
  * `PRINT`   --  Print a string. Takes one argument, the string to print.
  * `CALL`    --  Call a function. Takes one argument, the function name of
                  the function to call.

## Coming soon...

* Variables
* Passing arguments
* Return values
* Conditionals
* Loops