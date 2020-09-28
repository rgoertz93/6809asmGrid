vpstr	equ	$1400	;top left of screen
vpend	equ	$2c00	;bottom right of screen
start	nop
	ldu	#$e30
	bsr	initv
	bsr	vpclr
	bsr	vert
	bsr	horiz
btx	bsr	xcoord
	pulu	a
	pulu	a
	pulu	b
	nop
	nop
loop1	jmp	loop1
	rts

initv	lda	#$f0	;sets to color and graphics mode 6c
	sta	$ff22	;at 256 x 192 resolution
	sta	$ffc3
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
	
xcoord	ldb	#33
	stb	$e00
	lda	#1
div	subb	#8		
	cmpb	#8
	bgt	incr
	pshu	a
	lsla
	lsla
	lsla
	sta	$e02
	ldb	$e00
	subb	$e02
	ldx	#table
	abx
	pshu	x
	rts
incr	inca
	jmp	div

table	fcb	0
	fcb	128
	fcb	64
	fcb	32
	fcb	16
	fcb	8
	fcb	2
	fcb	1

	end	start
