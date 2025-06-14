*==========================================================================
*
*	�����Fshort xsp_set(short x, short y, short pt, short info);
*
*	�����Fshort x    : �X�v���C�g X ���W
*	      short y    : �X�v���C�g Y ���W
*	      short pt   : �X�v���C�g PCG �p�^�[�� No.�i0�`0x7FFF�j
*	      short info : ���]�R�[�h�E�F�E�\���D��x��\���f�[�^
*
*	�߂�l�F�X�v���C�g���W�ix,y�j����ʊO�������Ȃ� 0
*	        ����ȊO�̏ꍇ�� 0 �ȊO�̒l
*
*==========================================================================

_xsp_set:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

.if	SHIFT==0
	* 
	* �V�t�g�r�b�g���� 0 �̎��́ASP_x SP_y �� word �P�ʂŏ����������������B
	* 

	move.w	A7ID+arg1_w(sp),d0	*[12]	d0.w = SP_x
	cmpi.w	#(XY_MAX<<SHIFT),d0	*[ 8]	X ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_CANCEL		*[8,10]	XY_MAX <= SP_x �Ȃ�L�����Z��

	move.w	A7ID+arg2_w(sp),d1	*[12]	d1.w = SP_y
	cmpi.w	#(XY_MAX<<SHIFT),d1	*[ 8]	Y ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_CANCEL		*[8,10]	XY_MAX <= SP_y �Ȃ�L�����Z��

	lea	buff_pointer(pc),a2	*[ 8]	a2.l = ���o�b�t�@�|�C���^�̃|�C���^
	movea.l	(a2),a0			*[12]	a0.l = ���o�b�t�@�|�C���^
	tst.w	(a0)			*[ 8]	�����`�F�b�N
	bmi.b	XSP_SET_RETURN		*[8,10]	���Ȃ�o�b�t�@�I�_�ƌ��Ȃ��I��

	*-------[ PUSH ]
		.if	SHIFT<>0
			asr.w	#SHIFT,d0	*[6+2n]	�Œ菬���r�b�g�����̃V�t�g
			asr.w	#SHIFT,d1	*[6+2n]	�Œ菬���r�b�g�����̃V�t�g
		.endif

		move.w	d0,(a0)+		*[ 8]	SP_x ��]��
		move.w	d1,(a0)+		*[ 8]	SP_y ��]��

		move.w	A7ID+arg3_w(sp),(a0)+	*[16]	SP_pt ��]��
		move.w	A7ID+arg4_w(sp),(a0)+	*[16]	SP_info ��]��

		move.l	a0,(a2)			*[12]	���o�b�t�@�|�C���^�̕ۑ�

XSP_SET_RETURN:
					*	d0.w = SP_x
	rts

.else
	* 
	* �V�t�g�r�b�g���� 0 �łȂ����́ASP_x SP_y ���܂Ƃ߂� long �ŏ����������������B
	* 

	move.w	A7ID+arg1_w(sp),d0		*[12]	d0.w = SP_x
	cmpi.w	#(XY_MAX<<SHIFT),d0		*[ 8]	X ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_CANCEL			*[8,10]	XY_MAX <= SP_x �Ȃ�L�����Z��

	swap	d0				*[ 4]	d0.l = SP_x,????
	move.w	A7ID+arg2_w(sp),d0		*[12]	d0.l = SP_x,SP_y
	cmpi.w	#(XY_MAX<<SHIFT),d0		*[ 8]	Y ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_CANCEL			*[8,10]	XY_MAX <= SP_y �Ȃ�L�����Z��

	lea	buff_pointer(pc),a2		*[ 8]	a2.l = ���o�b�t�@�|�C���^�̃|�C���^
	movea.l	(a2),a0				*[12]	a0.l = ���o�b�t�@�|�C���^
	tst.w	(a0)				*[ 8]	�����`�F�b�N
	bmi.b	XSP_SET_RETURN			*[8,10]	���Ȃ�o�b�t�@�I�_�ƌ��Ȃ��I��

	*-------[ PUSH ]
		.if	SHIFT<>0
			lsr.l	#SHIFT,d0	*[8+2n]	�Œ菬���r�b�g�����̃V�t�g
						*	SP_x �̉��ʃr�b�g�� SP_y ��ʃr�b�g��
						*	�R�ꂾ���̂Œ��ӁB
		.endif

		move.l	d0,(a0)+		*[12]	SP_x,SP_y ��]��
		move.w	A7ID+arg3_w(sp),(a0)+	*[16]	SP_pt ��]��
		move.w	A7ID+arg4_w(sp),(a0)+	*[16]	SP_info ��]��

		move.l	a0,(a2)			*[12]	���o�b�t�@�|�C���^�̕ۑ�

XSP_SET_RETURN:
	.if	COMPATIBLE<>0
					*	d0.l = SP_x,SP_y
					* �ߋ��̓���Ƃ̌݊��ɂ���ɂ� swap ���K�v
		swap	d0		*[ 4]	d0.l = SP_y,SP_x
	.endif
					*	d0.w = SP_x
	rts

.endif


XSP_SET_CANCEL:
	moveq	#0,d0			*[ 4]	��ʊO�Ȃ̂ŁA�߂�l = 0
	rts




*==========================================================================
*
*	�����Fshort xsp_set_st(void *arg);
*
*	�����Fvoid *arg : �p�����[�^�\���̂̃|�C���^
*
*	�߂�l�F�X�v���C�g���W����ʊO�������Ȃ� 0
*	        ����ȊO�̏ꍇ�� 0 �ȊO�̒l
*
*        +0.w : �X�v���C�g x ���W
*        +2.w : �X�v���C�g y ���W
*        +4.w : �X�v���C�g PCG �p�^�[�� No.�i0�`0x7FFF�j
*        +6.w : ���]�R�[�h�E�F�E�\���D��x��\���f�[�^�ixsp_set �֐��́A
*               ���� info �ɑ����j
*
*==========================================================================

_xsp_set_st:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.l	A7ID+arg1_l(sp),a1		*[16]	a1.l = �\���̃A�h���X

	move.l	(a1)+,d0			*[12]	d0.l = SP_x,SP_y

	cmpi.l	#(XY_MAX<<(SHIFT+16)),d0	*[14]	X ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_ST_CANCEL		*[8,10]	XY_MAX <= SP_x �Ȃ�L�����Z��
	cmpi.w	#(XY_MAX<<SHIFT),d0		*[ 8]	Y ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_ST_CANCEL		*[8,10]	XY_MAX <= SP_y �Ȃ�L�����Z��

	lea	buff_pointer(pc),a2		*[ 8]	a2.l = ���o�b�t�@�|�C���^�̃|�C���^
	movea.l	(a2),a0				*[12]	a0.l = ���o�b�t�@�|�C���^
	tst.w	(a0)				*[ 8]	�����`�F�b�N
	bmi.b	XSP_SET_ST_RETURN		*[8,10]	���Ȃ�o�b�t�@�I�_�ƌ��Ȃ��I��

	*-------[ PUSH ]
		.if	SHIFT<>0
			lsr.l	#SHIFT,d0	*[8+2n]	�Œ菬���r�b�g�����̃V�t�g
						*	SP_x �̉��ʃr�b�g�� SP_y ��ʃr�b�g��
						*	�R�ꂾ���̂Œ��ӁB
		.endif

		move.l	d0,(a0)+		*[12]	SP_x,SP_y ��]��
		move.l	(a1)+,(a0)+		*[20]	SP_pt,info ��]��

		move.l	a0,(a2)			*[12]	���o�b�t�@�|�C���^�̕ۑ�

XSP_SET_ST_RETURN:
	.if	COMPATIBLE<>0
					*	d0.l = SP_x,SP_y
					* �ߋ��̓���Ƃ̌݊��ɂ���ɂ� swap ���K�v
		swap	d0		*[ 4]	d0.l = SP_y,SP_x
	.endif
					*	d0.w = SP_x
	rts

XSP_SET_ST_CANCEL:
	moveq	#0,d0			*[ 4]	��ʊO�Ȃ̂ŁA�߂�l = 0
	rts



*==========================================================================
*
*	�����Fvoid xobj_set(short x, short y, short pt, short info);
*
*	�����Fshort x    : �����X�v���C�g�� x ���W
*	      short y    : �����X�v���C�g�� y ���W
*	      short pt   : �����X�v���C�g�̌`��p�^�[�� No.�i0�`0x0FFF�j
*	      short info : ���]�R�[�h�E�F�E�\���D��x��\���f�[�^
*
*	�߂�l�F����
*
*==========================================================================


*-------[ �}�N���̒�` ]

OBJ_WRITE:	.macro	RV10,RV01
		.local	OBJ_LOOP
		.local	NEXT_OBJ
		.local	EXIT_OBJ_LOOP
		.local	SKIP_OBJ_PUSH_1
		.local	SKIP_OBJ_PUSH_2

					* ����C�Ȃ����[�v 2 �{�W�J
		lsr.w	#1,d0
		bcc.b	NEXT_OBJ

OBJ_LOOP:
		.if	RV01=0
			add.w	(a1)+,d3	* SP_x += vx
		.else
			sub.w	(a1)+,d3	* SP_x -= vx
		.endif

		.if	RV10=0
			add.w	(a1)+,d4	* SP_y += vy
		.else
			sub.w	(a1)+,d4	* SP_y -= vy
		.endif

		cmp.w	a2,d3
		bcc.b	SKIP_OBJ_PUSH_1		* MAX���W <= SP_x �Ȃ� push ����
		cmp.w	a2,d4
		bcc.b	SKIP_OBJ_PUSH_1		* MAX���W <= SP_y �Ȃ� push ����

		move.w	d3,(a0)+		* x ��]��
		move.w	d4,(a0)+		* y ��]��

		move.l	(a1)+,d1		*[12] d1.l = PT RV
		eor.w	d2,d1			*[ 4] d1.w = ���]���H�� info
		move.l	d1,(a0)+		*[12] PT RV ��]��

	NEXT_OBJ:

		.if	RV01=0
			add.w	(a1)+,d3	* SP_x += vx
		.else
			sub.w	(a1)+,d3	* SP_x -= vx
		.endif

		.if	RV10=0
			add.w	(a1)+,d4	* SP_y += vy
		.else
			sub.w	(a1)+,d4	* SP_y -= vy
		.endif

		cmp.w	a2,d3
		bcc.b	SKIP_OBJ_PUSH_2		* MAX���W <= SP_x �Ȃ� push ����
		cmp.w	a2,d4
		bcc.b	SKIP_OBJ_PUSH_2		* MAX���W <= SP_y �Ȃ� push ����

		move.w	d3,(a0)+		* x ��]��
		move.w	d4,(a0)+		* y ��]��

		move.l	(a1)+,d1		*[12] d1.l = PT RV
		eor.w	d2,d1			*[ 4] d1.w = ���]���H�� info
		move.l	d1,(a0)+		*[12] PT RV ��]��

		dbra.w	d0,OBJ_LOOP

EXIT_OBJ_LOOP:
	*-------[ �I�� ]
		move.w	(sp)+,d4		* d4.w ����
		move.w	(sp)+,d3		* d3.w ����
		move.l	a0,buff_pointer		* �o�b�t�@�|�C���^�ۑ�
		rts


SKIP_OBJ_PUSH_1:
	addq.w	#4,a1
	bra.b	NEXT_OBJ

SKIP_OBJ_PUSH_2:
	addq.w	#4,a1
	dbra.w	d0,OBJ_LOOP
	bra.b	EXIT_OBJ_LOOP

		.endm

*------------------------



OBJ_SET_RETURN:
	move.w	(sp)+,d4		* d4.w ����
	move.w	(sp)+,d3		* d3.w ����
	rts


_xobj_set:

A7ID	=	4+2*2			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 2*2 byte ]

	move.w	d3,-(sp)		* d3.w �ޔ�
	move.w	d4,-(sp)		* d4.w �ޔ�

	move.w	A7ID+arg3_w(sp),d1	*[12] d1.w = �����X�v���C�g pt
	move.w	A7ID+arg4_w(sp),d2	*[12] d2.w = SP_info
	move.w	A7ID+arg1_w(sp),d3	*[12] d3.w = SP_x
	move.w	A7ID+arg2_w(sp),d4	*[12] d4.w = SP_y


*-------[ �Q�Ƃ��ׂ� sp_ref �̃A�h���X�����߂� ]
OBJ_SET_INIT_STEP1:

	lsl.w	#3,d1			* d1.w *= 8
	movea.l	sp_ref_adr(pc),a1	* a1.l = sp_ref_adr
	adda.w	d1,a1			* a1.w += pt*8
					* a1.l = �Q�Ƃ��ׂ� sp_ref �̃A�h���X
					* d1.w �� �p�ς�


*-------[ �K�v�����X�v���C�g�������߂� ]
OBJ_SET_INIT_STEP2:

	movea.l	buff_pointer(pc),a0
	move.l	#buff_end_adr_no_pc,d0	* d0.l = #buff_end_adr_no_pc�imove.w ���g����Ɨǂ����E�E�E�j
	sub.w	a0,d0			* d0.w -= a0.w
	asr.w	#3,d0			* d0.w /= 8
					* d0.w = push�\�X�v���C�g��(1�`)
	cmp.w	(a1)+,d0		* 
	ble.b	@F			* �K�v�����X�v���C�g�� >= d0 �Ȃ� bra
		move.w	-2(a1),d0	* d0.w = �K�v�����X�v���C�g��
@@:
	sub.w	#1,d0			* d0.w �� dbra �J�E���^�Ƃ��邽�� -1 ����B
	bmi.b	OBJ_SET_RETURN		* �K�v�����X�v���C�g�� <= 0 �Ȃ狭���I������


*-------[ ���̑��̏����� ]
OBJ_SET_INIT_STEP3:

	.if	SHIFT<>0
		asr.w	#SHIFT,d3
		asr.w	#SHIFT,d4
	.endif
					*------------------------------------------------------
					* d0.w = �K�v�����X�v���C�g�� - 1�idbra �J�E���^�Ƃ���j
					* d1.l = temp
					* d2.w = SP_info
					* d3.w = SP_x
					* d4.w = SP_y
					*------------------------------------------------------
					* a0.l = push ��
	movea.l	(a1),a1			* a1.l = sp_frm �ǂݏo���J�n�A�h���X
	move.w	#XY_MAX,a2		* a2.l = XY ���W����l
					*------------------------------------------------------


*=======[ �X�v���C�g���� ]

	move.w	d2,d1
	bmi	RV_1x			* �㉺���]�F�P �Ȃ̂� bra

	*=======[ �㉺���]�F0  ���E���]�F? ]
RV_0x:		add.w	d1,d1
		bmi.b	RV_01			* ���E���]�F1 �Ȃ̂� bra

		*-------[ �㉺���]�F0  ���E���]�F0 ]
	RV_00:		OBJ_WRITE	0,0

		*-------[ �㉺���]�F0  ���E���]�F1 ]
	RV_01:		OBJ_WRITE	0,1

	*=======[ �㉺���]�F1  ���E���]�F? ]
RV_1x:		add.w	d1,d1
		bmi.b	RV_11			* ���E���]�F1 �Ȃ̂� bra

		*-------[ �㉺���]�F1  ���E���]�F0 ]
	RV_10:		OBJ_WRITE	1,0

		*-------[ �㉺���]�F1  ���E���]�F1 ]
	RV_11:		OBJ_WRITE	1,1




*==========================================================================
*
*	�����Fshort xsp_set_st(void *arg);
*
*	�����Fvoid *arg : �p�����[�^�\���̂̃|�C���^
*
*	�߂�l�F�X�v���C�g���W����ʊO�������Ȃ� 0
*	        ����ȊO�̏ꍇ�� 0 �ȊO�̒l
*
*        +0.w : �X�v���C�g x ���W
*        +2.w : �X�v���C�g y ���W
*        +4.w : �X�v���C�g PCG �p�^�[�� No.�i0�`0x7FFF�j
*        +6.w : ���]�R�[�h�E�F�E�\���D��x��\���f�[�^�ixsp_set �֐��́A
*               ���� info �ɑ����j
*
*==========================================================================

_xobj_set_st:

A7ID	=	4+2*2			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 2*2 byte ]

	move.w	d3,-(sp)		* d3.w �ޔ�
	move.w	d4,-(sp)		* d4.w �ޔ�

*-------[ �p�����[�^��� ]
	movea.l	A7ID+arg1_l(sp),a0	* a0.l = �\���̃A�h���X

	move.w	(a0)+,d3		*[8]	d3.w = SP_x
	move.w	(a0)+,d4		*[8]	d4.w = SP_y
	move.w	(a0)+,d1		*[8]	d1.w = �����X�v���C�gpt
	move.w	(a0)+,d2		*[8]	d2.w = SP_info
					*	a0.l �͗p�ς�

	bra	OBJ_SET_INIT_STEP1	* obj_set()�֐���




