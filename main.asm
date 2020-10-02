vpstr	equ	$1400	;top left of screen
vpend	equ	$2c00	;bottom right of screen
start	org	$1200
	ldu	#$e30
	bsr	initv
	bsr	vpclr
	bsr	vert
	bsr	horiz
	lda	#3
	lsla
	lsla
	lsla
	lsla
	lsla
	sta	$e04	;ycoord
btx	bsr	xcoord
	pulu	a
	pulu	b	;xcoord
	addb	$e04
	ldx	#vpstr
	leax	b,x
	sta	,x
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
	
xcoord	ldb	#33	;Original x coordinate
	stb	$e00	;store it in 0xe00
	lda	#1	
div	subb	#8	;subtract 8 from b	
	cmpb	#8	;compare to 8
	bgt	incr	;if b > 8 then increment a
	pshu	a	;store the remainder in the stack
	lsla
	lsla
	lsla		;multiply by 8
	sta	$e02	;store in 0xe02
	ldb	$e00	;load the original coordinate
	subb	$e02	;sub the original coordinate from the calculated
	ldx	#table  ;load the table data and look up the bit position
	abx
	lda	,x
	pshu	a	;store it in the user stack
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
