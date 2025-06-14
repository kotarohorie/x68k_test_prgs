*==========================================================================
*
*	xsp_set_asm
*
*	�����F
*		d0.w = SP_x : �X�v���C�g X ���W
*		d1.w = SP_y : �X�v���C�g Y ���W
*		d2.w = SP_pt : �X�v���C�g PCG �p�^�[�� No.�i0�`0x7FFF�j
*		d3.w = SP_info : ���]�R�[�h�E�F�E�\���D��x��\���f�[�^
*
*	�j��F
*		d0 a0
*
*	�߂�l�F
*		d0.w
*			�X�v���C�g���W����ʊO�������Ȃ� 0
*			����ȊO�̏ꍇ�� 0 �ȊO�̒l
*
*==========================================================================

_xsp_set_asm:
					* d0.w = SP_x
					* d1.w = SP_y
					* d2.w = SP_pt
					* d3.w = SP_info

	cmpi.w	#(XY_MAX<<SHIFT),d0	*[ 8]	X ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_ASM_CANCEL	*[8,10]	XY_MAX <= SP_x �Ȃ�L�����Z��

	cmpi.w	#(XY_MAX<<SHIFT),d1	*[ 8]	Y ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_ASM_CANCEL	*[8,10]	XY_MAX <= SP_y �Ȃ�L�����Z��

	movea.l	buff_pointer(pc),a0	*[16]	a0.l = ���o�b�t�@�|�C���^
	tst.w	(a0)			*[ 8]	�����`�F�b�N
	bmi.b	XSP_SET_ASM_RETURN	*[8,10]	���Ȃ�o�b�t�@�I�_�ƌ��Ȃ��I��

	*-------[ PUSH ]
		.if	SHIFT<>0
						*	d1 ���r�b�g�V�t�g���Ȃ����Ƃ�
						*	�j�󃌃W�X�^�����炷���Ƃ��ł���B
			swap	d0		*[ 4]	d0.l = SP_x,????
			move.w	d1,d0		*[ 4]	d0.l = SP_x,SP_y
			lsr.l	#SHIFT,d0	*[8+2n]	�Œ菬���r�b�g�����̃V�t�g
						*	SP_x �̉��ʃr�b�g�� SP_y ��ʃr�b�g��
						*	�R�ꂾ���̂Œ��ӁB
			move.l	d0,(a0)+	*[12]	SP_x,SP_y ��]��
			.if	COMPATIBLE<>0
						*	d0.l = SP_x,SP_y
						* �ߋ��̓���Ƃ̌݊��ɂ���ɂ� swap ���K�v
				swap	d0	*[ 4]	d0.l = SP_y,SP_x
			.endif
		.else
			move.w	d0,(a0)+	*[ 8]	SP_x ��]��
			move.w	d1,(a0)+	*[ 8]	SP_y ��]��
		.endif
		move.w	d2,(a0)+		*[ 8]	SP_pt ��]��
		move.w	d3,(a0)+		*[ 8]	SP_info ��]��

		move.l	a0,buff_pointer		*[12]	���o�b�t�@�|�C���^�̕ۑ�

XSP_SET_ASM_RETURN:
						* d0.w = SP_x
	rts

XSP_SET_ASM_CANCEL:
	moveq	#0,d0			*[ 4]	��ʊO�Ȃ̂ŁA�߂�l = 0
	rts




*==========================================================================
*
*	xsp_set_st_asm
*
*	�����F
*		a0.l = �p�����[�^�\���̂̃|�C���^
*
*	�߂�l�F
*		d0.w
*			�X�v���C�g���W����ʊO�������Ȃ� 0
*			����ȊO�̏ꍇ�� 0 �ȊO�̒l
*
*	�j��F
*		a0 a1
*
*	�p�����[�^�\����
*	+0.w : �X�v���C�g x ���W
*	+2.w : �X�v���C�g y ���W
*	+4.w : �X�v���C�g PCG �p�^�[�� No.�i0�`0x7FFF�j
*	+6.w : ���]�R�[�h�E�F�E�\���D��x��\���f�[�^�ixsp_set �֐��́A
*	       ���� info �ɑ����j
*
*==========================================================================

_xsp_set_st_asm:
						* a0.l = �\���̃A�h���X

	move.l	(a0)+,d0			*[12]	d0.l = SP_x,SP_y

	cmpi.l	#(XY_MAX<<(SHIFT+16)),d0	*[14]	X ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_ST_ASM_CANCEL		*[8,10]	XY_MAX <= SP_x �Ȃ�L�����Z��
	cmpi.w	#(XY_MAX<<SHIFT),d0		*[ 8]	Y ���W��ʊO�`�F�b�N
	bcc.b	XSP_SET_ST_ASM_CANCEL		*[8,10]	XY_MAX <= SP_y �Ȃ�L�����Z��

	movea.l	buff_pointer(pc),a1		*[16]	a1.l = ���o�b�t�@�|�C���^
	tst.w	(a1)				*[ 8]	�����`�F�b�N
	bmi.b	XSP_SET_ST_ASM_RETURN		*[8,10]	���Ȃ�o�b�t�@�I�_�ƌ��Ȃ��I��

	*-------[ PUSH ]
		.if	SHIFT<>0
			lsr.l	#SHIFT,d0	*[8+2n]	�Œ菬���r�b�g�����̃V�t�g
						*	SP_x �̉��ʃr�b�g�� SP_y ��ʃr�b�g��
						*	�R�ꂾ���̂Œ��ӁB
		.endif

		move.l	d0,(a1)+		*[12]	SP_x,SP_y ��]��
		move.l	(a0)+,(a1)+		*[20]	SP_pt,info ��]��

		move.l	a1,buff_pointer		*[20]	���o�b�t�@�|�C���^�̕ۑ�

XSP_SET_ST_ASM_RETURN:
	.if	COMPATIBLE<>0
					*	d0.l = SP_x,SP_y
					* �ߋ��̓���Ƃ̌݊��ɂ���ɂ� swap ���K�v
		swap	d0		*[ 4]	d0.w = SP_x
	.endif
					* d0.w = SP_x
	rts

XSP_SET_ST_ASM_CANCEL:
	moveq	#0,d0			*[ 4]	��ʊO�Ȃ̂ŁA�߂�l = 0
	rts




*==========================================================================
*
*	xobj_set_asm
*
*	�����F
*		d0.w = SP_x : �����X�v���C�g�� X ���W
*		d1.w = SP_y : �����X�v���C�g�� Y ���W
*		d2.w = SP_pt : �����X�v���C�g�̌`��p�^�[�� No.�i0�`0x0FFF�j
*		d3.w = SP_info : ���]�R�[�h�E�F�E�\���D��x��\���f�[�^
*
*	�j��F
*		d0 d1 d2 d3 d4 a0 a1 a2
*
*	�߂�l�F����
*
*==========================================================================
*
*	xobj_set_st_asm
*
*	�����F
*		a0.l = �p�����[�^�\���̂̃|�C���^
*
*	�j��F
*		d0 d1 d2 d3 d4 a0 a1 a2
*
*	�߂�l�F����
*
*	�p�����[�^�\����
*	+0.w : �����X�v���C�g�� x ���W
*	+2.w : �����X�v���C�g�� y ���W
*	+4.w : �����X�v���C�g�̌`��p�^�[�� No.
*	+6.w : ���]�R�[�h�E�F�E�\���D��x��\���f�[�^
*
*==========================================================================


*-------[ �}�N���̒�` ]

OBJ_WRITE_ASM:	.macro	RV10,RV01
		.local	OBJ_LOOP
		.local	NEXT_OBJ
		.local	EXIT_OBJ_LOOP
		.local	SKIP_OBJ_PUSH_1
		.local	SKIP_OBJ_PUSH_2

					* ����C�Ȃ����[�v 2 �{�W�J
		lsr.w	#1,d4
		bcc.b	NEXT_OBJ

OBJ_LOOP:
		.if	RV01=0
			add.w	(a1)+,d0	* SP_x += vx
		.else
			sub.w	(a1)+,d0	* SP_x -= vx
		.endif

		.if	RV10=0
			add.w	(a1)+,d1	* SP_y += vy
		.else
			sub.w	(a1)+,d1	* SP_y -= vy
		.endif

		cmp.w	a2,d0
		bcc.b	SKIP_OBJ_PUSH_1		* MAX���W <= SP_x �Ȃ� push ����
		cmp.w	a2,d1
		bcc.b	SKIP_OBJ_PUSH_1		* MAX���W <= SP_y �Ȃ� push ����

		move.w	d0,(a0)+		* SP_x ��]��
		move.w	d1,(a0)+		* SP_y ��]��

		move.l	(a1)+,d2		*[12] d2.l = PT RV
		eor.w	d3,d2			*[ 4] d2.w = ���]���H�� info
		move.l	d2,(a0)+		*[12] PT RV ��]��

	NEXT_OBJ:

		.if	RV01=0
			add.w	(a1)+,d0	* SP_x += vx
		.else
			sub.w	(a1)+,d0	* SP_x -= vx
		.endif

		.if	RV10=0
			add.w	(a1)+,d1	* SP_y += vy
		.else
			sub.w	(a1)+,d1	* SP_y -= vy
		.endif

		cmp.w	a2,d0
		bcc.b	SKIP_OBJ_PUSH_2		* MAX���W <= SP_x �Ȃ� push ����
		cmp.w	a2,d1
		bcc.b	SKIP_OBJ_PUSH_2		* MAX���W <= SP_y �Ȃ� push ����

		move.w	d0,(a0)+		* SP_x ��]��
		move.w	d1,(a0)+		* SP_y ��]��

		move.l	(a1)+,d2		*[12] d2.l = PT RV
		eor.w	d3,d2			*[ 4] d2.w = ���]���H�� info
		move.l	d2,(a0)+		*[12] PT RV ��]��

		dbra.w	d4,OBJ_LOOP

EXIT_OBJ_LOOP:
	*-------[ �I�� ]
		move.l	a0,buff_pointer		* �o�b�t�@�|�C���^�ۑ�
		rts


SKIP_OBJ_PUSH_1:
	addq.w	#4,a1
	bra.b	NEXT_OBJ

SKIP_OBJ_PUSH_2:
	addq.w	#4,a1
	dbra.w	d4,OBJ_LOOP
	bra.b	EXIT_OBJ_LOOP

		.endm

*------------------------



OBJ_SET_ASM_RETURN:
	rts


_xobj_set_st_asm:
					*	a0.l = �\���̃A�h���X
	movem.w	(a0),d0-d3		*[8+4n]	d0.w = SP_x
					*	d1.w = SP_y
					*	d2.w = �����X�v���C�gpt
					*	d3.w = SP_info
					*	a0.l �͗p�ς�

_xobj_set_asm:
					* d0.w = SP_x
					* d1.w = SP_y
					* d2.w = �����X�v���C�g pt
					* d3.w = SP_info


*-------[ �Q�Ƃ��ׂ� sp_ref �̃A�h���X�����߂� ]
	lsl.w	#3,d2			* d2.w *= 8
	movea.l	sp_ref_adr(pc),a1	* a1.l = sp_ref_adr
	adda.w	d2,a1			* a1.w += pt*8
					* a1.l = �Q�Ƃ��ׂ� sp_ref �̃A�h���X
					* d2.w �� �p�ς�


*-------[ �K�v�����X�v���C�g�������߂� ]
	movea.l	buff_pointer(pc),a0
	move.l	#buff_end_adr_no_pc,d4	* d4.l = #buff_end_adr_no_pc�imove.w ���g����Ɨǂ����E�E�E�j
	sub.w	a0,d4			* d4.w -= a0.w
	asr.w	#3,d4			* d4.w /= 8
					* d4.w = push�\�X�v���C�g��(1�`)
	cmp.w	(a1)+,d4		* 
	ble.b	@F			* �K�v�����X�v���C�g�� >= d4 �Ȃ� bra
		move.w	-2(a1),d4	* d4.w = �K�v�����X�v���C�g��
@@:
	sub.w	#1,d4			* d4.w �� dbra �J�E���^�Ƃ��邽�� -1 ����B
	bmi.b	OBJ_SET_ASM_RETURN	* �K�v�����X�v���C�g�� <= 0 �Ȃ狭���I������


*-------[ ���̑��̏����� ]
	.if	SHIFT<>0
		asr.w	#SHIFT,d0
		asr.w	#SHIFT,d1
	.endif
					*------------------------------------------------------
					* d0.w = SP_x
					* d1.w = SP_y
					* d2.l = temp
					* d3.w = SP_info
					* d4.w = �K�v�����X�v���C�g�� - 1�idbra �J�E���^�Ƃ���j
					*------------------------------------------------------
					* a0.l = push ��
	movea.l	(a1),a1			* a1.l = sp_frm �ǂݏo���J�n�A�h���X
	move.w	#XY_MAX,a2		* a2.l = XY ���W����l
					*------------------------------------------------------


*=======[ �X�v���C�g���� ]

	move.w	d3,d2
	bmi	RV_1x_asm			* �㉺���]�F�P �Ȃ̂� bra

	*=======[ �㉺���]�F0  ���E���]�F? ]
RV_0x_asm:	add.w	d2,d2
		bmi.b	RV_01_asm		* ���E���]�F1 �Ȃ̂� bra

		*-------[ �㉺���]�F0  ���E���]�F0 ]
	RV_00_asm:	OBJ_WRITE_ASM	0,0

		*-------[ �㉺���]�F0  ���E���]�F1 ]
	RV_01_asm:	OBJ_WRITE_ASM	0,1

	*=======[ �㉺���]�F1  ���E���]�F? ]
RV_1x_asm:	add.w	d2,d2
		bmi.b	RV_11_asm			* ���E���]�F1 �Ȃ̂� bra

		*-------[ �㉺���]�F1  ���E���]�F0 ]
	RV_10_asm:	OBJ_WRITE_ASM	1,0

		*-------[ �㉺���]�F1  ���E���]�F1 ]
	RV_11_asm:	OBJ_WRITE_ASM	1,1


