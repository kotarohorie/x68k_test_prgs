
	.text
	.even

vector_118_bak:	dc.l	0			* �ύX�O�� V-disp �x�N�^
vector_138_bak:	dc.l	0			* �ύX�O�� CRT-IRQ �x�N�^
raster_No_bak:	dc.w	0			* �ύX�O�� CRT-IRQ ���X�^ No.
MFP_bak:	dcb.b	$18,0			* �ύX�O�� MFP

	.even


*--------------[ �X�v���C�g���o�b�t�@�̃|�C���^ ]
buff_pointer:
		dc.l	buff_top_adr_no_pc

*--------------[ ���[�U�[�w��A�����Ԋ��荞�� ]
vsyncint_sub:	dc.l	dummy_proc		* ���荞�ݏ����T�u���[�`���A�h���X�i�����l�̓_�~�[�j

*--------------[ ���X�^���荞�݊֌W ]
hsyncint_sub:	dc.l	dummy_proc		* ���荞�ݏ����T�u���[�`���A�h���X�i�����l�̓_�~�[�j
xsp_chart_ptr:	dc.l	dummy_chart		* XSP ���`���[�g�ւ̃|�C���^�i�����l�̓_�~�[�j
usr_chart_ptr:	dc.l	dummy_chart		* USR ���`���[�g�ւ̃|�C���^�i�����l�̓_�~�[�j
usr_chart:	dc.l	dummy_chart		* USR ���`���[�g�ւ̃|�C���^�����l�iUSR �w��\�j

*----------------[ ���X�^���� Y ���W ]
divy_AB:	dc.w	36			* ���X�^�����o�b�t�@AB ���E Y
divy_BC:	dc.w	36+32			* ���X�^�����o�b�t�@BC ���E Y
divy_CD:	dc.w	36+32+36		* ���X�^�����o�b�t�@CD ���E Y
divy_DE:	dc.w	36+32+36+32		* ���X�^�����o�b�t�@DE ���E Y
divy_EF:	dc.w	36+32+36+32+36		* ���X�^�����o�b�t�@EF ���E Y
divy_FG:	dc.w	36+32+36+32+36+32	* ���X�^�����o�b�t�@FG ���E Y
divy_GH:	dc.w	36+32+36+32+36+32+36	* ���X�^�����o�b�t�@GH ���E Y

*--------------[ ���̑� ]
sp_mode:	dc.w	2			* XSP �̃��[�h�i1�`3�j

R65535:		dc.w	0			* �V�X�e�������J�E���^

write_struct:		dc.l	XSP_STRUCT_no_pc+STRUCT_SIZE	* �����p�o�b�t�@�Ǘ��\���̃A�h���X
disp_struct:		dc.l	XSP_STRUCT_no_pc		* �\���p�o�b�t�@�Ǘ��\���̃A�h���X
penging_disp_count:	dc.w	0				* �ۗ���Ԃ̕\�����N�G�X�g��

vsync_count:	dc.w	0			* �A�����Ԃ̓x�ɃC���N�������g�����

vsync_interval_count_max:	dc.w	1	* vsync_interval �J�E���^ max �l
vsync_interval_count_down:	dc.w	1	* vsync_interval �J�E���g�_�E��

sp_ref_adr:	dc.l	0			* �����X�v���C�g�̃��t�@�����X�f�[�^�ւ̃|�C���^

pcg_alt_adr:	dc.l	0			* pcg_alt �̃|�C���^�i���[�U�[�w��j

pcg_dat_adr:	dc.l	0			* PCG �f�[�^�̃|�C���^�i���[�U�[�w��j

OX_level:	dc.b	0			* OX_tbl ����
	.even
OX_mask_renew:	dc.w	0			* OX_mask �X�V�����������Ƃ������t���O�i�� 0 �ōX�V�j
OX_chk_top:	dc.l	0			* OX_tbl �����J�n�A�h���X
OX_chk_ptr:	dc.l	0			* OX_tbl �����|�C���^
OX_chk_size:	dc.w	0			* OX_tbl �����T�C�Y - 1�idbra �J�E���^�Ƃ���j

a7_bak1:	dc.l	0			* A7 ���W�X�^��ۑ��i���W�X�^�ޔ𒼌�j

usp_bak:	dc.l	0			* usp �ۑ�

XSP_flg:	dc.b	0			* XSP ��������Ԃ̃t���O�i8 �r�b�g�j
						* bit0 = �g���ݏ�Ԃ��H
						* bit1 = PCG_DAT,PCG_ALT �w��ς��H
	.even

vertical_flg:	dc.w	0			* �c��ʃ��[�h�t���O�i�� 0 = �c��ʃ��[�h�j

min_divh:	dc.w	32			* ���X�^�����u���b�N�c���ŏ��l�i�� 0 = ���������j

auto_adjust_divy_flg:	dc.w	1		* ���X�^���� Y ���W���������t���O�i�� 0 = ���������j

raster_ofs_for31khz:	dc.w	16*2+8		* �X�v���C�g�]�����X�^�̒����l�i31KHz �p�j
						*	+16*2 �� 31KHz ���̃X�v���C�g�̏c�����X�^���B
						*	+24 �̓^�C�~���O�����p�B
						*	XSP ver2.00 �݊��ɂ���ɂ� +24 �Ƃ���B
						*	XM6 ���� +8 ���Ó��B
raster_ofs_for15khz:	dc.w	16*1+0		* �X�v���C�g�]�����X�^�̒����l�i15KHz �p�j
						*	+16*1 �� 15KHz ���̃X�v���C�g�̏c�����X�^���B
						*	+0 �̓^�C�~���O�����p�B
						*	XSP ver2.00 �݊��ɂ���ɂ� +16 �Ƃ���B


*==============================================================

	.bss
	.even


*--------------[ XSP �o�b�t�@�Ǘ��\���́i�o�b�t�@ No. �ʁj]
XSP_STRUCT_no_pc:
		ds.b	STRUCT_SIZE*3
endof_XSP_STRUCT_no_pc:


*----------------[ �X�v���C�g���o�b�t�@ & �D��x�\�[�g�֌W�̃o�b�t�@ ]

		ds.b	8		* end_mark�ipr = 0�j
buff_top_adr_no_pc:
		ds.b	8*SP_MAX	* push�\���� x 8 �o�C�g
buff_end_adr_no_pc:
		ds.b	8		* end_mark�i8 �o�C�g�� -1�j�� �I�_�_�~�[ PR �u���b�N
		ds.b	8*SP_MAX	* �\�[�g�`�F�C���쐬�o�b�t�@
		ds.b	8		* �I�_�_�~�[�`�F�C��

pr_top_tbl_no_pc:
		ds.l	64		* PR �ʐ擪�e�[�u��
		ds.l	1		* end_mark �p


*----------------[ ���X�^�ʕ����\�[�g�ς݃X�v���C�g�ۑ��o�b�t�@ ]

*	�o�b�t�@�͕\���p�E�����p�E�\���p�̍��v 3 �{�iNo.0�`2�j
*	���ꂼ�ꕪ�����X�^�ʂ� 4 �ɍו�����܂��B


*	[ + $0000 = �o�b�t�@No.0 ]
div_buff_0A_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@A
		ds.b	8		* end_mark
div_buff_0B_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@B
		ds.b	8		* end_mark
div_buff_0C_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@C
		ds.b	8		* end_mark
div_buff_0D_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@D
		ds.b	8		* end_mark
div_buff_0E_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@E
		ds.b	8		* end_mark
div_buff_0F_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@F
		ds.b	8		* end_mark
div_buff_0G_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@G
		ds.b	8		* end_mark
div_buff_0H_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@H
		ds.b	8		* end_mark


*	[ + $1040 = �o�b�t�@No.1 ]
div_buff_1A_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@A
		ds.b	8		* end_mark
div_buff_1B_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@B
		ds.b	8		* end_mark
div_buff_1C_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@C
		ds.b	8		* end_mark
div_buff_1D_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@D
		ds.b	8		* end_mark
div_buff_1E_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@E
		ds.b	8		* end_mark
div_buff_1F_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@F
		ds.b	8		* end_mark
div_buff_1G_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@G
		ds.b	8		* end_mark
div_buff_1H_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@H
		ds.b	8		* end_mark


*	[ + $2080 = �o�b�t�@No.2 ]
div_buff_2A_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@A
		ds.b	8		* end_mark
div_buff_2B_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@B
		ds.b	8		* end_mark
div_buff_2C_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@C
		ds.b	8		* end_mark
div_buff_2D_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@D
		ds.b	8		* end_mark
div_buff_2E_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@E
		ds.b	8		* end_mark
div_buff_2F_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@F
		ds.b	8		* end_mark
div_buff_2G_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@G
		ds.b	8		* end_mark
div_buff_2H_no_pc:
		ds.b	8*64		* ���X�^�����o�b�t�@H
		ds.b	8		* end_mark

*	[ + $30C0 = �]���`�F�C����� ]
div_buff_chain_no_pc:
		ds.b	(8*64+8)*8*3


*----------------[ PCG �z�u�Ǘ��i�t�Q�Ɓj�e�[�u�� ]

*	PCG_No.���p�^�[��No. �ϊ��e�[�u���ł��B

pcg_rev_alt_no_pc:
		ds.w	256		* �t�Q�� alt �����l(-1)���������ނ���


*----------------[ OX �e�[�u�� ]

*	�e PCG ���g�p����Ă��邩�ǂ�����\���e�[�u���ł��B

OX_tbl_no_pc:
		ds.b	256		* ���ʏ��
		ds.w	1		* end_mark(0)���������ނ���
OX_mask_no_pc:
		ds.b	256		* �}�X�N���i0:off  255:on�j


