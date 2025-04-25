*==========================================================================
*
*	short xsp_vsync(short n);
*
*==========================================================================

_xsp_vsync:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),d0	* d0.w = n�i�A�����Ԑ��j


*=======[ XSP �g���݃`�F�b�N ]
	btst.b	#0,XSP_flg(pc)		* XSP �͑g�ݍ��܂�Ă��邩�H�ibit0=1���H�j
	bne.b	@F			* YES �Ȃ� bra
		moveq	#-1,d0			* XSP ���g�ݍ��܂�Ă��Ȃ��̂ŁA�߂�l = -1
		bra.b	xsp_vsync_rts
@@:

*=======[ �w�� VSYNC �P�ʂ̐������� ]
xsp_vsync_wait_loop:
	cmp.w	vsync_count(pc),d0
	bhi.b	xsp_vsync_wait_loop	* vsync_count < arg1�i���������j�Ȃ烋�[�v

	move.w	vsync_count(pc),d0	* d0.w = �Ԃ�l
	clr.w	vsync_count


xsp_vsync_rts:
	rts




*==========================================================================
*
*	short xsp_vsync2(short max_delay);
*
*==========================================================================

_xsp_vsync2:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	moveq	#0,d0			* �߂�l�����l = 0

*=======[ XSP �g���݃`�F�b�N ]
	btst.b	#0,XSP_flg(pc)		* XSP �͑g�ݍ��܂�Ă��邩�H�ibit0=1���H�j
	bne.b	@F			* YES �Ȃ� bra
		moveq	#-1,d0			* XSP ���g�ݍ��܂�Ă��Ȃ��̂ŁA�߂�l = -1
		bra.b	xsp_vsync2_rts
@@:

*=======[ �ۗ���Ԃ̕\�����N�G�X�g�����܂肷����Ȃ�҂� ]
	move.w	A7ID+arg1_w(sp),d1	* d1.w = max_delay�i���e�x���t���[�����j

xsp_vsync2_wait_loop:
	cmp.w	penging_disp_count(pc),d1	*
	bcc.b	xsp_vsync2_rts			* penging_disp_count <= d1�i���������j�Ȃ甲����
		moveq	#1,d0			* �߂�l = 1�i�u���b�L���O�������Ƃ������j
		bra.b	xsp_vsync2_wait_loop	* ���g���C

xsp_vsync2_rts:
	rts




*==========================================================================
*
*	void xsp_objdat_set(void *sp_ref);
*
*==========================================================================

_xsp_objdat_set:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.l	A7ID+arg1_l(sp),sp_ref_adr

	rts




*==========================================================================
*
*	void xsp_pcgdat_set(void *pcg_dat, char *pcg_alt, short alt_size);
*
*==========================================================================

_xsp_pcgdat_set:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	movea.l	A7ID+arg1_l(sp),a0	* a0.l = *PCG_DAT
	movea.l	A7ID+arg2_l(sp),a1	* a1.l = *PCG_ALT
	move.w	A7ID+arg3_w(sp),d0	* d0.w =  PCG_ALT �T�C�Y

*-------[ �܂��O��܂ł̋A������ PCG ��`���I������܂� WAIT ]
	clr.w	vsync_count
	movem.l	d0-d2/a0-a2,-(sp)	* ���W�X�^�ޔ�
	move.l	#3,-(sp)		* ������ PUSH
	bsr	_xsp_vsync		* 3 vsync WAIT
	lea	4(sp),sp		* �X�^�b�N�␳
	movem.l	(sp)+,d0-d2/a0-a2	* ���W�X�^����

*-------[ �e�탆�[�U�[�w��A�h���X������ ]
	move.l	a0,pcg_dat_adr
	addq.w	#1,a1			* �z�u�Ǘ��e�[�u���̐擪 1 �o�C�g�͔�΂�
	move.l	a1,pcg_alt_adr

*-------[ PCG_ALT ������ ]
					* a1.l = pcg_alt_adr
					* d0.w = �N���A�� +1
	subq.w	#2,d0			* dbra �J�E���^�Ƃ��邽�ߕ␳
@@:		clr.b	(a1)+
		dbra	d0,@B

*-------[ PCG_REV_ALT ������ ]
	lea	pcg_rev_alt_no_pc,a1
	move.w	#255,d0			* 256.w �N���A���邽�߂� dbra �J�E���^
@@:		move.w	#-1,(a1)+
		dbra	d0,@B

*-------[ XSP �����t���O���� ]
	bset.b	#1,XSP_flg		* PCG_DAT, PCG_ALT ���w��ς������t���O���Z�b�g

	rts




*==========================================================================
*
*	void xsp_pcgmask_on(short start_no, short end_no);
*
*==========================================================================

_xsp_pcgmask_on:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),d0	* d0.w = �}�X�N�ݒ�J�n�i���o�[
	move.w	A7ID+arg2_w(sp),d1	* d1.w = �}�X�N�ݒ�I���i���o�[

*-------[ dbra �J�E���^�����l�ݒ� ]
	cmpi.w	#256,d0
	bcc.b	xsp_mask_on_ERR		* #256 <= d1.w�i���������j�Ȃ� bra

	cmpi.w	#256,d1
	bcc.b	xsp_mask_on_ERR		* #256 <= d1.w�i���������j�Ȃ� bra

	tst.w	d0
	bne.b	@f
		addq.w	#1,d0		* �}�X�N�ݒ�J�n�i���o�[�� 0 �Ȃ̂ŁA�����I�� 1 �ɂ���B
@@:

	sub.w	d0,d1			* d1.w -= d0.w
	bmi.b	xsp_mask_on_ERR		* dbra �J�E���^ < 0 �Ȃ� bra

	lea.l	OX_mask_no_pc,a0	* a0.l = OX_mask �g�b�v�A�h���X
	adda.w	d0,a0			* a0.l = OX_mask �Q�ƊJ�n�A�h���X

*-------[ �}�X�N���H ]
	moveq.l	#255,d0			* d0.b = 255�i�}�X�Non�j

@@:	move.b	d0,(a0)+		* �}�X�N�ݒ�
	dbra	d1,@b			* �w�萔��������܂Ń��[�v

	move.w	#1,OX_mask_renew	* OX_mask �ɍX�V�����������Ƃ�`����

*-------[ ����I�� ]
	rts

*-------[ �������s���Ȃ̂ŋ����I�� ]
xsp_mask_on_ERR:
	rts




*==========================================================================
*
*	void xsp_pcgmask_off(short start_no, short end_no);
*
*==========================================================================

_xsp_pcgmask_off:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),d0	* d0.w = �}�X�N�ݒ�J�n�i���o�[
	move.w	A7ID+arg2_w(sp),d1	* d1.w = �}�X�N�ݒ�I���i���o�[

*-------[ dbra �J�E���^�����l�ݒ� ]
	cmpi.w	#256,d0
	bcc.b	xsp_mask_off_ERR	* #256 <= d1.w�i���������j�Ȃ� bra

	cmpi.w	#256,d1
	bcc.b	xsp_mask_off_ERR	* #256 <= d1.w�i���������j�Ȃ� bra

	tst.w	d0
	bne.b	@f
		addq.w	#1,d0		* �}�X�N�ݒ�J�n�i���o�[�� 0 �Ȃ̂ŁA�����I�� 1 �ɂ���B
@@:

	sub.w	d0,d1			* d1.w -= d0.w
	bmi.b	xsp_mask_off_ERR	* dbra �J�E���^ < 0 �Ȃ� bra

	lea.l	OX_mask_no_pc,a0	* a0.l = OX_mask �g�b�v�A�h���X
	adda.w	d0,a0			* a0.l = OX_mask �Q�ƊJ�n�A�h���X

*-------[ �}�X�N���H ]
	moveq.l	#0,d0			* d0.b = 0�i�}�X�Noff�j

@@:	move.b	d0,(a0)+		* �}�X�N�ݒ�
	dbra	d1,@b			* �w�萔��������܂Ń��[�v

	move.w	#1,OX_mask_renew	* OX_mask �ɍX�V�����������Ƃ�`����

*-------[ ����I�� ]
	rts

*-------[ �������s���Ȃ̂ŋ����I�� ]
xsp_mask_off_ERR:
	rts




*==========================================================================
*
*	void xsp_mode(short mode_no);
*
*==========================================================================

_xsp_mode:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),d0	* d0.w = MODE_No.

*-------[ �����Ȓl�̏ꍇ�A3 ���w�肳�ꂽ���̂Ƃ��� ]
	tst.w	d0
	bne.b	@F
		moveq.l	#3,d0
@@:
	cmpi.w	#3,d0
	bls.b	@F			* 3 >= d0.w �Ȃ� bra
		moveq.l	#3,d0
@@:

	move.w	d0,sp_mode
	rts




*==========================================================================
*
*	void xsp_vertical(short flag);
*
*==========================================================================

_xsp_vertical:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),vertical_flg
	rts




*==========================================================================
*
*	void xsp_on();
*
*==========================================================================

_xsp_on:

A7ID	=	4+15*4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 15*4 byte ]
	movem.l	d0-d7/a0-a6,-(sp)	* ���W�X�^�ޔ�


*=======[ XSP �g�ݍ��݃`�F�b�N ]
	bset.b	#0,XSP_flg		* �g�ݍ��ݏ�Ԃ��H�i�`�F�b�N�Ɠ����Ƀt���O�Z�b�g�j
	beq.b	@F			* 0(=NO) �Ȃ�g���ݏ����� bra
		bra	xsp_on_rts	* ���ɑg�ݍ��܂�Ă���̂ŁA���ʏI��������
@@:

*=======[ �o�b�t�@������ ]
	bsr	XSP_BUFF_INIT		* �S�����o�b�t�@�������i�A�����ԓ]���o�b�t�@�͏����j

*=======[ �X�[�p�[�o�C�U�[���[�h�� ]
	suba.l	a1,a1
	iocs	_B_SUPER		* �X�[�p�[�o�C�U�[���[�h��
	move.l	d0,usp_bak		*�i���Ƃ��ƃX�[�p�[�o�C�U�[���[�h�Ȃ� d0.l=-1�j


*=======[ XSP �g���ݏ��� ]
	ori.w	#$0700,sr		* ���荞�� off
	bsr	WAIT			* 68030 �΍�

*-------[ MFP �̃o�b�N�A�b�v����� ]
	movea.l	#$e88000,a0		* a0.l = MFP�A�h���X
	lea.l	MFP_bak(pc),a1		* a1.l = MFP�ۑ���A�h���X

	move.b	AER(a0),AER(a1)		*  AER �ۑ�
	move.b	IERA(a0),IERA(a1)	* IERA �ۑ�
	move.b	IERB(a0),IERB(a1)	* IERB �ۑ�
	move.b	IMRA(a0),IMRA(a1)	* IMRA �ۑ�
	move.b	IMRB(a0),IMRB(a1)	* IMRB �ۑ�

	move.l	$118,vector_118_bak	* �ύX�O�� V-disp �x�N�^
	move.l	$138,vector_138_bak	* �ύX�O�� CRT-IRQ �x�N�^
	move.w	$E80012,raster_No_bak	* �ύX�O�� CRT-IRQ ���X�^ No.

*-------[ V-DISP ���荞�ݐݒ� ]
	move.l	#VSYNC_INT,$118		* V-disp �x�N�^������
	bclr.b	#4,AER(a0)		* �A�����ԂƓ����Ɋ��荞��
	bset.b	#6,IMRB(a0)		* �}�X�N���͂���
	bset.b	#6,IERB(a0)		* ���荞�݋���

*-------[ H-SYNC ���荞�ݐݒ� ]
	move.w	#1023,$E80012		* ���荞�݃��X�^�i���o�[�i�܂����荞�� off�j
	move.l	#RAS_INT,$138		* CRT-IRQ �x�N�^������
	bclr.b	#6,AER(a0)		* ���荞�ݗv���Ɠ����Ɋ��荞��
	bset.b	#6,IMRA(a0)		* �}�X�N���͂���
	bset.b	#6,IERA(a0)		* ���荞�݋���

*------------------------------
	bsr	WAIT			* 68030 �΍�
	andi.w	#$f8ff,sr		* ���荞�� on


*=======[ ���[�U�[���[�h�� ]
	move.l	usp_bak(pc),d0
	bmi.b	@F			* �X�[�p�[�o�C�U�[���[�h������s����Ă�����߂��K�v����
		movea.l	d0,a1
		iocs	_B_SUPER	* ���[�U�[���[�h��
@@:

*-------[ �I�� ]
xsp_on_rts:
	movem.l	(sp)+,d0-d7/a0-a6	* ���W�X�^����
	rts




*==========================================================================
*
*	void xsp_off();
*
*==========================================================================

_xsp_off:

A7ID	=	4+15*4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 15*4 byte ]
	movem.l	d0-d7/a0-a6,-(sp)	* ���W�X�^�ޔ�


*=======[ XSP �g�ݍ��݃`�F�b�N ]
	bclr.b	#0,XSP_flg		* �g�ݍ��ݏ�Ԃ��H�i�`�F�b�N�Ɠ����Ƀt���O�N���A�j
	bne.b	@F			* 1(=YES) �Ȃ�g���݉��������� bra
		bra	xsp_off_rts	* ���Ƃ��Ƒg�ݍ��܂�Ă��Ȃ��̂ŁA���ʏI��������
@@:


*=======[ �X�[�p�[�o�C�U�[���[�h�� ]
	suba.l	a1,a1
	iocs	_B_SUPER		* �X�[�p�[�o�C�U�[���[�h��
	move.l	d0,usp_bak		*�i���Ƃ��ƃX�[�p�[�o�C�U�[���[�h�Ȃ� d0.l=-1�j


*=======[ XSP �g���݉������� ]
	ori.w	#$0700,sr		* ���荞�� off
	bsr	WAIT			* 68030 �΍�

*-------[ MFP �̕��� ]
	movea.l	#$e88000,a0		* a0.l = MFP�A�h���X
	lea.l	MFP_bak(pc),a1		* a1.l = MFP��ۑ����Ă������A�h���X

	move.b	AER(a1),d0
	andi.b	#%0101_0000,d0
	andi.b	#%1010_1111,AER(a0)
	or.b	d0,AER(a0)		* AER bit4&6 ����

	move.b	IERA(a1),d0
	andi.b	#%0100_0000,d0
	andi.b	#%1011_1111,IERA(a0)
	or.b	d0,IERA(a0)		* IERA bit6 ����

	move.b	IERB(a1),d0
	andi.b	#%0100_0000,d0
	andi.b	#%1011_1111,IERB(a0)
	or.b	d0,IERB(a0)		* IERB bit6 ����

	move.b	IMRA(a1),d0
	andi.b	#%0100_0000,d0
	andi.b	#%1011_1111,IMRA(a0)
	or.b	d0,IMRA(a0)		* IMRA bit6 ����

	move.b	IMRB(a1),d0
	andi.b	#%0100_0000,d0
	andi.b	#%1011_1111,IMRB(a0)
	or.b	d0,IMRB(a0)		* IMRB bit6 ����

	move.l	vector_118_bak(pc),$118		* V-disp �x�N�^����
	move.l	vector_138_bak(pc),$138		* CRT-IRQ �x�N�^����
	move.w	raster_No_bak(pc),$E80012	* CRT-IRQ ���X�^ No. ����

*------------------------------
	bsr	WAIT			* 68030 �΍�
	andi.w	#$f8ff,sr		* ���荞�� on


*=======[ ���[�U�[���[�h�� ]
	move.l	usp_bak(pc),d0
	bmi.b	@F			* �X�[�p�[�o�C�U�[���[�h������s����Ă�����߂��K�v����
		movea.l	d0,a1
		iocs	_B_SUPER	* ���[�U�[���[�h��
@@:

*-------[ �I�� ]
xsp_off_rts:
	movem.l	(sp)+,d0-d7/a0-a6	* ���W�X�^����
	rts




*==========================================================================
*
*	void xsp_vsyncint_on(void *proc);
*
*==========================================================================

_xsp_vsyncint_on:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.l	A7ID+arg1_l(sp),vsyncint_sub
	rts




*==========================================================================
*
*	void xsp_vsyncint_off();
*
*==========================================================================

_xsp_vsyncint_off:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.l	#dummy_proc,vsyncint_sub
	rts




*==========================================================================
*
*	void xsp_hsyncint_on(void *time_chart);
*
*==========================================================================

_xsp_hsyncint_on:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.l	A7ID+arg1_l(sp),usr_chart
	rts




*==========================================================================
*
*	void xsp_hsyncint_off();
*
*==========================================================================

_xsp_hsyncint_off:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.l	#dummy_chart,usr_chart
	rts




*==========================================================================
*
*	void xsp_auto_adjust_divy(short flag);
*
*==========================================================================

_xsp_auto_adjust_divy:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),auto_adjust_divy_flg
	rts




*==========================================================================
*
*	short xsp_divy_get(short i);
*
*==========================================================================

_xsp_divy_get:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),d0	* d0 = i
	bmi	@f			* i < 0 �Ȃ� bra
	cmp #6,d0
	bgt	@f			* 6 < i �Ȃ� bra
	*-----[ 0 <= i <= 6 ]
		add.w	d0,d0			* d0 = i * 2
		lea.l	divy_AB(pc),a0		* a0.l = #divy_AB
		move.w	(a0,d0.w),d0		* dl.w = *(short *)(#divy_AB + i * 2)
		rts
@@:

	move.w	#-1, d0			* �����Ȉ����̏ꍇ�̓G���[�Ƃ��� -1 ��Ԃ�
	rts




*==========================================================================
*
*	void xsp_min_divh_set(short h);
*
*==========================================================================
_xsp_min_divh_set:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),d0	* d0.w = h

	cmp #MIN_DIVH_MIN,d0
	bge @f				* #MIN_DIVH_MIN <= h �Ȃ� bra
	*-----[ MIN_DIVH_MIN > h ]
		moveq.l #MIN_DIVH_MIN,d0	* h = MIN_DIVH_MIN
@@:
	cmp #MIN_DIVH_MAX,d0
	ble @f				* #MIN_DIVH_MAX >= h �Ȃ� bra
	*-----[ MIN_DIVH_MAX < h ]
		moveq.l #MIN_DIVH_MAX,d0	* h = MIN_DIVH_MAX
@@:

	move.w	d0,min_divh		* min_divh �ݒ�

	rts




*==========================================================================
*
*	void xsp_raster_ofs_for31khz_set(short ofs);
*
*==========================================================================
_xsp_raster_ofs_for31khz_set:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),raster_ofs_for31khz


*-------[ �S�o�b�t�@�̃X�v���C�g�]�����X�^�̍Čv�Z�i31KHz �p�j]
	moveq.l	#2,d2
	lea.l	XSP_STRUCT_no_pc,a0
	@@:
		bsr	UPDATE_INT_RASTER_NUMBER_FOR_31KHZ	* �j�� d0-d1/a1
	lea.l	STRUCT_SIZE(a0),a0			* ���̍\���̗v�f��
	dbra	d2,@b					* �w�萔��������܂Ń��[�v

	rts




*==========================================================================
*
*	short xsp_raster_ofs_for31khz_get();
*
*==========================================================================
_xsp_raster_ofs_for31khz_get:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	raster_ofs_for31khz(pc),d0

	rts




*==========================================================================
*
*	void xsp_raster_ofs_for15khz_set(short ofs);
*
*==========================================================================
_xsp_raster_ofs_for15khz_set:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),raster_ofs_for15khz

*-------[ �S�o�b�t�@�̃X�v���C�g�]�����X�^�̍Čv�Z�i15KHz �p�j]
	moveq.l	#2,d2
	lea.l	XSP_STRUCT_no_pc,a0
	@@:
		bsr	UPDATE_INT_RASTER_NUMBER_FOR_15KHZ	* �j�� d0-d1/a1
	lea.l	STRUCT_SIZE(a0),a0			* ���̍\���̗v�f��
	dbra	d2,@b					* �w�萔��������܂Ń��[�v

	rts




*==========================================================================
*
*	short xsp_raster_ofs_for15khz_get();
*
*==========================================================================
_xsp_raster_ofs_for15khz_get:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	raster_ofs_for15khz(pc),d0

	rts




*==========================================================================
*
*	void xsp_vsync_interval_set(short interval);
*
*==========================================================================
_xsp_vsync_interval_set:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	A7ID+arg1_w(sp),d0		* d0.w = interval
	bne.b	@F				* interval 0 �łȂ��Ȃ� bra
		moveq.l	#1,d0			* interval 0 �� 65536 �����ɂȂ��Ă��܂��̂� 1 �ɕ␳
@@:
	move.w	d0,vsync_interval_count_max	* vsync_interval_count_max = d0
	rts




*==========================================================================
*
*	short xsp_vsync_interval_get(void);
*
*==========================================================================
_xsp_vsync_interval_get:

A7ID	=	4			*   �X�^�b�N�� return��A�h���X  [ 4 byte ]
					* + �ޔ����W�X�^�̑S�o�C�g��     [ 0 byte ]

	move.w	vsync_interval_count_max(pc),d0

	rts



