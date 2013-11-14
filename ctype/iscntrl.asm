; FIXME: could this be smaller?
iscntrl:
	cp	32
	jr	nc,.notcntrl
	cp	a
	ret
.notcntrl
	or	a
	ret
