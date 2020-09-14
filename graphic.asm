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

vpclr	ldx	#vpstr
	lda	#0
vpclp	sta	,x+
	cmpx	#vpend
	blo	vpclp
	rts

draw	lda	#$aa
	ldx	#$1530
loop2	sta	,x+
	cmpx	#$1531
	blo	loop2
	rts
	
	end	start
