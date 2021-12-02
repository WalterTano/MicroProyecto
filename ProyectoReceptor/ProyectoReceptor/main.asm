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
	;configuro los puertos:
;	PB2 PB3 PB4 PB5	- son los LEDs del shield
;	PB0 es SD (serial data) para el display 7seg
;	PD7 es SCLK, el reloj de los shift registers del display 7seg
;	PD4 es LCH, transfiere los datos que ya ingresaron en serie, a la salida del registro paralelo 
;   PC son entradas para los botones
    ldi		r20,	0b00111101	
	out		0x04,	r20			;4 LEDs del shield son salidas
	out		0x05,	r20			;apago los LEDs
	ldi		r20,	0b00000000	
	out		0x07,	r20			;3 botones del shield son entradas
	ldi		r20,	0b10010000	
	out		0x0A,	r20			;configuro PD.4 y PD.7 como salidas
	cbi		0x0B,	7			;PD.7 a 0, es el reloj serial, inicializo a 0
	cbi		0x0B,	4			;PD.4 a 0, es el reloj del latch, inicializo a 0
	ldi		r19,	0b00010000
apagar:		; apaga todo el display de 7 segmentos
	ldi		r18,0
	ldi		r19,0b00000000
	call	sacanum
	ldi		r18,	0
	ldi		r19,	0
	;ldi		r21,	0
	;ldi		r22,	0
	;ldi		r23,	0
	;ldi		r24,	0

.org	0x0060

main:
	nop
	rjmp main

; Replace with your application code
;primer_num:
;	lds		r21,	UDR0
;	mov		r18,	r21
;	ldi		r19,	0b00010000
;	call	sacanum
;	lds		r22,	UDR0
;	cp		r22,	r21
;	breq	primer_num
;segundo_num:
;	mov		r18,	r22
;	ldi		r19,	0b00100000
;	call	sacanum
;	lds		r23,	UDR0
;	cp		r22,	r23
;	breq	segundo_num
;tercer_num:
;	mov		r18,	r23
;	ldi		r19,	0b01000000
;	call	sacanum
;	lds		r24,	UDR0
;	cp		r23,	r24
;	breq	tercer_num
;cuarto_num:
;	mov		r18,	r24
;	ldi		r19,	0b10000000
;	call	sacanum
;	lds		r21,	UDR0
;	cp		r24,	r21
;	breq	cuarto_num
;   rjmp	primer_num

sacanum: 
	cpi r18, 0
	brne sacanum_1
	ldi r18, 0b00000011
	rjmp sacanum_fin
sacanum_1:
	cpi r18, 1
	brne sacanum_2
	ldi r18, 0b10011111
	rjmp sacanum_fin
sacanum_2:
	cpi r18, 2
	brne sacanum_3
	ldi r18, 0b00100101
	rjmp sacanum_fin
sacanum_3:
	cpi r18, 3
	brne sacanum_4
	ldi r18, 0b00001101
	rjmp sacanum_fin
sacanum_4:
	cpi r18, 4
	brne sacanum_5
	ldi r18, 0b10011001
	rjmp sacanum_fin
sacanum_5:
	cpi r18, 5
	brne sacanum_6
	ldi r18, 0b01001001
	rjmp sacanum_fin
sacanum_6:
	cpi r18, 6
	brne sacanum_7
	ldi r18, 0b01000001
	rjmp sacanum_fin
sacanum_7:
	cpi r18, 7
	brne sacanum_8
	ldi r18, 0b00011111
	rjmp sacanum_fin
sacanum_8:
	cpi r18, 8
	brne sacanum_9
	ldi r18, 0b00000001
	rjmp sacanum_fin
sacanum_9:
	cpi	r18, 9
	brne sacanum_A
	ldi r18, 0b00001001
	rjmp sacanum_fin
sacanum_A:
	cpi	r18, 10
	brne sacanum_B
	ldi r18, 0b00010001
	rjmp sacanum_fin
sacanum_B:
	cpi	r18, 11
	brne sacanum_C 
	ldi r18, 0b11000001
	rjmp sacanum_fin
sacanum_C:
	cpi	r18, 12
	brne sacanum_D
	ldi r18, 0b01100011
	rjmp sacanum_fin
sacanum_D:
	cpi	r18, 13
	brne sacanum_E
	ldi r18, 0b10000101
	rjmp sacanum_fin
sacanum_E:
	cpi	r18, 14
	brne sacanum_F
	ldi r18, 0b01100001
	rjmp sacanum_fin
sacanum_F:
	ldi r18, 0b01110001

sacanum_fin:
	call	dato_serie
	mov		r18, r19
	call	dato_serie
	sbi		0x0B, 4		;PD.4 a 1, es LCH el reloj del latch
	cbi		0x0B, 4		;PD.4 a 0, 
	ret
	
	;Voy a sacar un byte por el 7seg
dato_serie:
	ldi		r20, 0x08		; lo utilizo para contar 8 (8 bits)
loop_dato1:
	cbi		0x0B, 7			;SCLK = 0 reloj en 0
	lsr		r18				;roto a la derecha r18 y el bit 0 se pone en el C
	brcs	loop_dato2		;salta si C=1
	cbi		0x05, 0			;SD = 0 escribo un 0 
	rjmp	loop_dato3
loop_dato2:
	sbi		0x05, 0			;SD = 1 escribo un 1
loop_dato3:
	sbi		0x0B, 7			;SCLK = 1 reloj en 1
	dec		r20
	brne	loop_dato1		;cuando r20 llega a 0 corta y vuelve
	ret

rx_int:
	cpi		r18,	0
	brne	rx_r19
	lds		r18,	UDR0
	cpi		r18,	0
	breq	rx_int_out
rx_r19:
	lds		r19,	UDR0
	cpi		r19,	0
	breq	rx_int_out
	call	sacanum
	ldi		r18,	0
	ldi		r19,	0
rx_int_out:
	reti