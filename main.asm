crdmem	equ	$e00	;memory location for coord calculation
pagmem	equ	$e10	;memory location for the page pointers
pagind	equ	$e20	;memory location for the page index
sqrind	equ	$e30	;memory location for the start index of the square
start	org	$1200
	lda	#1
	sta	$ffd9
	ldu	#$f00	;user stack location
	lda	$ff03
	ora	#$01
	sta	$ff03
	lda	#0
	sta	pagind
	lbsr	initv
	ldd	#$20
	std	sqrind
main	lda	pagind
	tsta
	lbeq	inip1
	lbne	inip2
main1	jsr	vpclr
	jsr	vert
	jsr	horiz
	ldx	pagmem
	ldd	sqrind
	leax	d,x
	jsr	drwsqr

	* Wait for the vsync irq to complete
vsync	lda	$ff02
vwait	lda	$ff03
	bpl	vwait
	* The vsync irq has completed

	*Test for the right keypress	
	lda	#%10111111
	sta	$ff02
	lda	$ff00
	cmpa	#$f7
	beq	right

	*Test for the left keypress
	lda	#%11011111
	sta	$ff02
	lda	$ff00	
	cmpa	#$f7
	beq	left

	*Test for the down keypress
	lda	#%11101111
	sta	$ff02
	lda	$ff00	
	cmpa	#$f7
	beq	down

	*Test for the up keypress
	lda	#%11110111
	sta	$ff02
	lda	$ff00	
	cmpa	#$f7
	beq	up		
ok	lda	pagind
	tsta
	beq	page1
	bne	page2	
main2	nop
loop1	jmp	main
	rts

	*Process the right keypress
right	ldd	sqrind
	addd	#1
	std	sqrind
	jmp	ok

	*Process the left keypress
left	ldd	sqrind
	subd	#1
	std	sqrind
	jmp	ok	

	*Process the down keypress
down	ldd	sqrind
	addd	#256
	std	sqrind
	jmp	ok

	*Process the up keypress
up	ldd	sqrind
	subd	#256
	std	sqrind
	jmp	ok

initv	lda	#$f0	;sets to color and graphics mode 6c
	sta	$ff22	;at 256 x 192 resolution
	sta	$ffc3	;graphics pages start at 0x1400
	sta	$ffc5
	rts

inip1	ldd	#$1400
	std	pagmem
	ldd	#$2c00
	std	pagmem+2
	jmp	main1

page1	sta	$ffce	;clear page 2
	sta	$ffca	;clear page 2
	sta	$ffc8	;clear page 2
	sta	$ffcd
	sta	$ffc9	
	lda	#1
	sta	pagind
	jmp	main2

inip2	ldd	#$2c00
	std	pagmem
	ldd	#$4400
	std	pagmem+2
	jmp	main1

page2	sta	$ffcc	;clear page 2
	sta	$ffc8	;clear page 2
	sta	$ffcf
	sta	$ffcb
	sta	$ffc9
	lda	#0
	sta	pagind
	jmp	main2	

vpclr	ldd	#0	;this clears the screen
	ldx	pagmem
vpclp	std	,x++	
	cmpx	pagmem+2
	blo	vpclp
	rts

vert	ldd	#$101	;draws the vertical lines
	ldx	pagmem
loop2	std	,x++
	cmpx	pagmem+2
	blo	loop2
	rts

horiz	ldd	#$ffff ;draws the horizontal lines
	ldx	pagmem
outer	ldy	#$0
inner	std	,x++
	leay	+1,y
	cmpy	#$10
	blo	inner
	leax	+224,x
	cmpx	pagmem+2
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

drwpxl	bsr	offset
	lslb
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
