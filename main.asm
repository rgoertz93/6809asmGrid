vpstr	equ	$1400	;top left of screen
vpend	equ	$2c00	;bottom right of screen
crdmem	equ	$e00	;memory location for coord calculation
start	org	$1200
	ldu	#$f00	;user stack location
	bsr	initv
	bsr	vpclr
	bsr	vert
	bsr	horiz
	lda	#33	;x
	ldb	#3	;y
	pshu	a
	pshu	b
	bsr	drwpxl
	lda	#35	;x
	ldb	#25	;y
	pshu	a
	pshu	b
	bsr	drwpxl
	lda	#37	;x
	ldb	#38	;y
	pshu	a
	pshu	b
	bsr	drwpxl		
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

drwpxl	pulu	a	;pull the y coord from the stack
	tfr	a,b
	lslb
	lslb
	lslb
	lslb
	lslb
	lsra
	lsra
	lsra
	std	crdmem+4	;store the y offset
	bsr	xcoord	;calculate the x coordinate
	pulu	a	;This is the bit position for the pixel
	sta	crdmem+6
	lda	#0
	pulu	b	;xcoord
	addd	crdmem+4
	ldx	#vpstr
	leax	d,x
	lda	crdmem+6
	ora	,x
	sta	,x
	rts
	
xcoord	pulu	b	;Original x coordinate
	stb	crdmem	;store it in 0xe00
	lda	#1	
div	subb	#8	;subtract 8 from b	
	cmpb	#8	;compare to 8
	bgt	incr	;if b > 8 then increment a
	pshu	a	;store the remainder in the stack
	lsla
	lsla
	lsla		;multiply by 8
	sta	crdmem+2	;store in 0xe02
	ldb	crdmem	;load the original coordinate
	subb	crdmem+2	;sub the original coordinate from the calculated
	ldx	#table  ;load the table data and look up the bit position
	abx
	lda	,x
	pshu	a	;store it in the user stack
	rts
incr	inca
	jmp	div

table	fcb	0,128,64,32,16,8,2,1

	end	start
