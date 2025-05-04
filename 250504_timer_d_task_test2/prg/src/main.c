/*
	XSP 利用サンプルプログラム

	[動作]
		画面上にスプライトが 1 枚表示されます。ジョイスティックで 8 方向に
		移動可能です。

	[解説]
		XSP システムを用いた最も簡単なプログラムの例です。

*/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <doslib.h>
#include <iocslib.h>
#include "../lib/XSP/XSP2lib.H"

#define FALSE (0)
#define TRUE (!0)

/* スプライト PCG パターン最大使用数 */
#define	PCG_MAX		256


/*
	XSP 用 PCG 配置管理テーブル
	スプライト PCG パターン最大使用数 + 1 バイトのサイズが必要。
*/
char pcg_alt[PCG_MAX + 1];

/* PCG データファイル読み込みバッファ */
char pcg_dat[PCG_MAX * 128];

/* パレットデータファイル読み込みバッファ */
unsigned short pal_dat[256];

/* キャラクタ管理構造体 */
struct {
	short	x, y;		/* 座標 */
	short	pt;			/* スプライトパターン No. */
	short	info;		/* 反転コード・色・優先度を表すデータ */
} g_player;

/* フレームカウント */
short g_frame_count = 0;
// タイマーDスレッド実行回数カウンタ
volatile int g_timerd_cnt = 0;
// g_timerd_cnt クリア要求
char g_b_req_timerd_cnt_clr = FALSE;
// メインスレッド実行回数カウンタ
int g_main_cnt = 0;

/*----------------------[ 垂直帰線期間割り込み関数に与える引数 ]----------------------*/

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
		/* グラフィクス画面 0 を設定 */
		SCROLL(0, arg->scroll_x, arg->scroll_y);
	}
	timerd_thread_wakeup();
}

/*-------------------------------------[ MAIN ]---------------------------------------*/
void main()
{
	int		i;
	FILE	*fp;

	/*---------------------[ 画面を初期化 ]---------------------*/

	/* 256x256 dot 16 色グラフィックプレーン 4 枚 31KHz */
	CRTMOD(6);

	/* グラフィック表示 ON */
	G_CLR_ON();

	/* スプライト表示を ON */
	SP_ON();

	/* BG0 表示 OFF */
	BGCTRLST(0, 0, 0);

	/* BG1 表示 OFF */
	BGCTRLST(1, 1, 0);

	/* グラフィックパレット 1 番を真っ白にする */
	GPALET(1, 0xFFFF);

	/* 簡易説明 */
	printf(
		"ジョイスティック、カーソルキーでスプライトを移動できます。\n"
		"[F10]キーを押すと終了します。\n"
	);

	/* カーソル表示 OFF */
	B_CUROFF();

	/* 格子模様を描画 */
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

	/*------------------[ PCG データ読み込み ]------------------*/

	fp = fopen("./sample/PANEL.SP", "rb");
	if (fp == NULL) {
		CRTMOD(0x10);
		printf("./sample/PANEL.SP が open できません。\n");
		exit(1);
	}
	fread(
		pcg_dat,
		128,		/* 1PCG = 128byte */
		256,		/* 256PCG */
		fp
	);
	fclose(fp);


	/*--------[ スプライトパレットデータ読み込みと定義 ]--------*/

	fp = fopen("./sample/PANEL.PAL", "rb");
	if (fp == NULL) {
		CRTMOD(0x10);
		printf("./sample/PANEL.PAL が open できません。\n");
		exit(1);
	}
	fread(
		pal_dat,
		2,			/* 1color = 2byte */
		256,		/* 16color * 16block */
		fp
	);
	fclose(fp);

	/* スプライトパレットに転送 */
	for (i = 0; i < 256; i++) {
		SPALET((i & 15) | (1 << 0x1F), i / 16, pal_dat[i]);
	}

	// スーパーバイザモードに移行する
	intptr_t usp = B_SUPER(0);
	CRTMOD_192X240_HI_RESO();

	/*---------------------[ XSP を初期化 ]---------------------*/

	/* XSP の初期化 */
	xsp_on();

	/* PCG データと PCG 配置管理をテーブルを指定 */
	xsp_pcgdat_set(pcg_dat, pcg_alt, sizeof(pcg_alt));

	// タイマーD割り込み開始
	initTimerDInterrupt();
	/* 垂直帰線期間割り込み開始 */
	xsp_vsyncint_on(vsync_int);
	timerd_thread_init();

	/*===========================[ スティックで操作するデモ ]=============================*/

	/* 初期化 */
	g_player.x	= 192/2 + 8;	/* X 座標初期値 */
	g_player.y	= 240/2 + 8;	/* Y 座標初期値 */
	g_player.pt	= 0;			/* スプライトパターン No. */
	g_player.info	= 0x013F;	/* 反転コード・色・優先度を表すデータ */
	/* フレームカウント */
	g_frame_count = 0;

	B_LOCATE(0, 4);
	printf("sec TmD MAIN\n");

	timerd_thread_start();
	int bak_second = TIMEGET() & 0xFF;
	for (;;)
	{
		g_main_cnt++;
		// [F10]で終了
		int sns = BITSNS(0xD);
		if (sns & 0x10) break;
		int second = TIMEGET() & 0xFF;
		// RTC の秒が変化したら、表示更新
		if (bak_second != second)
		{
			bak_second = second;
			B_LOCATE(1, 5);
			printf("%02X %3d %6d", second, g_timerd_cnt, g_main_cnt);
			// 表示更新したら g_timerd_cnt, g_main_cnt はリセット
			g_b_req_timerd_cnt_clr = TRUE;
			g_main_cnt = 0;
		}
	}

	/*-----------------------[ 終了処理 ]-----------------------*/

	// タイマーD割り込み終了
	termTimerDInterrupt();
	/* XSP の終了処理 */
	xsp_off();

	// キーバッファのフラッシュ
	while (INPOUT(0xFF));
	/* 画面モードを戻す */
	CRTMOD(0x10);

	// ユーザーモードに復帰する
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
	// -b3 ←
	// -b4 ↑
	// -b5 →
	// -b6 ↓
	int sns = BITSNS(7);

	int	stk;

	/* 垂直帰線期間割り込み関数の引数 */
	g_arg = &vsync_int_args[g_frame_count % NUM_VSYNC_INT_ARGS];

	g_arg->scroll_y -= 1;

	/* スティックの入力に合せて移動 */
	stk = JOYGET(0);
	if (sns & 0x10) stk &= ~0x01;
	if (sns & 0x40) stk &= ~0x02;
	if (sns & 0x08) stk &= ~0x04;
	if (sns & 0x20) stk &= ~0x08;
	if ((stk & 1) == 0  &&  g_player.y >  16) g_player.y -= 1;	/* 上に移動 */
	if ((stk & 2) == 0  &&  g_player.y < 240) g_player.y += 1;	/* 下に移動 */
	if ((stk & 4) == 0  &&  g_player.x >  16) g_player.x -= 1;	/* 左に移動 */
	if ((stk & 8) == 0  &&  g_player.x < 192) g_player.x += 1;	/* 右に移動 */

	/* スプライトの表示登録 */
	xsp_set(g_player.x, g_player.y, g_player.pt, g_player.info);
	/*
		↑ここは、
			xsp_set_st(&g_player);
		と記述すれば、より高速に実行できる。
	*/
	blink++;
	if (blink & 1)
	{
		xsp_set(g_player.x+24, g_player.y+24, g_player.pt, g_player.info);
	}

	/*
		スプライトを一括表示する。
		プライト描画に同期して設定するスクロール座標を、
		垂直帰線期間割り込み関数の引数として渡す。
	*/
	xsp_out2(g_arg);
}

/* 割り込み設定の保存用バッファ */
static volatile uint8_t s_mfpBackup[0x26] = {};
static volatile uint32_t s_vector110Backup = 0;
static volatile uint32_t s_uspBackup = 0;

/* MFP 操作の待ち時間 */
void waitForMfp()
{
	/*
		今となっては出展元が不明ですが、X68000 全盛期当時、
		sr レジスタの書き換えと MFP 操作の間に若干の待ち時間を入れないと、
		X68030 などの高速な CPU 環境で誤動作する恐れがあると言われていました。

		実際に X68030 実機環境でテストできていないため真偽が不明で、
		誤動作は X68000 都市伝説の一つだった可能性も否定できませんが、
		念のため待ち時間を確保する目的で、この関数を実行しています。

		この関数は、何も実行せず return するだけの動作です。
	*/
}
static void initTimerDInterrupt()
{
	register uint32_t reg_a2 asm ("a2") = (uint32_t)timerd_int;

	/*
		最新の gcc 環境では、スーパーバイザーモード⇔ユーザーモードの切り替えに、
		IOCSLIB.L に収録されている B_SUPER() を利用するのは危険です。
		ここでは、スーパーバイザーモード区間にコンパイラの最適化が介入することを
		避けるため、インラインアセンブラを利用します。
	*/
	asm volatile (
		/* MFP のレジスタ番号 */
		"\n"
		"AER		= $003\n"	// アクティブエッジレジスタ
		"IERA		= $007\n"	// 割り込みイネーブルレジスタA 
		"IERB		= $009\n"	// 割り込みイネーブルレジスタB
		"ISRA		= $00F\n"	// 割り込みインサービスレジスタA
		"ISRB		= $011\n"	// 割り込みインサービスレジスタB
		"IMRA		= $013\n"	// 割り込みマスクレジスタA
		"IMRB		= $015\n"	// 割り込みマスクレジスタB
		"TCDCR		= $01D\n"	// タイマーC,Dコントロールレジスタ
		"TDDR		= $025\n"	// タイマーDデータレジスタ
		"\n"

		/* スーパーバイザーモードに入る */
		"	suba.l	a1,a1\n"
		"	iocs	__B_SUPER\n"					/* iocscall.inc で "__B_SUPER: .equ $81" が定義されている */
		"	move.l	d0,_s_uspBackup\n"				/*（もともとスーパーバイザーモードなら d0.l=-1） */

		/* 割り込み off */
		"	ori.w	#$0700,sr\n"
		"	bsr		_waitForMfp\n"

		/* MFP のバックアップを取る */
		"	movea.l	#$e88000,a0\n"					/* a0.l = MFPアドレス */
		"	lea.l	_s_mfpBackup,a1\n"				/* a1.l = MFP保存先アドレス */
		"	move.b	IERB(a0),IERB(a1)\n"			/* IERB 保存 */
		"	move.b	IMRB(a0),IMRB(a1)\n"			/* IMRB 保存 */
		"	move.b	TCDCR(a0),TCDCR(a1)\n"			/* TCDCR 保存 */
		"	move.b	TDDR(a0),TDDR(a1)\n"			/* TDDR 保存 */
		"	move.l	$110,_s_vector110Backup\n"		/* 変更前の TIMER-D ベクタ */

		/* TIMER-D 割り込み設定 */
		"	move.l	a2,$110\n"						/* TIMER-D ベクタ書換え */
		"	bset.b	#4,IMRB(a0)\n"					/* マスクをはがす */
		"	move.b	TCDCR(a0),d0\n"
		"	andi.b	#$F0,d0\n"
		"	move.b	d0,TCDCR(a0)\n"
		"	clr.b	TDDR(a0)\n"
		"	bset.b	#4,IERB(a0)\n"					/* 割り込み許可 */

		/* 割り込み on */
		"	bsr		_waitForMfp\n"
		"	andi.w	#$f8ff,sr\n"

		/* ユーザーモードに復帰 */
		"	move.l	_s_uspBackup,d0\n"
		"	bmi.b	@F\n"							/* スーパーバイザーモードから実行されていたら戻す必要無し */
		"		movea.l	d0,a1\n"
		"		iocs	__B_SUPER\n"				/* iocscall.inc で "__B_SUPER: .equ $81" が定義されている */
		"@@:\n"

	:	/* 出力 */
	:	/* 入力 */	"r"		(reg_a2)				/* in     %0 (入力＆維持) */
	:	/* 破壊 */	"memory",						/* メモリバリアを要求 */
					"d0", "a0", "a1"
	);
}
static void termTimerDInterrupt()
{
	/*
		前述の理由から、インラインアセンブラを利用します。
	*/
	asm volatile (
		/* スーパーバイザーモードに入る */
		"	suba.l	a1,a1\n"
		"	iocs	__B_SUPER\n"					/* iocscall.inc で "__B_SUPER: .equ $81" が定義されている */
		"	move.l	d0,_s_uspBackup\n"				/*（もともとスーパーバイザーモードなら d0.l=-1） */

		/* 割り込み off */
		"	ori.w	#$0700,sr\n"
		"	bsr		_waitForMfp\n"

		/* MFP の設定を復帰 */
		"	movea.l	#$e88000,a0\n"					/* a0.l = MFPアドレス */
		"	lea.l	_s_mfpBackup,a1\n"				/* a1.l = MFPを保存しておいたアドレス */

		"	move.b	IERB(a1),d0\n"
		"	andi.b	#%%0001_0000,d0\n"
		"	andi.b	#%%1110_1111,IERB(a0)\n"
		"	or.b	d0,IERB(a0)\n"					/* IERB bit4 復帰 */

		"	move.b	IMRB(a1),d0\n"
		"	andi.b	#%%0001_0000,d0\n"
		"	andi.b	#%%1110_1111,IMRB(a0)\n"
		"	or.b	d0,IMRB(a0)\n"					/* IMRB bit4 復帰 */

		/* TIMER-D 割り込み復帰 */
		"	move.l	_s_vector110Backup,$110\n"

		/* 割り込み on */
		"	bsr		_waitForMfp\n"
		"	andi.w	#$f8ff,sr\n"

		/* ユーザーモードに復帰 */
		"	move.l	_s_uspBackup,d0\n"
		"	bmi.b	@F\n"							/* スーパーバイザーモードから実行されていたら戻す必要無し */
		"		movea.l	d0,a1\n"
		"		iocs	__B_SUPER\n"				/* iocscall.inc で "__B_SUPER: .equ $81" が定義されている */
		"@@:\n"

	:	/* 出力 */
	:	/* 入力 */
	:	/* 破壊 */	"memory",						/* メモリバリアを要求 */
					"d0", "a0", "a1"
	);
}
