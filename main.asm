vpstr	equ	$1400
vpend	equ	$2c00
	org	$1200
start	bsr	initv
	bsr	vpclr
	bsr	draw
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

draw	ldd	#$101
	ldx	#vpstr
loop2	std	,x++
	cmpx	#vpend
	blo	loop2
	rts
	
	end	start
