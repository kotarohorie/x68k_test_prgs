*==========================================================================
*
*	512 �����[�h�E�\�[�e�B���O���[�`���i�D��x�ی�@�\�t���j
*
*==========================================================================



*==========================================================================
*
*	�}�N����`
*
*==========================================================================

*--------------------------------------------------------------------------

SORT_512b_An	.macro	An
		.local	end_mark

	*=======[ ���X�^�����o�b�t�@�ɓo�^ ]
		tst.w	(An)			*[12]	�o�b�t�@�`�F�b�N
		bmi.b	end_mark		*[8,10]	���Ȃ�I�_�Ȃ̂Ŕ�΂�
		move.l	d0,(An)+		*[12]	x,y �]��
		move.l	(a0)+,(An)+		*[20]	cd,pr �]��
		dbra	d7,SORT_512b_LOOP
@@:
		movea.l	CHAIN_OFS-4(a0),a0	* ���� PR ���A�h���X
		move.w	CHAIN_OFS(a0),d7	* �A�����i���̂܂� dbcc �J�E���^�Ƃ��Ďg����j
		bpl	SORT_512b_LOOP		* �A���� >= 0 �Ȃ瑱�s
		bra	SORT_512b_PRchange	* PR �ύX

	*-------[ �I�_�ɒB���� ]
end_mark:	addq.w	#4,a0			* �|�C���^�␳�icd,pr���΂��j
		dbra	d7,SORT_512b_LOOP
		bra.b	@B

		.endm

*--------------------------------------------------------------------------

SORT_512b_Dn	.macro	Dn
		.local	end_mark

	*=======[ ���X�^�����o�b�t�@�ɓo�^ ]
		movea.l	Dn,a2			*[ 4]	a2.l = Dn.l
		tst.w	(a2)			*[12]	�o�b�t�@�`�F�b�N
		bmi.b	end_mark		*[8,10]	���Ȃ�I�_�Ȃ̂Ŕ�΂�
		move.l	d0,(a2)+		*[12]	x,y �]��
		move.l	(a0)+,(a2)+		*[20]	cd,pr �]��
		move.l	a2,Dn			*[ 4]	Dn.l �ɖ߂�
		dbra	d7,SORT_512b_LOOP
@@:
		movea.l	CHAIN_OFS-4(a0),a0	* ���� PR ���A�h���X
		move.w	CHAIN_OFS(a0),d7	* �A�����i���̂܂� dbcc �J�E���^�Ƃ��Ďg����j
		bpl	SORT_512b_LOOP		* �A���� >= 0 �Ȃ瑱�s
		bra	SORT_512b_PRchange	* PR �ύX

	*-------[ �I�_�ɒB���� ]
end_mark:	addq.w	#4,a0			* �|�C���^�␳�icd,pr���΂��j
		dbra	d7,SORT_512b_LOOP
		bra.b	@B

		.endm

*--------------------------------------------------------------------------

PR_PROTECT:	.macro	buff_0_protect,buff_1_protect
		.local	PR_PROTECT_0,PR_PROTECT_1,PR_PROTECT_END
					* d0.w = buff_0_total
					* d1.w = buff_1_total
	cmp.w	d0,d1
	bge.b	PR_PROTECT_1		* �� <= �� �Ȃ� bra
	*-------[ �� > �� �̎��i�� buff ��[X]�쐬�j]
PR_PROTECT_0:	move.w	d0,d7
		subq.w	#8,d7			* d7.w = buff_0_total - 8
		cmp.w	buff_1_protect,d7
		ble.b	PR_PROTECT_END		* buff_1_protect >= d7 �Ȃ� bra
			move.w	d7,buff_1_protect
			bra.b	PR_PROTECT_END

	*-------[ �� <= �� �̎��i�� buff ��[X]�쐬�j]
PR_PROTECT_1:					* d1.w = buff_1_total
		cmp.w	buff_0_protect,d1
		ble.b	PR_PROTECT_END		* buff_0_protect >= d1 �Ȃ� bra
			move.w	d1,buff_0_protect

PR_PROTECT_END:

		.endm

*--------------------------------------------------------------------------


*==========================================================================
*
*	�\�[�g�E�A���S���Y��
*
*==========================================================================

					* a0.l = �����p�o�b�t�@�Ǘ��\����

*-------[ ������ 1 ]
	move.l	#8*65,d0		* d0.l = �����o�b�t�@�P���̃T�C�Y

	movea.l	div_buff(a0),a3		* a3.l = #���X�^�����o�b�t�@A
	move.l	a3,d3
	add.l	d0,d3			* d3.l = #���X�^�����o�b�t�@B
	movea.l	d3,a4
	adda.l	d0,a4			* a4.l = #���X�^�����o�b�t�@C
	move.l	a4,d4
	add.l	d0,d4			* d4.l = #���X�^�����o�b�t�@D
	movea.l	d4,a5
	adda.l	d0,a5			* a5.l = #���X�^�����o�b�t�@E
	move.l	a5,d5
	add.l	d0,d5			* d5.l = #���X�^�����o�b�t�@F
	movea.l	d5,a6
	adda.l	d0,a6			* a6.l = #���X�^�����o�b�t�@G
	move.l	a6,d6
	add.l	d0,d6			* d6.l = #���X�^�����o�b�t�@H

	moveq.l	#-1,d0
	move.w	d0,8*65*0+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*1+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*2+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*3+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*4+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*5+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*6+8*64(a3)	* end_mark(SP_x = -1)
	move.w	d0,8*65*7+8*64(a3)	* end_mark(SP_x = -1)


*-------[ ������ 2�i�D��x�ی쏈���p �e��o�b�t�@�̏������j]
	lea.l	buff_A_bak(pc),a2
	move.w	a3,(a2)+
	move.w	d3,(a2)+
	move.w	a4,(a2)+
	move.w	d4,(a2)+
	move.w	a5,(a2)+
	move.w	d5,(a2)+
	move.w	a6,(a2)+
	move.w	d6,(a2)+

	moveq.l	#0,d0
	lea.l	buff_A_total(pc),a2
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+		* �ȉ��Abuff_X_protect �� 0 �N���A
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+


*-------[ ������ 3 ]
					*---------------------------------------
					* a0.l = ���o�b�t�@�X�L�����|�C���^
					* a1.l = 
					* a2.l = temp
					* a3.l = #���X�^�����o�b�t�@A
					* a4.l = #���X�^�����o�b�t�@C
					* a5.l = #���X�^�����o�b�t�@E
					* a6.l = #���X�^�����o�b�t�@G
					* a7.l = PR ���擪���ǂݏo���p
					*---------------------------------------
					* d0.l = temp�iSP_x,SP_y �ǂ݂����j
					* d1.l = temp
	move.w	#$1FC,d2		* d2.w = SP_y ���� 4 �r�b�g�؂�̂ėp and�l
					* d3.l = #���X�^�����o�b�t�@B
					* d4.l = #���X�^�����o�b�t�@D
					* d5.l = #���X�^�����o�b�t�@F
					* d6.l = #���X�^�����o�b�t�@H
					* d7.w = �A���� dbcc �J�E���^
					*---------------------------------------


	move.l	(a7)+,a0		* PR ���Ƃ̐擪�A�h���X
	move.w	CHAIN_OFS(a0),d7	* �A�����i���̂܂� dbcc �J�E���^�Ƃ��Ďg����j
	bmi	SORT_512b_END		* �����Ȃ�A���������i�I�_�j�Ȃ�I��
	bra	SORT_512b_LOOP


*=======[ �D��x�ی쏈�� ]
SORT_512b_PRchange:


*-------[ A�`H �e�X�ɂ��ėD��x�ی쏈�� ]
					* a0.l �́A���� PR ���擪��ǂݏo���܂� free
	lea.l	buff_A_bak(pc),a0
	lea.l	buff_A_used(pc),a1

	move.w	a3,d0			* d0.w = buff_X �|�C���^
	sub.w	(a0),d0			* d0.w = �]����*8
	move.w	d0,(a1)+		* �]����*8 �ۑ�
	move.w	a3,(a0)+		* buff_X_bak �� �|�C���^�ۑ�

	move.w	d3,d0			* d0.w = buff_X �|�C���^
	sub.w	(a0),d0			* d0.w = �]����*8
	move.w	d0,(a1)+		* �]����*8 �ۑ�
	move.w	d3,(a0)+		* buff_X_bak �� �|�C���^�ۑ�

	move.w	a4,d0			* d0.w = buff_X �|�C���^
	sub.w	(a0),d0			* d0.w = �]����*8
	move.w	d0,(a1)+		* �]����*8 �ۑ�
	move.w	a4,(a0)+		* buff_X_bak �� �|�C���^�ۑ�

	move.w	d4,d0			* d0.w = buff_X �|�C���^
	sub.w	(a0),d0			* d0.w = �]����*8
	move.w	d0,(a1)+		* �]����*8 �ۑ�
	move.w	d4,(a0)+		* buff_X_bak �� �|�C���^�ۑ�

	move.w	a5,d0			* d0.w = buff_X �|�C���^
	sub.w	(a0),d0			* d0.w = �]����*8
	move.w	d0,(a1)+		* �]����*8 �ۑ�
	move.w	a5,(a0)+		* buff_X_bak �� �|�C���^�ۑ�

	move.w	d5,d0			* d0.w = buff_X �|�C���^
	sub.w	(a0),d0			* d0.w = �]����*8
	move.w	d0,(a1)+		* �]����*8 �ۑ�
	move.w	d5,(a0)+		* buff_X_bak �� �|�C���^�ۑ�

	move.w	a6,d0			* d0.w = buff_X �|�C���^
	sub.w	(a0),d0			* d0.w = �]����*8
	move.w	d0,(a1)+		* �]����*8 �ۑ�
	move.w	a6,(a0)+		* buff_X_bak �� �|�C���^�ۑ�

	move.w	d6,d0			* d0.w = buff_X �|�C���^
	sub.w	(a0),d0			* d0.w = �]����*8
	move.w	d0,(a1)+		* �]����*8 �ۑ�
	move.w	d6,(a0)+		* buff_X_bak �� �|�C���^�ۑ�



	lea.l	buff_A_total(pc),a0
	lea.l	buff_A_used(pc),a1

	move.w	(a1)+,d0			* d0.w = �]����*8
	beq.b	@f
		movea.l	a3,a2			* a2.l = buff_X �|�C���^
		sub.w	d0,a2			* a2.l = buff_X �� ���� PR �u���b�N�̐擪
		move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C�����́u�]����*8�v�ɏ�����
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total �� �X�L�b�v��*8 ���Z
		add.w	d1,d1			* d1.w = �X�L�b�v��*16
		move.w	d1,CHAIN_OFS_div(a2)	* �`�F�C�����́u�X�L�b�v��*8�v�ɏ�����
@@:	add.w	d0,(a0)+			* buff_X_total �� �]����*8 ���Z

	move.w	(a1)+,d0			* d0.w = �]����*8
	beq.b	@f
		movea.l	d3,a2			* a2.l = buff_X �|�C���^
		sub.w	d0,a2			* a2.l = buff_X �� ���� PR �u���b�N�̐擪
		move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C�����́u�]����*8�v�ɏ�����
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total �� �X�L�b�v��*8 ���Z
		add.w	d1,d1			* d1.w = �X�L�b�v��*16
		move.w	d1,CHAIN_OFS_div(a2)	* �`�F�C�����́u�X�L�b�v��*8�v�ɏ�����
@@:	add.w	d0,(a0)+			* buff_X_total�� �]����*8 ���Z

	move.w	(a1)+,d0			* d0.w = �]����*8
	beq.b	@f
		movea.l	a4,a2			* a2.l = buff_X �|�C���^
		sub.w	d0,a2			* a2.l = buff_X �� ���� PR �u���b�N�̐擪
		move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C�����́u�]����*8�v�ɏ�����
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total �� �X�L�b�v��*8 ���Z
		add.w	d1,d1			* d1.w = �X�L�b�v��*16
		move.w	d1,CHAIN_OFS_div(a2)	* �`�F�C�����́u�X�L�b�v��*8�v�ɏ�����
@@:	add.w	d0,(a0)+			* buff_X_total�� �]����*8 ���Z

	move.w	(a1)+,d0			* d0.w = �]����*8
	beq.b	@f
		movea.l	d4,a2			* a2.l = buff_X �|�C���^
		sub.w	d0,a2			* a2.l = buff_X �� ���� PR �u���b�N�̐擪
		move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C�����́u�]����*8�v�ɏ�����
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total �� �X�L�b�v��*8 ���Z
		add.w	d1,d1			* d1.w = �X�L�b�v��*16
		move.w	d1,CHAIN_OFS_div(a2)	* �`�F�C�����́u�X�L�b�v��*8�v�ɏ�����
@@:	add.w	d0,(a0)+			* buff_X_total�� �]����*8 ���Z

	move.w	(a1)+,d0			* d0.w = �]����*8
	beq.b	@f
		movea.l	a5,a2			* a2.l = buff_X �|�C���^
		sub.w	d0,a2			* a2.l = buff_X �� ���� PR �u���b�N�̐擪
		move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C�����́u�]����*8�v�ɏ�����
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total �� �X�L�b�v��*8 ���Z
		add.w	d1,d1			* d1.w = �X�L�b�v��*16
		move.w	d1,CHAIN_OFS_div(a2)	* �`�F�C�����́u�X�L�b�v��*8�v�ɏ�����
@@:	add.w	d0,(a0)+			* buff_X_total�� �]����*8 ���Z

	move.w	(a1)+,d0			* d0.w = �]����*8
	beq.b	@f
		movea.l	d5,a2			* a2.l = buff_X �|�C���^
		sub.w	d0,a2			* a2.l = buff_X �� ���� PR �u���b�N�̐擪
		move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C�����́u�]����*8�v�ɏ�����
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total �� �X�L�b�v��*8 ���Z
		add.w	d1,d1			* d1.w = �X�L�b�v��*16
		move.w	d1,CHAIN_OFS_div(a2)	* �`�F�C�����́u�X�L�b�v��*8�v�ɏ�����
@@:	add.w	d0,(a0)+			* buff_X_total�� �]����*8 ���Z

	move.w	(a1)+,d0			* d0.w = �]����*8
	beq.b	@f
		movea.l	a6,a2			* a2.l = buff_X �|�C���^
		sub.w	d0,a2			* a2.l = buff_X �� ���� PR �u���b�N�̐擪
		move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C�����́u�]����*8�v�ɏ�����
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total �� �X�L�b�v��*8 ���Z
		add.w	d1,d1			* d1.w = �X�L�b�v��*16
		move.w	d1,CHAIN_OFS_div(a2)	* �`�F�C�����́u�X�L�b�v��*8�v�ɏ�����
@@:	add.w	d0,(a0)+			* buff_X_total�� �]����*8 ���Z

	move.w	(a1)+,d0			* d0.w = �]����*8
	beq.b	@f
		movea.l	d6,a2			* a2.l = buff_X �|�C���^
		sub.w	d0,a2			* a2.l = buff_X �� ���� PR �u���b�N�̐擪
		move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C�����́u�]����*8�v�ɏ�����
		move.w	16(a0),d1		* d1.w  = buff_X_protect
		sub.w	(a0),d1			* d1.w -= buff_X_total
		add.w	d1,d0			* buff_X_total �� �X�L�b�v��*8 ���Z
		add.w	d1,d1			* d1.w = �X�L�b�v��*16
		move.w	d1,CHAIN_OFS_div(a2)	* �`�F�C�����́u�X�L�b�v��*8�v�ɏ�����
@@:	add.w	d0,(a0)+			* buff_X_total�� �]����*8 ���Z



	lea.l	buff_A_protect(pc),a0
	lea.l	buff_A_total(pc),a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+



	lea.l	buff_A_protect(pc),a0
	lea.l	buff_A_total(pc),a1
						* �o�b�t�@���፷��r & �X�L�b�v���̎Z�o
						* PR_PROTECT	 buff_0_protect,buff_1_protect
	move.w	(a1)+,d0			* d0.w = buff_A_total
	move.w	(a1)+,d1			* d1.w = buff_B_total
	PR_PROTECT	00(a0),02(a0)

	move.w	(a1)+,d0			* d0.w = buff_C_total
						* d1.w = buff_B_total
	PR_PROTECT	04(a0),02(a0)

						* d0.w = buff_C_total
	move.w	(a1)+,d1			* d1.w = buff_D_total
	PR_PROTECT	04(a0),06(a0)

	move.w	(a1)+,d0			* d0.w = buff_E_total
						* d1.w = buff_D_total
	PR_PROTECT	08(a0),06(a0)

						* d0.w = buff_E_total
	move.w	(a1)+,d1			* d1.w = buff_F_total
	PR_PROTECT	08(a0),10(a0)

	move.w	(a1)+,d0			* d0.w = buff_G_total
						* d1.w = buff_F_total
	PR_PROTECT	12(a0),10(a0)

						* d0.w = buff_G_total
	move.w	(a1)+,d1			* d1.w = buff_H_total
	PR_PROTECT	12(a0),14(a0)



*=======[ PR �ύX ]
	move.l	(a7)+,a0		* ���� PR �擪�A�h���X
	move.w	CHAIN_OFS(a0),d7	* �A�����i���̂܂� dbcc �J�E���^�Ƃ��Ďg����j
	bmi	SORT_512b_END		* �A���� < 0 �Ȃ�I��


*=======[ �\�[�e�B���O�������[�v ]
SORT_512b_LOOP:
	move.l	(a0)+,d0			*[12]	d0.l = x,y
	move.w	d0,d1				*[ 4]	d1.w = y
	and.w	d2,d1				*[ 4]	d1.w = y & $1FC
	movea.l	SORT_512b_JPTBL(pc,d1.w),a2	*[18]	a2.l = �u�����`��A�h���X
	jmp	(a2)				*[ 8]	�u�����`


*=======[ Y ���W�ʃW�����v�e�[�u�� ]
SORT_512b_JPTBL:
	dcb.l	9,SORT_512b_A		* 36dot
	dcb.l	8,SORT_512b_B		* 32dot
	dcb.l	9,SORT_512b_C		* 36dot
	dcb.l	8,SORT_512b_D		* 32dot
	dcb.l	9,SORT_512b_E		* 36dot
	dcb.l	8,SORT_512b_F		* 32dot
	dcb.l	9,SORT_512b_G		* 36dot
	dcb.l	8,SORT_512b_H		* 32dot

	dcb.l	128-(8+9)*4,SORT_512b_H	* �_�~�[


*=======[ ���X�^�����o�b�t�@�ɓo�^ ]
SORT_512b_A:	SORT_512b_An	a3
SORT_512b_B:	SORT_512b_Dn	d3
SORT_512b_C:	SORT_512b_An	a4
SORT_512b_D:	SORT_512b_Dn	d4
SORT_512b_E:	SORT_512b_An	a5
SORT_512b_F:	SORT_512b_Dn	d5
SORT_512b_G:	SORT_512b_An	a6
SORT_512b_H:	SORT_512b_Dn	d6


*=======[ �D��x�ی쏈���p �e��o�b�t�@ ]
buff_A_total:	dc.w	0
buff_B_total:	dc.w	0
buff_C_total:	dc.w	0
buff_D_total:	dc.w	0
buff_E_total:	dc.w	0
buff_F_total:	dc.w	0
buff_G_total:	dc.w	0
buff_H_total:	dc.w	0
*�������҂́A�A��������������Ԃɑ��݂��邱��
buff_A_protect:	dc.w	0
buff_B_protect:	dc.w	0
buff_C_protect:	dc.w	0
buff_D_protect:	dc.w	0
buff_E_protect:	dc.w	0
buff_F_protect:	dc.w	0
buff_G_protect:	dc.w	0
buff_H_protect:	dc.w	0

buff_A_used:	dc.w	0
buff_B_used:	dc.w	0
buff_C_used:	dc.w	0
buff_D_used:	dc.w	0
buff_E_used:	dc.w	0
buff_F_used:	dc.w	0
buff_G_used:	dc.w	0
buff_H_used:	dc.w	0

buff_A_bak:	dc.w	0
buff_B_bak:	dc.w	0
buff_C_bak:	dc.w	0
buff_D_bak:	dc.w	0
buff_E_bak:	dc.w	0
buff_F_bak:	dc.w	0
buff_G_bak:	dc.w	0
buff_H_bak:	dc.w	0


SORT_512b_END:


*==========================================================================
*
*	�ő� 512 �����[�h �������X�^�ړ� ���̑�
*
*==========================================================================

*-------[ �`�F�C����񖖒[�� end_mark �������� ]

	moveq.l	#0,d0			* d0.l = 0

	move.w	d0,CHAIN_OFS_div+2(a3)	* �`�F�C������ end_mark�i�]����*8 = 0�j��������
	movea.l	d3,a2
	move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C������ end_mark�i�]����*8 = 0�j��������

	move.w	d0,CHAIN_OFS_div+2(a4)	* �`�F�C������ end_mark�i�]����*8 = 0�j��������
	movea.l	d4,a2
	move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C������ end_mark�i�]����*8 = 0�j��������

	move.w	d0,CHAIN_OFS_div+2(a5)	* �`�F�C������ end_mark�i�]����*8 = 0�j��������
	movea.l	d5,a2
	move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C������ end_mark�i�]����*8 = 0�j��������

	move.w	d0,CHAIN_OFS_div+2(a6)	* �`�F�C������ end_mark�i�]����*8 = 0�j��������
	movea.l	d6,a2
	move.w	d0,CHAIN_OFS_div+2(a2)	* �`�F�C������ end_mark�i�]����*8 = 0�j��������


*-------[ �e�����u���b�N�̎g�p�������߂� ]
	move.l	write_struct(pc),a0	* a0.l = �����p�o�b�t�@�Ǘ��\����
	movea.l	div_buff(a0),a1		* a1.l = �o�b�t�@A �擪�A�h���X
	move.l	#8*65,d0		* d0.l = �����o�b�t�@ 1 ���̃T�C�Y

					* a1.l = �o�b�t�@A �擪�A�h���X
	suba.l	a1,a3			* a3.l = �o�b�t�@A �g�p��*8
	adda.l	d0,a1			* a1.l = �o�b�t�@B �擪�A�h���X
	sub.l	a1,d3			* d3.l = �o�b�t�@B �g�p��*8
	adda.l	d0,a1			* a1.l = �o�b�t�@C �擪�A�h���X
	suba.l	a1,a4			* a4.l = �o�b�t�@C �g�p��*8
	adda.l	d0,a1			* a1.l = �o�b�t�@D �擪�A�h���X
	sub.l	a1,d4			* d4.l = �o�b�t�@D �g�p��*8
	adda.l	d0,a1			* a1.l = �o�b�t�@E �擪�A�h���X
	suba.l	a1,a5			* a5.l = �o�b�t�@E �g�p��*8
	adda.l	d0,a1			* a1.l = �o�b�t�@F �擪�A�h���X
	sub.l	a1,d5			* d5.l = �o�b�t�@F �g�p��*8
	adda.l	d0,a1			* a1.l = �o�b�t�@G �擪�A�h���X
	suba.l	a1,a6			* a6.l = �o�b�t�@G �g�p��*8
	adda.l	d0,a1			* a1.l = �o�b�t�@H �擪�A�h���X
	sub.l	a1,d6			* d6.l = �o�b�t�@H �g�p��*8

					*---------------------------------------
					* a0.l = �����p�o�b�t�@�Ǘ��\����
					*---------------------------------------
					* a3.l = ���X�^�����o�b�t�@A �g�p��*8
					* a4.l = ���X�^�����o�b�t�@C �g�p��*8
					* a5.l = ���X�^�����o�b�t�@E �g�p��*8
					* a6.l = ���X�^�����o�b�t�@G �g�p��*8
					*---------------------------------------
					* d3.l = ���X�^�����o�b�t�@B �g�p��*8
					* d4.l = ���X�^�����o�b�t�@D �g�p��*8
					* d5.l = ���X�^�����o�b�t�@F �g�p��*8
					* d6.l = ���X�^�����o�b�t�@H �g�p��*8
					*---------------------------------------

*-------[ ���X�^���� Y ���W�̎����X�V ]
	tst.w	auto_adjust_divy_flg	* ���X�^���� Y ���W�̎����������L�����H
	beq	@f			* NO �Ȃ� bra
		bsr AUTO_ADJUST_DIV_Y
@@:


*-------[ ���ԋl�ߏ��� ]

					*---------------------------------------
					* a0.l = �����p�o�b�t�@�Ǘ��\����
					*---------------------------------------
					* a3.l = ���X�^�����o�b�t�@A �g�p��*8
					* a4.l = ���X�^�����o�b�t�@C �g�p��*8
					* a5.l = ���X�^�����o�b�t�@E �g�p��*8
					* a6.l = ���X�^�����o�b�t�@G �g�p��*8
					*---------------------------------------
					* d3.l = ���X�^�����o�b�t�@B �g�p��*8
					* d4.l = ���X�^�����o�b�t�@D �g�p��*8
					* d5.l = ���X�^�����o�b�t�@F �g�p��*8
					* d6.l = ���X�^�����o�b�t�@H �g�p��*8
					*---------------------------------------

	movea.l	div_buff(a0),a2		* a2.l = ���X�^�����o�b�t�@A �擪�A�h���X

	lea.l	buff_A_total(pc),a1
	move.w	#64*8,d7		* d7.w = 64*8

	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total <= 64*8 �Ȃ� bra
		lea.l	CHAIN_OFS_div+65*8*0(a2),a0	* a0.l = div_buff_X �`�F�C���擪�A�h���X
		move.l	a0,d1
		add.l	a3,d1				* d1.l = div_buff_X �`�F�C�����[�A�h���X
		move.w	d7,d0				* d0.w = 64*8
		sub.w	a3,d0				* d0.w = 64*8 - (buff_X �g�p��*8)
							*      = [X]���e��*8
		bsr	CLEAR_SKIP			* ���ԋl��
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total <= 64*8 �Ȃ� bra
		lea.l	CHAIN_OFS_div+65*8*1(a2),a0	* a0.l = div_buff_X �`�F�C���擪�A�h���X
		move.l	a0,d1
		add.l	d3,d1				* d1.l = div_buff_X �`�F�C�����[�A�h���X
		move.w	d7,d0				* d0.w = 64*8
		sub.w	d3,d0				* d0.w = 64*8 - (buff_X �g�p��*8)
							*      = [X]���e��*8
		bsr	CLEAR_SKIP			* ���ԋl��
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total <= 64*8 �Ȃ� bra
		lea.l	CHAIN_OFS_div+65*8*2(a2),a0	* a0.l = div_buff_X �`�F�C���擪�A�h���X
		move.l	a0,d1
		add.l	a4,d1				* d1.l = div_buff_X �`�F�C�����[�A�h���X
		move.w	d7,d0				* d0.w = 64*8
		sub.w	a4,d0				* d0.w = 64*8 - (buff_X �g�p��*8)
							*      = [X]���e��*8
		bsr	CLEAR_SKIP			* ���ԋl��
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total <= 64*8 �Ȃ� bra
		lea.l	CHAIN_OFS_div+65*8*3(a2),a0	* a0.l = div_buff_X �`�F�C���擪�A�h���X
		move.l	a0,d1
		add.l	d4,d1				* d1.l = div_buff_X �`�F�C�����[�A�h���X
		move.w	d7,d0				* d0.w = 64*8
		sub.w	d4,d0				* d0.w = 64*8 - (buff_X �g�p��*8)
							*      = [X]���e��*8
		bsr	CLEAR_SKIP			* ���ԋl��
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total <= 64*8 �Ȃ� bra
		lea.l	CHAIN_OFS_div+65*8*4(a2),a0	* a0.l = div_buff_X �`�F�C���擪�A�h���X
		move.l	a0,d1
		add.l	a5,d1				* d1.l = div_buff_X �`�F�C�����[�A�h���X
		move.w	d7,d0				* d0.w = 64*8
		sub.w	a5,d0				* d0.w = 64*8 - (buff_X �g�p��*8)
							*      = [X]���e��*8
		bsr	CLEAR_SKIP			* ���ԋl��
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total <= 64*8 �Ȃ� bra
		lea.l	CHAIN_OFS_div+65*8*5(a2),a0	* a0.l = div_buff_X �`�F�C���擪�A�h���X
		move.l	a0,d1
		add.l	d5,d1				* d1.l = div_buff_X �`�F�C�����[�A�h���X
		move.w	d7,d0				* d0.w = 64*8
		sub.w	d5,d0				* d0.w = 64*8 - (buff_X �g�p��*8)
							*      = [X]���e��*8
		bsr	CLEAR_SKIP			* ���ԋl��
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total <= 64*8 �Ȃ� bra
		lea.l	CHAIN_OFS_div+65*8*6(a2),a0	* a0.l = div_buff_X �`�F�C���擪�A�h���X
		move.l	a0,d1
		add.l	a6,d1				* d1.l = div_buff_X �`�F�C�����[�A�h���X
		move.w	d7,d0				* d0.w = 64*8
		sub.w	a6,d0				* d0.w = 64*8 - (buff_X �g�p��*8)
							*      = [X]���e��*8
		bsr	CLEAR_SKIP			* ���ԋl��
@@:
	cmp.w	(a1)+,d7
	bge.b	@f					* buff_X_total <= 64*8 �Ȃ� bra
		lea.l	CHAIN_OFS_div+65*8*7(a2),a0	* a0.l = div_buff_X �`�F�C���擪�A�h���X
		move.l	a0,d1
		add.l	d6,d1				* d1.l = div_buff_X �`�F�C�����[�A�h���X
		move.w	d7,d0				* d0.w = 64*8
		sub.w	d6,d0				* d0.w = 64*8 - (buff_X �g�p��*8)
							*      = [X]���e��*8
		bsr	CLEAR_SKIP			* ���ԋl��
@@:




