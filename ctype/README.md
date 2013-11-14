ctype
=====

Chris Williams <abbrev@gmail.com>

Introduction
------------

These are character classification routines. They are standard C functions and
differ only in argument-passing and return-value mechanisms. Each function,
where applicable, assumes the "C" or "POSIX" locale, such as for alphabetic
characters. For other locales, you must change each function which depends on
locale.

The Functions
-------------

Here is a list of the character classification functions and the classes of
characters for which each function tests:

* isalnum - alpha-numeric (A-Z, a-z, 0-9)
* isalpha - alphabetic (A-Z, a-z)
* isascii - ASCII (7-bit)
* isblank - blank (space and tab)
* iscntrl - control (0-31)
* isdigit - digit (0-9)
* isgraph - printable, except space
* islower - lower-case alphabetic (a-z)
* isprint - printable, including space
* ispunct - non-space, non-alpha-numeric printable
* isspace - space (' ', '\f', '\n', '\r', '\t', '\v')
* isupper - upper-case alphabetic (A-Z)
* isxdigit - hexadecimal digit (0-9, A-F, a-f)

How to Use the Functions
------------------------

First, each respective assembly file must be included in the program.

Load the character to test into A, then call the function for the class you
wish to test. The functions set the zero flag (Z) if the character falls into
the class and clears the zero flag otherwise. Only the flag register is
affected.

History
-------

2004-11-10	Fixed (hopefully) and shortened some of the routines

2004-05-12	Released the first version

Permitted Use
-------------

Use these functions as you wish. I would appreciate feedback, though.
