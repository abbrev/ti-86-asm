World Sunlight Map
==================

Author: Christopher Williams

Email: abbrev@gmail.com

Introduction
------------

A World Sunlight Map shows the illumination of the sun at a given time on a map
of the Earth. The position of the sun (and therefore the position of the
illumination) depends on the time and day of year.

This program shows a World sunlight map using Bayer dithering (sorry, no
grayscale) for gray values. It can display any time and day of year and can
render the image in under 2 seconds.

How to Use the Program
----------------------

Send the wsm.86p file to your calculator, then run it with "Asm(wsm)".

Select the month, day, and hour using the menus. Press ENTER or 2ND to select
each of them. The date and time are in UTC, which is the same as GMT. You can
go back in the menus by pressing EXIT, and you can exit the program by pressing
CLEAR.

How the Program Works
---------------------

While the exact implementation differs slightly for performance reasons, here
is how the program works.

The program iterates through each pixel and determines whether it is
illuminated by the sun (and how much), and it puts the amount of illumination
at that pixel (ranging from 50% for unlit to 100% for full sunlight).

To determine how much illumination a point gets, the program finds the (x,y,z)
coordinates (vector length of 1) of the sun and of each point on Earth and uses
the dot product of the sun vector and the earth vector to find the cosine of
the angle between the two vectors times the product of the magnitudes of the
vectors. Since the vectors have lengths of 1, we divide by (1 * 1), so we don't
have to divide at all (convenient, eh?). The cosine of the angle ranges from
1.0 when the vectors are equal to -1.0 when the vectors point in opposite
directions.

If the cosine is greater than 0, the earth vector and the sun vector are within
90 degrees, and thus that point on earth is lit by the sun. The *amount* of
sunlight a point gets is simply the same as the cosine value we just computed,
ranging from 0 for no sunlight to 1 for full sunlight.

If the point is unlit, it just becomes 50% gray (why 50%? Why not?). From the
value of 0 to 1, we divide by two and add 0.5, so it ranges from 50% to 100%,
and put that value on the screen.

It's not rocket science. It's only analytic gemometry!

How the Program *Really* Works
------------------------------

The actual implementation differs only in detail. In the description above, the
program would need to multiply values 5 times per pixel. It actually multiplies
only 2 times per pixel because I moved unchanging values around.

One unchanging value I moved was the product of the Z components of the earth
and sun vectors. This value changes only once per row, so I moved it so it's
multiplied once at the start of each row.

The other two multiplies disappeared when I set the sun at 0 degrees longitude
and shifted the earth's longitude to compensate. This causes the Y component of
the sun vector to become 0 for any angle of longitude. Any multiplication with
0 is always 0, so the multiply was replaced with 0 (actually, it was completely
removed). The other operand in that multiplication was also removed, so its
value does not need to be computed either. There goes the second of these
multiplications.

Acknowledgments
---------------

* Texas Instruments, for great calculators (TI-86, 89, and 92+, of course!).
* Matthew Shepcar, for his fast signed 8-bit multiplication routine.
