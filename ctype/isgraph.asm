isgraph:
	cp	33
	ret	c
	cp	128
	jr	nc,.notgraph
	cp	a	; set the zero flag
	ret
.notgraph
	or	a	; clear zero flag
	ret
