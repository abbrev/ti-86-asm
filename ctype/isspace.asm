isspace:
	cp	' '
	ret	z
	cp	'\f'
	ret	z
	cp	'\n'
	ret	z
	cp	'\r'
	ret	z
	cp	'\t'
	ret	z
	cp	'\v'
	ret
