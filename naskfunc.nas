; naskfunc
; TAB=4

[FORMAT "WCOFF"]		
[INSTRSET "i486p"]			
[BITS 32]						



[FILE "naskfunc.nas"]			

		GLOBAL	_io_hlt,_write_memory



[SECTION .text]		

_io_hlt:	; void io_hlt(void);
		HLT
		RET
_write_memory:	; void write_memory(int addr, int data);
		MOV		ECX,[ESP+4]		;��ŵĵ�ַ
		MOV		AL,[ESP+8]	  ;��ŵ�����
		MOV		[ECX],AL
		RET