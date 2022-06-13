	org	$1200

pagmem	equ	$e10	;memory location for the page pointers	
pagind	equ	$e20	;memory location for the page index
sqrind	equ	$e30	;memory location for the start index of the square
	
irq_start:
	lda	$ff02
	bne	irq_end

	lda	pagind	*load the page index
	tsta
	lbeq	set_page_1	*set the first page
	lbne	set_page_2	*set the second page
irq_end:
	rti	

start:
	*Start the vsync setup
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
	*End the vsync setup

	lda	#0
	sta	pagind
	lbsr	init_video

* MAIN LOOP
main:
	lda	pagind	*load the page index
	tsta
	lbeq	init_page1	*init the first page
	lbne	init_page2	*init the second page

main1:
	jsr	clear_page	*clear the page
	jsr	draw_square

	lda	pagind		*load the page index
	tsta
	lbeq	switch_to_page_1	*switch to the first page
	lbne	switch_to_page_2	*switch to the second page

main2:
	jmp	main
	rts

* END MAIN LOOP

init_video:
	lda	#$f0	;sets to color and graphics mode 6c
	sta	$ff22	;at 256 x 192 resolution
	sta	$ffc3	;graphics pages start at 0x1400
	sta	$ffc5
	rts

	*Setup the start and end memory addresses for the first page
init_page1:
	ldd	#$1400
	std	pagmem
	ldd	#$2c00
	std	pagmem+2
	jmp	main1

	*Setup the start and end memory addresses for the second page
init_page2:
	ldd	#$2c00
	std	pagmem
	ldd	#$4400
	std	pagmem+2
	jmp	main1

clear_page:
	ldd	#0	;this clears the screen
	ldx	pagmem
vpclp	std	,x++
	cmpx	pagmem+2
	blo	vpclp
	rts	

draw_square:
	lda	#$ff
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

set_page_1:
	sta	$ffce	;clear page 2
	sta	$ffca	;clear page 2
	sta	$ffc8	;clear page 2
	sta	$ffcd
	sta	$ffc9	
	jmp	irq_end

set_page_2:
	sta	$ffcc	;clear page 2
	sta	$ffc8	;clear page 2
	sta	$ffcf
	sta	$ffcb
	sta	$ffc9
	jmp	irq_end

switch_to_page_1:
	lda	#0
	sta	pagind
	jmp	main2

switch_to_page_2:
	lda	#1
	sta	pagind
	jmp	main2

	end	start