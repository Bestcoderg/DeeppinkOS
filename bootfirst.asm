;	wrwos
;	TAB=4								SP=0x7c00														0x8000=������������
;----------------------------------------------------------------------------------------------
;|�ж�������|							|;����洢λ��	|	 ......			|	512|								
;|						|							|								 |	......		 |		|
;----------------------------------------------------------------------------------------------
;																														 0x8200=��ߵĳ���
;	��ĳ����������⣬���ǵĳ���ֻ��Ҫ�ڴ��̵Ŀ�ʼ512�ֽھ���
;	Ȼ��Ӳ�����Զ�ȥ����512��Ȼ��ִ����γ���

;	1->	��ȡ���̺������������ 
;	2->	��bootsecond.nas�����LCD֧��
;	3->	��ʼ��PIC
; 4-> ��A20�����뱣��ģʽ

CYLS	EQU	 10				 ;��10������
		ORG		0x7c00		 ;�����������ַ

		JMP		entry
		DB		0x90
		DB		"lollipop"  ; ������8���ַ�,����FAT12��ʽ������8���� 
		DW		512				  ; �±�ʹ��DB 0xXX��� 
		DB		1				
		DW		1				
		DB		2				
		DW		224			
		DW		2880			
		DB		0xf0			
		DW		9				
		DW		18				
		DW		2			
		DD		0				
		DD		2880			
		DB		0,0,0x29		
		DD		0xffffffff		
		DB		"HARIBOTEOS "	
		DB		"FAT12   "		
		RESB	18					

;	��ʼ����SS=0 DS=0	ES=0 SPָ�������صĵ�ַ
;	��Ϊ������صĵ�ַ��0x7c00���������ǵĶε�ַ������0��
;	��Ȼ��ַ�Ͳ���0x7c00��

entry:
		MOV		AX,0		
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX
		MOV		ES,AX

		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			
		CMP		AL,0
		JE		Read_Sector
		MOV		AH,0x0e			
		MOV		BX,0x0f			
		INT		0x10			;ִ��BIOS�ж�0x10
		JMP		putloop
		
Read_Sector:			
		MOV		SI,msg_1;	�򿪳ɹ�Ҫ��ʾ�ַ�
Read:
		MOV		AL,[SI]
		ADD		SI,1			
		CMP		AL,0
		JE		Read_Ok
		MOV		AH,0x0e			
		MOV		BX,0x0f			
		INT		0x10			;ִ��BIOS�ж�0x10
		JMP		Read;	
;	���濪ʼ�����̳�������
;	������	��30��...��������ʵ
;	ES:BX	����������ַ
Read_Ok:
		MOV		AX,0x0820	;ԭ������˵��������ҲҪ�����������͸ĳ�0x0800
		MOV		ES,AX
		MOV		BX,0x00
		MOV		CH,0			;	����0
		MOV		DH,0			;	��ͷ0
		MOV		CL,2			;	����2
readloop:
		MOV		SI,0	
retry:
		MOV		AH,0x02		;	AH=0x02	:	������
		MOV		AL,1			;	�������� 
		MOV		BX,0
		MOV		DL,0x00		;	�����������
		INT		0x13			;	�������ж�
		JNC		next			;	��ת����������������ɹ�
		ADD		SI,1			;	SI��1���㤹
		CMP		SI,5			;	SI��5����^
		JAE		error			;	SI >=	5	���ä���error��
		MOV		AH,0x00
		MOV		DL,0x00			;	A�ɥ饤��
		INT		0x13			;	�ɥ饤�֤Υꥻ�å�
		JMP		retry
next:
		MOV		AX,ES			;	�����ַ����0x200
		ADD		AX,0x0020
		MOV		ES,AX			;	ADD	ES,0x020���ָ��û��
		ADD		CL,1			;	����һ������
		CMP		CL,18			;	CL��18�Ƚ�
		JBE		readloop	;	���CL <=	18 ����ת
		MOV		CL,1			;||||
		ADD		DH,1			;||||	��ͷָ����һ�����ֿ�ʼ����һ����һ������
		CMP		DH,2			;||||
		JB		readloop	;	DH < 2 ��ת
		MOV		DH,0
		ADD		CH,1			;---------���ոı��������
		CMP		CH,CYLS
		JB		readloop	;	CH < CYLS	��ת
;		10*2*18*512=
		MOV		[0x0ff0],CH		;	IPL���ɤ��ޤ��i����Τ�����
		JMP		0xc200
		
error:		 
		MOV		SI,msg_error;	�򿪳ɹ�Ҫ��ʾ�ַ�
error_loop:
		MOV		AL,[SI]
		ADD		SI,1			
		CMP		AL,0
		JE		fin_error
		MOV		AH,0x0e			
		MOV		BX,0x0f			
		INT		0x10
		JMP		error_loop	
		
;	��ʾ����ȡ�������ɹ������ִ�е�����			
fin_error:
		HLT						
		JMP		fin_error		

msg:
		DB		0x0a,	0x0a	;����	
		DB		"hello,world"
		DB		0x0a				;����
		DB		0
msg_1:
		DB		"Read	more Sector..."
		DB		0x0a				;����
		DB		0
msg_error:
		DB		"Load	error"
		DB		0x0a				;����
		DB		0

		;times	0x7dfe-$	db	0	
		times	510-($-$$)	db	0
		DW		0xaa55
		
;		DB		0xf0,	0xff,	0xff,	0x00,	0x00,	0x00,	0x00,	0x00
;		RESB	4600
;		DB		0xf0,	0xff,	0xff,	0x00,	0x00,	0x00,	0x00,	0x00
;		RESB	1469432



