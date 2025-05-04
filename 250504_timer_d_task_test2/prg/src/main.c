/*
	XSP ���p�T���v���v���O����

	[����]
		��ʏ�ɃX�v���C�g�� 1 ���\������܂��B�W���C�X�e�B�b�N�� 8 ������
		�ړ��\�ł��B

	[���]
		XSP �V�X�e����p�����ł��ȒP�ȃv���O�����̗�ł��B

*/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <doslib.h>
#include <iocslib.h>
#include "../lib/XSP/XSP2lib.H"

#define FALSE (0)
#define TRUE (!0)

/* �X�v���C�g PCG �p�^�[���ő�g�p�� */
#define	PCG_MAX		256


/*
	XSP �p PCG �z�u�Ǘ��e�[�u��
	�X�v���C�g PCG �p�^�[���ő�g�p�� + 1 �o�C�g�̃T�C�Y���K�v�B
*/
char pcg_alt[PCG_MAX + 1];

/* PCG �f�[�^�t�@�C���ǂݍ��݃o�b�t�@ */
char pcg_dat[PCG_MAX * 128];

/* �p���b�g�f�[�^�t�@�C���ǂݍ��݃o�b�t�@ */
unsigned short pal_dat[256];

/* �L�����N�^�Ǘ��\���� */
struct {
	short	x, y;		/* ���W */
	short	pt;			/* �X�v���C�g�p�^�[�� No. */
	short	info;		/* ���]�R�[�h�E�F�E�D��x��\���f�[�^ */
} g_player;

/* �t���[���J�E���g */
short g_frame_count = 0;
// �^�C�}�[D�X���b�h���s�񐔃J�E���^
volatile int g_timerd_cnt = 0;
// g_timerd_cnt �N���A�v��
char g_b_req_timerd_cnt_clr = FALSE;
// ���C���X���b�h���s�񐔃J�E���^
int g_main_cnt = 0;

/*----------------------[ �����A�����Ԋ��荞�݊֐��ɗ^������� ]----------------------*/

typedef struct {
	short scroll_x;
	short scroll_y;
} VSYNC_INT_ARG;

#define NUM_VSYNC_INT_ARGS	(4)
VSYNC_INT_ARG vsync_int_args[NUM_VSYNC_INT_ARGS] = {0};
VSYNC_INT_ARG* g_arg;

static void initTimerDInterrupt();
static void termTimerDInterrupt();
void timerd_thread_init();
void __attribute__((interrupt)) timerd_int(void);
void timerd_thread_start();
void timerd_thread_sleep();
void timerd_thread_wakeup();
void vsync_int(const VSYNC_INT_ARG *arg);
void CRTMOD_192X240_HI_RESO();
static void main_frame_run();

void vsync_int(const VSYNC_INT_ARG *arg)
{
	if (arg != NULL) {
		/* �O���t�B�N�X��� 0 ��ݒ� */
		SCROLL(0, arg->scroll_x, arg->scroll_y);
	}
	timerd_thread_wakeup();
}

/*-------------------------------------[ MAIN ]---------------------------------------*/
void main()
{
	int		i;
	FILE	*fp;

	/*---------------------[ ��ʂ������� ]---------------------*/

	/* 256x256 dot 16 �F�O���t�B�b�N�v���[�� 4 �� 31KHz */
	CRTMOD(6);

	/* �O���t�B�b�N�\�� ON */
	G_CLR_ON();

	/* �X�v���C�g�\���� ON */
	SP_ON();

	/* BG0 �\�� OFF */
	BGCTRLST(0, 0, 0);

	/* BG1 �\�� OFF */
	BGCTRLST(1, 1, 0);

	/* �O���t�B�b�N�p���b�g 1 �Ԃ�^�����ɂ��� */
	GPALET(1, 0xFFFF);

	/* �ȈՐ��� */
	printf(
		"�W���C�X�e�B�b�N�A�J�[�\���L�[�ŃX�v���C�g���ړ��ł��܂��B\n"
		"[F10]�L�[�������ƏI�����܂��B\n"
	);

	/* �J�[�\���\�� OFF */
	B_CUROFF();

	/* �i�q�͗l��`�� */
	WINDOW(0, 0, 511, 511);
	for (i = 0; i < 512; i+=16) {
		struct LINEPTR arg;
		arg.x1 = 0;
		arg.y1 = i;
		arg.x2 = 511;
		arg.y2 = i;
		arg.color = 1;
		arg.linestyle = 0x5555;
		LINE(&arg);
		arg.x1 = i;
		arg.y1 = 0;
		arg.x2 = i;
		arg.y2 = 511;
		arg.color = 1;
		arg.linestyle = 0x5555;
		LINE(&arg);
	}

	/*------------------[ PCG �f�[�^�ǂݍ��� ]------------------*/

	fp = fopen("./sample/PANEL.SP", "rb");
	if (fp == NULL) {
		CRTMOD(0x10);
		printf("./sample/PANEL.SP �� open �ł��܂���B\n");
		exit(1);
	}
	fread(
		pcg_dat,
		128,		/* 1PCG = 128byte */
		256,		/* 256PCG */
		fp
	);
	fclose(fp);


	/*--------[ �X�v���C�g�p���b�g�f�[�^�ǂݍ��݂ƒ�` ]--------*/

	fp = fopen("./sample/PANEL.PAL", "rb");
	if (fp == NULL) {
		CRTMOD(0x10);
		printf("./sample/PANEL.PAL �� open �ł��܂���B\n");
		exit(1);
	}
	fread(
		pal_dat,
		2,			/* 1color = 2byte */
		256,		/* 16color * 16block */
		fp
	);
	fclose(fp);

	/* �X�v���C�g�p���b�g�ɓ]�� */
	for (i = 0; i < 256; i++) {
		SPALET((i & 15) | (1 << 0x1F), i / 16, pal_dat[i]);
	}

	// �X�[�p�[�o�C�U���[�h�Ɉڍs����
	intptr_t usp = B_SUPER(0);
	CRTMOD_192X240_HI_RESO();

	/*---------------------[ XSP �������� ]---------------------*/

	/* XSP �̏����� */
	xsp_on();

	/* PCG �f�[�^�� PCG �z�u�Ǘ����e�[�u�����w�� */
	xsp_pcgdat_set(pcg_dat, pcg_alt, sizeof(pcg_alt));

	// �^�C�}�[D���荞�݊J�n
	initTimerDInterrupt();
	/* �����A�����Ԋ��荞�݊J�n */
	xsp_vsyncint_on(vsync_int);
	timerd_thread_init();

	/*===========================[ �X�e�B�b�N�ő��삷��f�� ]=============================*/

	/* ������ */
	g_player.x	= 192/2 + 8;	/* X ���W�����l */
	g_player.y	= 240/2 + 8;	/* Y ���W�����l */
	g_player.pt	= 0;			/* �X�v���C�g�p�^�[�� No. */
	g_player.info	= 0x013F;	/* ���]�R�[�h�E�F�E�D��x��\���f�[�^ */
	/* �t���[���J�E���g */
	g_frame_count = 0;

	B_LOCATE(0, 4);
	printf("sec TmD MAIN\n");

	timerd_thread_start();
	int bak_second = TIMEGET() & 0xFF;
	for (;;)
	{
		g_main_cnt++;
		// [F10]�ŏI��
		int sns = BITSNS(0xD);
		if (sns & 0x10) break;
		int second = TIMEGET() & 0xFF;
		// RTC �̕b���ω�������A�\���X�V
		if (bak_second != second)
		{
			bak_second = second;
			B_LOCATE(1, 5);
			printf("%02X %3d %6d", second, g_timerd_cnt, g_main_cnt);
			// �\���X�V������ g_timerd_cnt, g_main_cnt �̓��Z�b�g
			g_b_req_timerd_cnt_clr = TRUE;
			g_main_cnt = 0;
		}
	}

	/*-----------------------[ �I������ ]-----------------------*/

	// �^�C�}�[D���荞�ݏI��
	termTimerDInterrupt();
	/* XSP �̏I������ */
	xsp_off();

	// �L�[�o�b�t�@�̃t���b�V��
	while (INPOUT(0xFF));
	/* ��ʃ��[�h��߂� */
	CRTMOD(0x10);

	// ���[�U�[���[�h�ɕ��A����
	if (usp > 0)
	{
		B_SUPER(usp);
	}
}
void timerd_main(void)
{
	for (;;)
	{
		if (g_b_req_timerd_cnt_clr)
		{
			g_b_req_timerd_cnt_clr = FALSE;
			g_timerd_cnt = 0;
		}
		g_timerd_cnt++;
		main_frame_run();
		timerd_thread_sleep();
	}
}
/**
 * 
 */
static void main_frame_run()
{
	static int blink;
	// -b3 ��
	// -b4 ��
	// -b5 ��
	// -b6 ��
	int sns = BITSNS(7);

	int	stk;

	/* �����A�����Ԋ��荞�݊֐��̈��� */
	g_arg = &vsync_int_args[g_frame_count % NUM_VSYNC_INT_ARGS];

	g_arg->scroll_y -= 1;

	/* �X�e�B�b�N�̓��͂ɍ����Ĉړ� */
	stk = JOYGET(0);
	if (sns & 0x10) stk &= ~0x01;
	if (sns & 0x40) stk &= ~0x02;
	if (sns & 0x08) stk &= ~0x04;
	if (sns & 0x20) stk &= ~0x08;
	if ((stk & 1) == 0  &&  g_player.y >  16) g_player.y -= 1;	/* ��Ɉړ� */
	if ((stk & 2) == 0  &&  g_player.y < 240) g_player.y += 1;	/* ���Ɉړ� */
	if ((stk & 4) == 0  &&  g_player.x >  16) g_player.x -= 1;	/* ���Ɉړ� */
	if ((stk & 8) == 0  &&  g_player.x < 192) g_player.x += 1;	/* �E�Ɉړ� */

	/* �X�v���C�g�̕\���o�^ */
	xsp_set(g_player.x, g_player.y, g_player.pt, g_player.info);
	/*
		�������́A
			xsp_set_st(&g_player);
		�ƋL�q����΁A��荂���Ɏ��s�ł���B
	*/
	blink++;
	if (blink & 1)
	{
		xsp_set(g_player.x+24, g_player.y+24, g_player.pt, g_player.info);
	}

	/*
		�X�v���C�g���ꊇ�\������B
		�v���C�g�`��ɓ������Đݒ肷��X�N���[�����W���A
		�����A�����Ԋ��荞�݊֐��̈����Ƃ��ēn���B
	*/
	xsp_out2(g_arg);
}

/* ���荞�ݐݒ�̕ۑ��p�o�b�t�@ */
static volatile uint8_t s_mfpBackup[0x26] = {};
static volatile uint32_t s_vector110Backup = 0;
static volatile uint32_t s_uspBackup = 0;

/* MFP ����̑҂����� */
void waitForMfp()
{
	/*
		���ƂȂ��Ă͏o�W�����s���ł����AX68000 �S���������A
		sr ���W�X�^�̏��������� MFP ����̊ԂɎ኱�̑҂����Ԃ����Ȃ��ƁA
		X68030 �Ȃǂ̍����� CPU ���Ō듮�삷�鋰�ꂪ����ƌ����Ă��܂����B

		���ۂ� X68030 ���@���Ńe�X�g�ł��Ă��Ȃ����ߐ^�U���s���ŁA
		�듮��� X68000 �s�s�`���̈�������\�����ے�ł��܂��񂪁A
		�O�̂��ߑ҂����Ԃ��m�ۂ���ړI�ŁA���̊֐������s���Ă��܂��B

		���̊֐��́A�������s���� return ���邾���̓���ł��B
	*/
}
static void initTimerDInterrupt()
{
	register uint32_t reg_a2 asm ("a2") = (uint32_t)timerd_int;

	/*
		�ŐV�� gcc ���ł́A�X�[�p�[�o�C�U�[���[�h�̃��[�U�[���[�h�̐؂�ւ��ɁA
		IOCSLIB.L �Ɏ��^����Ă��� B_SUPER() �𗘗p����̂͊댯�ł��B
		�����ł́A�X�[�p�[�o�C�U�[���[�h��ԂɃR���p�C���̍œK����������邱�Ƃ�
		�����邽�߁A�C�����C���A�Z���u���𗘗p���܂��B
	*/
	asm volatile (
		/* MFP �̃��W�X�^�ԍ� */
		"\n"
		"AER		= $003\n"	// �A�N�e�B�u�G�b�W���W�X�^
		"IERA		= $007\n"	// ���荞�݃C�l�[�u�����W�X�^A 
		"IERB		= $009\n"	// ���荞�݃C�l�[�u�����W�X�^B
		"ISRA		= $00F\n"	// ���荞�݃C���T�[�r�X���W�X�^A
		"ISRB		= $011\n"	// ���荞�݃C���T�[�r�X���W�X�^B
		"IMRA		= $013\n"	// ���荞�݃}�X�N���W�X�^A
		"IMRB		= $015\n"	// ���荞�݃}�X�N���W�X�^B
		"TCDCR		= $01D\n"	// �^�C�}�[C,D�R���g���[�����W�X�^
		"TDDR		= $025\n"	// �^�C�}�[D�f�[�^���W�X�^
		"\n"

		/* �X�[�p�[�o�C�U�[���[�h�ɓ��� */
		"	suba.l	a1,a1\n"
		"	iocs	__B_SUPER\n"					/* iocscall.inc �� "__B_SUPER: .equ $81" ����`����Ă��� */
		"	move.l	d0,_s_uspBackup\n"				/*�i���Ƃ��ƃX�[�p�[�o�C�U�[���[�h�Ȃ� d0.l=-1�j */

		/* ���荞�� off */
		"	ori.w	#$0700,sr\n"
		"	bsr		_waitForMfp\n"

		/* MFP �̃o�b�N�A�b�v����� */
		"	movea.l	#$e88000,a0\n"					/* a0.l = MFP�A�h���X */
		"	lea.l	_s_mfpBackup,a1\n"				/* a1.l = MFP�ۑ���A�h���X */
		"	move.b	IERB(a0),IERB(a1)\n"			/* IERB �ۑ� */
		"	move.b	IMRB(a0),IMRB(a1)\n"			/* IMRB �ۑ� */
		"	move.b	TCDCR(a0),TCDCR(a1)\n"			/* TCDCR �ۑ� */
		"	move.b	TDDR(a0),TDDR(a1)\n"			/* TDDR �ۑ� */
		"	move.l	$110,_s_vector110Backup\n"		/* �ύX�O�� TIMER-D �x�N�^ */

		/* TIMER-D ���荞�ݐݒ� */
		"	move.l	a2,$110\n"						/* TIMER-D �x�N�^������ */
		"	bset.b	#4,IMRB(a0)\n"					/* �}�X�N���͂��� */
		"	move.b	TCDCR(a0),d0\n"
		"	andi.b	#$F0,d0\n"
		"	move.b	d0,TCDCR(a0)\n"
		"	clr.b	TDDR(a0)\n"
		"	bset.b	#4,IERB(a0)\n"					/* ���荞�݋��� */

		/* ���荞�� on */
		"	bsr		_waitForMfp\n"
		"	andi.w	#$f8ff,sr\n"

		/* ���[�U�[���[�h�ɕ��A */
		"	move.l	_s_uspBackup,d0\n"
		"	bmi.b	@F\n"							/* �X�[�p�[�o�C�U�[���[�h������s����Ă�����߂��K�v���� */
		"		movea.l	d0,a1\n"
		"		iocs	__B_SUPER\n"				/* iocscall.inc �� "__B_SUPER: .equ $81" ����`����Ă��� */
		"@@:\n"

	:	/* �o�� */
	:	/* ���� */	"r"		(reg_a2)				/* in     %0 (���́��ێ�) */
	:	/* �j�� */	"memory",						/* �������o���A��v�� */
					"d0", "a0", "a1"
	);
}
static void termTimerDInterrupt()
{
	/*
		�O�q�̗��R����A�C�����C���A�Z���u���𗘗p���܂��B
	*/
	asm volatile (
		/* �X�[�p�[�o�C�U�[���[�h�ɓ��� */
		"	suba.l	a1,a1\n"
		"	iocs	__B_SUPER\n"					/* iocscall.inc �� "__B_SUPER: .equ $81" ����`����Ă��� */
		"	move.l	d0,_s_uspBackup\n"				/*�i���Ƃ��ƃX�[�p�[�o�C�U�[���[�h�Ȃ� d0.l=-1�j */

		/* ���荞�� off */
		"	ori.w	#$0700,sr\n"
		"	bsr		_waitForMfp\n"

		/* MFP �̐ݒ�𕜋A */
		"	movea.l	#$e88000,a0\n"					/* a0.l = MFP�A�h���X */
		"	lea.l	_s_mfpBackup,a1\n"				/* a1.l = MFP��ۑ����Ă������A�h���X */

		"	move.b	IERB(a1),d0\n"
		"	andi.b	#%%0001_0000,d0\n"
		"	andi.b	#%%1110_1111,IERB(a0)\n"
		"	or.b	d0,IERB(a0)\n"					/* IERB bit4 ���A */

		"	move.b	IMRB(a1),d0\n"
		"	andi.b	#%%0001_0000,d0\n"
		"	andi.b	#%%1110_1111,IMRB(a0)\n"
		"	or.b	d0,IMRB(a0)\n"					/* IMRB bit4 ���A */

		/* TIMER-D ���荞�ݕ��A */
		"	move.l	_s_vector110Backup,$110\n"

		/* ���荞�� on */
		"	bsr		_waitForMfp\n"
		"	andi.w	#$f8ff,sr\n"

		/* ���[�U�[���[�h�ɕ��A */
		"	move.l	_s_uspBackup,d0\n"
		"	bmi.b	@F\n"							/* �X�[�p�[�o�C�U�[���[�h������s����Ă�����߂��K�v���� */
		"		movea.l	d0,a1\n"
		"		iocs	__B_SUPER\n"				/* iocscall.inc �� "__B_SUPER: .equ $81" ����`����Ă��� */
		"@@:\n"

	:	/* �o�� */
	:	/* ���� */
	:	/* �j�� */	"memory",						/* �������o���A��v�� */
					"d0", "a0", "a1"
	);
}
