vpstr	equ	$1400
vpend	equ	$2c00
	org	$1200
start	bsr	initv
	bsr	vpclr
	bsr	vert
	bsr	horiz
loop1	jmp	loop1
	rts

initv	lda	#$f0
	sta	$ff22
	sta	$ffc3
	sta	$ffc5
	sta	$ffcd
	sta	$ffc9
	rts

vpclr	ldd	#0	Clear the screen
	ldx	#vpstr	Load the start address
vpclp	std	,x++	
	cmpx	#vpend
	blo	vpclp
	rts

vert	ldd	#$101	Set the vertical lines
	ldx	#vpstr
loop2	std	,x++
	cmpx	#vpend
	blo	loop2
	rts

horiz	ldd	#$ffff	Set the horizontal lines
	ldx	#vpstr
outer	ldy	#$0
inner	std	,x++
	leax	1,y
	cmpy	#$8
	blo	inner
	leax	20,x
	cmpx	#vpend
	blo	outer
	rts	
	
	end	start
