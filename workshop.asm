	org	$1200
	
irq_start:
	lda	$ff02
	bne	irq_end

	nop
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


main:
	nop

	jmp	main
	rts

	end	start