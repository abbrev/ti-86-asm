wsm.86p: wsm.asm atexit.asm mult.asm menu.asm compress/compress.asm \
         bayer/bayer.asm feumult.asm sincos.asm earth.gfx menus.data
	mk86asm.sh "$<"

%.gfx: %.pgm
	pgmtopbm "$<" | tail -c 1024 | compress/compressfile | xxd -p -c 1 | \
	for ((r=0;;++r)); do \
		echo -n "	db "; \
		for ((c=0;c<16;++c)); do \
			read n || break 2; \
			echo -n "\$$$$n,"; \
			done; \
		echo; \
	done | sed 's/,$$//' >"$@"
