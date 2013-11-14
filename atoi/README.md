atoi
====

by Chris Williams <abbrev@gmail.com>

Introduction
------------

I could not find a good routine to convert a string to an integer, so I
implemented atoi. atoi is a standard C function that converts a null-terminated
string to an integer. It simply takes a string and returns its integer
equivalent.

This implementation differs from C only in the argument-passing method.

How to Use atoi
---------------

First, you must include the file atoi.asm in your program.

Load the address of the null-terminated string into HL, then call atoi. The
converted value is in HL. If the number is outside the range -32768..32767 (or
0..65535 for unsigned values), then the value will silently overflow; this is
not a bug - it's a feature!

That's all there is to it.

History
-------

2004-11-10	Made it faster and smaller by inlining the ctype functions

2004-05-12	Released the first version

More Information
----------------

For more information on this function, see man 3 atoi, unless you're stuck with
a non-\*nix box like DOS (Windows).
