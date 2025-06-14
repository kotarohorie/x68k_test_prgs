*==========================================================================
*
*	512 �����[�h�E�\�[�e�B���O���[�`���i�D��x�ی�@�\�Ȃ��j
*
*==========================================================================



*==========================================================================
*
*	�}�N����`
*
*==========================================================================

*--------------------------------------------------------------------------

SORT_512_An	.macro	An
		.local	end_mark

	*=======[ ���X�^�����o�b�t�@�ɓo�^ ]
		tst.w	(An)			*[12]	�o�b�t�@�`�F�b�N
		bmi.b	end_mark		*[8,10]	���Ȃ�I�_�Ȃ̂Ŕ�΂�
		move.l	d0,(An)+		*[12]	x,y �]��
		move.l	(a0)+,(An)+		*[20]	cd,pr �]��
		dbra	d7,SORT_512_LOOP
@@:
		movea.l	CHAIN_OFS-4(a0),a0	* ���� PR ���A�h���X
		move.w	CHAIN_OFS(a0),d7	* �A�����i���̂܂� dbcc �J�E���^�Ƃ��Ďg����j
		bpl	SORT_512_LOOP		* �A���� >= 0 �Ȃ瑱�s
	*-------[ PR �ύX ]
		move.l	(a7)+,a0		* ���� PR �̐擪�A�h���X
		move.w	CHAIN_OFS(a0),d7	* �A�����i���̂܂� dbcc �J�E���^�Ƃ��Ďg����j
		bpl	SORT_512_LOOP		* �A���� >= 0 �Ȃ瑱�s
		bra	SORT_512_END		* �I��

	*-------[ �I�_�ɒB���� ]
end_mark:	addq.w	#4,a0			* �|�C���^�␳�icd,pr ���΂��j
		dbra	d7,SORT_512_LOOP
		bra.b	@B

		.endm

*--------------------------------------------------------------------------

SORT_512_Dn	.macro	Dn
		.local	end_mark

	*=======[ ���X�^�����o�b�t�@�ɓo�^ ]
		movea.l	Dn,a2			*[ 4]	a2.l = Dn.l
		tst.w	(a2)			*[12]	�o�b�t�@�`�F�b�N
		bmi.b	end_mark		*[8,10]	���Ȃ�I�_�Ȃ̂Ŕ�΂�
		move.l	d0,(a2)+		*[12]	x,y �]��
		move.l	(a0)+,(a2)+		*[20]	cd,pr �]��
		move.l	a2,Dn			*[ 4]	Dn.l �ɖ߂�
		dbra	d7,SORT_512_LOOP
@@:
		movea.l	CHAIN_OFS-4(a0),a0	* ���� PR ���A�h���X
		move.w	CHAIN_OFS(a0),d7	* �A�����i���̂܂� dbcc �J�E���^�Ƃ��Ďg����j
		bpl	SORT_512_LOOP		* �A���� >= 0 �Ȃ瑱�s
	*-------[ PR �ύX ]
		move.l	(a7)+,a0		* ���� PR �̐擪�A�h���X
		move.w	CHAIN_OFS(a0),d7	* �A�����i���̂܂� dbcc �J�E���^�Ƃ��Ďg����j
		bpl	SORT_512_LOOP		* �A���� >= 0 �Ȃ瑱�s
		bra	SORT_512_END		* �I��

	*-------[ �I�_�ɒB���� ]
end_mark:	addq.w	#4,a0			* �|�C���^�␳�icd,pr ���΂��j
		dbra	d7,SORT_512_LOOP
		bra.b	@B

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


*-------[ ������ 2 ]
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
	bmi	SORT_512_END		* �����Ȃ�A���������i�I�_�j�Ȃ�I��

*=======[ �\�[�e�B���O�������[�v ]
SORT_512_LOOP:
	move.l	(a0)+,d0			*[12]	d0.l = x,y
	move.w	d0,d1				*[ 4]	d1.w = y
	and.w	d2,d1				*[ 4]	d1.w = y & $1FC
	movea.l	SORT_512_JPTBL(pc,d1.w),a2	*[18]	a2.l = �u�����`��A�h���X
	jmp	(a2)				*[ 8]	�u�����`


*=======[ Y ���W�ʃW�����v�e�[�u�� ]
SORT_512_JPTBL:
	dcb.l	9,SORT_512_A		* 36dot
	dcb.l	8,SORT_512_B		* 32dot
	dcb.l	9,SORT_512_C		* 36dot
	dcb.l	8,SORT_512_D		* 32dot
	dcb.l	9,SORT_512_E		* 36dot
	dcb.l	8,SORT_512_F		* 32dot
	dcb.l	9,SORT_512_G		* 36dot
	dcb.l	8,SORT_512_H		* 32dot

	dcb.l	128-(8+9)*4,SORT_512_H	* �_�~�[


*=======[ ���X�^�����o�b�t�@�ɓo�^ ]
SORT_512_A:	SORT_512_An	a3
SORT_512_B:	SORT_512_Dn	d3
SORT_512_C:	SORT_512_An	a4
SORT_512_D:	SORT_512_Dn	d4
SORT_512_E:	SORT_512_An	a5
SORT_512_F:	SORT_512_Dn	d5
SORT_512_G:	SORT_512_An	a6
SORT_512_H:	SORT_512_Dn	d6


SORT_512_END:



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


*-------[ �e�����u���b�N�̎g�p�������߁A�`�F�C�����擪�� �]����*8 �������� ]

	move.l	write_struct(pc),a0	* a0.l = �����p�o�b�t�@�Ǘ��\����
	movea.l	div_buff(a0),a1		* a1.l = �o�b�t�@A �擪�A�h���X
	move.l	#8*65,d0		* d0.l = �����o�b�t�@ 1 ���̃T�C�Y

					* a1.l = �o�b�t�@A �擪�A�h���X
	suba.l	a1,a3			* a3.l = �o�b�t�@A �g�p��*8
	move.l	a3,CHAIN_OFS_div(a1)	* �`�F�C�����i�g�p��*8�j��������
					* ���A�X�L�b�v��*8 �� 0 �N���A

	adda.l	d0,a1			* a1.l = �o�b�t�@B �擪�A�h���X
	sub.l	a1,d3			* d3.l = �o�b�t�@B �g�p��*8
	move.l	d3,CHAIN_OFS_div(a1)	* �`�F�C�����i�g�p��*8�j��������
					* ���A�X�L�b�v��*8 �� 0 �N���A

	adda.l	d0,a1			* a1.l = �o�b�t�@C �擪�A�h���X
	suba.l	a1,a4			* a4.l = �o�b�t�@C �g�p��*8
	move.l	a4,CHAIN_OFS_div(a1)	* �`�F�C�����i�g�p��*8�j��������
					* ���A�X�L�b�v��*8 �� 0 �N���A

	adda.l	d0,a1			* a1.l = �o�b�t�@D �擪�A�h���X
	sub.l	a1,d4			* d4.l = �o�b�t�@D �g�p��*8
	move.l	d4,CHAIN_OFS_div(a1)	* �`�F�C�����i�g�p��*8�j��������
					* ���A�X�L�b�v��*8 �� 0 �N���A

	adda.l	d0,a1			* a1.l = �o�b�t�@E �擪�A�h���X
	suba.l	a1,a5			* a5.l = �o�b�t�@E �g�p��*8
	move.l	a5,CHAIN_OFS_div(a1)	* �`�F�C�����i�g�p��*8�j��������
					* ���A�X�L�b�v��*8 �� 0 �N���A

	adda.l	d0,a1			* a1.l = �o�b�t�@F �擪�A�h���X
	sub.l	a1,d5			* d5.l = �o�b�t�@F �g�p��*8
	move.l	d5,CHAIN_OFS_div(a1)	* �`�F�C�����i�g�p��*8�j��������
					* ���A�X�L�b�v��*8 �� 0 �N���A

	adda.l	d0,a1			* a1.l = �o�b�t�@G �擪�A�h���X
	suba.l	a1,a6			* a6.l = �o�b�t�@G �g�p��*8
	move.l	a6,CHAIN_OFS_div(a1)	* �`�F�C�����i�g�p��*8�j��������
					* ���A�X�L�b�v��*8 �� 0 �N���A

	adda.l	d0,a1			* a1.l = �o�b�t�@H �擪�A�h���X
	sub.l	a1,d6			* d6.l = �o�b�t�@H �g�p��*8
	move.l	d6,CHAIN_OFS_div(a1)	* �`�F�C�����i�g�p��*8�j��������
					* ���A�X�L�b�v��*8 �� 0 �N���A

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


