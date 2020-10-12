vpstr	equ	$1400	;top left of screen
vpend	equ	$2c00	;bottom right of screen
crdmem	equ	$e00	;memory location for coord calculation
start	org	$1200
	ldu	#$f00	;user stack location
	bsr	initv
	bsr	vpclr
	bsr	vert
	bsr	horiz
	ldx	#vpstr
	lda	#33	;x coord
	ldb	#3	;y coord
	pshu	a
	pshu	a
	pshu	b
	bsr	offset	
	jsr	drwpxl			
loop1	jmp	loop1
	rts

initv	lda	#$f0	;sets to color and graphics mode 6c
	sta	$ff22	;at 256 x 192 resolution
	sta	$ffc3	;graphics pages start at 0x1400
	sta	$ffc5
	sta	$ffcd
	sta	$ffc9
	rts

vpclr	ldd	#0	;this clears the screen
	ldx	#vpstr
vpclp	std	,x++	
	cmpx	#vpend
	blo	vpclp
	rts

vert	ldd	#$101	;draws the vertical lines
	ldx	#vpstr
loop2	std	,x++
	cmpx	#vpend
	blo	loop2
	rts

horiz	ldd	#$ffff ;draws the horizontal lines
	ldx	#vpstr
outer	ldy	#$0
inner	std	,x++
	leay	+1,y
	cmpy	#$10
	blo	inner
	leax	+224,x
	cmpx	#vpend
	blo	outer
	rts

offset	pulu	a	;pull the y coord from the stack
	tfr	a,b	;copy the contents of a into b
	lslb		;begin multiply by 32
	lslb
	lslb
	lslb
	lslb
	lsra
	lsra
	lsra		;end multiply by 32
	leax	d,x	;add the y offset to the x register

	pulu	a	;pull the x coord from the stack
	ldb	#1	;this is the remainder
div1	suba	#8	;integer division through subtraction
	cmpa	#8
	bgt	incr1
	lda	#0
	leax	d,x	;add the x offset to the x register
	rts
incr1	incb
	jmp	div1

drwsqr	lda	#$ff
	sta	,x
	leax	32,x
	sta	,x
	leax	32,x
	sta	,x
	leax	32,x
	sta	,x
	leax	32,x
	sta	,x
	leax	32,x
	sta	,x	
	leax	32,x
	sta	,x
	rts

drwpxl	lslb
	lslb
	lslb	;muliply the remainder by 8
	stb	crdmem
	pulu	b
	subb	crdmem
	ldy	#table  ;load the table data and look up the bit position
	leay	b,y
	lda	,y
	ora	,x
	sta	,x
	rts

table	fcb	0,128,64,32,16,8,2,1

	end	start
