;	Deeppinkos
;	TAB=4	SP=0x7c00		0x8000=������������
;-------------------------------------------------------------------------------
;|�ж�������|	|;����洢λ�� |......	|512|
;|	    |	|	       |......  |   |
;-------------------------------------------------------------------------------
;						0x8200=��ߵĳ���
;��ĳ����������⣬���ǵĳ���ֻ��Ҫ�ڴ��̵Ŀ�ʼ512�ֽھ���
;Ȼ��Ӳ�����Զ�ȥ����512��Ȼ��ִ����γ���

;1-> ��ȡ���̺������������
;2-> ��bootsecond.nas�����LCD֧��
;3-> ��ʼ��PIC
;4-> ��A20�����뱣��ģʽ


[bits 16]
CYLS		EQU	10	;��10������
BOOT_ADDR	EQU	0x7C00
KERNEL_ADDR	EQU	0xC0000000

LCDMODE		EQU	0x0ff2  ;
SCREENX		EQU	0x0ff4  ;	x
SCREENY		EQU	0x0ff6  ;	y
LCDRAM		EQU	0x0ff8  ; ͼ�񻺳����Ŀ�ʼ��ַ

	ORG	BOOT_ADDR	;�����������ַ
;��ʼ����SS=0 DS=0 ES=0 SPָ�������صĵ�ַ
;��Ϊ������صĵ�ַ��0x7c00���������ǵĶε�ַ������0��
;��Ȼ��ַ�Ͳ���0x7c00��
	MOV	AX,CS
	MOV	SS,AX
	MOV	SP,BOOT_ADDR
	MOV	DS,AX
	MOV	ES,AX
;
;The second stage
;	Now ,load kernel from img
;
	MOV	SI,msg
putloop:
	MOV	AL,[SI]
	ADD	SI,1
	CMP	AL,0
	JE	Read_Sector
	MOV	AH,0x0e
	MOV	BX,0x0f
	INT	0x10		;ִ��BIOS�ж�0x10
	JMP	putloop

Read_Sector:
	MOV	SI,msg_1	;�򿪳ɹ�Ҫ��ʾ�ַ�
Read:
	MOV	AL,[SI]
	ADD	SI,1
	CMP	AL,0
	JE	Read_Ok
	MOV	AH,0x0e
	MOV	BX,0x0f
	INT	0x10		;ִ��BIOS�ж�0x10
	JMP	Read;
;���濪ʼ�����̳�������
;��������30��...��������ʵ
;ES:BX	����������ַ
Read_Ok:
	MOV	AX,0x0800	;ԭ������˵��������ҲҪ�����������͸ĳ�0x0800
	MOV	ES,AX
	MOV	BX,0x00
	MOV	CH,0		;����0
	MOV	DH,0		;��ͷ0
	MOV	CL,2		;����2
readloop:
	MOV	SI,0
retry:
	MOV	AH,0x02		;AH=0x02:������
	MOV	AL,1		;�������� 
	MOV	BX,0
	MOV	DL,0x00		;�����������
	INT	0x13		;�������ж�
	JNC	next		;��ת����������������ɹ�
	ADD	SI,1		;SI��1���㤹
	CMP	SI,5		;SI��5����^
	JAE	error		;SI >=	5���ä���error��
	MOV	AH,0x00
	MOV	DL,0x00		;A�ɥ饤��
	INT	0x13		;�ɥ饤�֤Υꥻ�å�
	JMP	retry
next:
	MOV	AX,ES		;�����ַ����0x200
	ADD	AX,0x0020
	MOV	ES,AX		;ADD ES,0x020���ָ��û��
	ADD	CL,1		;����һ������
	CMP	CL,18		;CL��18�Ƚ�
	JBE	readloop	;���CL <=18 ����ת
	MOV	CL,1		;||||
	ADD	DH,1		;||||	��ͷָ����һ�����ֿ�ʼ����һ����һ������
	CMP	DH,2		;||||
	JB	readloop	;DH < 2 ��ת
	MOV	DH,0
	ADD	CH,1		;---------���ոı��������
	CMP	CH,CYLS
	JB	readloop	;CH < CYLS��ת
;10*2*18*512=
	MOV	[0x0ff0],CH	;IPL���ɤ��ޤ��i����Τ�����

;
;  ��ӡ�ɹ���ȡ״̬
;	����ʾ����	
		
	MOV	AH,0x02
	MOV	BX,0x0f
	MOV	DX,0x0e16
	INT	0x10

	MOV	SI,msg_2	;�򿪳ɹ�Ҫ��ʾ�ַ�
print_loop:
	MOV	AL,[SI]
	ADD	SI,1
	CMP	AL,0
	JE	goto_PM
	MOV	AH,0x0e
	MOV	BX,0x0f
	INT	0x10		;ִ��BIOS�ж�0x10
	
	JMP	print_loop;
;
;The third stage
;	goto PM mode
;
goto_PM:
	MOV	AL,0x03
	MOV	AH,0x00
	INT	0x10

	;MOV	BYTE [LCDMODE],8
	;MOV	WORD [SCREENX],320
	;MOV	WORD [SCREENY],200
	;MOV	DWORD [LCDRAM],0x000a0000
	
	MOV	AL,0XFF
	OUT	0x21,AL
	NOP
	OUT	0xa1,AL

	;MOV	AH,0x0e
	;MOV	AL,'!'
	;INT	0x10

	CLI
;
; OPEN A20
;
	CALL	waitkbd_8042
	MOV	AL,0xd1      ;д����
	OUT	0x64,AL
	CALL	waitkbd_8042
	MOV	AL,0xdf
	OUT	0x60,AL
	CALL	waitkbd_8042 ;��A20


	;MOV	AH,0x0e
	;MOV	AL,'O'
	;INT	0x10

	;MOV	AH,0x0e
	;MOV	AL,'S'
	;INT	0x10

        ;jmp     $
        CLI
	LGDT	[GDTR0]

        IN      AL,92h
        OR      AL,0x02
	OUT     92h,AL

        MOV	EAX,CR0
	AND	EAX,0x7fffffff
	OR	AL,1
	MOV	CR0,EAX       ;�򿪶μ�������������ҳ����

        JMP	dword 0x08:PM_MODE
[bits 32]
PM_MODE:
	MOV	EAX,0x00000010
	MOV	DS,AX
	MOV	ES,AX
	MOV	FS,AX
	MOV	GS,AX
	MOV	SS,AX

        ;MOV     EAX,0x00000018
        ;MOV     GS,EAX
        
        MOV     EAX,0x8080
        JMP     EAX;dword 0x08:0x8200
;
;	��ʾ��Ҫ������ַ���
;

waitkbd_8042:
	IN	AL,0x64
	AND	AL,0x02    ;���뻺�����Ƿ����ˣ�
	JNZ	waitkbd_8042 ;Yes---��ת
	RET

;
;���뱣��ģʽ�󣬲��ٰ���CS*16+IPȡָ��ִ�У���Ҫ������ȫ��������
;	����ɲο���linux�ں���Ƶ�������
;

GDT0:
	DW      0x0000,0x0000,0x0000,0x0000
        ;---����λ���ַ 0x0047ȡ00��0x9a28ȡ28��0x0000ȡȫ��===0x00280000
	DW	0xffff,0x0000,0x9a00,0x00cf
        ;---���ݶλ���ַ 0x00cfȡ00��0x9200ȡ00��0x0000ȡȫ��===0x00000000
	DW	0xffff,0x0000,0x9200,0x00cf
        DW      0xffff,0x8000,0xf20b,0x000f
        ;Ϊtss׼����
	DW      0x0000,0x0000,0x0000,0x0000
        ;Ϊidt׼����
	DW      0x0000,0x0000,0x0000,0x0000
        ;DW      0xffff,0x8000,0xf20b,0x000f
GDT0_LEN EQU $-GDT0
GDTR0:
	DW	GDT0_LEN-1
	DD	GDT0

error:
	MOV	SI,msg_error;	��ʧ��Ҫ��ʾ�ַ�
error_loop:
	MOV	AL,[SI]
	ADD	SI,1
	CMP	AL,0
	JE	fin_error
	MOV	AH,0x0e
	MOV	BX,0x0f
	INT	0x10
	JMP	error_loop

;��ʾ����ȡ�������ɹ������ִ�е�����
fin_error:
	HLT
	JMP	fin_error

msg:
	DB	0x0a,	0x0a	;����
	DB	"Welcome to DeeppinkOS:"
	DB	0x0a				;����
	DB	0
msg_1:
	DB	0x0a,	0x0a	;����
	DB	"Read Sectors..."
	DB	0x0a				;����
	DB	0
msg_2:
	DB	"Read Completely!!"
	DB	0x0a				;����
	DB	0

msg_error:
	DB	"Load	error"
	DB	0x0a				;����
	DB	0

	times	510-($-$$) db 0
	DW	0xaa55


