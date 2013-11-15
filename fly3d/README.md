Fly 3D!
=======

Copyright 2002 Chris Williams (abbrev@gmail.com)

30 Aug 2002

How to run
----------

Send the file fly3d.86p to your calculator. Run it by typing Asm(fly3d or run it
through a shell. Enjoy. Or else.

About
-----

This is just a small demo to show the capabilities of my rotation functions and
how to do 3D graphics on a calculator. I will be using these functions in a
full-screen helicopter simulation game. It will feature smooth *true 3D*
graphics and near-true helicopter physics.

Some technical stuff (you can skip this)
----------------------------------------

This program draws the screen by iterating through each of the 32 by 24 pixels
and determines if the ground is visible at each point. It is somewhat like a
raytracer but much simpler. At full screen (128 x 64), the framerate was around
one per second, so that's why I reduced it to 32 x 24 pixels. At its current
size, it gets about 4 FPS, which I think is acceptable for this silly demo,
especially since it takes only 928 bytes on a TI-86!

My upcoming helicopter simulation will work quite differently. It will compute
the screen location of several points and connect them with lines. Hopefully,
given a small number of objects (tanks, trees, horizon, etc.) to draw, the game
will have a reasonably high frame rate.

Credits
-------

- Me
- You for downloading this silly program
- Me
- Dan Eble for his fast 8-bit multiply function (MUL\_AxL)
- Me
- TI for nice calculators <cough>TI-86</cough>
- Me
- Alan Bailey et al for Prgm86
- Me
- Anyone whose literature and programs on 3D transformations I've studied, 
  and last, but certainly not least,
- Me!

(Note from 2013: wow, I was kind of narcissistic back in 2002!)
