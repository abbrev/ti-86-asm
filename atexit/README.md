atexit
======

Copyright 2005, 2006 Chris Williams.

Email: abbrev@gmail.com

How to Use the Functions
------------------------

atexit.asm comes with three subroutines of interest:  exit, \_Exit, and
atexit. Each of these is identical to the C version of the same name,
except as noted.

### exit

This function exits the program after calling each of the functions
that were registered with 'atexit'. The functions are called in reverse
order from the order in which they were registered. 'exit' takes the
exit status of the program in the 'HL' register pair. (The status is
ignored in this version because TI-OS doesn't care about it).

### \_Exit

This function exits the program. It does not call any of the functions
that were registered with 'atexit'. '\_Exit' takes the exit status of
the program in the 'HL' register pair. (see 'exit' above).

### atexit

This function registers a function to call when the program calls 'exit'
or simply returns from the main function. 'atexit' takes the address of
the function in the 'HL' register pair. If 'atexit' could not register
a function, it returns with the carry flag set. Otherwise the carry flag
is clear.

How to Use atexit.asm
---------------------

To use atexit.asm in a program, include the file in your program
immediately following the "org $D748" or "org \_asm\_exec\_ram" statement
and before any other code. The code in atexit.asm must be run first
or almost first in the program (you can put other initialisation code
before atexit.asm). Either way, the stack pointer should be as given to
the program from TI-OS.

You must also define a "main" label somewhere in your code; it does not
need to be at or even near the beginning of the program. This will be
the starting point of your application.

Size
====

atexit.asm uses $36 bytes of code, $05 bytes of RAM for variables,
and at least $42 bytes of stack space (this can be changed with the
ATEXIT\_MAX equate). The variables can be moved to anywhere in RAM,
such as to reduce program size.

License
-------

Copyright 2005, 2006 Chris Williams.

This library is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this library; if not, write to the Free Software Foundation,
Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
