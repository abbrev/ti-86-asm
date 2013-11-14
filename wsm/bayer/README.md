bayer.asm
=========

Christopher Williams

Email: abbrev@gmail.com

Introduction
------------

Dithering is used commonly when a grayscale image is to be displayed on a
monochrome screen, such as the LCD of the TI-86. Of course, you could just use
grayscale on the calculator to display an image, but where's the fun in that?
:-P

How to Use the "bayerdither" Routine
------------------------------------

Using the bayerdither routine is brain-dead simple. Load the coordinates of a
point in B and C (row and column, respectively) and its gray value in A (0 =
black, 255 = white), and then call bayerdither. It returns whether the pixel is
on or not. Carry is set when that pixel is set or on. How much simpler can it
get?

You can also look inside bayer.asm to see the inputs and outputs of the routine
or even to see how it works. If you can improve it, please send them to me!

Other Considerations
--------------------

This routine is written in the syntax for the very good *FREE* tpasm assembler
(http://www.sqrt.com) (you'll even find my name in the credits :). If you want
it for a lesser assembler <cough>TASM</cough> you'll have to tweak it yourself.
For example, you may need to change the "align" directives (I'm not sure if
TASM supports align). "align X" translates to "org ($+X-1)&~(X-1)" or something
similar.

This routine is faster than any find pixel routine, at only 70 cycles, so it's
fairly fast. In the previous version, it took between 121 and 129 cycles,
depending on memory usage. I changed the whole algorithm to make it over 40%
faster. There might still be some possible optimizations that I don't see, so
if you find one, let me know!

License
-------

This routine is Copyright 2006 Christopher Williams. However, I grant
permission for anyone to use it however they want. I would appreciate feedback,
though.
