*==========================================================================
*
*	xsp_out2(void *vsyncint_arg);
*
*==========================================================================

_xsp_out2:

A7ID	=	4+0*4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0*4 byte ]

*=======[ vsyncint_arg ���擾 ]
	movea.l	A7ID+arg1_l(sp),a1	* a1.l = vsyncint_arg

*=======[ xsp_out �ɔ�� ]
	bra.b	xsp_out_entry



*==========================================================================
*
*	xsp_out();
*
*==========================================================================

_xsp_out:

A7ID	=	4+11*4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 11*4 byte ]

*=======[ vsyncint_arg ���擾�i���݂��Ȃ��̂� NULL�j]
	suba.l	a1,a1			* a1.l = vsyncint_arg = NULL

xsp_out_entry:
*=======[ XSP �������`�F�b�N ]
	cmpi.b	#%0000_0011,XSP_flg
	beq.b	@F			* XSP ������������������Ă���Ȃ� bra

	*-------[ ����������������Ă��Ȃ� ]
		moveq.l	#-1,d0		* �߂�l = �1
		rts			* �������� rts

@@:

*=======[ �����p�o�b�t�@�����p�\�ɂȂ�܂ő҂� ]
					* a1.l = vsyncint_arg
wait_until_write_struct_is_free:
	move.l	write_struct(pc),a0			* a0.l = �����p�o�b�t�@�Ǘ��\����
	cmpa.l	disp_struct(pc),a0			* �\���p�o�b�t�@�Ǘ��\���̂Əd�Ȃ��Ă��邩�H
	beq.b	wait_until_write_struct_is_free		* �d�Ȃ��Ă���Ȃ�\���p�o�b�t�@���ύX�����܂ő҂B
	move.l	a1,vsyncint_arg(a0)			* vsyncint_arg ��ۑ�

*=======[ ���W�X�^�ޔ��Ȃ� ]
	movem.l	d2-d7/a2-a6,-(sp)	* ���W�X�^�ޔ�

	move.l	a7,a7_bak1		* �܂� A7 ��ۑ��B�{�֐����ł́A
					* �����v���ȊO�̃X�^�b�Npush��
					* �֎~����Ă���B

*=======[ �X�[�p�[�o�C�U�[���[�h�� ]
	suba.l	a1,a1
	iocs	_B_SUPER		* �X�[�p�[�o�C�U�[���[�h��
	move.l	d0,usp_bak		* ���X�X�[�p�[�o�C�U�[���[�h�Ȃ�Ad0.l = -1



*==========================================================================
*
*	������
*
*==========================================================================


*=======[ OX_mask �X�V�葱�� ]
	tst.w	OX_mask_renew
	beq.b	EXIT_OX_mask_renew

		clr.w	OX_mask_renew		* �X�V�t���O���N���A

	*-------[ OX_mask �X�V ]
		moveq.l	#0,d0			* d0.l = 0
		move.b	OX_level(pc),d1
		sub.b	#1,d1			* d1.b = OX_tbl ���� - 1
		moveq.l	#-1,d2			* d2.l = -1�id2.b = 255�j

		move.w	#255,d7			* d7.w = dbra �J�E���^ �� PCG �i���o�[
		move.w	#255*2,d6		* d6.w = d7.w * 2

		moveq.l	#0,d4			* d4.l = 0�i�}�X�N off �� PCG �� �ŏ��i���o�[�j
		moveq.l	#0,d5			* d5.l = 0�i�}�X�N off �� PCG �� �ő�i���o�[�j

		lea.l	OX_tbl_no_pc,a0		* a0.l = OX_tbl
		lea.l	OX_mask_no_pc,a1	* a1.l = OX_mask
		lea.l	pcg_rev_alt_no_pc,a2	* a2.l = pcg_rev_alt
		movea.l	pcg_alt_adr(pc),a3	* a3.l = pcg_alt

OX_mask_renew_LOOP:
		tst.b	(a1,d7.w)		* OX_mask on���H
		beq.b	OX_mask_off		* NO �Ȃ� bra
		*-------[ OX_mask on ]
OX_mask_on:		move.b	d2,(a0,d7.w)	* ���� = 255 �Ƃ���
			move.w	(a2,d6.w),d3	* d3.w = �}�X�N���ꂽ PCG �ɒ�`����Ă��� pt
			move.b	d0,(a3,d3.w)	* pcg_alt �N���A�i��`�j���j
			move.w	d2,(a2,d6.w)	* pcg_rev_alt �N���A�i��`�j���̏d��������j
			bra.b	OX_mask_NEXT

		*-------[ OX_mask off ]		* ���� == 255 �̏ꍇ�̂݁A���� = 1 �Ƃ���
OX_mask_off:		cmp.b	(a0,d7.w),d2	* ���� == 255 ���H
			bne.b	@f
				move.b	d1,(a0,d7.w)	* ���݂̐��� - 1 ����������
							* (�܂�Œ� 1 �^�[���҂��Ȃ���
							* �g�p�s�B�����Ȃ��Ə���������
							* �����Ă��܂��̂ł���B)
@@:
			move.w	d7,d4		* d4.w = �}�X�N off �� PCG �̍ŏ��i���o�[
			tst.w	d5
			bne.b	@f		* d5.w ���� 0 �Ȃ� bra
						*(�܂� d5.w �ݒ�͍ŏ��� 1 �񂫂�ł���)
				move.w	d7,d5	* d5.w = �}�X�N off �� PCG �̍ő�i���o�[
@@:
OX_mask_NEXT:
		sub.w	#2,d6
		dbra	d7,OX_mask_renew_LOOP

	*-------[ �����J�n�A�h���X�ƌ����T�C�Y - 1 �����߂� ]

		* �}�X�N off �� PCG ���P�������݂��Ȃ��������Ad4.w d5.w �Ƃ��� 0 �ł���B
		* ����āA�����T�C�Y - 1 = 0 �ƂȂ�A1 ������̌����ƂȂ�B
		* �܂��A�����J�n PCG �̃i���o�[�� 0 �ƂȂ�B0 �� PCG �͕K���u�g�p�v�ł���
		* ����A�܂� PCG ��`�͎������s����Ȃ����ƂɂȂ�B

						* a0.l = OX_tbl
		add.w	d4,a0			* a0.l = OX_tbl �����J�n�A�h���X
		move.l	a0,OX_chk_top		* OX_tbl �����J�n�A�h���X�ɕۑ�
		move.l	a0,OX_chk_ptr		* OX_tbl �����|�C���^�ɕۑ�
		sub.w	d4,d5			* d5.w = �����T�C�Y - 1
		move.w	d5,OX_chk_size		* OX_tbl �����T�C�Y - 1 �ɕۑ�

EXIT_OX_mask_renew:



*=======[ OX_tbl ���ʒ��� ]
OX_level_INC:
	lea.l	OX_level(pc),a0		* (a0).b = OX_level.b
	addq.b	#1,(a0)			* OX_level.b++
	cmpi.b	#255,(a0)
	bne	OX_level_INC_END	* (#255 != OX_level) �Ȃ� bra

	*-------[ ���ʂ̈����������� ]
		move.b	#4,(a0)		* OX_level.b = 4

		lea.l	OX_tbl_no_pc,a0	* a0.l = OX_tbl
		moveq.l	#0,d0		* d0.l = 0
		moveq.l	#31,d1		* d1.l = 31�idbra �J�E���^�j
@@:
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		move.b	(a0),d0
		move.b	OX_tbl_INIT_TBL(pc,d0.w),(a0)+
		dbra	d1,@B

		bra	OX_level_INC_END


OX_tbl_INIT_TBL:
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01

	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01

	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01

	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01
	dc.b	$01,$01,$01,$01 , $01,$01,$01,$01 , $01,$01,$01,$01 , $01,$02,$03,$FF


OX_level_INC_END:



*=======[ �g�p�X�v���C�g���Ȃǂ����߂� ]
	lea	buff_top_adr_no_pc,a0		* a0.l = #buff_top_adr_no_pc
	move.l	buff_pointer(pc),d0
	sub.l	a0,d0			* d0.w =�i���o�b�t�@��́j�X�v���C�g�� x 8

	move.w	sp_mode(pc),d1		* d1.w = sp_mode
	cmpi.w	#1,d1			* 128 �����[�h���H
	bne.b	@F			* NO �Ȃ� bra
		cmpi.w	#384*8,d0
		ble.b	EXIT_GET_TOTAL_SP	* #384*8 >= d0 �Ȃ� bra
			move.w	#384*8,d0	* 384 ���ȉ��ɏC��
			move.l	#buff_top_adr_no_pc+384*8,buff_pointer
			bra.b	EXIT_GET_TOTAL_SP
@@:
	cmpi.w	#128*8,d0
	bgt.b	@F			* #128*8 < d0 �Ȃ� bra
		moveq	#1,d1		* 128 ���ȉ��̏ꍇ�͈ꎞ�I�� 128 �����[�h
		bra.b	EXIT_GET_TOTAL_SP
@@:
	move.w	sp_mode(pc),d1		* 512 �����[�h�ɂ���

EXIT_GET_TOTAL_SP:
					* d0.w = ���H�ώg�p�X�v���C�g�� x 8
					* d1.w = ���H��sp_mode


*=======[ ���̑� ]
	move.l	write_struct(pc),a1	* a1.l = �����p�o�b�t�@�Ǘ��\����
	move.w	d1,buff_sp_mode(a1)	* �o�b�t�@�i���o�[�� sp_mode�ۑ�
	move.w	d0,buff_sp_total(a1)	* �o�b�t�@�i���o�[�� �X�v���C�g�� x 8 �ۑ�

					*--------------------------
					* d0.w = �X�v���C�g�� x 8
					* a0.l = #buff_top_adr
					*--------------------------



*==========================================================================
*
*	�X�v���C�g���H �� �`�F�C���쐬
*
*==========================================================================

					* d0.w = �X�v���C�g�� x 8
					* a0.l = #buff_top_adr

	clr.w	-2(a0)			* ���o�b�t�@ end_mark�iPR �� 0�j

*-------[ ���W�X�^������ ]
					*---------------------------------------------
	adda.w	d0,a0			* a0.l = ���o�b�t�@�X�L�����i���[���j
	lea.l	pr_top_tbl_no_pc,a1	* a1.l = PR �ʐ擪�e�[�u��
					* a2.l = 
	movea.l	pcg_alt_adr(pc),a3	* a3.l = pcg_alt
					* a4.l = 
					* a5.l = 
	lea.l	OX_tbl_no_pc,a6		* a6.l = OX_tbl
					* a7.l = PCG ��`�v���o�b�t�@
					*---------------------------------------------

*-------[ PCG ��`�v���o�b�t�@�� end_mark ]
	move.w	#-1,-(a7)		* pt �ɕ�
	subq.w	#4,a7			* �|�C���^�␳

*-------[ PR �ʐ擪�e�[�u��[32].l �̏����� ]
	move.l	#buff_end_adr_no_pc,d0	* d0.l = �I�_�_�~�[ PR �u���b�N�̃A�h���X
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7

					*	a1.l = PR �ʐ擪�e�[�u��
	lea.l	$40*4(a1),a1		*[8]	a1.l = PR �ʐ擪�e�[�u���̖��[
	movem.l	d0-d7,-(a1)		*[8+4n]
	movem.l	d0-d7,-(a1)		*[8+4n]
	movem.l	d0-d7,-(a1)		*[8+4n]
	movem.l	d0-d7,-(a1)		*[8+4n]
	movem.l	d0-d7,-(a1)		*[8+4n]
	movem.l	d0-d7,-(a1)		*[8+4n]
	movem.l	d0-d7,-(a1)		*[8+4n]
	movem.l	d0-d7,-(a1)		*[8+4n]
					* ���v 64.l ������


*=======[ �X�v���C�g���H & �`�F�C���쐬�i��c��ʃ��[�h�j]
					*---------------------------------------------
					* d0.w = tmp�ipt �ǂݎ�� & ���H�j
	moveq.l	#0,d1			* d1.w = PCG_No.w�ibit8�`�� 0�j
					* d2.w = �� info�i���� PR �`�F�b�N�p�j
	moveq.l	#0,d3			* d3.w = �� pr/16�ibit8�`�� 0�j
	moveq.l	#0,d4			* d4.w =(�� pr & 63) * 4�ibit8�`�� 0�j
					* d5.w = tmp�iinfo �ǂݎ�聕���H�j
	move.b	OX_level(pc),d6		* d6.b = OX_tbl ����
					* d7.w = ���� PR �A����
					*---------------------------------------------

	tst.w	vertical_flg		* �c��ʃ��[�h���H
	bne	VERTICAL_MODE		* YES �Ȃ� bra


	move.w	-4(a0),d0		*[12]	�ŏ��� pt
	move.w	-2(a0),d5		*[12]	�ŏ��� info

	bra.b	START_MK_CHAIN		*[10]


*-------[ PCG ��`�v�� ]
REQ_PCGDEF:
	move.w	d3,-(a0)		* �� pr/16 �]��
	move.w	d5,-(a0)		* [��:�F:PR].w �𖢉��H cd �Ƃ��ē]��
	move.w	d0,-(a7)		* ��`������ pt ��ۑ�
	move.l	a0,-(a7)		* pt �A�h���X��ۑ�

	addq.w	#1,d7			* �A�������Z
	subq.w	#8,a0			* �X�L�����|�C���^�ړ�

	move.w	(a0)+,d0		* d0.w = pt
	move.w	(a0)+,d5		* d5.w = info
	cmp.b	d2,d5			* ���� PR ���H
	bne.b	NOT_SAME_PR		* NO �Ȃ� bra

*-------[ ���[�v ]
MK_CHAIN_LOOP:
	move.b	(a3,d0.w),d1		* d1.w = PCG_No.
	beq.b	REQ_PCGDEF		* PCG ����`�Ȃ� PCG ��`�v��
	move.b	d6,(a6,d1.w)		* OX_tbl �Ɂu�g�p�v��������

	move.w	d3,-(a0)		* �� pr/16 ��]��
	move.b	d1,d5			* d5.w = [��:�F:PCG_No].w�i= cd�j
	move.w	d5,-(a0)		* ���H�� cd �]��

	addq.w	#1,d7			* �A�������Z
	subq.w	#8,a0			* �X�L�����|�C���^�ړ�

	move.w	(a0)+,d0		* d0.w = pt
	move.w	(a0)+,d5		* d5.w = info
	cmp.b	d2,d5			* ���� PR ���H
	beq.b	MK_CHAIN_LOOP		* YES �Ȃ� bra�i���m���� bra�j

*-------[ PR �ύX ]
NOT_SAME_PR:
					* a0.l = �ύX�O PR ���̐擪�A�h���X�iSP_x �̈ʒu�j
					* d4.w =(�ύX�O PR & 63)*4
	move.l	a0,(a1,d4.w)		* PR �ʐ擪�e�[�u���֕ۑ�
	move.w	d7,CHAIN_OFS(a0)	* �A�����ۑ�

START_MK_CHAIN:
	move.w	d5,d2			* d2.w = �ύX�� info�i���� PR �`�F�b�N�p�j
	move.b	d5,d4
	add.b	d4,d4
	add.b	d4,d4			* d4.w = (�ύX�� PR * 4) & 255 = (�ύX�� PR & 63) * 4
	move.l	(a1,d4.w),CHAIN_OFS-4(a0)	* NEXT �|�C���^�� PR �ʐ擪�A�h���X����������

	moveq.l	#-1,d7			* �A�����N���A
	move.b	d5,d3
	asr.w	#4,d3			* d3.w = ��pr/16
	bne.b	MK_CHAIN_LOOP		* �� 0 �Ȃ�J��Ԃ�

*-------[ 0 �Ȃ̂� end_mark �̉\���L�� ]
	move.b	#$10,d2			* pr = 0 ���A������� end_mark ����肱�ڂ��̂Ŗ������␳

	cmpa.l	#buff_top_adr_no_pc,a0	* �{���ɏI�_�܂ŃX�L�����������H
	bne.b	MK_CHAIN_LOOP		* NO �Ȃ�J��Ԃ�

	bra	PCG_DEF_1



*=======[ �X�v���C�g���H & �`�F�C���쐬�i�c��ʃ��[�h�j]
VERTICAL_MODE:

	move.w	#XY_MAX,a2		*[ 8]	a2.l = XY_MAX�i�c��� x,y ���H�p�j

	subq.w	#8,a0
	move.l	(a0),d0			*[12]	d0.l = �ŏ��� x , y
	neg.w	d0			*[ 4]	d0.w =- d0.w
	add.w	a2,d0			*[ 4]	d0.w += XY_MAX
	.if	SHIFT<>0
					*	SHIFT �� 0 �Ŗ����Ƃ��Axsp_set �n�֐��ɂāA
					*	�X�v���C�g���W�̌Œ菭���̃V�t�g�� 32bit ����
					*	�s���œK���̓s���A���� x ���W�̉��ʃr�b�g��
					*	y ���W�̏�ʃr�b�g�ɘR��o���Ay ���W�ɕ��̒l��
					*	������B���̏�Ԃ̂܂܏c��ʃ��[�h�� x y ��
					*	����������ƁAx ���W�ɕ��̒l�������Aend mark
					*	�ƌ�F�������B�����������邽�߁Ay ���W���
					*	�r�b�g�̃N���A���K�v�ɂȂ�B
					*	���̃I�[�o�[�w�b�h�́A�c��ʃ��[�h�̎�����
					*	������B
		andi.w	#511,d0		*[ 8]	y ���W��ʃr�b�g�̃N���A
	.endif
	swap	d0			*[ 4]	x,y ����
	move.l	d0,(a0)+		*[12]	���H�ς� x,y �]��

	move.w	(a0)+,d0		*[ 8]	d0.w = �ŏ��� pt
	move.w	(a0)+,d5		*[ 8]	d5.w = �ŏ��� info

	bra.b	START_MK_CHAIN_v	*[10]


*-------[ PCG ��`�v�� ]
REQ_PCGDEF_v:
	move.w	d0,-(a7)		*[ 8]	��`������pt��ۑ�

	move.w	d5,d0			*[ 4]	d0.w ��� 2 �r�b�g = ���]�R�[�h
	add.w	d0,d0			*[ 4]	��� 2 �r�b�g�� 01 ���� 10 �̎��AV=1
	bvc.b	@f			*[8,10]	V=0 �Ȃ� bra
		eor.w	#$C000,d5	*[ 8]	���]�R�[�h���H
@@:
	move.w	d3,-(a0)		*[ 8]	��pr/16 �]��
	move.w	d5,-(a0)		*[ 8]	[��:�F:PR].w �𖢉��H cd �Ƃ��ē]��
	move.l	a0,-(a7)		*[12]	pt �A�h���X��ۑ�

	addq.w	#1,d7			*[ 4]	�A�������Z
	lea.l	-12(a0),a0		*[ 8]	�X�L�����|�C���^�ړ�

	move.l	(a0),d0			*[12]	d0.l = x , y
	neg.w	d0			*[ 4]	d0.w = -d0.w
	add.w	a2,d0			*[ 4]	d0.w += XY_MAX
	.if	SHIFT<>0
		andi.w	#511,d0		*[ 8]	y ���W��ʃr�b�g�̃N���A
	.endif
	swap	d0			*[ 4]	x,y ����
	move.l	d0,(a0)+		*[12]	���H�ς� x,y �]��

	move.w	(a0)+,d0		*[ 8]	d0.w = pt
	move.w	(a0)+,d5		*[ 8]	d5.w = info
	cmp.b	d2,d5			*[ 4]	���� PR ���H
	bne.b	NOT_SAME_PR_v		*[8,10]	NO �Ȃ� bra

*-------[ ���[�v ]
MK_CHAIN_LOOP_v:
	move.b	(a3,d0.w),d1		*[14]	d1.w = PCG_No.
	beq.b	REQ_PCGDEF_v		*[8,10]
	move.b	d6,(a6,d1.w)		*[14]	OX_tbl �Ɂu�g�p�v��������

	move.w	d3,-(a0)		*[ 8]	�� pr/16 ��]��
	move.b	d1,d5			*[ 4]	d5.w = [��:�F:PCG_No].w�i��cd�j

	move.w	d5,d0			*[ 4]	d0.w ��� 2 �r�b�g = ���]�R�[�h
	add.w	d0,d0			*[ 4]	��� 2 �r�b�g�� 01 ���� 10 �̎��AV=1
	bvc.b	@f			*[8,10]	V=0 �Ȃ� bra
		eor.w	#$C000,d5	*[ 8]	���]�R�[�h���H
@@:
	move.w	d5,-(a0)		*[ 8]	���H�� cd �]��

	addq.w	#1,d7			*[ 4]	�A�������Z
	lea.l	-12(a0),a0		*[ 8]	�X�L�����|�C���^�ړ�

	move.l	(a0),d0			*[12]	d0.l = x , y
	neg.w	d0			*[ 4]	d0.w = -d0.w
	add.w	a2,d0			*[ 4]	d0.w += XY_MAX
	.if	SHIFT<>0
		andi.w	#511,d0		*[ 8]	y ���W��ʃr�b�g�̃N���A
	.endif
	swap	d0			*[ 4]	x,y ����
	move.l	d0,(a0)+		*[12]	���H�ς� x,y �]��

	move.w	(a0)+,d0		*[ 8]	d0.w = pt
	move.w	(a0)+,d5		*[ 8]	d5.w = info
	cmp.b	d2,d5			*[ 4]	���� PR ���H
	beq.b	MK_CHAIN_LOOP_v		*[8,10]	YES �Ȃ� bra�i���m���� bra�j

*-------[ PR �ύX ]
NOT_SAME_PR_v:
					* a0.l = �ύX�O PR ���̐擪�A�h���X�iSP_x �̈ʒu�j
					* d4.w =(�ύX�O PR & 63) * 4
	move.l	a0,(a1,d4.w)		* PR �ʐ擪�e�[�u���֕ۑ�
	move.w	d7,CHAIN_OFS(a0)	* �A�����ۑ�

START_MK_CHAIN_v:
	move.w	d5,d2			* d2.w = �ύX��info�i���� PR �`�F�b�N�p�j
	move.b	d5,d4
	add.b	d4,d4
	add.b	d4,d4			* d4.w = (�ύX�� PR * 4) & 255 = (�ύX�� PR & 63) * 4
	move.l	(a1,d4.w),CHAIN_OFS-4(a0)	* NEXT �|�C���^�� PR �ʐ擪�A�h���X����������

	moveq.l	#-1,d7			* �A�����N���A
	move.b	d5,d3
	asr.w	#4,d3			* d3.w = ��pr/16
	bne.b	MK_CHAIN_LOOP_v		* �� 0 �Ȃ�J��Ԃ�

*-------[ 0 �Ȃ̂� end_mark �̉\���L�� ]
	move.b	#$10,d2			* pr = 0 ���A������� end_mark ����肱�ڂ��̂Ŗ������␳

	cmpa.l	#buff_top_adr_no_pc,a0	* �{���ɏI�_�܂ŃX�L�����������H
	bne.b	MK_CHAIN_LOOP_v		* NO �Ȃ�J��Ԃ�




*==========================================================================
*
*	PCG ��`���� 1
*
*==========================================================================

PCG_DEF_1:
	move.l	write_struct(pc),a2	* a2.l = �����p�o�b�t�@�Ǘ��\����
	lea.l	vsync_def(a2),a2	* a2.l = �A������ PCG ��`�v���o�b�t�@
					* a3.l = pcg_alt
					* a6.l = OX_tbl
					* a7.l = PCG��`�v���o�b�t�@�|�C���^

*-------[ ������ ]
					*----------------------------------------------
					* a0.l = temp
					* a1.l = temp
					* a2.l = �A������ PCG ��`�v���o�b�t�@
					* a3.l = pcg_alt
	lea.l	pcg_rev_alt_no_pc,a4	* a4.l = pcg_rev_alt
	movea.l	OX_chk_ptr(pc),a5	* a5.l = OX_tbl �����|�C���^
					* a6.l = OX_tbl
					* a7.l = PCG ��`�v���o�b�t�@�|�C���^
					*----------------------------------------------
					* d0.w = temp�ipt �ǂ݂����j
					* d1.w = PCG_No.w�ibit8�`�̎��O�� 0 �N���A�K�v�Ȃ��j
					* d2.l = temp
					* d3.l = temp
	move.l	#$EB8000,d4		* d4.l = #$EB8000�i���ʂP�o�C�g�� 0 �̂����j
	move.l	pcg_dat_adr(pc),d5	* d5.l = PCG �f�[�^�A�h���X
					* d6.b = OX_tbl ����
	move.w	OX_chk_size(pc),d7	* d7.w = PCG ������ dbcc �J�E���^
					*----------------------------------------------

	move.b	d6,d2			* d2.b = OX_tbl ����
	subq.b	#2,d2			* d2.b = OX_tbl ���� - 2

	bra.b	PCG_DEF_1_START


*=======[ PCG ��`���� 1 ���S�I�� ]
PCG_DEF_1_END:
	bra	PCG_DEF_COMPLETE	* �u�����`���p


*-------[ ������ cd �̏C�����[�v ]
@@:
	move.b	d1,1(a0)		* ������ cd �C��
PCG_DEF_1_START:
	movea.l	(a7)+,a0		* a0.l = �C�����K�v�� cd �A�h���X
	move.w	(a7)+,d0		* d0.w = ��`���� pt
	bmi.b	PCG_DEF_1_END		* ���Ȃ犮�S�I��
PCG_DEF_1_L0:
	move.b	(a3,d0.w),d1		* d1.b = PCG_No.
	bne.b	@B			* ��`����Ă���Ȃ� bra

	*-------[ �� PCG ���� ]
@@:		cmp.b	(a5)+,d2	* < d2.b �Ȃ� 3 �t���[�����g�p
		dbhi	d7,@B		* ���Fcc �����Ń��[�v�𔲂��鎞�Ad7.w �̓f�N������Ȃ�
					* (cc���� && d7 >= 0) || (cc �s���� && d7 < 0)
		bls	PCG_DEF_2	* cc �s�����Ȃ� (���̎��K�� d7 < 0 && ��I�_) �s���S�I��

		tst.b	-(a5)		* end_mark(0) ���H
		bne.b	FOUND_PCG_1	* No �Ȃ� bra
		*-------[ ���g�p PCG �łȂ��Aend_mark ������ ]
			move.l	OX_chk_top(pc),a5	* OX_tbl �����|�C���^��擪�ɖ߂�
			bra.b	@B			* ���[�v
							* d7.w++ �␳�͕s�p�i��L���ӎQ�Ɓj

	*-------[ ���g�p PCG ���� ]
FOUND_PCG_1:
		move.w	a5,d1
		sub.w	a6,d1			* d1.w = a5.w - OX_tbl.w = PCG_No.
		move.b	d1,1(a0)		* ������ cd �C��
		move.b	d6,(a5)+		* OX_tbl �Ɍ��݂̐��ʂ�������

	*-------[ PCG �z�u�Ǘ��e�[�u������ ]
						*[d0.w = ��`���� pt (0�`0x7FFF)]
						*[d1.w = ��`�� PCG_No.(0�`255)]
		move.b	d1,(a3,d0.w)		* pcg_alt ������
		add.w	d1,d1			* d1.w = ��`�� PCG No.*2
						*[a4.l = pcg_rev_alt �A�h���X]
		move.w	(a4,d1.w),d3		* d3.w = �`���ׂ���� pt
		move.b	d4,(a3,d3.w)		* �`���ׂ���� pt �𖢒�`�ɂ���
		move.w	d0,(a4,d1.w)		* �V���� pcg_rev_alt ������

	*-------[ PCG ��`���s ]
		ext.l	d0			* d0.l = ��`���� pt
		lsl.l	#7,d0			* d0.l = ��`���� pt * 128
		add.l	d5,d0			* d0.l = PCG �f�[�^�A�h���X + pt * 128
						*      = �]����

		ext.l	d1			* d1.l = ��`�� PCG_No.* 2
		lsl.w	#6,d1			* d1.l = ��`�� PCG_No.* 128�i.w �Ŕj�]���Ȃ��j
		add.l	d4,d1			* d1.l = #$EB8000 + PCG_No.* 128
						*      = �]����

		movea.l	d0,a0
		movea.l	d1,a1

		.rept	32
			move.l	(a0)+,(a1)+	* 1 PCG �]��
		.endm

	*-------[ ���̃X�v���C�g�� ]
		dbra	d7,PCG_DEF_1_START

						* �s���S�I��
		movea.l	(a7)+,a0		* ���܍���
		move.w	(a7)+,d0		* ���܍���
		bmi	PCG_DEF_COMPLETE	* d0.w �����Ȃ犮�S�I��




*==========================================================================
*
*	PCG ��`���� 2�iPCG �����肸�A������ PCG ��`�v���j
*
*==========================================================================

PCG_DEF_2:
					*----------------------------------------------
					* a0.l = temp
					* a1.l = temp
					* a2.l = �A������ PCG ��`�v���o�b�t�@
					* a3.l = pcg_alt �A�h���X
					* a4.l = pcg_rev_alt �A�h���X
					* a5.l = OX_tbl �����|�C���^
					* a6.l = OX_tbl
					* a7.l = PCG ��`�v���o�b�t�@�|�C���^
					*----------------------------------------------
					* d0.w = temp�ipt �ǂ݂����j
					* d1.w = PCG_No.w�ibit8�`�̎��O�� 0 �N���A�K�v�Ȃ��j
	moveq.l	#30,d2			* d2.w = 31PCG �܂Ō������邽�߂� dbcc �J�E���^
					* d3.l = temp
					* d4.l = #$EB8000�i���ʂP�o�C�g�� 0 �̂����j
					* d5.l = PCG �f�[�^�A�h���X
					* d6.b = OX_tbl ����
	move.w	OX_chk_size(pc),d7	* d7.w = PCG ������ dbcc �J�E���^
					*----------------------------------------------
					* a0.l = PCG_DEF_1 �Ŗ������� �C����A�h���X
					* d0.w = PCG_DEF_1 �Ŗ������� pt

	bra.b	PCG_DEF_2_L0		* a0.l d0.w �̓ǂݏo�������͔�΂�


*=======[ PCG ��`���� 1 ���S�I�� ]
PCG_DEF_2_END:
	bra	PCG_DEF_COMPLETE	* �u�����`���p


*-------[ ������ cd �̏C�����[�v ]
@@:
	move.b	d1,1(a0)		* ������ cd �C��
PCG_DEF_2_START:
	movea.l	(a7)+,a0		* a0.l = �C�����K�v�� cd �A�h���X
	move.w	(a7)+,d0		* d0.w = ��`���� pt
	bmi.b	PCG_DEF_2_END		* ���Ȃ犮�S�I��
PCG_DEF_2_L0:
	move.b	(a3,d0.w),d1		* d1.b = PCG_No.
	bne.b	@B			* ��`����Ă���Ȃ� bra

	*-------[ �� PCG ���� ]
@@:		cmp.b	(a5)+,d6	* < d6.b �Ȃ獡��̃t���[���ɂ����Ė��g�p
		dbhi	d7,@B		* ���Fcc �����Ń��[�v�𔲂��鎞�Ad7.w �̓f�N������Ȃ�
					* (cc ���� && d7 >= 0) || (cc �s���� && d7 < 0)
		bls.b	PCG_DEF_3	* cc �s�����Ȃ� (���̎��K�� d7 < 0 && ��I�_) �s���S�I��

		tst.b	-(a5)		* end_mark(0) ���H
		bne.b	FOUND_PCG_2	* No �Ȃ� bra
		*-------[ ���g�p PCG �łȂ��Aend_mark ������ ]
			move.l	OX_chk_top(pc),a5	* OX_tbl �����|�C���^��擪�ɖ߂�
			bra.b	@B			* ���[�v
							* d7.w++ �␳�͕s�p�i��L���ӎQ�Ɓj

	*-------[ ���g�p PCG ���� ]
FOUND_PCG_2:
		move.w	a5,d1
		sub.w	a6,d1			* d1.w = a5.w - OX_tbl.w = PCG_No.
		move.b	d1,1(a0)		* ������ cd �C��
		move.b	d6,(a5)+		* OX_tbl�Ɍ��݂̐��ʂ�������

	*-------[ PCG �z�u�Ǘ��e�[�u������ ]
						*[d0.w = ��`���� pt (0�`0x7FFF)]
						*[d1.w = ��`�� PCG_No.(0�`255)]
		move.b	d1,(a3,d0.w)		* pcg_alt ������
		add.w	d1,d1			* d1.w = ��`�� PCG No.*2
						*[a4.l = pcg_rev_alt �A�h���X]
		move.w	(a4,d1.w),d3		* d3.w = �`���ׂ����pt
		move.b	d4,(a3,d3.w)		* �`���ׂ����pt�𖢒�`�ɂ���
		move.w	d0,(a4,d1.w)		* �V���� pcg_rev_alt ������

	*-------[ PCG ��`���s ]
		ext.l	d0			* d0.l = ��`����pt
		lsl.l	#7,d0			* d0.l = ��`����pt * 128
		add.l	d5,d0			* d0.l = PCG �f�[�^�A�h���X + pt * 128
						*      = �]����

		ext.l	d1			* d1.l = ��`�� PCG_No.* 2
		lsl.w	#6,d1			* d1.l = ��`�� PCG_No.* 128�i.w �Ŕj�]���Ȃ��j
		add.l	d4,d1			* d1.l = #$EB8000 + PCG_No.* 128
						*      = �]����

		move.l	d1,(a2)+		* �A������ PCG ��`�v���o�b�t�@�ցi�]����j
		move.l	d0,(a2)+		* �A������ PCG ��`�v���o�b�t�@�ցi�]�����j

	*-------[ ���̃X�v���C�g�� ]
		dbra	d2,@f
		bra.b	PCG_DEF_2_L1		* �A������ PCG ��`�v���o�b�t�@������Ȃ�
@@:
		dbra	d7,PCG_DEF_2_START


PCG_DEF_2_L1:
						* �s���S�I��
		movea.l	(a7)+,a0		* ���܍���
		move.w	(a7)+,d0		* ���܍���
		bmi.b	PCG_DEF_COMPLETE	* d0.w�����Ȃ犮�S�I��




*==========================================================================
*
*	PCG ��`���� 3�iPCG �����肸��`�v����艺���j
*
*==========================================================================

PCG_DEF_3:
	moveq.l	#0,d2			* d2.l = 0

	bra.b	PCG_DEF_3_L0		* a0.l d0.w �̓ǂݏo�������͔�΂�


*-------[ ������ cd �̏C�����[�v ]
@@:
	move.b	d1,1(a0)		* ������ cd �C��
PCG_DEF_3_START:
	movea.l	(a7)+,a0		* a0.l = �C�����K�v�� cd �A�h���X
	move.w	(a7)+,d0		* d0.w = ��`���� pt
	bmi.b	PCG_DEF_COMPLETE	* ���Ȃ�I��
PCG_DEF_3_L0:
	move.b	(a3,d0.w),d1		* d1.b = PCG_No.
	bne.b	@B			* ��`����Ă���Ȃ� bra
	*-------[ �������Ă��܂� ]
		move.w	d2,2(a0)	* pr �� 0�i�\�� off�j

		movea.l	(a7)+,a0	* a0.l = �C�����K�v�� cd �A�h���X
		move.w	(a7)+,d0	* d0.w = ��`���� pt
		bpl.b	PCG_DEF_3_L0	* end_mark �łȂ��Ȃ� bra


PCG_DEF_COMPLETE:
	move.l	#-1,(a2)		* �A������ PCG ��`�v���o�b�t�@�� end_mark ������
	move.l	a5,OX_chk_ptr		* OX_tbl �����|�C���^�ۑ�




*==========================================================================
*
*	PR �ʐ擪�A�h���X�̕K�v�Ȃ��̂��X�^�b�N�ɓ]��
*
*==========================================================================

LINK_CHAIN:

*-------[ ������ ]
	lea.l	buff_end_adr_no_pc,a0	* a0.l = �I�_�_�~�[ PR �u���b�N
	move.w	#-1,CHAIN_OFS(a0)	* �I�_�_�~�[�`�F�C���ɁAend_mark�i�A����-1�j��������
	move.l	a0,-(a7)		* �X�^�b�N�� end_mark �Ƃ��ď�������

	lea.l	pr_top_tbl_no_pc,a1	* a1.l = PR �ʐ擪�e�[�u��
	move.l	#-1,64*4(a1)		* PR �ʐ擪�e�[�u�����[�� end_mark(-1)������
	lea.l	$10*4(a1),a1		* pr >= $10 �ɋ����␳���Ă���̂ŁApr = $10 ���X�L����

*-------[ PR �ʐ擪���� ]
SEARCH_PR_TOP:
	move.l	(a1)+,d0		* d0.l = PR �ʐ擪�A�h���X
	bmi.b	LINK_CHAIN_END		* end_mark(-1)�Ȃ�I��
SEARCH_PR_TOP_:
	cmp.l	a0,d0			* �I�_�_�~�[ PR �u���b�N���w���Ă��邩�H
	beq.b	SEARCH_PR_TOP		* YES �Ȃ�X�L�b�v
	move.l	d0,-(a7)		* PR �ʐ擪�A�h���X���X�^�b�N�֓]��

	move.l	(a1)+,d0		* d0.l = PR �ʐ擪�A�h���X
	bpl.b	SEARCH_PR_TOP_		* end_mark(-1)�łȂ��Ȃ�J��Ԃ�

LINK_CHAIN_END:



*==========================================================================
*
*	sp_mode �ʃX�v���C�g�����i���X�^�������j
*
*==========================================================================

SP_RAS_SORT:

	move.l	write_struct(pc),a0	* a0.l = �����p�o�b�t�@�Ǘ��\����
	move.w	buff_sp_mode(a0),d0	* d0.w = ���H�� sp_mode
	cmpi.w	#2,d0			* �ő� 512 �����[�h���H
	beq.b	SP_RAS_SORT_mode2	* YES �Ȃ� bra
	cmpi.w	#3,d0			* �ő� 512 ���i�D��x�ی�j���[�h���H
	beq	SP_RAS_SORT_mode3	* YES �Ȃ� bra

*=======[ �ő� 128 �����[�h ]
SP_RAS_SORT_mode1:
	.include	XSP128.s
	bra	SP_RAS_SORT_END

*=======[ �ő� 512 �����[�h ]
SP_RAS_SORT_mode2:
	.include	XSP512.s
	bra	SP_RAS_SORT_END

*=======[ �ő� 512 ���i�D��x�ی�j���[�h ]
SP_RAS_SORT_mode3:
	.include	XSP512b.s

SP_RAS_SORT_END:



*==========================================================================
*
*	�����p�o�b�t�@���`�F���W
*
*==========================================================================


*=======[ �����p�o�b�t�@���`�F���W ]
	movea.l	write_struct(pc),a0	* a0.l = �����p�o�b�t�@�Ǘ��\���̃A�h���X
	lea.l	STRUCT_SIZE(a0),a0

	cmpa.l	#endof_XSP_STRUCT_no_pc,a0	* �I�_�܂ŒB�������H
	bne.b	@F				* No �Ȃ� bra
		lea.l	XSP_STRUCT_no_pc,a0	* a0.l = �o�b�t�@�Ǘ��\���� #0 �A�h���X
@@:
	move.l	a0,write_struct		* �����p�o�b�t�@�Ǘ��\���̃A�h���X ������
	addq.w	#1,penging_disp_count	* �ۗ���Ԃ̕\�����N�G�X�g�� �C���N�������g


*=======[ ���[�U�[���[�h�� ]
	move.l	usp_bak(pc),d0
	bmi.b	@F			* �X�[�p�[�o�C�U�[���[�h�����s����Ă�����߂��K�v����
		movea.l	d0,a1
		iocs	_B_SUPER	* ���[�U�[���[�h��
@@:

*-------[ �߂�l ]
	move.l	buff_pointer(pc),d0
	sub.l	#buff_top_adr_no_pc,d0
	asr.l	#3,d0				* �߂�l�����o�b�t�@��̃X�v���C�g��

	move.l	#buff_top_adr_no_pc,buff_pointer	* ���o�b�t�@�̃|�C���^��������

	movea.l	a7_bak1(pc),a7			* A7 ����
	movem.l	(sp)+,d2-d7/a2-a6		* ���W�X�^����
						* d0.l �͖߂�l

	rts



