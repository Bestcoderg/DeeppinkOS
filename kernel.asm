;	deeppinkos
;-------------------------------------------------------------------------------
;                                      BIOS�ڴ�ӳ��
;-------------------------------------------------------------------------------
;	TAB=4			SP=0x7c00		0x8000=������������
;-------------------------------------------------------------------------------
;	|�ж�������|		|;����洢λ��|	......	| 512|
;	|	  |		|	     |	......	|    |
;-------------------------------------------------------------------------------
;								0x8200=��ߵĳ���
;	��ĳ����������⣬���ǵĳ���ֻ��Ҫ�ڴ��̵Ŀ�ʼ512�ֽھ���
;	Ȼ��Ӳ�����Զ�ȥ����512��Ȼ��ִ����γ���

; 1-> ��ȡ���̺������������
; 2-> ��bootsecond.nas�����LCD֧��
; 3-> ��ʼ��PIC
; 4-> ��A20�����뱣��ģʽ
; 5-> ����CR0��PE��PG
; 6-> ����D��E��F��G��S��������������ǵڼ���GDT

GLOBAL  _start
GLOBAL	myprintf
BOTPAK	EQU		0x00280000
DSKCAC	EQU		0x00100000
DSKCAC0	EQU		0x00008000

;BOOT_INFO��Ϣ
CYLS		EQU	0x0ff0
LEDS		EQU	0x0ff1
LCDMODE		EQU	0x0ff2  ;
SCREENX		EQU	0x0ff4  ;	x
SCREENY		EQU	0x0ff6  ;	y
LCDRAM		EQU	0x0ff8  ; ͼ�񻺳����Ŀ�ʼ��ַ
[bits 16]
_start:
	ORG	0x8200
	MOV	AH,0x0e
	MOV	AL,'1'
	INT	0x10

[bits 32]
	LGDT	[GDTR0]
	MOV	EAX,CR0
	AND	EAX,0x7fffffff
	OR	EAX,0x00000001
	MOV	CR0,EAX       ;�򿪶μ�������������ҳ����

	JMP	0x8:PM_MODE
PM_MODE:
	MOV	AX,8
	MOV	DS,AX
	MOV	ES,AX
	MOV	FS,AX
	MOV	GS,AX
	MOV	SS,AX
	
	;MOV	BYTE [GS:dword 0xb8002],'1'	

	JMP	$
	;KERNEL_ADDR
	
	ALIGNB	16
;
;���뱣��ģʽ�󣬲��ٰ���CS*16+IPȡָ��ִ�У���Ҫ������ȫ��������
;	����ɲο���linux�ں���Ƶ�������
;
GDT0:
	RESB	8
	DW	0xffff,0x0000,0x9200,0x00cf ;---�λ���ַ 0x00cfȡ00��0x9200ȡ00��0x0000ȡȫ��===0x00000000
	DW	0xffff,0x0000,0x9a28,0x0047 ;---�λ���ַ 0x0047ȡ00��0x9a28ȡ28��0x0000ȡȫ��===0x00280000
	DW	0

GDTR0:
	DW	23
	DD	GDT0




	
		


