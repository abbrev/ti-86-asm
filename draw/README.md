Draw
====

This is demo drawing program that uses the small mouse library that I wrote.
This drawing program is very minimal: drawing and erasing.

The mouse library adds mouse and key events to a single queue that can be
polled by an application. The mouse library also supports event-driven
applications via a callback routine provided by the application. An application
can use one of the built-in cursors or provide its own cursors, which is the
case with this drawing application.

This program was written for the tpasm assembler. I know that it builds with
version 1.2 but not with version 1.6 (this later version handles local labels
differently). This should be easily fixable, though.

