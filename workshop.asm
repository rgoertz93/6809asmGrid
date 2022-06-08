	org	$1200

pagmem	equ	$e10	;memory location for the page pointers
pagind	equ	$e20	;memory location for the page index/reference
	
irq_start:
	lda	$ff02
	bne	irq_end

	lda	pagind
	tsta
	lbeq	page1
	lbne	page2
irq_end:
	rti	

start:
	lda	#1	;begin set mhz
	sta	$ffd9	;end set mhz
	ldu	#$f00	;user stack location

	orcc	#$50	;disable firq and irqs
	lda	$ff01
	anda	#$fe	;disable hsync
	sta	$ff01	;save settings
	lda	$ff03	;vsync address
	ora	#$01	;set enable bit
	sta	$ff03	;enable vsync
	lda	$ff02	;signal the system

	lda	#$7e	*load jump instruction opcode
	sta	$10c	*store it at IRQ jump address
	ldx	#irq_start	*load x with pointer to irq routine
	stx	$10d	*store the new IRQ address location

	andcc	#$ef	*enable irq
	lda	$ff02	*signal the system

	lda	#0	
	sta	pagind	*store 0 in the page index
	lbsr	initv	*initialize the video
main	lda	pagind
	tsta
	lbeq	inip1
	lbne	inip2
main1	jsr	vpclr
	ldx	pagmem

	lda	#$aa
	ldx	#$1530

main2	nop
	lda	pagind
	tsta
	beq	#set_page2
	bne	#set_page1	
loop1	jmp	main
	rts

set_page1:
	lda	#0
	sta	pagind	
	jmp	loop1

set_page2:
	lda	#1
	sta	pagind	
	jmp	loop1

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
	rts

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
	rts	

vpclr	ldd	#0	;this clears the screen
	ldx	pagmem
vpclp	std	,x++	
	cmpx	pagmem+2
	blo	vpclp
	rts

	end	start
