*==========================================================================
*                      �X�v���C�g�Ǘ��V�X�e�� XSP
*==========================================================================


	.include	doscall.mac
	.include	iocscall.mac

	.globl	_xsp_vsync
	.globl	_xsp_vsync2
	.globl	_xsp_objdat_set
	.globl	_xsp_pcgdat_set
	.globl	_xsp_pcgmask_on
	.globl	_xsp_pcgmask_off
	.globl	_xsp_mode
	.globl	_xsp_vertical

	.globl	_xsp_on
	.globl	_xsp_off

	.globl	_xsp_set
	.globl	_xsp_set_st
	.globl	_xobj_set
	.globl	_xobj_set_st
	.globl	_xsp_set_asm
	.globl	_xsp_set_st_asm
	.globl	_xobj_set_asm
	.globl	_xobj_set_st_asm
	.globl	_xsp_out
	.globl	_xsp_out2

	.globl	_xsp_vsyncint_on
	.globl	_xsp_vsyncint_off
	.globl	_xsp_hsyncint_on
	.globl	_xsp_hsyncint_off

	.globl	_xsp_auto_adjust_divy
	.globl	_xsp_min_divh_set

	.globl	_xsp_divy_get

	.globl	_xsp_raster_ofs_for31khz_set
	.globl	_xsp_raster_ofs_for31khz_get
	.globl	_xsp_raster_ofs_for15khz_set
	.globl	_xsp_raster_ofs_for15khz_get

	.globl	_xsp_vsync_interval_set
	.globl	_xsp_vsync_interval_get


*==========================================================================
*
*	���l�f�[�^
*
*==========================================================================

COMPATIBLE	= 1		* �]���o�[�W�����Ɗ��S�Ȍ݊�����Ƃ��邩�H

SHIFT		= 0		* ���W �Œ菬���r�b�g��

SP_MAX		= 512		* �X�v���C�g push �\����

XY_MAX		= 272		* �X�v���C�g X ���W Y ���W����l�i���ʂł��j

MIN_DIVH_MIN	= 24		* min_divh �̍ŏ��l
MIN_DIVH_MAX	= 32		* min_divh �̍ő�l

CHAIN_OFS	= SP_MAX*8+8	* ���o�b�t�@ �� �`�F�C����� �ւ̃I�t�Z�b�g
CHAIN_OFS_div	= $30C0		* ���X�^�����o�b�t�@ �� �`�F�C����� �ւ̃I�t�Z�b�g

AER		= $003
IERA		= $007
IERB		= $009
ISRA		= $00F
ISRB		= $011
IMRA		= $013
IMRB		= $015



*==========================================================================
*
*	�X�^�b�N�t���[���̍쐬
*
*==========================================================================

	.offset 0

arg1_l	ds.b	2
arg1_w	ds.b	1
arg1_b	ds.b	1

arg2_l	ds.b	2
arg2_w	ds.b	1
arg2_b	ds.b	1

arg3_l	ds.b	2
arg3_w	ds.b	1
arg3_b	ds.b	1

arg4_l	ds.b	2
arg4_w	ds.b	1
arg4_b	ds.b	1

arg5_l	ds.b	2
arg5_w	ds.b	1
arg5_b	ds.b	1

arg6_l	ds.b	2
arg6_w	ds.b	1
arg6_b	ds.b	1




*==========================================================================
*
*	�\���̃t���[���̍쐬
*
*==========================================================================

	.offset 0

struct_top:
*--------------[ �e�o�b�t�@�i���o�[�ʃX�v���C�g���� x 8 ]
buff_sp_mode:	ds.w	1
buff_sp_total:	ds.w	1

*--------------[ ���X�^�ʕ����o�b�t�@�̐擪�A�h���X ]
div_buff:	ds.l	1

*--------------[ �A�����Ԋ��荞�݂̈��� ]
vsyncint_arg:	ds.l	1

*--------------[ �A������ PCG ��`�v���o�b�t�@ ]
vsync_def:	ds.b	8*31
		ds.b	8	* end_mark(-1)

*--------------[ 512 �����[�h�p���X�^���荞�݃^�C���`���[�g ]
*
*	XSP 2.00 ���_�̎����ł̓��X�^�[�����ʒu�͌Œ�ł���A
*	�ȉ��̂悤�Ȑݒ肾�����B
*
*	XSP_CHART_512sp_31k:		* �T�P�Q���@�R�P�j�g��
*		dc.w	32		* ���X�^�[�i���o�[
*		dc.l	sp_disp_on	* ���荞�ݐ�A�h���X
*		dc.w	24+(36+16)*2
*		dc.l	DISP_buff_C
*		dc.w	24+(36+32+16)*2
*		dc.l	DISP_buff_D
*		dc.w	24+(36+32+36+16)*2
*		dc.l	DISP_buff_E
*		dc.w	24+(36+32+36+32+16)*2
*		dc.l	DISP_buff_F
*		dc.w	24+(36+32+36+32+36+16)*2
*		dc.l	DISP_buff_G
*		dc.w	24+(36+32+36+32+36+32+16)*2
*		dc.l	DISP_buff_H
*		dc.w	-1		* end_mark
*		dc.l	0		* �_�~�[
*
*	XSP_CHART_512sp_15k:		* �T�P�Q���@�P�T�j�g��
*		dc.w	12		* ���X�^�[�i���o�[
*		dc.l	sp_disp_on	* ���荞�ݐ�A�h���X
*		dc.w	0+(36+16)
*		dc.l	DISP_buff_C
*		dc.w	0+(36+32+16)
*		dc.l	DISP_buff_D
*		dc.w	0+(36+32+36+16)
*		dc.l	DISP_buff_E
*		dc.w	0+(36+32+36+32+16)
*		dc.l	DISP_buff_F
*		dc.w	0+(36+32+36+32+36+16)
*		dc.l	DISP_buff_G
*		dc.w	0+(36+32+36+32+36+32+16)
*		dc.l	DISP_buff_H
*		dc.w	-1		* end_mark
*		dc.l	0		* �_�~�[
*
XSP_chart_for_512sp_31khz:
		ds.b	6	* sp_disp_on
		ds.b	6	* DISP_buff_C
		ds.b	6	* DISP_buff_D
		ds.b	6	* DISP_buff_E
		ds.b	6	* DISP_buff_F
		ds.b	6	* DISP_buff_G
		ds.b	6	* DISP_buff_H
		ds.b	6	* end_mark

XSP_chart_for_512sp_15khz:
		ds.b	6	* sp_disp_on
		ds.b	6	* DISP_buff_C
		ds.b	6	* DISP_buff_D
		ds.b	6	* DISP_buff_E
		ds.b	6	* DISP_buff_F
		ds.b	6	* DISP_buff_G
		ds.b	6	* DISP_buff_H
		ds.b	6	* end_mark

*--------------
struct_end:


STRUCT_SIZE	=	struct_end - struct_top




*==========================================================================
*
*	�֐��Q�̃C���N���[�h
*
*==========================================================================

	.text
	.even

	.include	XSPset.s

	.include	XSPsetas.s

	.include	XSPfnc.s

	.include	XSPout.s




*==========================================================================
*
*	���荞�݂ɂ�� �X�v���C�g�\��
*
*==========================================================================



*--------------------------------------------------------------------------
*
*	�A�����Ԋ��荞�݃T�u���[�`��
*
*--------------------------------------------------------------------------

VSYNC_INT:

	movem.l	d0-d7/a0-a6,-(a7)	* ���W�X�^�ޔ�

	move.w	#1023,$E80012		* ���X�^���荞�� off
	addq.w	#1,vsync_count		* VSYNC �J�E���^�C���N��
	addq.w	#1,R65535		* XSP �����J�E���^�C���N��


*=======[ ���荞�݃}�X�N�ɏ��׍H ]	* �A�����Ԋ����ݒ��Ƀ��X�^�����݂�������悤�ɏ��׍H
	ori.w	#$0700,sr

	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	IMRA(a0),-(a7)		* IMRA �ۑ�
	move.b	IMRB(a0),-(a7)		* IMRB �ۑ�
	andi.b	#%0101_1110,IMRA(a0)	* �}�X�N�ɏ��׍H
	andi.b	#%1011_0111,IMRB(a0)	* �}�X�N�ɏ��׍H
					*	�r�b�g�� 0 = �}�X�N���
					*	1)�����������荞��
					*	2)�^�C�}�[ A/B
					*	3)�����������荞��
					*	4)FM ���� IC �̊��荞��
					*	�ȏ���}�X�N����


*=======[ �\���p�o�b�t�@���`�F���W ]
	subq.w	#1,vsync_interval_count_down
	bne.b	skip_change_disp_struct			* vsync_interval_count_down != 0 �Ȃ� bra
							* vsync_interval_count_down �̃��Z�b�g
		move.w	vsync_interval_count_max(pc),vsync_interval_count_down

		movea.l	disp_struct(pc),a0		* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
		lea.l	STRUCT_SIZE(a0),a0		* �\���̃T�C�Y���i�߂�

		cmpa.l	#endof_XSP_STRUCT_no_pc,a0	* �I�_�܂ŒB�������H
		bne.b	@F				* No �Ȃ� bra
			lea.l	XSP_STRUCT_no_pc,a0	* �擪�ɖ߂�
@@:
		cmpa.l	write_struct(pc),a0		* �����p�o�b�t�@�Ǘ��\���̂Əd�Ȃ��Ă��邩�H
		beq.b	@F				* �d�Ȃ��Ă���Ȃ� bra
			move.l	a0,disp_struct		* �\���p�o�b�t�@�Ǘ��\���̃A�h���X �X�V
			subq.w	#1,penging_disp_count	* �ۗ���Ԃ̕\�����N�G�X�g�� �f�N�������g
@@:
skip_change_disp_struct:

*=======[ 768*512 dot mode ���H ]
	btst.b	#1,$E80029		* 768*512 mode �Ȃ� bit1=1
	bne	VSYNC_RTE		* 768*512 mode �Ȃ� �����I��


*=======[ �X�v���C�g�\�� off ]
	bclr.b	#1,$EB0808		* sp_disp(0)


*=======[ ���X�^���荞�݃^�C���`���[�g�̎w�� & ����̊��荞�݂̎w�� ]
	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X

	btst.b	#4,$E80029		* [inside68k p.233 ]
					* bit4 =( 15Khz��=0 / 31Khz��=1 )
	beq.b	_15khz

	*-------[ 31khz ]
_31khz:		cmpi.w	#1,buff_sp_mode(a0)	* buff_sp_mode == 1 ���H
		bne.b	@F			* NO �Ȃ� bra
		*-------[ buff_sp_mode == 1 ]
			lea.l	XSP_chart_for_128sp_31khz(pc),a0
			bra.b	RAS_INT_init
		*-------[ buff_sp_mode != 1 ]
@@:			lea.l	XSP_chart_for_512sp_31khz(a0),a0
			bra.b	RAS_INT_init

	*-------[ 15khz ]
_15khz:		cmpi.w	#1,buff_sp_mode(a0)	* buff_sp_mode == 1 ���H
		bne.b	@F			* NO �Ȃ� bra
		*-------[ buff_sp_mode == 1 ]
			lea.l	XSP_chart_for_128sp_15khz(pc),a0
			bra.b	RAS_INT_init
		*-------[ buff_sp_mode != 1 ]
@@:			lea.l	XSP_chart_for_512sp_15khz(a0),a0
		*!!	bra.b	RAS_INT_init


RAS_INT_init:
					* a0.l = XSP ���`���[�g�̃|�C���^
	movea.l	usr_chart(pc),a1	* a1.l = USR ���`���[�g�̃|�C���^
	move.l	a0,xsp_chart_ptr	*[20] �|�C���^�ۑ�
	move.l	a1,usr_chart_ptr	*[20] �|�C���^�ۑ�

	move.w	(a0)+,d0		*[ 8] d0.w = XSP �����񊄂荞�݃��X�^�i���o�[
	move.w	(a1)+,d1		*[ 8] d1.w = USR �����񊄂荞�݃��X�^�i���o�[

	cmp.w	d0,d1			*[ 4] �����X�^�i���o�[��r
	bcs.b	_NEXT_USR		*[8,10] d0 > d1�i���������j�Ȃ� bra
	beq.b	_XSP_equ_USR		*[8,10] �������Ȃ�A���荞�ݏՓ�or�I�_

	*-------[ d0 < d1 �Ȃ̂ŁA����� XSP �������荞�� ]
_NEXT_XSP:	move.l	(a0)+,hsyncint_sub	*[28] ����T�u���[�`���A�h���X�ݒ�
		move.l	a0,xsp_chart_ptr	*[20] �|�C���^�ۑ�
		move.w	d0,$E80012		*[16] ���񊄂荞�݃��X�^�i���o�[�ݒ�
		bra.b	RAS_INT_init_END

	*-------[ d0 > d1 �Ȃ̂ŁA����� USR �������荞�� ]
_NEXT_USR:	move.l	(a1)+,hsyncint_sub	*[28] ����T�u���[�`���A�h���X�ݒ�
		move.l	a1,usr_chart_ptr	*[20] �|�C���^�ۑ�
		move.w	d1,$E80012		*[16] ���񊄂荞�݃��X�^�i���o�[�ݒ�
		bra.b	RAS_INT_init_END

	*-------[ d0 == d1 �Ȃ̂ŁA���荞�ݏՓ� or �I�_ ]
_XSP_equ_USR:	tst.w	d0
		bmi.b	_RAS_INT_endmark	*[8,10] ���Ȃ� bra
		*-------[ ���荞�ݏՓ˂ƌ��Ȃ� ]
			move.l	#RAS_INT_conflict,hsyncint_sub	*[28] ����T�u���[�`���A�h���X�ݒ�
			addq.w	#4,a0				*[ 8] �|�C���^�␳
			move.l	a0,xsp_chart_ptr		*[20] �|�C���^�ۑ�
			addq.w	#4,a1				*[ 8] �|�C���^�␳
			move.l	a1,usr_chart_ptr		*[20] �|�C���^�ۑ�
			move.w	d0,$E80012			*[16] ���񊄂荞�݃��X�^�i���o�[�ݒ�
			bra.b	RAS_INT_init_END

		*-------[ �I�_�ƌ��Ȃ� ]
_RAS_INT_endmark:	move.l	#dummy_proc,hsyncint_sub	*[28] ����T�u���[�`���A�h���X�ݒ�
			move.w	#1023,$E80012			*[16] ���񊄂荞�݃��X�^�i���o�[�ݒ�


RAS_INT_init_END:
	andi.w	#$FDFF,sr		* �����݃}�X�N���x�� 5�i���荞�݋��j


*=======[ ���[�U�[�w��A�����Ԋ��荞�݃T�u���[�`���̎��s ]
	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
	move.l	vsyncint_arg(a0),-(sp)	* ���� push
	movea.l	vsyncint_sub(pc),a0
	jsr	(a0)
	addq.w	#4,sp			* �X�^�b�N�␳


*=======[ �X�v���C�g�\�� ]
DISP_buff_AB:
	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
	cmpi.w	#1,buff_sp_mode(a0)	* buff_sp_mode == 1 ���H
	bne.b	@F			* NO �Ȃ� bra
	*-------[ buff_sp_mode == 1 �̏ꍇ ]
		movea.l	div_buff(a0),a5		* a5.l = �\���p div_buff_A �A�h���X
						*      = �X�v���C�g�]�����A�h���X
		move.w	buff_sp_total(a0),d0	* d0.w = �]����*8
		bsr	SP_TRANS
		bra.b	DISP_buff_AB_END

	*-------[ buff_sp_mode != 1 �̏ꍇ ]
@@:		move.w	#128*8,d7		* d7.w = �X�v���C�g�N���A��*8
		movea.l	#$EB0000,a6		* a6.l = �X�v���C�g�N���A�J�n�A�h���X
		bsr	SP_CLEAR		* �܂��S�X�v���C�g�N���A
						* �j��Fd5-d7/a6

						* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
		movea.l	div_buff(a0),a0		* a0.l = �\���p div_buff_A �A�h���X
		movea.l	a0,a6			* a0.l �� a6.l �ɑޔ�
						* a0.l = �]�����A�h���X
		movea.l	#$EB0000,a1		* a1.l = �]����A�h���X�i�����ԍ��X�v���C�g�j
		bsr	SP_TRANS_div		* �`�F�C���]�����s
						* �j��Fa0.l a1.l a2.l d0.w

		lea.l	65*8(a6),a0		* a0.l = �\���p div_buff_B �A�h���X
						* a0.l = �]�����A�h���X
		movea.l	#$EB0008,a1		* a1.l = �]����A�h���X�i��ԍ��X�v���C�g�j
		bsr	SP_TRANS_div		* �`�F�C���]�����s

DISP_buff_AB_END:


*=======[ �A������ PCG ��`���s ]
	move.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\����
	lea.l	vsync_def(a0),a0	* a0.l = �A������ PCG ��`�v���o�b�t�@

	move.l	(a0),d0			* d0.l = �]���� PCG �A�h���X
	bmi.b	vsync_PCG_DEF_END	* �����Ȃ� end_mark(-) �Ȃ� PCG ��`���s����
	move.l	#-1,(a0)+		* end_mark �����݁i����Ē�`�� 1 �񂫂�j
	movea.l	d0,a1			* a1.l = �]���� PCG �A�h���X

@@:
	move.l	(a0)+,a2		* a2.l = PCG �f�[�^�]�����A�h���X

	movem.l	(a2)+,d0-d7/a3-a5
	movem.l	d0-d7/a3-a5,(a1)	* 11.l

	movem.l	(a2)+,d0-d7/a3-a5
	movem.l	d0-d7/a3-a5,11*4(a1)	* 11.l

	movem.l	(a2)+,d0-d7/a3-a4
	movem.l	d0-d7/a3-a4,11*8(a1)	* 10.l
					* ���v 32.l = 1 PCG

	move.l	(a0)+,a1		* a1.l = ��`�� PCG �A�h���X
	move.l	a1,d0
	bpl.b	@B			* end_mark �łȂ��Ȃ�J��Ԃ�


vsync_PCG_DEF_END:


*=======[ RTE ]
VSYNC_RTE:
	ori.w	#$0700,sr		* ���荞�݃}�X�N���x�� 7�i���荞�݋֎~�j
	bsr	WAIT			* 68030 �΍�

	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	(a7)+,IMRB(a0)		* IMRB ����
	move.b	(a7)+,IMRA(a0)		* IMRA ����

	movem.l	(a7)+,d0-d7/a0-a6	* ���W�X�^����
	rte




*--------------------------------------------------------------------------
*
*	���X�^���荞�݊Ď����[�`��
*
*	�@�\�FXSP ���� USR ���̗��^�C���`���[�g���Q�Ƃ��A���̓��e�ɏ]����
*             ���荞�ݏ��������s����B�����荞�݂��Փ˂���ꍇ�AUSR ����
*             ���荞�݃^�C�~���O��D�悷��iXSP ���͒x��Ď��s�����j�B
*
*--------------------------------------------------------------------------

RAS_INT:
	movem.l	d0-d2/a0-a2,-(a7)	*[8+8*6 = 56] ���W�X�^�ޔ�

	movea.l	xsp_chart_ptr(pc),a0	*[16] a0.l = XSP ���`���[�g�̃|�C���^
	movea.l	usr_chart_ptr(pc),a1	*[16] a1.l = USR ���`���[�g�̃|�C���^
	move.w	(a0)+,d0		*[ 8] d0.w = XSP �����񊄂荞�݃��X�^�i���o�[
	move.w	(a1)+,d1		*[ 8] d1.w = USR �����񊄂荞�݃��X�^�i���o�[

	cmp.w	d0,d1			*[ 4] �����X�^�i���o�[��r
	bcs.b	NEXT_USR		*[8,10] d0 > d1�i���������j�Ȃ� bra
	beq.b	XSP_equ_USR		*[8,10] �������Ȃ�A���荞�ݏՓ� or �I�_

	*-------[ d0 < d1 �Ȃ̂ŁA����� XSP �������荞�� ]
NEXT_XSP:	move.l	hsyncint_sub(pc),a2	*[16] a2.l = �T�u���[�`���A�h���X
		move.l	(a0)+,hsyncint_sub	*[28] ����T�u���[�`���A�h���X�ݒ�
		move.l	a0,xsp_chart_ptr	*[20] �|�C���^�ۑ�
		move.w	d0,$E80012		*[16] ���񊄂荞�݃��X�^�i���o�[�ݒ�
		jsr	(a2)			*[16] �T�u���[�`�����s
		movem.l	(a7)+,d0-d2/a0-a2	*[12+8*6 = 60] ���W�X�^����
		rte

	*-------[ d0 > d1 �Ȃ̂ŁA����� USR �������荞�� ]
NEXT_USR:	move.l	hsyncint_sub(pc),a2	*[16] a2.l = �T�u���[�`���A�h���X
		move.l	(a1)+,hsyncint_sub	*[28] ����T�u���[�`���A�h���X�ݒ�
		move.l	a1,usr_chart_ptr	*[20] �|�C���^�ۑ�
		move.w	d1,$E80012		*[16] ���񊄂荞�݃��X�^�i���o�[�ݒ�
		jsr	(a2)			*[16] �T�u���[�`�����s
		movem.l	(a7)+,d0-d2/a0-a2	*[12+8*6 = 60] ���W�X�^����
		rte

	*-------[ d0 == d1 �Ȃ̂ŁA���荞�ݏՓ� or �I�_ ]
XSP_equ_USR:	tst.w	d0
		bmi.b	RAS_INT_endmark		*[8,10] ���Ȃ� bra
		*-------[ ���荞�ݏՓ˂ƌ��Ȃ� ]
			move.l	hsyncint_sub(pc),a2		*[16] a2.l = �T�u���[�`���A�h���X
			move.l	#RAS_INT_conflict,hsyncint_sub	*[28] ����T�u���[�`���A�h���X�ݒ�
			addq.w	#4,a0				*[ 8] �|�C���^�␳
			move.l	a0,xsp_chart_ptr		*[20] �|�C���^�ۑ�
			addq.w	#4,a1				*[ 8] �|�C���^�␳
			move.l	a1,usr_chart_ptr		*[20] �|�C���^�ۑ�
			move.w	d0,$E80012			*[16] ���񊄂荞�݃��X�^�i���o�[�ݒ�
			jsr	(a2)				*[16] �T�u���[�`�����s
			movem.l	(a7)+,d0-d2/a0-a2		*[12+8*6 = 60] ���W�X�^����
			rte

		*-------[ �I�_�ƌ��Ȃ� ]
RAS_INT_endmark:	move.l	hsyncint_sub(pc),a2		*[16] a2.l = �T�u���[�`���A�h���X
			move.l	#dummy_proc,hsyncint_sub	*[28] ����T�u���[�`���A�h���X�ݒ�
			move.w	#1023,$E80012			*[16] ���񊄂荞�݃��X�^�i���o�[�ݒ�
			jsr	(a2)				*[16] �T�u���[�`�����s
			movem.l	(a7)+,d0-d2/a0-a2		*[12+8*6 = 60] ���W�X�^����
			rte


*=======[ ���荞�݃��X�^�i���o�[�Փ˂̏ꍇ ]
RAS_INT_conflict:
	movea.l	usr_chart_ptr(pc),a0	*[16] a0.l = USR ���`���[�g�̃|�C���^
	movea.l	-4(a0),a0		*[16] a0.l = �T�u���[�`���A�h���X
	jsr	(a0)			*[16] �T�u���[�`�����s

	movea.l	xsp_chart_ptr(pc),a0	*[16] a0.l = XSP ���`���[�g�̃|�C���^
	movea.l	-4(a0),a0		*[16] a0.l = �T�u���[�`���A�h���X
	jsr	(a0)			*[16] �T�u���[�`�����s

	rts


*===============[ ���X�^���荞�݊Ǘ��^�C���`���[�g ]
	.even
				* 31KHz�F�����݃��X�^ No. = (Y ���W) * 2 + 32
				* 15KHz�F�����݃��X�^ No. = (Y ���W) + 12

XSP_chart_for_128sp_31khz:	* 128 �� 31 KHz
	dc.w	34		* ���X�^�i���o�[
	dc.l	sp_disp_on	* ���荞�ݐ�A�h���X
	dc.w	-1		* end_mark
	dc.l	0		* �_�~�[


XSP_chart_for_128sp_15khz:	* 128 �� 15 KHz
	dc.w	12		* ���X�^�i���o�[
	dc.l	sp_disp_on	* ���荞�ݐ�A�h���X
	dc.w	-1		* end_mark
	dc.l	0		* �_�~�[


dummy_chart:			* ���X�^���荞�� OFF
	dc.w	-1		* end_mark
	dc.l	0		* �_�~�[



*--------------------------------------------------------------------------
*
*	�e�탉�X�^���荞�ݎ��s�T�u���[�`��
*
*--------------------------------------------------------------------------

sp_disp_on:
	bset.b	#1,$EB0808		* sp_disp(1)
	rts

dummy_proc:
	rts


DISP_buff_C:
	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7

	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	IMRA(a0),-(a7)		* IMRA �ۑ�
	move.b	IMRB(a0),-(a7)		* IMRB �ۑ�
	andi.b	#%0101_1110,IMRA(a0)	* �}�X�N�ɏ��׍H
	andi.b	#%1111_0111,IMRB(a0)	* �}�X�N�ɏ��׍H

	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
	andi.w	#$FDFF,sr		* �����݃}�X�N���x�� 5
	movea.l	div_buff(a0),a0		* a0.l = �\���p div_buff_A �A�h���X
	lea.l	65*8*2(a0),a0		* a0.l = �\���p div_buff_C �A�h���X
	movea.l	#$EB0000,a1		* a1.l = �]����A�h���X�i�����ԍ��X�v���C�g�j
	bsr	SP_TRANS_div		* �`�F�C���]�����s

	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7
	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	(a7)+,IMRB(a0)		* IMRB ����
	move.b	(a7)+,IMRA(a0)		* IMRA ����
	rts


DISP_buff_D:
	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7

	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	IMRA(a0),-(a7)		* IMRA �ۑ�
	move.b	IMRB(a0),-(a7)		* IMRB �ۑ�
	andi.b	#%0101_1110,IMRA(a0)	* �}�X�N�ɏ��׍H
	andi.b	#%1111_0111,IMRB(a0)	* �}�X�N�ɏ��׍H

	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
	andi.w	#$FDFF,sr		* �����݃}�X�N���x�� 5
	movea.l	div_buff(a0),a0		* a0.l = �\���p div_buff_A �A�h���X
	lea.l	65*8*3(a0),a0		* a0.l = �\���p div_buff_D �A�h���X
	movea.l	#$EB0008,a1		* a1.l = �]����A�h���X�i��ԍ��X�v���C�g�j
	bsr	SP_TRANS_div		* �`�F�C���]�����s

	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7
	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	(a7)+,IMRB(a0)		* IMRB ����
	move.b	(a7)+,IMRA(a0)		* IMRA ����
	rts


DISP_buff_E:
	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7

	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	IMRA(a0),-(a7)		* IMRA �ۑ�
	move.b	IMRB(a0),-(a7)		* IMRB �ۑ�
	andi.b	#%0101_1110,IMRA(a0)	* �}�X�N�ɏ��׍H
	andi.b	#%1111_0111,IMRB(a0)	* �}�X�N�ɏ��׍H

	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
	andi.w	#$FDFF,sr		* �����݃}�X�N���x�� 5
	movea.l	div_buff(a0),a0		* a0.l = �\���p div_buff_A �A�h���X
	lea.l	65*8*4(a0),a0		* a0.l = �\���p div_buff_E �A�h���X
	movea.l	#$EB0000,a1		* a1.l = �]����A�h���X�i�����ԍ��X�v���C�g�j
	bsr	SP_TRANS_div		* �`�F�C���]�����s

	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7
	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	(a7)+,IMRB(a0)		* IMRB ����
	move.b	(a7)+,IMRA(a0)		* IMRA ����
	rts


DISP_buff_F:
	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7

	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	IMRA(a0),-(a7)		* IMRA �ۑ�
	move.b	IMRB(a0),-(a7)		* IMRB �ۑ�
	andi.b	#%0101_1110,IMRA(a0)	* �}�X�N�ɏ��׍H
	andi.b	#%1111_0111,IMRB(a0)	* �}�X�N�ɏ��׍H

	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
	andi.w	#$FDFF,sr		* �����݃}�X�N���x�� 5
	movea.l	div_buff(a0),a0		* a0.l = �\���p div_buff_A �A�h���X
	lea.l	65*8*5(a0),a0		* a0.l = �\���p div_buff_F �A�h���X
	movea.l	#$EB0008,a1		* a1.l = �]����A�h���X�i��ԍ��X�v���C�g�j
	bsr	SP_TRANS_div		* �`�F�C���]�����s

	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7
	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	(a7)+,IMRB(a0)		* IMRB ����
	move.b	(a7)+,IMRA(a0)		* IMRA ����
	rts


DISP_buff_G:
	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7

	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	IMRA(a0),-(a7)		* IMRA �ۑ�
	move.b	IMRB(a0),-(a7)		* IMRB �ۑ�
	andi.b	#%0101_1110,IMRA(a0)	* �}�X�N�ɏ��׍H
	andi.b	#%1111_0111,IMRB(a0)	* �}�X�N�ɏ��׍H

	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
	andi.w	#$FDFF,sr		* �����݃}�X�N���x�� 5
	movea.l	div_buff(a0),a0		* a0.l = �\���p div_buff_A �A�h���X
	lea.l	65*8*6(a0),a0		* a0.l = �\���p div_buff_G �A�h���X
	movea.l	#$EB0000,a1		* a1.l = �]����A�h���X�i�����ԍ��X�v���C�g�j
	bsr	SP_TRANS_div		* �`�F�C���]�����s

	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7
	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	(a7)+,IMRB(a0)		* IMRB ����
	move.b	(a7)+,IMRA(a0)		* IMRA ����
	rts


DISP_buff_H:
	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7

	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	IMRA(a0),-(a7)		* IMRA �ۑ�
	move.b	IMRB(a0),-(a7)		* IMRB �ۑ�
	andi.b	#%0101_1110,IMRA(a0)	* �}�X�N�ɏ��׍H
	andi.b	#%1111_0111,IMRB(a0)	* �}�X�N�ɏ��׍H

	movea.l	disp_struct(pc),a0	* a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
	andi.w	#$FDFF,sr		* �����݃}�X�N���x�� 5
	movea.l	div_buff(a0),a0		* a0.l = �\���p div_buff_A �A�h���X
	lea.l	65*8*7(a0),a0		* a0.l = �\���p div_buff_H �A�h���X
	movea.l	#$EB0008,a1		* a1.l = �]����A�h���X�i��ԍ��X�v���C�g�j
	bsr	SP_TRANS_div		* �`�F�C���]�����s

	ori.w	#$0700,sr		* �����݃}�X�N���x�� 7
	movea.l	#$e88000,a0		* a0.l = MFP �A�h���X
	move.b	(a7)+,IMRB(a0)		* IMRB ����
	move.b	(a7)+,IMRA(a0)		* IMRA ����
	rts






*==========================================================================
*
*	�_�ŕ\���Ή��X�v���C�g 128 ���]���T�u���[�`��
*
*	SP_TRANS
*
*	�����F	a0.l = �\���p�o�b�t�@�Ǘ��\���̃A�h���X
*		a5.l = �]�����A�h���X
*		d0.w = �X�v���C�g�� x 8
*
*	�j��F	�S���W�X�^
*
*==========================================================================

SP_TRANS:
	movea.l	#$EB0000,a6		* a6.l = �X�v���C�g�]����A�h���X

	cmpi.w	#129*8,d0		* 129 ���ȏォ�H
	bge.b	@F			* YES �Ȃ� bra

*=======[ 128 ���ȉ� ]
	cmpi.w	#1,buff_sp_mode(a0)	* 128 �����[�h���H
	bne.b	SP_128_TRANS		* NO �Ȃ� 128 �X�v���C�g�꒼���]���� bra

	*-------[ �����t�� 128 ���꒼���]�� ]
						*---------------------------------------
						* d0.w = �]���X�v���C�g�� x 8
						* a5.l = �X�v���C�g�]�����A�h���X
						* a6.l = �X�v���C�g�]����A�h���X
						*---------------------------------------
		move.w	d0,-(sp)		* d0.w �ޔ�
		move.w	d0,d7
		asr.w	#1,d7			* d7.w = �]�����[�h��
		bsr	BLOCK_TRANS

		move.w	#128*8,d7
		sub.w	(sp)+,d7		* d7.w = �K�v�N���A�X�v���C�g�� x 8
						* a6.l = �X�v���C�g�N���A�J�n�A�h���X
		bsr	SP_CLEAR		* �]���ȃX�v���C�g�̃N���A

		bra.b	EXIT_SP_TRANS


@@:
*=======[ 129 ���ȏ� ]
	move.w	R65535(pc),d1		* d1.w = XSP �����J�E���^
	btst	#0,d1			*�i2 VSYNC �� 1 �� Z �t���O = 0�j
	bne.b	SP_128_TRANS		* Z = 0 �Ȃ� 128 �X�v���C�g�꒼���]���� bra

		asr.w	#1,d0			* d0.w = �\���p�o�b�t�@�� �����[�h��
		cmpi.w	#256*4,d0
		ble.b	SP_256_TRANS		* 256*4 >= d0 �Ȃ� �_�� 256 �����]���� bra

	*-------[ �_�� 384 �����]�� ]
SP_384_TRANS:
						*---------------------------------------
						* d0.w = �\���p�o�b�t�@�㑍 push ���[�h��
						* d1.w = XSP �����J�E���^�iR65535�j
						* a5.l = �X�v���C�g�]�����A�h���X
						* a6.l = �X�v���C�g�]����A�h���X
						*---------------------------------------
		cmpi.w	#384*4,d0
		ble.b	@F			* #384*4 >= d0 �Ȃ� bra
			move.w	#384*4,d0	* 1 ��ʒ� 384 ���𒴂��Ȃ��悤�ɏC��
@@:
		lea	128*8(a5),a5		* �擪 128 �����X�L�b�v
		subi.w	#128*4,d0		* �]������ 128 �����炷

		btst	#1,d1			*�i4 VSYNC �� 1 �� Z �t���O = 0�j
		bne.b	SP_128_TRANS		* Z = 0 �Ȃ� 128 �X�v���C�g�꒼���]���� bra
						* Z = 0 �Ȃ�_�� 256 �����]����

	*-------[ �_�� 256 �����]�� ]
SP_256_TRANS:
						*---------------------------------------
						* d0.w = �\���p�o�b�t�@�㑍 push ���[�h��
						* d1.w = XSP �����J�E���^�iR65535�j
						* a5.l = �X�v���C�g�]�����A�h���X
						* a6.l = �X�v���C�g�]����A�h���X
						*---------------------------------------
		move.w	#256*4,d7
		sub.w	d0,d7			* d7.w = �O���[�v 1 �]�����[�h��

		lea	128*8(a5),a0		* a0.l = �O���[�v 2 �X�v���C�g�]�����A�h���X
		subi.w	#128*4,d0		* d0.w = �O���[�v 3 �]�����[�h��
		move.w	d0,-(sp)		* d0.w �ޔ�
		bsr	BLOCK_TRANS

		move.w	(sp)+,d7		* d0.w �����A���̂܂� d7.w ��
		movea.l	a0,a5			* a5.l = �O���[�v 2 �X�v���C�g�]�����A�h���X
						* a6.l = �O���[�v 2 �X�v���C�g�]����A�h���X
		bsr	BLOCK_TRANS

		bra.b	EXIT_SP_TRANS

*------[ 128 ���꒼���]�� ]
SP_128_TRANS:
					*---------------------------------------
					* a5.l = �X�v���C�g�]�����A�h���X
					* a6.l = �X�v���C�g�]����A�h���X
					*---------------------------------------
	bsr	SP_BLOCK_TRANS		* �X�v���C�g 128 ���u���b�N�]��


EXIT_SP_TRANS:
	rts




*==========================================================================
*
*	�X�v���C�g 128 �� �ő呬�x�u���b�N�]���T�u���[�`��
*
*	SP_BLOCK_TRANS
*
*	�����F	a5.l = �]�����A�h���X
*		a6.l = �]����A�h���X
*
*	�j��F	�S���W�X�^
*
*==========================================================================

SP_BLOCK_TRANS:

	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [0]
	movem.l	d0-d7/a0-a4,(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [1]
	movem.l	d0-d7/a0-a4,1*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [2]
	movem.l	d0-d7/a0-a4,2*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [3]
	movem.l	d0-d7/a0-a4,3*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [4]
	movem.l	d0-d7/a0-a4,4*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [5]
	movem.l	d0-d7/a0-a4,5*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [6]
	movem.l	d0-d7/a0-a4,6*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [7]
	movem.l	d0-d7/a0-a4,7*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [8]
	movem.l	d0-d7/a0-a4,8*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [9]
	movem.l	d0-d7/a0-a4,9*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [10]
	movem.l	d0-d7/a0-a4,10*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [11]
	movem.l	d0-d7/a0-a4,11*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [12]
	movem.l	d0-d7/a0-a4,12*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [13]
	movem.l	d0-d7/a0-a4,13*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [14]
	movem.l	d0-d7/a0-a4,14*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [15]
	movem.l	d0-d7/a0-a4,15*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [16]
	movem.l	d0-d7/a0-a4,16*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [17]
	movem.l	d0-d7/a0-a4,17*13*4(a6)
	movem.l	(a5)+,d0-d7/a0-a4		* 13.l  [18]
	movem.l	d0-d7/a0-a4,18*13*4(a6)
						* �ȏ�ō��v 247.l
	movem.l	(a5)+,d0-d7/a0			* 9.l
	movem.l	d0-d7/a0,19*13*4(a6)
						* �ȏ�ō��v 256.l
	rts




*==========================================================================
*
*	�`�F�C���X�L���� 1 ����΂��X�v���C�g�]���T�u���[�`��
*
*	SP_TRANS_div
*
*	�����F	a0.l = �]�����X�L�����J�n�A�h���X
*		a1.l = �]����A�h���X
*
*	�j��F	a0.l a1.l a2.l d0.w
*
*==========================================================================

SP_TRANS_div_LOOP:
	.rept	64
		move.l	(a0)+,(a1)+	*[20] 2byte
		move.l	(a0)+,(a1)+	*[20] 2byte
		addq.w	#8,a1		*[ 8] 2byte
	.endm


SP_TRANS_div:
	add.w	CHAIN_OFS_div(a0),a1	* �D��x�ی�̂��߂̃X�L�b�v
	move.w	CHAIN_OFS_div+2(a0),d0	* d0.w = �]����*8
	movea.l	@f(pc,d0.w),a2		* a2.l = �]����*8 �ʃW�����v��
	jmp	(a2)			* �]�����[�`���ɃW�����v

SP_TRANS_div_END:
	rts


*-------[ �]�����ʃW�����v�e�[�u�� ]
@@:
	dcb.l	2,SP_TRANS_div_END		* 0 �Ȃ�I��

	dcb.l	2,SP_TRANS_div_LOOP+$3F*6	* $01�� �]��
	dcb.l	2,SP_TRANS_div_LOOP+$3E*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$3D*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$3C*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$3B*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$3A*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$39*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$38*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$37*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$36*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$35*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$34*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$33*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$32*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$31*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$30*6	* 

	dcb.l	2,SP_TRANS_div_LOOP+$2F*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2E*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2D*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2C*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2B*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$2A*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$29*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$28*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$27*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$26*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$25*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$24*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$23*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$22*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$21*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$20*6	* 

	dcb.l	2,SP_TRANS_div_LOOP+$1F*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1E*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1D*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1C*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1B*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$1A*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$19*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$18*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$17*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$16*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$15*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$14*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$13*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$12*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$11*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$10*6	* 

	dcb.l	2,SP_TRANS_div_LOOP+$0F*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0E*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0D*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0C*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0B*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$0A*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$09*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$08*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$07*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$06*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$05*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$04*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$03*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$02*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$01*6	* 
	dcb.l	2,SP_TRANS_div_LOOP+$00*6	* $40�� �]��




*==========================================================================
*
*	�ėp�����u���b�N�]���T�u���[�`��
*
*	BLOCK_TRANS
*
*	�����F	a5.l = �]�����A�h���X
*		a6.l = �]����A�h���X
*		d7.w = �]�����[�h��
*
*	�j��F	a0.l �ȊO�̑S���W�X�^
*		�ia5.l a6.l �̓C���N�������j
*
*==========================================================================

BLOCK_TRANS:

*-------[ �]�����[�h�� ���� 1 �r�b�g������ ]
					* d7.w = �]�����[�h��
	btst.l	#0,d7
	beq.b	@F			* �������[�h���Ȃ� bra
		move.w	(a5)+,(a6)+	* ����[�h���̏ꍇ�A�܂� 1 ���[�h�]��
@@:

*-------[ �]�����[�h�� ���� 6 �r�b�g������ ]
	move.w	d7,d0
	andi.w	#62,d0
	neg.w	d0			* d0.w = �W�����v �C���f�N�X
	jmp	TRANS_64W(pc,d0.w)	* �W�J���[�v���ɔ�э���

	.rept	31
		move.l	(a5)+,(a6)+	*[2byte]
	.endm

TRANS_64W:
	*-------[ 64 ���[�h�ꊇ�]�����[�v ]
		lsr.w	#6,d7
		beq.b	EXIT_BLOCK_TRANS
		subq.w	#1,d7			* d7.w = dbra �J�E���^

@@:
			movem.l	(a5)+,d0-d6/a1-a4
			movem.l	d0-d6/a1-a4,(a6)	* 11.l

			movem.l	(a5)+,d0-d6/a1-a4
			movem.l	d0-d6/a1-a4,11*4(a6)	* 11.l

			movem.l	(a5)+,d0-d6/a1-a3
			movem.l	d0-d6/a1-a3,22*4(a6)	* 10.l
							* ���v 32.l = 64.w

			lea	32*4(a6),a6
			dbra	d7,@B

EXIT_BLOCK_TRANS:
			rts




*==========================================================================
*
*	�X�v���C�g�N���A�T�u���[�`��
*
*	SP_CLEAR
*
*	�@�\�F	�X�v���C�g���������܂��B
*
*	�����F	d7.w = �N���A���� * 8
*		a6.l = �N���A�J�n�A�h���X
*
*	�j��F	d5-d7/a6
*
*==========================================================================

SP_CLEAR:

	subq.w	#8,d7
	bmi.b	SP_CL_RTS		* �N���A�� <= 0 �Ȃ�L�����Z��

	move.w	d7,d6
	andi.w	#$FF80,d6		* (16sprite STEP)
	lea.l	6(a6,d6.w),a6		* SP_pr.w �̎Q�Ɗ�A�h���X

	move.w	d7,d6
	andi.w	#$78,d6
	asr.w	#1,d6			* 1 ���� 4 �o�C�g�Ȃ̂łQ�Ŋ���
	neg.w	d6			* d6.w = �W�����v�C���f�N�X

	asr.w	#7,d7			* d7.w = (�N���A�� - 1) * 8 / 8 / 16
					*      = dbra �J�E���^

	moveq.l	#0,d5

	jmp	SP_CL_LOOP+15*4(pc,d6.w)	* �W�J���[�v���֔�э���


SP_CL_LOOP:
		move.l	d5,$0078(a6)		* 4byte
		move.l	d5,$0070(a6)
		move.l	d5,$0068(a6)
		move.l	d5,$0060(a6)
		move.l	d5,$0058(a6)
		move.l	d5,$0050(a6)
		move.l	d5,$0048(a6)
		move.l	d5,$0040(a6)
		move.l	d5,$0038(a6)
		move.l	d5,$0030(a6)
		move.l	d5,$0028(a6)
		move.l	d5,$0020(a6)
		move.l	d5,$0018(a6)
		move.l	d5,$0010(a6)
		move.l	d5,$0008(a6)
		move.l	d5,(a6)
		lea.l	-$0080(a6),a6
		dbra	d7,SP_CL_LOOP

SP_CL_RTS:

	rts




*==========================================================================
*
*	���ԋl�߃T�u���[�`��
*
*	CLEAR_SKIP
*
*	�@�\�F	�S�����o�b�t�@�������i�A�����ԓ]���o�b�t�@�͏����j
*
*	�����F	a0.l = �`�F�C���擪�A�h���X
*		d0.w = [X]���e��*8
*		d1.l = �`�F�C�����[�A�h���X
*
*	�j��Fa0.l d0.l d1.l
*
*==========================================================================


CLEAR_SKIP:
	add.w	d0,d0			* d0.w = [X]���e��*16
	beq.b	ALL_CLEAR2		* [X]���e��*16 == 0 �Ȃ� �S�l�ߏ��� 2 ��

	sub.w	(a0),d0			* [X]���e��*16 -= �X�L�b�v��*16
	ble.b	ALL_CLEAR		* [X]���e��*16 <= 0 �Ȃ� �S�l�ߏ�����
@@:
	adda.w	2(a0),a0		* a0.l += �]����*8
					* a0.l = ���̃`�F�C���A�h���X
	sub.w	(a0),d0			* [X]���e��*16 -= �X�L�b�v��*16
	bgt.b	@b			* [X]���e��*16 > 0 �Ȃ� �J��Ԃ�

ALL_CLEAR:
	add.w	d0,(a0)			* �X�L�b�v��*16 �␳
	sub.w	a0,d1			* d1.w = �c��S���� �]����*8
	move.w	d1,2(a0)		* �]����*8 ��������
	rts

ALL_CLEAR2:
	move.w	#0,(a0)			* �X�L�b�v��*16 = 0
	move.w	#64*8,2(a0)		* �]����*8 = 64*8
	rts



*==========================================================================
*
*	XSP �S�����o�b�t�@������ �ėp�T�u���[�`��
*
*	XSP_BUFF_INIT
*
*	�@�\�F	�����o�b�t�@�������i�N���� 1 �񂫂�̑S�������j
*
*	�j��F	����
*
*==========================================================================

XSP_BUFF_INIT:

	movem.l	d0-d7/a0-a6,-(sp)	* ���W�X�^�ޔ�


*-------[ �X�v���C�g���o�b�t�@�N���A ]
	lea	buff_top_adr_no_pc,a0
	move.l	a0,buff_pointer		* �|�C���^�N���A

	moveq	#0,d0
	move.w	#SP_MAX*2-1,d1		* 1 SP ������ 2 �����O���[�h
@@:		move.l	d0,(a0)+
		dbra	d1,@B

	move.l	#-1,(a0)+		* end_mark
	move.l	#-1,(a0)+		* end_mark


*-------[ ���X�^�ʕ����o�b�t�@������ ]
	lea	div_buff_0A_no_pc,a0
	moveq.l	#0,d0			* d0.l = 0�i�N���A�p�j

	move.w	#65*8*3-1,d1		* d1.w = dbra �J�E���^�����l
@@:		move.l	d0,(a0)+	* 0 �N���A
		move.l	d0,(a0)+	* 0 �N���A
		dbra	d1,@B


*-------[ OX_tbl , OX_mask �̏����� ]
	lea	OX_tbl_no_pc,a0
	move.b	#255,(a0)+		* PCG_No.0 �͐��� = 255

	lea	OX_mask_no_pc,a1
	move.b	#255,(a1)+		* PCG_No.0 �̓}�X�N

	move.w	#254,d0			* 255.b ���������邽�߂� dbra �J�E���^
@@:		move.b	#1,(a0)+	* OX_tbl �������i���� = �P�j
		move.b	#0,(a1)+	* OX_mask �������i�}�X�N off�j
	dbra	d0,@B

	move.b	#0,(a0)+		* OX_tbl �� end_mark(0)

	move.b	#4,OX_level		* ���݂� OX_tbl ���ʂ� 4 �Ƃ���
	move.w	#0,OX_mask_renew	* OX_mask �X�V�����������Ƃ������t���O���N���A
	move.l	#OX_tbl_no_pc+1,OX_chk_top
	move.l	#OX_tbl_no_pc+1,OX_chk_ptr
	move.w	#254,OX_chk_size


*-------[ XSP �Ǘ��\���̏����� ]
	lea.l	XSP_STRUCT_no_pc,a0
	lea.l	STRUCT_SIZE(a0),a1
	lea.l	STRUCT_SIZE(a1),a2

	moveq.l	#1,d0
	move.w	d0,buff_sp_mode(a0)
	move.w	d0,buff_sp_mode(a1)
	move.w	d0,buff_sp_mode(a2)

	moveq.l	#0,d0
	move.w	d0,buff_sp_total(a0)
	move.w	d0,buff_sp_total(a1)
	move.w	d0,buff_sp_total(a2)

	move.l	#div_buff_0A_no_pc,div_buff(a0)
	move.l	#div_buff_1A_no_pc,div_buff(a1)
	move.l	#div_buff_2A_no_pc,div_buff(a2)

	move.l	d0,vsyncint_arg(a0)
	move.l	d0,vsyncint_arg(a1)
	move.l	d0,vsyncint_arg(a2)

	moveq.l	#-1,d0
	move.l	d0,vsync_def(a0)
	move.l	d0,vsync_def(a1)
	move.l	d0,vsync_def(a2)


*-------[ 512 �����[�h�p���X�^���荞�݃^�C���`���[�g�̏����� ]
	moveq.l	#2,d2
	lea.l	XSP_STRUCT_no_pc,a0

	@@:
	*-------[ 31KHz �p ]
		lea.l	XSP_chart_for_512sp_31khz(a0),a1

		move.w	#32,(a1)+				* 
		move.l	#sp_disp_on,(a1)+			* �X�v���C�g�\�� on

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_C,(a1)+			* ���X�^�����o�b�t�@C ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_D,(a1)+			* ���X�^�����o�b�t�@D ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_E,(a1)+			* ���X�^�����o�b�t�@E ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_F,(a1)+			* ���X�^�����o�b�t�@F ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_G,(a1)+			* ���X�^�����o�b�t�@G ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_H,(a1)+			* ���X�^�����o�b�t�@H ��\��

		move.w	#-1,(a1)+				* end_mark
		move.l	#0,(a1)+				* �_�~�[

		bsr	UPDATE_INT_RASTER_NUMBER_FOR_31KHZ	* �j��Fd0-d1/a1

	*-------[ 15KHz �p ]
		lea.l	XSP_chart_for_512sp_15khz(a0),a1

		move.w	#12,(a1)+				* 
		move.l	#sp_disp_on,(a1)+			* �X�v���C�g�\�� on

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_C,(a1)+			* ���X�^�����o�b�t�@C ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_D,(a1)+			* ���X�^�����o�b�t�@D ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_E,(a1)+			* ���X�^�����o�b�t�@E ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_F,(a1)+			* ���X�^�����o�b�t�@F ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_G,(a1)+			* ���X�^�����o�b�t�@G ��\��

		addq.l	#2,a1					* ���X�^�i���o�ݒ�̓X�L�b�v
		move.l	#DISP_buff_H,(a1)+			* ���X�^�����o�b�t�@H ��\��

		move.w	#-1,(a1)+				* end_mark
		move.l	#0,(a1)+				* �_�~�[

		bsr	UPDATE_INT_RASTER_NUMBER_FOR_15KHZ	* �j��Fd0-d1/a1

	*-------[ ���̍\���̗v�f�� ]
	lea.l	STRUCT_SIZE(a0),a0				* ���̍\���̗v�f��
	dbra	d2,@b						* �w�萔��������܂Ń��[�v


*-------[ �I�� ]
	movem.l	(sp)+,d0-d7/a0-a6	* ���W�X�^����

	rts



*==========================================================================
*
*	�X�v���C�g�]�����X�^�̍Čv�Z�i31KHz �p�j
*
*	UPDATE_INT_RASTER_NUMBER_31KHZ
*
*	�@�\�F	31KHz ���̃^�C���`���[�g�̊��荞�݃��X�^�ԍ����Čv�Z����B
*
*	�����F	a0.l = �����p�o�b�t�@�Ǘ��\����
*
*	�j��F	d0-d1/a1
*
*==========================================================================
UPDATE_INT_RASTER_NUMBER_FOR_31KHZ:

							* a0.l = �����p�o�b�t�@�Ǘ��\����
	lea.l	divy_AB(pc),a1				* a1.l = #divy_AB

	move.w	raster_ofs_for31khz(pc),d1		* d1.w = ���X�^���荞�݈ʒu�I�t�Z�b�g

	*-------[ DISP_buff_C ]
	move.w	(a1)+,d0				* d0.w = divy_AB
	add.w	d0,d0
	add.w	d1,d0					* d0.w = divy_AB * 2 + d1
	move.w	d0,XSP_chart_for_512sp_31khz+6*1(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_D ]
	move.w	(a1)+,d0				* d0.w = divy_BC
	add.w	d0,d0
	add.w	d1,d0					* d0.w = divy_BC * 2 + d1
	move.w	d0,XSP_chart_for_512sp_31khz+6*2(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_E ]
	move.w	(a1)+,d0				* d0.w = divy_CD
	add.w	d0,d0
	add.w	d1,d0					* d0.w = divy_CD * 2 + d1
	move.w	d0,XSP_chart_for_512sp_31khz+6*3(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_F ]
	move.w	(a1)+,d0				* d0.w = divy_DE
	add.w	d0,d0
	add.w	d1,d0					* d0.w = divy_DE * 2 + d1
	move.w	d0,XSP_chart_for_512sp_31khz+6*4(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_G ]
	move.w	(a1)+,d0				* d0.w = divy_EF
	add.w	d0,d0
	add.w	d1,d0					* d0.w = divy_EF * 2 + d1
	move.w	d0,XSP_chart_for_512sp_31khz+6*5(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_H ]
	move.w	(a1)+,d0				* d0.w = divy_FG
	add.w	d0,d0
	add.w	d1,d0					* d0.w = divy_FG * 2 + d1
	move.w	d0,XSP_chart_for_512sp_31khz+6*6(a0)	* ���X�^�i���o��������

	rts


*==========================================================================
*
*	�X�v���C�g�]�����X�^�̍Čv�Z�i15KHz �p�j
*
*	UPDATE_INT_RASTER_NUMBER_15KHZ
*
*	�@�\�F	15KHz ���̃^�C���`���[�g�̊��荞�݃��X�^�ԍ����Čv�Z����B
*
*	�����F	a0.l = �����p�o�b�t�@�Ǘ��\����
*
*	�j��F	d0-d1/a1
*
*==========================================================================
UPDATE_INT_RASTER_NUMBER_FOR_15KHZ:

							* a0.l = �����p�o�b�t�@�Ǘ��\����
	lea.l	divy_AB(pc),a1				* a1.l = #divy_AB

	move.w	raster_ofs_for15khz(pc),d1		* d1.w = ���X�^���荞�݈ʒu�I�t�Z�b�g

	*-------[ DISP_buff_C ]
	move.w	(a1)+,d0				* d0.w = divy_AB
	add.w	d1,d0					* d0.w = divy_AB + d1
	move.w	d0,XSP_chart_for_512sp_15khz+6*1(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_D ]
	move.w	(a1)+,d0				* d0.w = divy_BC
	add.w	d1,d0					* d0.w = divy_BC + d1
	move.w	d0,XSP_chart_for_512sp_15khz+6*2(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_E ]
	move.w	(a1)+,d0				* d0.w = divy_CD
	add.w	d1,d0					* d0.w = divy_CD + d1
	move.w	d0,XSP_chart_for_512sp_15khz+6*3(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_F ]
	move.w	(a1)+,d0				* d0.w = divy_DE
	add.w	d1,d0					* d0.w = divy_DE + d1
	move.w	d0,XSP_chart_for_512sp_15khz+6*4(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_G ]
	move.w	(a1)+,d0				* d0.w = divy_EF
	add.w	d1,d0					* d0.w = divy_EF + d1
	move.w	d0,XSP_chart_for_512sp_15khz+6*5(a0)	* ���X�^�i���o��������

	*-------[ DISP_buff_H ]
	move.w	(a1)+,d0				* d0.w = divy_FG
	add.w	d1,d0					* d0.w = divy_FG + d1
	move.w	d0,XSP_chart_for_512sp_15khz+6*6(a0)	* ���X�^�i���o��������

	rts


*==========================================================================
*
*	���X�^���� Y ���W�̎����X�V
*
*	AUTO_ADJUST_DIV_Y
*
*	�@�\�F	���X�^���� Y �u���b�N�̎g�p�����q���g�ɁA���X�^���� Y ���W
*		���X�V����B
*
*	�����F	a0.l = �����p�o�b�t�@�Ǘ��\����
*
*		a3.w = ���X�^�����o�b�t�@A �g�p��*8
*		a4.w = ���X�^�����o�b�t�@C �g�p��*8
*		a5.w = ���X�^�����o�b�t�@E �g�p��*8
*		a6.w = ���X�^�����o�b�t�@G �g�p��*8
*
*		d3.w = ���X�^�����o�b�t�@B �g�p��*8
*		d4.w = ���X�^�����o�b�t�@D �g�p��*8
*		d5.w = ���X�^�����o�b�t�@F �g�p��*8
*		d6.w = ���X�^�����o�b�t�@H �g�p��*8
*
*	�j��F	d0.w
*		d1.l
*		a1.l
*		a2.l
*
*==========================================================================


*--------------------------------------------------------------------------
*	�}�N����`
*--------------------------------------------------------------------------

ADJUST_DIV_Y_SUB	.macro	reg1, reg2, divy_01, divy_12, divy_23, SORT_512_1, SORT_512b_1, SORT_512_2, SORT_512b_2
			.local	else

							* reg1.w = ���X�^�����o�b�t�@1 �g�p��*8
							* reg2.w = ���X�^�����o�b�t�@2 �g�p��*8
	cmp.w	reg1,reg2
	ble.b	else					* �����l�� (�o�b�t�@1 �g�p�� >= �o�b�t�@2 �g�p��) �Ȃ� bra
	*-------[ �o�b�t�@1 �g�p�� < �o�b�t�@2 �g�p�� ]
		move.w	divy_12(pc),d0			: d0.w = divy_12
		move.w	divy_23(pc),d1			* d1.w = divy_23
		sub.w	min_divh(pc),d1			* d1.w = divy_23 - min_divh
		cmp.w	d0,d1
		ble.b	@f				* �����l�� (divy_12 >= divy_23 - min_divh) �Ȃ� bra
		*-------[ divy_12 < divy_23 - min_divh ]
			move.l	#SORT_512_1,(a1,d0.w)	* SORT_512_JPTBL[divy_12/4] = SORT_512_1
			move.l	#SORT_512b_1,(a2,d0.w)	* SORT_512b_JPTBL[divy_12/4] = SORT_512b_1
			addq.w	#4,d0			* divy_12 += 4
			move.w	d0,divy_12
			bra @f

else:
	cmp.w	a4,d4
	bge.b	@f					* �����l�� (�o�b�t�@1 �g�p�� <= �o�b�t�@2 �g�p��) �Ȃ� bra
	*-------[ �o�b�t�@1 �g�p�� > �o�b�t�@2 �g�p�� ]
		move.w	divy_12(pc),d0			* d0.w = divy_12
		move.w	divy_01(pc),d1			* d1.w = divy_01
		add.w	min_divh(pc),d1			* d1.w = divy_01 + min_divh
		cmp.w	d1,d0				
		ble.b	@f				* �����l�� (divy_01 + min_divh >= divy_12) �Ȃ� bra
		*-------[ divy_01 + min_divh < divy_12 ]
			subq.w	#4,d0			* divy_12 -= 4
			move.l	#SORT_512_2,(a1,d0.w)	* SORT_512_JPTBL[divy_23/4] = SORT_512_2
			move.l	#SORT_512b_2,(a2,d0.w)	* SORT_512b_JPTBL[divy_23/4] = SORT_512b_2
			move.w	d0,divy_12

@@:
		.endm

*--------------------------------------------------------------------------


AUTO_ADJUST_DIV_Y:

	*-------[ �X�V�O�̌�������X�^���荞�݃^�C���`���[�g�ɔ��f ]
		btst.b	#4,$E80029		* [inside68k p.233 ]
						* bit4 =( 15Khz��=0 / 31Khz��=1 )
		beq.b	update_chart_for_15khz
		*-------[ 31khz ]
update_chart_for_31khz:
			bsr	UPDATE_INT_RASTER_NUMBER_FOR_31KHZ	* �j�� d0-d1/a1
			bra	@f

		*-------[ 15khz ]
update_chart_for_15khz:
			bsr	UPDATE_INT_RASTER_NUMBER_FOR_15KHZ	* �j�� d0-d1/a1
@@:


	*-------[ �������X�^�������� ]
		lea.l	SORT_512_JPTBL(pc),a1		* a1.l = #SORT_512_JPTBL
		lea.l	SORT_512b_JPTBL(pc),a2		* a2.l = #SORT_512b_JPTBL

		move.w	R65535(pc),d0			* d0.w = XSP �����J�E���^
		btst	#0,d0				* 2 VSYNC �� 1 �� Z �t���O = 0
		bne	adjust_div_BC_DE_FG		* Z = 0 �Ȃ� bra
		*-------[ �o�b�t�@ AB CD EF GH ���� Y ���W�̍X�V ]
adjust_div_AB_CD_EF_GH:

			*-------[ �o�b�t�@ AB ���� Y ���W�̍X�V ]
										* a3.w = ���X�^�����o�b�t�@A �g�p��*8
										* d3.w = ���X�^�����o�b�t�@B �g�p��*8
				cmp.w	a3,d3
				ble.b	adjust_div_AB_else			* �����l�� (�o�b�t�@A �g�p�� >= �o�b�t�@B �g�p��) �Ȃ� bra
				*-------[ �o�b�t�@A �g�p�� < �o�b�t�@B �g�p�� ]
					move.w	divy_AB(pc),d0			* d0.w = divy_AB
					move.w	divy_BC(pc),d1			* d1.w = divy_BC
					sub.w	min_divh(pc),d1			* d1.w = divy_BC - min_divh
					cmp.w	d0,d1
					ble.b	@f				* �����l�� (divy_AB >= divy_BC - min_divh) �Ȃ� bra
					*-------[ divy_AB < divy_BC - min_divh ]
						move.l	#SORT_512_A,(a1,d0.w)	* SORT_512_JPTBL[divy_AB/4] = SORT_512_A
						move.l	#SORT_512b_A,(a2,d0.w)	* SORT_512b_JPTBL[divy_AB/4] = SORT_512b_A
						addq.w	#4,d0			* divy_AB += 4
						move.w	d0,divy_AB
						bra.b @f

adjust_div_AB_else:
				cmp.w	a3,d3
				bge.b	@f			* �����l�� (�o�b�t�@A �g�p�� <= �o�b�t�@B �g�p��) �Ȃ� bra
				*-------[ �o�b�t�@A �g�p�� > �o�b�t�@B �g�p�� ]
					move.w	divy_AB(pc),d0			* d0.w = divy_AB
					cmp.w	min_divh(pc),d0			
					ble.b	@f				* �����l�� (min_divh >= divy_AB) �Ȃ� bra
					*-------[ min_divh < divy_AB ]
						subq.w	#4,d0			* divy_AB -= 4
						move.l	#SORT_512_B,(a1,d0.w)	* SORT_512_JPTBL[divy_AB/4] = SORT_512_B
						move.l	#SORT_512b_B,(a2,d0.w)	* SORT_512b_JPTBL[divy_AB/4] = SORT_512b_B
						move.w	d0,divy_AB

@@:

			*-------[ �o�b�t�@ CD ���� Y ���W�̍X�V ]
				ADJUST_DIV_Y_SUB	a4, d4, divy_BC, divy_CD, divy_DE, SORT_512_C, SORT_512b_C, SORT_512_D, SORT_512b_D

			*-------[ �o�b�t�@ EF ���� Y ���W�̍X�V ]
				ADJUST_DIV_Y_SUB	a5, d5, divy_DE, divy_EF, divy_FG, SORT_512_E, SORT_512b_E, SORT_512_F, SORT_512b_F

			*-------[ �o�b�t�@ GH ���� Y ���W�̍X�V ]
										* a6.w = ���X�^�����o�b�t�@G �g�p��*8
										* d6.w = ���X�^�����o�b�t�@H �g�p��*8
				cmp.w	a6,d6
				ble.b	adjust_div_GH_else			* �����l�� (�o�b�t�@G �g�p�� >= �o�b�t�@H �g�p��) �Ȃ� bra
				*-------[ �o�b�t�@G �g�p�� < �o�b�t�@H �g�p�� ]
					move.w	divy_GH(pc),d0			* d0.w = divy_GH
					move.w	#XY_MAX,d1			* d1.w = #XY_MAX
					sub.w	min_divh(pc),d1			* d1.w = #XY_MAX - min_divh
					cmp.w	d0,d1				
					ble.b	@f				* �����l�� (divy_GH >= XY_MAX - min_divh) �Ȃ� bra
					*-------[ divy_GH < XY_MAX - min_divh ]
						move.l	#SORT_512_G,(a1,d0.w)	* SORT_512_JPTBL[divy_GH/4] = SORT_512_G
						move.l	#SORT_512b_G,(a2,d0.w)	* SORT_512b_JPTBL[divy_GH/4] = SORT_512b_G
						addq.w	#4,d0			* divy_GH += 4
						move.w	d0,divy_GH
						bra @f

adjust_div_GH_else:
				cmp.w	a6,d6
				bge.b	@f					* �����l�� (�o�b�t�@G �g�p�� <= �o�b�t�@H �g�p��) �Ȃ� bra
				*-------[ �o�b�t�@G �g�p�� > �o�b�t�@H �g�p�� ]
					move.w	divy_GH(pc),d0			* d0.w = divy_GH
					move.w	divy_FG(pc),d1			* d1.w = divy_FG
					add.w	min_divh(pc),d1			* d1.w = divy_FG + min_divh
					cmp.w	d1,d0				
					ble	@f				* �����l�� (divy_FG + min_divh >= divy_GH) �Ȃ� bra
					*-------[ divy_FG + min_divh < divy_GH ]
						subq.w	#4,d0			* divy_GH -= 4
						move.l	#SORT_512_H,(a1,d0.w)	* SORT_512_JPTBL[divy_GH/4] = SORT_512_H
						move.l	#SORT_512b_H,(a2,d0.w)	* SORT_512b_JPTBL[divy_GH/4] = SORT_512b_H
						move.w	d0,divy_GH

@@:
			bra adjust_div_done

		*-------[ �o�b�t�@ BC DE FG ���� Y ���W�̍X�V ]
adjust_div_BC_DE_FG:

			*-------[ �o�b�t�@ BC ���� Y ���W�̍X�V ]
			ADJUST_DIV_Y_SUB	d3, a4, divy_AB, divy_BC, divy_CD, SORT_512_B, SORT_512b_B, SORT_512_C, SORT_512b_C

			*-------[ �o�b�t�@ DE ���� Y ���W�̍X�V ]
			ADJUST_DIV_Y_SUB	d4, a5, divy_CD, divy_DE, divy_EF, SORT_512_D, SORT_512b_D, SORT_512_E, SORT_512b_E

			*-------[ �o�b�t�@ FG ���� Y ���W�̍X�V ]
			ADJUST_DIV_Y_SUB	d5, a6, divy_EF, divy_FG, divy_GH, SORT_512_F, SORT_512b_F, SORT_512_G, SORT_512b_G

adjust_div_done:



*==========================================================================
*
*	68030 �΍� MFP ����� WAIT �T�u���[�`��
*
*==========================================================================

WAIT:
	rts				* ���������A�邾���ł�




*==========================================================================
*
*	���[�N�m��
*
*==========================================================================

	.include	XSPmem.s



