/*
 * Lab_2.asm
 *
 *  Created: 2020-11-24 14:54:36
 *   Author: wille
 */ 
	.equ	N_4 = $18
	.equ	N_3 = $12
	.equ	N_1	= $06
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	sbi		DDRB, 4	
	ldi		r20, $02	;antal gånger man vill köra MAIN
	;h ttps://morsecode.world/international/decoder/audio-decoder-adaptive.html
	jmp		MAIN
	
	.dseg
CHAR_INDEX:
	.byte	1
	.cseg

MORSETABEL:
	.db $60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48, $E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8 

MESSAGE:
	.db "WILVO WILVO", $00	 
											
MAIN:
	push	r16
	push	r19
	call	GET_STRING
	pop		r19
	pop		r16
	dec		r20
	brne	MAIN

STOP:
	jmp		STOP

GET_STRING:
	call	GET_CHAR
	cpi		r16, $20
	breq	SPACE_NOBEEP
	call	LOOKUP
	jmp		SKIP_SPACE_NOBEEP
	;
SPACE_NOBEEP:
	ldi		r19, N_4
	call	NOBEEP
	jmp		GET_STRING
	;
SKIP_SPACE_NOBEEP:
	cpi		r16, $00
	breq	END_OF_STRING
	call	SEND
 	jmp		GET_STRING
	;
END_OF_STRING:
	ldi		r19, N_4
	call	NOBEEP
	call	RESET_CHAR_INDEX
	ret

SEND:
	cpi		r16, $80
	breq	END_OF_LETTER
	lsl		r16
	BRCS	BEEP_N_3
	BRCC	BEEP_N_1
	;
BEEP_N_3:
	ldi		r19, N_3
	call	BEEP
	jmp		SKIP
	;
BEEP_N_1:
	ldi		r19, N_1
	call	BEEP
	;
SKIP:
	ldi		r19, N_1
	call	NOBEEP
	jmp		SEND
	;
END_OF_LETTER:
	ldi		r19, N_3
	call	NOBEEP
	ret


RESET_CHAR_INDEX:
	push	r17
	;
	ldi		r17, $00
	sts		CHAR_INDEX, r17
	;
	pop		r17
	ret

LOOKUP:
	push	ZH
	push	ZL
	ldi		ZH, HIGH(MORSETABEL*2)
	ldi		ZL, LOW(MORSETABEL*2)
	;
	cpi		r16, $00
	breq	ENDLOOKUP
	subi	r16, $41
	add		ZL, r16 
	lpm		r16, Z
	;
ENDLOOKUP:
	pop		ZL
	pop		ZH
	ret

GET_CHAR:
	push	r18
	ldi		ZH, HIGH(MESSAGE*2)
	ldi		ZL, LOW(MESSAGE*2)
	lds		r18, CHAR_INDEX
	;
	add		ZL, r18
	lpm		r16, Z
	inc		r18
	sts		CHAR_INDEX, r18
	pop		r18
	ret


NOBEEP:
	cbi		PORTB, 4
	call	DELAY
	ret

BEEP:
	sbi		PORTB, 4
	call	DELAY
	ret

DELAY:
	push	r24
	push	r25
	clr		r24
	clr		r25 	
	;
D_1:
	adiw	r24, 1
	brne	D_1
	dec		r19
	cpi		r19, 0
	brne	D_1
	;
	pop		r25
	pop		r24
	ret
