;
; AssemblerApplication1.asm
;
; Created: 01/12/2021 21:37:50
; Author : TanoW
;

.org	0x0024
	rjmp	rx_int

.org	0x0000

setup:
	; Inicializo TX y RX
	.equ	baud	=	9600				;baudrate
	.equ	F_CPU	=	16000000
	.equ	bps		=	(F_CPU/16/baud) - 1	;baud prescale
	ldi		r28,	LOW(bps)
	ldi		r29,	HIGH(bps)
	sts		UBRR0L,	r28
	sts		UBRR0H,	r29
	ldi		r28,	(1<<RXEN0)|(1<<RXCIE0)	;|(1<<RXEN0)	;RX y TX enabled
	sts		UCSR0B,	r28

; Replace with your application code
start:
    inc r16
    rjmp start

rx_int:
	nop
	reti