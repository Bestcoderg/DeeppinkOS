;	wrwos
;-----------------------------------------------------------------------------------------------
;                                      BIOS�ڴ�ӳ��
;-----------------------------------------------------------------------------------------------
;	TAB=4								SP=0x7c00														0x8000=������������
;	----------------------------------------------------------------------------------------------
;	|�ж�������|						 |;����洢λ��	 |	......		 | 512|								 
;	|						 |						 |								|	 ......			|		 |
;	----------------------------------------------------------------------------------------------
;	   																													 0x8200=��ߵĳ���
;	��ĳ����������⣬���ǵĳ���ֻ��Ҫ�ڴ��̵Ŀ�ʼ512�ֽھ���
;	Ȼ��Ӳ�����Զ�ȥ����512��Ȼ��ִ����γ���

;	1->	��ȡ���̺������������ 
;	2->	��bootsecond.nas�����LCD֧��
; 3->	��ʼ��PIC
; 4-> ��A20�����뱣��ģʽ
; 5-> ����CR0��PE��PG
; 6-> ����D��E��F��G��S��������������ǵڼ���GDT
extern	main
GLOBAL	myprintf
BOTPAK	EQU		0x00280000		
DSKCAC	EQU		0x00100000		
DSKCAC0	EQU		0x00008000		

;BOOT_INFO��Ϣ
CYLS		 EQU		 0x0ff0			
LEDS		 EQU		 0x0ff1
LCDMODE	 EQU		 0x0ff2		;
SCREENX	 EQU		 0x0ff4		;	x	
SCREENY	 EQU		 0x0ff6		;	y
LCDRAM	 EQU		 0x0ff8		; ͼ�񻺳����Ŀ�ʼ��ַ

		ORG		0xc200			;	�����������ַ
	
;		MOV		SI,msg_sys	;	�򿪳ɹ�Ҫ��ʾ�ַ�
;		display_loop:
;		MOV		AL,[SI]
;		ADD		SI,1			
;		CMP		AL,0
;		JE		fin
;		MOV		AH,0x0e			
;		MOV		BX,0x0f			
;		INT		0x10
;		JMP		display_loop
	
                    ; /------------------------------ 							
		MOV		AL,0x13		;/-------------------------------
		MOV		AH,0x00		;\  �趨VIDEOģʽ640*480	256ɫ
		INT		0x10			; \------------------------------
	
		MOV		BYTE	[LCDMODE],8
		MOV		WORD	[SCREENX],320
		mov		WORD	[SCREENY],200
		MOV		DWORD	[LCDRAM],0x000a0000	;	����һ����Ϣ
;
; ��ʼ��PIC��Ȼ��ر��ж�
;	
		MOV		AL,0XFF
		OUT		0x21,AL
		NOP
		OUT		0xa1,AL
		
		CLI
;
; OPEN A20
;
		CALL	waitkbd_8042
		MOV		AL,0xd1      ;д����
		OUT		0x64,AL
		CALL	waitkbd_8042
		MOV		AL,0xdf
		OUT		0x60,AL
		CALL	waitkbd_8042 ;��A20
;
; ��ʼ���뱣��ģʽ
;
[INSTRSET "i486p"]
		LGDT	[GDTR0]
		
		MOV		EAX,CR0
		AND		EAX,0x7fffffff
		OR		EAX,0x00000001
		MOV		CR0,EAX       ;�򿪶μ�������������ҳ����
	  JMP		pipelineflush
pipelineflush:
		MOV		AX,8
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX
		
		; bootpack��ܞ��

		MOV		ESI,bootpack	; 
		MOV		EDI,BOTPAK		; 0x00280000
		MOV		ECX,512*1024/4
		CALL	memcpy

; �Ĥ��Ǥ˥ǥ������ǩ`���Ȿ����λ�ä�ܞ��

; �ޤ��ϥ֩`�ȥ���������

;		MOV		ESI,0x7c00		; ܞ��Ԫ
;		MOV		EDI,DSKCAC		; ܞ���� 0x00100000
;		MOV		ECX,512/4
;		CALL	memcpy

; �Ф�ȫ��

;		MOV		ESI,DSKCAC0+512	; ܞ��Ԫ 0x00008000
;		MOV		EDI,DSKCAC+512	; ܞ���� 0x00100000
;		MOV		ECX,0
;		MOV		CL,BYTE [CYLS]
;		IMUL	ECX,512*18*2/4	; ������������Х�����/4�ˉ�Q
;		SUB		ECX,512/4		; IPL�η֤��������
;		CALL	memcpy

; asmhead�Ǥ��ʤ���Ф����ʤ����Ȥ�ȫ�����K��ä��Τǡ�
;	���Ȥ�bootpack���Τ���

; bootpack������

		MOV		EBX,BOTPAK     ;0x00280000
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			
		MOV		ESI,[EBX+20]	
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; ��ջ��ʼֵ
		JMP		DWORD 2*8:0x0000001b
			
;
;8042 �����̿�����
;		
waitkbd_8042:
		IN		AL,0x64
		AND		AL,0x02    ;���뻺�����Ƿ����ˣ�
		JNZ		waitkbd_8042 ;Yes---��ת
		RET
		
myprintf:	; void myprintf(char* msg, int len);
		MOV		ECX,[ESP+4]		;��ŵĵ�ַ
		MOV		EDX,[ESP+8]	  ;��ŵ�����
		MOV		EBX,1
		MOV		EAX,4
		INT		0x80
		RET		
		
memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			
		RET
	
		ALIGNB	16
;
;���뱣��ģʽ�󣬲��ٰ���CS*16+IPȡָ��ִ�У���Ҫ������ȫ��������
;	����ɲο���linux�ں���Ƶ�������
;
GDT0:
		RESB	8
		DW		0xffff,0x0000,0x9200,0x00cf		;---�λ���ַ 0x00cfȡ00��0x9200ȡ00��0x0000ȡȫ��====0x00000000
		DW		0xffff,0x0000,0x9a28,0x0047		;---�λ���ַ 0x0047ȡ00��0x9a28ȡ28��0x0000ȡȫ��====0x00280000
		DW		0
		
GDTR0:
		DW		23
		DD		GDT0
		
		ALIGNB	16
bootpack:		
		call main		; ����C����
;msg_sys:
;		DB		"JMP 0xc200"
;		DB		0x0a				;����
;		DB		0
		
		