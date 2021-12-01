;
; ProyectoFinal.asm
;
; Created: 16/11/2021 18:26:34
; Author : TanoW
;

.DSEG
	num:	.byte 512
.CSEG

.org 0x0000

setup:
	; Inicializo TX y RX
	.equ	baud	=	9600				;baudrate
	.equ	F_CPU	=	16000000
	.equ	bps		=	(F_CPU/16/baud) - 1	;baud prescale
	ldi		r28,	LOW(bps)
	ldi		r29,	HIGH(bps)
	sts		UBRR0L,	r28
	sts		UBRR0H,	r29
	ldi		r28,	(1<<RXEN0)|(1<<TXEN0)
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
	ldi r18,15
	ldi r19,0b11110000
	call sacanum

	ldi		r30,	low(num)
	ldi		r31,	high(num)		; Guardo en registros la dirección en memoria donde se guarda el número.
	ldi		r16,	100				; GLC: Valor inicial (X sub 0)
	ldi		r17,	192				; GLC: Multiplicador (a)
	ldi		r18,	134				; GLC: Incremento (c)
	ldi		r19,	211				; GLC: Modulo (m)
	ldi		r20,	0				; Inicializo r19 con 0 para contar los bits guardados.
	ldi		r21,	0				; Inicializo r20 con 0 para contar cuando llegue a 512.

obtener_num:
	call	generar_num_in
	sbrs	r21,	1
	rjmp	obtener_num
setup_sacar_de_memo:
	ldi		r16,	0
	ldi		r17,	0
	ldi		r19,	0
	ldi		r20,	0
	clr		r0
sacar_de_memo:
	ld		r18,	-Z
	add		r16,	r18
	adc		r17,	r0
	inc		r19
	brbc	1,		sacar_de_memo
	inc		r20
	sbrs	r20,	1
	rjmp	sacar_de_memo
despues:
	ldi		r18,	0b00001111
	and		r18,	r16
	ldi		r19,	0b00010000
	call	sacanum
	ldi		r18,	0b11110000
	and		r18,	r16
	lsr		r18
	lsr		r18
	lsr		r18
	lsr		r18
	ldi		r19,	0b00100000
	call	sacanum
	ldi		r18,	0b00001111
	and		r18,	r17
	ldi		r19,	0b01000000
	call	sacanum
	ldi		r18,	0b11110000
	and		r18,	r17
	lsr		r18
	lsr		r18
	lsr		r18
	lsr		r18
	ldi		r19,	0b10000000
	call	sacanum
	rjmp despues

	;lookup table con cpis de todos los cantidades pares de bits en 4 bits
;-----------------------------------------------------------------------------------------
; Genera un número aleatorio utilizando un algoritmo generador lineal recurrencial (GLC).
;-----------------------------------------------------------------------------------------
generar_num_in:
	mul		r16,	r17
	adc		r16,	r18

modulo:
	sbc		r16,	r19
	cp		r16,	r19
	brsh	modulo 
	st		Z+,		r16
	inc		r20
	brbc	1,		generar_num_out
	inc		r21

generar_num_out:
	ret

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
	brne sacanum_C ;cdefg
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

enviar:
	lds		r22,	UCSR0A
	sbrs	r22,	UDRE0
	rjmp	enviar

	sts		UDR0,	r23
	ret