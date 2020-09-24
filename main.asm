vpstr	equ	$1400	;top left of screen
vpend	equ	$2c00	;bottom right of screen
	org	$1200
start	bsr	initv
	bsr	vpclr
	bsr	vert
	bsr	horiz
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
	stb	$30
	lda	#1
div	subb	#8		
	cmpb	#8
	bgt	incr
	lsla
	lsla
	lsla
	sta	$38
	ldb	$30
	subb	$38
	ldx	#table
	abx
	ldb	,x
	nop
incr	inca
	jmp	div

table	fcb	0,128,64,32,16,8,2,1

	end	start
