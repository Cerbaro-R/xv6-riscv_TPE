
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	42813103          	ld	sp,1064(sp) # 8000a428 <_GLOBAL_OFFSET_TABLE_+0x8>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	042000ef          	jal	80000058 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000024:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000028:	577d                	li	a4,-1
    8000002a:	177e                	slli	a4,a4,0x3f
    8000002c:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002e:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000032:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000036:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    8000003a:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003e:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000042:	000f4737          	lui	a4,0xf4
    80000046:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000004a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004c:	14d79073          	csrw	stimecmp,a5
}
    80000050:	60a2                	ld	ra,8(sp)
    80000052:	6402                	ld	s0,0(sp)
    80000054:	0141                	addi	sp,sp,16
    80000056:	8082                	ret

0000000080000058 <start>:
{
    80000058:	1141                	addi	sp,sp,-16
    8000005a:	e406                	sd	ra,8(sp)
    8000005c:	e022                	sd	s0,0(sp)
    8000005e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    80000060:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000064:	7779                	lui	a4,0xffffe
    80000066:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdae6f>
    8000006a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000006c:	6705                	lui	a4,0x1
    8000006e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000072:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000074:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000078:	00001797          	auipc	a5,0x1
    8000007c:	e1678793          	addi	a5,a5,-490 # 80000e8e <main>
    80000080:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000084:	4781                	li	a5,0
    80000086:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    8000008a:	67c1                	lui	a5,0x10
    8000008c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    80000092:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000096:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    8000009a:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    800000a2:	57fd                	li	a5,-1
    800000a4:	83a9                	srli	a5,a5,0xa
    800000a6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000aa:	47bd                	li	a5,15
    800000ac:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000b0:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b4:	4705                	li	a4,1
    800000b6:	1776                	slli	a4,a4,0x3d
    800000b8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000ba:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000be:	f5fff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000c2:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c6:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c8:	823e                	mv	tp,a5
  asm volatile("mret");
    800000ca:	30200073          	mret
}
    800000ce:	60a2                	ld	ra,8(sp)
    800000d0:	6402                	ld	s0,0(sp)
    800000d2:	0141                	addi	sp,sp,16
    800000d4:	8082                	ret

00000000800000d6 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d6:	7119                	addi	sp,sp,-128
    800000d8:	fc86                	sd	ra,120(sp)
    800000da:	f8a2                	sd	s0,112(sp)
    800000dc:	f4a6                	sd	s1,104(sp)
    800000de:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000e0:	06c05b63          	blez	a2,80000156 <consolewrite+0x80>
    800000e4:	f0ca                	sd	s2,96(sp)
    800000e6:	ecce                	sd	s3,88(sp)
    800000e8:	e8d2                	sd	s4,80(sp)
    800000ea:	e4d6                	sd	s5,72(sp)
    800000ec:	e0da                	sd	s6,64(sp)
    800000ee:	fc5e                	sd	s7,56(sp)
    800000f0:	f862                	sd	s8,48(sp)
    800000f2:	f466                	sd	s9,40(sp)
    800000f4:	f06a                	sd	s10,32(sp)
    800000f6:	8b2a                	mv	s6,a0
    800000f8:	8bae                	mv	s7,a1
    800000fa:	8a32                	mv	s4,a2
  int i = 0;
    800000fc:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000fe:	02000c93          	li	s9,32
    80000102:	02000d13          	li	s10,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000106:	f8040a93          	addi	s5,s0,-128
    8000010a:	5c7d                	li	s8,-1
    8000010c:	a025                	j	80000134 <consolewrite+0x5e>
    if (nn > n - i)
    8000010e:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000112:	86ce                	mv	a3,s3
    80000114:	01748633          	add	a2,s1,s7
    80000118:	85da                	mv	a1,s6
    8000011a:	8556                	mv	a0,s5
    8000011c:	2d2020ef          	jal	800023ee <either_copyin>
    80000120:	03850d63          	beq	a0,s8,8000015a <consolewrite+0x84>
      break;
    uartwrite(buf, nn);
    80000124:	85ce                	mv	a1,s3
    80000126:	8556                	mv	a0,s5
    80000128:	7c2000ef          	jal	800008ea <uartwrite>
    i += nn;
    8000012c:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    80000130:	0144d963          	bge	s1,s4,80000142 <consolewrite+0x6c>
    if (nn > n - i)
    80000134:	409a07bb          	subw	a5,s4,s1
    80000138:	893e                	mv	s2,a5
    8000013a:	fcfcdae3          	bge	s9,a5,8000010e <consolewrite+0x38>
    8000013e:	896a                	mv	s2,s10
    80000140:	b7f9                	j	8000010e <consolewrite+0x38>
    80000142:	7906                	ld	s2,96(sp)
    80000144:	69e6                	ld	s3,88(sp)
    80000146:	6a46                	ld	s4,80(sp)
    80000148:	6aa6                	ld	s5,72(sp)
    8000014a:	6b06                	ld	s6,64(sp)
    8000014c:	7be2                	ld	s7,56(sp)
    8000014e:	7c42                	ld	s8,48(sp)
    80000150:	7ca2                	ld	s9,40(sp)
    80000152:	7d02                	ld	s10,32(sp)
    80000154:	a821                	j	8000016c <consolewrite+0x96>
  int i = 0;
    80000156:	4481                	li	s1,0
    80000158:	a811                	j	8000016c <consolewrite+0x96>
    8000015a:	7906                	ld	s2,96(sp)
    8000015c:	69e6                	ld	s3,88(sp)
    8000015e:	6a46                	ld	s4,80(sp)
    80000160:	6aa6                	ld	s5,72(sp)
    80000162:	6b06                	ld	s6,64(sp)
    80000164:	7be2                	ld	s7,56(sp)
    80000166:	7c42                	ld	s8,48(sp)
    80000168:	7ca2                	ld	s9,40(sp)
    8000016a:	7d02                	ld	s10,32(sp)
  }

  return i;
}
    8000016c:	8526                	mv	a0,s1
    8000016e:	70e6                	ld	ra,120(sp)
    80000170:	7446                	ld	s0,112(sp)
    80000172:	74a6                	ld	s1,104(sp)
    80000174:	6109                	addi	sp,sp,128
    80000176:	8082                	ret

0000000080000178 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000178:	711d                	addi	sp,sp,-96
    8000017a:	ec86                	sd	ra,88(sp)
    8000017c:	e8a2                	sd	s0,80(sp)
    8000017e:	e4a6                	sd	s1,72(sp)
    80000180:	e0ca                	sd	s2,64(sp)
    80000182:	fc4e                	sd	s3,56(sp)
    80000184:	f852                	sd	s4,48(sp)
    80000186:	f05a                	sd	s6,32(sp)
    80000188:	ec5e                	sd	s7,24(sp)
    8000018a:	1080                	addi	s0,sp,96
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	8bb2                	mv	s7,a2
  acquire(&cons.lock);
    80000194:	00012517          	auipc	a0,0x12
    80000198:	2dc50513          	addi	a0,a0,732 # 80012470 <cons>
    8000019c:	27d000ef          	jal	80000c18 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    800001a0:	00012497          	auipc	s1,0x12
    800001a4:	2d048493          	addi	s1,s1,720 # 80012470 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a8:	00012917          	auipc	s2,0x12
    800001ac:	36090913          	addi	s2,s2,864 # 80012508 <cons+0x98>
  while (n > 0) {
    800001b0:	0d305263          	blez	s3,80000274 <consoleread+0xfc>
    while (cons.r == cons.w) {
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	0af71763          	bne	a4,a5,8000026a <consoleread+0xf2>
      if (killed(myproc())) {
    800001c0:	778010ef          	jal	80001938 <myproc>
    800001c4:	0aa020ef          	jal	8000226e <killed>
    800001c8:	e925                	bnez	a0,80000238 <consoleread+0xc0>
      sleep_prepare(&cons.r);
    800001ca:	854a                	mv	a0,s2
    800001cc:	64b010ef          	jal	80002016 <sleep_prepare>
      release(&cons.lock);
    800001d0:	8526                	mv	a0,s1
    800001d2:	2cf000ef          	jal	80000ca0 <release>
      sleep();
    800001d6:	67d010ef          	jal	80002052 <sleep>
      acquire(&cons.lock);
    800001da:	8526                	mv	a0,s1
    800001dc:	23d000ef          	jal	80000c18 <acquire>
    while (cons.r == cons.w) {
    800001e0:	0984a783          	lw	a5,152(s1)
    800001e4:	09c4a703          	lw	a4,156(s1)
    800001e8:	fcf70ce3          	beq	a4,a5,800001c0 <consoleread+0x48>
    800001ec:	f456                	sd	s5,40(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	00012717          	auipc	a4,0x12
    800001f2:	28270713          	addi	a4,a4,642 # 80012470 <cons>
    800001f6:	0017869b          	addiw	a3,a5,1
    800001fa:	08d72c23          	sw	a3,152(a4)
    800001fe:	07f7f693          	andi	a3,a5,127
    80000202:	9736                	add	a4,a4,a3
    80000204:	01874703          	lbu	a4,24(a4)
    80000208:	00070a9b          	sext.w	s5,a4

    if (c == C('D')) { // end-of-file
    8000020c:	4691                	li	a3,4
    8000020e:	04da8663          	beq	s5,a3,8000025a <consoleread+0xe2>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000212:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000216:	4685                	li	a3,1
    80000218:	faf40613          	addi	a2,s0,-81
    8000021c:	85d2                	mv	a1,s4
    8000021e:	855a                	mv	a0,s6
    80000220:	182020ef          	jal	800023a2 <either_copyout>
    80000224:	57fd                	li	a5,-1
    80000226:	04f50663          	beq	a0,a5,80000272 <consoleread+0xfa>
      break;

    dst++;
    8000022a:	0a05                	addi	s4,s4,1
    --n;
    8000022c:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    8000022e:	47a9                	li	a5,10
    80000230:	04fa8b63          	beq	s5,a5,80000286 <consoleread+0x10e>
    80000234:	7aa2                	ld	s5,40(sp)
    80000236:	bfad                	j	800001b0 <consoleread+0x38>
        release(&cons.lock);
    80000238:	00012517          	auipc	a0,0x12
    8000023c:	23850513          	addi	a0,a0,568 # 80012470 <cons>
    80000240:	261000ef          	jal	80000ca0 <release>
        return -1;
    80000244:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000246:	60e6                	ld	ra,88(sp)
    80000248:	6446                	ld	s0,80(sp)
    8000024a:	64a6                	ld	s1,72(sp)
    8000024c:	6906                	ld	s2,64(sp)
    8000024e:	79e2                	ld	s3,56(sp)
    80000250:	7a42                	ld	s4,48(sp)
    80000252:	7b02                	ld	s6,32(sp)
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	6125                	addi	sp,sp,96
    80000258:	8082                	ret
      if (n < target) {
    8000025a:	0179fa63          	bgeu	s3,s7,8000026e <consoleread+0xf6>
        cons.r--;
    8000025e:	00012717          	auipc	a4,0x12
    80000262:	2af72523          	sw	a5,682(a4) # 80012508 <cons+0x98>
    80000266:	7aa2                	ld	s5,40(sp)
    80000268:	a031                	j	80000274 <consoleread+0xfc>
    8000026a:	f456                	sd	s5,40(sp)
    8000026c:	b749                	j	800001ee <consoleread+0x76>
    8000026e:	7aa2                	ld	s5,40(sp)
    80000270:	a011                	j	80000274 <consoleread+0xfc>
    80000272:	7aa2                	ld	s5,40(sp)
  release(&cons.lock);
    80000274:	00012517          	auipc	a0,0x12
    80000278:	1fc50513          	addi	a0,a0,508 # 80012470 <cons>
    8000027c:	225000ef          	jal	80000ca0 <release>
  return target - n;
    80000280:	413b853b          	subw	a0,s7,s3
    80000284:	b7c9                	j	80000246 <consoleread+0xce>
    80000286:	7aa2                	ld	s5,40(sp)
    80000288:	b7f5                	j	80000274 <consoleread+0xfc>

000000008000028a <consputc>:
{
    8000028a:	1141                	addi	sp,sp,-16
    8000028c:	e406                	sd	ra,8(sp)
    8000028e:	e022                	sd	s0,0(sp)
    80000290:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000292:	10000793          	li	a5,256
    80000296:	00f50863          	beq	a0,a5,800002a6 <consputc+0x1c>
    uartputc_sync(c);
    8000029a:	6d6000ef          	jal	80000970 <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	6c8000ef          	jal	80000970 <uartputc_sync>
    uartputc_sync(' ');
    800002ac:	02000513          	li	a0,32
    800002b0:	6c0000ef          	jal	80000970 <uartputc_sync>
    uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	6ba000ef          	jal	80000970 <uartputc_sync>
    800002ba:	b7d5                	j	8000029e <consputc+0x14>

00000000800002bc <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002bc:	1101                	addi	sp,sp,-32
    800002be:	ec06                	sd	ra,24(sp)
    800002c0:	e822                	sd	s0,16(sp)
    800002c2:	e426                	sd	s1,8(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00012517          	auipc	a0,0x12
    800002cc:	1a850513          	addi	a0,a0,424 # 80012470 <cons>
    800002d0:	149000ef          	jal	80000c18 <acquire>

  switch (c) {
    800002d4:	47d5                	li	a5,21
    800002d6:	08f48d63          	beq	s1,a5,80000370 <consoleintr+0xb4>
    800002da:	0297c563          	blt	a5,s1,80000304 <consoleintr+0x48>
    800002de:	47a1                	li	a5,8
    800002e0:	0ef48263          	beq	s1,a5,800003c4 <consoleintr+0x108>
    800002e4:	47c1                	li	a5,16
    800002e6:	10f49363          	bne	s1,a5,800003ec <consoleintr+0x130>
  case C('P'): // Print process list.
    procdump();
    800002ea:	150020ef          	jal	8000243a <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ee:	00012517          	auipc	a0,0x12
    800002f2:	18250513          	addi	a0,a0,386 # 80012470 <cons>
    800002f6:	1ab000ef          	jal	80000ca0 <release>
}
    800002fa:	60e2                	ld	ra,24(sp)
    800002fc:	6442                	ld	s0,16(sp)
    800002fe:	64a2                	ld	s1,8(sp)
    80000300:	6105                	addi	sp,sp,32
    80000302:	8082                	ret
  switch (c) {
    80000304:	07f00793          	li	a5,127
    80000308:	0af48e63          	beq	s1,a5,800003c4 <consoleintr+0x108>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030c:	00012717          	auipc	a4,0x12
    80000310:	16470713          	addi	a4,a4,356 # 80012470 <cons>
    80000314:	0a072783          	lw	a5,160(a4)
    80000318:	09872703          	lw	a4,152(a4)
    8000031c:	9f99                	subw	a5,a5,a4
    8000031e:	07f00713          	li	a4,127
    80000322:	fcf766e3          	bltu	a4,a5,800002ee <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000326:	47b5                	li	a5,13
    80000328:	0cf48563          	beq	s1,a5,800003f2 <consoleintr+0x136>
      consputc(c);
    8000032c:	8526                	mv	a0,s1
    8000032e:	f5dff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000332:	00012717          	auipc	a4,0x12
    80000336:	13e70713          	addi	a4,a4,318 # 80012470 <cons>
    8000033a:	0a072683          	lw	a3,160(a4)
    8000033e:	0016879b          	addiw	a5,a3,1
    80000342:	863e                	mv	a2,a5
    80000344:	0af72023          	sw	a5,160(a4)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	9736                	add	a4,a4,a3
    8000034e:	00970c23          	sb	s1,24(a4)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	ff648713          	addi	a4,s1,-10
    80000356:	c371                	beqz	a4,8000041a <consoleintr+0x15e>
    80000358:	14f1                	addi	s1,s1,-4
    8000035a:	c0e1                	beqz	s1,8000041a <consoleintr+0x15e>
    8000035c:	00012717          	auipc	a4,0x12
    80000360:	1ac72703          	lw	a4,428(a4) # 80012508 <cons+0x98>
    80000364:	9f99                	subw	a5,a5,a4
    80000366:	08000713          	li	a4,128
    8000036a:	f8e792e3          	bne	a5,a4,800002ee <consoleintr+0x32>
    8000036e:	a075                	j	8000041a <consoleintr+0x15e>
    80000370:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000372:	00012717          	auipc	a4,0x12
    80000376:	0fe70713          	addi	a4,a4,254 # 80012470 <cons>
    8000037a:	0a072783          	lw	a5,160(a4)
    8000037e:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000382:	00012497          	auipc	s1,0x12
    80000386:	0ee48493          	addi	s1,s1,238 # 80012470 <cons>
    while (cons.e != cons.w &&
    8000038a:	4929                	li	s2,10
    8000038c:	02f70863          	beq	a4,a5,800003bc <consoleintr+0x100>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000390:	37fd                	addiw	a5,a5,-1
    80000392:	07f7f713          	andi	a4,a5,127
    80000396:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    80000398:	01874703          	lbu	a4,24(a4)
    8000039c:	03270263          	beq	a4,s2,800003c0 <consoleintr+0x104>
      cons.e--;
    800003a0:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a4:	10000513          	li	a0,256
    800003a8:	ee3ff0ef          	jal	8000028a <consputc>
    while (cons.e != cons.w &&
    800003ac:	0a04a783          	lw	a5,160(s1)
    800003b0:	09c4a703          	lw	a4,156(s1)
    800003b4:	fcf71ee3          	bne	a4,a5,80000390 <consoleintr+0xd4>
    800003b8:	6902                	ld	s2,0(sp)
    800003ba:	bf15                	j	800002ee <consoleintr+0x32>
    800003bc:	6902                	ld	s2,0(sp)
    800003be:	bf05                	j	800002ee <consoleintr+0x32>
    800003c0:	6902                	ld	s2,0(sp)
    800003c2:	b735                	j	800002ee <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c4:	00012717          	auipc	a4,0x12
    800003c8:	0ac70713          	addi	a4,a4,172 # 80012470 <cons>
    800003cc:	0a072783          	lw	a5,160(a4)
    800003d0:	09c72703          	lw	a4,156(a4)
    800003d4:	f0f70de3          	beq	a4,a5,800002ee <consoleintr+0x32>
      cons.e--;
    800003d8:	37fd                	addiw	a5,a5,-1
    800003da:	00012717          	auipc	a4,0x12
    800003de:	12f72b23          	sw	a5,310(a4) # 80012510 <cons+0xa0>
      consputc(BACKSPACE);
    800003e2:	10000513          	li	a0,256
    800003e6:	ea5ff0ef          	jal	8000028a <consputc>
    800003ea:	b711                	j	800002ee <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ec:	f00481e3          	beqz	s1,800002ee <consoleintr+0x32>
    800003f0:	bf31                	j	8000030c <consoleintr+0x50>
      consputc(c);
    800003f2:	4529                	li	a0,10
    800003f4:	e97ff0ef          	jal	8000028a <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003f8:	00012797          	auipc	a5,0x12
    800003fc:	07878793          	addi	a5,a5,120 # 80012470 <cons>
    80000400:	0a07a703          	lw	a4,160(a5)
    80000404:	0017069b          	addiw	a3,a4,1
    80000408:	8636                	mv	a2,a3
    8000040a:	0ad7a023          	sw	a3,160(a5)
    8000040e:	07f77713          	andi	a4,a4,127
    80000412:	97ba                	add	a5,a5,a4
    80000414:	4729                	li	a4,10
    80000416:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041a:	00012797          	auipc	a5,0x12
    8000041e:	0ec7a923          	sw	a2,242(a5) # 8001250c <cons+0x9c>
        wakeup(&cons.r);
    80000422:	00012517          	auipc	a0,0x12
    80000426:	0e650513          	addi	a0,a0,230 # 80012508 <cons+0x98>
    8000042a:	459010ef          	jal	80002082 <wakeup>
    8000042e:	b5c1                	j	800002ee <consoleintr+0x32>

0000000080000430 <consoleinit>:

void
consoleinit(void)
{
    80000430:	1141                	addi	sp,sp,-16
    80000432:	e406                	sd	ra,8(sp)
    80000434:	e022                	sd	s0,0(sp)
    80000436:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000438:	00007597          	auipc	a1,0x7
    8000043c:	bc858593          	addi	a1,a1,-1080 # 80007000 <etext>
    80000440:	00012517          	auipc	a0,0x12
    80000444:	03050513          	addi	a0,a0,48 # 80012470 <cons>
    80000448:	750000ef          	jal	80000b98 <initlock>

  uartinit();
    8000044c:	448000ef          	jal	80000894 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000450:	00022797          	auipc	a5,0x22
    80000454:	3a878793          	addi	a5,a5,936 # 800227f8 <devsw>
    80000458:	00000717          	auipc	a4,0x0
    8000045c:	d2070713          	addi	a4,a4,-736 # 80000178 <consoleread>
    80000460:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000462:	00000717          	auipc	a4,0x0
    80000466:	c7470713          	addi	a4,a4,-908 # 800000d6 <consolewrite>
    8000046a:	ef98                	sd	a4,24(a5)
}
    8000046c:	60a2                	ld	ra,8(sp)
    8000046e:	6402                	ld	s0,0(sp)
    80000470:	0141                	addi	sp,sp,16
    80000472:	8082                	ret

0000000080000474 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000474:	7139                	addi	sp,sp,-64
    80000476:	fc06                	sd	ra,56(sp)
    80000478:	f822                	sd	s0,48(sp)
    8000047a:	f04a                	sd	s2,32(sp)
    8000047c:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    8000047e:	c219                	beqz	a2,80000484 <printint+0x10>
    80000480:	08054163          	bltz	a0,80000502 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    80000484:	4301                	li	t1,0

  i = 0;
    80000486:	fc840913          	addi	s2,s0,-56
    x = xx;
    8000048a:	86ca                	mv	a3,s2
  i = 0;
    8000048c:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00007817          	auipc	a6,0x7
    80000492:	2a280813          	addi	a6,a6,674 # 80007730 <digits>
    80000496:	88ba                	mv	a7,a4
    80000498:	0017061b          	addiw	a2,a4,1
    8000049c:	8732                	mv	a4,a2
    8000049e:	02b577b3          	remu	a5,a0,a1
    800004a2:	97c2                	add	a5,a5,a6
    800004a4:	0007c783          	lbu	a5,0(a5)
    800004a8:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
    800004ac:	87aa                	mv	a5,a0
    800004ae:	02b55533          	divu	a0,a0,a1
    800004b2:	0685                	addi	a3,a3,1
    800004b4:	feb7f1e3          	bgeu	a5,a1,80000496 <printint+0x22>

  if (sign)
    800004b8:	00030c63          	beqz	t1,800004d0 <printint+0x5c>
    buf[i++] = '-';
    800004bc:	fe060793          	addi	a5,a2,-32
    800004c0:	00878633          	add	a2,a5,s0
    800004c4:	02d00793          	li	a5,45
    800004c8:	fef60423          	sb	a5,-24(a2)
    800004cc:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
    800004d0:	02e05463          	blez	a4,800004f8 <printint+0x84>
    800004d4:	f426                	sd	s1,40(sp)
    800004d6:	377d                	addiw	a4,a4,-1
    800004d8:	00e904b3          	add	s1,s2,a4
    800004dc:	197d                	addi	s2,s2,-1
    800004de:	993a                	add	s2,s2,a4
    800004e0:	1702                	slli	a4,a4,0x20
    800004e2:	9301                	srli	a4,a4,0x20
    800004e4:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    800004e8:	0004c503          	lbu	a0,0(s1)
    800004ec:	d9fff0ef          	jal	8000028a <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x74>
    800004f6:	74a2                	ld	s1,40(sp)
}
    800004f8:	70e2                	ld	ra,56(sp)
    800004fa:	7442                	ld	s0,48(sp)
    800004fc:	7902                	ld	s2,32(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4305                	li	t1,1
    x = -xx;
    80000508:	bfbd                	j	80000486 <printint+0x12>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	f0ca                	sd	s2,96(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	892a                	mv	s2,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	0000a797          	auipc	a5,0xa
    8000052c:	f1c7a783          	lw	a5,-228(a5) # 8000a444 <panicking>
    80000530:	cf9d                	beqz	a5,8000056e <printk+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	00094503          	lbu	a0,0(s2)
    8000053e:	22050663          	beqz	a0,8000076a <printk+0x260>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	ecce                	sd	s3,88(sp)
    80000546:	e8d2                	sd	s4,80(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	fc5e                	sd	s7,56(sp)
    8000054e:	f862                	sd	s8,48(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4a01                	li	s4,0
    if (cx != '%') {
    80000556:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    8000055a:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    8000055e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    80000562:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000566:	4b29                	li	s6,10
    if (c0 == 'd') {
    80000568:	06400b93          	li	s7,100
    8000056c:	a015                	j	80000590 <printk+0x86>
    acquire(&pr.lock);
    8000056e:	00012517          	auipc	a0,0x12
    80000572:	faa50513          	addi	a0,a0,-86 # 80012518 <pr>
    80000576:	6a2000ef          	jal	80000c18 <acquire>
    8000057a:	bf65                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057c:	d0fff0ef          	jal	8000028a <consputc>
      continue;
    80000580:	84d2                	mv	s1,s4
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000582:	2485                	addiw	s1,s1,1
    80000584:	8a26                	mv	s4,s1
    80000586:	94ca                	add	s1,s1,s2
    80000588:	0004c503          	lbu	a0,0(s1)
    8000058c:	1c050663          	beqz	a0,80000758 <printk+0x24e>
    if (cx != '%') {
    80000590:	ff3516e3          	bne	a0,s3,8000057c <printk+0x72>
    i++;
    80000594:	001a079b          	addiw	a5,s4,1
    80000598:	84be                	mv	s1,a5
    c0 = fmt[i + 0] & 0xff;
    8000059a:	00f90733          	add	a4,s2,a5
    8000059e:	00074a83          	lbu	s5,0(a4)
    if (c0)
    800005a2:	200a8963          	beqz	s5,800007b4 <printk+0x2aa>
      c1 = fmt[i + 1] & 0xff;
    800005a6:	00174683          	lbu	a3,1(a4)
    if (c1)
    800005aa:	1e068c63          	beqz	a3,800007a2 <printk+0x298>
    if (c0 == 'd') {
    800005ae:	037a8863          	beq	s5,s7,800005de <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800005b2:	f94a8713          	addi	a4,s5,-108
    800005b6:	00173713          	seqz	a4,a4
    800005ba:	f9c68613          	addi	a2,a3,-100
    800005be:	ee05                	bnez	a2,800005f6 <printk+0xec>
    800005c0:	cb1d                	beqz	a4,800005f6 <printk+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005c2:	f8843783          	ld	a5,-120(s0)
    800005c6:	00878713          	addi	a4,a5,8
    800005ca:	f8e43423          	sd	a4,-120(s0)
    800005ce:	4605                	li	a2,1
    800005d0:	85da                	mv	a1,s6
    800005d2:	6388                	ld	a0,0(a5)
    800005d4:	ea1ff0ef          	jal	80000474 <printint>
      i += 1;
    800005d8:	002a049b          	addiw	s1,s4,2
    800005dc:	b75d                	j	80000582 <printk+0x78>
      printint(va_arg(ap, int), 10, 1);
    800005de:	f8843783          	ld	a5,-120(s0)
    800005e2:	00878713          	addi	a4,a5,8
    800005e6:	f8e43423          	sd	a4,-120(s0)
    800005ea:	4605                	li	a2,1
    800005ec:	85da                	mv	a1,s6
    800005ee:	4388                	lw	a0,0(a5)
    800005f0:	e85ff0ef          	jal	80000474 <printint>
    800005f4:	b779                	j	80000582 <printk+0x78>
      c2 = fmt[i + 2] & 0xff;
    800005f6:	97ca                	add	a5,a5,s2
    800005f8:	8636                	mv	a2,a3
    800005fa:	0027c683          	lbu	a3,2(a5)
    800005fe:	a2c9                	j	800007c0 <printk+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    80000600:	f8843783          	ld	a5,-120(s0)
    80000604:	00878713          	addi	a4,a5,8
    80000608:	f8e43423          	sd	a4,-120(s0)
    8000060c:	4605                	li	a2,1
    8000060e:	45a9                	li	a1,10
    80000610:	6388                	ld	a0,0(a5)
    80000612:	e63ff0ef          	jal	80000474 <printint>
      i += 2;
    80000616:	003a049b          	addiw	s1,s4,3
    8000061a:	b7a5                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000061c:	f8843783          	ld	a5,-120(s0)
    80000620:	00878713          	addi	a4,a5,8
    80000624:	f8e43423          	sd	a4,-120(s0)
    80000628:	4601                	li	a2,0
    8000062a:	85da                	mv	a1,s6
    8000062c:	0007e503          	lwu	a0,0(a5)
    80000630:	e45ff0ef          	jal	80000474 <printint>
    80000634:	b7b9                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000636:	f8843783          	ld	a5,-120(s0)
    8000063a:	00878713          	addi	a4,a5,8
    8000063e:	f8e43423          	sd	a4,-120(s0)
    80000642:	4601                	li	a2,0
    80000644:	85da                	mv	a1,s6
    80000646:	6388                	ld	a0,0(a5)
    80000648:	e2dff0ef          	jal	80000474 <printint>
      i += 1;
    8000064c:	002a049b          	addiw	s1,s4,2
    80000650:	bf0d                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4601                	li	a2,0
    80000660:	45a9                	li	a1,10
    80000662:	6388                	ld	a0,0(a5)
    80000664:	e11ff0ef          	jal	80000474 <printint>
      i += 2;
    80000668:	003a049b          	addiw	s1,s4,3
    8000066c:	bf19                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4601                	li	a2,0
    8000067c:	45c1                	li	a1,16
    8000067e:	0007e503          	lwu	a0,0(a5)
    80000682:	df3ff0ef          	jal	80000474 <printint>
    80000686:	bdf5                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    80000688:	f8843783          	ld	a5,-120(s0)
    8000068c:	00878713          	addi	a4,a5,8
    80000690:	f8e43423          	sd	a4,-120(s0)
    80000694:	45c1                	li	a1,16
    80000696:	6388                	ld	a0,0(a5)
    80000698:	dddff0ef          	jal	80000474 <printint>
      i += 1;
    8000069c:	002a049b          	addiw	s1,s4,2
    800006a0:	b5cd                	j	80000582 <printk+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	4601                	li	a2,0
    800006b0:	45c1                	li	a1,16
    800006b2:	6388                	ld	a0,0(a5)
    800006b4:	dc1ff0ef          	jal	80000474 <printint>
      i += 2;
    800006b8:	003a049b          	addiw	s1,s4,3
    800006bc:	b5d9                	j	80000582 <printk+0x78>
    800006be:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006c0:	f8843783          	ld	a5,-120(s0)
    800006c4:	00878713          	addi	a4,a5,8
    800006c8:	f8e43423          	sd	a4,-120(s0)
    800006cc:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006d0:	03000513          	li	a0,48
    800006d4:	bb7ff0ef          	jal	8000028a <consputc>
  consputc('x');
    800006d8:	07800513          	li	a0,120
    800006dc:	bafff0ef          	jal	8000028a <consputc>
    800006e0:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006e2:	00007c97          	auipc	s9,0x7
    800006e6:	04ec8c93          	addi	s9,s9,78 # 80007730 <digits>
    800006ea:	03cad793          	srli	a5,s5,0x3c
    800006ee:	97e6                	add	a5,a5,s9
    800006f0:	0007c503          	lbu	a0,0(a5)
    800006f4:	b97ff0ef          	jal	8000028a <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006f8:	0a92                	slli	s5,s5,0x4
    800006fa:	3a7d                	addiw	s4,s4,-1
    800006fc:	fe0a17e3          	bnez	s4,800006ea <printk+0x1e0>
    80000700:	7ca2                	ld	s9,40(sp)
    80000702:	b541                	j	80000582 <printk+0x78>
    } else if (c0 == 'c') {
      consputc(va_arg(ap, uint));
    80000704:	f8843783          	ld	a5,-120(s0)
    80000708:	00878713          	addi	a4,a5,8
    8000070c:	f8e43423          	sd	a4,-120(s0)
    80000710:	4388                	lw	a0,0(a5)
    80000712:	b79ff0ef          	jal	8000028a <consputc>
    80000716:	b5b5                	j	80000582 <printk+0x78>
    } else if (c0 == 's') {
      if ((s = va_arg(ap, char *)) == 0)
    80000718:	f8843783          	ld	a5,-120(s0)
    8000071c:	00878713          	addi	a4,a5,8
    80000720:	f8e43423          	sd	a4,-120(s0)
    80000724:	0007ba03          	ld	s4,0(a5)
    80000728:	000a0d63          	beqz	s4,80000742 <printk+0x238>
        s = "(null)";
      for (; *s; s++)
    8000072c:	000a4503          	lbu	a0,0(s4)
    80000730:	e40509e3          	beqz	a0,80000582 <printk+0x78>
        consputc(*s);
    80000734:	b57ff0ef          	jal	8000028a <consputc>
      for (; *s; s++)
    80000738:	0a05                	addi	s4,s4,1
    8000073a:	000a4503          	lbu	a0,0(s4)
    8000073e:	f97d                	bnez	a0,80000734 <printk+0x22a>
    80000740:	b589                	j	80000582 <printk+0x78>
        s = "(null)";
    80000742:	00007a17          	auipc	s4,0x7
    80000746:	8c6a0a13          	addi	s4,s4,-1850 # 80007008 <etext+0x8>
      for (; *s; s++)
    8000074a:	02800513          	li	a0,40
    8000074e:	b7dd                	j	80000734 <printk+0x22a>
    } else if (c0 == '%') {
      consputc('%');
    80000750:	8556                	mv	a0,s5
    80000752:	b39ff0ef          	jal	8000028a <consputc>
    80000756:	b535                	j	80000582 <printk+0x78>
    80000758:	74a6                	ld	s1,104(sp)
    8000075a:	69e6                	ld	s3,88(sp)
    8000075c:	6a46                	ld	s4,80(sp)
    8000075e:	6aa6                	ld	s5,72(sp)
    80000760:	6b06                	ld	s6,64(sp)
    80000762:	7be2                	ld	s7,56(sp)
    80000764:	7c42                	ld	s8,48(sp)
    80000766:	7d02                	ld	s10,32(sp)
    80000768:	6de2                	ld	s11,24(sp)
      consputc(c0);
    }
  }
  va_end(ap);

  if (panicking == 0)
    8000076a:	0000a797          	auipc	a5,0xa
    8000076e:	cda7a783          	lw	a5,-806(a5) # 8000a444 <panicking>
    80000772:	c38d                	beqz	a5,80000794 <printk+0x28a>
    release(&pr.lock);

  return 0;
}
    80000774:	4501                	li	a0,0
    80000776:	70e6                	ld	ra,120(sp)
    80000778:	7446                	ld	s0,112(sp)
    8000077a:	7906                	ld	s2,96(sp)
    8000077c:	6129                	addi	sp,sp,192
    8000077e:	8082                	ret
    80000780:	74a6                	ld	s1,104(sp)
    80000782:	69e6                	ld	s3,88(sp)
    80000784:	6a46                	ld	s4,80(sp)
    80000786:	6aa6                	ld	s5,72(sp)
    80000788:	6b06                	ld	s6,64(sp)
    8000078a:	7be2                	ld	s7,56(sp)
    8000078c:	7c42                	ld	s8,48(sp)
    8000078e:	7d02                	ld	s10,32(sp)
    80000790:	6de2                	ld	s11,24(sp)
    80000792:	bfe1                	j	8000076a <printk+0x260>
    release(&pr.lock);
    80000794:	00012517          	auipc	a0,0x12
    80000798:	d8450513          	addi	a0,a0,-636 # 80012518 <pr>
    8000079c:	504000ef          	jal	80000ca0 <release>
  return 0;
    800007a0:	bfd1                	j	80000774 <printk+0x26a>
    if (c0 == 'd') {
    800007a2:	e37a8ee3          	beq	s5,s7,800005de <printk+0xd4>
    } else if (c0 == 'l' && c1 == 'd') {
    800007a6:	f94a8713          	addi	a4,s5,-108
    800007aa:	00173713          	seqz	a4,a4
    800007ae:	8636                	mv	a2,a3
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007b0:	4781                	li	a5,0
    800007b2:	a00d                	j	800007d4 <printk+0x2ca>
    } else if (c0 == 'l' && c1 == 'd') {
    800007b4:	f94a8713          	addi	a4,s5,-108
    800007b8:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007bc:	8656                	mv	a2,s5
    800007be:	86d6                	mv	a3,s5
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    800007c0:	f9460793          	addi	a5,a2,-108
    800007c4:	0017b793          	seqz	a5,a5
    800007c8:	8ff9                	and	a5,a5,a4
    800007ca:	f9c68593          	addi	a1,a3,-100
    800007ce:	e199                	bnez	a1,800007d4 <printk+0x2ca>
    800007d0:	e20798e3          	bnez	a5,80000600 <printk+0xf6>
    } else if (c0 == 'u') {
    800007d4:	e58a84e3          	beq	s5,s8,8000061c <printk+0x112>
    } else if (c0 == 'l' && c1 == 'u') {
    800007d8:	f8b60593          	addi	a1,a2,-117
    800007dc:	e199                	bnez	a1,800007e2 <printk+0x2d8>
    800007de:	e4071ce3          	bnez	a4,80000636 <printk+0x12c>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    800007e2:	f8b68593          	addi	a1,a3,-117
    800007e6:	e199                	bnez	a1,800007ec <printk+0x2e2>
    800007e8:	e60795e3          	bnez	a5,80000652 <printk+0x148>
    } else if (c0 == 'x') {
    800007ec:	e9aa81e3          	beq	s5,s10,8000066e <printk+0x164>
    } else if (c0 == 'l' && c1 == 'x') {
    800007f0:	f8860613          	addi	a2,a2,-120
    800007f4:	e219                	bnez	a2,800007fa <printk+0x2f0>
    800007f6:	e80719e3          	bnez	a4,80000688 <printk+0x17e>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    800007fa:	f8868693          	addi	a3,a3,-120
    800007fe:	e299                	bnez	a3,80000804 <printk+0x2fa>
    80000800:	ea0791e3          	bnez	a5,800006a2 <printk+0x198>
    } else if (c0 == 'p') {
    80000804:	ebba8de3          	beq	s5,s11,800006be <printk+0x1b4>
    } else if (c0 == 'c') {
    80000808:	06300793          	li	a5,99
    8000080c:	eefa8ce3          	beq	s5,a5,80000704 <printk+0x1fa>
    } else if (c0 == 's') {
    80000810:	07300793          	li	a5,115
    80000814:	f0fa82e3          	beq	s5,a5,80000718 <printk+0x20e>
    } else if (c0 == '%') {
    80000818:	02500793          	li	a5,37
    8000081c:	f2fa8ae3          	beq	s5,a5,80000750 <printk+0x246>
    } else if (c0 == 0) {
    80000820:	f60a80e3          	beqz	s5,80000780 <printk+0x276>
      consputc('%');
    80000824:	02500513          	li	a0,37
    80000828:	a63ff0ef          	jal	8000028a <consputc>
      consputc(c0);
    8000082c:	8556                	mv	a0,s5
    8000082e:	a5dff0ef          	jal	8000028a <consputc>
    80000832:	bb81                	j	80000582 <printk+0x78>

0000000080000834 <panic>:

void
panic(char *s)
{
    80000834:	1101                	addi	sp,sp,-32
    80000836:	ec06                	sd	ra,24(sp)
    80000838:	e822                	sd	s0,16(sp)
    8000083a:	e426                	sd	s1,8(sp)
    8000083c:	e04a                	sd	s2,0(sp)
    8000083e:	1000                	addi	s0,sp,32
    80000840:	892a                	mv	s2,a0
  panicking = 1;
    80000842:	4485                	li	s1,1
    80000844:	0000a797          	auipc	a5,0xa
    80000848:	c097a023          	sw	s1,-1024(a5) # 8000a444 <panicking>
  printk("panic: ");
    8000084c:	00006517          	auipc	a0,0x6
    80000850:	7cc50513          	addi	a0,a0,1996 # 80007018 <etext+0x18>
    80000854:	cb7ff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000858:	85ca                	mv	a1,s2
    8000085a:	00006517          	auipc	a0,0x6
    8000085e:	7c650513          	addi	a0,a0,1990 # 80007020 <etext+0x20>
    80000862:	ca9ff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000866:	0000a797          	auipc	a5,0xa
    8000086a:	bc97ad23          	sw	s1,-1062(a5) # 8000a440 <panicked>
  for (;;)
    8000086e:	a001                	j	8000086e <panic+0x3a>

0000000080000870 <printkinit>:
    ;
}

void
printkinit(void)
{
    80000870:	1141                	addi	sp,sp,-16
    80000872:	e406                	sd	ra,8(sp)
    80000874:	e022                	sd	s0,0(sp)
    80000876:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000878:	00006597          	auipc	a1,0x6
    8000087c:	7b058593          	addi	a1,a1,1968 # 80007028 <etext+0x28>
    80000880:	00012517          	auipc	a0,0x12
    80000884:	c9850513          	addi	a0,a0,-872 # 80012518 <pr>
    80000888:	310000ef          	jal	80000b98 <initlock>
}
    8000088c:	60a2                	ld	ra,8(sp)
    8000088e:	6402                	ld	s0,0(sp)
    80000890:	0141                	addi	sp,sp,16
    80000892:	8082                	ret

0000000080000894 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000894:	1141                	addi	sp,sp,-16
    80000896:	e406                	sd	ra,8(sp)
    80000898:	e022                	sd	s0,0(sp)
    8000089a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000089c:	100007b7          	lui	a5,0x10000
    800008a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800008a4:	10000737          	lui	a4,0x10000
    800008a8:	f8000693          	li	a3,-128
    800008ac:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008b0:	468d                	li	a3,3
    800008b2:	10000637          	lui	a2,0x10000
    800008b6:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008be:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008c2:	8732                	mv	a4,a2
    800008c4:	461d                	li	a2,7
    800008c6:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ca:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    800008ce:	00006597          	auipc	a1,0x6
    800008d2:	76258593          	addi	a1,a1,1890 # 80007030 <etext+0x30>
    800008d6:	00012517          	auipc	a0,0x12
    800008da:	c5a50513          	addi	a0,a0,-934 # 80012530 <tx_lock>
    800008de:	7f8030ef          	jal	800040d6 <initsleeplock>
}
    800008e2:	60a2                	ld	ra,8(sp)
    800008e4:	6402                	ld	s0,0(sp)
    800008e6:	0141                	addi	sp,sp,16
    800008e8:	8082                	ret

00000000800008ea <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008ea:	7139                	addi	sp,sp,-64
    800008ec:	fc06                	sd	ra,56(sp)
    800008ee:	f822                	sd	s0,48(sp)
    800008f0:	f04a                	sd	s2,32(sp)
    800008f2:	e456                	sd	s5,8(sp)
    800008f4:	0080                	addi	s0,sp,64
    800008f6:	8aaa                	mv	s5,a0
    800008f8:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008fa:	00012517          	auipc	a0,0x12
    800008fe:	c3650513          	addi	a0,a0,-970 # 80012530 <tx_lock>
    80000902:	00b030ef          	jal	8000410c <acquiresleep>

  int i = 0;
  while (i < n) {
    80000906:	05205963          	blez	s2,80000958 <uartwrite+0x6e>
    8000090a:	f426                	sd	s1,40(sp)
    8000090c:	ec4e                	sd	s3,24(sp)
    8000090e:	e852                	sd	s4,16(sp)
    80000910:	e05a                	sd	s6,0(sp)
  int i = 0;
    80000912:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    80000914:	0000aa17          	auipc	s4,0xa
    80000918:	b34a0a13          	addi	s4,s4,-1228 # 8000a448 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    8000091c:	100009b7          	lui	s3,0x10000
    80000920:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    80000922:	10000b37          	lui	s6,0x10000
    80000926:	a029                	j	80000930 <uartwrite+0x46>
      i += 1;
    } else {
      sleep();
    80000928:	72a010ef          	jal	80002052 <sleep>
  while (i < n) {
    8000092c:	0324d263          	bge	s1,s2,80000950 <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    80000930:	8552                	mv	a0,s4
    80000932:	6e4010ef          	jal	80002016 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    80000936:	0009c783          	lbu	a5,0(s3)
    8000093a:	0207f793          	andi	a5,a5,32
    8000093e:	d7ed                	beqz	a5,80000928 <uartwrite+0x3e>
      WriteReg(THR, buf[i]);
    80000940:	009a87b3          	add	a5,s5,s1
    80000944:	0007c783          	lbu	a5,0(a5)
    80000948:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    8000094c:	2485                	addiw	s1,s1,1
    8000094e:	bff9                	j	8000092c <uartwrite+0x42>
    80000950:	74a2                	ld	s1,40(sp)
    80000952:	69e2                	ld	s3,24(sp)
    80000954:	6a42                	ld	s4,16(sp)
    80000956:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000958:	00012517          	auipc	a0,0x12
    8000095c:	bd850513          	addi	a0,a0,-1064 # 80012530 <tx_lock>
    80000960:	001030ef          	jal	80004160 <releasesleep>
}
    80000964:	70e2                	ld	ra,56(sp)
    80000966:	7442                	ld	s0,48(sp)
    80000968:	7902                	ld	s2,32(sp)
    8000096a:	6aa2                	ld	s5,8(sp)
    8000096c:	6121                	addi	sp,sp,64
    8000096e:	8082                	ret

0000000080000970 <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000970:	1101                	addi	sp,sp,-32
    80000972:	ec06                	sd	ra,24(sp)
    80000974:	e822                	sd	s0,16(sp)
    80000976:	e426                	sd	s1,8(sp)
    80000978:	1000                	addi	s0,sp,32
    8000097a:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000097c:	0000a797          	auipc	a5,0xa
    80000980:	ac87a783          	lw	a5,-1336(a5) # 8000a444 <panicking>
    80000984:	cf95                	beqz	a5,800009c0 <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000986:	0000a797          	auipc	a5,0xa
    8000098a:	aba7a783          	lw	a5,-1350(a5) # 8000a440 <panicked>
    8000098e:	ef85                	bnez	a5,800009c6 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000990:	10000737          	lui	a4,0x10000
    80000994:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	00074783          	lbu	a5,0(a4)
    8000099a:	0207f793          	andi	a5,a5,32
    8000099e:	dfe5                	beqz	a5,80000996 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    800009a0:	0ff4f513          	zext.b	a0,s1
    800009a4:	100007b7          	lui	a5,0x10000
    800009a8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    800009ac:	0000a797          	auipc	a5,0xa
    800009b0:	a987a783          	lw	a5,-1384(a5) # 8000a444 <panicking>
    800009b4:	cb91                	beqz	a5,800009c8 <uartputc_sync+0x58>
    pop_off();
}
    800009b6:	60e2                	ld	ra,24(sp)
    800009b8:	6442                	ld	s0,16(sp)
    800009ba:	64a2                	ld	s1,8(sp)
    800009bc:	6105                	addi	sp,sp,32
    800009be:	8082                	ret
    push_off();
    800009c0:	21e000ef          	jal	80000bde <push_off>
    800009c4:	b7c9                	j	80000986 <uartputc_sync+0x16>
    for (;;)
    800009c6:	a001                	j	800009c6 <uartputc_sync+0x56>
    pop_off();
    800009c8:	290000ef          	jal	80000c58 <pop_off>
}
    800009cc:	b7ed                	j	800009b6 <uartputc_sync+0x46>

00000000800009ce <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009ce:	1101                	addi	sp,sp,-32
    800009d0:	ec06                	sd	ra,24(sp)
    800009d2:	e822                	sd	s0,16(sp)
    800009d4:	e426                	sd	s1,8(sp)
    800009d6:	e04a                	sd	s2,0(sp)
    800009d8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009da:	100007b7          	lui	a5,0x10000
    800009de:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009e2:	100007b7          	lui	a5,0x10000
    800009e6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ea:	0207f793          	andi	a5,a5,32
    800009ee:	ef99                	bnez	a5,80000a0c <uartintr+0x3e>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009f0:	100004b7          	lui	s1,0x10000
    800009f4:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009f6:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009fa:	0004c783          	lbu	a5,0(s1)
    800009fe:	8b85                	andi	a5,a5,1
    80000a00:	cf89                	beqz	a5,80000a1a <uartintr+0x4c>
    return ReadReg(RHR);
    80000a02:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    80000a06:	8b7ff0ef          	jal	800002bc <consoleintr>
  while (1) {
    80000a0a:	bfc5                	j	800009fa <uartintr+0x2c>
    wakeup(&tx_chan);
    80000a0c:	0000a517          	auipc	a0,0xa
    80000a10:	a3c50513          	addi	a0,a0,-1476 # 8000a448 <tx_chan>
    80000a14:	66e010ef          	jal	80002082 <wakeup>
    80000a18:	bfe1                	j	800009f0 <uartintr+0x22>
  }
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6902                	ld	s2,0(sp)
    80000a22:	6105                	addi	sp,sp,32
    80000a24:	8082                	ret

0000000080000a26 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a26:	1101                	addi	sp,sp,-32
    80000a28:	ec06                	sd	ra,24(sp)
    80000a2a:	e822                	sd	s0,16(sp)
    80000a2c:	e426                	sd	s1,8(sp)
    80000a2e:	e04a                	sd	s2,0(sp)
    80000a30:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a32:	00023797          	auipc	a5,0x23
    80000a36:	f5e78793          	addi	a5,a5,-162 # 80023990 <end>
    80000a3a:	00f53733          	sltu	a4,a0,a5
    80000a3e:	47c5                	li	a5,17
    80000a40:	07ee                	slli	a5,a5,0x1b
    80000a42:	17fd                	addi	a5,a5,-1
    80000a44:	00a7b7b3          	sltu	a5,a5,a0
    80000a48:	8fd9                	or	a5,a5,a4
    80000a4a:	ef95                	bnez	a5,80000a86 <kfree+0x60>
    80000a4c:	84aa                	mv	s1,a0
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	eb95                	bnez	a5,80000a86 <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a54:	6605                	lui	a2,0x1
    80000a56:	4585                	li	a1,1
    80000a58:	280000ef          	jal	80000cd8 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a5c:	00012917          	auipc	s2,0x12
    80000a60:	b0490913          	addi	s2,s2,-1276 # 80012560 <kmem>
    80000a64:	854a                	mv	a0,s2
    80000a66:	1b2000ef          	jal	80000c18 <acquire>
  r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	22a000ef          	jal	80000ca0 <release>
}
    80000a7a:	60e2                	ld	ra,24(sp)
    80000a7c:	6442                	ld	s0,16(sp)
    80000a7e:	64a2                	ld	s1,8(sp)
    80000a80:	6902                	ld	s2,0(sp)
    80000a82:	6105                	addi	sp,sp,32
    80000a84:	8082                	ret
    panic("kfree");
    80000a86:	00006517          	auipc	a0,0x6
    80000a8a:	5b250513          	addi	a0,a0,1458 # 80007038 <etext+0x38>
    80000a8e:	da7ff0ef          	jal	80000834 <panic>

0000000080000a92 <freerange>:
{
    80000a92:	7179                	addi	sp,sp,-48
    80000a94:	f406                	sd	ra,40(sp)
    80000a96:	f022                	sd	s0,32(sp)
    80000a98:	ec26                	sd	s1,24(sp)
    80000a9a:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a9c:	6785                	lui	a5,0x1
    80000a9e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000aa2:	00e504b3          	add	s1,a0,a4
    80000aa6:	777d                	lui	a4,0xfffff
    80000aa8:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aaa:	94be                	add	s1,s1,a5
    80000aac:	0295e263          	bltu	a1,s1,80000ad0 <freerange+0x3e>
    80000ab0:	e84a                	sd	s2,16(sp)
    80000ab2:	e44e                	sd	s3,8(sp)
    80000ab4:	e052                	sd	s4,0(sp)
    80000ab6:	892e                	mv	s2,a1
    kfree(p);
    80000ab8:	8a3a                	mv	s4,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aba:	89be                	mv	s3,a5
    kfree(p);
    80000abc:	01448533          	add	a0,s1,s4
    80000ac0:	f67ff0ef          	jal	80000a26 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ac4:	94ce                	add	s1,s1,s3
    80000ac6:	fe997be3          	bgeu	s2,s1,80000abc <freerange+0x2a>
    80000aca:	6942                	ld	s2,16(sp)
    80000acc:	69a2                	ld	s3,8(sp)
    80000ace:	6a02                	ld	s4,0(sp)
}
    80000ad0:	70a2                	ld	ra,40(sp)
    80000ad2:	7402                	ld	s0,32(sp)
    80000ad4:	64e2                	ld	s1,24(sp)
    80000ad6:	6145                	addi	sp,sp,48
    80000ad8:	8082                	ret

0000000080000ada <kinit>:
{
    80000ada:	1141                	addi	sp,sp,-16
    80000adc:	e406                	sd	ra,8(sp)
    80000ade:	e022                	sd	s0,0(sp)
    80000ae0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ae2:	00006597          	auipc	a1,0x6
    80000ae6:	55e58593          	addi	a1,a1,1374 # 80007040 <etext+0x40>
    80000aea:	00012517          	auipc	a0,0x12
    80000aee:	a7650513          	addi	a0,a0,-1418 # 80012560 <kmem>
    80000af2:	0a6000ef          	jal	80000b98 <initlock>
  freerange(end, (void *)PHYSTOP);
    80000af6:	45c5                	li	a1,17
    80000af8:	05ee                	slli	a1,a1,0x1b
    80000afa:	00023517          	auipc	a0,0x23
    80000afe:	e9650513          	addi	a0,a0,-362 # 80023990 <end>
    80000b02:	f91ff0ef          	jal	80000a92 <freerange>
}
    80000b06:	60a2                	ld	ra,8(sp)
    80000b08:	6402                	ld	s0,0(sp)
    80000b0a:	0141                	addi	sp,sp,16
    80000b0c:	8082                	ret

0000000080000b0e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b18:	00012517          	auipc	a0,0x12
    80000b1c:	a4850513          	addi	a0,a0,-1464 # 80012560 <kmem>
    80000b20:	0f8000ef          	jal	80000c18 <acquire>
  r = kmem.freelist;
    80000b24:	00012497          	auipc	s1,0x12
    80000b28:	a544b483          	ld	s1,-1452(s1) # 80012578 <kmem+0x18>
  if (r)
    80000b2c:	c49d                	beqz	s1,80000b5a <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b2e:	609c                	ld	a5,0(s1)
    80000b30:	00012717          	auipc	a4,0x12
    80000b34:	a4f73423          	sd	a5,-1464(a4) # 80012578 <kmem+0x18>
  release(&kmem.lock);
    80000b38:	00012517          	auipc	a0,0x12
    80000b3c:	a2850513          	addi	a0,a0,-1496 # 80012560 <kmem>
    80000b40:	160000ef          	jal	80000ca0 <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000b44:	6605                	lui	a2,0x1
    80000b46:	4595                	li	a1,5
    80000b48:	8526                	mv	a0,s1
    80000b4a:	18e000ef          	jal	80000cd8 <memset>
  return (void *)r;
}
    80000b4e:	8526                	mv	a0,s1
    80000b50:	60e2                	ld	ra,24(sp)
    80000b52:	6442                	ld	s0,16(sp)
    80000b54:	64a2                	ld	s1,8(sp)
    80000b56:	6105                	addi	sp,sp,32
    80000b58:	8082                	ret
  release(&kmem.lock);
    80000b5a:	00012517          	auipc	a0,0x12
    80000b5e:	a0650513          	addi	a0,a0,-1530 # 80012560 <kmem>
    80000b62:	13e000ef          	jal	80000ca0 <release>
  if (r)
    80000b66:	b7e5                	j	80000b4e <kalloc+0x40>

0000000080000b68 <random>:
static unsigned long seed = 666;

unsigned long
random(void)
{
    80000b68:	1141                	addi	sp,sp,-16
    80000b6a:	e406                	sd	ra,8(sp)
    80000b6c:	e022                	sd	s0,0(sp)
    80000b6e:	0800                	addi	s0,sp,16
  seed = seed * 1103515245 + 12345;
    80000b70:	0000a717          	auipc	a4,0xa
    80000b74:	8a070713          	addi	a4,a4,-1888 # 8000a410 <seed>
    80000b78:	6308                	ld	a0,0(a4)
    80000b7a:	41c657b7          	lui	a5,0x41c65
    80000b7e:	e6d78793          	addi	a5,a5,-403 # 41c64e6d <_entry-0x3e39b193>
    80000b82:	02f50533          	mul	a0,a0,a5
    80000b86:	678d                	lui	a5,0x3
    80000b88:	03978793          	addi	a5,a5,57 # 3039 <_entry-0x7fffcfc7>
    80000b8c:	953e                	add	a0,a0,a5
    80000b8e:	e308                	sd	a0,0(a4)
  return seed;
    80000b90:	60a2                	ld	ra,8(sp)
    80000b92:	6402                	ld	s0,0(sp)
    80000b94:	0141                	addi	sp,sp,16
    80000b96:	8082                	ret

0000000080000b98 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b98:	1141                	addi	sp,sp,-16
    80000b9a:	e406                	sd	ra,8(sp)
    80000b9c:	e022                	sd	s0,0(sp)
    80000b9e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ba0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ba2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ba6:	00053823          	sd	zero,16(a0)
}
    80000baa:	60a2                	ld	ra,8(sp)
    80000bac:	6402                	ld	s0,0(sp)
    80000bae:	0141                	addi	sp,sp,16
    80000bb0:	8082                	ret

0000000080000bb2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb2:	411c                	lw	a5,0(a0)
    80000bb4:	e399                	bnez	a5,80000bba <holding+0x8>
    80000bb6:	4501                	li	a0,0
  return r;
}
    80000bb8:	8082                	ret
{
    80000bba:	1101                	addi	sp,sp,-32
    80000bbc:	ec06                	sd	ra,24(sp)
    80000bbe:	e822                	sd	s0,16(sp)
    80000bc0:	e426                	sd	s1,8(sp)
    80000bc2:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bc4:	691c                	ld	a5,16(a0)
    80000bc6:	84be                	mv	s1,a5
    80000bc8:	551000ef          	jal	80001918 <mycpu>
    80000bcc:	40a48533          	sub	a0,s1,a0
    80000bd0:	00153513          	seqz	a0,a0
}
    80000bd4:	60e2                	ld	ra,24(sp)
    80000bd6:	6442                	ld	s0,16(sp)
    80000bd8:	64a2                	ld	s1,8(sp)
    80000bda:	6105                	addi	sp,sp,32
    80000bdc:	8082                	ret

0000000080000bde <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bde:	1101                	addi	sp,sp,-32
    80000be0:	ec06                	sd	ra,24(sp)
    80000be2:	e822                	sd	s0,16(sp)
    80000be4:	e426                	sd	s1,8(sp)
    80000be6:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000be8:	100177f3          	csrrci	a5,sstatus,2
    80000bec:	84be                	mv	s1,a5
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000bee:	52b000ef          	jal	80001918 <mycpu>
    80000bf2:	5d3c                	lw	a5,120(a0)
    80000bf4:	cb99                	beqz	a5,80000c0a <push_off+0x2c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bf6:	523000ef          	jal	80001918 <mycpu>
    80000bfa:	5d3c                	lw	a5,120(a0)
    80000bfc:	2785                	addiw	a5,a5,1
    80000bfe:	dd3c                	sw	a5,120(a0)
}
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
    mycpu()->intena = old;
    80000c0a:	50f000ef          	jal	80001918 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000c0e:	0014d793          	srli	a5,s1,0x1
    80000c12:	8b85                	andi	a5,a5,1
    mycpu()->intena = old;
    80000c14:	dd7c                	sw	a5,124(a0)
    80000c16:	b7c5                	j	80000bf6 <push_off+0x18>

0000000080000c18 <acquire>:
{
    80000c18:	1101                	addi	sp,sp,-32
    80000c1a:	ec06                	sd	ra,24(sp)
    80000c1c:	e822                	sd	s0,16(sp)
    80000c1e:	e426                	sd	s1,8(sp)
    80000c20:	1000                	addi	s0,sp,32
    80000c22:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c24:	fbbff0ef          	jal	80000bde <push_off>
  if (holding(lk))
    80000c28:	8526                	mv	a0,s1
    80000c2a:	f89ff0ef          	jal	80000bb2 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c2e:	4705                	li	a4,1
  if (holding(lk))
    80000c30:	ed11                	bnez	a0,80000c4c <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000c32:	87ba                	mv	a5,a4
    80000c34:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c38:	2781                	sext.w	a5,a5
    80000c3a:	ffe5                	bnez	a5,80000c32 <acquire+0x1a>
  lk->cpu = mycpu();
    80000c3c:	4dd000ef          	jal	80001918 <mycpu>
    80000c40:	e888                	sd	a0,16(s1)
}
    80000c42:	60e2                	ld	ra,24(sp)
    80000c44:	6442                	ld	s0,16(sp)
    80000c46:	64a2                	ld	s1,8(sp)
    80000c48:	6105                	addi	sp,sp,32
    80000c4a:	8082                	ret
    panic("acquire");
    80000c4c:	00006517          	auipc	a0,0x6
    80000c50:	3fc50513          	addi	a0,a0,1020 # 80007048 <etext+0x48>
    80000c54:	be1ff0ef          	jal	80000834 <panic>

0000000080000c58 <pop_off>:

void
pop_off(void)
{
    80000c58:	1141                	addi	sp,sp,-16
    80000c5a:	e406                	sd	ra,8(sp)
    80000c5c:	e022                	sd	s0,0(sp)
    80000c5e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c60:	4b9000ef          	jal	80001918 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000c64:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c68:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000c6a:	ef99                	bnez	a5,80000c88 <pop_off+0x30>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000c6c:	5d3c                	lw	a5,120(a0)
    80000c6e:	02f05363          	blez	a5,80000c94 <pop_off+0x3c>
    panic("pop_off");
  c->noff -= 1;
    80000c72:	37fd                	addiw	a5,a5,-1
    80000c74:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000c76:	e789                	bnez	a5,80000c80 <pop_off+0x28>
    80000c78:	5d7c                	lw	a5,124(a0)
    80000c7a:	c399                	beqz	a5,80000c80 <pop_off+0x28>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000c7c:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000c80:	60a2                	ld	ra,8(sp)
    80000c82:	6402                	ld	s0,0(sp)
    80000c84:	0141                	addi	sp,sp,16
    80000c86:	8082                	ret
    panic("pop_off - interruptible");
    80000c88:	00006517          	auipc	a0,0x6
    80000c8c:	3c850513          	addi	a0,a0,968 # 80007050 <etext+0x50>
    80000c90:	ba5ff0ef          	jal	80000834 <panic>
    panic("pop_off");
    80000c94:	00006517          	auipc	a0,0x6
    80000c98:	3d450513          	addi	a0,a0,980 # 80007068 <etext+0x68>
    80000c9c:	b99ff0ef          	jal	80000834 <panic>

0000000080000ca0 <release>:
{
    80000ca0:	1101                	addi	sp,sp,-32
    80000ca2:	ec06                	sd	ra,24(sp)
    80000ca4:	e822                	sd	s0,16(sp)
    80000ca6:	e426                	sd	s1,8(sp)
    80000ca8:	1000                	addi	s0,sp,32
    80000caa:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000cac:	f07ff0ef          	jal	80000bb2 <holding>
    80000cb0:	cd11                	beqz	a0,80000ccc <release+0x2c>
  lk->cpu = 0;
    80000cb2:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000cb6:	0310000f          	fence	rw,w
    80000cba:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cbe:	f9bff0ef          	jal	80000c58 <pop_off>
}
    80000cc2:	60e2                	ld	ra,24(sp)
    80000cc4:	6442                	ld	s0,16(sp)
    80000cc6:	64a2                	ld	s1,8(sp)
    80000cc8:	6105                	addi	sp,sp,32
    80000cca:	8082                	ret
    panic("release");
    80000ccc:	00006517          	auipc	a0,0x6
    80000cd0:	3a450513          	addi	a0,a0,932 # 80007070 <etext+0x70>
    80000cd4:	b61ff0ef          	jal	80000834 <panic>

0000000080000cd8 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000cd8:	1141                	addi	sp,sp,-16
    80000cda:	e406                	sd	ra,8(sp)
    80000cdc:	e022                	sd	s0,0(sp)
    80000cde:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000ce0:	ca19                	beqz	a2,80000cf6 <memset+0x1e>
    80000ce2:	87aa                	mv	a5,a0
    80000ce4:	1602                	slli	a2,a2,0x20
    80000ce6:	9201                	srli	a2,a2,0x20
    80000ce8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cec:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000cf0:	0785                	addi	a5,a5,1
    80000cf2:	fee79de3          	bne	a5,a4,80000cec <memset+0x14>
  }
  return dst;
}
    80000cf6:	60a2                	ld	ra,8(sp)
    80000cf8:	6402                	ld	s0,0(sp)
    80000cfa:	0141                	addi	sp,sp,16
    80000cfc:	8082                	ret

0000000080000cfe <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cfe:	1141                	addi	sp,sp,-16
    80000d00:	e406                	sd	ra,8(sp)
    80000d02:	e022                	sd	s0,0(sp)
    80000d04:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000d06:	c61d                	beqz	a2,80000d34 <memcmp+0x36>
    80000d08:	1602                	slli	a2,a2,0x20
    80000d0a:	9201                	srli	a2,a2,0x20
    80000d0c:	00c506b3          	add	a3,a0,a2
    if (*s1 != *s2)
    80000d10:	00054783          	lbu	a5,0(a0)
    80000d14:	0005c703          	lbu	a4,0(a1)
    80000d18:	00e79863          	bne	a5,a4,80000d28 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d1c:	0505                	addi	a0,a0,1
    80000d1e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000d20:	fed518e3          	bne	a0,a3,80000d10 <memcmp+0x12>
  }

  return 0;
    80000d24:	4501                	li	a0,0
    80000d26:	a019                	j	80000d2c <memcmp+0x2e>
      return *s1 - *s2;
    80000d28:	40e7853b          	subw	a0,a5,a4
}
    80000d2c:	60a2                	ld	ra,8(sp)
    80000d2e:	6402                	ld	s0,0(sp)
    80000d30:	0141                	addi	sp,sp,16
    80000d32:	8082                	ret
  return 0;
    80000d34:	4501                	li	a0,0
    80000d36:	bfdd                	j	80000d2c <memcmp+0x2e>

0000000080000d38 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000d38:	1141                	addi	sp,sp,-16
    80000d3a:	e406                	sd	ra,8(sp)
    80000d3c:	e022                	sd	s0,0(sp)
    80000d3e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000d40:	c205                	beqz	a2,80000d60 <memmove+0x28>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000d42:	02a5e363          	bltu	a1,a0,80000d68 <memmove+0x30>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000d46:	1602                	slli	a2,a2,0x20
    80000d48:	9201                	srli	a2,a2,0x20
    80000d4a:	00c587b3          	add	a5,a1,a2
{
    80000d4e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d50:	0585                	addi	a1,a1,1
    80000d52:	0705                	addi	a4,a4,1
    80000d54:	fff5c683          	lbu	a3,-1(a1)
    80000d58:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000d5c:	feb79ae3          	bne	a5,a1,80000d50 <memmove+0x18>

  return dst;
}
    80000d60:	60a2                	ld	ra,8(sp)
    80000d62:	6402                	ld	s0,0(sp)
    80000d64:	0141                	addi	sp,sp,16
    80000d66:	8082                	ret
  if (s < d && s + n > d) {
    80000d68:	02061693          	slli	a3,a2,0x20
    80000d6c:	9281                	srli	a3,a3,0x20
    80000d6e:	00d58733          	add	a4,a1,a3
    80000d72:	fce57ae3          	bgeu	a0,a4,80000d46 <memmove+0xe>
    d += n;
    80000d76:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000d78:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000d7c:	1782                	slli	a5,a5,0x20
    80000d7e:	9381                	srli	a5,a5,0x20
    80000d80:	fff7c793          	not	a5,a5
    80000d84:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d86:	177d                	addi	a4,a4,-1
    80000d88:	16fd                	addi	a3,a3,-1
    80000d8a:	00074603          	lbu	a2,0(a4)
    80000d8e:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d92:	fee79ae3          	bne	a5,a4,80000d86 <memmove+0x4e>
    80000d96:	b7e9                	j	80000d60 <memmove+0x28>

0000000080000d98 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d98:	1141                	addi	sp,sp,-16
    80000d9a:	e406                	sd	ra,8(sp)
    80000d9c:	e022                	sd	s0,0(sp)
    80000d9e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da0:	f99ff0ef          	jal	80000d38 <memmove>
}
    80000da4:	60a2                	ld	ra,8(sp)
    80000da6:	6402                	ld	s0,0(sp)
    80000da8:	0141                	addi	sp,sp,16
    80000daa:	8082                	ret

0000000080000dac <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dac:	1141                	addi	sp,sp,-16
    80000dae:	e406                	sd	ra,8(sp)
    80000db0:	e022                	sd	s0,0(sp)
    80000db2:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000db4:	ce11                	beqz	a2,80000dd0 <strncmp+0x24>
    80000db6:	00054783          	lbu	a5,0(a0)
    80000dba:	cf89                	beqz	a5,80000dd4 <strncmp+0x28>
    80000dbc:	0005c703          	lbu	a4,0(a1)
    80000dc0:	00f71a63          	bne	a4,a5,80000dd4 <strncmp+0x28>
    n--, p++, q++;
    80000dc4:	367d                	addiw	a2,a2,-1
    80000dc6:	0505                	addi	a0,a0,1
    80000dc8:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000dca:	f675                	bnez	a2,80000db6 <strncmp+0xa>
  if (n == 0)
    return 0;
    80000dcc:	4501                	li	a0,0
    80000dce:	a801                	j	80000dde <strncmp+0x32>
    80000dd0:	4501                	li	a0,0
    80000dd2:	a031                	j	80000dde <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000dd4:	00054503          	lbu	a0,0(a0)
    80000dd8:	0005c783          	lbu	a5,0(a1)
    80000ddc:	9d1d                	subw	a0,a0,a5
}
    80000dde:	60a2                	ld	ra,8(sp)
    80000de0:	6402                	ld	s0,0(sp)
    80000de2:	0141                	addi	sp,sp,16
    80000de4:	8082                	ret

0000000080000de6 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000de6:	1141                	addi	sp,sp,-16
    80000de8:	e406                	sd	ra,8(sp)
    80000dea:	e022                	sd	s0,0(sp)
    80000dec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000dee:	87aa                	mv	a5,a0
    80000df0:	a011                	j	80000df4 <strncpy+0xe>
    80000df2:	8636                	mv	a2,a3
    80000df4:	02c05863          	blez	a2,80000e24 <strncpy+0x3e>
    80000df8:	fff6069b          	addiw	a3,a2,-1
    80000dfc:	8836                	mv	a6,a3
    80000dfe:	0785                	addi	a5,a5,1
    80000e00:	0005c703          	lbu	a4,0(a1)
    80000e04:	fee78fa3          	sb	a4,-1(a5)
    80000e08:	0585                	addi	a1,a1,1
    80000e0a:	f765                	bnez	a4,80000df2 <strncpy+0xc>
    ;
  while (n-- > 0)
    80000e0c:	873e                	mv	a4,a5
    80000e0e:	01005b63          	blez	a6,80000e24 <strncpy+0x3e>
    80000e12:	9fb1                	addw	a5,a5,a2
    80000e14:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e16:	0705                	addi	a4,a4,1
    80000e18:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000e1c:	40e786bb          	subw	a3,a5,a4
    80000e20:	fed04be3          	bgtz	a3,80000e16 <strncpy+0x30>
  return os;
}
    80000e24:	60a2                	ld	ra,8(sp)
    80000e26:	6402                	ld	s0,0(sp)
    80000e28:	0141                	addi	sp,sp,16
    80000e2a:	8082                	ret

0000000080000e2c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000e2c:	1141                	addi	sp,sp,-16
    80000e2e:	e406                	sd	ra,8(sp)
    80000e30:	e022                	sd	s0,0(sp)
    80000e32:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000e34:	02c05363          	blez	a2,80000e5a <safestrcpy+0x2e>
    80000e38:	fff6069b          	addiw	a3,a2,-1
    80000e3c:	1682                	slli	a3,a3,0x20
    80000e3e:	9281                	srli	a3,a3,0x20
    80000e40:	96ae                	add	a3,a3,a1
    80000e42:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000e44:	00d58963          	beq	a1,a3,80000e56 <safestrcpy+0x2a>
    80000e48:	0585                	addi	a1,a1,1
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff5c703          	lbu	a4,-1(a1)
    80000e50:	fee78fa3          	sb	a4,-1(a5)
    80000e54:	fb65                	bnez	a4,80000e44 <safestrcpy+0x18>
    ;
  *s = 0;
    80000e56:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e5a:	60a2                	ld	ra,8(sp)
    80000e5c:	6402                	ld	s0,0(sp)
    80000e5e:	0141                	addi	sp,sp,16
    80000e60:	8082                	ret

0000000080000e62 <strlen>:

int
strlen(const char *s)
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000e6a:	00054783          	lbu	a5,0(a0)
    80000e6e:	cf91                	beqz	a5,80000e8a <strlen+0x28>
    80000e70:	00150793          	addi	a5,a0,1
    80000e74:	86be                	mv	a3,a5
    80000e76:	0785                	addi	a5,a5,1
    80000e78:	fff7c703          	lbu	a4,-1(a5)
    80000e7c:	ff65                	bnez	a4,80000e74 <strlen+0x12>
    80000e7e:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000e82:	60a2                	ld	ra,8(sp)
    80000e84:	6402                	ld	s0,0(sp)
    80000e86:	0141                	addi	sp,sp,16
    80000e88:	8082                	ret
  for (n = 0; s[n]; n++)
    80000e8a:	4501                	li	a0,0
    80000e8c:	bfdd                	j	80000e82 <strlen+0x20>

0000000080000e8e <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e406                	sd	ra,8(sp)
    80000e92:	e022                	sd	s0,0(sp)
    80000e94:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000e96:	26f000ef          	jal	80001904 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e9a:	00009717          	auipc	a4,0x9
    80000e9e:	5b270713          	addi	a4,a4,1458 # 8000a44c <started>
  if (cpuid() == 0) {
    80000ea2:	c51d                	beqz	a0,80000ed0 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000ea4:	431c                	lw	a5,0(a4)
    80000ea6:	0230000f          	fence	r,rw
    80000eaa:	2781                	sext.w	a5,a5
    80000eac:	dfe5                	beqz	a5,80000ea4 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000eae:	257000ef          	jal	80001904 <cpuid>
    80000eb2:	85aa                	mv	a1,a0
    80000eb4:	00006517          	auipc	a0,0x6
    80000eb8:	1e450513          	addi	a0,a0,484 # 80007098 <etext+0x98>
    80000ebc:	e4eff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000ec0:	082000ef          	jal	80000f42 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000ec4:	6a8010ef          	jal	8000256c <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000ec8:	0c1040ef          	jal	80005788 <plicinithart>
  }

  scheduler();
    80000ecc:	765000ef          	jal	80001e30 <scheduler>
    consoleinit();
    80000ed0:	d60ff0ef          	jal	80000430 <consoleinit>
    printkinit();
    80000ed4:	99dff0ef          	jal	80000870 <printkinit>
    printk("\n");
    80000ed8:	00006517          	auipc	a0,0x6
    80000edc:	1a050513          	addi	a0,a0,416 # 80007078 <etext+0x78>
    80000ee0:	e2aff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000ee4:	00006517          	auipc	a0,0x6
    80000ee8:	19c50513          	addi	a0,a0,412 # 80007080 <etext+0x80>
    80000eec:	e1eff0ef          	jal	8000050a <printk>
    printk("\n");
    80000ef0:	00006517          	auipc	a0,0x6
    80000ef4:	18850513          	addi	a0,a0,392 # 80007078 <etext+0x78>
    80000ef8:	e12ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000efc:	bdfff0ef          	jal	80000ada <kinit>
    kvminit();          // create kernel page table
    80000f00:	2ce000ef          	jal	800011ce <kvminit>
    kvminithart();      // turn on paging
    80000f04:	03e000ef          	jal	80000f42 <kvminithart>
    procinit();         // process table
    80000f08:	147000ef          	jal	8000184e <procinit>
    trapinit();         // trap vectors
    80000f0c:	63c010ef          	jal	80002548 <trapinit>
    trapinithart();     // install kernel trap vector
    80000f10:	65c010ef          	jal	8000256c <trapinithart>
    plicinit();         // set up interrupt controller
    80000f14:	05b040ef          	jal	8000576e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000f18:	071040ef          	jal	80005788 <plicinithart>
    binit();            // buffer cache
    80000f1c:	54d010ef          	jal	80002c68 <binit>
    iinit();            // inode table
    80000f20:	29e020ef          	jal	800031be <iinit>
    fileinit();         // file table
    80000f24:	2be030ef          	jal	800041e2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f28:	151040ef          	jal	80005878 <virtio_disk_init>
    userinit();         // first user process
    80000f2c:	4e9000ef          	jal	80001c14 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000f30:	00009797          	auipc	a5,0x9
    80000f34:	51c78793          	addi	a5,a5,1308 # 8000a44c <started>
    80000f38:	4705                	li	a4,1
    80000f3a:	0310000f          	fence	rw,w
    80000f3e:	c398                	sw	a4,0(a5)
    80000f40:	b771                	j	80000ecc <main+0x3e>

0000000080000f42 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f42:	1141                	addi	sp,sp,-16
    80000f44:	e406                	sd	ra,8(sp)
    80000f46:	e022                	sd	s0,0(sp)
    80000f48:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f4a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f4e:	00009797          	auipc	a5,0x9
    80000f52:	5027b783          	ld	a5,1282(a5) # 8000a450 <kernel_pagetable>
    80000f56:	83b1                	srli	a5,a5,0xc
    80000f58:	577d                	li	a4,-1
    80000f5a:	177e                	slli	a4,a4,0x3f
    80000f5c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000f5e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000f62:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f66:	60a2                	ld	ra,8(sp)
    80000f68:	6402                	ld	s0,0(sp)
    80000f6a:	0141                	addi	sp,sp,16
    80000f6c:	8082                	ret

0000000080000f6e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f6e:	7139                	addi	sp,sp,-64
    80000f70:	fc06                	sd	ra,56(sp)
    80000f72:	f822                	sd	s0,48(sp)
    80000f74:	f426                	sd	s1,40(sp)
    80000f76:	f04a                	sd	s2,32(sp)
    80000f78:	ec4e                	sd	s3,24(sp)
    80000f7a:	e852                	sd	s4,16(sp)
    80000f7c:	e456                	sd	s5,8(sp)
    80000f7e:	e05a                	sd	s6,0(sp)
    80000f80:	0080                	addi	s0,sp,64
    80000f82:	84aa                	mv	s1,a0
    80000f84:	89ae                	mv	s3,a1
    80000f86:	8b32                	mv	s6,a2
  if (va >= MAXVA)
    80000f88:	57fd                	li	a5,-1
    80000f8a:	83e9                	srli	a5,a5,0x1a
    80000f8c:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000f8e:	4ab1                	li	s5,12
  if (va >= MAXVA)
    80000f90:	04b7e263          	bltu	a5,a1,80000fd4 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f94:	0149d933          	srl	s2,s3,s4
    80000f98:	1ff97913          	andi	s2,s2,511
    80000f9c:	090e                	slli	s2,s2,0x3
    80000f9e:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000fa0:	00093483          	ld	s1,0(s2)
    80000fa4:	0014f793          	andi	a5,s1,1
    80000fa8:	cf85                	beqz	a5,80000fe0 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000faa:	80a9                	srli	s1,s1,0xa
    80000fac:	04b2                	slli	s1,s1,0xc
  for (int level = 2; level > 0; level--) {
    80000fae:	3a5d                	addiw	s4,s4,-9
    80000fb0:	ff5a12e3          	bne	s4,s5,80000f94 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80000fb4:	00c9d513          	srli	a0,s3,0xc
    80000fb8:	1ff57513          	andi	a0,a0,511
    80000fbc:	050e                	slli	a0,a0,0x3
    80000fbe:	9526                	add	a0,a0,s1
}
    80000fc0:	70e2                	ld	ra,56(sp)
    80000fc2:	7442                	ld	s0,48(sp)
    80000fc4:	74a2                	ld	s1,40(sp)
    80000fc6:	7902                	ld	s2,32(sp)
    80000fc8:	69e2                	ld	s3,24(sp)
    80000fca:	6a42                	ld	s4,16(sp)
    80000fcc:	6aa2                	ld	s5,8(sp)
    80000fce:	6b02                	ld	s6,0(sp)
    80000fd0:	6121                	addi	sp,sp,64
    80000fd2:	8082                	ret
    panic("walk");
    80000fd4:	00006517          	auipc	a0,0x6
    80000fd8:	0dc50513          	addi	a0,a0,220 # 800070b0 <etext+0xb0>
    80000fdc:	859ff0ef          	jal	80000834 <panic>
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000fe0:	020b0263          	beqz	s6,80001004 <walk+0x96>
    80000fe4:	b2bff0ef          	jal	80000b0e <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	d979                	beqz	a0,80000fc0 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	ce9ff0ef          	jal	80000cd8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff4:	00c4d793          	srli	a5,s1,0xc
    80000ff8:	07aa                	slli	a5,a5,0xa
    80000ffa:	0017e793          	ori	a5,a5,1
    80000ffe:	00f93023          	sd	a5,0(s2)
    80001002:	b775                	j	80000fae <walk+0x40>
        return 0;
    80001004:	4501                	li	a0,0
    80001006:	bf6d                	j	80000fc0 <walk+0x52>

0000000080001008 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80001008:	57fd                	li	a5,-1
    8000100a:	83e9                	srli	a5,a5,0x1a
    8000100c:	00b7f463          	bgeu	a5,a1,80001014 <walkaddr+0xc>
    return 0;
    80001010:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001012:	8082                	ret
{
    80001014:	1141                	addi	sp,sp,-16
    80001016:	e406                	sd	ra,8(sp)
    80001018:	e022                	sd	s0,0(sp)
    8000101a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000101c:	4601                	li	a2,0
    8000101e:	f51ff0ef          	jal	80000f6e <walk>
  if (pte == 0)
    80001022:	c901                	beqz	a0,80001032 <walkaddr+0x2a>
  if ((*pte & PTE_V) == 0)
    80001024:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80001026:	0117f693          	andi	a3,a5,17
    8000102a:	4745                	li	a4,17
    return 0;
    8000102c:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    8000102e:	00e68663          	beq	a3,a4,8000103a <walkaddr+0x32>
}
    80001032:	60a2                	ld	ra,8(sp)
    80001034:	6402                	ld	s0,0(sp)
    80001036:	0141                	addi	sp,sp,16
    80001038:	8082                	ret
  pa = PTE2PA(*pte);
    8000103a:	83a9                	srli	a5,a5,0xa
    8000103c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001040:	bfcd                	j	80001032 <walkaddr+0x2a>

0000000080001042 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001042:	715d                	addi	sp,sp,-80
    80001044:	e486                	sd	ra,72(sp)
    80001046:	e0a2                	sd	s0,64(sp)
    80001048:	fc26                	sd	s1,56(sp)
    8000104a:	f84a                	sd	s2,48(sp)
    8000104c:	f44e                	sd	s3,40(sp)
    8000104e:	f052                	sd	s4,32(sp)
    80001050:	ec56                	sd	s5,24(sp)
    80001052:	e85a                	sd	s6,16(sp)
    80001054:	e45e                	sd	s7,8(sp)
    80001056:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001058:	03459793          	slli	a5,a1,0x34
    8000105c:	eba1                	bnez	a5,800010ac <mappages+0x6a>
    8000105e:	8a2a                	mv	s4,a0
    80001060:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80001062:	03461793          	slli	a5,a2,0x34
    80001066:	eba9                	bnez	a5,800010b8 <mappages+0x76>
    panic("mappages: size not aligned");

  if (size == 0)
    80001068:	ce31                	beqz	a2,800010c4 <mappages+0x82>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    8000106a:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000106e:	80060613          	addi	a2,a2,-2048
    80001072:	00b60933          	add	s2,a2,a1
  a = va;
    80001076:	84ae                	mv	s1,a1
  for (;;) {
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001078:	4b05                	li	s6,1
    8000107a:	40b689b3          	sub	s3,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    8000107e:	6b85                	lui	s7,0x1
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001080:	865a                	mv	a2,s6
    80001082:	85a6                	mv	a1,s1
    80001084:	8552                	mv	a0,s4
    80001086:	ee9ff0ef          	jal	80000f6e <walk>
    8000108a:	c929                	beqz	a0,800010dc <mappages+0x9a>
    if (*pte & PTE_V)
    8000108c:	611c                	ld	a5,0(a0)
    8000108e:	8b85                	andi	a5,a5,1
    80001090:	e3a1                	bnez	a5,800010d0 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001092:	013487b3          	add	a5,s1,s3
    80001096:	83b1                	srli	a5,a5,0xc
    80001098:	07aa                	slli	a5,a5,0xa
    8000109a:	0157e7b3          	or	a5,a5,s5
    8000109e:	0017e793          	ori	a5,a5,1
    800010a2:	e11c                	sd	a5,0(a0)
    if (a == last)
    800010a4:	05248863          	beq	s1,s2,800010f4 <mappages+0xb2>
    a += PGSIZE;
    800010a8:	94de                	add	s1,s1,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800010aa:	bfd9                	j	80001080 <mappages+0x3e>
    panic("mappages: va not aligned");
    800010ac:	00006517          	auipc	a0,0x6
    800010b0:	00c50513          	addi	a0,a0,12 # 800070b8 <etext+0xb8>
    800010b4:	f80ff0ef          	jal	80000834 <panic>
    panic("mappages: size not aligned");
    800010b8:	00006517          	auipc	a0,0x6
    800010bc:	02050513          	addi	a0,a0,32 # 800070d8 <etext+0xd8>
    800010c0:	f74ff0ef          	jal	80000834 <panic>
    panic("mappages: size");
    800010c4:	00006517          	auipc	a0,0x6
    800010c8:	03450513          	addi	a0,a0,52 # 800070f8 <etext+0xf8>
    800010cc:	f68ff0ef          	jal	80000834 <panic>
      panic("mappages: remap");
    800010d0:	00006517          	auipc	a0,0x6
    800010d4:	03850513          	addi	a0,a0,56 # 80007108 <etext+0x108>
    800010d8:	f5cff0ef          	jal	80000834 <panic>
      return -1;
    800010dc:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010de:	60a6                	ld	ra,72(sp)
    800010e0:	6406                	ld	s0,64(sp)
    800010e2:	74e2                	ld	s1,56(sp)
    800010e4:	7942                	ld	s2,48(sp)
    800010e6:	79a2                	ld	s3,40(sp)
    800010e8:	7a02                	ld	s4,32(sp)
    800010ea:	6ae2                	ld	s5,24(sp)
    800010ec:	6b42                	ld	s6,16(sp)
    800010ee:	6ba2                	ld	s7,8(sp)
    800010f0:	6161                	addi	sp,sp,80
    800010f2:	8082                	ret
  return 0;
    800010f4:	4501                	li	a0,0
    800010f6:	b7e5                	j	800010de <mappages+0x9c>

00000000800010f8 <kvmmap>:
{
    800010f8:	1141                	addi	sp,sp,-16
    800010fa:	e406                	sd	ra,8(sp)
    800010fc:	e022                	sd	s0,0(sp)
    800010fe:	0800                	addi	s0,sp,16
    80001100:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001102:	86b2                	mv	a3,a2
    80001104:	863e                	mv	a2,a5
    80001106:	f3dff0ef          	jal	80001042 <mappages>
    8000110a:	e509                	bnez	a0,80001114 <kvmmap+0x1c>
}
    8000110c:	60a2                	ld	ra,8(sp)
    8000110e:	6402                	ld	s0,0(sp)
    80001110:	0141                	addi	sp,sp,16
    80001112:	8082                	ret
    panic("kvmmap");
    80001114:	00006517          	auipc	a0,0x6
    80001118:	00450513          	addi	a0,a0,4 # 80007118 <etext+0x118>
    8000111c:	f18ff0ef          	jal	80000834 <panic>

0000000080001120 <kvmmake>:
{
    80001120:	1101                	addi	sp,sp,-32
    80001122:	ec06                	sd	ra,24(sp)
    80001124:	e822                	sd	s0,16(sp)
    80001126:	e426                	sd	s1,8(sp)
    80001128:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    8000112a:	9e5ff0ef          	jal	80000b0e <kalloc>
    8000112e:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001130:	6605                	lui	a2,0x1
    80001132:	4581                	li	a1,0
    80001134:	ba5ff0ef          	jal	80000cd8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001138:	4719                	li	a4,6
    8000113a:	6685                	lui	a3,0x1
    8000113c:	10000637          	lui	a2,0x10000
    80001140:	85b2                	mv	a1,a2
    80001142:	8526                	mv	a0,s1
    80001144:	fb5ff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001148:	4719                	li	a4,6
    8000114a:	6685                	lui	a3,0x1
    8000114c:	10001637          	lui	a2,0x10001
    80001150:	85b2                	mv	a1,a2
    80001152:	8526                	mv	a0,s1
    80001154:	fa5ff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001158:	4719                	li	a4,6
    8000115a:	040006b7          	lui	a3,0x4000
    8000115e:	0c000637          	lui	a2,0xc000
    80001162:	85b2                	mv	a1,a2
    80001164:	8526                	mv	a0,s1
    80001166:	f93ff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    8000116a:	4729                	li	a4,10
    8000116c:	80006697          	auipc	a3,0x80006
    80001170:	e9468693          	addi	a3,a3,-364 # 7000 <_entry-0x7fff9000>
    80001174:	4605                	li	a2,1
    80001176:	067e                	slli	a2,a2,0x1f
    80001178:	85b2                	mv	a1,a2
    8000117a:	8526                	mv	a0,s1
    8000117c:	f7dff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    80001180:	4719                	li	a4,6
    80001182:	00006697          	auipc	a3,0x6
    80001186:	e7e68693          	addi	a3,a3,-386 # 80007000 <etext>
    8000118a:	47c5                	li	a5,17
    8000118c:	07ee                	slli	a5,a5,0x1b
    8000118e:	40d786b3          	sub	a3,a5,a3
    80001192:	00006617          	auipc	a2,0x6
    80001196:	e6e60613          	addi	a2,a2,-402 # 80007000 <etext>
    8000119a:	85b2                	mv	a1,a2
    8000119c:	8526                	mv	a0,s1
    8000119e:	f5bff0ef          	jal	800010f8 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011a2:	4729                	li	a4,10
    800011a4:	6685                	lui	a3,0x1
    800011a6:	00005617          	auipc	a2,0x5
    800011aa:	e5a60613          	addi	a2,a2,-422 # 80006000 <_trampoline>
    800011ae:	040005b7          	lui	a1,0x4000
    800011b2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011b4:	05b2                	slli	a1,a1,0xc
    800011b6:	8526                	mv	a0,s1
    800011b8:	f41ff0ef          	jal	800010f8 <kvmmap>
  proc_mapstacks(kpgtbl);
    800011bc:	8526                	mv	a0,s1
    800011be:	5ec000ef          	jal	800017aa <proc_mapstacks>
}
    800011c2:	8526                	mv	a0,s1
    800011c4:	60e2                	ld	ra,24(sp)
    800011c6:	6442                	ld	s0,16(sp)
    800011c8:	64a2                	ld	s1,8(sp)
    800011ca:	6105                	addi	sp,sp,32
    800011cc:	8082                	ret

00000000800011ce <kvminit>:
{
    800011ce:	1141                	addi	sp,sp,-16
    800011d0:	e406                	sd	ra,8(sp)
    800011d2:	e022                	sd	s0,0(sp)
    800011d4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011d6:	f4bff0ef          	jal	80001120 <kvmmake>
    800011da:	00009797          	auipc	a5,0x9
    800011de:	26a7bb23          	sd	a0,630(a5) # 8000a450 <kernel_pagetable>
}
    800011e2:	60a2                	ld	ra,8(sp)
    800011e4:	6402                	ld	s0,0(sp)
    800011e6:	0141                	addi	sp,sp,16
    800011e8:	8082                	ret

00000000800011ea <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800011ea:	1101                	addi	sp,sp,-32
    800011ec:	ec06                	sd	ra,24(sp)
    800011ee:	e822                	sd	s0,16(sp)
    800011f0:	e426                	sd	s1,8(sp)
    800011f2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    800011f4:	91bff0ef          	jal	80000b0e <kalloc>
    800011f8:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800011fa:	c509                	beqz	a0,80001204 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800011fc:	6605                	lui	a2,0x1
    800011fe:	4581                	li	a1,0
    80001200:	ad9ff0ef          	jal	80000cd8 <memset>
  return pagetable;
}
    80001204:	8526                	mv	a0,s1
    80001206:	60e2                	ld	ra,24(sp)
    80001208:	6442                	ld	s0,16(sp)
    8000120a:	64a2                	ld	s1,8(sp)
    8000120c:	6105                	addi	sp,sp,32
    8000120e:	8082                	ret

0000000080001210 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001210:	7139                	addi	sp,sp,-64
    80001212:	fc06                	sd	ra,56(sp)
    80001214:	f822                	sd	s0,48(sp)
    80001216:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001218:	03459793          	slli	a5,a1,0x34
    8000121c:	e38d                	bnez	a5,8000123e <uvmunmap+0x2e>
    8000121e:	f04a                	sd	s2,32(sp)
    80001220:	ec4e                	sd	s3,24(sp)
    80001222:	e852                	sd	s4,16(sp)
    80001224:	e456                	sd	s5,8(sp)
    80001226:	e05a                	sd	s6,0(sp)
    80001228:	8a2a                	mv	s4,a0
    8000122a:	892e                	mv	s2,a1
    8000122c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000122e:	0632                	slli	a2,a2,0xc
    80001230:	00b609b3          	add	s3,a2,a1
    80001234:	6b05                	lui	s6,0x1
    80001236:	0535f963          	bgeu	a1,s3,80001288 <uvmunmap+0x78>
    8000123a:	f426                	sd	s1,40(sp)
    8000123c:	a015                	j	80001260 <uvmunmap+0x50>
    8000123e:	f426                	sd	s1,40(sp)
    80001240:	f04a                	sd	s2,32(sp)
    80001242:	ec4e                	sd	s3,24(sp)
    80001244:	e852                	sd	s4,16(sp)
    80001246:	e456                	sd	s5,8(sp)
    80001248:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000124a:	00006517          	auipc	a0,0x6
    8000124e:	ed650513          	addi	a0,a0,-298 # 80007120 <etext+0x120>
    80001252:	de2ff0ef          	jal	80000834 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    80001256:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000125a:	995a                	add	s2,s2,s6
    8000125c:	03397563          	bgeu	s2,s3,80001286 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    80001260:	4601                	li	a2,0
    80001262:	85ca                	mv	a1,s2
    80001264:	8552                	mv	a0,s4
    80001266:	d09ff0ef          	jal	80000f6e <walk>
    8000126a:	84aa                	mv	s1,a0
    8000126c:	d57d                	beqz	a0,8000125a <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    8000126e:	611c                	ld	a5,0(a0)
    80001270:	0017f713          	andi	a4,a5,1
    80001274:	d37d                	beqz	a4,8000125a <uvmunmap+0x4a>
    if (do_free) {
    80001276:	fe0a80e3          	beqz	s5,80001256 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    8000127a:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    8000127c:	00c79513          	slli	a0,a5,0xc
    80001280:	fa6ff0ef          	jal	80000a26 <kfree>
    80001284:	bfc9                	j	80001256 <uvmunmap+0x46>
    80001286:	74a2                	ld	s1,40(sp)
    80001288:	7902                	ld	s2,32(sp)
    8000128a:	69e2                	ld	s3,24(sp)
    8000128c:	6a42                	ld	s4,16(sp)
    8000128e:	6aa2                	ld	s5,8(sp)
    80001290:	6b02                	ld	s6,0(sp)
  }
}
    80001292:	70e2                	ld	ra,56(sp)
    80001294:	7442                	ld	s0,48(sp)
    80001296:	6121                	addi	sp,sp,64
    80001298:	8082                	ret

000000008000129a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000129a:	1101                	addi	sp,sp,-32
    8000129c:	ec06                	sd	ra,24(sp)
    8000129e:	e822                	sd	s0,16(sp)
    800012a0:	e426                	sd	s1,8(sp)
    800012a2:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800012a4:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800012a6:	00b67d63          	bgeu	a2,a1,800012c0 <uvmdealloc+0x26>
    800012aa:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    800012ac:	6785                	lui	a5,0x1
    800012ae:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012b0:	00f60733          	add	a4,a2,a5
    800012b4:	76fd                	lui	a3,0xfffff
    800012b6:	8f75                	and	a4,a4,a3
    800012b8:	97ae                	add	a5,a5,a1
    800012ba:	8ff5                	and	a5,a5,a3
    800012bc:	00f76863          	bltu	a4,a5,800012cc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012c0:	8526                	mv	a0,s1
    800012c2:	60e2                	ld	ra,24(sp)
    800012c4:	6442                	ld	s0,16(sp)
    800012c6:	64a2                	ld	s1,8(sp)
    800012c8:	6105                	addi	sp,sp,32
    800012ca:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012cc:	8f99                	sub	a5,a5,a4
    800012ce:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012d0:	4685                	li	a3,1
    800012d2:	0007861b          	sext.w	a2,a5
    800012d6:	85ba                	mv	a1,a4
    800012d8:	f39ff0ef          	jal	80001210 <uvmunmap>
    800012dc:	b7d5                	j	800012c0 <uvmdealloc+0x26>

00000000800012de <uvmalloc>:
  if (newsz < oldsz)
    800012de:	0ab66163          	bltu	a2,a1,80001380 <uvmalloc+0xa2>
{
    800012e2:	715d                	addi	sp,sp,-80
    800012e4:	e486                	sd	ra,72(sp)
    800012e6:	e0a2                	sd	s0,64(sp)
    800012e8:	f84a                	sd	s2,48(sp)
    800012ea:	f052                	sd	s4,32(sp)
    800012ec:	ec56                	sd	s5,24(sp)
    800012ee:	e45e                	sd	s7,8(sp)
    800012f0:	0880                	addi	s0,sp,80
    800012f2:	8aaa                	mv	s5,a0
    800012f4:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800012f6:	6785                	lui	a5,0x1
    800012f8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800012fa:	95be                	add	a1,a1,a5
    800012fc:	77fd                	lui	a5,0xfffff
    800012fe:	00f5f933          	and	s2,a1,a5
    80001302:	8bca                	mv	s7,s2
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001304:	08c97063          	bgeu	s2,a2,80001384 <uvmalloc+0xa6>
    80001308:	fc26                	sd	s1,56(sp)
    8000130a:	f44e                	sd	s3,40(sp)
    8000130c:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    8000130e:	6985                	lui	s3,0x1
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001310:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001314:	ffaff0ef          	jal	80000b0e <kalloc>
    80001318:	84aa                	mv	s1,a0
    if (mem == 0) {
    8000131a:	c50d                	beqz	a0,80001344 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    8000131c:	864e                	mv	a2,s3
    8000131e:	4581                	li	a1,0
    80001320:	9b9ff0ef          	jal	80000cd8 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    80001324:	875a                	mv	a4,s6
    80001326:	86a6                	mv	a3,s1
    80001328:	864e                	mv	a2,s3
    8000132a:	85ca                	mv	a1,s2
    8000132c:	8556                	mv	a0,s5
    8000132e:	d15ff0ef          	jal	80001042 <mappages>
    80001332:	e915                	bnez	a0,80001366 <uvmalloc+0x88>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    80001334:	994e                	add	s2,s2,s3
    80001336:	fd496fe3          	bltu	s2,s4,80001314 <uvmalloc+0x36>
  return newsz;
    8000133a:	8552                	mv	a0,s4
    8000133c:	74e2                	ld	s1,56(sp)
    8000133e:	79a2                	ld	s3,40(sp)
    80001340:	6b42                	ld	s6,16(sp)
    80001342:	a811                	j	80001356 <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001344:	865e                	mv	a2,s7
    80001346:	85ca                	mv	a1,s2
    80001348:	8556                	mv	a0,s5
    8000134a:	f51ff0ef          	jal	8000129a <uvmdealloc>
      return 0;
    8000134e:	4501                	li	a0,0
    80001350:	74e2                	ld	s1,56(sp)
    80001352:	79a2                	ld	s3,40(sp)
    80001354:	6b42                	ld	s6,16(sp)
}
    80001356:	60a6                	ld	ra,72(sp)
    80001358:	6406                	ld	s0,64(sp)
    8000135a:	7942                	ld	s2,48(sp)
    8000135c:	7a02                	ld	s4,32(sp)
    8000135e:	6ae2                	ld	s5,24(sp)
    80001360:	6ba2                	ld	s7,8(sp)
    80001362:	6161                	addi	sp,sp,80
    80001364:	8082                	ret
      kfree(mem);
    80001366:	8526                	mv	a0,s1
    80001368:	ebeff0ef          	jal	80000a26 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000136c:	865e                	mv	a2,s7
    8000136e:	85ca                	mv	a1,s2
    80001370:	8556                	mv	a0,s5
    80001372:	f29ff0ef          	jal	8000129a <uvmdealloc>
      return 0;
    80001376:	4501                	li	a0,0
    80001378:	74e2                	ld	s1,56(sp)
    8000137a:	79a2                	ld	s3,40(sp)
    8000137c:	6b42                	ld	s6,16(sp)
    8000137e:	bfe1                	j	80001356 <uvmalloc+0x78>
    return oldsz;
    80001380:	852e                	mv	a0,a1
}
    80001382:	8082                	ret
  return newsz;
    80001384:	8532                	mv	a0,a2
    80001386:	bfc1                	j	80001356 <uvmalloc+0x78>

0000000080001388 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001388:	7179                	addi	sp,sp,-48
    8000138a:	f406                	sd	ra,40(sp)
    8000138c:	f022                	sd	s0,32(sp)
    8000138e:	ec26                	sd	s1,24(sp)
    80001390:	e84a                	sd	s2,16(sp)
    80001392:	e44e                	sd	s3,8(sp)
    80001394:	1800                	addi	s0,sp,48
    80001396:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    80001398:	84aa                	mv	s1,a0
    8000139a:	6905                	lui	s2,0x1
    8000139c:	992a                	add	s2,s2,a0
    8000139e:	a811                	j	800013b2 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if (pte & PTE_V) {
      panic("freewalk: leaf");
    800013a0:	00006517          	auipc	a0,0x6
    800013a4:	d9850513          	addi	a0,a0,-616 # 80007138 <etext+0x138>
    800013a8:	c8cff0ef          	jal	80000834 <panic>
  for (int i = 0; i < 512; i++) {
    800013ac:	04a1                	addi	s1,s1,8
    800013ae:	03248163          	beq	s1,s2,800013d0 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013b2:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013b4:	0017f713          	andi	a4,a5,1
    800013b8:	db75                	beqz	a4,800013ac <freewalk+0x24>
    800013ba:	00e7f713          	andi	a4,a5,14
    800013be:	f36d                	bnez	a4,800013a0 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800013c0:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800013c2:	00c79513          	slli	a0,a5,0xc
    800013c6:	fc3ff0ef          	jal	80001388 <freewalk>
      pagetable[i] = 0;
    800013ca:	0004b023          	sd	zero,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800013ce:	bff9                	j	800013ac <freewalk+0x24>
    }
  }
  kfree((void *)pagetable);
    800013d0:	854e                	mv	a0,s3
    800013d2:	e54ff0ef          	jal	80000a26 <kfree>
}
    800013d6:	70a2                	ld	ra,40(sp)
    800013d8:	7402                	ld	s0,32(sp)
    800013da:	64e2                	ld	s1,24(sp)
    800013dc:	6942                	ld	s2,16(sp)
    800013de:	69a2                	ld	s3,8(sp)
    800013e0:	6145                	addi	sp,sp,48
    800013e2:	8082                	ret

00000000800013e4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013e4:	1101                	addi	sp,sp,-32
    800013e6:	ec06                	sd	ra,24(sp)
    800013e8:	e822                	sd	s0,16(sp)
    800013ea:	e426                	sd	s1,8(sp)
    800013ec:	1000                	addi	s0,sp,32
    800013ee:	84aa                	mv	s1,a0
  if (sz > 0)
    800013f0:	e989                	bnez	a1,80001402 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    800013f2:	8526                	mv	a0,s1
    800013f4:	f95ff0ef          	jal	80001388 <freewalk>
}
    800013f8:	60e2                	ld	ra,24(sp)
    800013fa:	6442                	ld	s0,16(sp)
    800013fc:	64a2                	ld	s1,8(sp)
    800013fe:	6105                	addi	sp,sp,32
    80001400:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001402:	6785                	lui	a5,0x1
    80001404:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001406:	95be                	add	a1,a1,a5
    80001408:	4685                	li	a3,1
    8000140a:	00c5d613          	srli	a2,a1,0xc
    8000140e:	4581                	li	a1,0
    80001410:	e01ff0ef          	jal	80001210 <uvmunmap>
    80001414:	bff9                	j	800013f2 <uvmfree+0xe>

0000000080001416 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001416:	ca59                	beqz	a2,800014ac <uvmcopy+0x96>
{
    80001418:	715d                	addi	sp,sp,-80
    8000141a:	e486                	sd	ra,72(sp)
    8000141c:	e0a2                	sd	s0,64(sp)
    8000141e:	fc26                	sd	s1,56(sp)
    80001420:	f84a                	sd	s2,48(sp)
    80001422:	f44e                	sd	s3,40(sp)
    80001424:	f052                	sd	s4,32(sp)
    80001426:	ec56                	sd	s5,24(sp)
    80001428:	e85a                	sd	s6,16(sp)
    8000142a:	e45e                	sd	s7,8(sp)
    8000142c:	0880                	addi	s0,sp,80
    8000142e:	8b2a                	mv	s6,a0
    80001430:	8bae                	mv	s7,a1
    80001432:	8ab2                	mv	s5,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001434:	4481                	li	s1,0
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if ((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    80001436:	6a05                	lui	s4,0x1
    80001438:	a021                	j	80001440 <uvmcopy+0x2a>
  for (i = 0; i < sz; i += PGSIZE) {
    8000143a:	94d2                	add	s1,s1,s4
    8000143c:	0554fc63          	bgeu	s1,s5,80001494 <uvmcopy+0x7e>
    if ((pte = walk(old, i, 0)) == 0)
    80001440:	4601                	li	a2,0
    80001442:	85a6                	mv	a1,s1
    80001444:	855a                	mv	a0,s6
    80001446:	b29ff0ef          	jal	80000f6e <walk>
    8000144a:	d965                	beqz	a0,8000143a <uvmcopy+0x24>
    if ((*pte & PTE_V) == 0)
    8000144c:	00053983          	ld	s3,0(a0)
    80001450:	0019f793          	andi	a5,s3,1
    80001454:	d3fd                	beqz	a5,8000143a <uvmcopy+0x24>
    if ((mem = kalloc()) == 0)
    80001456:	eb8ff0ef          	jal	80000b0e <kalloc>
    8000145a:	892a                	mv	s2,a0
    8000145c:	c11d                	beqz	a0,80001482 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000145e:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char *)pa, PGSIZE);
    80001462:	8652                	mv	a2,s4
    80001464:	05b2                	slli	a1,a1,0xc
    80001466:	8d3ff0ef          	jal	80000d38 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    8000146a:	3ff9f713          	andi	a4,s3,1023
    8000146e:	86ca                	mv	a3,s2
    80001470:	8652                	mv	a2,s4
    80001472:	85a6                	mv	a1,s1
    80001474:	855e                	mv	a0,s7
    80001476:	bcdff0ef          	jal	80001042 <mappages>
    8000147a:	d161                	beqz	a0,8000143a <uvmcopy+0x24>
      kfree(mem);
    8000147c:	854a                	mv	a0,s2
    8000147e:	da8ff0ef          	jal	80000a26 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001482:	4685                	li	a3,1
    80001484:	00c4d613          	srli	a2,s1,0xc
    80001488:	4581                	li	a1,0
    8000148a:	855e                	mv	a0,s7
    8000148c:	d85ff0ef          	jal	80001210 <uvmunmap>
  return -1;
    80001490:	557d                	li	a0,-1
    80001492:	a011                	j	80001496 <uvmcopy+0x80>
  return 0;
    80001494:	4501                	li	a0,0
}
    80001496:	60a6                	ld	ra,72(sp)
    80001498:	6406                	ld	s0,64(sp)
    8000149a:	74e2                	ld	s1,56(sp)
    8000149c:	7942                	ld	s2,48(sp)
    8000149e:	79a2                	ld	s3,40(sp)
    800014a0:	7a02                	ld	s4,32(sp)
    800014a2:	6ae2                	ld	s5,24(sp)
    800014a4:	6b42                	ld	s6,16(sp)
    800014a6:	6ba2                	ld	s7,8(sp)
    800014a8:	6161                	addi	sp,sp,80
    800014aa:	8082                	ret
  return 0;
    800014ac:	4501                	li	a0,0
}
    800014ae:	8082                	ret

00000000800014b0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014b0:	1141                	addi	sp,sp,-16
    800014b2:	e406                	sd	ra,8(sp)
    800014b4:	e022                	sd	s0,0(sp)
    800014b6:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800014b8:	4601                	li	a2,0
    800014ba:	ab5ff0ef          	jal	80000f6e <walk>
  if (pte == 0)
    800014be:	c901                	beqz	a0,800014ce <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014c0:	611c                	ld	a5,0(a0)
    800014c2:	9bbd                	andi	a5,a5,-17
    800014c4:	e11c                	sd	a5,0(a0)
}
    800014c6:	60a2                	ld	ra,8(sp)
    800014c8:	6402                	ld	s0,0(sp)
    800014ca:	0141                	addi	sp,sp,16
    800014cc:	8082                	ret
    panic("uvmclear");
    800014ce:	00006517          	auipc	a0,0x6
    800014d2:	c7a50513          	addi	a0,a0,-902 # 80007148 <etext+0x148>
    800014d6:	b5eff0ef          	jal	80000834 <panic>

00000000800014da <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800014da:	1141                	addi	sp,sp,-16
    800014dc:	e406                	sd	ra,8(sp)
    800014de:	e022                	sd	s0,0(sp)
    800014e0:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800014e2:	4601                	li	a2,0
    800014e4:	a8bff0ef          	jal	80000f6e <walk>
  if (pte == 0) {
    800014e8:	c119                	beqz	a0,800014ee <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V) {
    800014ea:	6108                	ld	a0,0(a0)
    800014ec:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800014ee:	60a2                	ld	ra,8(sp)
    800014f0:	6402                	ld	s0,0(sp)
    800014f2:	0141                	addi	sp,sp,16
    800014f4:	8082                	ret

00000000800014f6 <vmfault>:
{
    800014f6:	7179                	addi	sp,sp,-48
    800014f8:	f406                	sd	ra,40(sp)
    800014fa:	f022                	sd	s0,32(sp)
    800014fc:	e052                	sd	s4,0(sp)
    800014fe:	1800                	addi	s0,sp,48
    return 0;
    80001500:	4a01                	li	s4,0
  if (va >= psz)
    80001502:	00b66863          	bltu	a2,a1,80001512 <vmfault+0x1c>
}
    80001506:	8552                	mv	a0,s4
    80001508:	70a2                	ld	ra,40(sp)
    8000150a:	7402                	ld	s0,32(sp)
    8000150c:	6a02                	ld	s4,0(sp)
    8000150e:	6145                	addi	sp,sp,48
    80001510:	8082                	ret
    80001512:	ec26                	sd	s1,24(sp)
    80001514:	e44e                	sd	s3,8(sp)
    80001516:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001518:	77fd                	lui	a5,0xfffff
    8000151a:	00f679b3          	and	s3,a2,a5
  if (ismapped(pagetable, va)) {
    8000151e:	85ce                	mv	a1,s3
    80001520:	fbbff0ef          	jal	800014da <ismapped>
    return 0;
    80001524:	4a01                	li	s4,0
  if (ismapped(pagetable, va)) {
    80001526:	c501                	beqz	a0,8000152e <vmfault+0x38>
    80001528:	64e2                	ld	s1,24(sp)
    8000152a:	69a2                	ld	s3,8(sp)
    8000152c:	bfe9                	j	80001506 <vmfault+0x10>
    8000152e:	e84a                	sd	s2,16(sp)
  mem = (uint64)kalloc();
    80001530:	ddeff0ef          	jal	80000b0e <kalloc>
    80001534:	892a                	mv	s2,a0
  if (mem == 0)
    80001536:	c915                	beqz	a0,8000156a <vmfault+0x74>
  mem = (uint64)kalloc();
    80001538:	8a2a                	mv	s4,a0
  memset((void *)mem, 0, PGSIZE);
    8000153a:	6605                	lui	a2,0x1
    8000153c:	4581                	li	a1,0
    8000153e:	f9aff0ef          	jal	80000cd8 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    80001542:	4759                	li	a4,22
    80001544:	86ca                	mv	a3,s2
    80001546:	6605                	lui	a2,0x1
    80001548:	85ce                	mv	a1,s3
    8000154a:	8526                	mv	a0,s1
    8000154c:	af7ff0ef          	jal	80001042 <mappages>
    80001550:	e509                	bnez	a0,8000155a <vmfault+0x64>
    80001552:	64e2                	ld	s1,24(sp)
    80001554:	6942                	ld	s2,16(sp)
    80001556:	69a2                	ld	s3,8(sp)
    80001558:	b77d                	j	80001506 <vmfault+0x10>
    kfree((void *)mem);
    8000155a:	854a                	mv	a0,s2
    8000155c:	ccaff0ef          	jal	80000a26 <kfree>
    return 0;
    80001560:	4a01                	li	s4,0
    80001562:	64e2                	ld	s1,24(sp)
    80001564:	6942                	ld	s2,16(sp)
    80001566:	69a2                	ld	s3,8(sp)
    80001568:	bf79                	j	80001506 <vmfault+0x10>
    8000156a:	64e2                	ld	s1,24(sp)
    8000156c:	6942                	ld	s2,16(sp)
    8000156e:	69a2                	ld	s3,8(sp)
    80001570:	bf59                	j	80001506 <vmfault+0x10>

0000000080001572 <copyout>:
  while (len > 0) {
    80001572:	cf49                	beqz	a4,8000160c <copyout+0x9a>
{
    80001574:	7159                	addi	sp,sp,-112
    80001576:	f486                	sd	ra,104(sp)
    80001578:	f0a2                	sd	s0,96(sp)
    8000157a:	eca6                	sd	s1,88(sp)
    8000157c:	e8ca                	sd	s2,80(sp)
    8000157e:	e4ce                	sd	s3,72(sp)
    80001580:	e0d2                	sd	s4,64(sp)
    80001582:	fc56                	sd	s5,56(sp)
    80001584:	f85a                	sd	s6,48(sp)
    80001586:	f45e                	sd	s7,40(sp)
    80001588:	f062                	sd	s8,32(sp)
    8000158a:	ec66                	sd	s9,24(sp)
    8000158c:	e86a                	sd	s10,16(sp)
    8000158e:	e46e                	sd	s11,8(sp)
    80001590:	1880                	addi	s0,sp,112
    80001592:	8baa                	mv	s7,a0
    80001594:	8dae                	mv	s11,a1
    80001596:	8a32                	mv	s4,a2
    80001598:	8b36                	mv	s6,a3
    8000159a:	8aba                	mv	s5,a4
    va0 = PGROUNDDOWN(dstva);
    8000159c:	7d7d                	lui	s10,0xfffff
    if (va0 >= MAXVA)
    8000159e:	5cfd                	li	s9,-1
    800015a0:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    800015a4:	6c05                	lui	s8,0x1
    800015a6:	a005                	j	800015c6 <copyout+0x54>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015a8:	409a0533          	sub	a0,s4,s1
    800015ac:	0009061b          	sext.w	a2,s2
    800015b0:	85da                	mv	a1,s6
    800015b2:	954e                	add	a0,a0,s3
    800015b4:	f84ff0ef          	jal	80000d38 <memmove>
    len -= n;
    800015b8:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800015bc:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800015be:	01848a33          	add	s4,s1,s8
  while (len > 0) {
    800015c2:	040a8363          	beqz	s5,80001608 <copyout+0x96>
    va0 = PGROUNDDOWN(dstva);
    800015c6:	01aa74b3          	and	s1,s4,s10
    if (va0 >= MAXVA)
    800015ca:	049ce363          	bltu	s9,s1,80001610 <copyout+0x9e>
    pa0 = walkaddr(pagetable, va0);
    800015ce:	85a6                	mv	a1,s1
    800015d0:	855e                	mv	a0,s7
    800015d2:	a37ff0ef          	jal	80001008 <walkaddr>
    800015d6:	89aa                	mv	s3,a0
    if (pa0 == 0) {
    800015d8:	e909                	bnez	a0,800015ea <copyout+0x78>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    800015da:	4681                	li	a3,0
    800015dc:	8626                	mv	a2,s1
    800015de:	85ee                	mv	a1,s11
    800015e0:	855e                	mv	a0,s7
    800015e2:	f15ff0ef          	jal	800014f6 <vmfault>
    800015e6:	89aa                	mv	s3,a0
    800015e8:	c521                	beqz	a0,80001630 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    800015ea:	4601                	li	a2,0
    800015ec:	85a6                	mv	a1,s1
    800015ee:	855e                	mv	a0,s7
    800015f0:	97fff0ef          	jal	80000f6e <walk>
    if ((*pte & PTE_W) == 0)
    800015f4:	611c                	ld	a5,0(a0)
    800015f6:	8b91                	andi	a5,a5,4
    800015f8:	cf95                	beqz	a5,80001634 <copyout+0xc2>
    n = PGSIZE - (dstva - va0);
    800015fa:	41448933          	sub	s2,s1,s4
    800015fe:	9962                	add	s2,s2,s8
    if (n > len)
    80001600:	fb2af4e3          	bgeu	s5,s2,800015a8 <copyout+0x36>
    80001604:	8956                	mv	s2,s5
    80001606:	b74d                	j	800015a8 <copyout+0x36>
  return 0;
    80001608:	4501                	li	a0,0
    8000160a:	a021                	j	80001612 <copyout+0xa0>
    8000160c:	4501                	li	a0,0
}
    8000160e:	8082                	ret
      return -1;
    80001610:	557d                	li	a0,-1
}
    80001612:	70a6                	ld	ra,104(sp)
    80001614:	7406                	ld	s0,96(sp)
    80001616:	64e6                	ld	s1,88(sp)
    80001618:	6946                	ld	s2,80(sp)
    8000161a:	69a6                	ld	s3,72(sp)
    8000161c:	6a06                	ld	s4,64(sp)
    8000161e:	7ae2                	ld	s5,56(sp)
    80001620:	7b42                	ld	s6,48(sp)
    80001622:	7ba2                	ld	s7,40(sp)
    80001624:	7c02                	ld	s8,32(sp)
    80001626:	6ce2                	ld	s9,24(sp)
    80001628:	6d42                	ld	s10,16(sp)
    8000162a:	6da2                	ld	s11,8(sp)
    8000162c:	6165                	addi	sp,sp,112
    8000162e:	8082                	ret
        return -1;
    80001630:	557d                	li	a0,-1
    80001632:	b7c5                	j	80001612 <copyout+0xa0>
      return -1;
    80001634:	557d                	li	a0,-1
    80001636:	bff1                	j	80001612 <copyout+0xa0>

0000000080001638 <copyin>:
  while (len > 0) {
    80001638:	cf41                	beqz	a4,800016d0 <copyin+0x98>
{
    8000163a:	711d                	addi	sp,sp,-96
    8000163c:	ec86                	sd	ra,88(sp)
    8000163e:	e8a2                	sd	s0,80(sp)
    80001640:	e4a6                	sd	s1,72(sp)
    80001642:	e0ca                	sd	s2,64(sp)
    80001644:	fc4e                	sd	s3,56(sp)
    80001646:	f852                	sd	s4,48(sp)
    80001648:	f456                	sd	s5,40(sp)
    8000164a:	f05a                	sd	s6,32(sp)
    8000164c:	ec5e                	sd	s7,24(sp)
    8000164e:	e862                	sd	s8,16(sp)
    80001650:	e466                	sd	s9,8(sp)
    80001652:	e06a                	sd	s10,0(sp)
    80001654:	1080                	addi	s0,sp,96
    80001656:	8baa                	mv	s7,a0
    80001658:	8cae                	mv	s9,a1
    8000165a:	8ab2                	mv	s5,a2
    8000165c:	8936                	mv	s2,a3
    8000165e:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    80001660:	7c7d                	lui	s8,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001662:	4d05                	li	s10,1
    n = PGSIZE - (srcva - va0);
    80001664:	6b05                	lui	s6,0x1
    80001666:	a035                	j	80001692 <copyin+0x5a>
    80001668:	412984b3          	sub	s1,s3,s2
    8000166c:	94da                	add	s1,s1,s6
    if (n > len)
    8000166e:	009a7363          	bgeu	s4,s1,80001674 <copyin+0x3c>
    80001672:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001674:	413905b3          	sub	a1,s2,s3
    80001678:	0004861b          	sext.w	a2,s1
    8000167c:	95aa                	add	a1,a1,a0
    8000167e:	8556                	mv	a0,s5
    80001680:	eb8ff0ef          	jal	80000d38 <memmove>
    len -= n;
    80001684:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001688:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    8000168a:	01698933          	add	s2,s3,s6
  while (len > 0) {
    8000168e:	020a0263          	beqz	s4,800016b2 <copyin+0x7a>
    va0 = PGROUNDDOWN(srcva);
    80001692:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001696:	85ce                	mv	a1,s3
    80001698:	855e                	mv	a0,s7
    8000169a:	96fff0ef          	jal	80001008 <walkaddr>
    if (pa0 == 0) {
    8000169e:	f569                	bnez	a0,80001668 <copyin+0x30>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016a0:	86ea                	mv	a3,s10
    800016a2:	864e                	mv	a2,s3
    800016a4:	85e6                	mv	a1,s9
    800016a6:	855e                	mv	a0,s7
    800016a8:	e4fff0ef          	jal	800014f6 <vmfault>
    800016ac:	fd55                	bnez	a0,80001668 <copyin+0x30>
        return -1;
    800016ae:	557d                	li	a0,-1
    800016b0:	a011                	j	800016b4 <copyin+0x7c>
  return 0;
    800016b2:	4501                	li	a0,0
}
    800016b4:	60e6                	ld	ra,88(sp)
    800016b6:	6446                	ld	s0,80(sp)
    800016b8:	64a6                	ld	s1,72(sp)
    800016ba:	6906                	ld	s2,64(sp)
    800016bc:	79e2                	ld	s3,56(sp)
    800016be:	7a42                	ld	s4,48(sp)
    800016c0:	7aa2                	ld	s5,40(sp)
    800016c2:	7b02                	ld	s6,32(sp)
    800016c4:	6be2                	ld	s7,24(sp)
    800016c6:	6c42                	ld	s8,16(sp)
    800016c8:	6ca2                	ld	s9,8(sp)
    800016ca:	6d02                	ld	s10,0(sp)
    800016cc:	6125                	addi	sp,sp,96
    800016ce:	8082                	ret
  return 0;
    800016d0:	4501                	li	a0,0
}
    800016d2:	8082                	ret

00000000800016d4 <copyinstr>:
  while (got_null == 0 && max > 0) {
    800016d4:	c769                	beqz	a4,8000179e <copyinstr+0xca>
{
    800016d6:	711d                	addi	sp,sp,-96
    800016d8:	ec86                	sd	ra,88(sp)
    800016da:	e8a2                	sd	s0,80(sp)
    800016dc:	e4a6                	sd	s1,72(sp)
    800016de:	e0ca                	sd	s2,64(sp)
    800016e0:	fc4e                	sd	s3,56(sp)
    800016e2:	f852                	sd	s4,48(sp)
    800016e4:	f456                	sd	s5,40(sp)
    800016e6:	f05a                	sd	s6,32(sp)
    800016e8:	ec5e                	sd	s7,24(sp)
    800016ea:	e862                	sd	s8,16(sp)
    800016ec:	e466                	sd	s9,8(sp)
    800016ee:	1080                	addi	s0,sp,96
    800016f0:	8b2a                	mv	s6,a0
    800016f2:	8c2e                	mv	s8,a1
    800016f4:	89b2                	mv	s3,a2
    800016f6:	84b6                	mv	s1,a3
    800016f8:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800016fa:	7bfd                	lui	s7,0xfffff
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    800016fc:	4c85                	li	s9,1
    n = PGSIZE - (srcva - va0);
    800016fe:	6a85                	lui	s5,0x1
    80001700:	a881                	j	80001750 <copyinstr+0x7c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001702:	86e6                	mv	a3,s9
    80001704:	864a                	mv	a2,s2
    80001706:	85e2                	mv	a1,s8
    80001708:	855a                	mv	a0,s6
    8000170a:	dedff0ef          	jal	800014f6 <vmfault>
    8000170e:	e921                	bnez	a0,8000175e <copyinstr+0x8a>
        return -1;
    80001710:	557d                	li	a0,-1
    80001712:	a801                	j	80001722 <copyinstr+0x4e>
        *dst = '\0';
    80001714:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb670>
        got_null = 1;
    80001718:	4785                	li	a5,1
  if (got_null) {
    8000171a:	0017c793          	xori	a5,a5,1
    8000171e:	40f0053b          	negw	a0,a5
}
    80001722:	60e6                	ld	ra,88(sp)
    80001724:	6446                	ld	s0,80(sp)
    80001726:	64a6                	ld	s1,72(sp)
    80001728:	6906                	ld	s2,64(sp)
    8000172a:	79e2                	ld	s3,56(sp)
    8000172c:	7a42                	ld	s4,48(sp)
    8000172e:	7aa2                	ld	s5,40(sp)
    80001730:	7b02                	ld	s6,32(sp)
    80001732:	6be2                	ld	s7,24(sp)
    80001734:	6c42                	ld	s8,16(sp)
    80001736:	6ca2                	ld	s9,8(sp)
    80001738:	6125                	addi	sp,sp,96
    8000173a:	8082                	ret
    8000173c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80001740:	974e                	add	a4,a4,s3
      --max;
    80001742:	40b70a33          	sub	s4,a4,a1
    srcva = va0 + PGSIZE;
    80001746:	015904b3          	add	s1,s2,s5
  while (got_null == 0 && max > 0) {
    8000174a:	04e58463          	beq	a1,a4,80001792 <copyinstr+0xbe>
{
    8000174e:	89be                	mv	s3,a5
    va0 = PGROUNDDOWN(srcva);
    80001750:	0174f933          	and	s2,s1,s7
    pa0 = walkaddr(pagetable, va0);
    80001754:	85ca                	mv	a1,s2
    80001756:	855a                	mv	a0,s6
    80001758:	8b1ff0ef          	jal	80001008 <walkaddr>
    if (pa0 == 0) {
    8000175c:	d15d                	beqz	a0,80001702 <copyinstr+0x2e>
    n = PGSIZE - (srcva - va0);
    8000175e:	40990633          	sub	a2,s2,s1
    80001762:	9656                	add	a2,a2,s5
    if (n > max)
    80001764:	00ca7363          	bgeu	s4,a2,8000176a <copyinstr+0x96>
    80001768:	8652                	mv	a2,s4
    while (n > 0) {
    8000176a:	c615                	beqz	a2,80001796 <copyinstr+0xc2>
    char *p = (char *)(pa0 + (srcva - va0));
    8000176c:	412484b3          	sub	s1,s1,s2
    80001770:	94aa                	add	s1,s1,a0
    80001772:	87ce                	mv	a5,s3
      if (*p == '\0') {
    80001774:	413484b3          	sub	s1,s1,s3
    while (n > 0) {
    80001778:	964e                	add	a2,a2,s3
    8000177a:	85be                	mv	a1,a5
      if (*p == '\0') {
    8000177c:	00f48733          	add	a4,s1,a5
    80001780:	00074683          	lbu	a3,0(a4)
    80001784:	dac1                	beqz	a3,80001714 <copyinstr+0x40>
        *dst = *p;
    80001786:	00d78023          	sb	a3,0(a5)
      dst++;
    8000178a:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000178c:	fec797e3          	bne	a5,a2,8000177a <copyinstr+0xa6>
    80001790:	b775                	j	8000173c <copyinstr+0x68>
    80001792:	4781                	li	a5,0
    80001794:	b759                	j	8000171a <copyinstr+0x46>
    srcva = va0 + PGSIZE;
    80001796:	6485                	lui	s1,0x1
    80001798:	94ca                	add	s1,s1,s2
    8000179a:	87ce                	mv	a5,s3
    8000179c:	bf4d                	j	8000174e <copyinstr+0x7a>
  int got_null = 0;
    8000179e:	4781                	li	a5,0
  if (got_null) {
    800017a0:	0017c793          	xori	a5,a5,1
    800017a4:	40f0053b          	negw	a0,a5
}
    800017a8:	8082                	ret

00000000800017aa <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017aa:	715d                	addi	sp,sp,-80
    800017ac:	e486                	sd	ra,72(sp)
    800017ae:	e0a2                	sd	s0,64(sp)
    800017b0:	fc26                	sd	s1,56(sp)
    800017b2:	f84a                	sd	s2,48(sp)
    800017b4:	f44e                	sd	s3,40(sp)
    800017b6:	f052                	sd	s4,32(sp)
    800017b8:	ec56                	sd	s5,24(sp)
    800017ba:	e85a                	sd	s6,16(sp)
    800017bc:	e45e                	sd	s7,8(sp)
    800017be:	e062                	sd	s8,0(sp)
    800017c0:	0880                	addi	s0,sp,80
    800017c2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800017c4:	00011497          	auipc	s1,0x11
    800017c8:	1ec48493          	addi	s1,s1,492 # 800129b0 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017cc:	8c26                	mv	s8,s1
    800017ce:	ff4df937          	lui	s2,0xff4df
    800017d2:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb02d>
    800017d6:	0936                	slli	s2,s2,0xd
    800017d8:	6f590913          	addi	s2,s2,1781
    800017dc:	0936                	slli	s2,s2,0xd
    800017de:	bd390913          	addi	s2,s2,-1069
    800017e2:	0932                	slli	s2,s2,0xc
    800017e4:	7a790913          	addi	s2,s2,1959
    800017e8:	040009b7          	lui	s3,0x4000
    800017ec:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017ee:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017f0:	4b99                	li	s7,6
    800017f2:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    800017f4:	00017a97          	auipc	s5,0x17
    800017f8:	dbca8a93          	addi	s5,s5,-580 # 800185b0 <tickslock>
    char *pa = kalloc();
    800017fc:	b12ff0ef          	jal	80000b0e <kalloc>
    80001800:	862a                	mv	a2,a0
    if (pa == 0)
    80001802:	c121                	beqz	a0,80001842 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001804:	418485b3          	sub	a1,s1,s8
    80001808:	8591                	srai	a1,a1,0x4
    8000180a:	032585b3          	mul	a1,a1,s2
    8000180e:	05b6                	slli	a1,a1,0xd
    80001810:	6789                	lui	a5,0x2
    80001812:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001814:	875e                	mv	a4,s7
    80001816:	86da                	mv	a3,s6
    80001818:	40b985b3          	sub	a1,s3,a1
    8000181c:	8552                	mv	a0,s4
    8000181e:	8dbff0ef          	jal	800010f8 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001822:	17048493          	addi	s1,s1,368
    80001826:	fd549be3          	bne	s1,s5,800017fc <proc_mapstacks+0x52>
  }
}
    8000182a:	60a6                	ld	ra,72(sp)
    8000182c:	6406                	ld	s0,64(sp)
    8000182e:	74e2                	ld	s1,56(sp)
    80001830:	7942                	ld	s2,48(sp)
    80001832:	79a2                	ld	s3,40(sp)
    80001834:	7a02                	ld	s4,32(sp)
    80001836:	6ae2                	ld	s5,24(sp)
    80001838:	6b42                	ld	s6,16(sp)
    8000183a:	6ba2                	ld	s7,8(sp)
    8000183c:	6c02                	ld	s8,0(sp)
    8000183e:	6161                	addi	sp,sp,80
    80001840:	8082                	ret
      panic("kalloc");
    80001842:	00006517          	auipc	a0,0x6
    80001846:	91650513          	addi	a0,a0,-1770 # 80007158 <etext+0x158>
    8000184a:	febfe0ef          	jal	80000834 <panic>

000000008000184e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000184e:	7139                	addi	sp,sp,-64
    80001850:	fc06                	sd	ra,56(sp)
    80001852:	f822                	sd	s0,48(sp)
    80001854:	f426                	sd	s1,40(sp)
    80001856:	f04a                	sd	s2,32(sp)
    80001858:	ec4e                	sd	s3,24(sp)
    8000185a:	e852                	sd	s4,16(sp)
    8000185c:	e456                	sd	s5,8(sp)
    8000185e:	e05a                	sd	s6,0(sp)
    80001860:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001862:	00006597          	auipc	a1,0x6
    80001866:	8fe58593          	addi	a1,a1,-1794 # 80007160 <etext+0x160>
    8000186a:	00011517          	auipc	a0,0x11
    8000186e:	d1650513          	addi	a0,a0,-746 # 80012580 <pid_lock>
    80001872:	b26ff0ef          	jal	80000b98 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001876:	00006597          	auipc	a1,0x6
    8000187a:	8f258593          	addi	a1,a1,-1806 # 80007168 <etext+0x168>
    8000187e:	00011517          	auipc	a0,0x11
    80001882:	d1a50513          	addi	a0,a0,-742 # 80012598 <wait_lock>
    80001886:	b12ff0ef          	jal	80000b98 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000188a:	00011497          	auipc	s1,0x11
    8000188e:	12648493          	addi	s1,s1,294 # 800129b0 <proc>
    initlock(&p->lock, "proc");
    80001892:	00006b17          	auipc	s6,0x6
    80001896:	8e6b0b13          	addi	s6,s6,-1818 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000189a:	8aa6                	mv	s5,s1
    8000189c:	ff4df937          	lui	s2,0xff4df
    800018a0:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bb02d>
    800018a4:	0936                	slli	s2,s2,0xd
    800018a6:	6f590913          	addi	s2,s2,1781
    800018aa:	0936                	slli	s2,s2,0xd
    800018ac:	bd390913          	addi	s2,s2,-1069
    800018b0:	0932                	slli	s2,s2,0xc
    800018b2:	7a790913          	addi	s2,s2,1959
    800018b6:	040009b7          	lui	s3,0x4000
    800018ba:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018bc:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018be:	00017a17          	auipc	s4,0x17
    800018c2:	cf2a0a13          	addi	s4,s4,-782 # 800185b0 <tickslock>
    initlock(&p->lock, "proc");
    800018c6:	85da                	mv	a1,s6
    800018c8:	8526                	mv	a0,s1
    800018ca:	aceff0ef          	jal	80000b98 <initlock>
    p->state = UNUSED;
    800018ce:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018d2:	415487b3          	sub	a5,s1,s5
    800018d6:	8791                	srai	a5,a5,0x4
    800018d8:	032787b3          	mul	a5,a5,s2
    800018dc:	07b6                	slli	a5,a5,0xd
    800018de:	6709                	lui	a4,0x2
    800018e0:	9fb9                	addw	a5,a5,a4
    800018e2:	40f987b3          	sub	a5,s3,a5
    800018e6:	e4bc                	sd	a5,72(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    800018e8:	17048493          	addi	s1,s1,368
    800018ec:	fd449de3          	bne	s1,s4,800018c6 <procinit+0x78>
  }
}
    800018f0:	70e2                	ld	ra,56(sp)
    800018f2:	7442                	ld	s0,48(sp)
    800018f4:	74a2                	ld	s1,40(sp)
    800018f6:	7902                	ld	s2,32(sp)
    800018f8:	69e2                	ld	s3,24(sp)
    800018fa:	6a42                	ld	s4,16(sp)
    800018fc:	6aa2                	ld	s5,8(sp)
    800018fe:	6b02                	ld	s6,0(sp)
    80001900:	6121                	addi	sp,sp,64
    80001902:	8082                	ret

0000000080001904 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001904:	1141                	addi	sp,sp,-16
    80001906:	e406                	sd	ra,8(sp)
    80001908:	e022                	sd	s0,0(sp)
    8000190a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    8000190c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000190e:	2501                	sext.w	a0,a0
    80001910:	60a2                	ld	ra,8(sp)
    80001912:	6402                	ld	s0,0(sp)
    80001914:	0141                	addi	sp,sp,16
    80001916:	8082                	ret

0000000080001918 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001918:	1141                	addi	sp,sp,-16
    8000191a:	e406                	sd	ra,8(sp)
    8000191c:	e022                	sd	s0,0(sp)
    8000191e:	0800                	addi	s0,sp,16
    80001920:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001922:	2781                	sext.w	a5,a5
    80001924:	079e                	slli	a5,a5,0x7
  return c;
}
    80001926:	00011517          	auipc	a0,0x11
    8000192a:	c8a50513          	addi	a0,a0,-886 # 800125b0 <cpus>
    8000192e:	953e                	add	a0,a0,a5
    80001930:	60a2                	ld	ra,8(sp)
    80001932:	6402                	ld	s0,0(sp)
    80001934:	0141                	addi	sp,sp,16
    80001936:	8082                	ret

0000000080001938 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    80001938:	1101                	addi	sp,sp,-32
    8000193a:	ec06                	sd	ra,24(sp)
    8000193c:	e822                	sd	s0,16(sp)
    8000193e:	e426                	sd	s1,8(sp)
    80001940:	1000                	addi	s0,sp,32
  push_off();
    80001942:	a9cff0ef          	jal	80000bde <push_off>
    80001946:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001948:	2781                	sext.w	a5,a5
    8000194a:	079e                	slli	a5,a5,0x7
    8000194c:	00011717          	auipc	a4,0x11
    80001950:	c3470713          	addi	a4,a4,-972 # 80012580 <pid_lock>
    80001954:	97ba                	add	a5,a5,a4
    80001956:	7b9c                	ld	a5,48(a5)
    80001958:	84be                	mv	s1,a5
  pop_off();
    8000195a:	afeff0ef          	jal	80000c58 <pop_off>
  return p;
}
    8000195e:	8526                	mv	a0,s1
    80001960:	60e2                	ld	ra,24(sp)
    80001962:	6442                	ld	s0,16(sp)
    80001964:	64a2                	ld	s1,8(sp)
    80001966:	6105                	addi	sp,sp,32
    80001968:	8082                	ret

000000008000196a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000196a:	7179                	addi	sp,sp,-48
    8000196c:	f406                	sd	ra,40(sp)
    8000196e:	f022                	sd	s0,32(sp)
    80001970:	ec26                	sd	s1,24(sp)
    80001972:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001974:	fc5ff0ef          	jal	80001938 <myproc>
    80001978:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    8000197a:	b26ff0ef          	jal	80000ca0 <release>

  if (__atomic_load_n(&first, __ATOMIC_ACQUIRE)) {
    8000197e:	00009797          	auipc	a5,0x9
    80001982:	a9a78793          	addi	a5,a5,-1382 # 8000a418 <first.1>
    80001986:	439c                	lw	a5,0(a5)
    80001988:	0230000f          	fence	r,rw
    8000198c:	2781                	sext.w	a5,a5
    8000198e:	c3a1                	beqz	a5,800019ce <forkret+0x64>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001990:	4505                	li	a0,1
    80001992:	531010ef          	jal	800036c2 <fsinit>

    // ensure other cores see first=0.
    __atomic_store_n(&first, 0, __ATOMIC_RELEASE);
    80001996:	00009797          	auipc	a5,0x9
    8000199a:	a8278793          	addi	a5,a5,-1406 # 8000a418 <first.1>
    8000199e:	0310000f          	fence	rw,w
    800019a2:	0007a023          	sw	zero,0(a5)

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019a6:	00005797          	auipc	a5,0x5
    800019aa:	7da78793          	addi	a5,a5,2010 # 80007180 <etext+0x180>
    800019ae:	fcf43823          	sd	a5,-48(s0)
    800019b2:	fc043c23          	sd	zero,-40(s0)
    800019b6:	fd040593          	addi	a1,s0,-48
    800019ba:	853e                	mv	a0,a5
    800019bc:	789020ef          	jal	80004944 <kexec>
    800019c0:	70bc                	ld	a5,96(s1)
    800019c2:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019c4:	70bc                	ld	a5,96(s1)
    800019c6:	7bb8                	ld	a4,112(a5)
    800019c8:	57fd                	li	a5,-1
    800019ca:	02f70d63          	beq	a4,a5,80001a04 <forkret+0x9a>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019ce:	3bb000ef          	jal	80002588 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019d2:	6ca8                	ld	a0,88(s1)
    800019d4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019d6:	04000737          	lui	a4,0x4000
    800019da:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019dc:	0732                	slli	a4,a4,0xc
    800019de:	00004797          	auipc	a5,0x4
    800019e2:	6be78793          	addi	a5,a5,1726 # 8000609c <userret>
    800019e6:	00004697          	auipc	a3,0x4
    800019ea:	61a68693          	addi	a3,a3,1562 # 80006000 <_trampoline>
    800019ee:	8f95                	sub	a5,a5,a3
    800019f0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800019f2:	577d                	li	a4,-1
    800019f4:	177e                	slli	a4,a4,0x3f
    800019f6:	8d59                	or	a0,a0,a4
    800019f8:	9782                	jalr	a5
}
    800019fa:	70a2                	ld	ra,40(sp)
    800019fc:	7402                	ld	s0,32(sp)
    800019fe:	64e2                	ld	s1,24(sp)
    80001a00:	6145                	addi	sp,sp,48
    80001a02:	8082                	ret
      panic("exec");
    80001a04:	00005517          	auipc	a0,0x5
    80001a08:	78450513          	addi	a0,a0,1924 # 80007188 <etext+0x188>
    80001a0c:	e29fe0ef          	jal	80000834 <panic>

0000000080001a10 <allocpid>:
{
    80001a10:	1101                	addi	sp,sp,-32
    80001a12:	ec06                	sd	ra,24(sp)
    80001a14:	e822                	sd	s0,16(sp)
    80001a16:	e426                	sd	s1,8(sp)
    80001a18:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a1a:	00011517          	auipc	a0,0x11
    80001a1e:	b6650513          	addi	a0,a0,-1178 # 80012580 <pid_lock>
    80001a22:	9f6ff0ef          	jal	80000c18 <acquire>
  pid = nextpid;
    80001a26:	00009797          	auipc	a5,0x9
    80001a2a:	9f678793          	addi	a5,a5,-1546 # 8000a41c <nextpid>
    80001a2e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a30:	0014871b          	addiw	a4,s1,1
    80001a34:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a36:	00011517          	auipc	a0,0x11
    80001a3a:	b4a50513          	addi	a0,a0,-1206 # 80012580 <pid_lock>
    80001a3e:	a62ff0ef          	jal	80000ca0 <release>
}
    80001a42:	8526                	mv	a0,s1
    80001a44:	60e2                	ld	ra,24(sp)
    80001a46:	6442                	ld	s0,16(sp)
    80001a48:	64a2                	ld	s1,8(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret

0000000080001a4e <proc_pagetable>:
{
    80001a4e:	1101                	addi	sp,sp,-32
    80001a50:	ec06                	sd	ra,24(sp)
    80001a52:	e822                	sd	s0,16(sp)
    80001a54:	e426                	sd	s1,8(sp)
    80001a56:	e04a                	sd	s2,0(sp)
    80001a58:	1000                	addi	s0,sp,32
    80001a5a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a5c:	f8eff0ef          	jal	800011ea <uvmcreate>
    80001a60:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a62:	cd05                	beqz	a0,80001a9a <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a64:	4729                	li	a4,10
    80001a66:	00004697          	auipc	a3,0x4
    80001a6a:	59a68693          	addi	a3,a3,1434 # 80006000 <_trampoline>
    80001a6e:	6605                	lui	a2,0x1
    80001a70:	040005b7          	lui	a1,0x4000
    80001a74:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a76:	05b2                	slli	a1,a1,0xc
    80001a78:	dcaff0ef          	jal	80001042 <mappages>
    80001a7c:	02054663          	bltz	a0,80001aa8 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001a80:	4719                	li	a4,6
    80001a82:	06093683          	ld	a3,96(s2)
    80001a86:	6605                	lui	a2,0x1
    80001a88:	020005b7          	lui	a1,0x2000
    80001a8c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a8e:	05b6                	slli	a1,a1,0xd
    80001a90:	8526                	mv	a0,s1
    80001a92:	db0ff0ef          	jal	80001042 <mappages>
    80001a96:	00054f63          	bltz	a0,80001ab4 <proc_pagetable+0x66>
}
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	60e2                	ld	ra,24(sp)
    80001a9e:	6442                	ld	s0,16(sp)
    80001aa0:	64a2                	ld	s1,8(sp)
    80001aa2:	6902                	ld	s2,0(sp)
    80001aa4:	6105                	addi	sp,sp,32
    80001aa6:	8082                	ret
    uvmfree(pagetable, 0);
    80001aa8:	4581                	li	a1,0
    80001aaa:	8526                	mv	a0,s1
    80001aac:	939ff0ef          	jal	800013e4 <uvmfree>
    return 0;
    80001ab0:	4481                	li	s1,0
    80001ab2:	b7e5                	j	80001a9a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ab4:	4681                	li	a3,0
    80001ab6:	4605                	li	a2,1
    80001ab8:	040005b7          	lui	a1,0x4000
    80001abc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001abe:	05b2                	slli	a1,a1,0xc
    80001ac0:	8526                	mv	a0,s1
    80001ac2:	f4eff0ef          	jal	80001210 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ac6:	4581                	li	a1,0
    80001ac8:	8526                	mv	a0,s1
    80001aca:	91bff0ef          	jal	800013e4 <uvmfree>
    return 0;
    80001ace:	4481                	li	s1,0
    80001ad0:	b7e9                	j	80001a9a <proc_pagetable+0x4c>

0000000080001ad2 <proc_freepagetable>:
{
    80001ad2:	1101                	addi	sp,sp,-32
    80001ad4:	ec06                	sd	ra,24(sp)
    80001ad6:	e822                	sd	s0,16(sp)
    80001ad8:	e426                	sd	s1,8(sp)
    80001ada:	e04a                	sd	s2,0(sp)
    80001adc:	1000                	addi	s0,sp,32
    80001ade:	84aa                	mv	s1,a0
    80001ae0:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae2:	4681                	li	a3,0
    80001ae4:	4605                	li	a2,1
    80001ae6:	040005b7          	lui	a1,0x4000
    80001aea:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aec:	05b2                	slli	a1,a1,0xc
    80001aee:	f22ff0ef          	jal	80001210 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001af2:	4681                	li	a3,0
    80001af4:	4605                	li	a2,1
    80001af6:	020005b7          	lui	a1,0x2000
    80001afa:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001afc:	05b6                	slli	a1,a1,0xd
    80001afe:	8526                	mv	a0,s1
    80001b00:	f10ff0ef          	jal	80001210 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b04:	85ca                	mv	a1,s2
    80001b06:	8526                	mv	a0,s1
    80001b08:	8ddff0ef          	jal	800013e4 <uvmfree>
}
    80001b0c:	60e2                	ld	ra,24(sp)
    80001b0e:	6442                	ld	s0,16(sp)
    80001b10:	64a2                	ld	s1,8(sp)
    80001b12:	6902                	ld	s2,0(sp)
    80001b14:	6105                	addi	sp,sp,32
    80001b16:	8082                	ret

0000000080001b18 <freeproc>:
{
    80001b18:	1101                	addi	sp,sp,-32
    80001b1a:	ec06                	sd	ra,24(sp)
    80001b1c:	e822                	sd	s0,16(sp)
    80001b1e:	e426                	sd	s1,8(sp)
    80001b20:	1000                	addi	s0,sp,32
    80001b22:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b24:	7128                	ld	a0,96(a0)
    80001b26:	c119                	beqz	a0,80001b2c <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b28:	efffe0ef          	jal	80000a26 <kfree>
  p->trapframe = 0;
    80001b2c:	0604b023          	sd	zero,96(s1)
  if (p->pagetable)
    80001b30:	6ca8                	ld	a0,88(s1)
    80001b32:	c501                	beqz	a0,80001b3a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b34:	68ac                	ld	a1,80(s1)
    80001b36:	f9dff0ef          	jal	80001ad2 <proc_freepagetable>
  p->pagetable = 0;
    80001b3a:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001b3e:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001b42:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001b46:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001b4a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b4e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b52:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b56:	0004ac23          	sw	zero,24(s1)
}
    80001b5a:	60e2                	ld	ra,24(sp)
    80001b5c:	6442                	ld	s0,16(sp)
    80001b5e:	64a2                	ld	s1,8(sp)
    80001b60:	6105                	addi	sp,sp,32
    80001b62:	8082                	ret

0000000080001b64 <allocproc>:
{
    80001b64:	1101                	addi	sp,sp,-32
    80001b66:	ec06                	sd	ra,24(sp)
    80001b68:	e822                	sd	s0,16(sp)
    80001b6a:	e426                	sd	s1,8(sp)
    80001b6c:	e04a                	sd	s2,0(sp)
    80001b6e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b70:	00011497          	auipc	s1,0x11
    80001b74:	e4048493          	addi	s1,s1,-448 # 800129b0 <proc>
    80001b78:	00017917          	auipc	s2,0x17
    80001b7c:	a3890913          	addi	s2,s2,-1480 # 800185b0 <tickslock>
    acquire(&p->lock);
    80001b80:	8526                	mv	a0,s1
    80001b82:	896ff0ef          	jal	80000c18 <acquire>
    if (p->state == UNUSED) {
    80001b86:	4c9c                	lw	a5,24(s1)
    80001b88:	cb91                	beqz	a5,80001b9c <allocproc+0x38>
      release(&p->lock);
    80001b8a:	8526                	mv	a0,s1
    80001b8c:	914ff0ef          	jal	80000ca0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b90:	17048493          	addi	s1,s1,368
    80001b94:	ff2496e3          	bne	s1,s2,80001b80 <allocproc+0x1c>
  return 0;
    80001b98:	4481                	li	s1,0
    80001b9a:	a0b1                	j	80001be6 <allocproc+0x82>
  p->pid = allocpid();
    80001b9c:	e75ff0ef          	jal	80001a10 <allocpid>
    80001ba0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ba2:	4785                	li	a5,1
    80001ba4:	cc9c                	sw	a5,24(s1)
  p->tickets = 1;  // dar um ticket para todas as novas tarefas
    80001ba6:	d8dc                	sw	a5,52(s1)
  p->contator = 0;
    80001ba8:	0204ac23          	sw	zero,56(s1)
  p->last_lottery = -1;  // nao sorteado
    80001bac:	57fd                	li	a5,-1
    80001bae:	dcdc                	sw	a5,60(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bb0:	f5ffe0ef          	jal	80000b0e <kalloc>
    80001bb4:	892a                	mv	s2,a0
    80001bb6:	f0a8                	sd	a0,96(s1)
    80001bb8:	cd15                	beqz	a0,80001bf4 <allocproc+0x90>
  p->pagetable = proc_pagetable(p);
    80001bba:	8526                	mv	a0,s1
    80001bbc:	e93ff0ef          	jal	80001a4e <proc_pagetable>
    80001bc0:	892a                	mv	s2,a0
    80001bc2:	eca8                	sd	a0,88(s1)
  if (p->pagetable == 0) {
    80001bc4:	c121                	beqz	a0,80001c04 <allocproc+0xa0>
  memset(&p->context, 0, sizeof(p->context));
    80001bc6:	07000613          	li	a2,112
    80001bca:	4581                	li	a1,0
    80001bcc:	06848513          	addi	a0,s1,104
    80001bd0:	908ff0ef          	jal	80000cd8 <memset>
  p->context.ra = (uint64)forkret;
    80001bd4:	00000797          	auipc	a5,0x0
    80001bd8:	d9678793          	addi	a5,a5,-618 # 8000196a <forkret>
    80001bdc:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bde:	64bc                	ld	a5,72(s1)
    80001be0:	6705                	lui	a4,0x1
    80001be2:	97ba                	add	a5,a5,a4
    80001be4:	f8bc                	sd	a5,112(s1)
}
    80001be6:	8526                	mv	a0,s1
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret
    freeproc(p);
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	f23ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001bfa:	8526                	mv	a0,s1
    80001bfc:	8a4ff0ef          	jal	80000ca0 <release>
    return 0;
    80001c00:	84ca                	mv	s1,s2
    80001c02:	b7d5                	j	80001be6 <allocproc+0x82>
    freeproc(p);
    80001c04:	8526                	mv	a0,s1
    80001c06:	f13ff0ef          	jal	80001b18 <freeproc>
    release(&p->lock);
    80001c0a:	8526                	mv	a0,s1
    80001c0c:	894ff0ef          	jal	80000ca0 <release>
    return 0;
    80001c10:	84ca                	mv	s1,s2
    80001c12:	bfd1                	j	80001be6 <allocproc+0x82>

0000000080001c14 <userinit>:
{
    80001c14:	1101                	addi	sp,sp,-32
    80001c16:	ec06                	sd	ra,24(sp)
    80001c18:	e822                	sd	s0,16(sp)
    80001c1a:	e426                	sd	s1,8(sp)
    80001c1c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c1e:	f47ff0ef          	jal	80001b64 <allocproc>
    80001c22:	84aa                	mv	s1,a0
  initproc = p;
    80001c24:	00009797          	auipc	a5,0x9
    80001c28:	82a7ba23          	sd	a0,-1996(a5) # 8000a458 <initproc>
  p->cwd = namei("/");
    80001c2c:	00005517          	auipc	a0,0x5
    80001c30:	56450513          	addi	a0,a0,1380 # 80007190 <etext+0x190>
    80001c34:	7df010ef          	jal	80003c12 <namei>
    80001c38:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001c3c:	478d                	li	a5,3
    80001c3e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c40:	8526                	mv	a0,s1
    80001c42:	85eff0ef          	jal	80000ca0 <release>
}
    80001c46:	60e2                	ld	ra,24(sp)
    80001c48:	6442                	ld	s0,16(sp)
    80001c4a:	64a2                	ld	s1,8(sp)
    80001c4c:	6105                	addi	sp,sp,32
    80001c4e:	8082                	ret

0000000080001c50 <growproc>:
{
    80001c50:	1101                	addi	sp,sp,-32
    80001c52:	ec06                	sd	ra,24(sp)
    80001c54:	e822                	sd	s0,16(sp)
    80001c56:	e426                	sd	s1,8(sp)
    80001c58:	e04a                	sd	s2,0(sp)
    80001c5a:	1000                	addi	s0,sp,32
    80001c5c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c5e:	cdbff0ef          	jal	80001938 <myproc>
    80001c62:	892a                	mv	s2,a0
  sz = p->sz;
    80001c64:	692c                	ld	a1,80(a0)
  if (n > 0) {
    80001c66:	02905963          	blez	s1,80001c98 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c6a:	00b48633          	add	a2,s1,a1
    80001c6e:	020007b7          	lui	a5,0x2000
    80001c72:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c74:	07b6                	slli	a5,a5,0xd
    80001c76:	02c7ea63          	bltu	a5,a2,80001caa <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c7a:	4691                	li	a3,4
    80001c7c:	6d28                	ld	a0,88(a0)
    80001c7e:	e60ff0ef          	jal	800012de <uvmalloc>
    80001c82:	85aa                	mv	a1,a0
    80001c84:	c50d                	beqz	a0,80001cae <growproc+0x5e>
  p->sz = sz;
    80001c86:	04b93823          	sd	a1,80(s2)
  return 0;
    80001c8a:	4501                	li	a0,0
}
    80001c8c:	60e2                	ld	ra,24(sp)
    80001c8e:	6442                	ld	s0,16(sp)
    80001c90:	64a2                	ld	s1,8(sp)
    80001c92:	6902                	ld	s2,0(sp)
    80001c94:	6105                	addi	sp,sp,32
    80001c96:	8082                	ret
  } else if (n < 0) {
    80001c98:	fe04d7e3          	bgez	s1,80001c86 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c9c:	00b48633          	add	a2,s1,a1
    80001ca0:	6d28                	ld	a0,88(a0)
    80001ca2:	df8ff0ef          	jal	8000129a <uvmdealloc>
    80001ca6:	85aa                	mv	a1,a0
    80001ca8:	bff9                	j	80001c86 <growproc+0x36>
      return -1;
    80001caa:	557d                	li	a0,-1
    80001cac:	b7c5                	j	80001c8c <growproc+0x3c>
      return -1;
    80001cae:	557d                	li	a0,-1
    80001cb0:	bff1                	j	80001c8c <growproc+0x3c>

0000000080001cb2 <kfork>:
{
    80001cb2:	7139                	addi	sp,sp,-64
    80001cb4:	fc06                	sd	ra,56(sp)
    80001cb6:	f822                	sd	s0,48(sp)
    80001cb8:	f426                	sd	s1,40(sp)
    80001cba:	e456                	sd	s5,8(sp)
    80001cbc:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cbe:	c7bff0ef          	jal	80001938 <myproc>
    80001cc2:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cc4:	ea1ff0ef          	jal	80001b64 <allocproc>
    80001cc8:	0e050e63          	beqz	a0,80001dc4 <kfork+0x112>
    80001ccc:	e852                	sd	s4,16(sp)
    80001cce:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cd0:	050ab603          	ld	a2,80(s5)
    80001cd4:	6d2c                	ld	a1,88(a0)
    80001cd6:	058ab503          	ld	a0,88(s5)
    80001cda:	f3cff0ef          	jal	80001416 <uvmcopy>
    80001cde:	04054863          	bltz	a0,80001d2e <kfork+0x7c>
    80001ce2:	f04a                	sd	s2,32(sp)
    80001ce4:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001ce6:	050ab783          	ld	a5,80(s5)
    80001cea:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001cee:	060ab683          	ld	a3,96(s5)
    80001cf2:	87b6                	mv	a5,a3
    80001cf4:	060a3703          	ld	a4,96(s4)
    80001cf8:	12068693          	addi	a3,a3,288
    80001cfc:	6388                	ld	a0,0(a5)
    80001cfe:	678c                	ld	a1,8(a5)
    80001d00:	6b90                	ld	a2,16(a5)
    80001d02:	e308                	sd	a0,0(a4)
    80001d04:	e70c                	sd	a1,8(a4)
    80001d06:	eb10                	sd	a2,16(a4)
    80001d08:	6f90                	ld	a2,24(a5)
    80001d0a:	ef10                	sd	a2,24(a4)
    80001d0c:	02078793          	addi	a5,a5,32
    80001d10:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d14:	fed794e3          	bne	a5,a3,80001cfc <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d18:	060a3783          	ld	a5,96(s4)
    80001d1c:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d20:	0d8a8493          	addi	s1,s5,216
    80001d24:	0d8a0913          	addi	s2,s4,216
    80001d28:	158a8993          	addi	s3,s5,344
    80001d2c:	a015                	j	80001d50 <kfork+0x9e>
    freeproc(np);
    80001d2e:	8552                	mv	a0,s4
    80001d30:	de9ff0ef          	jal	80001b18 <freeproc>
    release(&np->lock);
    80001d34:	8552                	mv	a0,s4
    80001d36:	f6bfe0ef          	jal	80000ca0 <release>
    np->tickets = p->tickets; //copia os tickets do pai para o filho
    80001d3a:	034aa783          	lw	a5,52(s5)
    80001d3e:	02fa2a23          	sw	a5,52(s4)
    return -1;
    80001d42:	54fd                	li	s1,-1
    80001d44:	6a42                	ld	s4,16(sp)
    80001d46:	a885                	j	80001db6 <kfork+0x104>
  for (i = 0; i < NOFILE; i++)
    80001d48:	04a1                	addi	s1,s1,8
    80001d4a:	0921                	addi	s2,s2,8
    80001d4c:	01348963          	beq	s1,s3,80001d5e <kfork+0xac>
    if (p->ofile[i])
    80001d50:	6088                	ld	a0,0(s1)
    80001d52:	d97d                	beqz	a0,80001d48 <kfork+0x96>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d54:	510020ef          	jal	80004264 <filedup>
    80001d58:	00a93023          	sd	a0,0(s2)
    80001d5c:	b7f5                	j	80001d48 <kfork+0x96>
  np->cwd = idup(p->cwd);
    80001d5e:	158ab503          	ld	a0,344(s5)
    80001d62:	5ee010ef          	jal	80003350 <idup>
    80001d66:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d6a:	4641                	li	a2,16
    80001d6c:	160a8593          	addi	a1,s5,352
    80001d70:	160a0513          	addi	a0,s4,352
    80001d74:	8b8ff0ef          	jal	80000e2c <safestrcpy>
  pid = np->pid;
    80001d78:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d7c:	8552                	mv	a0,s4
    80001d7e:	f23fe0ef          	jal	80000ca0 <release>
  acquire(&wait_lock);
    80001d82:	00011517          	auipc	a0,0x11
    80001d86:	81650513          	addi	a0,a0,-2026 # 80012598 <wait_lock>
    80001d8a:	e8ffe0ef          	jal	80000c18 <acquire>
  np->parent = p;
    80001d8e:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80001d92:	00011517          	auipc	a0,0x11
    80001d96:	80650513          	addi	a0,a0,-2042 # 80012598 <wait_lock>
    80001d9a:	f07fe0ef          	jal	80000ca0 <release>
  acquire(&np->lock);
    80001d9e:	8552                	mv	a0,s4
    80001da0:	e79fe0ef          	jal	80000c18 <acquire>
  np->state = RUNNABLE;
    80001da4:	478d                	li	a5,3
    80001da6:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001daa:	8552                	mv	a0,s4
    80001dac:	ef5fe0ef          	jal	80000ca0 <release>
  return pid;
    80001db0:	7902                	ld	s2,32(sp)
    80001db2:	69e2                	ld	s3,24(sp)
    80001db4:	6a42                	ld	s4,16(sp)
}
    80001db6:	8526                	mv	a0,s1
    80001db8:	70e2                	ld	ra,56(sp)
    80001dba:	7442                	ld	s0,48(sp)
    80001dbc:	74a2                	ld	s1,40(sp)
    80001dbe:	6aa2                	ld	s5,8(sp)
    80001dc0:	6121                	addi	sp,sp,64
    80001dc2:	8082                	ret
    return -1;
    80001dc4:	54fd                	li	s1,-1
    80001dc6:	bfc5                	j	80001db6 <kfork+0x104>

0000000080001dc8 <settickets>:
  if(number < 1)
    80001dc8:	02a05163          	blez	a0,80001dea <settickets+0x22>
{
    80001dcc:	1101                	addi	sp,sp,-32
    80001dce:	ec06                	sd	ra,24(sp)
    80001dd0:	e822                	sd	s0,16(sp)
    80001dd2:	e426                	sd	s1,8(sp)
    80001dd4:	1000                	addi	s0,sp,32
    80001dd6:	84aa                	mv	s1,a0
  myproc()->tickets = number;
    80001dd8:	b61ff0ef          	jal	80001938 <myproc>
    80001ddc:	d944                	sw	s1,52(a0)
  return 0;
    80001dde:	4501                	li	a0,0
}
    80001de0:	60e2                	ld	ra,24(sp)
    80001de2:	6442                	ld	s0,16(sp)
    80001de4:	64a2                	ld	s1,8(sp)
    80001de6:	6105                	addi	sp,sp,32
    80001de8:	8082                	ret
    return -1;                       //funcao que altera o numero de tickets, se for maior quer um altera, se for menor que 1 ele nao deixa alterar
    80001dea:	557d                	li	a0,-1
}
    80001dec:	8082                	ret

0000000080001dee <getcontator>:
{
    80001dee:	1141                	addi	sp,sp,-16
    80001df0:	e406                	sd	ra,8(sp)
    80001df2:	e022                	sd	s0,0(sp)
    80001df4:	0800                	addi	s0,sp,16
  return myproc()->contator;         // so para conseguir ver o contator é necessario criar uma funçao...isso esta ficando longo
    80001df6:	b43ff0ef          	jal	80001938 <myproc>
}
    80001dfa:	5d08                	lw	a0,56(a0)
    80001dfc:	60a2                	ld	ra,8(sp)
    80001dfe:	6402                	ld	s0,0(sp)
    80001e00:	0141                	addi	sp,sp,16
    80001e02:	8082                	ret

0000000080001e04 <getlastlottery>:
{
    80001e04:	1141                	addi	sp,sp,-16
    80001e06:	e406                	sd	ra,8(sp)
    80001e08:	e022                	sd	s0,0(sp)
    80001e0a:	0800                	addi	s0,sp,16
  return myproc()->last_lottery; 	// pegar o numero sorteado
    80001e0c:	b2dff0ef          	jal	80001938 <myproc>
}
    80001e10:	5d48                	lw	a0,60(a0)
    80001e12:	60a2                	ld	ra,8(sp)
    80001e14:	6402                	ld	s0,0(sp)
    80001e16:	0141                	addi	sp,sp,16
    80001e18:	8082                	ret

0000000080001e1a <gettickets>:
{
    80001e1a:	1141                	addi	sp,sp,-16
    80001e1c:	e406                	sd	ra,8(sp)
    80001e1e:	e022                	sd	s0,0(sp)
    80001e20:	0800                	addi	s0,sp,16
  return myproc()->tickets;             //pegar o ticket
    80001e22:	b17ff0ef          	jal	80001938 <myproc>
}
    80001e26:	5948                	lw	a0,52(a0)
    80001e28:	60a2                	ld	ra,8(sp)
    80001e2a:	6402                	ld	s0,0(sp)
    80001e2c:	0141                	addi	sp,sp,16
    80001e2e:	8082                	ret

0000000080001e30 <scheduler>:
{
    80001e30:	711d                	addi	sp,sp,-96
    80001e32:	ec86                	sd	ra,88(sp)
    80001e34:	e8a2                	sd	s0,80(sp)
    80001e36:	e4a6                	sd	s1,72(sp)
    80001e38:	e0ca                	sd	s2,64(sp)
    80001e3a:	fc4e                	sd	s3,56(sp)
    80001e3c:	f852                	sd	s4,48(sp)
    80001e3e:	f456                	sd	s5,40(sp)
    80001e40:	f05a                	sd	s6,32(sp)
    80001e42:	ec5e                	sd	s7,24(sp)
    80001e44:	e862                	sd	s8,16(sp)
    80001e46:	e466                	sd	s9,8(sp)
    80001e48:	1080                	addi	s0,sp,96
    80001e4a:	8792                	mv	a5,tp
  int id = r_tp();
    80001e4c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e4e:	00779b13          	slli	s6,a5,0x7
    80001e52:	00010717          	auipc	a4,0x10
    80001e56:	72e70713          	addi	a4,a4,1838 # 80012580 <pid_lock>
    80001e5a:	975a                	add	a4,a4,s6
    80001e5c:	02073823          	sd	zero,48(a4)
            swtch(&c->context, &p->context);
    80001e60:	00010717          	auipc	a4,0x10
    80001e64:	75870713          	addi	a4,a4,1880 # 800125b8 <cpus+0x8>
    80001e68:	9b3a                	add	s6,s6,a4
      if (p->state == RUNNABLE)
    80001e6a:	490d                	li	s2,3
    for (p = proc; p < &proc[NPROC]; p++) {   // Percorre todos os processos existentes no xv6.
    80001e6c:	00016997          	auipc	s3,0x16
    80001e70:	74498993          	addi	s3,s3,1860 # 800185b0 <tickslock>
            p->state = RUNNING; //ganha acesso a cpu
    80001e74:	4c11                	li	s8,4
            c->proc = p;
    80001e76:	00010b97          	auipc	s7,0x10
    80001e7a:	70ab8b93          	addi	s7,s7,1802 # 80012580 <pid_lock>
    80001e7e:	079e                	slli	a5,a5,0x7
    80001e80:	00fb8ab3          	add	s5,s7,a5
    80001e84:	a869                	j	80001f1e <scheduler+0xee>
      release(&p->lock);
    80001e86:	8526                	mv	a0,s1
    80001e88:	e19fe0ef          	jal	80000ca0 <release>
    for (p = proc; p < &proc[NPROC]; p++) {   // Percorre todos os processos existentes no xv6.
    80001e8c:	17048493          	addi	s1,s1,368
    80001e90:	01348c63          	beq	s1,s3,80001ea8 <scheduler+0x78>
      acquire(&p->lock);                      //bloqueia o processo de ser modificado
    80001e94:	8526                	mv	a0,s1
    80001e96:	d83fe0ef          	jal	80000c18 <acquire>
      if (p->state == RUNNABLE)
    80001e9a:	4c9c                	lw	a5,24(s1)
    80001e9c:	ff2795e3          	bne	a5,s2,80001e86 <scheduler+0x56>
        total += p->tickets; 
    80001ea0:	58dc                	lw	a5,52(s1)
    80001ea2:	01978cbb          	addw	s9,a5,s9
    80001ea6:	b7c5                	j	80001e86 <scheduler+0x56>
    if (total > 0) {
    80001ea8:	07905963          	blez	s9,80001f1a <scheduler+0xea>
      int winner = random() % total;
    80001eac:	cbdfe0ef          	jal	80000b68 <random>
    80001eb0:	03957cb3          	remu	s9,a0,s9
    80001eb4:	2c81                	sext.w	s9,s9
      int count = 0;
    80001eb6:	4a01                	li	s4,0
      for (p = proc; p < &proc[NPROC]; p++) {
    80001eb8:	00011497          	auipc	s1,0x11
    80001ebc:	af848493          	addi	s1,s1,-1288 # 800129b0 <proc>
    80001ec0:	a801                	j	80001ed0 <scheduler+0xa0>
        release(&p->lock);
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	dddfe0ef          	jal	80000ca0 <release>
      for (p = proc; p < &proc[NPROC]; p++) {
    80001ec8:	17048493          	addi	s1,s1,368
    80001ecc:	05348763          	beq	s1,s3,80001f1a <scheduler+0xea>
        acquire(&p->lock);
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	d47fe0ef          	jal	80000c18 <acquire>
        if (p->state == RUNNABLE) {
    80001ed6:	4c9c                	lw	a5,24(s1)
    80001ed8:	ff2795e3          	bne	a5,s2,80001ec2 <scheduler+0x92>
          count += p->tickets;
    80001edc:	58dc                	lw	a5,52(s1)
    80001ede:	01478a3b          	addw	s4,a5,s4
          if (count > winner) {
    80001ee2:	ff4cd0e3          	bge	s9,s4,80001ec2 <scheduler+0x92>
p->last_lottery = winner;
    80001ee6:	0394ae23          	sw	s9,60(s1)
p->contator++;
    80001eea:	5c9c                	lw	a5,56(s1)
    80001eec:	2785                	addiw	a5,a5,1
    80001eee:	dc9c                	sw	a5,56(s1)
            p->state = RUNNING; //ganha acesso a cpu
    80001ef0:	0184ac23          	sw	s8,24(s1)
            c->proc = p;
    80001ef4:	029ab823          	sd	s1,48(s5)
            swtch(&c->context, &p->context);
    80001ef8:	06848593          	addi	a1,s1,104
    80001efc:	855a                	mv	a0,s6
    80001efe:	5e0000ef          	jal	800024de <swtch>
    80001f02:	8792                	mv	a5,tp
            mycpu()->intena = 0;
    80001f04:	2781                	sext.w	a5,a5
    80001f06:	079e                	slli	a5,a5,0x7
    80001f08:	97de                	add	a5,a5,s7
    80001f0a:	0a07a623          	sw	zero,172(a5)
            c->proc = 0;
    80001f0e:	020ab823          	sd	zero,48(s5)
            release(&p->lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	d8dfe0ef          	jal	80000ca0 <release>
    if (found == 0) {
    80001f18:	a019                	j	80001f1e <scheduler+0xee>
      asm volatile("wfi");
    80001f1a:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001f1e:	10016073          	csrsi	sstatus,2
    int total = 0;
    80001f22:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {   // Percorre todos os processos existentes no xv6.
    80001f24:	00011497          	auipc	s1,0x11
    80001f28:	a8c48493          	addi	s1,s1,-1396 # 800129b0 <proc>
    80001f2c:	b7a5                	j	80001e94 <scheduler+0x64>

0000000080001f2e <sched>:
{
    80001f2e:	7179                	addi	sp,sp,-48
    80001f30:	f406                	sd	ra,40(sp)
    80001f32:	f022                	sd	s0,32(sp)
    80001f34:	ec26                	sd	s1,24(sp)
    80001f36:	e84a                	sd	s2,16(sp)
    80001f38:	e44e                	sd	s3,8(sp)
    80001f3a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f3c:	9fdff0ef          	jal	80001938 <myproc>
    80001f40:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001f42:	c71fe0ef          	jal	80000bb2 <holding>
    80001f46:	c935                	beqz	a0,80001fba <sched+0x8c>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f48:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001f4a:	2781                	sext.w	a5,a5
    80001f4c:	079e                	slli	a5,a5,0x7
    80001f4e:	00010717          	auipc	a4,0x10
    80001f52:	63270713          	addi	a4,a4,1586 # 80012580 <pid_lock>
    80001f56:	97ba                	add	a5,a5,a4
    80001f58:	0a87a703          	lw	a4,168(a5)
    80001f5c:	4785                	li	a5,1
    80001f5e:	06f71463          	bne	a4,a5,80001fc6 <sched+0x98>
  if (p->state == RUNNING)
    80001f62:	4c98                	lw	a4,24(s1)
    80001f64:	4791                	li	a5,4
    80001f66:	06f70663          	beq	a4,a5,80001fd2 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001f6a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f6e:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001f70:	e7bd                	bnez	a5,80001fde <sched+0xb0>
  asm volatile("mv %0, tp" : "=r"(x));
    80001f72:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f74:	00010917          	auipc	s2,0x10
    80001f78:	60c90913          	addi	s2,s2,1548 # 80012580 <pid_lock>
    80001f7c:	2781                	sext.w	a5,a5
    80001f7e:	079e                	slli	a5,a5,0x7
    80001f80:	97ca                	add	a5,a5,s2
    80001f82:	0ac7a983          	lw	s3,172(a5)
    80001f86:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f88:	2781                	sext.w	a5,a5
    80001f8a:	079e                	slli	a5,a5,0x7
    80001f8c:	07a1                	addi	a5,a5,8
    80001f8e:	00010597          	auipc	a1,0x10
    80001f92:	62258593          	addi	a1,a1,1570 # 800125b0 <cpus>
    80001f96:	95be                	add	a1,a1,a5
    80001f98:	06848513          	addi	a0,s1,104
    80001f9c:	542000ef          	jal	800024de <swtch>
    80001fa0:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fa2:	2781                	sext.w	a5,a5
    80001fa4:	079e                	slli	a5,a5,0x7
    80001fa6:	993e                	add	s2,s2,a5
    80001fa8:	0b392623          	sw	s3,172(s2)
}
    80001fac:	70a2                	ld	ra,40(sp)
    80001fae:	7402                	ld	s0,32(sp)
    80001fb0:	64e2                	ld	s1,24(sp)
    80001fb2:	6942                	ld	s2,16(sp)
    80001fb4:	69a2                	ld	s3,8(sp)
    80001fb6:	6145                	addi	sp,sp,48
    80001fb8:	8082                	ret
    panic("sched p->lock");
    80001fba:	00005517          	auipc	a0,0x5
    80001fbe:	1de50513          	addi	a0,a0,478 # 80007198 <etext+0x198>
    80001fc2:	873fe0ef          	jal	80000834 <panic>
    panic("sched locks");
    80001fc6:	00005517          	auipc	a0,0x5
    80001fca:	1e250513          	addi	a0,a0,482 # 800071a8 <etext+0x1a8>
    80001fce:	867fe0ef          	jal	80000834 <panic>
    panic("sched RUNNING");
    80001fd2:	00005517          	auipc	a0,0x5
    80001fd6:	1e650513          	addi	a0,a0,486 # 800071b8 <etext+0x1b8>
    80001fda:	85bfe0ef          	jal	80000834 <panic>
    panic("sched interruptible");
    80001fde:	00005517          	auipc	a0,0x5
    80001fe2:	1ea50513          	addi	a0,a0,490 # 800071c8 <etext+0x1c8>
    80001fe6:	84ffe0ef          	jal	80000834 <panic>

0000000080001fea <yield>:
{
    80001fea:	1101                	addi	sp,sp,-32
    80001fec:	ec06                	sd	ra,24(sp)
    80001fee:	e822                	sd	s0,16(sp)
    80001ff0:	e426                	sd	s1,8(sp)
    80001ff2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ff4:	945ff0ef          	jal	80001938 <myproc>
    80001ff8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ffa:	c1ffe0ef          	jal	80000c18 <acquire>
  p->state = RUNNABLE;
    80001ffe:	478d                	li	a5,3
    80002000:	cc9c                	sw	a5,24(s1)
  sched();
    80002002:	f2dff0ef          	jal	80001f2e <sched>
  release(&p->lock);
    80002006:	8526                	mv	a0,s1
    80002008:	c99fe0ef          	jal	80000ca0 <release>
}
    8000200c:	60e2                	ld	ra,24(sp)
    8000200e:	6442                	ld	s0,16(sp)
    80002010:	64a2                	ld	s1,8(sp)
    80002012:	6105                	addi	sp,sp,32
    80002014:	8082                	ret

0000000080002016 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80002016:	1101                	addi	sp,sp,-32
    80002018:	ec06                	sd	ra,24(sp)
    8000201a:	e822                	sd	s0,16(sp)
    8000201c:	e426                	sd	s1,8(sp)
    8000201e:	e04a                	sd	s2,0(sp)
    80002020:	1000                	addi	s0,sp,32
    80002022:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002024:	915ff0ef          	jal	80001938 <myproc>
    80002028:	892a                	mv	s2,a0

  acquire(&p->lock);
    8000202a:	beffe0ef          	jal	80000c18 <acquire>
  if (chan == 0)
    8000202e:	cc81                	beqz	s1,80002046 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80002030:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80002034:	854a                	mv	a0,s2
    80002036:	c6bfe0ef          	jal	80000ca0 <release>
}
    8000203a:	60e2                	ld	ra,24(sp)
    8000203c:	6442                	ld	s0,16(sp)
    8000203e:	64a2                	ld	s1,8(sp)
    80002040:	6902                	ld	s2,0(sp)
    80002042:	6105                	addi	sp,sp,32
    80002044:	8082                	ret
    panic("sleep_prepare: zero chan");
    80002046:	00005517          	auipc	a0,0x5
    8000204a:	19a50513          	addi	a0,a0,410 # 800071e0 <etext+0x1e0>
    8000204e:	fe6fe0ef          	jal	80000834 <panic>

0000000080002052 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80002052:	1101                	addi	sp,sp,-32
    80002054:	ec06                	sd	ra,24(sp)
    80002056:	e822                	sd	s0,16(sp)
    80002058:	e426                	sd	s1,8(sp)
    8000205a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000205c:	8ddff0ef          	jal	80001938 <myproc>
    80002060:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80002062:	bb7fe0ef          	jal	80000c18 <acquire>
  if (p->chan != 0) {
    80002066:	709c                	ld	a5,32(s1)
    80002068:	c789                	beqz	a5,80002072 <sleep+0x20>
    p->state = SLEEPING;
    8000206a:	4789                	li	a5,2
    8000206c:	cc9c                	sw	a5,24(s1)
    sched();
    8000206e:	ec1ff0ef          	jal	80001f2e <sched>
  }
  release(&p->lock);
    80002072:	8526                	mv	a0,s1
    80002074:	c2dfe0ef          	jal	80000ca0 <release>
}
    80002078:	60e2                	ld	ra,24(sp)
    8000207a:	6442                	ld	s0,16(sp)
    8000207c:	64a2                	ld	s1,8(sp)
    8000207e:	6105                	addi	sp,sp,32
    80002080:	8082                	ret

0000000080002082 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80002082:	7139                	addi	sp,sp,-64
    80002084:	fc06                	sd	ra,56(sp)
    80002086:	f822                	sd	s0,48(sp)
    80002088:	f426                	sd	s1,40(sp)
    8000208a:	f04a                	sd	s2,32(sp)
    8000208c:	ec4e                	sd	s3,24(sp)
    8000208e:	e852                	sd	s4,16(sp)
    80002090:	e456                	sd	s5,8(sp)
    80002092:	0080                	addi	s0,sp,64
    80002094:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002096:	00011497          	auipc	s1,0x11
    8000209a:	91a48493          	addi	s1,s1,-1766 # 800129b0 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    8000209e:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800020a0:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800020a2:	00016997          	auipc	s3,0x16
    800020a6:	50e98993          	addi	s3,s3,1294 # 800185b0 <tickslock>
    800020aa:	a801                	j	800020ba <wakeup+0x38>
      }
    }
    release(&p->lock);
    800020ac:	8526                	mv	a0,s1
    800020ae:	bf3fe0ef          	jal	80000ca0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020b2:	17048493          	addi	s1,s1,368
    800020b6:	03348063          	beq	s1,s3,800020d6 <wakeup+0x54>
    acquire(&p->lock);
    800020ba:	8526                	mv	a0,s1
    800020bc:	b5dfe0ef          	jal	80000c18 <acquire>
    if (p->chan == chan) {
    800020c0:	709c                	ld	a5,32(s1)
    800020c2:	ff2795e3          	bne	a5,s2,800020ac <wakeup+0x2a>
      p->chan = 0;
    800020c6:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    800020ca:	4c9c                	lw	a5,24(s1)
    800020cc:	ff4790e3          	bne	a5,s4,800020ac <wakeup+0x2a>
        p->state = RUNNABLE;
    800020d0:	0154ac23          	sw	s5,24(s1)
    800020d4:	bfe1                	j	800020ac <wakeup+0x2a>
  }
}
    800020d6:	70e2                	ld	ra,56(sp)
    800020d8:	7442                	ld	s0,48(sp)
    800020da:	74a2                	ld	s1,40(sp)
    800020dc:	7902                	ld	s2,32(sp)
    800020de:	69e2                	ld	s3,24(sp)
    800020e0:	6a42                	ld	s4,16(sp)
    800020e2:	6aa2                	ld	s5,8(sp)
    800020e4:	6121                	addi	sp,sp,64
    800020e6:	8082                	ret

00000000800020e8 <reparent>:
{
    800020e8:	7179                	addi	sp,sp,-48
    800020ea:	f406                	sd	ra,40(sp)
    800020ec:	f022                	sd	s0,32(sp)
    800020ee:	ec26                	sd	s1,24(sp)
    800020f0:	e84a                	sd	s2,16(sp)
    800020f2:	e44e                	sd	s3,8(sp)
    800020f4:	e052                	sd	s4,0(sp)
    800020f6:	1800                	addi	s0,sp,48
    800020f8:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800020fa:	00011497          	auipc	s1,0x11
    800020fe:	8b648493          	addi	s1,s1,-1866 # 800129b0 <proc>
      pp->parent = initproc;
    80002102:	00008a17          	auipc	s4,0x8
    80002106:	356a0a13          	addi	s4,s4,854 # 8000a458 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000210a:	00016997          	auipc	s3,0x16
    8000210e:	4a698993          	addi	s3,s3,1190 # 800185b0 <tickslock>
    80002112:	a029                	j	8000211c <reparent+0x34>
    80002114:	17048493          	addi	s1,s1,368
    80002118:	01348b63          	beq	s1,s3,8000212e <reparent+0x46>
    if (pp->parent == p) {
    8000211c:	60bc                	ld	a5,64(s1)
    8000211e:	ff279be3          	bne	a5,s2,80002114 <reparent+0x2c>
      pp->parent = initproc;
    80002122:	000a3503          	ld	a0,0(s4)
    80002126:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002128:	f5bff0ef          	jal	80002082 <wakeup>
    8000212c:	b7e5                	j	80002114 <reparent+0x2c>
}
    8000212e:	70a2                	ld	ra,40(sp)
    80002130:	7402                	ld	s0,32(sp)
    80002132:	64e2                	ld	s1,24(sp)
    80002134:	6942                	ld	s2,16(sp)
    80002136:	69a2                	ld	s3,8(sp)
    80002138:	6a02                	ld	s4,0(sp)
    8000213a:	6145                	addi	sp,sp,48
    8000213c:	8082                	ret

000000008000213e <kexit>:
{
    8000213e:	7179                	addi	sp,sp,-48
    80002140:	f406                	sd	ra,40(sp)
    80002142:	f022                	sd	s0,32(sp)
    80002144:	ec26                	sd	s1,24(sp)
    80002146:	e84a                	sd	s2,16(sp)
    80002148:	e44e                	sd	s3,8(sp)
    8000214a:	e052                	sd	s4,0(sp)
    8000214c:	1800                	addi	s0,sp,48
    8000214e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002150:	fe8ff0ef          	jal	80001938 <myproc>
    80002154:	89aa                	mv	s3,a0
  if (p == initproc)
    80002156:	00008797          	auipc	a5,0x8
    8000215a:	3027b783          	ld	a5,770(a5) # 8000a458 <initproc>
    8000215e:	0d850493          	addi	s1,a0,216
    80002162:	15850913          	addi	s2,a0,344
    80002166:	00a79b63          	bne	a5,a0,8000217c <kexit+0x3e>
    panic("init exiting");
    8000216a:	00005517          	auipc	a0,0x5
    8000216e:	09650513          	addi	a0,a0,150 # 80007200 <etext+0x200>
    80002172:	ec2fe0ef          	jal	80000834 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002176:	04a1                	addi	s1,s1,8
    80002178:	01248963          	beq	s1,s2,8000218a <kexit+0x4c>
    if (p->ofile[fd]) {
    8000217c:	6088                	ld	a0,0(s1)
    8000217e:	dd65                	beqz	a0,80002176 <kexit+0x38>
      fileclose(f);
    80002180:	12a020ef          	jal	800042aa <fileclose>
      p->ofile[fd] = 0;
    80002184:	0004b023          	sd	zero,0(s1)
    80002188:	b7fd                	j	80002176 <kexit+0x38>
  begin_op();
    8000218a:	467010ef          	jal	80003df0 <begin_op>
  iput(p->cwd);
    8000218e:	1589b503          	ld	a0,344(s3)
    80002192:	376010ef          	jal	80003508 <iput>
  end_op();
    80002196:	4e7010ef          	jal	80003e7c <end_op>
  p->cwd = 0;
    8000219a:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    8000219e:	00010517          	auipc	a0,0x10
    800021a2:	3fa50513          	addi	a0,a0,1018 # 80012598 <wait_lock>
    800021a6:	a73fe0ef          	jal	80000c18 <acquire>
  reparent(p);
    800021aa:	854e                	mv	a0,s3
    800021ac:	f3dff0ef          	jal	800020e8 <reparent>
  wakeup(p->parent);
    800021b0:	0409b503          	ld	a0,64(s3)
    800021b4:	ecfff0ef          	jal	80002082 <wakeup>
  acquire(&p->lock);
    800021b8:	854e                	mv	a0,s3
    800021ba:	a5ffe0ef          	jal	80000c18 <acquire>
  p->xstate = status;
    800021be:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800021c2:	4795                	li	a5,5
    800021c4:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800021c8:	00010517          	auipc	a0,0x10
    800021cc:	3d050513          	addi	a0,a0,976 # 80012598 <wait_lock>
    800021d0:	ad1fe0ef          	jal	80000ca0 <release>
  sched();
    800021d4:	d5bff0ef          	jal	80001f2e <sched>
  panic("zombie exit");
    800021d8:	00005517          	auipc	a0,0x5
    800021dc:	03850513          	addi	a0,a0,56 # 80007210 <etext+0x210>
    800021e0:	e54fe0ef          	jal	80000834 <panic>

00000000800021e4 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800021e4:	7179                	addi	sp,sp,-48
    800021e6:	f406                	sd	ra,40(sp)
    800021e8:	f022                	sd	s0,32(sp)
    800021ea:	ec26                	sd	s1,24(sp)
    800021ec:	e84a                	sd	s2,16(sp)
    800021ee:	e44e                	sd	s3,8(sp)
    800021f0:	1800                	addi	s0,sp,48
    800021f2:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800021f4:	00010497          	auipc	s1,0x10
    800021f8:	7bc48493          	addi	s1,s1,1980 # 800129b0 <proc>
    800021fc:	00016997          	auipc	s3,0x16
    80002200:	3b498993          	addi	s3,s3,948 # 800185b0 <tickslock>
    acquire(&p->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	a13fe0ef          	jal	80000c18 <acquire>
    if (p->pid == pid) {
    8000220a:	589c                	lw	a5,48(s1)
    8000220c:	01278b63          	beq	a5,s2,80002222 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	a8ffe0ef          	jal	80000ca0 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002216:	17048493          	addi	s1,s1,368
    8000221a:	ff3495e3          	bne	s1,s3,80002204 <kkill+0x20>
  }
  return -1;
    8000221e:	557d                	li	a0,-1
    80002220:	a819                	j	80002236 <kkill+0x52>
      p->killed = 1;
    80002222:	4785                	li	a5,1
    80002224:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002226:	4c98                	lw	a4,24(s1)
    80002228:	4789                	li	a5,2
    8000222a:	00f70d63          	beq	a4,a5,80002244 <kkill+0x60>
      release(&p->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	a71fe0ef          	jal	80000ca0 <release>
      return 0;
    80002234:	4501                	li	a0,0
}
    80002236:	70a2                	ld	ra,40(sp)
    80002238:	7402                	ld	s0,32(sp)
    8000223a:	64e2                	ld	s1,24(sp)
    8000223c:	6942                	ld	s2,16(sp)
    8000223e:	69a2                	ld	s3,8(sp)
    80002240:	6145                	addi	sp,sp,48
    80002242:	8082                	ret
        p->state = RUNNABLE;
    80002244:	478d                	li	a5,3
    80002246:	cc9c                	sw	a5,24(s1)
    80002248:	b7dd                	j	8000222e <kkill+0x4a>

000000008000224a <setkilled>:

void
setkilled(struct proc *p)
{
    8000224a:	1101                	addi	sp,sp,-32
    8000224c:	ec06                	sd	ra,24(sp)
    8000224e:	e822                	sd	s0,16(sp)
    80002250:	e426                	sd	s1,8(sp)
    80002252:	1000                	addi	s0,sp,32
    80002254:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002256:	9c3fe0ef          	jal	80000c18 <acquire>
  p->killed = 1;
    8000225a:	4785                	li	a5,1
    8000225c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000225e:	8526                	mv	a0,s1
    80002260:	a41fe0ef          	jal	80000ca0 <release>
}
    80002264:	60e2                	ld	ra,24(sp)
    80002266:	6442                	ld	s0,16(sp)
    80002268:	64a2                	ld	s1,8(sp)
    8000226a:	6105                	addi	sp,sp,32
    8000226c:	8082                	ret

000000008000226e <killed>:

int
killed(struct proc *p)
{
    8000226e:	1101                	addi	sp,sp,-32
    80002270:	ec06                	sd	ra,24(sp)
    80002272:	e822                	sd	s0,16(sp)
    80002274:	e426                	sd	s1,8(sp)
    80002276:	e04a                	sd	s2,0(sp)
    80002278:	1000                	addi	s0,sp,32
    8000227a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000227c:	99dfe0ef          	jal	80000c18 <acquire>
  k = p->killed;
    80002280:	549c                	lw	a5,40(s1)
    80002282:	893e                	mv	s2,a5
  release(&p->lock);
    80002284:	8526                	mv	a0,s1
    80002286:	a1bfe0ef          	jal	80000ca0 <release>
  return k;
}
    8000228a:	854a                	mv	a0,s2
    8000228c:	60e2                	ld	ra,24(sp)
    8000228e:	6442                	ld	s0,16(sp)
    80002290:	64a2                	ld	s1,8(sp)
    80002292:	6902                	ld	s2,0(sp)
    80002294:	6105                	addi	sp,sp,32
    80002296:	8082                	ret

0000000080002298 <kwait>:
{
    80002298:	715d                	addi	sp,sp,-80
    8000229a:	e486                	sd	ra,72(sp)
    8000229c:	e0a2                	sd	s0,64(sp)
    8000229e:	fc26                	sd	s1,56(sp)
    800022a0:	f84a                	sd	s2,48(sp)
    800022a2:	f44e                	sd	s3,40(sp)
    800022a4:	f052                	sd	s4,32(sp)
    800022a6:	ec56                	sd	s5,24(sp)
    800022a8:	e85a                	sd	s6,16(sp)
    800022aa:	e45e                	sd	s7,8(sp)
    800022ac:	0880                	addi	s0,sp,80
    800022ae:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800022b0:	e88ff0ef          	jal	80001938 <myproc>
    800022b4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022b6:	00010517          	auipc	a0,0x10
    800022ba:	2e250513          	addi	a0,a0,738 # 80012598 <wait_lock>
    800022be:	95bfe0ef          	jal	80000c18 <acquire>
        if (pp->state == ZOMBIE) {
    800022c2:	4a15                	li	s4,5
        havekids = 1;
    800022c4:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022c6:	00016997          	auipc	s3,0x16
    800022ca:	2ea98993          	addi	s3,s3,746 # 800185b0 <tickslock>
    release(&wait_lock);
    800022ce:	00010b17          	auipc	s6,0x10
    800022d2:	2cab0b13          	addi	s6,s6,714 # 80012598 <wait_lock>
    800022d6:	a845                	j	80002386 <kwait+0xee>
          pid = pp->pid;
    800022d8:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    800022dc:	000b8e63          	beqz	s7,800022f8 <kwait+0x60>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    800022e0:	4711                	li	a4,4
    800022e2:	02c48693          	addi	a3,s1,44
    800022e6:	865e                	mv	a2,s7
    800022e8:	05093583          	ld	a1,80(s2)
    800022ec:	05893503          	ld	a0,88(s2)
    800022f0:	a82ff0ef          	jal	80001572 <copyout>
          if (addr != 0 &&
    800022f4:	02054c63          	bltz	a0,8000232c <kwait+0x94>
          pp->parent = 0;
    800022f8:	0404b023          	sd	zero,64(s1)
          freeproc(pp);
    800022fc:	8526                	mv	a0,s1
    800022fe:	81bff0ef          	jal	80001b18 <freeproc>
          release(&pp->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	99dfe0ef          	jal	80000ca0 <release>
          release(&wait_lock);
    80002308:	00010517          	auipc	a0,0x10
    8000230c:	29050513          	addi	a0,a0,656 # 80012598 <wait_lock>
    80002310:	991fe0ef          	jal	80000ca0 <release>
}
    80002314:	854e                	mv	a0,s3
    80002316:	60a6                	ld	ra,72(sp)
    80002318:	6406                	ld	s0,64(sp)
    8000231a:	74e2                	ld	s1,56(sp)
    8000231c:	7942                	ld	s2,48(sp)
    8000231e:	79a2                	ld	s3,40(sp)
    80002320:	7a02                	ld	s4,32(sp)
    80002322:	6ae2                	ld	s5,24(sp)
    80002324:	6b42                	ld	s6,16(sp)
    80002326:	6ba2                	ld	s7,8(sp)
    80002328:	6161                	addi	sp,sp,80
    8000232a:	8082                	ret
            release(&pp->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	973fe0ef          	jal	80000ca0 <release>
            release(&wait_lock);
    80002332:	00010517          	auipc	a0,0x10
    80002336:	26650513          	addi	a0,a0,614 # 80012598 <wait_lock>
    8000233a:	967fe0ef          	jal	80000ca0 <release>
            return -1;
    8000233e:	59fd                	li	s3,-1
    80002340:	bfd1                	j	80002314 <kwait+0x7c>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002342:	17048493          	addi	s1,s1,368
    80002346:	03348063          	beq	s1,s3,80002366 <kwait+0xce>
      if (pp->parent == p) {
    8000234a:	60bc                	ld	a5,64(s1)
    8000234c:	ff279be3          	bne	a5,s2,80002342 <kwait+0xaa>
        acquire(&pp->lock);
    80002350:	8526                	mv	a0,s1
    80002352:	8c7fe0ef          	jal	80000c18 <acquire>
        if (pp->state == ZOMBIE) {
    80002356:	4c9c                	lw	a5,24(s1)
    80002358:	f94780e3          	beq	a5,s4,800022d8 <kwait+0x40>
        release(&pp->lock);
    8000235c:	8526                	mv	a0,s1
    8000235e:	943fe0ef          	jal	80000ca0 <release>
        havekids = 1;
    80002362:	8756                	mv	a4,s5
    80002364:	bff9                	j	80002342 <kwait+0xaa>
    if (!havekids || killed(p)) {
    80002366:	c715                	beqz	a4,80002392 <kwait+0xfa>
    80002368:	854a                	mv	a0,s2
    8000236a:	f05ff0ef          	jal	8000226e <killed>
    8000236e:	e115                	bnez	a0,80002392 <kwait+0xfa>
    sleep_prepare(p); //DOC: wait-sleep
    80002370:	854a                	mv	a0,s2
    80002372:	ca5ff0ef          	jal	80002016 <sleep_prepare>
    release(&wait_lock);
    80002376:	855a                	mv	a0,s6
    80002378:	929fe0ef          	jal	80000ca0 <release>
    sleep();
    8000237c:	cd7ff0ef          	jal	80002052 <sleep>
    acquire(&wait_lock);
    80002380:	855a                	mv	a0,s6
    80002382:	897fe0ef          	jal	80000c18 <acquire>
    havekids = 0;
    80002386:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002388:	00010497          	auipc	s1,0x10
    8000238c:	62848493          	addi	s1,s1,1576 # 800129b0 <proc>
    80002390:	bf6d                	j	8000234a <kwait+0xb2>
      release(&wait_lock);
    80002392:	00010517          	auipc	a0,0x10
    80002396:	20650513          	addi	a0,a0,518 # 80012598 <wait_lock>
    8000239a:	907fe0ef          	jal	80000ca0 <release>
      return -1;
    8000239e:	59fd                	li	s3,-1
    800023a0:	bf95                	j	80002314 <kwait+0x7c>

00000000800023a2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800023a2:	7179                	addi	sp,sp,-48
    800023a4:	f406                	sd	ra,40(sp)
    800023a6:	f022                	sd	s0,32(sp)
    800023a8:	ec26                	sd	s1,24(sp)
    800023aa:	e84a                	sd	s2,16(sp)
    800023ac:	e44e                	sd	s3,8(sp)
    800023ae:	e052                	sd	s4,0(sp)
    800023b0:	1800                	addi	s0,sp,48
    800023b2:	84aa                	mv	s1,a0
    800023b4:	8a2e                	mv	s4,a1
    800023b6:	89b2                	mv	s3,a2
    800023b8:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800023ba:	d7eff0ef          	jal	80001938 <myproc>
  if (user_dst) {
    800023be:	c085                	beqz	s1,800023de <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    800023c0:	874a                	mv	a4,s2
    800023c2:	86ce                	mv	a3,s3
    800023c4:	8652                	mv	a2,s4
    800023c6:	692c                	ld	a1,80(a0)
    800023c8:	6d28                	ld	a0,88(a0)
    800023ca:	9a8ff0ef          	jal	80001572 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023ce:	70a2                	ld	ra,40(sp)
    800023d0:	7402                	ld	s0,32(sp)
    800023d2:	64e2                	ld	s1,24(sp)
    800023d4:	6942                	ld	s2,16(sp)
    800023d6:	69a2                	ld	s3,8(sp)
    800023d8:	6a02                	ld	s4,0(sp)
    800023da:	6145                	addi	sp,sp,48
    800023dc:	8082                	ret
    memmove((char *)dst, src, len);
    800023de:	0009061b          	sext.w	a2,s2
    800023e2:	85ce                	mv	a1,s3
    800023e4:	8552                	mv	a0,s4
    800023e6:	953fe0ef          	jal	80000d38 <memmove>
    return 0;
    800023ea:	8526                	mv	a0,s1
    800023ec:	b7cd                	j	800023ce <either_copyout+0x2c>

00000000800023ee <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023ee:	7179                	addi	sp,sp,-48
    800023f0:	f406                	sd	ra,40(sp)
    800023f2:	f022                	sd	s0,32(sp)
    800023f4:	ec26                	sd	s1,24(sp)
    800023f6:	e84a                	sd	s2,16(sp)
    800023f8:	e44e                	sd	s3,8(sp)
    800023fa:	e052                	sd	s4,0(sp)
    800023fc:	1800                	addi	s0,sp,48
    800023fe:	8a2a                	mv	s4,a0
    80002400:	84ae                	mv	s1,a1
    80002402:	89b2                	mv	s3,a2
    80002404:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002406:	d32ff0ef          	jal	80001938 <myproc>
  if (user_src) {
    8000240a:	c085                	beqz	s1,8000242a <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    8000240c:	874a                	mv	a4,s2
    8000240e:	86ce                	mv	a3,s3
    80002410:	8652                	mv	a2,s4
    80002412:	692c                	ld	a1,80(a0)
    80002414:	6d28                	ld	a0,88(a0)
    80002416:	a22ff0ef          	jal	80001638 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000241a:	70a2                	ld	ra,40(sp)
    8000241c:	7402                	ld	s0,32(sp)
    8000241e:	64e2                	ld	s1,24(sp)
    80002420:	6942                	ld	s2,16(sp)
    80002422:	69a2                	ld	s3,8(sp)
    80002424:	6a02                	ld	s4,0(sp)
    80002426:	6145                	addi	sp,sp,48
    80002428:	8082                	ret
    memmove(dst, (char *)src, len);
    8000242a:	0009061b          	sext.w	a2,s2
    8000242e:	85ce                	mv	a1,s3
    80002430:	8552                	mv	a0,s4
    80002432:	907fe0ef          	jal	80000d38 <memmove>
    return 0;
    80002436:	8526                	mv	a0,s1
    80002438:	b7cd                	j	8000241a <either_copyin+0x2c>

000000008000243a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000243a:	715d                	addi	sp,sp,-80
    8000243c:	e486                	sd	ra,72(sp)
    8000243e:	e0a2                	sd	s0,64(sp)
    80002440:	fc26                	sd	s1,56(sp)
    80002442:	f84a                	sd	s2,48(sp)
    80002444:	f44e                	sd	s3,40(sp)
    80002446:	f052                	sd	s4,32(sp)
    80002448:	ec56                	sd	s5,24(sp)
    8000244a:	e85a                	sd	s6,16(sp)
    8000244c:	e45e                	sd	s7,8(sp)
    8000244e:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    80002450:	00005517          	auipc	a0,0x5
    80002454:	c2850513          	addi	a0,a0,-984 # 80007078 <etext+0x78>
    80002458:	8b2fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000245c:	00010497          	auipc	s1,0x10
    80002460:	6b448493          	addi	s1,s1,1716 # 80012b10 <proc+0x160>
    80002464:	00016917          	auipc	s2,0x16
    80002468:	2ac90913          	addi	s2,s2,684 # 80018710 <bcache+0x148>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000246c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000246e:	00005997          	auipc	s3,0x5
    80002472:	db298993          	addi	s3,s3,-590 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002476:	00005a97          	auipc	s5,0x5
    8000247a:	db2a8a93          	addi	s5,s5,-590 # 80007228 <etext+0x228>
    printk("\n");
    8000247e:	00005a17          	auipc	s4,0x5
    80002482:	bfaa0a13          	addi	s4,s4,-1030 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002486:	00005b97          	auipc	s7,0x5
    8000248a:	2c2b8b93          	addi	s7,s7,706 # 80007748 <states.0>
    8000248e:	a829                	j	800024a8 <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002490:	ed06a583          	lw	a1,-304(a3)
    80002494:	8556                	mv	a0,s5
    80002496:	874fe0ef          	jal	8000050a <printk>
    printk("\n");
    8000249a:	8552                	mv	a0,s4
    8000249c:	86efe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024a0:	17048493          	addi	s1,s1,368
    800024a4:	03248263          	beq	s1,s2,800024c8 <procdump+0x8e>
    if (p->state == UNUSED)
    800024a8:	86a6                	mv	a3,s1
    800024aa:	eb84a783          	lw	a5,-328(s1)
    800024ae:	dbed                	beqz	a5,800024a0 <procdump+0x66>
      state = "???";
    800024b0:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024b2:	fcfb6fe3          	bltu	s6,a5,80002490 <procdump+0x56>
    800024b6:	02079713          	slli	a4,a5,0x20
    800024ba:	01d75793          	srli	a5,a4,0x1d
    800024be:	97de                	add	a5,a5,s7
    800024c0:	6390                	ld	a2,0(a5)
    800024c2:	f679                	bnez	a2,80002490 <procdump+0x56>
      state = "???";
    800024c4:	864e                	mv	a2,s3
    800024c6:	b7e9                	j	80002490 <procdump+0x56>
  }
}
    800024c8:	60a6                	ld	ra,72(sp)
    800024ca:	6406                	ld	s0,64(sp)
    800024cc:	74e2                	ld	s1,56(sp)
    800024ce:	7942                	ld	s2,48(sp)
    800024d0:	79a2                	ld	s3,40(sp)
    800024d2:	7a02                	ld	s4,32(sp)
    800024d4:	6ae2                	ld	s5,24(sp)
    800024d6:	6b42                	ld	s6,16(sp)
    800024d8:	6ba2                	ld	s7,8(sp)
    800024da:	6161                	addi	sp,sp,80
    800024dc:	8082                	ret

00000000800024de <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800024de:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800024e2:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800024e6:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800024e8:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800024ea:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800024ee:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800024f2:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800024f6:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800024fa:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800024fe:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002502:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002506:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000250a:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000250e:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002512:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002516:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000251a:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000251c:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000251e:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002522:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002526:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000252a:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000252e:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002532:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002536:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000253a:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000253e:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002542:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002546:	8082                	ret

0000000080002548 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002548:	1141                	addi	sp,sp,-16
    8000254a:	e406                	sd	ra,8(sp)
    8000254c:	e022                	sd	s0,0(sp)
    8000254e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002550:	00005597          	auipc	a1,0x5
    80002554:	d1858593          	addi	a1,a1,-744 # 80007268 <etext+0x268>
    80002558:	00016517          	auipc	a0,0x16
    8000255c:	05850513          	addi	a0,a0,88 # 800185b0 <tickslock>
    80002560:	e38fe0ef          	jal	80000b98 <initlock>
}
    80002564:	60a2                	ld	ra,8(sp)
    80002566:	6402                	ld	s0,0(sp)
    80002568:	0141                	addi	sp,sp,16
    8000256a:	8082                	ret

000000008000256c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000256c:	1141                	addi	sp,sp,-16
    8000256e:	e406                	sd	ra,8(sp)
    80002570:	e022                	sd	s0,0(sp)
    80002572:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002574:	00003797          	auipc	a5,0x3
    80002578:	19c78793          	addi	a5,a5,412 # 80005710 <kernelvec>
    8000257c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002580:	60a2                	ld	ra,8(sp)
    80002582:	6402                	ld	s0,0(sp)
    80002584:	0141                	addi	sp,sp,16
    80002586:	8082                	ret

0000000080002588 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002588:	1141                	addi	sp,sp,-16
    8000258a:	e406                	sd	ra,8(sp)
    8000258c:	e022                	sd	s0,0(sp)
    8000258e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002590:	ba8ff0ef          	jal	80001938 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002594:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002598:	04000737          	lui	a4,0x4000
    8000259c:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000259e:	0732                	slli	a4,a4,0xc
    800025a0:	00004797          	auipc	a5,0x4
    800025a4:	a6078793          	addi	a5,a5,-1440 # 80006000 <_trampoline>
    800025a8:	00004697          	auipc	a3,0x4
    800025ac:	a5868693          	addi	a3,a3,-1448 # 80006000 <_trampoline>
    800025b0:	8f95                	sub	a5,a5,a3
    800025b2:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    800025b4:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800025b8:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    800025ba:	18002773          	csrr	a4,satp
    800025be:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025c0:	7138                	ld	a4,96(a0)
    800025c2:	653c                	ld	a5,72(a0)
    800025c4:	6685                	lui	a3,0x1
    800025c6:	97b6                	add	a5,a5,a3
    800025c8:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800025ca:	713c                	ld	a5,96(a0)
    800025cc:	00000717          	auipc	a4,0x0
    800025d0:	0fc70713          	addi	a4,a4,252 # 800026c8 <usertrap>
    800025d4:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800025d6:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    800025d8:	8712                	mv	a4,tp
    800025da:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800025dc:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025e0:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025e4:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800025e8:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800025ec:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    800025ee:	6f9c                	ld	a5,24(a5)
    800025f0:	14179073          	csrw	sepc,a5
}
    800025f4:	60a2                	ld	ra,8(sp)
    800025f6:	6402                	ld	s0,0(sp)
    800025f8:	0141                	addi	sp,sp,16
    800025fa:	8082                	ret

00000000800025fc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800025fc:	1141                	addi	sp,sp,-16
    800025fe:	e406                	sd	ra,8(sp)
    80002600:	e022                	sd	s0,0(sp)
    80002602:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80002604:	b00ff0ef          	jal	80001904 <cpuid>
    80002608:	cd11                	beqz	a0,80002624 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    8000260a:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000260e:	000f4737          	lui	a4,0xf4
    80002612:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002616:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    80002618:	14d79073          	csrw	stimecmp,a5
}
    8000261c:	60a2                	ld	ra,8(sp)
    8000261e:	6402                	ld	s0,0(sp)
    80002620:	0141                	addi	sp,sp,16
    80002622:	8082                	ret
    acquire(&tickslock);
    80002624:	00016517          	auipc	a0,0x16
    80002628:	f8c50513          	addi	a0,a0,-116 # 800185b0 <tickslock>
    8000262c:	decfe0ef          	jal	80000c18 <acquire>
    ticks++;
    80002630:	00008717          	auipc	a4,0x8
    80002634:	e3070713          	addi	a4,a4,-464 # 8000a460 <ticks>
    80002638:	431c                	lw	a5,0(a4)
    8000263a:	2785                	addiw	a5,a5,1
    8000263c:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    8000263e:	853a                	mv	a0,a4
    80002640:	a43ff0ef          	jal	80002082 <wakeup>
    release(&tickslock);
    80002644:	00016517          	auipc	a0,0x16
    80002648:	f6c50513          	addi	a0,a0,-148 # 800185b0 <tickslock>
    8000264c:	e54fe0ef          	jal	80000ca0 <release>
    80002650:	bf6d                	j	8000260a <clockintr+0xe>

0000000080002652 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002652:	1101                	addi	sp,sp,-32
    80002654:	ec06                	sd	ra,24(sp)
    80002656:	e822                	sd	s0,16(sp)
    80002658:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    8000265a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    8000265e:	57fd                	li	a5,-1
    80002660:	17fe                	slli	a5,a5,0x3f
    80002662:	07a5                	addi	a5,a5,9
    80002664:	00f70c63          	beq	a4,a5,8000267c <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    80002668:	57fd                	li	a5,-1
    8000266a:	17fe                	slli	a5,a5,0x3f
    8000266c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000266e:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    80002670:	04f70863          	beq	a4,a5,800026c0 <devintr+0x6e>
  }
}
    80002674:	60e2                	ld	ra,24(sp)
    80002676:	6442                	ld	s0,16(sp)
    80002678:	6105                	addi	sp,sp,32
    8000267a:	8082                	ret
    8000267c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000267e:	13e030ef          	jal	800057bc <plic_claim>
    80002682:	872a                	mv	a4,a0
    80002684:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002686:	47a9                	li	a5,10
    80002688:	00f50963          	beq	a0,a5,8000269a <devintr+0x48>
    } else if (irq == VIRTIO0_IRQ) {
    8000268c:	4785                	li	a5,1
    8000268e:	00f50963          	beq	a0,a5,800026a0 <devintr+0x4e>
    return 1;
    80002692:	4505                	li	a0,1
    } else if (irq) {
    80002694:	eb09                	bnez	a4,800026a6 <devintr+0x54>
    80002696:	64a2                	ld	s1,8(sp)
    80002698:	bff1                	j	80002674 <devintr+0x22>
      uartintr();
    8000269a:	b34fe0ef          	jal	800009ce <uartintr>
    if (irq)
    8000269e:	a819                	j	800026b4 <devintr+0x62>
      virtio_disk_intr();
    800026a0:	5d4030ef          	jal	80005c74 <virtio_disk_intr>
    if (irq)
    800026a4:	a801                	j	800026b4 <devintr+0x62>
      printk("unexpected interrupt irq=%d\n", irq);
    800026a6:	85ba                	mv	a1,a4
    800026a8:	00005517          	auipc	a0,0x5
    800026ac:	bc850513          	addi	a0,a0,-1080 # 80007270 <etext+0x270>
    800026b0:	e5bfd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    800026b4:	8526                	mv	a0,s1
    800026b6:	126030ef          	jal	800057dc <plic_complete>
    return 1;
    800026ba:	4505                	li	a0,1
    800026bc:	64a2                	ld	s1,8(sp)
    800026be:	bf5d                	j	80002674 <devintr+0x22>
    clockintr();
    800026c0:	f3dff0ef          	jal	800025fc <clockintr>
    return 2;
    800026c4:	4509                	li	a0,2
    800026c6:	b77d                	j	80002674 <devintr+0x22>

00000000800026c8 <usertrap>:
{
    800026c8:	1101                	addi	sp,sp,-32
    800026ca:	ec06                	sd	ra,24(sp)
    800026cc:	e822                	sd	s0,16(sp)
    800026ce:	e426                	sd	s1,8(sp)
    800026d0:	e04a                	sd	s2,0(sp)
    800026d2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800026d4:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    800026d8:	1007f793          	andi	a5,a5,256
    800026dc:	eba5                	bnez	a5,8000274c <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    800026de:	00003797          	auipc	a5,0x3
    800026e2:	03278793          	addi	a5,a5,50 # 80005710 <kernelvec>
    800026e6:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800026ea:	a4eff0ef          	jal	80001938 <myproc>
    800026ee:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800026f0:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026f2:	14102773          	csrr	a4,sepc
    800026f6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    800026f8:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    800026fc:	47a1                	li	a5,8
    800026fe:	04f70d63          	beq	a4,a5,80002758 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    80002702:	f51ff0ef          	jal	80002652 <devintr>
    80002706:	892a                	mv	s2,a0
    80002708:	e54d                	bnez	a0,800027b2 <usertrap+0xea>
    8000270a:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    8000270e:	47bd                	li	a5,15
    80002710:	08f70463          	beq	a4,a5,80002798 <usertrap+0xd0>
    80002714:	14202773          	csrr	a4,scause
    80002718:	47b5                	li	a5,13
    8000271a:	06f70f63          	beq	a4,a5,80002798 <usertrap+0xd0>
    8000271e:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002722:	5890                	lw	a2,48(s1)
    80002724:	00005517          	auipc	a0,0x5
    80002728:	b8c50513          	addi	a0,a0,-1140 # 800072b0 <etext+0x2b0>
    8000272c:	ddffd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002730:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002734:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002738:	00005517          	auipc	a0,0x5
    8000273c:	ba850513          	addi	a0,a0,-1112 # 800072e0 <etext+0x2e0>
    80002740:	dcbfd0ef          	jal	8000050a <printk>
    setkilled(p);
    80002744:	8526                	mv	a0,s1
    80002746:	b05ff0ef          	jal	8000224a <setkilled>
    8000274a:	a015                	j	8000276e <usertrap+0xa6>
    panic("usertrap: not from user mode");
    8000274c:	00005517          	auipc	a0,0x5
    80002750:	b4450513          	addi	a0,a0,-1212 # 80007290 <etext+0x290>
    80002754:	8e0fe0ef          	jal	80000834 <panic>
    if (killed(p))
    80002758:	b17ff0ef          	jal	8000226e <killed>
    8000275c:	e915                	bnez	a0,80002790 <usertrap+0xc8>
    p->trapframe->epc += 4;
    8000275e:	70b8                	ld	a4,96(s1)
    80002760:	6f1c                	ld	a5,24(a4)
    80002762:	0791                	addi	a5,a5,4
    80002764:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002766:	10016073          	csrsi	sstatus,2
    syscall();
    8000276a:	244000ef          	jal	800029ae <syscall>
  if (killed(p))
    8000276e:	8526                	mv	a0,s1
    80002770:	affff0ef          	jal	8000226e <killed>
    80002774:	e521                	bnez	a0,800027bc <usertrap+0xf4>
  prepare_return();
    80002776:	e13ff0ef          	jal	80002588 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    8000277a:	6ca8                	ld	a0,88(s1)
    8000277c:	8131                	srli	a0,a0,0xc
    8000277e:	57fd                	li	a5,-1
    80002780:	17fe                	slli	a5,a5,0x3f
    80002782:	8d5d                	or	a0,a0,a5
}
    80002784:	60e2                	ld	ra,24(sp)
    80002786:	6442                	ld	s0,16(sp)
    80002788:	64a2                	ld	s1,8(sp)
    8000278a:	6902                	ld	s2,0(sp)
    8000278c:	6105                	addi	sp,sp,32
    8000278e:	8082                	ret
      kexit(-1);
    80002790:	557d                	li	a0,-1
    80002792:	9adff0ef          	jal	8000213e <kexit>
    80002796:	b7e1                	j	8000275e <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002798:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    8000279c:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    800027a0:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    800027a2:	0016b693          	seqz	a3,a3
    800027a6:	68ac                	ld	a1,80(s1)
    800027a8:	6ca8                	ld	a0,88(s1)
    800027aa:	d4dfe0ef          	jal	800014f6 <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800027ae:	f161                	bnez	a0,8000276e <usertrap+0xa6>
    800027b0:	b7bd                	j	8000271e <usertrap+0x56>
  if (killed(p))
    800027b2:	8526                	mv	a0,s1
    800027b4:	abbff0ef          	jal	8000226e <killed>
    800027b8:	c511                	beqz	a0,800027c4 <usertrap+0xfc>
    800027ba:	a011                	j	800027be <usertrap+0xf6>
    800027bc:	4901                	li	s2,0
    kexit(-1);
    800027be:	557d                	li	a0,-1
    800027c0:	97fff0ef          	jal	8000213e <kexit>
  if (which_dev == 2)
    800027c4:	4789                	li	a5,2
    800027c6:	faf918e3          	bne	s2,a5,80002776 <usertrap+0xae>
    yield();
    800027ca:	821ff0ef          	jal	80001fea <yield>
    800027ce:	b765                	j	80002776 <usertrap+0xae>

00000000800027d0 <kerneltrap>:
{
    800027d0:	7179                	addi	sp,sp,-48
    800027d2:	f406                	sd	ra,40(sp)
    800027d4:	f022                	sd	s0,32(sp)
    800027d6:	ec26                	sd	s1,24(sp)
    800027d8:	e84a                	sd	s2,16(sp)
    800027da:	e44e                	sd	s3,8(sp)
    800027dc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    800027de:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027e2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    800027e6:	142027f3          	csrr	a5,scause
    800027ea:	89be                	mv	s3,a5
  if ((sstatus & SSTATUS_SPP) == 0)
    800027ec:	1004f793          	andi	a5,s1,256
    800027f0:	c795                	beqz	a5,8000281c <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    800027f2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800027f6:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    800027f8:	eb85                	bnez	a5,80002828 <kerneltrap+0x58>
  if ((which_dev = devintr()) == 0) {
    800027fa:	e59ff0ef          	jal	80002652 <devintr>
    800027fe:	c91d                	beqz	a0,80002834 <kerneltrap+0x64>
  if (which_dev == 2 && myproc() != 0)
    80002800:	4789                	li	a5,2
    80002802:	04f50a63          	beq	a0,a5,80002856 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r"(x));
    80002806:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    8000280a:	10049073          	csrw	sstatus,s1
}
    8000280e:	70a2                	ld	ra,40(sp)
    80002810:	7402                	ld	s0,32(sp)
    80002812:	64e2                	ld	s1,24(sp)
    80002814:	6942                	ld	s2,16(sp)
    80002816:	69a2                	ld	s3,8(sp)
    80002818:	6145                	addi	sp,sp,48
    8000281a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000281c:	00005517          	auipc	a0,0x5
    80002820:	aec50513          	addi	a0,a0,-1300 # 80007308 <etext+0x308>
    80002824:	810fe0ef          	jal	80000834 <panic>
    panic("kerneltrap: interrupts enabled");
    80002828:	00005517          	auipc	a0,0x5
    8000282c:	b0850513          	addi	a0,a0,-1272 # 80007330 <etext+0x330>
    80002830:	804fe0ef          	jal	80000834 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002834:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    80002838:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    8000283c:	85ce                	mv	a1,s3
    8000283e:	00005517          	auipc	a0,0x5
    80002842:	b1250513          	addi	a0,a0,-1262 # 80007350 <etext+0x350>
    80002846:	cc5fd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    8000284a:	00005517          	auipc	a0,0x5
    8000284e:	b2e50513          	addi	a0,a0,-1234 # 80007378 <etext+0x378>
    80002852:	fe3fd0ef          	jal	80000834 <panic>
  if (which_dev == 2 && myproc() != 0)
    80002856:	8e2ff0ef          	jal	80001938 <myproc>
    8000285a:	d555                	beqz	a0,80002806 <kerneltrap+0x36>
    yield();
    8000285c:	f8eff0ef          	jal	80001fea <yield>
    80002860:	b75d                	j	80002806 <kerneltrap+0x36>

0000000080002862 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002862:	1101                	addi	sp,sp,-32
    80002864:	ec06                	sd	ra,24(sp)
    80002866:	e822                	sd	s0,16(sp)
    80002868:	e426                	sd	s1,8(sp)
    8000286a:	1000                	addi	s0,sp,32
    8000286c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000286e:	8caff0ef          	jal	80001938 <myproc>
  switch (n) {
    80002872:	4795                	li	a5,5
    80002874:	0497e163          	bltu	a5,s1,800028b6 <argraw+0x54>
    80002878:	048a                	slli	s1,s1,0x2
    8000287a:	00005717          	auipc	a4,0x5
    8000287e:	efe70713          	addi	a4,a4,-258 # 80007778 <states.0+0x30>
    80002882:	94ba                	add	s1,s1,a4
    80002884:	409c                	lw	a5,0(s1)
    80002886:	97ba                	add	a5,a5,a4
    80002888:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000288a:	713c                	ld	a5,96(a0)
    8000288c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000288e:	60e2                	ld	ra,24(sp)
    80002890:	6442                	ld	s0,16(sp)
    80002892:	64a2                	ld	s1,8(sp)
    80002894:	6105                	addi	sp,sp,32
    80002896:	8082                	ret
    return p->trapframe->a1;
    80002898:	713c                	ld	a5,96(a0)
    8000289a:	7fa8                	ld	a0,120(a5)
    8000289c:	bfcd                	j	8000288e <argraw+0x2c>
    return p->trapframe->a2;
    8000289e:	713c                	ld	a5,96(a0)
    800028a0:	63c8                	ld	a0,128(a5)
    800028a2:	b7f5                	j	8000288e <argraw+0x2c>
    return p->trapframe->a3;
    800028a4:	713c                	ld	a5,96(a0)
    800028a6:	67c8                	ld	a0,136(a5)
    800028a8:	b7dd                	j	8000288e <argraw+0x2c>
    return p->trapframe->a4;
    800028aa:	713c                	ld	a5,96(a0)
    800028ac:	6bc8                	ld	a0,144(a5)
    800028ae:	b7c5                	j	8000288e <argraw+0x2c>
    return p->trapframe->a5;
    800028b0:	713c                	ld	a5,96(a0)
    800028b2:	6fc8                	ld	a0,152(a5)
    800028b4:	bfe9                	j	8000288e <argraw+0x2c>
  panic("argraw");
    800028b6:	00005517          	auipc	a0,0x5
    800028ba:	ad250513          	addi	a0,a0,-1326 # 80007388 <etext+0x388>
    800028be:	f77fd0ef          	jal	80000834 <panic>

00000000800028c2 <fetchaddr>:
{
    800028c2:	1101                	addi	sp,sp,-32
    800028c4:	ec06                	sd	ra,24(sp)
    800028c6:	e822                	sd	s0,16(sp)
    800028c8:	e426                	sd	s1,8(sp)
    800028ca:	e04a                	sd	s2,0(sp)
    800028cc:	1000                	addi	s0,sp,32
    800028ce:	84aa                	mv	s1,a0
    800028d0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800028d2:	866ff0ef          	jal	80001938 <myproc>
  if (addr >= p->sz ||
    800028d6:	692c                	ld	a1,80(a0)
    800028d8:	02b4f663          	bgeu	s1,a1,80002904 <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800028dc:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    800028e0:	02f5e463          	bltu	a1,a5,80002908 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    800028e4:	4721                	li	a4,8
    800028e6:	86a6                	mv	a3,s1
    800028e8:	864a                	mv	a2,s2
    800028ea:	6d28                	ld	a0,88(a0)
    800028ec:	d4dfe0ef          	jal	80001638 <copyin>
    800028f0:	00a03533          	snez	a0,a0
    800028f4:	40a0053b          	negw	a0,a0
}
    800028f8:	60e2                	ld	ra,24(sp)
    800028fa:	6442                	ld	s0,16(sp)
    800028fc:	64a2                	ld	s1,8(sp)
    800028fe:	6902                	ld	s2,0(sp)
    80002900:	6105                	addi	sp,sp,32
    80002902:	8082                	ret
    return -1;
    80002904:	557d                	li	a0,-1
    80002906:	bfcd                	j	800028f8 <fetchaddr+0x36>
    80002908:	557d                	li	a0,-1
    8000290a:	b7fd                	j	800028f8 <fetchaddr+0x36>

000000008000290c <fetchstr>:
{
    8000290c:	7179                	addi	sp,sp,-48
    8000290e:	f406                	sd	ra,40(sp)
    80002910:	f022                	sd	s0,32(sp)
    80002912:	ec26                	sd	s1,24(sp)
    80002914:	e84a                	sd	s2,16(sp)
    80002916:	e44e                	sd	s3,8(sp)
    80002918:	1800                	addi	s0,sp,48
    8000291a:	89aa                	mv	s3,a0
    8000291c:	84ae                	mv	s1,a1
    8000291e:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002920:	818ff0ef          	jal	80001938 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    80002924:	874a                	mv	a4,s2
    80002926:	86ce                	mv	a3,s3
    80002928:	8626                	mv	a2,s1
    8000292a:	692c                	ld	a1,80(a0)
    8000292c:	6d28                	ld	a0,88(a0)
    8000292e:	da7fe0ef          	jal	800016d4 <copyinstr>
    80002932:	00054c63          	bltz	a0,8000294a <fetchstr+0x3e>
  return strlen(buf);
    80002936:	8526                	mv	a0,s1
    80002938:	d2afe0ef          	jal	80000e62 <strlen>
}
    8000293c:	70a2                	ld	ra,40(sp)
    8000293e:	7402                	ld	s0,32(sp)
    80002940:	64e2                	ld	s1,24(sp)
    80002942:	6942                	ld	s2,16(sp)
    80002944:	69a2                	ld	s3,8(sp)
    80002946:	6145                	addi	sp,sp,48
    80002948:	8082                	ret
    return -1;
    8000294a:	557d                	li	a0,-1
    8000294c:	bfc5                	j	8000293c <fetchstr+0x30>

000000008000294e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000294e:	1101                	addi	sp,sp,-32
    80002950:	ec06                	sd	ra,24(sp)
    80002952:	e822                	sd	s0,16(sp)
    80002954:	e426                	sd	s1,8(sp)
    80002956:	1000                	addi	s0,sp,32
    80002958:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000295a:	f09ff0ef          	jal	80002862 <argraw>
    8000295e:	c088                	sw	a0,0(s1)
}
    80002960:	60e2                	ld	ra,24(sp)
    80002962:	6442                	ld	s0,16(sp)
    80002964:	64a2                	ld	s1,8(sp)
    80002966:	6105                	addi	sp,sp,32
    80002968:	8082                	ret

000000008000296a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000296a:	1101                	addi	sp,sp,-32
    8000296c:	ec06                	sd	ra,24(sp)
    8000296e:	e822                	sd	s0,16(sp)
    80002970:	e426                	sd	s1,8(sp)
    80002972:	1000                	addi	s0,sp,32
    80002974:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002976:	eedff0ef          	jal	80002862 <argraw>
    8000297a:	e088                	sd	a0,0(s1)
}
    8000297c:	60e2                	ld	ra,24(sp)
    8000297e:	6442                	ld	s0,16(sp)
    80002980:	64a2                	ld	s1,8(sp)
    80002982:	6105                	addi	sp,sp,32
    80002984:	8082                	ret

0000000080002986 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002986:	1101                	addi	sp,sp,-32
    80002988:	ec06                	sd	ra,24(sp)
    8000298a:	e822                	sd	s0,16(sp)
    8000298c:	e426                	sd	s1,8(sp)
    8000298e:	e04a                	sd	s2,0(sp)
    80002990:	1000                	addi	s0,sp,32
    80002992:	892e                	mv	s2,a1
    80002994:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002996:	ecdff0ef          	jal	80002862 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    8000299a:	8626                	mv	a2,s1
    8000299c:	85ca                	mv	a1,s2
    8000299e:	f6fff0ef          	jal	8000290c <fetchstr>
}
    800029a2:	60e2                	ld	ra,24(sp)
    800029a4:	6442                	ld	s0,16(sp)
    800029a6:	64a2                	ld	s1,8(sp)
    800029a8:	6902                	ld	s2,0(sp)
    800029aa:	6105                	addi	sp,sp,32
    800029ac:	8082                	ret

00000000800029ae <syscall>:
  // clang-format on
};

void
syscall(void)
{
    800029ae:	1101                	addi	sp,sp,-32
    800029b0:	ec06                	sd	ra,24(sp)
    800029b2:	e822                	sd	s0,16(sp)
    800029b4:	e426                	sd	s1,8(sp)
    800029b6:	e04a                	sd	s2,0(sp)
    800029b8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800029ba:	f7ffe0ef          	jal	80001938 <myproc>
    800029be:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800029c0:	06053903          	ld	s2,96(a0)
    800029c4:	0a893783          	ld	a5,168(s2)
    800029c8:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800029cc:	37fd                	addiw	a5,a5,-1
    800029ce:	4765                	li	a4,25
    800029d0:	00f76f63          	bltu	a4,a5,800029ee <syscall+0x40>
    800029d4:	00369713          	slli	a4,a3,0x3
    800029d8:	00005797          	auipc	a5,0x5
    800029dc:	db878793          	addi	a5,a5,-584 # 80007790 <syscalls>
    800029e0:	97ba                	add	a5,a5,a4
    800029e2:	639c                	ld	a5,0(a5)
    800029e4:	c789                	beqz	a5,800029ee <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800029e6:	9782                	jalr	a5
    800029e8:	06a93823          	sd	a0,112(s2)
    800029ec:	a829                	j	80002a06 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    800029ee:	16048613          	addi	a2,s1,352
    800029f2:	588c                	lw	a1,48(s1)
    800029f4:	00005517          	auipc	a0,0x5
    800029f8:	99c50513          	addi	a0,a0,-1636 # 80007390 <etext+0x390>
    800029fc:	b0ffd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    80002a00:	70bc                	ld	a5,96(s1)
    80002a02:	577d                	li	a4,-1
    80002a04:	fbb8                	sd	a4,112(a5)
  }
}
    80002a06:	60e2                	ld	ra,24(sp)
    80002a08:	6442                	ld	s0,16(sp)
    80002a0a:	64a2                	ld	s1,8(sp)
    80002a0c:	6902                	ld	s2,0(sp)
    80002a0e:	6105                	addi	sp,sp,32
    80002a10:	8082                	ret

0000000080002a12 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002a12:	1101                	addi	sp,sp,-32
    80002a14:	ec06                	sd	ra,24(sp)
    80002a16:	e822                	sd	s0,16(sp)
    80002a18:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002a1a:	fec40593          	addi	a1,s0,-20
    80002a1e:	4501                	li	a0,0
    80002a20:	f2fff0ef          	jal	8000294e <argint>
  kexit(n);
    80002a24:	fec42503          	lw	a0,-20(s0)
    80002a28:	f16ff0ef          	jal	8000213e <kexit>
  return 0; // not reached
}
    80002a2c:	4501                	li	a0,0
    80002a2e:	60e2                	ld	ra,24(sp)
    80002a30:	6442                	ld	s0,16(sp)
    80002a32:	6105                	addi	sp,sp,32
    80002a34:	8082                	ret

0000000080002a36 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a36:	1141                	addi	sp,sp,-16
    80002a38:	e406                	sd	ra,8(sp)
    80002a3a:	e022                	sd	s0,0(sp)
    80002a3c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a3e:	efbfe0ef          	jal	80001938 <myproc>
}
    80002a42:	5908                	lw	a0,48(a0)
    80002a44:	60a2                	ld	ra,8(sp)
    80002a46:	6402                	ld	s0,0(sp)
    80002a48:	0141                	addi	sp,sp,16
    80002a4a:	8082                	ret

0000000080002a4c <sys_fork>:

uint64
sys_fork(void)
{
    80002a4c:	1141                	addi	sp,sp,-16
    80002a4e:	e406                	sd	ra,8(sp)
    80002a50:	e022                	sd	s0,0(sp)
    80002a52:	0800                	addi	s0,sp,16
  return kfork();
    80002a54:	a5eff0ef          	jal	80001cb2 <kfork>
}
    80002a58:	60a2                	ld	ra,8(sp)
    80002a5a:	6402                	ld	s0,0(sp)
    80002a5c:	0141                	addi	sp,sp,16
    80002a5e:	8082                	ret

0000000080002a60 <sys_wait>:

uint64
sys_wait(void)
{
    80002a60:	1101                	addi	sp,sp,-32
    80002a62:	ec06                	sd	ra,24(sp)
    80002a64:	e822                	sd	s0,16(sp)
    80002a66:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002a68:	fe840593          	addi	a1,s0,-24
    80002a6c:	4501                	li	a0,0
    80002a6e:	efdff0ef          	jal	8000296a <argaddr>
  return kwait(p);
    80002a72:	fe843503          	ld	a0,-24(s0)
    80002a76:	823ff0ef          	jal	80002298 <kwait>
}
    80002a7a:	60e2                	ld	ra,24(sp)
    80002a7c:	6442                	ld	s0,16(sp)
    80002a7e:	6105                	addi	sp,sp,32
    80002a80:	8082                	ret

0000000080002a82 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a82:	7179                	addi	sp,sp,-48
    80002a84:	f406                	sd	ra,40(sp)
    80002a86:	f022                	sd	s0,32(sp)
    80002a88:	ec26                	sd	s1,24(sp)
    80002a8a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002a8c:	fd840593          	addi	a1,s0,-40
    80002a90:	4501                	li	a0,0
    80002a92:	ebdff0ef          	jal	8000294e <argint>
  argint(1, &t);
    80002a96:	fdc40593          	addi	a1,s0,-36
    80002a9a:	4505                	li	a0,1
    80002a9c:	eb3ff0ef          	jal	8000294e <argint>
  addr = myproc()->sz;
    80002aa0:	e99fe0ef          	jal	80001938 <myproc>
    80002aa4:	6924                	ld	s1,80(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002aa6:	fdc42703          	lw	a4,-36(s0)
    80002aaa:	4785                	li	a5,1
    80002aac:	02f70763          	beq	a4,a5,80002ada <sys_sbrk+0x58>
    80002ab0:	fd842783          	lw	a5,-40(s0)
    80002ab4:	0207c363          	bltz	a5,80002ada <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002ab8:	97a6                	add	a5,a5,s1
      return -1;
    if (addr + n > TRAPFRAME)
    80002aba:	02000737          	lui	a4,0x2000
    80002abe:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ac0:	0736                	slli	a4,a4,0xd
    80002ac2:	02f76a63          	bltu	a4,a5,80002af6 <sys_sbrk+0x74>
    80002ac6:	0297e863          	bltu	a5,s1,80002af6 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002aca:	e6ffe0ef          	jal	80001938 <myproc>
    80002ace:	fd842703          	lw	a4,-40(s0)
    80002ad2:	693c                	ld	a5,80(a0)
    80002ad4:	97ba                	add	a5,a5,a4
    80002ad6:	e93c                	sd	a5,80(a0)
    80002ad8:	a039                	j	80002ae6 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    80002ada:	fd842503          	lw	a0,-40(s0)
    80002ade:	972ff0ef          	jal	80001c50 <growproc>
    80002ae2:	00054863          	bltz	a0,80002af2 <sys_sbrk+0x70>
  }
  return addr;
}
    80002ae6:	8526                	mv	a0,s1
    80002ae8:	70a2                	ld	ra,40(sp)
    80002aea:	7402                	ld	s0,32(sp)
    80002aec:	64e2                	ld	s1,24(sp)
    80002aee:	6145                	addi	sp,sp,48
    80002af0:	8082                	ret
      return -1;
    80002af2:	54fd                	li	s1,-1
    80002af4:	bfcd                	j	80002ae6 <sys_sbrk+0x64>
      return -1;
    80002af6:	54fd                	li	s1,-1
    80002af8:	b7fd                	j	80002ae6 <sys_sbrk+0x64>

0000000080002afa <sys_pause>:

uint64
sys_pause(void)
{
    80002afa:	7139                	addi	sp,sp,-64
    80002afc:	fc06                	sd	ra,56(sp)
    80002afe:	f822                	sd	s0,48(sp)
    80002b00:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002b02:	fcc40593          	addi	a1,s0,-52
    80002b06:	4501                	li	a0,0
    80002b08:	e47ff0ef          	jal	8000294e <argint>
  if (n < 0)
    80002b0c:	fcc42783          	lw	a5,-52(s0)
    80002b10:	0807c063          	bltz	a5,80002b90 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    80002b14:	00016517          	auipc	a0,0x16
    80002b18:	a9c50513          	addi	a0,a0,-1380 # 800185b0 <tickslock>
    80002b1c:	8fcfe0ef          	jal	80000c18 <acquire>
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    80002b20:	fcc42783          	lw	a5,-52(s0)
    80002b24:	cbb9                	beqz	a5,80002b7a <sys_pause+0x80>
    80002b26:	f426                	sd	s1,40(sp)
    80002b28:	f04a                	sd	s2,32(sp)
    80002b2a:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002b2c:	00008997          	auipc	s3,0x8
    80002b30:	9349a983          	lw	s3,-1740(s3) # 8000a460 <ticks>
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    80002b34:	00008917          	auipc	s2,0x8
    80002b38:	92c90913          	addi	s2,s2,-1748 # 8000a460 <ticks>
    release(&tickslock);
    80002b3c:	00016497          	auipc	s1,0x16
    80002b40:	a7448493          	addi	s1,s1,-1420 # 800185b0 <tickslock>
    if (killed(myproc())) {
    80002b44:	df5fe0ef          	jal	80001938 <myproc>
    80002b48:	f26ff0ef          	jal	8000226e <killed>
    80002b4c:	e529                	bnez	a0,80002b96 <sys_pause+0x9c>
    sleep_prepare(&ticks);
    80002b4e:	854a                	mv	a0,s2
    80002b50:	cc6ff0ef          	jal	80002016 <sleep_prepare>
    release(&tickslock);
    80002b54:	8526                	mv	a0,s1
    80002b56:	94afe0ef          	jal	80000ca0 <release>
    sleep();
    80002b5a:	cf8ff0ef          	jal	80002052 <sleep>
    acquire(&tickslock);
    80002b5e:	8526                	mv	a0,s1
    80002b60:	8b8fe0ef          	jal	80000c18 <acquire>
  while (ticks - ticks0 < n) {
    80002b64:	00092783          	lw	a5,0(s2)
    80002b68:	413787bb          	subw	a5,a5,s3
    80002b6c:	fcc42703          	lw	a4,-52(s0)
    80002b70:	fce7eae3          	bltu	a5,a4,80002b44 <sys_pause+0x4a>
    80002b74:	74a2                	ld	s1,40(sp)
    80002b76:	7902                	ld	s2,32(sp)
    80002b78:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002b7a:	00016517          	auipc	a0,0x16
    80002b7e:	a3650513          	addi	a0,a0,-1482 # 800185b0 <tickslock>
    80002b82:	91efe0ef          	jal	80000ca0 <release>
  return 0;
    80002b86:	4501                	li	a0,0
}
    80002b88:	70e2                	ld	ra,56(sp)
    80002b8a:	7442                	ld	s0,48(sp)
    80002b8c:	6121                	addi	sp,sp,64
    80002b8e:	8082                	ret
    n = 0;
    80002b90:	fc042623          	sw	zero,-52(s0)
    80002b94:	b741                	j	80002b14 <sys_pause+0x1a>
      release(&tickslock);
    80002b96:	00016517          	auipc	a0,0x16
    80002b9a:	a1a50513          	addi	a0,a0,-1510 # 800185b0 <tickslock>
    80002b9e:	902fe0ef          	jal	80000ca0 <release>
      return -1;
    80002ba2:	557d                	li	a0,-1
    80002ba4:	74a2                	ld	s1,40(sp)
    80002ba6:	7902                	ld	s2,32(sp)
    80002ba8:	69e2                	ld	s3,24(sp)
    80002baa:	bff9                	j	80002b88 <sys_pause+0x8e>

0000000080002bac <sys_kill>:

uint64
sys_kill(void)
{
    80002bac:	1101                	addi	sp,sp,-32
    80002bae:	ec06                	sd	ra,24(sp)
    80002bb0:	e822                	sd	s0,16(sp)
    80002bb2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002bb4:	fec40593          	addi	a1,s0,-20
    80002bb8:	4501                	li	a0,0
    80002bba:	d95ff0ef          	jal	8000294e <argint>
  return kkill(pid);
    80002bbe:	fec42503          	lw	a0,-20(s0)
    80002bc2:	e22ff0ef          	jal	800021e4 <kkill>
}
    80002bc6:	60e2                	ld	ra,24(sp)
    80002bc8:	6442                	ld	s0,16(sp)
    80002bca:	6105                	addi	sp,sp,32
    80002bcc:	8082                	ret

0000000080002bce <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002bce:	1101                	addi	sp,sp,-32
    80002bd0:	ec06                	sd	ra,24(sp)
    80002bd2:	e822                	sd	s0,16(sp)
    80002bd4:	e426                	sd	s1,8(sp)
    80002bd6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bd8:	00016517          	auipc	a0,0x16
    80002bdc:	9d850513          	addi	a0,a0,-1576 # 800185b0 <tickslock>
    80002be0:	838fe0ef          	jal	80000c18 <acquire>
  xticks = ticks;
    80002be4:	00008797          	auipc	a5,0x8
    80002be8:	87c7a783          	lw	a5,-1924(a5) # 8000a460 <ticks>
    80002bec:	84be                	mv	s1,a5
  release(&tickslock);
    80002bee:	00016517          	auipc	a0,0x16
    80002bf2:	9c250513          	addi	a0,a0,-1598 # 800185b0 <tickslock>
    80002bf6:	8aafe0ef          	jal	80000ca0 <release>
  return xticks;
}
    80002bfa:	02049513          	slli	a0,s1,0x20
    80002bfe:	9101                	srli	a0,a0,0x20
    80002c00:	60e2                	ld	ra,24(sp)
    80002c02:	6442                	ld	s0,16(sp)
    80002c04:	64a2                	ld	s1,8(sp)
    80002c06:	6105                	addi	sp,sp,32
    80002c08:	8082                	ret

0000000080002c0a <sys_settickets>:
// funcao que faz a alteraçao (recebida pelo usuario e manda para o settickets)
uint64
sys_settickets(void)
{
    80002c0a:	1101                	addi	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	1000                	addi	s0,sp,32
  int number;

  argint(0, &number);
    80002c12:	fec40593          	addi	a1,s0,-20
    80002c16:	4501                	li	a0,0
    80002c18:	d37ff0ef          	jal	8000294e <argint>

  return settickets(number);
    80002c1c:	fec42503          	lw	a0,-20(s0)
    80002c20:	9a8ff0ef          	jal	80001dc8 <settickets>
}
    80002c24:	60e2                	ld	ra,24(sp)
    80002c26:	6442                	ld	s0,16(sp)
    80002c28:	6105                	addi	sp,sp,32
    80002c2a:	8082                	ret

0000000080002c2c <sys_getcontator>:
// funçao que retorna o contator no processo
uint64
sys_getcontator(void)
{
    80002c2c:	1141                	addi	sp,sp,-16
    80002c2e:	e406                	sd	ra,8(sp)
    80002c30:	e022                	sd	s0,0(sp)
    80002c32:	0800                	addi	s0,sp,16
  return getcontator();
    80002c34:	9baff0ef          	jal	80001dee <getcontator>
}
    80002c38:	60a2                	ld	ra,8(sp)
    80002c3a:	6402                	ld	s0,0(sp)
    80002c3c:	0141                	addi	sp,sp,16
    80002c3e:	8082                	ret

0000000080002c40 <sys_getlastlottery>:
// mesma coisa so que para pegar os novos valores, eu estou começando a pegar raiva do xv6
uint64
sys_getlastlottery(void)
{
    80002c40:	1141                	addi	sp,sp,-16
    80002c42:	e406                	sd	ra,8(sp)
    80002c44:	e022                	sd	s0,0(sp)
    80002c46:	0800                	addi	s0,sp,16
  return getlastlottery();
    80002c48:	9bcff0ef          	jal	80001e04 <getlastlottery>
}
    80002c4c:	60a2                	ld	ra,8(sp)
    80002c4e:	6402                	ld	s0,0(sp)
    80002c50:	0141                	addi	sp,sp,16
    80002c52:	8082                	ret

0000000080002c54 <sys_gettickets>:

uint64
sys_gettickets(void)
{
    80002c54:	1141                	addi	sp,sp,-16
    80002c56:	e406                	sd	ra,8(sp)
    80002c58:	e022                	sd	s0,0(sp)
    80002c5a:	0800                	addi	s0,sp,16
  return gettickets();
    80002c5c:	9beff0ef          	jal	80001e1a <gettickets>
    80002c60:	60a2                	ld	ra,8(sp)
    80002c62:	6402                	ld	s0,0(sp)
    80002c64:	0141                	addi	sp,sp,16
    80002c66:	8082                	ret

0000000080002c68 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002c68:	7179                	addi	sp,sp,-48
    80002c6a:	f406                	sd	ra,40(sp)
    80002c6c:	f022                	sd	s0,32(sp)
    80002c6e:	ec26                	sd	s1,24(sp)
    80002c70:	e84a                	sd	s2,16(sp)
    80002c72:	e44e                	sd	s3,8(sp)
    80002c74:	e052                	sd	s4,0(sp)
    80002c76:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002c78:	00004597          	auipc	a1,0x4
    80002c7c:	73858593          	addi	a1,a1,1848 # 800073b0 <etext+0x3b0>
    80002c80:	00016517          	auipc	a0,0x16
    80002c84:	94850513          	addi	a0,a0,-1720 # 800185c8 <bcache>
    80002c88:	f11fd0ef          	jal	80000b98 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c8c:	0001e797          	auipc	a5,0x1e
    80002c90:	93c78793          	addi	a5,a5,-1732 # 800205c8 <bcache+0x8000>
    80002c94:	0001e717          	auipc	a4,0x1e
    80002c98:	b9c70713          	addi	a4,a4,-1124 # 80020830 <bcache+0x8268>
    80002c9c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ca0:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ca4:	00016497          	auipc	s1,0x16
    80002ca8:	93c48493          	addi	s1,s1,-1732 # 800185e0 <bcache+0x18>
    b->next = bcache.head.next;
    80002cac:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002cae:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002cb0:	00004a17          	auipc	s4,0x4
    80002cb4:	708a0a13          	addi	s4,s4,1800 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002cb8:	2b893783          	ld	a5,696(s2)
    80002cbc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002cbe:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002cc2:	85d2                	mv	a1,s4
    80002cc4:	01048513          	addi	a0,s1,16
    80002cc8:	40e010ef          	jal	800040d6 <initsleeplock>
    bcache.head.next->prev = b;
    80002ccc:	2b893783          	ld	a5,696(s2)
    80002cd0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002cd2:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002cd6:	45848493          	addi	s1,s1,1112
    80002cda:	fd349fe3          	bne	s1,s3,80002cb8 <binit+0x50>
  }
}
    80002cde:	70a2                	ld	ra,40(sp)
    80002ce0:	7402                	ld	s0,32(sp)
    80002ce2:	64e2                	ld	s1,24(sp)
    80002ce4:	6942                	ld	s2,16(sp)
    80002ce6:	69a2                	ld	s3,8(sp)
    80002ce8:	6a02                	ld	s4,0(sp)
    80002cea:	6145                	addi	sp,sp,48
    80002cec:	8082                	ret

0000000080002cee <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002cee:	7179                	addi	sp,sp,-48
    80002cf0:	f406                	sd	ra,40(sp)
    80002cf2:	f022                	sd	s0,32(sp)
    80002cf4:	ec26                	sd	s1,24(sp)
    80002cf6:	e84a                	sd	s2,16(sp)
    80002cf8:	e44e                	sd	s3,8(sp)
    80002cfa:	1800                	addi	s0,sp,48
    80002cfc:	892a                	mv	s2,a0
    80002cfe:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d00:	00016517          	auipc	a0,0x16
    80002d04:	8c850513          	addi	a0,a0,-1848 # 800185c8 <bcache>
    80002d08:	f11fd0ef          	jal	80000c18 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002d0c:	0001e497          	auipc	s1,0x1e
    80002d10:	b744b483          	ld	s1,-1164(s1) # 80020880 <bcache+0x82b8>
    80002d14:	0001e797          	auipc	a5,0x1e
    80002d18:	b1c78793          	addi	a5,a5,-1252 # 80020830 <bcache+0x8268>
    80002d1c:	02f48b63          	beq	s1,a5,80002d52 <bread+0x64>
    80002d20:	873e                	mv	a4,a5
    80002d22:	a021                	j	80002d2a <bread+0x3c>
    80002d24:	68a4                	ld	s1,80(s1)
    80002d26:	02e48663          	beq	s1,a4,80002d52 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002d2a:	449c                	lw	a5,8(s1)
    80002d2c:	ff279ce3          	bne	a5,s2,80002d24 <bread+0x36>
    80002d30:	44dc                	lw	a5,12(s1)
    80002d32:	ff3799e3          	bne	a5,s3,80002d24 <bread+0x36>
      b->refcnt++;
    80002d36:	40bc                	lw	a5,64(s1)
    80002d38:	2785                	addiw	a5,a5,1
    80002d3a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d3c:	00016517          	auipc	a0,0x16
    80002d40:	88c50513          	addi	a0,a0,-1908 # 800185c8 <bcache>
    80002d44:	f5dfd0ef          	jal	80000ca0 <release>
      acquiresleep(&b->lock);
    80002d48:	01048513          	addi	a0,s1,16
    80002d4c:	3c0010ef          	jal	8000410c <acquiresleep>
      return b;
    80002d50:	a889                	j	80002da2 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d52:	0001e497          	auipc	s1,0x1e
    80002d56:	b264b483          	ld	s1,-1242(s1) # 80020878 <bcache+0x82b0>
    80002d5a:	0001e797          	auipc	a5,0x1e
    80002d5e:	ad678793          	addi	a5,a5,-1322 # 80020830 <bcache+0x8268>
    80002d62:	00f48863          	beq	s1,a5,80002d72 <bread+0x84>
    80002d66:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002d68:	40bc                	lw	a5,64(s1)
    80002d6a:	cb91                	beqz	a5,80002d7e <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002d6c:	64a4                	ld	s1,72(s1)
    80002d6e:	fee49de3          	bne	s1,a4,80002d68 <bread+0x7a>
  panic("bget: no buffers");
    80002d72:	00004517          	auipc	a0,0x4
    80002d76:	64e50513          	addi	a0,a0,1614 # 800073c0 <etext+0x3c0>
    80002d7a:	abbfd0ef          	jal	80000834 <panic>
      b->dev = dev;
    80002d7e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002d82:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002d86:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d8a:	4785                	li	a5,1
    80002d8c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d8e:	00016517          	auipc	a0,0x16
    80002d92:	83a50513          	addi	a0,a0,-1990 # 800185c8 <bcache>
    80002d96:	f0bfd0ef          	jal	80000ca0 <release>
      acquiresleep(&b->lock);
    80002d9a:	01048513          	addi	a0,s1,16
    80002d9e:	36e010ef          	jal	8000410c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002da2:	409c                	lw	a5,0(s1)
    80002da4:	cb89                	beqz	a5,80002db6 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002da6:	8526                	mv	a0,s1
    80002da8:	70a2                	ld	ra,40(sp)
    80002daa:	7402                	ld	s0,32(sp)
    80002dac:	64e2                	ld	s1,24(sp)
    80002dae:	6942                	ld	s2,16(sp)
    80002db0:	69a2                	ld	s3,8(sp)
    80002db2:	6145                	addi	sp,sp,48
    80002db4:	8082                	ret
    virtio_disk_rw(b, 0);
    80002db6:	4581                	li	a1,0
    80002db8:	8526                	mv	a0,s1
    80002dba:	487020ef          	jal	80005a40 <virtio_disk_rw>
    b->valid = 1;
    80002dbe:	4785                	li	a5,1
    80002dc0:	c09c                	sw	a5,0(s1)
  return b;
    80002dc2:	b7d5                	j	80002da6 <bread+0xb8>

0000000080002dc4 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002dc4:	1101                	addi	sp,sp,-32
    80002dc6:	ec06                	sd	ra,24(sp)
    80002dc8:	e822                	sd	s0,16(sp)
    80002dca:	e426                	sd	s1,8(sp)
    80002dcc:	1000                	addi	s0,sp,32
    80002dce:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002dd0:	0541                	addi	a0,a0,16
    80002dd2:	3c6010ef          	jal	80004198 <holdingsleep>
    80002dd6:	c911                	beqz	a0,80002dea <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002dd8:	4585                	li	a1,1
    80002dda:	8526                	mv	a0,s1
    80002ddc:	465020ef          	jal	80005a40 <virtio_disk_rw>
}
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	64a2                	ld	s1,8(sp)
    80002de6:	6105                	addi	sp,sp,32
    80002de8:	8082                	ret
    panic("bwrite");
    80002dea:	00004517          	auipc	a0,0x4
    80002dee:	5ee50513          	addi	a0,a0,1518 # 800073d8 <etext+0x3d8>
    80002df2:	a43fd0ef          	jal	80000834 <panic>

0000000080002df6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002df6:	1101                	addi	sp,sp,-32
    80002df8:	ec06                	sd	ra,24(sp)
    80002dfa:	e822                	sd	s0,16(sp)
    80002dfc:	e426                	sd	s1,8(sp)
    80002dfe:	e04a                	sd	s2,0(sp)
    80002e00:	1000                	addi	s0,sp,32
    80002e02:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002e04:	01050913          	addi	s2,a0,16
    80002e08:	854a                	mv	a0,s2
    80002e0a:	38e010ef          	jal	80004198 <holdingsleep>
    80002e0e:	c125                	beqz	a0,80002e6e <brelse+0x78>
    panic("brelse");

  releasesleep(&b->lock);
    80002e10:	854a                	mv	a0,s2
    80002e12:	34e010ef          	jal	80004160 <releasesleep>

  acquire(&bcache.lock);
    80002e16:	00015517          	auipc	a0,0x15
    80002e1a:	7b250513          	addi	a0,a0,1970 # 800185c8 <bcache>
    80002e1e:	dfbfd0ef          	jal	80000c18 <acquire>
  b->refcnt--;
    80002e22:	40bc                	lw	a5,64(s1)
    80002e24:	37fd                	addiw	a5,a5,-1
    80002e26:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e28:	e79d                	bnez	a5,80002e56 <brelse+0x60>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e2a:	68b8                	ld	a4,80(s1)
    80002e2c:	64bc                	ld	a5,72(s1)
    80002e2e:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e30:	68b8                	ld	a4,80(s1)
    80002e32:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e34:	0001d797          	auipc	a5,0x1d
    80002e38:	79478793          	addi	a5,a5,1940 # 800205c8 <bcache+0x8000>
    80002e3c:	2b87b703          	ld	a4,696(a5)
    80002e40:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e42:	0001e717          	auipc	a4,0x1e
    80002e46:	9ee70713          	addi	a4,a4,-1554 # 80020830 <bcache+0x8268>
    80002e4a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e4c:	2b87b703          	ld	a4,696(a5)
    80002e50:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e52:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002e56:	00015517          	auipc	a0,0x15
    80002e5a:	77250513          	addi	a0,a0,1906 # 800185c8 <bcache>
    80002e5e:	e43fd0ef          	jal	80000ca0 <release>
}
    80002e62:	60e2                	ld	ra,24(sp)
    80002e64:	6442                	ld	s0,16(sp)
    80002e66:	64a2                	ld	s1,8(sp)
    80002e68:	6902                	ld	s2,0(sp)
    80002e6a:	6105                	addi	sp,sp,32
    80002e6c:	8082                	ret
    panic("brelse");
    80002e6e:	00004517          	auipc	a0,0x4
    80002e72:	57250513          	addi	a0,a0,1394 # 800073e0 <etext+0x3e0>
    80002e76:	9bffd0ef          	jal	80000834 <panic>

0000000080002e7a <bpin>:

void
bpin(struct buf *b)
{
    80002e7a:	1101                	addi	sp,sp,-32
    80002e7c:	ec06                	sd	ra,24(sp)
    80002e7e:	e822                	sd	s0,16(sp)
    80002e80:	e426                	sd	s1,8(sp)
    80002e82:	1000                	addi	s0,sp,32
    80002e84:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e86:	00015517          	auipc	a0,0x15
    80002e8a:	74250513          	addi	a0,a0,1858 # 800185c8 <bcache>
    80002e8e:	d8bfd0ef          	jal	80000c18 <acquire>
  b->refcnt++;
    80002e92:	40bc                	lw	a5,64(s1)
    80002e94:	2785                	addiw	a5,a5,1
    80002e96:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e98:	00015517          	auipc	a0,0x15
    80002e9c:	73050513          	addi	a0,a0,1840 # 800185c8 <bcache>
    80002ea0:	e01fd0ef          	jal	80000ca0 <release>
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	64a2                	ld	s1,8(sp)
    80002eaa:	6105                	addi	sp,sp,32
    80002eac:	8082                	ret

0000000080002eae <bunpin>:

void
bunpin(struct buf *b)
{
    80002eae:	1101                	addi	sp,sp,-32
    80002eb0:	ec06                	sd	ra,24(sp)
    80002eb2:	e822                	sd	s0,16(sp)
    80002eb4:	e426                	sd	s1,8(sp)
    80002eb6:	1000                	addi	s0,sp,32
    80002eb8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002eba:	00015517          	auipc	a0,0x15
    80002ebe:	70e50513          	addi	a0,a0,1806 # 800185c8 <bcache>
    80002ec2:	d57fd0ef          	jal	80000c18 <acquire>
  b->refcnt--;
    80002ec6:	40bc                	lw	a5,64(s1)
    80002ec8:	37fd                	addiw	a5,a5,-1
    80002eca:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ecc:	00015517          	auipc	a0,0x15
    80002ed0:	6fc50513          	addi	a0,a0,1788 # 800185c8 <bcache>
    80002ed4:	dcdfd0ef          	jal	80000ca0 <release>
}
    80002ed8:	60e2                	ld	ra,24(sp)
    80002eda:	6442                	ld	s0,16(sp)
    80002edc:	64a2                	ld	s1,8(sp)
    80002ede:	6105                	addi	sp,sp,32
    80002ee0:	8082                	ret

0000000080002ee2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ee2:	1101                	addi	sp,sp,-32
    80002ee4:	ec06                	sd	ra,24(sp)
    80002ee6:	e822                	sd	s0,16(sp)
    80002ee8:	e426                	sd	s1,8(sp)
    80002eea:	e04a                	sd	s2,0(sp)
    80002eec:	1000                	addi	s0,sp,32
    80002eee:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ef0:	00d5d79b          	srliw	a5,a1,0xd
    80002ef4:	0001e597          	auipc	a1,0x1e
    80002ef8:	db05a583          	lw	a1,-592(a1) # 80020ca4 <sb+0x1c>
    80002efc:	9dbd                	addw	a1,a1,a5
    80002efe:	df1ff0ef          	jal	80002cee <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f02:	0074f713          	andi	a4,s1,7
    80002f06:	4785                	li	a5,1
    80002f08:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002f0c:	14ce                	slli	s1,s1,0x33
  if ((bp->data[bi / 8] & m) == 0)
    80002f0e:	90d9                	srli	s1,s1,0x36
    80002f10:	00950733          	add	a4,a0,s1
    80002f14:	05874703          	lbu	a4,88(a4)
    80002f18:	00e7f6b3          	and	a3,a5,a4
    80002f1c:	c29d                	beqz	a3,80002f42 <bfree+0x60>
    80002f1e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002f20:	94aa                	add	s1,s1,a0
    80002f22:	fff7c793          	not	a5,a5
    80002f26:	8f7d                	and	a4,a4,a5
    80002f28:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f2c:	072010ef          	jal	80003f9e <log_write>
  brelse(bp);
    80002f30:	854a                	mv	a0,s2
    80002f32:	ec5ff0ef          	jal	80002df6 <brelse>
}
    80002f36:	60e2                	ld	ra,24(sp)
    80002f38:	6442                	ld	s0,16(sp)
    80002f3a:	64a2                	ld	s1,8(sp)
    80002f3c:	6902                	ld	s2,0(sp)
    80002f3e:	6105                	addi	sp,sp,32
    80002f40:	8082                	ret
    panic("freeing free block");
    80002f42:	00004517          	auipc	a0,0x4
    80002f46:	4a650513          	addi	a0,a0,1190 # 800073e8 <etext+0x3e8>
    80002f4a:	8ebfd0ef          	jal	80000834 <panic>

0000000080002f4e <balloc>:
{
    80002f4e:	715d                	addi	sp,sp,-80
    80002f50:	e486                	sd	ra,72(sp)
    80002f52:	e0a2                	sd	s0,64(sp)
    80002f54:	fc26                	sd	s1,56(sp)
    80002f56:	0880                	addi	s0,sp,80
  for (b = 0; b < sb.size; b += BPB) {
    80002f58:	0001e797          	auipc	a5,0x1e
    80002f5c:	d347a783          	lw	a5,-716(a5) # 80020c8c <sb+0x4>
    80002f60:	0e078263          	beqz	a5,80003044 <balloc+0xf6>
    80002f64:	f84a                	sd	s2,48(sp)
    80002f66:	f44e                	sd	s3,40(sp)
    80002f68:	f052                	sd	s4,32(sp)
    80002f6a:	ec56                	sd	s5,24(sp)
    80002f6c:	e85a                	sd	s6,16(sp)
    80002f6e:	e45e                	sd	s7,8(sp)
    80002f70:	e062                	sd	s8,0(sp)
    80002f72:	8baa                	mv	s7,a0
    80002f74:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f76:	0001eb17          	auipc	s6,0x1e
    80002f7a:	d12b0b13          	addi	s6,s6,-750 # 80020c88 <sb>
      m = 1 << (bi % 8);
    80002f7e:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002f80:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002f82:	6c09                	lui	s8,0x2
    80002f84:	a09d                	j	80002fea <balloc+0x9c>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002f86:	97ca                	add	a5,a5,s2
    80002f88:	8e55                	or	a2,a2,a3
    80002f8a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002f8e:	854a                	mv	a0,s2
    80002f90:	00e010ef          	jal	80003f9e <log_write>
        brelse(bp);
    80002f94:	854a                	mv	a0,s2
    80002f96:	e61ff0ef          	jal	80002df6 <brelse>
  bp = bread(dev, bno);
    80002f9a:	85a6                	mv	a1,s1
    80002f9c:	855e                	mv	a0,s7
    80002f9e:	d51ff0ef          	jal	80002cee <bread>
    80002fa2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002fa4:	40000613          	li	a2,1024
    80002fa8:	4581                	li	a1,0
    80002faa:	05850513          	addi	a0,a0,88
    80002fae:	d2bfd0ef          	jal	80000cd8 <memset>
  log_write(bp);
    80002fb2:	854a                	mv	a0,s2
    80002fb4:	7eb000ef          	jal	80003f9e <log_write>
  brelse(bp);
    80002fb8:	854a                	mv	a0,s2
    80002fba:	e3dff0ef          	jal	80002df6 <brelse>
}
    80002fbe:	7942                	ld	s2,48(sp)
    80002fc0:	79a2                	ld	s3,40(sp)
    80002fc2:	7a02                	ld	s4,32(sp)
    80002fc4:	6ae2                	ld	s5,24(sp)
    80002fc6:	6b42                	ld	s6,16(sp)
    80002fc8:	6ba2                	ld	s7,8(sp)
    80002fca:	6c02                	ld	s8,0(sp)
}
    80002fcc:	8526                	mv	a0,s1
    80002fce:	60a6                	ld	ra,72(sp)
    80002fd0:	6406                	ld	s0,64(sp)
    80002fd2:	74e2                	ld	s1,56(sp)
    80002fd4:	6161                	addi	sp,sp,80
    80002fd6:	8082                	ret
    brelse(bp);
    80002fd8:	854a                	mv	a0,s2
    80002fda:	e1dff0ef          	jal	80002df6 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002fde:	015c0abb          	addw	s5,s8,s5
    80002fe2:	004b2783          	lw	a5,4(s6)
    80002fe6:	04faf863          	bgeu	s5,a5,80003036 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002fea:	40dad59b          	sraiw	a1,s5,0xd
    80002fee:	01cb2783          	lw	a5,28(s6)
    80002ff2:	9dbd                	addw	a1,a1,a5
    80002ff4:	855e                	mv	a0,s7
    80002ff6:	cf9ff0ef          	jal	80002cee <bread>
    80002ffa:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002ffc:	004b2503          	lw	a0,4(s6)
    80003000:	84d6                	mv	s1,s5
    80003002:	4701                	li	a4,0
    80003004:	fca4fae3          	bgeu	s1,a0,80002fd8 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003008:	00777693          	andi	a3,a4,7
    8000300c:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80003010:	41f7579b          	sraiw	a5,a4,0x1f
    80003014:	01d7d79b          	srliw	a5,a5,0x1d
    80003018:	9fb9                	addw	a5,a5,a4
    8000301a:	4037d79b          	sraiw	a5,a5,0x3
    8000301e:	00f90633          	add	a2,s2,a5
    80003022:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003026:	00c6f5b3          	and	a1,a3,a2
    8000302a:	ddb1                	beqz	a1,80002f86 <balloc+0x38>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    8000302c:	2705                	addiw	a4,a4,1
    8000302e:	2485                	addiw	s1,s1,1
    80003030:	fd471ae3          	bne	a4,s4,80003004 <balloc+0xb6>
    80003034:	b755                	j	80002fd8 <balloc+0x8a>
    80003036:	7942                	ld	s2,48(sp)
    80003038:	79a2                	ld	s3,40(sp)
    8000303a:	7a02                	ld	s4,32(sp)
    8000303c:	6ae2                	ld	s5,24(sp)
    8000303e:	6b42                	ld	s6,16(sp)
    80003040:	6ba2                	ld	s7,8(sp)
    80003042:	6c02                	ld	s8,0(sp)
  printk("balloc: out of blocks\n");
    80003044:	00004517          	auipc	a0,0x4
    80003048:	3bc50513          	addi	a0,a0,956 # 80007400 <etext+0x400>
    8000304c:	cbefd0ef          	jal	8000050a <printk>
  return 0;
    80003050:	4481                	li	s1,0
    80003052:	bfad                	j	80002fcc <balloc+0x7e>

0000000080003054 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003054:	7179                	addi	sp,sp,-48
    80003056:	f406                	sd	ra,40(sp)
    80003058:	f022                	sd	s0,32(sp)
    8000305a:	ec26                	sd	s1,24(sp)
    8000305c:	e84a                	sd	s2,16(sp)
    8000305e:	e44e                	sd	s3,8(sp)
    80003060:	1800                	addi	s0,sp,48
    80003062:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80003064:	47ad                	li	a5,11
    80003066:	02b7e363          	bltu	a5,a1,8000308c <bmap+0x38>
    if ((addr = ip->addrs[bn]) == 0) {
    8000306a:	02059793          	slli	a5,a1,0x20
    8000306e:	01e7d593          	srli	a1,a5,0x1e
    80003072:	00b509b3          	add	s3,a0,a1
    80003076:	0509a483          	lw	s1,80(s3)
    8000307a:	e0b5                	bnez	s1,800030de <bmap+0x8a>
      addr = balloc(ip->dev);
    8000307c:	4108                	lw	a0,0(a0)
    8000307e:	ed1ff0ef          	jal	80002f4e <balloc>
    80003082:	84aa                	mv	s1,a0
      if (addr == 0)
    80003084:	cd29                	beqz	a0,800030de <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003086:	04a9a823          	sw	a0,80(s3)
    8000308a:	a891                	j	800030de <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000308c:	ff45879b          	addiw	a5,a1,-12
    80003090:	873e                	mv	a4,a5
    80003092:	89be                	mv	s3,a5

  if (bn < NINDIRECT) {
    80003094:	0ff00793          	li	a5,255
    80003098:	06e7e763          	bltu	a5,a4,80003106 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    8000309c:	08052483          	lw	s1,128(a0)
    800030a0:	e891                	bnez	s1,800030b4 <bmap+0x60>
      addr = balloc(ip->dev);
    800030a2:	4108                	lw	a0,0(a0)
    800030a4:	eabff0ef          	jal	80002f4e <balloc>
    800030a8:	84aa                	mv	s1,a0
      if (addr == 0)
    800030aa:	c915                	beqz	a0,800030de <bmap+0x8a>
    800030ac:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800030ae:	08a92023          	sw	a0,128(s2)
    800030b2:	a011                	j	800030b6 <bmap+0x62>
    800030b4:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800030b6:	85a6                	mv	a1,s1
    800030b8:	00092503          	lw	a0,0(s2)
    800030bc:	c33ff0ef          	jal	80002cee <bread>
    800030c0:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    800030c2:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    800030c6:	02099713          	slli	a4,s3,0x20
    800030ca:	01e75593          	srli	a1,a4,0x1e
    800030ce:	97ae                	add	a5,a5,a1
    800030d0:	89be                	mv	s3,a5
    800030d2:	4384                	lw	s1,0(a5)
    800030d4:	cc89                	beqz	s1,800030ee <bmap+0x9a>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800030d6:	8552                	mv	a0,s4
    800030d8:	d1fff0ef          	jal	80002df6 <brelse>
    return addr;
    800030dc:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800030de:	8526                	mv	a0,s1
    800030e0:	70a2                	ld	ra,40(sp)
    800030e2:	7402                	ld	s0,32(sp)
    800030e4:	64e2                	ld	s1,24(sp)
    800030e6:	6942                	ld	s2,16(sp)
    800030e8:	69a2                	ld	s3,8(sp)
    800030ea:	6145                	addi	sp,sp,48
    800030ec:	8082                	ret
      addr = balloc(ip->dev);
    800030ee:	00092503          	lw	a0,0(s2)
    800030f2:	e5dff0ef          	jal	80002f4e <balloc>
    800030f6:	84aa                	mv	s1,a0
      if (addr) {
    800030f8:	dd79                	beqz	a0,800030d6 <bmap+0x82>
        a[bn] = addr;
    800030fa:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800030fe:	8552                	mv	a0,s4
    80003100:	69f000ef          	jal	80003f9e <log_write>
    80003104:	bfc9                	j	800030d6 <bmap+0x82>
    80003106:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003108:	00004517          	auipc	a0,0x4
    8000310c:	31050513          	addi	a0,a0,784 # 80007418 <etext+0x418>
    80003110:	f24fd0ef          	jal	80000834 <panic>

0000000080003114 <iget>:
{
    80003114:	7179                	addi	sp,sp,-48
    80003116:	f406                	sd	ra,40(sp)
    80003118:	f022                	sd	s0,32(sp)
    8000311a:	ec26                	sd	s1,24(sp)
    8000311c:	e84a                	sd	s2,16(sp)
    8000311e:	e44e                	sd	s3,8(sp)
    80003120:	e052                	sd	s4,0(sp)
    80003122:	1800                	addi	s0,sp,48
    80003124:	892a                	mv	s2,a0
    80003126:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003128:	0001e517          	auipc	a0,0x1e
    8000312c:	b8050513          	addi	a0,a0,-1152 # 80020ca8 <itable>
    80003130:	ae9fd0ef          	jal	80000c18 <acquire>
  empty = 0;
    80003134:	4981                	li	s3,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003136:	0001e497          	auipc	s1,0x1e
    8000313a:	b8a48493          	addi	s1,s1,-1142 # 80020cc0 <itable+0x18>
    8000313e:	0001f697          	auipc	a3,0x1f
    80003142:	61268693          	addi	a3,a3,1554 # 80022750 <log>
    80003146:	a809                	j	80003158 <iget+0x44>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80003148:	e781                	bnez	a5,80003150 <iget+0x3c>
    8000314a:	00099363          	bnez	s3,80003150 <iget+0x3c>
      empty = ip;
    8000314e:	89a6                	mv	s3,s1
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80003150:	08848493          	addi	s1,s1,136
    80003154:	02d48563          	beq	s1,a3,8000317e <iget+0x6a>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80003158:	449c                	lw	a5,8(s1)
    8000315a:	fef057e3          	blez	a5,80003148 <iget+0x34>
    8000315e:	4098                	lw	a4,0(s1)
    80003160:	ff2718e3          	bne	a4,s2,80003150 <iget+0x3c>
    80003164:	40d8                	lw	a4,4(s1)
    80003166:	ff4715e3          	bne	a4,s4,80003150 <iget+0x3c>
      ip->ref++;
    8000316a:	2785                	addiw	a5,a5,1
    8000316c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000316e:	0001e517          	auipc	a0,0x1e
    80003172:	b3a50513          	addi	a0,a0,-1222 # 80020ca8 <itable>
    80003176:	b2bfd0ef          	jal	80000ca0 <release>
      return ip;
    8000317a:	89a6                	mv	s3,s1
    8000317c:	a015                	j	800031a0 <iget+0x8c>
  if (empty == 0)
    8000317e:	02098a63          	beqz	s3,800031b2 <iget+0x9e>
  ip->dev = dev;
    80003182:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003186:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000318a:	4785                	li	a5,1
    8000318c:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003190:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003194:	0001e517          	auipc	a0,0x1e
    80003198:	b1450513          	addi	a0,a0,-1260 # 80020ca8 <itable>
    8000319c:	b05fd0ef          	jal	80000ca0 <release>
}
    800031a0:	854e                	mv	a0,s3
    800031a2:	70a2                	ld	ra,40(sp)
    800031a4:	7402                	ld	s0,32(sp)
    800031a6:	64e2                	ld	s1,24(sp)
    800031a8:	6942                	ld	s2,16(sp)
    800031aa:	69a2                	ld	s3,8(sp)
    800031ac:	6a02                	ld	s4,0(sp)
    800031ae:	6145                	addi	sp,sp,48
    800031b0:	8082                	ret
    panic("iget: no inodes");
    800031b2:	00004517          	auipc	a0,0x4
    800031b6:	27e50513          	addi	a0,a0,638 # 80007430 <etext+0x430>
    800031ba:	e7afd0ef          	jal	80000834 <panic>

00000000800031be <iinit>:
{
    800031be:	7179                	addi	sp,sp,-48
    800031c0:	f406                	sd	ra,40(sp)
    800031c2:	f022                	sd	s0,32(sp)
    800031c4:	ec26                	sd	s1,24(sp)
    800031c6:	e84a                	sd	s2,16(sp)
    800031c8:	e44e                	sd	s3,8(sp)
    800031ca:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800031cc:	00004597          	auipc	a1,0x4
    800031d0:	27458593          	addi	a1,a1,628 # 80007440 <etext+0x440>
    800031d4:	0001e517          	auipc	a0,0x1e
    800031d8:	ad450513          	addi	a0,a0,-1324 # 80020ca8 <itable>
    800031dc:	9bdfd0ef          	jal	80000b98 <initlock>
  for (i = 0; i < NINODE; i++) {
    800031e0:	0001e497          	auipc	s1,0x1e
    800031e4:	af048493          	addi	s1,s1,-1296 # 80020cd0 <itable+0x28>
    800031e8:	0001f997          	auipc	s3,0x1f
    800031ec:	57898993          	addi	s3,s3,1400 # 80022760 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800031f0:	00004917          	auipc	s2,0x4
    800031f4:	25890913          	addi	s2,s2,600 # 80007448 <etext+0x448>
    800031f8:	85ca                	mv	a1,s2
    800031fa:	8526                	mv	a0,s1
    800031fc:	6db000ef          	jal	800040d6 <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003200:	08848493          	addi	s1,s1,136
    80003204:	ff349ae3          	bne	s1,s3,800031f8 <iinit+0x3a>
}
    80003208:	70a2                	ld	ra,40(sp)
    8000320a:	7402                	ld	s0,32(sp)
    8000320c:	64e2                	ld	s1,24(sp)
    8000320e:	6942                	ld	s2,16(sp)
    80003210:	69a2                	ld	s3,8(sp)
    80003212:	6145                	addi	sp,sp,48
    80003214:	8082                	ret

0000000080003216 <ialloc>:
{
    80003216:	7139                	addi	sp,sp,-64
    80003218:	fc06                	sd	ra,56(sp)
    8000321a:	f822                	sd	s0,48(sp)
    8000321c:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000321e:	0001e717          	auipc	a4,0x1e
    80003222:	a7672703          	lw	a4,-1418(a4) # 80020c94 <sb+0xc>
    80003226:	4785                	li	a5,1
    80003228:	06e7f063          	bgeu	a5,a4,80003288 <ialloc+0x72>
    8000322c:	f426                	sd	s1,40(sp)
    8000322e:	f04a                	sd	s2,32(sp)
    80003230:	ec4e                	sd	s3,24(sp)
    80003232:	e852                	sd	s4,16(sp)
    80003234:	e456                	sd	s5,8(sp)
    80003236:	e05a                	sd	s6,0(sp)
    80003238:	8aaa                	mv	s5,a0
    8000323a:	8b2e                	mv	s6,a1
    8000323c:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000323e:	0001ea17          	auipc	s4,0x1e
    80003242:	a4aa0a13          	addi	s4,s4,-1462 # 80020c88 <sb>
    80003246:	00495593          	srli	a1,s2,0x4
    8000324a:	018a2783          	lw	a5,24(s4)
    8000324e:	9dbd                	addw	a1,a1,a5
    80003250:	8556                	mv	a0,s5
    80003252:	a9dff0ef          	jal	80002cee <bread>
    80003256:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    80003258:	05850993          	addi	s3,a0,88
    8000325c:	00f97793          	andi	a5,s2,15
    80003260:	079a                	slli	a5,a5,0x6
    80003262:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    80003264:	00099783          	lh	a5,0(s3)
    80003268:	cb9d                	beqz	a5,8000329e <ialloc+0x88>
    brelse(bp);
    8000326a:	b8dff0ef          	jal	80002df6 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    8000326e:	0905                	addi	s2,s2,1
    80003270:	00ca2703          	lw	a4,12(s4)
    80003274:	0009079b          	sext.w	a5,s2
    80003278:	fce7e7e3          	bltu	a5,a4,80003246 <ialloc+0x30>
    8000327c:	74a2                	ld	s1,40(sp)
    8000327e:	7902                	ld	s2,32(sp)
    80003280:	69e2                	ld	s3,24(sp)
    80003282:	6a42                	ld	s4,16(sp)
    80003284:	6aa2                	ld	s5,8(sp)
    80003286:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    80003288:	00004517          	auipc	a0,0x4
    8000328c:	1c850513          	addi	a0,a0,456 # 80007450 <etext+0x450>
    80003290:	a7afd0ef          	jal	8000050a <printk>
  return 0;
    80003294:	4501                	li	a0,0
}
    80003296:	70e2                	ld	ra,56(sp)
    80003298:	7442                	ld	s0,48(sp)
    8000329a:	6121                	addi	sp,sp,64
    8000329c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000329e:	04000613          	li	a2,64
    800032a2:	4581                	li	a1,0
    800032a4:	854e                	mv	a0,s3
    800032a6:	a33fd0ef          	jal	80000cd8 <memset>
      dip->type = type;
    800032aa:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    800032ae:	8526                	mv	a0,s1
    800032b0:	4ef000ef          	jal	80003f9e <log_write>
      brelse(bp);
    800032b4:	8526                	mv	a0,s1
    800032b6:	b41ff0ef          	jal	80002df6 <brelse>
      return iget(dev, inum);
    800032ba:	0009059b          	sext.w	a1,s2
    800032be:	8556                	mv	a0,s5
    800032c0:	e55ff0ef          	jal	80003114 <iget>
    800032c4:	74a2                	ld	s1,40(sp)
    800032c6:	7902                	ld	s2,32(sp)
    800032c8:	69e2                	ld	s3,24(sp)
    800032ca:	6a42                	ld	s4,16(sp)
    800032cc:	6aa2                	ld	s5,8(sp)
    800032ce:	6b02                	ld	s6,0(sp)
    800032d0:	b7d9                	j	80003296 <ialloc+0x80>

00000000800032d2 <iupdate>:
{
    800032d2:	1101                	addi	sp,sp,-32
    800032d4:	ec06                	sd	ra,24(sp)
    800032d6:	e822                	sd	s0,16(sp)
    800032d8:	e426                	sd	s1,8(sp)
    800032da:	e04a                	sd	s2,0(sp)
    800032dc:	1000                	addi	s0,sp,32
    800032de:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032e0:	415c                	lw	a5,4(a0)
    800032e2:	0047d79b          	srliw	a5,a5,0x4
    800032e6:	0001e597          	auipc	a1,0x1e
    800032ea:	9ba5a583          	lw	a1,-1606(a1) # 80020ca0 <sb+0x18>
    800032ee:	9dbd                	addw	a1,a1,a5
    800032f0:	4108                	lw	a0,0(a0)
    800032f2:	9fdff0ef          	jal	80002cee <bread>
    800032f6:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    800032f8:	05850793          	addi	a5,a0,88
    800032fc:	40d8                	lw	a4,4(s1)
    800032fe:	8b3d                	andi	a4,a4,15
    80003300:	071a                	slli	a4,a4,0x6
    80003302:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003304:	04449703          	lh	a4,68(s1)
    80003308:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000330c:	04649703          	lh	a4,70(s1)
    80003310:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003314:	04849703          	lh	a4,72(s1)
    80003318:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000331c:	04a49703          	lh	a4,74(s1)
    80003320:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003324:	44f8                	lw	a4,76(s1)
    80003326:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003328:	03400613          	li	a2,52
    8000332c:	05048593          	addi	a1,s1,80
    80003330:	00c78513          	addi	a0,a5,12
    80003334:	a05fd0ef          	jal	80000d38 <memmove>
  log_write(bp);
    80003338:	854a                	mv	a0,s2
    8000333a:	465000ef          	jal	80003f9e <log_write>
  brelse(bp);
    8000333e:	854a                	mv	a0,s2
    80003340:	ab7ff0ef          	jal	80002df6 <brelse>
}
    80003344:	60e2                	ld	ra,24(sp)
    80003346:	6442                	ld	s0,16(sp)
    80003348:	64a2                	ld	s1,8(sp)
    8000334a:	6902                	ld	s2,0(sp)
    8000334c:	6105                	addi	sp,sp,32
    8000334e:	8082                	ret

0000000080003350 <idup>:
{
    80003350:	1101                	addi	sp,sp,-32
    80003352:	ec06                	sd	ra,24(sp)
    80003354:	e822                	sd	s0,16(sp)
    80003356:	e426                	sd	s1,8(sp)
    80003358:	1000                	addi	s0,sp,32
    8000335a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000335c:	0001e517          	auipc	a0,0x1e
    80003360:	94c50513          	addi	a0,a0,-1716 # 80020ca8 <itable>
    80003364:	8b5fd0ef          	jal	80000c18 <acquire>
  ip->ref++;
    80003368:	449c                	lw	a5,8(s1)
    8000336a:	2785                	addiw	a5,a5,1
    8000336c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000336e:	0001e517          	auipc	a0,0x1e
    80003372:	93a50513          	addi	a0,a0,-1734 # 80020ca8 <itable>
    80003376:	92bfd0ef          	jal	80000ca0 <release>
}
    8000337a:	8526                	mv	a0,s1
    8000337c:	60e2                	ld	ra,24(sp)
    8000337e:	6442                	ld	s0,16(sp)
    80003380:	64a2                	ld	s1,8(sp)
    80003382:	6105                	addi	sp,sp,32
    80003384:	8082                	ret

0000000080003386 <ilock>:
{
    80003386:	1101                	addi	sp,sp,-32
    80003388:	ec06                	sd	ra,24(sp)
    8000338a:	e822                	sd	s0,16(sp)
    8000338c:	e426                	sd	s1,8(sp)
    8000338e:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003390:	cd19                	beqz	a0,800033ae <ilock+0x28>
    80003392:	84aa                	mv	s1,a0
    80003394:	451c                	lw	a5,8(a0)
    80003396:	00f05c63          	blez	a5,800033ae <ilock+0x28>
  acquiresleep(&ip->lock);
    8000339a:	0541                	addi	a0,a0,16
    8000339c:	571000ef          	jal	8000410c <acquiresleep>
  if (ip->valid == 0) {
    800033a0:	40bc                	lw	a5,64(s1)
    800033a2:	cf89                	beqz	a5,800033bc <ilock+0x36>
}
    800033a4:	60e2                	ld	ra,24(sp)
    800033a6:	6442                	ld	s0,16(sp)
    800033a8:	64a2                	ld	s1,8(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret
    800033ae:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800033b0:	00004517          	auipc	a0,0x4
    800033b4:	0b850513          	addi	a0,a0,184 # 80007468 <etext+0x468>
    800033b8:	c7cfd0ef          	jal	80000834 <panic>
    800033bc:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033be:	40dc                	lw	a5,4(s1)
    800033c0:	0047d79b          	srliw	a5,a5,0x4
    800033c4:	0001e597          	auipc	a1,0x1e
    800033c8:	8dc5a583          	lw	a1,-1828(a1) # 80020ca0 <sb+0x18>
    800033cc:	9dbd                	addw	a1,a1,a5
    800033ce:	4088                	lw	a0,0(s1)
    800033d0:	91fff0ef          	jal	80002cee <bread>
    800033d4:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    800033d6:	05850593          	addi	a1,a0,88
    800033da:	40dc                	lw	a5,4(s1)
    800033dc:	8bbd                	andi	a5,a5,15
    800033de:	079a                	slli	a5,a5,0x6
    800033e0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800033e2:	00059783          	lh	a5,0(a1)
    800033e6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800033ea:	00259783          	lh	a5,2(a1)
    800033ee:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800033f2:	00459783          	lh	a5,4(a1)
    800033f6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800033fa:	00659783          	lh	a5,6(a1)
    800033fe:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003402:	459c                	lw	a5,8(a1)
    80003404:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003406:	03400613          	li	a2,52
    8000340a:	05b1                	addi	a1,a1,12
    8000340c:	05048513          	addi	a0,s1,80
    80003410:	929fd0ef          	jal	80000d38 <memmove>
    brelse(bp);
    80003414:	854a                	mv	a0,s2
    80003416:	9e1ff0ef          	jal	80002df6 <brelse>
    ip->valid = 1;
    8000341a:	4785                	li	a5,1
    8000341c:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    8000341e:	04449783          	lh	a5,68(s1)
    80003422:	c399                	beqz	a5,80003428 <ilock+0xa2>
    80003424:	6902                	ld	s2,0(sp)
    80003426:	bfbd                	j	800033a4 <ilock+0x1e>
      panic("ilock: no type");
    80003428:	00004517          	auipc	a0,0x4
    8000342c:	04850513          	addi	a0,a0,72 # 80007470 <etext+0x470>
    80003430:	c04fd0ef          	jal	80000834 <panic>

0000000080003434 <iunlock>:
{
    80003434:	1101                	addi	sp,sp,-32
    80003436:	ec06                	sd	ra,24(sp)
    80003438:	e822                	sd	s0,16(sp)
    8000343a:	e426                	sd	s1,8(sp)
    8000343c:	e04a                	sd	s2,0(sp)
    8000343e:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003440:	c505                	beqz	a0,80003468 <iunlock+0x34>
    80003442:	84aa                	mv	s1,a0
    80003444:	01050913          	addi	s2,a0,16
    80003448:	854a                	mv	a0,s2
    8000344a:	54f000ef          	jal	80004198 <holdingsleep>
    8000344e:	cd09                	beqz	a0,80003468 <iunlock+0x34>
    80003450:	449c                	lw	a5,8(s1)
    80003452:	00f05b63          	blez	a5,80003468 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003456:	854a                	mv	a0,s2
    80003458:	509000ef          	jal	80004160 <releasesleep>
}
    8000345c:	60e2                	ld	ra,24(sp)
    8000345e:	6442                	ld	s0,16(sp)
    80003460:	64a2                	ld	s1,8(sp)
    80003462:	6902                	ld	s2,0(sp)
    80003464:	6105                	addi	sp,sp,32
    80003466:	8082                	ret
    panic("iunlock");
    80003468:	00004517          	auipc	a0,0x4
    8000346c:	01850513          	addi	a0,a0,24 # 80007480 <etext+0x480>
    80003470:	bc4fd0ef          	jal	80000834 <panic>

0000000080003474 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003474:	7179                	addi	sp,sp,-48
    80003476:	f406                	sd	ra,40(sp)
    80003478:	f022                	sd	s0,32(sp)
    8000347a:	ec26                	sd	s1,24(sp)
    8000347c:	e84a                	sd	s2,16(sp)
    8000347e:	e44e                	sd	s3,8(sp)
    80003480:	1800                	addi	s0,sp,48
    80003482:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    80003484:	05050493          	addi	s1,a0,80
    80003488:	08050913          	addi	s2,a0,128
    8000348c:	a021                	j	80003494 <itrunc+0x20>
    8000348e:	0491                	addi	s1,s1,4
    80003490:	01248b63          	beq	s1,s2,800034a6 <itrunc+0x32>
    if (ip->addrs[i]) {
    80003494:	408c                	lw	a1,0(s1)
    80003496:	dde5                	beqz	a1,8000348e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003498:	0009a503          	lw	a0,0(s3)
    8000349c:	a47ff0ef          	jal	80002ee2 <bfree>
      ip->addrs[i] = 0;
    800034a0:	0004a023          	sw	zero,0(s1)
    800034a4:	b7ed                	j	8000348e <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    800034a6:	0809a583          	lw	a1,128(s3)
    800034aa:	ed89                	bnez	a1,800034c4 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800034ac:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800034b0:	854e                	mv	a0,s3
    800034b2:	e21ff0ef          	jal	800032d2 <iupdate>
}
    800034b6:	70a2                	ld	ra,40(sp)
    800034b8:	7402                	ld	s0,32(sp)
    800034ba:	64e2                	ld	s1,24(sp)
    800034bc:	6942                	ld	s2,16(sp)
    800034be:	69a2                	ld	s3,8(sp)
    800034c0:	6145                	addi	sp,sp,48
    800034c2:	8082                	ret
    800034c4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800034c6:	0009a503          	lw	a0,0(s3)
    800034ca:	825ff0ef          	jal	80002cee <bread>
    800034ce:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    800034d0:	05850493          	addi	s1,a0,88
    800034d4:	45850913          	addi	s2,a0,1112
    800034d8:	a021                	j	800034e0 <itrunc+0x6c>
    800034da:	0491                	addi	s1,s1,4
    800034dc:	01248963          	beq	s1,s2,800034ee <itrunc+0x7a>
      if (a[j])
    800034e0:	408c                	lw	a1,0(s1)
    800034e2:	dde5                	beqz	a1,800034da <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800034e4:	0009a503          	lw	a0,0(s3)
    800034e8:	9fbff0ef          	jal	80002ee2 <bfree>
    800034ec:	b7fd                	j	800034da <itrunc+0x66>
    brelse(bp);
    800034ee:	8552                	mv	a0,s4
    800034f0:	907ff0ef          	jal	80002df6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800034f4:	0809a583          	lw	a1,128(s3)
    800034f8:	0009a503          	lw	a0,0(s3)
    800034fc:	9e7ff0ef          	jal	80002ee2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003500:	0809a023          	sw	zero,128(s3)
    80003504:	6a02                	ld	s4,0(sp)
    80003506:	b75d                	j	800034ac <itrunc+0x38>

0000000080003508 <iput>:
{
    80003508:	7179                	addi	sp,sp,-48
    8000350a:	f406                	sd	ra,40(sp)
    8000350c:	f022                	sd	s0,32(sp)
    8000350e:	ec26                	sd	s1,24(sp)
    80003510:	1800                	addi	s0,sp,48
    80003512:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003514:	0001d517          	auipc	a0,0x1d
    80003518:	79450513          	addi	a0,a0,1940 # 80020ca8 <itable>
    8000351c:	efcfd0ef          	jal	80000c18 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003520:	449c                	lw	a5,8(s1)
    80003522:	4705                	li	a4,1
    80003524:	00e78f63          	beq	a5,a4,80003542 <iput+0x3a>
  ip->ref--;
    80003528:	37fd                	addiw	a5,a5,-1
    8000352a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000352c:	0001d517          	auipc	a0,0x1d
    80003530:	77c50513          	addi	a0,a0,1916 # 80020ca8 <itable>
    80003534:	f6cfd0ef          	jal	80000ca0 <release>
}
    80003538:	70a2                	ld	ra,40(sp)
    8000353a:	7402                	ld	s0,32(sp)
    8000353c:	64e2                	ld	s1,24(sp)
    8000353e:	6145                	addi	sp,sp,48
    80003540:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003542:	40b8                	lw	a4,64(s1)
    80003544:	d375                	beqz	a4,80003528 <iput+0x20>
    80003546:	e84a                	sd	s2,16(sp)
    80003548:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    8000354a:	0004aa03          	lw	s4,0(s1)
    8000354e:	0044a903          	lw	s2,4(s1)
  if (last) {
    80003552:	04a49703          	lh	a4,74(s1)
    80003556:	ef3d                	bnez	a4,800035d4 <iput+0xcc>
    80003558:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    8000355a:	01048793          	addi	a5,s1,16
    8000355e:	89be                	mv	s3,a5
    80003560:	853e                	mv	a0,a5
    80003562:	3ab000ef          	jal	8000410c <acquiresleep>
    release(&itable.lock);
    80003566:	0001d517          	auipc	a0,0x1d
    8000356a:	74250513          	addi	a0,a0,1858 # 80020ca8 <itable>
    8000356e:	f32fd0ef          	jal	80000ca0 <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    80003572:	8526                	mv	a0,s1
    80003574:	f01ff0ef          	jal	80003474 <itrunc>
    ip->valid = 0;
    80003578:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000357c:	854e                	mv	a0,s3
    8000357e:	3e3000ef          	jal	80004160 <releasesleep>
    acquire(&itable.lock);
    80003582:	0001d517          	auipc	a0,0x1d
    80003586:	72650513          	addi	a0,a0,1830 # 80020ca8 <itable>
    8000358a:	e8efd0ef          	jal	80000c18 <acquire>
  ip->ref--;
    8000358e:	449c                	lw	a5,8(s1)
    80003590:	37fd                	addiw	a5,a5,-1
    80003592:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003594:	0001d517          	auipc	a0,0x1d
    80003598:	71450513          	addi	a0,a0,1812 # 80020ca8 <itable>
    8000359c:	f04fd0ef          	jal	80000ca0 <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800035a0:	0049579b          	srliw	a5,s2,0x4
    800035a4:	0001d597          	auipc	a1,0x1d
    800035a8:	6fc5a583          	lw	a1,1788(a1) # 80020ca0 <sb+0x18>
    800035ac:	9dbd                	addw	a1,a1,a5
    800035ae:	8552                	mv	a0,s4
    800035b0:	f3eff0ef          	jal	80002cee <bread>
    800035b4:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800035b6:	00f97793          	andi	a5,s2,15
  dip->type = 0;
    800035ba:	079a                	slli	a5,a5,0x6
    800035bc:	97aa                	add	a5,a5,a0
    800035be:	04079c23          	sh	zero,88(a5)
  log_write(bp);
    800035c2:	1dd000ef          	jal	80003f9e <log_write>
  brelse(bp);
    800035c6:	8526                	mv	a0,s1
    800035c8:	82fff0ef          	jal	80002df6 <brelse>
}
    800035cc:	6942                	ld	s2,16(sp)
    800035ce:	69a2                	ld	s3,8(sp)
    800035d0:	6a02                	ld	s4,0(sp)
    800035d2:	b79d                	j	80003538 <iput+0x30>
    800035d4:	6942                	ld	s2,16(sp)
    800035d6:	6a02                	ld	s4,0(sp)
    800035d8:	bf81                	j	80003528 <iput+0x20>

00000000800035da <iunlockput>:
{
    800035da:	1101                	addi	sp,sp,-32
    800035dc:	ec06                	sd	ra,24(sp)
    800035de:	e822                	sd	s0,16(sp)
    800035e0:	e426                	sd	s1,8(sp)
    800035e2:	1000                	addi	s0,sp,32
    800035e4:	84aa                	mv	s1,a0
  iunlock(ip);
    800035e6:	e4fff0ef          	jal	80003434 <iunlock>
  iput(ip);
    800035ea:	8526                	mv	a0,s1
    800035ec:	f1dff0ef          	jal	80003508 <iput>
}
    800035f0:	60e2                	ld	ra,24(sp)
    800035f2:	6442                	ld	s0,16(sp)
    800035f4:	64a2                	ld	s1,8(sp)
    800035f6:	6105                	addi	sp,sp,32
    800035f8:	8082                	ret

00000000800035fa <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800035fa:	0001d717          	auipc	a4,0x1d
    800035fe:	69a72703          	lw	a4,1690(a4) # 80020c94 <sb+0xc>
    80003602:	4785                	li	a5,1
    80003604:	0ae7fe63          	bgeu	a5,a4,800036c0 <ireclaim+0xc6>
{
    80003608:	7139                	addi	sp,sp,-64
    8000360a:	fc06                	sd	ra,56(sp)
    8000360c:	f822                	sd	s0,48(sp)
    8000360e:	f426                	sd	s1,40(sp)
    80003610:	f04a                	sd	s2,32(sp)
    80003612:	ec4e                	sd	s3,24(sp)
    80003614:	e852                	sd	s4,16(sp)
    80003616:	e456                	sd	s5,8(sp)
    80003618:	e05a                	sd	s6,0(sp)
    8000361a:	0080                	addi	s0,sp,64
    8000361c:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000361e:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003620:	0001da17          	auipc	s4,0x1d
    80003624:	668a0a13          	addi	s4,s4,1640 # 80020c88 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    80003628:	00004b17          	auipc	s6,0x4
    8000362c:	e60b0b13          	addi	s6,s6,-416 # 80007488 <etext+0x488>
    80003630:	a099                	j	80003676 <ireclaim+0x7c>
    80003632:	85ce                	mv	a1,s3
    80003634:	855a                	mv	a0,s6
    80003636:	ed5fc0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    8000363a:	85ce                	mv	a1,s3
    8000363c:	8556                	mv	a0,s5
    8000363e:	ad7ff0ef          	jal	80003114 <iget>
    80003642:	89aa                	mv	s3,a0
    brelse(bp);
    80003644:	854a                	mv	a0,s2
    80003646:	fb0ff0ef          	jal	80002df6 <brelse>
    if (ip) {
    8000364a:	00098f63          	beqz	s3,80003668 <ireclaim+0x6e>
      begin_op();
    8000364e:	7a2000ef          	jal	80003df0 <begin_op>
      ilock(ip);
    80003652:	854e                	mv	a0,s3
    80003654:	d33ff0ef          	jal	80003386 <ilock>
      iunlock(ip);
    80003658:	854e                	mv	a0,s3
    8000365a:	ddbff0ef          	jal	80003434 <iunlock>
      iput(ip);
    8000365e:	854e                	mv	a0,s3
    80003660:	ea9ff0ef          	jal	80003508 <iput>
      end_op();
    80003664:	019000ef          	jal	80003e7c <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003668:	0485                	addi	s1,s1,1
    8000366a:	00ca2703          	lw	a4,12(s4)
    8000366e:	0004879b          	sext.w	a5,s1
    80003672:	02e7fd63          	bgeu	a5,a4,800036ac <ireclaim+0xb2>
    80003676:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000367a:	0044d593          	srli	a1,s1,0x4
    8000367e:	018a2783          	lw	a5,24(s4)
    80003682:	9dbd                	addw	a1,a1,a5
    80003684:	8556                	mv	a0,s5
    80003686:	e68ff0ef          	jal	80002cee <bread>
    8000368a:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000368c:	05850793          	addi	a5,a0,88
    80003690:	00f9f713          	andi	a4,s3,15
    80003694:	071a                	slli	a4,a4,0x6
    80003696:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    80003698:	00079703          	lh	a4,0(a5)
    8000369c:	c701                	beqz	a4,800036a4 <ireclaim+0xaa>
    8000369e:	00679783          	lh	a5,6(a5)
    800036a2:	dbc1                	beqz	a5,80003632 <ireclaim+0x38>
    brelse(bp);
    800036a4:	854a                	mv	a0,s2
    800036a6:	f50ff0ef          	jal	80002df6 <brelse>
    if (ip) {
    800036aa:	bf7d                	j	80003668 <ireclaim+0x6e>
}
    800036ac:	70e2                	ld	ra,56(sp)
    800036ae:	7442                	ld	s0,48(sp)
    800036b0:	74a2                	ld	s1,40(sp)
    800036b2:	7902                	ld	s2,32(sp)
    800036b4:	69e2                	ld	s3,24(sp)
    800036b6:	6a42                	ld	s4,16(sp)
    800036b8:	6aa2                	ld	s5,8(sp)
    800036ba:	6b02                	ld	s6,0(sp)
    800036bc:	6121                	addi	sp,sp,64
    800036be:	8082                	ret
    800036c0:	8082                	ret

00000000800036c2 <fsinit>:
{
    800036c2:	1101                	addi	sp,sp,-32
    800036c4:	ec06                	sd	ra,24(sp)
    800036c6:	e822                	sd	s0,16(sp)
    800036c8:	e426                	sd	s1,8(sp)
    800036ca:	e04a                	sd	s2,0(sp)
    800036cc:	1000                	addi	s0,sp,32
    800036ce:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036d0:	4585                	li	a1,1
    800036d2:	e1cff0ef          	jal	80002cee <bread>
    800036d6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036d8:	02000613          	li	a2,32
    800036dc:	05850593          	addi	a1,a0,88
    800036e0:	0001d517          	auipc	a0,0x1d
    800036e4:	5a850513          	addi	a0,a0,1448 # 80020c88 <sb>
    800036e8:	e50fd0ef          	jal	80000d38 <memmove>
  brelse(bp);
    800036ec:	8526                	mv	a0,s1
    800036ee:	f08ff0ef          	jal	80002df6 <brelse>
  if (sb.magic != FSMAGIC)
    800036f2:	0001d717          	auipc	a4,0x1d
    800036f6:	59672703          	lw	a4,1430(a4) # 80020c88 <sb>
    800036fa:	102037b7          	lui	a5,0x10203
    800036fe:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003702:	02f71263          	bne	a4,a5,80003726 <fsinit+0x64>
  initlog(dev, &sb);
    80003706:	0001d597          	auipc	a1,0x1d
    8000370a:	58258593          	addi	a1,a1,1410 # 80020c88 <sb>
    8000370e:	854a                	mv	a0,s2
    80003710:	65e000ef          	jal	80003d6e <initlog>
  ireclaim(dev);
    80003714:	854a                	mv	a0,s2
    80003716:	ee5ff0ef          	jal	800035fa <ireclaim>
}
    8000371a:	60e2                	ld	ra,24(sp)
    8000371c:	6442                	ld	s0,16(sp)
    8000371e:	64a2                	ld	s1,8(sp)
    80003720:	6902                	ld	s2,0(sp)
    80003722:	6105                	addi	sp,sp,32
    80003724:	8082                	ret
    panic("invalid file system");
    80003726:	00004517          	auipc	a0,0x4
    8000372a:	d8250513          	addi	a0,a0,-638 # 800074a8 <etext+0x4a8>
    8000372e:	906fd0ef          	jal	80000834 <panic>

0000000080003732 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003732:	1141                	addi	sp,sp,-16
    80003734:	e406                	sd	ra,8(sp)
    80003736:	e022                	sd	s0,0(sp)
    80003738:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    8000373a:	411c                	lw	a5,0(a0)
    8000373c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000373e:	415c                	lw	a5,4(a0)
    80003740:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003742:	04451783          	lh	a5,68(a0)
    80003746:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000374a:	04a51783          	lh	a5,74(a0)
    8000374e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003752:	04c56783          	lwu	a5,76(a0)
    80003756:	e99c                	sd	a5,16(a1)
}
    80003758:	60a2                	ld	ra,8(sp)
    8000375a:	6402                	ld	s0,0(sp)
    8000375c:	0141                	addi	sp,sp,16
    8000375e:	8082                	ret

0000000080003760 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003760:	457c                	lw	a5,76(a0)
    80003762:	0ed7e663          	bltu	a5,a3,8000384e <readi+0xee>
{
    80003766:	7159                	addi	sp,sp,-112
    80003768:	f486                	sd	ra,104(sp)
    8000376a:	f0a2                	sd	s0,96(sp)
    8000376c:	eca6                	sd	s1,88(sp)
    8000376e:	e0d2                	sd	s4,64(sp)
    80003770:	fc56                	sd	s5,56(sp)
    80003772:	f85a                	sd	s6,48(sp)
    80003774:	f45e                	sd	s7,40(sp)
    80003776:	1880                	addi	s0,sp,112
    80003778:	8b2a                	mv	s6,a0
    8000377a:	8bae                	mv	s7,a1
    8000377c:	8a32                	mv	s4,a2
    8000377e:	84b6                	mv	s1,a3
    80003780:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    80003782:	9f35                	addw	a4,a4,a3
    return 0;
    80003784:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    80003786:	0ad76b63          	bltu	a4,a3,8000383c <readi+0xdc>
    8000378a:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    8000378c:	00e7f463          	bgeu	a5,a4,80003794 <readi+0x34>
    n = ip->size - off;
    80003790:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003794:	080a8b63          	beqz	s5,8000382a <readi+0xca>
    80003798:	e8ca                	sd	s2,80(sp)
    8000379a:	f062                	sd	s8,32(sp)
    8000379c:	ec66                	sd	s9,24(sp)
    8000379e:	e86a                	sd	s10,16(sp)
    800037a0:	e46e                	sd	s11,8(sp)
    800037a2:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    800037a4:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800037a8:	5c7d                	li	s8,-1
    800037aa:	a80d                	j	800037dc <readi+0x7c>
    800037ac:	020d1d93          	slli	s11,s10,0x20
    800037b0:	020ddd93          	srli	s11,s11,0x20
    800037b4:	05890613          	addi	a2,s2,88
    800037b8:	86ee                	mv	a3,s11
    800037ba:	963e                	add	a2,a2,a5
    800037bc:	85d2                	mv	a1,s4
    800037be:	855e                	mv	a0,s7
    800037c0:	be3fe0ef          	jal	800023a2 <either_copyout>
    800037c4:	05850363          	beq	a0,s8,8000380a <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800037c8:	854a                	mv	a0,s2
    800037ca:	e2cff0ef          	jal	80002df6 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800037ce:	013d09bb          	addw	s3,s10,s3
    800037d2:	009d04bb          	addw	s1,s10,s1
    800037d6:	9a6e                	add	s4,s4,s11
    800037d8:	0559f363          	bgeu	s3,s5,8000381e <readi+0xbe>
    uint addr = bmap(ip, off / BSIZE);
    800037dc:	00a4d59b          	srliw	a1,s1,0xa
    800037e0:	855a                	mv	a0,s6
    800037e2:	873ff0ef          	jal	80003054 <bmap>
    800037e6:	85aa                	mv	a1,a0
    if (addr == 0)
    800037e8:	c139                	beqz	a0,8000382e <readi+0xce>
    bp = bread(ip->dev, addr);
    800037ea:	000b2503          	lw	a0,0(s6)
    800037ee:	d00ff0ef          	jal	80002cee <bread>
    800037f2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800037f4:	3ff4f793          	andi	a5,s1,1023
    800037f8:	40fc873b          	subw	a4,s9,a5
    800037fc:	413a86bb          	subw	a3,s5,s3
    80003800:	8d3a                	mv	s10,a4
    80003802:	fae6f5e3          	bgeu	a3,a4,800037ac <readi+0x4c>
    80003806:	8d36                	mv	s10,a3
    80003808:	b755                	j	800037ac <readi+0x4c>
      brelse(bp);
    8000380a:	854a                	mv	a0,s2
    8000380c:	deaff0ef          	jal	80002df6 <brelse>
      tot = -1;
    80003810:	59fd                	li	s3,-1
      break;
    80003812:	6946                	ld	s2,80(sp)
    80003814:	7c02                	ld	s8,32(sp)
    80003816:	6ce2                	ld	s9,24(sp)
    80003818:	6d42                	ld	s10,16(sp)
    8000381a:	6da2                	ld	s11,8(sp)
    8000381c:	a831                	j	80003838 <readi+0xd8>
    8000381e:	6946                	ld	s2,80(sp)
    80003820:	7c02                	ld	s8,32(sp)
    80003822:	6ce2                	ld	s9,24(sp)
    80003824:	6d42                	ld	s10,16(sp)
    80003826:	6da2                	ld	s11,8(sp)
    80003828:	a801                	j	80003838 <readi+0xd8>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    8000382a:	89d6                	mv	s3,s5
    8000382c:	a031                	j	80003838 <readi+0xd8>
    8000382e:	6946                	ld	s2,80(sp)
    80003830:	7c02                	ld	s8,32(sp)
    80003832:	6ce2                	ld	s9,24(sp)
    80003834:	6d42                	ld	s10,16(sp)
    80003836:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003838:	854e                	mv	a0,s3
    8000383a:	69a6                	ld	s3,72(sp)
}
    8000383c:	70a6                	ld	ra,104(sp)
    8000383e:	7406                	ld	s0,96(sp)
    80003840:	64e6                	ld	s1,88(sp)
    80003842:	6a06                	ld	s4,64(sp)
    80003844:	7ae2                	ld	s5,56(sp)
    80003846:	7b42                	ld	s6,48(sp)
    80003848:	7ba2                	ld	s7,40(sp)
    8000384a:	6165                	addi	sp,sp,112
    8000384c:	8082                	ret
    return 0;
    8000384e:	4501                	li	a0,0
}
    80003850:	8082                	ret

0000000080003852 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    80003852:	457c                	lw	a5,76(a0)
    80003854:	0ed7ee63          	bltu	a5,a3,80003950 <writei+0xfe>
{
    80003858:	7159                	addi	sp,sp,-112
    8000385a:	f486                	sd	ra,104(sp)
    8000385c:	f0a2                	sd	s0,96(sp)
    8000385e:	e8ca                	sd	s2,80(sp)
    80003860:	e0d2                	sd	s4,64(sp)
    80003862:	fc56                	sd	s5,56(sp)
    80003864:	f85a                	sd	s6,48(sp)
    80003866:	f45e                	sd	s7,40(sp)
    80003868:	1880                	addi	s0,sp,112
    8000386a:	8aaa                	mv	s5,a0
    8000386c:	8bae                	mv	s7,a1
    8000386e:	8a32                	mv	s4,a2
    80003870:	8936                	mv	s2,a3
    80003872:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    80003874:	00e687bb          	addw	a5,a3,a4
    return -1;
  if (off + n > MAXFILE * BSIZE)
    80003878:	00043737          	lui	a4,0x43
    8000387c:	0cf76c63          	bltu	a4,a5,80003954 <writei+0x102>
    80003880:	0cd7ea63          	bltu	a5,a3,80003954 <writei+0x102>
    80003884:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003886:	0a0b0d63          	beqz	s6,80003940 <writei+0xee>
    8000388a:	eca6                	sd	s1,88(sp)
    8000388c:	f062                	sd	s8,32(sp)
    8000388e:	ec66                	sd	s9,24(sp)
    80003890:	e86a                	sd	s10,16(sp)
    80003892:	e46e                	sd	s11,8(sp)
    80003894:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003896:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000389a:	5c7d                	li	s8,-1
    8000389c:	a825                	j	800038d4 <writei+0x82>
    8000389e:	020d1d93          	slli	s11,s10,0x20
    800038a2:	020ddd93          	srli	s11,s11,0x20
    800038a6:	05848513          	addi	a0,s1,88
    800038aa:	86ee                	mv	a3,s11
    800038ac:	8652                	mv	a2,s4
    800038ae:	85de                	mv	a1,s7
    800038b0:	953e                	add	a0,a0,a5
    800038b2:	b3dfe0ef          	jal	800023ee <either_copyin>
    800038b6:	05850663          	beq	a0,s8,80003902 <writei+0xb0>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    800038ba:	8526                	mv	a0,s1
    800038bc:	6e2000ef          	jal	80003f9e <log_write>
    brelse(bp);
    800038c0:	8526                	mv	a0,s1
    800038c2:	d34ff0ef          	jal	80002df6 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800038c6:	013d09bb          	addw	s3,s10,s3
    800038ca:	012d093b          	addw	s2,s10,s2
    800038ce:	9a6e                	add	s4,s4,s11
    800038d0:	0369ff63          	bgeu	s3,s6,8000390e <writei+0xbc>
    uint addr = bmap(ip, off / BSIZE);
    800038d4:	00a9559b          	srliw	a1,s2,0xa
    800038d8:	8556                	mv	a0,s5
    800038da:	f7aff0ef          	jal	80003054 <bmap>
    800038de:	85aa                	mv	a1,a0
    if (addr == 0)
    800038e0:	c51d                	beqz	a0,8000390e <writei+0xbc>
    bp = bread(ip->dev, addr);
    800038e2:	000aa503          	lw	a0,0(s5)
    800038e6:	c08ff0ef          	jal	80002cee <bread>
    800038ea:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    800038ec:	3ff97793          	andi	a5,s2,1023
    800038f0:	40fc873b          	subw	a4,s9,a5
    800038f4:	413b06bb          	subw	a3,s6,s3
    800038f8:	8d3a                	mv	s10,a4
    800038fa:	fae6f2e3          	bgeu	a3,a4,8000389e <writei+0x4c>
    800038fe:	8d36                	mv	s10,a3
    80003900:	bf79                	j	8000389e <writei+0x4c>
      log_write(bp);
    80003902:	8526                	mv	a0,s1
    80003904:	69a000ef          	jal	80003f9e <log_write>
      brelse(bp);
    80003908:	8526                	mv	a0,s1
    8000390a:	cecff0ef          	jal	80002df6 <brelse>
  }

  if (off > ip->size)
    8000390e:	04caa783          	lw	a5,76(s5)
    80003912:	0327f963          	bgeu	a5,s2,80003944 <writei+0xf2>
    ip->size = off;
    80003916:	052aa623          	sw	s2,76(s5)
    8000391a:	64e6                	ld	s1,88(sp)
    8000391c:	7c02                	ld	s8,32(sp)
    8000391e:	6ce2                	ld	s9,24(sp)
    80003920:	6d42                	ld	s10,16(sp)
    80003922:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003924:	8556                	mv	a0,s5
    80003926:	9adff0ef          	jal	800032d2 <iupdate>

  return tot;
    8000392a:	854e                	mv	a0,s3
    8000392c:	69a6                	ld	s3,72(sp)
}
    8000392e:	70a6                	ld	ra,104(sp)
    80003930:	7406                	ld	s0,96(sp)
    80003932:	6946                	ld	s2,80(sp)
    80003934:	6a06                	ld	s4,64(sp)
    80003936:	7ae2                	ld	s5,56(sp)
    80003938:	7b42                	ld	s6,48(sp)
    8000393a:	7ba2                	ld	s7,40(sp)
    8000393c:	6165                	addi	sp,sp,112
    8000393e:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003940:	89da                	mv	s3,s6
    80003942:	b7cd                	j	80003924 <writei+0xd2>
    80003944:	64e6                	ld	s1,88(sp)
    80003946:	7c02                	ld	s8,32(sp)
    80003948:	6ce2                	ld	s9,24(sp)
    8000394a:	6d42                	ld	s10,16(sp)
    8000394c:	6da2                	ld	s11,8(sp)
    8000394e:	bfd9                	j	80003924 <writei+0xd2>
    return -1;
    80003950:	557d                	li	a0,-1
}
    80003952:	8082                	ret
    return -1;
    80003954:	557d                	li	a0,-1
    80003956:	bfe1                	j	8000392e <writei+0xdc>

0000000080003958 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003958:	1141                	addi	sp,sp,-16
    8000395a:	e406                	sd	ra,8(sp)
    8000395c:	e022                	sd	s0,0(sp)
    8000395e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003960:	4639                	li	a2,14
    80003962:	c4afd0ef          	jal	80000dac <strncmp>
}
    80003966:	60a2                	ld	ra,8(sp)
    80003968:	6402                	ld	s0,0(sp)
    8000396a:	0141                	addi	sp,sp,16
    8000396c:	8082                	ret

000000008000396e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000396e:	711d                	addi	sp,sp,-96
    80003970:	ec86                	sd	ra,88(sp)
    80003972:	e8a2                	sd	s0,80(sp)
    80003974:	e4a6                	sd	s1,72(sp)
    80003976:	e0ca                	sd	s2,64(sp)
    80003978:	fc4e                	sd	s3,56(sp)
    8000397a:	f852                	sd	s4,48(sp)
    8000397c:	f456                	sd	s5,40(sp)
    8000397e:	f05a                	sd	s6,32(sp)
    80003980:	ec5e                	sd	s7,24(sp)
    80003982:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    80003984:	04451703          	lh	a4,68(a0)
    80003988:	4785                	li	a5,1
    8000398a:	00f71f63          	bne	a4,a5,800039a8 <dirlookup+0x3a>
    8000398e:	892a                	mv	s2,a0
    80003990:	8aae                	mv	s5,a1
    80003992:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003994:	457c                	lw	a5,76(a0)
    80003996:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003998:	fa040a13          	addi	s4,s0,-96
    8000399c:	49c1                	li	s3,16
      panic("dirlookup read");
    if (de.inum == 0)
      continue;
    if (namecmp(name, de.name) == 0) {
    8000399e:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800039a2:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039a4:	e39d                	bnez	a5,800039ca <dirlookup+0x5c>
    800039a6:	a8b9                	j	80003a04 <dirlookup+0x96>
    panic("dirlookup not DIR");
    800039a8:	00004517          	auipc	a0,0x4
    800039ac:	b1850513          	addi	a0,a0,-1256 # 800074c0 <etext+0x4c0>
    800039b0:	e85fc0ef          	jal	80000834 <panic>
      panic("dirlookup read");
    800039b4:	00004517          	auipc	a0,0x4
    800039b8:	b2450513          	addi	a0,a0,-1244 # 800074d8 <etext+0x4d8>
    800039bc:	e79fc0ef          	jal	80000834 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039c0:	24c1                	addiw	s1,s1,16
    800039c2:	04c92783          	lw	a5,76(s2)
    800039c6:	02f4fe63          	bgeu	s1,a5,80003a02 <dirlookup+0x94>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039ca:	874e                	mv	a4,s3
    800039cc:	86a6                	mv	a3,s1
    800039ce:	8652                	mv	a2,s4
    800039d0:	4581                	li	a1,0
    800039d2:	854a                	mv	a0,s2
    800039d4:	d8dff0ef          	jal	80003760 <readi>
    800039d8:	fd351ee3          	bne	a0,s3,800039b4 <dirlookup+0x46>
    if (de.inum == 0)
    800039dc:	fa045783          	lhu	a5,-96(s0)
    800039e0:	d3e5                	beqz	a5,800039c0 <dirlookup+0x52>
    if (namecmp(name, de.name) == 0) {
    800039e2:	85da                	mv	a1,s6
    800039e4:	8556                	mv	a0,s5
    800039e6:	f73ff0ef          	jal	80003958 <namecmp>
    800039ea:	f979                	bnez	a0,800039c0 <dirlookup+0x52>
      if (poff)
    800039ec:	000b8463          	beqz	s7,800039f4 <dirlookup+0x86>
        *poff = off;
    800039f0:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800039f4:	fa045583          	lhu	a1,-96(s0)
    800039f8:	00092503          	lw	a0,0(s2)
    800039fc:	f18ff0ef          	jal	80003114 <iget>
    80003a00:	a011                	j	80003a04 <dirlookup+0x96>
  return 0;
    80003a02:	4501                	li	a0,0
}
    80003a04:	60e6                	ld	ra,88(sp)
    80003a06:	6446                	ld	s0,80(sp)
    80003a08:	64a6                	ld	s1,72(sp)
    80003a0a:	6906                	ld	s2,64(sp)
    80003a0c:	79e2                	ld	s3,56(sp)
    80003a0e:	7a42                	ld	s4,48(sp)
    80003a10:	7aa2                	ld	s5,40(sp)
    80003a12:	7b02                	ld	s6,32(sp)
    80003a14:	6be2                	ld	s7,24(sp)
    80003a16:	6125                	addi	sp,sp,96
    80003a18:	8082                	ret

0000000080003a1a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003a1a:	711d                	addi	sp,sp,-96
    80003a1c:	ec86                	sd	ra,88(sp)
    80003a1e:	e8a2                	sd	s0,80(sp)
    80003a20:	e4a6                	sd	s1,72(sp)
    80003a22:	e0ca                	sd	s2,64(sp)
    80003a24:	fc4e                	sd	s3,56(sp)
    80003a26:	f852                	sd	s4,48(sp)
    80003a28:	f456                	sd	s5,40(sp)
    80003a2a:	f05a                	sd	s6,32(sp)
    80003a2c:	ec5e                	sd	s7,24(sp)
    80003a2e:	e862                	sd	s8,16(sp)
    80003a30:	e466                	sd	s9,8(sp)
    80003a32:	e06a                	sd	s10,0(sp)
    80003a34:	1080                	addi	s0,sp,96
    80003a36:	84aa                	mv	s1,a0
    80003a38:	8b2e                	mv	s6,a1
    80003a3a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    80003a3c:	00054703          	lbu	a4,0(a0)
    80003a40:	02f00793          	li	a5,47
    80003a44:	00f70f63          	beq	a4,a5,80003a62 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a48:	ef1fd0ef          	jal	80001938 <myproc>
    80003a4c:	15853503          	ld	a0,344(a0)
    80003a50:	901ff0ef          	jal	80003350 <idup>
    80003a54:	8a2a                	mv	s4,a0
  while (*path == '/')
    80003a56:	02f00993          	li	s3,47
  if (len >= DIRSIZ)
    80003a5a:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003a5c:	4cb9                	li	s9,14

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    80003a5e:	4b85                	li	s7,1
    80003a60:	a07d                	j	80003b0e <namex+0xf4>
    ip = iget(ROOTDEV, ROOTINO);
    80003a62:	4585                	li	a1,1
    80003a64:	852e                	mv	a0,a1
    80003a66:	eaeff0ef          	jal	80003114 <iget>
    80003a6a:	8a2a                	mv	s4,a0
    80003a6c:	b7ed                	j	80003a56 <namex+0x3c>
      iunlockput(ip);
    80003a6e:	8552                	mv	a0,s4
    80003a70:	b6bff0ef          	jal	800035da <iunlockput>
      return 0;
    80003a74:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a76:	8552                	mv	a0,s4
    80003a78:	60e6                	ld	ra,88(sp)
    80003a7a:	6446                	ld	s0,80(sp)
    80003a7c:	64a6                	ld	s1,72(sp)
    80003a7e:	6906                	ld	s2,64(sp)
    80003a80:	79e2                	ld	s3,56(sp)
    80003a82:	7a42                	ld	s4,48(sp)
    80003a84:	7aa2                	ld	s5,40(sp)
    80003a86:	7b02                	ld	s6,32(sp)
    80003a88:	6be2                	ld	s7,24(sp)
    80003a8a:	6c42                	ld	s8,16(sp)
    80003a8c:	6ca2                	ld	s9,8(sp)
    80003a8e:	6d02                	ld	s10,0(sp)
    80003a90:	6125                	addi	sp,sp,96
    80003a92:	8082                	ret
      iunlockput(ip);
    80003a94:	8552                	mv	a0,s4
    80003a96:	b45ff0ef          	jal	800035da <iunlockput>
      return 0;
    80003a9a:	4a01                	li	s4,0
    80003a9c:	bfe9                	j	80003a76 <namex+0x5c>
      iunlock(ip);
    80003a9e:	8552                	mv	a0,s4
    80003aa0:	995ff0ef          	jal	80003434 <iunlock>
      return ip;
    80003aa4:	bfc9                	j	80003a76 <namex+0x5c>
      iunlockput(ip);
    80003aa6:	8552                	mv	a0,s4
    80003aa8:	b33ff0ef          	jal	800035da <iunlockput>
      return 0;
    80003aac:	8a4a                	mv	s4,s2
    80003aae:	b7e1                	j	80003a76 <namex+0x5c>
  len = path - s;
    80003ab0:	40990633          	sub	a2,s2,s1
    80003ab4:	00060d1b          	sext.w	s10,a2
  if (len >= DIRSIZ)
    80003ab8:	09ac5763          	bge	s8,s10,80003b46 <namex+0x12c>
    memmove(name, s, DIRSIZ);
    80003abc:	8666                	mv	a2,s9
    80003abe:	85a6                	mv	a1,s1
    80003ac0:	8556                	mv	a0,s5
    80003ac2:	a76fd0ef          	jal	80000d38 <memmove>
    80003ac6:	84ca                	mv	s1,s2
  while (*path == '/')
    80003ac8:	0004c783          	lbu	a5,0(s1)
    80003acc:	01379763          	bne	a5,s3,80003ada <namex+0xc0>
    path++;
    80003ad0:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003ad2:	0004c783          	lbu	a5,0(s1)
    80003ad6:	ff378de3          	beq	a5,s3,80003ad0 <namex+0xb6>
    ilock(ip);
    80003ada:	8552                	mv	a0,s4
    80003adc:	8abff0ef          	jal	80003386 <ilock>
    if (ip->type != T_DIR) {
    80003ae0:	044a1783          	lh	a5,68(s4)
    80003ae4:	f97795e3          	bne	a5,s7,80003a6e <namex+0x54>
    if (ip->nlink == 0) {
    80003ae8:	04aa1783          	lh	a5,74(s4)
    80003aec:	d7c5                	beqz	a5,80003a94 <namex+0x7a>
    if (nameiparent && *path == '\0') {
    80003aee:	000b0563          	beqz	s6,80003af8 <namex+0xde>
    80003af2:	0004c783          	lbu	a5,0(s1)
    80003af6:	d7c5                	beqz	a5,80003a9e <namex+0x84>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    80003af8:	4601                	li	a2,0
    80003afa:	85d6                	mv	a1,s5
    80003afc:	8552                	mv	a0,s4
    80003afe:	e71ff0ef          	jal	8000396e <dirlookup>
    80003b02:	892a                	mv	s2,a0
    80003b04:	d14d                	beqz	a0,80003aa6 <namex+0x8c>
    iunlockput(ip);
    80003b06:	8552                	mv	a0,s4
    80003b08:	ad3ff0ef          	jal	800035da <iunlockput>
    ip = next;
    80003b0c:	8a4a                	mv	s4,s2
  while (*path == '/')
    80003b0e:	0004c783          	lbu	a5,0(s1)
    80003b12:	01379763          	bne	a5,s3,80003b20 <namex+0x106>
    path++;
    80003b16:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003b18:	0004c783          	lbu	a5,0(s1)
    80003b1c:	ff378de3          	beq	a5,s3,80003b16 <namex+0xfc>
  if (*path == 0)
    80003b20:	cf8d                	beqz	a5,80003b5a <namex+0x140>
  while (*path != '/' && *path != 0)
    80003b22:	0004c783          	lbu	a5,0(s1)
    80003b26:	fd178713          	addi	a4,a5,-47
    80003b2a:	cb19                	beqz	a4,80003b40 <namex+0x126>
    80003b2c:	cb91                	beqz	a5,80003b40 <namex+0x126>
    80003b2e:	8926                	mv	s2,s1
    path++;
    80003b30:	0905                	addi	s2,s2,1
  while (*path != '/' && *path != 0)
    80003b32:	00094783          	lbu	a5,0(s2)
    80003b36:	fd178713          	addi	a4,a5,-47
    80003b3a:	db3d                	beqz	a4,80003ab0 <namex+0x96>
    80003b3c:	fbf5                	bnez	a5,80003b30 <namex+0x116>
    80003b3e:	bf8d                	j	80003ab0 <namex+0x96>
    80003b40:	8926                	mv	s2,s1
  len = path - s;
    80003b42:	4d01                	li	s10,0
    80003b44:	4601                	li	a2,0
    memmove(name, s, len);
    80003b46:	2601                	sext.w	a2,a2
    80003b48:	85a6                	mv	a1,s1
    80003b4a:	8556                	mv	a0,s5
    80003b4c:	9ecfd0ef          	jal	80000d38 <memmove>
    name[len] = 0;
    80003b50:	9d56                	add	s10,s10,s5
    80003b52:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffdb670>
    80003b56:	84ca                	mv	s1,s2
    80003b58:	bf85                	j	80003ac8 <namex+0xae>
  if (nameiparent) {
    80003b5a:	f00b0ee3          	beqz	s6,80003a76 <namex+0x5c>
    iput(ip);
    80003b5e:	8552                	mv	a0,s4
    80003b60:	9a9ff0ef          	jal	80003508 <iput>
    return 0;
    80003b64:	4a01                	li	s4,0
    80003b66:	bf01                	j	80003a76 <namex+0x5c>

0000000080003b68 <dirlink>:
{
    80003b68:	715d                	addi	sp,sp,-80
    80003b6a:	e486                	sd	ra,72(sp)
    80003b6c:	e0a2                	sd	s0,64(sp)
    80003b6e:	f84a                	sd	s2,48(sp)
    80003b70:	ec56                	sd	s5,24(sp)
    80003b72:	e85a                	sd	s6,16(sp)
    80003b74:	0880                	addi	s0,sp,80
    80003b76:	892a                	mv	s2,a0
    80003b78:	8aae                	mv	s5,a1
    80003b7a:	8b32                	mv	s6,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80003b7c:	4601                	li	a2,0
    80003b7e:	df1ff0ef          	jal	8000396e <dirlookup>
    80003b82:	ed1d                	bnez	a0,80003bc0 <dirlink+0x58>
    80003b84:	fc26                	sd	s1,56(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003b86:	04c92483          	lw	s1,76(s2)
    80003b8a:	c4b9                	beqz	s1,80003bd8 <dirlink+0x70>
    80003b8c:	f44e                	sd	s3,40(sp)
    80003b8e:	f052                	sd	s4,32(sp)
    80003b90:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b92:	fb040a13          	addi	s4,s0,-80
    80003b96:	49c1                	li	s3,16
    80003b98:	874e                	mv	a4,s3
    80003b9a:	86a6                	mv	a3,s1
    80003b9c:	8652                	mv	a2,s4
    80003b9e:	4581                	li	a1,0
    80003ba0:	854a                	mv	a0,s2
    80003ba2:	bbfff0ef          	jal	80003760 <readi>
    80003ba6:	03351163          	bne	a0,s3,80003bc8 <dirlink+0x60>
    if (de.inum == 0)
    80003baa:	fb045783          	lhu	a5,-80(s0)
    80003bae:	c39d                	beqz	a5,80003bd4 <dirlink+0x6c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003bb0:	24c1                	addiw	s1,s1,16
    80003bb2:	04c92783          	lw	a5,76(s2)
    80003bb6:	fef4e1e3          	bltu	s1,a5,80003b98 <dirlink+0x30>
    80003bba:	79a2                	ld	s3,40(sp)
    80003bbc:	7a02                	ld	s4,32(sp)
    80003bbe:	a829                	j	80003bd8 <dirlink+0x70>
    iput(ip);
    80003bc0:	949ff0ef          	jal	80003508 <iput>
    return -1;
    80003bc4:	557d                	li	a0,-1
    80003bc6:	a83d                	j	80003c04 <dirlink+0x9c>
      panic("dirlink read");
    80003bc8:	00004517          	auipc	a0,0x4
    80003bcc:	92050513          	addi	a0,a0,-1760 # 800074e8 <etext+0x4e8>
    80003bd0:	c65fc0ef          	jal	80000834 <panic>
    80003bd4:	79a2                	ld	s3,40(sp)
    80003bd6:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003bd8:	4639                	li	a2,14
    80003bda:	85d6                	mv	a1,s5
    80003bdc:	fb240513          	addi	a0,s0,-78
    80003be0:	a06fd0ef          	jal	80000de6 <strncpy>
  de.inum = inum;
    80003be4:	fb641823          	sh	s6,-80(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003be8:	4741                	li	a4,16
    80003bea:	86a6                	mv	a3,s1
    80003bec:	fb040613          	addi	a2,s0,-80
    80003bf0:	4581                	li	a1,0
    80003bf2:	854a                	mv	a0,s2
    80003bf4:	c5fff0ef          	jal	80003852 <writei>
    80003bf8:	1541                	addi	a0,a0,-16
    80003bfa:	00a03533          	snez	a0,a0
    80003bfe:	40a0053b          	negw	a0,a0
    80003c02:	74e2                	ld	s1,56(sp)
}
    80003c04:	60a6                	ld	ra,72(sp)
    80003c06:	6406                	ld	s0,64(sp)
    80003c08:	7942                	ld	s2,48(sp)
    80003c0a:	6ae2                	ld	s5,24(sp)
    80003c0c:	6b42                	ld	s6,16(sp)
    80003c0e:	6161                	addi	sp,sp,80
    80003c10:	8082                	ret

0000000080003c12 <namei>:

struct inode *
namei(char *path)
{
    80003c12:	1101                	addi	sp,sp,-32
    80003c14:	ec06                	sd	ra,24(sp)
    80003c16:	e822                	sd	s0,16(sp)
    80003c18:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c1a:	fe040613          	addi	a2,s0,-32
    80003c1e:	4581                	li	a1,0
    80003c20:	dfbff0ef          	jal	80003a1a <namex>
}
    80003c24:	60e2                	ld	ra,24(sp)
    80003c26:	6442                	ld	s0,16(sp)
    80003c28:	6105                	addi	sp,sp,32
    80003c2a:	8082                	ret

0000000080003c2c <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003c2c:	1141                	addi	sp,sp,-16
    80003c2e:	e406                	sd	ra,8(sp)
    80003c30:	e022                	sd	s0,0(sp)
    80003c32:	0800                	addi	s0,sp,16
    80003c34:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c36:	4585                	li	a1,1
    80003c38:	de3ff0ef          	jal	80003a1a <namex>
}
    80003c3c:	60a2                	ld	ra,8(sp)
    80003c3e:	6402                	ld	s0,0(sp)
    80003c40:	0141                	addi	sp,sp,16
    80003c42:	8082                	ret

0000000080003c44 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003c44:	1101                	addi	sp,sp,-32
    80003c46:	ec06                	sd	ra,24(sp)
    80003c48:	e822                	sd	s0,16(sp)
    80003c4a:	e426                	sd	s1,8(sp)
    80003c4c:	e04a                	sd	s2,0(sp)
    80003c4e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003c50:	0001f917          	auipc	s2,0x1f
    80003c54:	b0090913          	addi	s2,s2,-1280 # 80022750 <log>
    80003c58:	01892583          	lw	a1,24(s2)
    80003c5c:	02492503          	lw	a0,36(s2)
    80003c60:	88eff0ef          	jal	80002cee <bread>
    80003c64:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003c66:	02c92603          	lw	a2,44(s2)
    80003c6a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003c6c:	00c05f63          	blez	a2,80003c8a <write_head+0x46>
    80003c70:	0001f717          	auipc	a4,0x1f
    80003c74:	b1070713          	addi	a4,a4,-1264 # 80022780 <log+0x30>
    80003c78:	87aa                	mv	a5,a0
    80003c7a:	060a                	slli	a2,a2,0x2
    80003c7c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003c7e:	4314                	lw	a3,0(a4)
    80003c80:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003c82:	0711                	addi	a4,a4,4
    80003c84:	0791                	addi	a5,a5,4
    80003c86:	fec79ce3          	bne	a5,a2,80003c7e <write_head+0x3a>
  }
  bwrite(buf);
    80003c8a:	8526                	mv	a0,s1
    80003c8c:	938ff0ef          	jal	80002dc4 <bwrite>
  brelse(buf);
    80003c90:	8526                	mv	a0,s1
    80003c92:	964ff0ef          	jal	80002df6 <brelse>
}
    80003c96:	60e2                	ld	ra,24(sp)
    80003c98:	6442                	ld	s0,16(sp)
    80003c9a:	64a2                	ld	s1,8(sp)
    80003c9c:	6902                	ld	s2,0(sp)
    80003c9e:	6105                	addi	sp,sp,32
    80003ca0:	8082                	ret

0000000080003ca2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ca2:	0001f797          	auipc	a5,0x1f
    80003ca6:	ada7a783          	lw	a5,-1318(a5) # 8002277c <log+0x2c>
    80003caa:	0cf05163          	blez	a5,80003d6c <install_trans+0xca>
{
    80003cae:	715d                	addi	sp,sp,-80
    80003cb0:	e486                	sd	ra,72(sp)
    80003cb2:	e0a2                	sd	s0,64(sp)
    80003cb4:	fc26                	sd	s1,56(sp)
    80003cb6:	f84a                	sd	s2,48(sp)
    80003cb8:	f44e                	sd	s3,40(sp)
    80003cba:	f052                	sd	s4,32(sp)
    80003cbc:	ec56                	sd	s5,24(sp)
    80003cbe:	e85a                	sd	s6,16(sp)
    80003cc0:	e45e                	sd	s7,8(sp)
    80003cc2:	e062                	sd	s8,0(sp)
    80003cc4:	0880                	addi	s0,sp,80
    80003cc6:	8b2a                	mv	s6,a0
    80003cc8:	0001fa97          	auipc	s5,0x1f
    80003ccc:	ab8a8a93          	addi	s5,s5,-1352 # 80022780 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003cd0:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003cd2:	00004c17          	auipc	s8,0x4
    80003cd6:	826c0c13          	addi	s8,s8,-2010 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003cda:	0001fa17          	auipc	s4,0x1f
    80003cde:	a76a0a13          	addi	s4,s4,-1418 # 80022750 <log>
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003ce2:	40000b93          	li	s7,1024
    80003ce6:	a025                	j	80003d0e <install_trans+0x6c>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003ce8:	000aa603          	lw	a2,0(s5)
    80003cec:	85ce                	mv	a1,s3
    80003cee:	8562                	mv	a0,s8
    80003cf0:	81bfc0ef          	jal	8000050a <printk>
    80003cf4:	a839                	j	80003d12 <install_trans+0x70>
    brelse(lbuf);
    80003cf6:	854a                	mv	a0,s2
    80003cf8:	8feff0ef          	jal	80002df6 <brelse>
    brelse(dbuf);
    80003cfc:	8526                	mv	a0,s1
    80003cfe:	8f8ff0ef          	jal	80002df6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d02:	2985                	addiw	s3,s3,1
    80003d04:	0a91                	addi	s5,s5,4
    80003d06:	02ca2783          	lw	a5,44(s4)
    80003d0a:	04f9d563          	bge	s3,a5,80003d54 <install_trans+0xb2>
    if (recovering) {
    80003d0e:	fc0b1de3          	bnez	s6,80003ce8 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003d12:	018a2583          	lw	a1,24(s4)
    80003d16:	013585bb          	addw	a1,a1,s3
    80003d1a:	2585                	addiw	a1,a1,1
    80003d1c:	024a2503          	lw	a0,36(s4)
    80003d20:	fcffe0ef          	jal	80002cee <bread>
    80003d24:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003d26:	000aa583          	lw	a1,0(s5)
    80003d2a:	024a2503          	lw	a0,36(s4)
    80003d2e:	fc1fe0ef          	jal	80002cee <bread>
    80003d32:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003d34:	865e                	mv	a2,s7
    80003d36:	05890593          	addi	a1,s2,88
    80003d3a:	05850513          	addi	a0,a0,88
    80003d3e:	ffbfc0ef          	jal	80000d38 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003d42:	8526                	mv	a0,s1
    80003d44:	880ff0ef          	jal	80002dc4 <bwrite>
    if (recovering == 0)
    80003d48:	fa0b17e3          	bnez	s6,80003cf6 <install_trans+0x54>
      bunpin(dbuf);
    80003d4c:	8526                	mv	a0,s1
    80003d4e:	960ff0ef          	jal	80002eae <bunpin>
    80003d52:	b755                	j	80003cf6 <install_trans+0x54>
}
    80003d54:	60a6                	ld	ra,72(sp)
    80003d56:	6406                	ld	s0,64(sp)
    80003d58:	74e2                	ld	s1,56(sp)
    80003d5a:	7942                	ld	s2,48(sp)
    80003d5c:	79a2                	ld	s3,40(sp)
    80003d5e:	7a02                	ld	s4,32(sp)
    80003d60:	6ae2                	ld	s5,24(sp)
    80003d62:	6b42                	ld	s6,16(sp)
    80003d64:	6ba2                	ld	s7,8(sp)
    80003d66:	6c02                	ld	s8,0(sp)
    80003d68:	6161                	addi	sp,sp,80
    80003d6a:	8082                	ret
    80003d6c:	8082                	ret

0000000080003d6e <initlog>:
{
    80003d6e:	7179                	addi	sp,sp,-48
    80003d70:	f406                	sd	ra,40(sp)
    80003d72:	f022                	sd	s0,32(sp)
    80003d74:	ec26                	sd	s1,24(sp)
    80003d76:	e84a                	sd	s2,16(sp)
    80003d78:	e44e                	sd	s3,8(sp)
    80003d7a:	1800                	addi	s0,sp,48
    80003d7c:	84aa                	mv	s1,a0
    80003d7e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003d80:	0001f917          	auipc	s2,0x1f
    80003d84:	9d090913          	addi	s2,s2,-1584 # 80022750 <log>
    80003d88:	00003597          	auipc	a1,0x3
    80003d8c:	79058593          	addi	a1,a1,1936 # 80007518 <etext+0x518>
    80003d90:	854a                	mv	a0,s2
    80003d92:	e07fc0ef          	jal	80000b98 <initlock>
  log.start = sb->logstart;
    80003d96:	0149a583          	lw	a1,20(s3)
    80003d9a:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003d9e:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003da2:	8526                	mv	a0,s1
    80003da4:	f4bfe0ef          	jal	80002cee <bread>
  log.lh.n = lh->n;
    80003da8:	4d30                	lw	a2,88(a0)
    80003daa:	02c92623          	sw	a2,44(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003dae:	00c05f63          	blez	a2,80003dcc <initlog+0x5e>
    80003db2:	87aa                	mv	a5,a0
    80003db4:	0001f717          	auipc	a4,0x1f
    80003db8:	9cc70713          	addi	a4,a4,-1588 # 80022780 <log+0x30>
    80003dbc:	060a                	slli	a2,a2,0x2
    80003dbe:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003dc0:	4ff4                	lw	a3,92(a5)
    80003dc2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003dc4:	0791                	addi	a5,a5,4
    80003dc6:	0711                	addi	a4,a4,4
    80003dc8:	fec79ce3          	bne	a5,a2,80003dc0 <initlog+0x52>
  brelse(buf);
    80003dcc:	82aff0ef          	jal	80002df6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003dd0:	4505                	li	a0,1
    80003dd2:	ed1ff0ef          	jal	80003ca2 <install_trans>
  log.lh.n = 0;
    80003dd6:	0001f797          	auipc	a5,0x1f
    80003dda:	9a07a323          	sw	zero,-1626(a5) # 8002277c <log+0x2c>
  write_head(); // clear the log
    80003dde:	e67ff0ef          	jal	80003c44 <write_head>
}
    80003de2:	70a2                	ld	ra,40(sp)
    80003de4:	7402                	ld	s0,32(sp)
    80003de6:	64e2                	ld	s1,24(sp)
    80003de8:	6942                	ld	s2,16(sp)
    80003dea:	69a2                	ld	s3,8(sp)
    80003dec:	6145                	addi	sp,sp,48
    80003dee:	8082                	ret

0000000080003df0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003df0:	1101                	addi	sp,sp,-32
    80003df2:	ec06                	sd	ra,24(sp)
    80003df4:	e822                	sd	s0,16(sp)
    80003df6:	e426                	sd	s1,8(sp)
    80003df8:	e04a                	sd	s2,0(sp)
    80003dfa:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003dfc:	0001f517          	auipc	a0,0x1f
    80003e00:	95450513          	addi	a0,a0,-1708 # 80022750 <log>
    80003e04:	e15fc0ef          	jal	80000c18 <acquire>
  while (1) {
    if (log.committing) {
    80003e08:	0001f497          	auipc	s1,0x1f
    80003e0c:	94848493          	addi	s1,s1,-1720 # 80022750 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e10:	4979                	li	s2,30
    80003e12:	a821                	j	80003e2a <begin_op+0x3a>
      sleep_prepare(&log);
    80003e14:	8526                	mv	a0,s1
    80003e16:	a00fe0ef          	jal	80002016 <sleep_prepare>
      release(&log.lock);
    80003e1a:	8526                	mv	a0,s1
    80003e1c:	e85fc0ef          	jal	80000ca0 <release>
      sleep();
    80003e20:	a32fe0ef          	jal	80002052 <sleep>
      acquire(&log.lock);
    80003e24:	8526                	mv	a0,s1
    80003e26:	df3fc0ef          	jal	80000c18 <acquire>
    if (log.committing) {
    80003e2a:	509c                	lw	a5,32(s1)
    80003e2c:	f7e5                	bnez	a5,80003e14 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003e2e:	4cd8                	lw	a4,28(s1)
    80003e30:	2705                	addiw	a4,a4,1
    80003e32:	0027179b          	slliw	a5,a4,0x2
    80003e36:	9fb9                	addw	a5,a5,a4
    80003e38:	0017979b          	slliw	a5,a5,0x1
    80003e3c:	54d4                	lw	a3,44(s1)
    80003e3e:	9fb5                	addw	a5,a5,a3
    80003e40:	00f95e63          	bge	s2,a5,80003e5c <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003e44:	8526                	mv	a0,s1
    80003e46:	9d0fe0ef          	jal	80002016 <sleep_prepare>
      release(&log.lock);
    80003e4a:	8526                	mv	a0,s1
    80003e4c:	e55fc0ef          	jal	80000ca0 <release>
      sleep();
    80003e50:	a02fe0ef          	jal	80002052 <sleep>
      acquire(&log.lock);
    80003e54:	8526                	mv	a0,s1
    80003e56:	dc3fc0ef          	jal	80000c18 <acquire>
    80003e5a:	bfc1                	j	80003e2a <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003e5c:	0001f797          	auipc	a5,0x1f
    80003e60:	90e7a823          	sw	a4,-1776(a5) # 8002276c <log+0x1c>
      release(&log.lock);
    80003e64:	0001f517          	auipc	a0,0x1f
    80003e68:	8ec50513          	addi	a0,a0,-1812 # 80022750 <log>
    80003e6c:	e35fc0ef          	jal	80000ca0 <release>
      break;
    }
  }
}
    80003e70:	60e2                	ld	ra,24(sp)
    80003e72:	6442                	ld	s0,16(sp)
    80003e74:	64a2                	ld	s1,8(sp)
    80003e76:	6902                	ld	s2,0(sp)
    80003e78:	6105                	addi	sp,sp,32
    80003e7a:	8082                	ret

0000000080003e7c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003e7c:	7139                	addi	sp,sp,-64
    80003e7e:	fc06                	sd	ra,56(sp)
    80003e80:	f822                	sd	s0,48(sp)
    80003e82:	f426                	sd	s1,40(sp)
    80003e84:	f04a                	sd	s2,32(sp)
    80003e86:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003e88:	0001f497          	auipc	s1,0x1f
    80003e8c:	8c848493          	addi	s1,s1,-1848 # 80022750 <log>
    80003e90:	8526                	mv	a0,s1
    80003e92:	d87fc0ef          	jal	80000c18 <acquire>
  log.outstanding -= 1;
    80003e96:	4cdc                	lw	a5,28(s1)
    80003e98:	37fd                	addiw	a5,a5,-1
    80003e9a:	893e                	mv	s2,a5
    80003e9c:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003e9e:	509c                	lw	a5,32(s1)
    80003ea0:	e3b1                	bnez	a5,80003ee4 <end_op+0x68>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003ea2:	04091a63          	bnez	s2,80003ef6 <end_op+0x7a>
    do_commit = 1;
    log.committing = 1;
    80003ea6:	0001f497          	auipc	s1,0x1f
    80003eaa:	8aa48493          	addi	s1,s1,-1878 # 80022750 <log>
    80003eae:	4785                	li	a5,1
    80003eb0:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003eb2:	8526                	mv	a0,s1
    80003eb4:	dedfc0ef          	jal	80000ca0 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003eb8:	54dc                	lw	a5,44(s1)
    80003eba:	06f04063          	bgtz	a5,80003f1a <end_op+0x9e>
    acquire(&log.lock);
    80003ebe:	0001f497          	auipc	s1,0x1f
    80003ec2:	89248493          	addi	s1,s1,-1902 # 80022750 <log>
    80003ec6:	8526                	mv	a0,s1
    80003ec8:	d51fc0ef          	jal	80000c18 <acquire>
    log.committing = 0;
    80003ecc:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003ed0:	549c                	lw	a5,40(s1)
    80003ed2:	2785                	addiw	a5,a5,1
    80003ed4:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003ed6:	8526                	mv	a0,s1
    80003ed8:	9aafe0ef          	jal	80002082 <wakeup>
    release(&log.lock);
    80003edc:	8526                	mv	a0,s1
    80003ede:	dc3fc0ef          	jal	80000ca0 <release>
}
    80003ee2:	a035                	j	80003f0e <end_op+0x92>
    80003ee4:	ec4e                	sd	s3,24(sp)
    80003ee6:	e852                	sd	s4,16(sp)
    80003ee8:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003eea:	00003517          	auipc	a0,0x3
    80003eee:	63650513          	addi	a0,a0,1590 # 80007520 <etext+0x520>
    80003ef2:	943fc0ef          	jal	80000834 <panic>
    wakeup(&log);
    80003ef6:	0001f517          	auipc	a0,0x1f
    80003efa:	85a50513          	addi	a0,a0,-1958 # 80022750 <log>
    80003efe:	984fe0ef          	jal	80002082 <wakeup>
  release(&log.lock);
    80003f02:	0001f517          	auipc	a0,0x1f
    80003f06:	84e50513          	addi	a0,a0,-1970 # 80022750 <log>
    80003f0a:	d97fc0ef          	jal	80000ca0 <release>
}
    80003f0e:	70e2                	ld	ra,56(sp)
    80003f10:	7442                	ld	s0,48(sp)
    80003f12:	74a2                	ld	s1,40(sp)
    80003f14:	7902                	ld	s2,32(sp)
    80003f16:	6121                	addi	sp,sp,64
    80003f18:	8082                	ret
    80003f1a:	ec4e                	sd	s3,24(sp)
    80003f1c:	e852                	sd	s4,16(sp)
    80003f1e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f20:	0001fa97          	auipc	s5,0x1f
    80003f24:	860a8a93          	addi	s5,s5,-1952 # 80022780 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003f28:	0001fa17          	auipc	s4,0x1f
    80003f2c:	828a0a13          	addi	s4,s4,-2008 # 80022750 <log>
    80003f30:	018a2583          	lw	a1,24(s4)
    80003f34:	012585bb          	addw	a1,a1,s2
    80003f38:	2585                	addiw	a1,a1,1
    80003f3a:	024a2503          	lw	a0,36(s4)
    80003f3e:	db1fe0ef          	jal	80002cee <bread>
    80003f42:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003f44:	000aa583          	lw	a1,0(s5)
    80003f48:	024a2503          	lw	a0,36(s4)
    80003f4c:	da3fe0ef          	jal	80002cee <bread>
    80003f50:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003f52:	40000613          	li	a2,1024
    80003f56:	05850593          	addi	a1,a0,88
    80003f5a:	05848513          	addi	a0,s1,88
    80003f5e:	ddbfc0ef          	jal	80000d38 <memmove>
    bwrite(to); // write the log
    80003f62:	8526                	mv	a0,s1
    80003f64:	e61fe0ef          	jal	80002dc4 <bwrite>
    brelse(from);
    80003f68:	854e                	mv	a0,s3
    80003f6a:	e8dfe0ef          	jal	80002df6 <brelse>
    brelse(to);
    80003f6e:	8526                	mv	a0,s1
    80003f70:	e87fe0ef          	jal	80002df6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f74:	2905                	addiw	s2,s2,1
    80003f76:	0a91                	addi	s5,s5,4
    80003f78:	02ca2783          	lw	a5,44(s4)
    80003f7c:	faf94ae3          	blt	s2,a5,80003f30 <end_op+0xb4>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003f80:	cc5ff0ef          	jal	80003c44 <write_head>
    install_trans(0); // Now install writes to home locations
    80003f84:	4501                	li	a0,0
    80003f86:	d1dff0ef          	jal	80003ca2 <install_trans>
    log.lh.n = 0;
    80003f8a:	0001e797          	auipc	a5,0x1e
    80003f8e:	7e07a923          	sw	zero,2034(a5) # 8002277c <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003f92:	cb3ff0ef          	jal	80003c44 <write_head>
    80003f96:	69e2                	ld	s3,24(sp)
    80003f98:	6a42                	ld	s4,16(sp)
    80003f9a:	6aa2                	ld	s5,8(sp)
    80003f9c:	b70d                	j	80003ebe <end_op+0x42>

0000000080003f9e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003f9e:	1101                	addi	sp,sp,-32
    80003fa0:	ec06                	sd	ra,24(sp)
    80003fa2:	e822                	sd	s0,16(sp)
    80003fa4:	e426                	sd	s1,8(sp)
    80003fa6:	1000                	addi	s0,sp,32
    80003fa8:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003faa:	0001e517          	auipc	a0,0x1e
    80003fae:	7a650513          	addi	a0,a0,1958 # 80022750 <log>
    80003fb2:	c67fc0ef          	jal	80000c18 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003fb6:	0001e617          	auipc	a2,0x1e
    80003fba:	7c662603          	lw	a2,1990(a2) # 8002277c <log+0x2c>
    80003fbe:	47f5                	li	a5,29
    80003fc0:	04c7cd63          	blt	a5,a2,8000401a <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003fc4:	0001e797          	auipc	a5,0x1e
    80003fc8:	7a87a783          	lw	a5,1960(a5) # 8002276c <log+0x1c>
    80003fcc:	04f05d63          	blez	a5,80004026 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003fd0:	4781                	li	a5,0
    80003fd2:	06c05063          	blez	a2,80004032 <log_write+0x94>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003fd6:	44cc                	lw	a1,12(s1)
    80003fd8:	0001e717          	auipc	a4,0x1e
    80003fdc:	7a870713          	addi	a4,a4,1960 # 80022780 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003fe0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003fe2:	4314                	lw	a3,0(a4)
    80003fe4:	04b68763          	beq	a3,a1,80004032 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003fe8:	2785                	addiw	a5,a5,1
    80003fea:	0711                	addi	a4,a4,4
    80003fec:	fef61be3          	bne	a2,a5,80003fe2 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003ff0:	060a                	slli	a2,a2,0x2
    80003ff2:	02060613          	addi	a2,a2,32
    80003ff6:	0001e797          	auipc	a5,0x1e
    80003ffa:	75a78793          	addi	a5,a5,1882 # 80022750 <log>
    80003ffe:	97b2                	add	a5,a5,a2
    80004000:	44d8                	lw	a4,12(s1)
    80004002:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80004004:	8526                	mv	a0,s1
    80004006:	e75fe0ef          	jal	80002e7a <bpin>
    log.lh.n++;
    8000400a:	0001e717          	auipc	a4,0x1e
    8000400e:	74670713          	addi	a4,a4,1862 # 80022750 <log>
    80004012:	575c                	lw	a5,44(a4)
    80004014:	2785                	addiw	a5,a5,1
    80004016:	d75c                	sw	a5,44(a4)
    80004018:	a815                	j	8000404c <log_write+0xae>
    panic("too big a transaction");
    8000401a:	00003517          	auipc	a0,0x3
    8000401e:	51650513          	addi	a0,a0,1302 # 80007530 <etext+0x530>
    80004022:	813fc0ef          	jal	80000834 <panic>
    panic("log_write outside of trans");
    80004026:	00003517          	auipc	a0,0x3
    8000402a:	52250513          	addi	a0,a0,1314 # 80007548 <etext+0x548>
    8000402e:	807fc0ef          	jal	80000834 <panic>
  log.lh.block[i] = b->blockno;
    80004032:	00279693          	slli	a3,a5,0x2
    80004036:	02068693          	addi	a3,a3,32
    8000403a:	0001e717          	auipc	a4,0x1e
    8000403e:	71670713          	addi	a4,a4,1814 # 80022750 <log>
    80004042:	9736                	add	a4,a4,a3
    80004044:	44d4                	lw	a3,12(s1)
    80004046:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80004048:	faf60ee3          	beq	a2,a5,80004004 <log_write+0x66>
  }
  release(&log.lock);
    8000404c:	0001e517          	auipc	a0,0x1e
    80004050:	70450513          	addi	a0,a0,1796 # 80022750 <log>
    80004054:	c4dfc0ef          	jal	80000ca0 <release>
}
    80004058:	60e2                	ld	ra,24(sp)
    8000405a:	6442                	ld	s0,16(sp)
    8000405c:	64a2                	ld	s1,8(sp)
    8000405e:	6105                	addi	sp,sp,32
    80004060:	8082                	ret

0000000080004062 <sys_sync>:

uint64
sys_sync(void)
{
    80004062:	1101                	addi	sp,sp,-32
    80004064:	ec06                	sd	ra,24(sp)
    80004066:	e822                	sd	s0,16(sp)
    80004068:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000406a:	0001e517          	auipc	a0,0x1e
    8000406e:	6e650513          	addi	a0,a0,1766 # 80022750 <log>
    80004072:	ba7fc0ef          	jal	80000c18 <acquire>
  if (log.committing || log.outstanding > 0) {
    80004076:	0001e797          	auipc	a5,0x1e
    8000407a:	6fa7a783          	lw	a5,1786(a5) # 80022770 <log+0x20>
    8000407e:	e799                	bnez	a5,8000408c <sys_sync+0x2a>
    80004080:	0001e797          	auipc	a5,0x1e
    80004084:	6ec7a783          	lw	a5,1772(a5) # 8002276c <log+0x1c>
    80004088:	02f05c63          	blez	a5,800040c0 <sys_sync+0x5e>
    8000408c:	e426                	sd	s1,8(sp)
    8000408e:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80004090:	0001e917          	auipc	s2,0x1e
    80004094:	6e892903          	lw	s2,1768(s2) # 80022778 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80004098:	0001e497          	auipc	s1,0x1e
    8000409c:	6b848493          	addi	s1,s1,1720 # 80022750 <log>
    800040a0:	8526                	mv	a0,s1
    800040a2:	f75fd0ef          	jal	80002016 <sleep_prepare>
      release(&log.lock);
    800040a6:	8526                	mv	a0,s1
    800040a8:	bf9fc0ef          	jal	80000ca0 <release>
      sleep();
    800040ac:	fa7fd0ef          	jal	80002052 <sleep>
      acquire(&log.lock);
    800040b0:	8526                	mv	a0,s1
    800040b2:	b67fc0ef          	jal	80000c18 <acquire>
    while (log.ncommit < n) {
    800040b6:	549c                	lw	a5,40(s1)
    800040b8:	fef954e3          	bge	s2,a5,800040a0 <sys_sync+0x3e>
    800040bc:	64a2                	ld	s1,8(sp)
    800040be:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    800040c0:	0001e517          	auipc	a0,0x1e
    800040c4:	69050513          	addi	a0,a0,1680 # 80022750 <log>
    800040c8:	bd9fc0ef          	jal	80000ca0 <release>
  return 0;
}
    800040cc:	4501                	li	a0,0
    800040ce:	60e2                	ld	ra,24(sp)
    800040d0:	6442                	ld	s0,16(sp)
    800040d2:	6105                	addi	sp,sp,32
    800040d4:	8082                	ret

00000000800040d6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800040d6:	1101                	addi	sp,sp,-32
    800040d8:	ec06                	sd	ra,24(sp)
    800040da:	e822                	sd	s0,16(sp)
    800040dc:	e426                	sd	s1,8(sp)
    800040de:	e04a                	sd	s2,0(sp)
    800040e0:	1000                	addi	s0,sp,32
    800040e2:	84aa                	mv	s1,a0
    800040e4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800040e6:	00003597          	auipc	a1,0x3
    800040ea:	48258593          	addi	a1,a1,1154 # 80007568 <etext+0x568>
    800040ee:	0521                	addi	a0,a0,8
    800040f0:	aa9fc0ef          	jal	80000b98 <initlock>
  lk->name = name;
    800040f4:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800040f8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800040fc:	0204a423          	sw	zero,40(s1)
}
    80004100:	60e2                	ld	ra,24(sp)
    80004102:	6442                	ld	s0,16(sp)
    80004104:	64a2                	ld	s1,8(sp)
    80004106:	6902                	ld	s2,0(sp)
    80004108:	6105                	addi	sp,sp,32
    8000410a:	8082                	ret

000000008000410c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000410c:	1101                	addi	sp,sp,-32
    8000410e:	ec06                	sd	ra,24(sp)
    80004110:	e822                	sd	s0,16(sp)
    80004112:	e426                	sd	s1,8(sp)
    80004114:	e04a                	sd	s2,0(sp)
    80004116:	1000                	addi	s0,sp,32
    80004118:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000411a:	00850913          	addi	s2,a0,8
    8000411e:	854a                	mv	a0,s2
    80004120:	af9fc0ef          	jal	80000c18 <acquire>
  while (lk->locked) {
    80004124:	409c                	lw	a5,0(s1)
    80004126:	cf91                	beqz	a5,80004142 <acquiresleep+0x36>
    sleep_prepare(lk);
    80004128:	8526                	mv	a0,s1
    8000412a:	eedfd0ef          	jal	80002016 <sleep_prepare>
    release(&lk->lk);
    8000412e:	854a                	mv	a0,s2
    80004130:	b71fc0ef          	jal	80000ca0 <release>
    sleep();
    80004134:	f1ffd0ef          	jal	80002052 <sleep>
    acquire(&lk->lk);
    80004138:	854a                	mv	a0,s2
    8000413a:	adffc0ef          	jal	80000c18 <acquire>
  while (lk->locked) {
    8000413e:	409c                	lw	a5,0(s1)
    80004140:	f7e5                	bnez	a5,80004128 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004142:	4785                	li	a5,1
    80004144:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004146:	ff2fd0ef          	jal	80001938 <myproc>
    8000414a:	591c                	lw	a5,48(a0)
    8000414c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000414e:	854a                	mv	a0,s2
    80004150:	b51fc0ef          	jal	80000ca0 <release>
}
    80004154:	60e2                	ld	ra,24(sp)
    80004156:	6442                	ld	s0,16(sp)
    80004158:	64a2                	ld	s1,8(sp)
    8000415a:	6902                	ld	s2,0(sp)
    8000415c:	6105                	addi	sp,sp,32
    8000415e:	8082                	ret

0000000080004160 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004160:	1101                	addi	sp,sp,-32
    80004162:	ec06                	sd	ra,24(sp)
    80004164:	e822                	sd	s0,16(sp)
    80004166:	e426                	sd	s1,8(sp)
    80004168:	e04a                	sd	s2,0(sp)
    8000416a:	1000                	addi	s0,sp,32
    8000416c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000416e:	00850913          	addi	s2,a0,8
    80004172:	854a                	mv	a0,s2
    80004174:	aa5fc0ef          	jal	80000c18 <acquire>
  lk->locked = 0;
    80004178:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000417c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004180:	8526                	mv	a0,s1
    80004182:	f01fd0ef          	jal	80002082 <wakeup>
  release(&lk->lk);
    80004186:	854a                	mv	a0,s2
    80004188:	b19fc0ef          	jal	80000ca0 <release>
}
    8000418c:	60e2                	ld	ra,24(sp)
    8000418e:	6442                	ld	s0,16(sp)
    80004190:	64a2                	ld	s1,8(sp)
    80004192:	6902                	ld	s2,0(sp)
    80004194:	6105                	addi	sp,sp,32
    80004196:	8082                	ret

0000000080004198 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004198:	7179                	addi	sp,sp,-48
    8000419a:	f406                	sd	ra,40(sp)
    8000419c:	f022                	sd	s0,32(sp)
    8000419e:	ec26                	sd	s1,24(sp)
    800041a0:	e84a                	sd	s2,16(sp)
    800041a2:	1800                	addi	s0,sp,48
    800041a4:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    800041a6:	00850913          	addi	s2,a0,8
    800041aa:	854a                	mv	a0,s2
    800041ac:	a6dfc0ef          	jal	80000c18 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800041b0:	409c                	lw	a5,0(s1)
    800041b2:	ef81                	bnez	a5,800041ca <holdingsleep+0x32>
    800041b4:	4481                	li	s1,0
  release(&lk->lk);
    800041b6:	854a                	mv	a0,s2
    800041b8:	ae9fc0ef          	jal	80000ca0 <release>
  return r;
}
    800041bc:	8526                	mv	a0,s1
    800041be:	70a2                	ld	ra,40(sp)
    800041c0:	7402                	ld	s0,32(sp)
    800041c2:	64e2                	ld	s1,24(sp)
    800041c4:	6942                	ld	s2,16(sp)
    800041c6:	6145                	addi	sp,sp,48
    800041c8:	8082                	ret
    800041ca:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800041cc:	0284a983          	lw	s3,40(s1)
    800041d0:	f68fd0ef          	jal	80001938 <myproc>
    800041d4:	5904                	lw	s1,48(a0)
    800041d6:	413484b3          	sub	s1,s1,s3
    800041da:	0014b493          	seqz	s1,s1
    800041de:	69a2                	ld	s3,8(sp)
    800041e0:	bfd9                	j	800041b6 <holdingsleep+0x1e>

00000000800041e2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800041e2:	1141                	addi	sp,sp,-16
    800041e4:	e406                	sd	ra,8(sp)
    800041e6:	e022                	sd	s0,0(sp)
    800041e8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800041ea:	00003597          	auipc	a1,0x3
    800041ee:	38e58593          	addi	a1,a1,910 # 80007578 <etext+0x578>
    800041f2:	0001e517          	auipc	a0,0x1e
    800041f6:	6a650513          	addi	a0,a0,1702 # 80022898 <ftable>
    800041fa:	99ffc0ef          	jal	80000b98 <initlock>
}
    800041fe:	60a2                	ld	ra,8(sp)
    80004200:	6402                	ld	s0,0(sp)
    80004202:	0141                	addi	sp,sp,16
    80004204:	8082                	ret

0000000080004206 <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    80004206:	1101                	addi	sp,sp,-32
    80004208:	ec06                	sd	ra,24(sp)
    8000420a:	e822                	sd	s0,16(sp)
    8000420c:	e426                	sd	s1,8(sp)
    8000420e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004210:	0001e517          	auipc	a0,0x1e
    80004214:	68850513          	addi	a0,a0,1672 # 80022898 <ftable>
    80004218:	a01fc0ef          	jal	80000c18 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    8000421c:	0001e497          	auipc	s1,0x1e
    80004220:	69448493          	addi	s1,s1,1684 # 800228b0 <ftable+0x18>
    80004224:	0001f717          	auipc	a4,0x1f
    80004228:	62c70713          	addi	a4,a4,1580 # 80023850 <disk>
    if (f->ref == 0) {
    8000422c:	40dc                	lw	a5,4(s1)
    8000422e:	cf89                	beqz	a5,80004248 <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004230:	02848493          	addi	s1,s1,40
    80004234:	fee49ce3          	bne	s1,a4,8000422c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004238:	0001e517          	auipc	a0,0x1e
    8000423c:	66050513          	addi	a0,a0,1632 # 80022898 <ftable>
    80004240:	a61fc0ef          	jal	80000ca0 <release>
  return 0;
    80004244:	4481                	li	s1,0
    80004246:	a809                	j	80004258 <filealloc+0x52>
      f->ref = 1;
    80004248:	4785                	li	a5,1
    8000424a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000424c:	0001e517          	auipc	a0,0x1e
    80004250:	64c50513          	addi	a0,a0,1612 # 80022898 <ftable>
    80004254:	a4dfc0ef          	jal	80000ca0 <release>
}
    80004258:	8526                	mv	a0,s1
    8000425a:	60e2                	ld	ra,24(sp)
    8000425c:	6442                	ld	s0,16(sp)
    8000425e:	64a2                	ld	s1,8(sp)
    80004260:	6105                	addi	sp,sp,32
    80004262:	8082                	ret

0000000080004264 <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    80004264:	1101                	addi	sp,sp,-32
    80004266:	ec06                	sd	ra,24(sp)
    80004268:	e822                	sd	s0,16(sp)
    8000426a:	e426                	sd	s1,8(sp)
    8000426c:	1000                	addi	s0,sp,32
    8000426e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004270:	0001e517          	auipc	a0,0x1e
    80004274:	62850513          	addi	a0,a0,1576 # 80022898 <ftable>
    80004278:	9a1fc0ef          	jal	80000c18 <acquire>
  if (f->ref < 1)
    8000427c:	40dc                	lw	a5,4(s1)
    8000427e:	02f05063          	blez	a5,8000429e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004282:	2785                	addiw	a5,a5,1
    80004284:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004286:	0001e517          	auipc	a0,0x1e
    8000428a:	61250513          	addi	a0,a0,1554 # 80022898 <ftable>
    8000428e:	a13fc0ef          	jal	80000ca0 <release>
  return f;
}
    80004292:	8526                	mv	a0,s1
    80004294:	60e2                	ld	ra,24(sp)
    80004296:	6442                	ld	s0,16(sp)
    80004298:	64a2                	ld	s1,8(sp)
    8000429a:	6105                	addi	sp,sp,32
    8000429c:	8082                	ret
    panic("filedup");
    8000429e:	00003517          	auipc	a0,0x3
    800042a2:	2e250513          	addi	a0,a0,738 # 80007580 <etext+0x580>
    800042a6:	d8efc0ef          	jal	80000834 <panic>

00000000800042aa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800042aa:	7139                	addi	sp,sp,-64
    800042ac:	fc06                	sd	ra,56(sp)
    800042ae:	f822                	sd	s0,48(sp)
    800042b0:	f426                	sd	s1,40(sp)
    800042b2:	0080                	addi	s0,sp,64
    800042b4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800042b6:	0001e517          	auipc	a0,0x1e
    800042ba:	5e250513          	addi	a0,a0,1506 # 80022898 <ftable>
    800042be:	95bfc0ef          	jal	80000c18 <acquire>
  if (f->ref < 1)
    800042c2:	40dc                	lw	a5,4(s1)
    800042c4:	04f05a63          	blez	a5,80004318 <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    800042c8:	37fd                	addiw	a5,a5,-1
    800042ca:	c0dc                	sw	a5,4(s1)
    800042cc:	06f04063          	bgtz	a5,8000432c <fileclose+0x82>
    800042d0:	f04a                	sd	s2,32(sp)
    800042d2:	ec4e                	sd	s3,24(sp)
    800042d4:	e852                	sd	s4,16(sp)
    800042d6:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800042d8:	0004a903          	lw	s2,0(s1)
    800042dc:	0094c783          	lbu	a5,9(s1)
    800042e0:	89be                	mv	s3,a5
    800042e2:	689c                	ld	a5,16(s1)
    800042e4:	8a3e                	mv	s4,a5
    800042e6:	6c9c                	ld	a5,24(s1)
    800042e8:	8abe                	mv	s5,a5
  f->ref = 0;
    800042ea:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800042ee:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800042f2:	0001e517          	auipc	a0,0x1e
    800042f6:	5a650513          	addi	a0,a0,1446 # 80022898 <ftable>
    800042fa:	9a7fc0ef          	jal	80000ca0 <release>

  if (ff.type == FD_PIPE) {
    800042fe:	4785                	li	a5,1
    80004300:	04f90163          	beq	s2,a5,80004342 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    80004304:	ffe9079b          	addiw	a5,s2,-2
    80004308:	4705                	li	a4,1
    8000430a:	04f77563          	bgeu	a4,a5,80004354 <fileclose+0xaa>
    8000430e:	7902                	ld	s2,32(sp)
    80004310:	69e2                	ld	s3,24(sp)
    80004312:	6a42                	ld	s4,16(sp)
    80004314:	6aa2                	ld	s5,8(sp)
    80004316:	a00d                	j	80004338 <fileclose+0x8e>
    80004318:	f04a                	sd	s2,32(sp)
    8000431a:	ec4e                	sd	s3,24(sp)
    8000431c:	e852                	sd	s4,16(sp)
    8000431e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004320:	00003517          	auipc	a0,0x3
    80004324:	26850513          	addi	a0,a0,616 # 80007588 <etext+0x588>
    80004328:	d0cfc0ef          	jal	80000834 <panic>
    release(&ftable.lock);
    8000432c:	0001e517          	auipc	a0,0x1e
    80004330:	56c50513          	addi	a0,a0,1388 # 80022898 <ftable>
    80004334:	96dfc0ef          	jal	80000ca0 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004338:	70e2                	ld	ra,56(sp)
    8000433a:	7442                	ld	s0,48(sp)
    8000433c:	74a2                	ld	s1,40(sp)
    8000433e:	6121                	addi	sp,sp,64
    80004340:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004342:	85ce                	mv	a1,s3
    80004344:	8552                	mv	a0,s4
    80004346:	360000ef          	jal	800046a6 <pipeclose>
    8000434a:	7902                	ld	s2,32(sp)
    8000434c:	69e2                	ld	s3,24(sp)
    8000434e:	6a42                	ld	s4,16(sp)
    80004350:	6aa2                	ld	s5,8(sp)
    80004352:	b7dd                	j	80004338 <fileclose+0x8e>
    begin_op();
    80004354:	a9dff0ef          	jal	80003df0 <begin_op>
    iput(ff.ip);
    80004358:	8556                	mv	a0,s5
    8000435a:	9aeff0ef          	jal	80003508 <iput>
    end_op();
    8000435e:	b1fff0ef          	jal	80003e7c <end_op>
    80004362:	7902                	ld	s2,32(sp)
    80004364:	69e2                	ld	s3,24(sp)
    80004366:	6a42                	ld	s4,16(sp)
    80004368:	6aa2                	ld	s5,8(sp)
    8000436a:	b7f9                	j	80004338 <fileclose+0x8e>

000000008000436c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000436c:	715d                	addi	sp,sp,-80
    8000436e:	e486                	sd	ra,72(sp)
    80004370:	e0a2                	sd	s0,64(sp)
    80004372:	fc26                	sd	s1,56(sp)
    80004374:	f052                	sd	s4,32(sp)
    80004376:	0880                	addi	s0,sp,80
    80004378:	84aa                	mv	s1,a0
    8000437a:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000437c:	dbcfd0ef          	jal	80001938 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    80004380:	409c                	lw	a5,0(s1)
    80004382:	37f9                	addiw	a5,a5,-2
    80004384:	4705                	li	a4,1
    80004386:	04f76463          	bltu	a4,a5,800043ce <filestat+0x62>
    8000438a:	f84a                	sd	s2,48(sp)
    8000438c:	f44e                	sd	s3,40(sp)
    8000438e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004390:	6c88                	ld	a0,24(s1)
    80004392:	ff5fe0ef          	jal	80003386 <ilock>
    stati(f->ip, &st);
    80004396:	fb840993          	addi	s3,s0,-72
    8000439a:	85ce                	mv	a1,s3
    8000439c:	6c88                	ld	a0,24(s1)
    8000439e:	b94ff0ef          	jal	80003732 <stati>
    iunlock(f->ip);
    800043a2:	6c88                	ld	a0,24(s1)
    800043a4:	890ff0ef          	jal	80003434 <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800043a8:	4761                	li	a4,24
    800043aa:	86ce                	mv	a3,s3
    800043ac:	8652                	mv	a2,s4
    800043ae:	05093583          	ld	a1,80(s2)
    800043b2:	05893503          	ld	a0,88(s2)
    800043b6:	9bcfd0ef          	jal	80001572 <copyout>
    800043ba:	41f5551b          	sraiw	a0,a0,0x1f
    800043be:	7942                	ld	s2,48(sp)
    800043c0:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800043c2:	60a6                	ld	ra,72(sp)
    800043c4:	6406                	ld	s0,64(sp)
    800043c6:	74e2                	ld	s1,56(sp)
    800043c8:	7a02                	ld	s4,32(sp)
    800043ca:	6161                	addi	sp,sp,80
    800043cc:	8082                	ret
  return -1;
    800043ce:	557d                	li	a0,-1
    800043d0:	bfcd                	j	800043c2 <filestat+0x56>

00000000800043d2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800043d2:	7179                	addi	sp,sp,-48
    800043d4:	f406                	sd	ra,40(sp)
    800043d6:	f022                	sd	s0,32(sp)
    800043d8:	e84a                	sd	s2,16(sp)
    800043da:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    800043dc:	00854783          	lbu	a5,8(a0)
    800043e0:	c3dd                	beqz	a5,80004486 <fileread+0xb4>
    800043e2:	ec26                	sd	s1,24(sp)
    800043e4:	e44e                	sd	s3,8(sp)
    800043e6:	84aa                	mv	s1,a0
    800043e8:	892e                	mv	s2,a1
    800043ea:	89b2                	mv	s3,a2
    800043ec:	01f6579b          	srliw	a5,a2,0x1f
    800043f0:	ebc9                	bnez	a5,80004482 <fileread+0xb0>
    return -1;

  if (f->type == FD_PIPE) {
    800043f2:	411c                	lw	a5,0(a0)
    800043f4:	4705                	li	a4,1
    800043f6:	04e78363          	beq	a5,a4,8000443c <fileread+0x6a>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800043fa:	470d                	li	a4,3
    800043fc:	04e78763          	beq	a5,a4,8000444a <fileread+0x78>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004400:	4709                	li	a4,2
    80004402:	06e79a63          	bne	a5,a4,80004476 <fileread+0xa4>
    ilock(f->ip);
    80004406:	6d08                	ld	a0,24(a0)
    80004408:	f7ffe0ef          	jal	80003386 <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000440c:	874e                	mv	a4,s3
    8000440e:	5094                	lw	a3,32(s1)
    80004410:	864a                	mv	a2,s2
    80004412:	4585                	li	a1,1
    80004414:	6c88                	ld	a0,24(s1)
    80004416:	b4aff0ef          	jal	80003760 <readi>
    8000441a:	892a                	mv	s2,a0
    8000441c:	00a05563          	blez	a0,80004426 <fileread+0x54>
      f->off += r;
    80004420:	509c                	lw	a5,32(s1)
    80004422:	9fa9                	addw	a5,a5,a0
    80004424:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004426:	6c88                	ld	a0,24(s1)
    80004428:	80cff0ef          	jal	80003434 <iunlock>
    8000442c:	64e2                	ld	s1,24(sp)
    8000442e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004430:	854a                	mv	a0,s2
    80004432:	70a2                	ld	ra,40(sp)
    80004434:	7402                	ld	s0,32(sp)
    80004436:	6942                	ld	s2,16(sp)
    80004438:	6145                	addi	sp,sp,48
    8000443a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000443c:	6908                	ld	a0,16(a0)
    8000443e:	3e2000ef          	jal	80004820 <piperead>
    80004442:	892a                	mv	s2,a0
    80004444:	64e2                	ld	s1,24(sp)
    80004446:	69a2                	ld	s3,8(sp)
    80004448:	b7e5                	j	80004430 <fileread+0x5e>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000444a:	02451783          	lh	a5,36(a0)
    8000444e:	03079693          	slli	a3,a5,0x30
    80004452:	92c1                	srli	a3,a3,0x30
    80004454:	4725                	li	a4,9
    80004456:	02d76b63          	bltu	a4,a3,8000448c <fileread+0xba>
    8000445a:	0792                	slli	a5,a5,0x4
    8000445c:	0001e717          	auipc	a4,0x1e
    80004460:	39c70713          	addi	a4,a4,924 # 800227f8 <devsw>
    80004464:	97ba                	add	a5,a5,a4
    80004466:	639c                	ld	a5,0(a5)
    80004468:	c79d                	beqz	a5,80004496 <fileread+0xc4>
    r = devsw[f->major].read(1, addr, n);
    8000446a:	4505                	li	a0,1
    8000446c:	9782                	jalr	a5
    8000446e:	892a                	mv	s2,a0
    80004470:	64e2                	ld	s1,24(sp)
    80004472:	69a2                	ld	s3,8(sp)
    80004474:	bf75                	j	80004430 <fileread+0x5e>
    panic("fileread");
    80004476:	00003517          	auipc	a0,0x3
    8000447a:	12250513          	addi	a0,a0,290 # 80007598 <etext+0x598>
    8000447e:	bb6fc0ef          	jal	80000834 <panic>
    80004482:	64e2                	ld	s1,24(sp)
    80004484:	69a2                	ld	s3,8(sp)
    return -1;
    80004486:	57fd                	li	a5,-1
    80004488:	893e                	mv	s2,a5
    8000448a:	b75d                	j	80004430 <fileread+0x5e>
      return -1;
    8000448c:	57fd                	li	a5,-1
    8000448e:	893e                	mv	s2,a5
    80004490:	64e2                	ld	s1,24(sp)
    80004492:	69a2                	ld	s3,8(sp)
    80004494:	bf71                	j	80004430 <fileread+0x5e>
    80004496:	57fd                	li	a5,-1
    80004498:	893e                	mv	s2,a5
    8000449a:	64e2                	ld	s1,24(sp)
    8000449c:	69a2                	ld	s3,8(sp)
    8000449e:	bf49                	j	80004430 <fileread+0x5e>

00000000800044a0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800044a0:	00954783          	lbu	a5,9(a0)
    800044a4:	12078b63          	beqz	a5,800045da <filewrite+0x13a>
{
    800044a8:	711d                	addi	sp,sp,-96
    800044aa:	ec86                	sd	ra,88(sp)
    800044ac:	e8a2                	sd	s0,80(sp)
    800044ae:	e0ca                	sd	s2,64(sp)
    800044b0:	f456                	sd	s5,40(sp)
    800044b2:	f05a                	sd	s6,32(sp)
    800044b4:	1080                	addi	s0,sp,96
    800044b6:	892a                	mv	s2,a0
    800044b8:	8b2e                	mv	s6,a1
    800044ba:	8ab2                	mv	s5,a2
  if (f->writable == 0 || n < 0)
    800044bc:	01f6579b          	srliw	a5,a2,0x1f
    800044c0:	0e079d63          	bnez	a5,800045ba <filewrite+0x11a>
    return -1;

  if (f->type == FD_PIPE) {
    800044c4:	411c                	lw	a5,0(a0)
    800044c6:	4705                	li	a4,1
    800044c8:	02e78a63          	beq	a5,a4,800044fc <filewrite+0x5c>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    800044cc:	470d                	li	a4,3
    800044ce:	02e78b63          	beq	a5,a4,80004504 <filewrite+0x64>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    800044d2:	4709                	li	a4,2
    800044d4:	0ce79763          	bne	a5,a4,800045a2 <filewrite+0x102>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    800044d8:	0ec05763          	blez	a2,800045c6 <filewrite+0x126>
    800044dc:	e4a6                	sd	s1,72(sp)
    800044de:	fc4e                	sd	s3,56(sp)
    800044e0:	f852                	sd	s4,48(sp)
    800044e2:	ec5e                	sd	s7,24(sp)
    800044e4:	e862                	sd	s8,16(sp)
    800044e6:	e466                	sd	s9,8(sp)
    int i = 0;
    800044e8:	4a01                	li	s4,0
      int n1 = n - i;
      if (n1 > max)
    800044ea:	6b85                	lui	s7,0x1
    800044ec:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800044f0:	6785                	lui	a5,0x1
    800044f2:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800044f6:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800044f8:	4c05                	li	s8,1
    800044fa:	a8ad                	j	80004574 <filewrite+0xd4>
    ret = pipewrite(f->pipe, addr, n);
    800044fc:	6908                	ld	a0,16(a0)
    800044fe:	206000ef          	jal	80004704 <pipewrite>
    80004502:	a849                	j	80004594 <filewrite+0xf4>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004504:	02451783          	lh	a5,36(a0)
    80004508:	03079693          	slli	a3,a5,0x30
    8000450c:	92c1                	srli	a3,a3,0x30
    8000450e:	4725                	li	a4,9
    80004510:	0ad76763          	bltu	a4,a3,800045be <filewrite+0x11e>
    80004514:	0792                	slli	a5,a5,0x4
    80004516:	0001e717          	auipc	a4,0x1e
    8000451a:	2e270713          	addi	a4,a4,738 # 800227f8 <devsw>
    8000451e:	97ba                	add	a5,a5,a4
    80004520:	679c                	ld	a5,8(a5)
    80004522:	c3c5                	beqz	a5,800045c2 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004524:	4505                	li	a0,1
    80004526:	9782                	jalr	a5
    80004528:	a0b5                	j	80004594 <filewrite+0xf4>
      if (n1 > max)
    8000452a:	2981                	sext.w	s3,s3
      begin_op();
    8000452c:	8c5ff0ef          	jal	80003df0 <begin_op>
      ilock(f->ip);
    80004530:	01893503          	ld	a0,24(s2)
    80004534:	e53fe0ef          	jal	80003386 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004538:	874e                	mv	a4,s3
    8000453a:	02092683          	lw	a3,32(s2)
    8000453e:	016a0633          	add	a2,s4,s6
    80004542:	85e2                	mv	a1,s8
    80004544:	01893503          	ld	a0,24(s2)
    80004548:	b0aff0ef          	jal	80003852 <writei>
    8000454c:	84aa                	mv	s1,a0
    8000454e:	00a05763          	blez	a0,8000455c <filewrite+0xbc>
        f->off += r;
    80004552:	02092783          	lw	a5,32(s2)
    80004556:	9fa9                	addw	a5,a5,a0
    80004558:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000455c:	01893503          	ld	a0,24(s2)
    80004560:	ed5fe0ef          	jal	80003434 <iunlock>
      end_op();
    80004564:	919ff0ef          	jal	80003e7c <end_op>

      if (r != n1) {
    80004568:	00999d63          	bne	s3,s1,80004582 <filewrite+0xe2>
        // error from writei
        break;
      }
      i += r;
    8000456c:	01448a3b          	addw	s4,s1,s4
    while (i < n) {
    80004570:	015a5963          	bge	s4,s5,80004582 <filewrite+0xe2>
      int n1 = n - i;
    80004574:	414a87bb          	subw	a5,s5,s4
    80004578:	89be                	mv	s3,a5
      if (n1 > max)
    8000457a:	fafbd8e3          	bge	s7,a5,8000452a <filewrite+0x8a>
    8000457e:	89e6                	mv	s3,s9
    80004580:	b76d                	j	8000452a <filewrite+0x8a>
    }
    ret = (i == n ? n : -1);
    80004582:	054a9463          	bne	s5,s4,800045ca <filewrite+0x12a>
    80004586:	8556                	mv	a0,s5
    80004588:	64a6                	ld	s1,72(sp)
    8000458a:	79e2                	ld	s3,56(sp)
    8000458c:	7a42                	ld	s4,48(sp)
    8000458e:	6be2                	ld	s7,24(sp)
    80004590:	6c42                	ld	s8,16(sp)
    80004592:	6ca2                	ld	s9,8(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004594:	60e6                	ld	ra,88(sp)
    80004596:	6446                	ld	s0,80(sp)
    80004598:	6906                	ld	s2,64(sp)
    8000459a:	7aa2                	ld	s5,40(sp)
    8000459c:	7b02                	ld	s6,32(sp)
    8000459e:	6125                	addi	sp,sp,96
    800045a0:	8082                	ret
    800045a2:	e4a6                	sd	s1,72(sp)
    800045a4:	fc4e                	sd	s3,56(sp)
    800045a6:	f852                	sd	s4,48(sp)
    800045a8:	ec5e                	sd	s7,24(sp)
    800045aa:	e862                	sd	s8,16(sp)
    800045ac:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800045ae:	00003517          	auipc	a0,0x3
    800045b2:	ffa50513          	addi	a0,a0,-6 # 800075a8 <etext+0x5a8>
    800045b6:	a7efc0ef          	jal	80000834 <panic>
    return -1;
    800045ba:	557d                	li	a0,-1
    800045bc:	bfe1                	j	80004594 <filewrite+0xf4>
      return -1;
    800045be:	557d                	li	a0,-1
    800045c0:	bfd1                	j	80004594 <filewrite+0xf4>
    800045c2:	557d                	li	a0,-1
    800045c4:	bfc1                	j	80004594 <filewrite+0xf4>
    ret = (i == n ? n : -1);
    800045c6:	8532                	mv	a0,a2
    800045c8:	b7f1                	j	80004594 <filewrite+0xf4>
    800045ca:	557d                	li	a0,-1
    800045cc:	64a6                	ld	s1,72(sp)
    800045ce:	79e2                	ld	s3,56(sp)
    800045d0:	7a42                	ld	s4,48(sp)
    800045d2:	6be2                	ld	s7,24(sp)
    800045d4:	6c42                	ld	s8,16(sp)
    800045d6:	6ca2                	ld	s9,8(sp)
    800045d8:	bf75                	j	80004594 <filewrite+0xf4>
    return -1;
    800045da:	557d                	li	a0,-1
}
    800045dc:	8082                	ret

00000000800045de <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800045de:	7179                	addi	sp,sp,-48
    800045e0:	f406                	sd	ra,40(sp)
    800045e2:	f022                	sd	s0,32(sp)
    800045e4:	ec26                	sd	s1,24(sp)
    800045e6:	e052                	sd	s4,0(sp)
    800045e8:	1800                	addi	s0,sp,48
    800045ea:	84aa                	mv	s1,a0
    800045ec:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800045ee:	0005b023          	sd	zero,0(a1)
    800045f2:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800045f6:	c11ff0ef          	jal	80004206 <filealloc>
    800045fa:	e088                	sd	a0,0(s1)
    800045fc:	c549                	beqz	a0,80004686 <pipealloc+0xa8>
    800045fe:	c09ff0ef          	jal	80004206 <filealloc>
    80004602:	00aa3023          	sd	a0,0(s4)
    80004606:	cd25                	beqz	a0,8000467e <pipealloc+0xa0>
    80004608:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000460a:	d04fc0ef          	jal	80000b0e <kalloc>
    8000460e:	892a                	mv	s2,a0
    80004610:	c12d                	beqz	a0,80004672 <pipealloc+0x94>
    80004612:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004614:	4985                	li	s3,1
    80004616:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000461a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000461e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004622:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004626:	00003597          	auipc	a1,0x3
    8000462a:	f9258593          	addi	a1,a1,-110 # 800075b8 <etext+0x5b8>
    8000462e:	d6afc0ef          	jal	80000b98 <initlock>
  (*f0)->type = FD_PIPE;
    80004632:	609c                	ld	a5,0(s1)
    80004634:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004638:	609c                	ld	a5,0(s1)
    8000463a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000463e:	609c                	ld	a5,0(s1)
    80004640:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004644:	609c                	ld	a5,0(s1)
    80004646:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000464a:	000a3783          	ld	a5,0(s4)
    8000464e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004652:	000a3783          	ld	a5,0(s4)
    80004656:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000465a:	000a3783          	ld	a5,0(s4)
    8000465e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004662:	000a3783          	ld	a5,0(s4)
    80004666:	0127b823          	sd	s2,16(a5)
  return 0;
    8000466a:	4501                	li	a0,0
    8000466c:	6942                	ld	s2,16(sp)
    8000466e:	69a2                	ld	s3,8(sp)
    80004670:	a01d                	j	80004696 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    80004672:	6088                	ld	a0,0(s1)
    80004674:	c119                	beqz	a0,8000467a <pipealloc+0x9c>
    80004676:	6942                	ld	s2,16(sp)
    80004678:	a029                	j	80004682 <pipealloc+0xa4>
    8000467a:	6942                	ld	s2,16(sp)
    8000467c:	a029                	j	80004686 <pipealloc+0xa8>
    8000467e:	6088                	ld	a0,0(s1)
    80004680:	c10d                	beqz	a0,800046a2 <pipealloc+0xc4>
    fileclose(*f0);
    80004682:	c29ff0ef          	jal	800042aa <fileclose>
  if (*f1)
    80004686:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000468a:	557d                	li	a0,-1
  if (*f1)
    8000468c:	c789                	beqz	a5,80004696 <pipealloc+0xb8>
    fileclose(*f1);
    8000468e:	853e                	mv	a0,a5
    80004690:	c1bff0ef          	jal	800042aa <fileclose>
  return -1;
    80004694:	557d                	li	a0,-1
}
    80004696:	70a2                	ld	ra,40(sp)
    80004698:	7402                	ld	s0,32(sp)
    8000469a:	64e2                	ld	s1,24(sp)
    8000469c:	6a02                	ld	s4,0(sp)
    8000469e:	6145                	addi	sp,sp,48
    800046a0:	8082                	ret
  return -1;
    800046a2:	557d                	li	a0,-1
    800046a4:	bfcd                	j	80004696 <pipealloc+0xb8>

00000000800046a6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800046a6:	1101                	addi	sp,sp,-32
    800046a8:	ec06                	sd	ra,24(sp)
    800046aa:	e822                	sd	s0,16(sp)
    800046ac:	e426                	sd	s1,8(sp)
    800046ae:	e04a                	sd	s2,0(sp)
    800046b0:	1000                	addi	s0,sp,32
    800046b2:	84aa                	mv	s1,a0
    800046b4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800046b6:	d62fc0ef          	jal	80000c18 <acquire>
  if (writable) {
    800046ba:	02090763          	beqz	s2,800046e8 <pipeclose+0x42>
    pi->writeopen = 0;
    800046be:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800046c2:	21848513          	addi	a0,s1,536
    800046c6:	9bdfd0ef          	jal	80002082 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800046ca:	2204a783          	lw	a5,544(s1)
    800046ce:	e781                	bnez	a5,800046d6 <pipeclose+0x30>
    800046d0:	2244a783          	lw	a5,548(s1)
    800046d4:	c38d                	beqz	a5,800046f6 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char *)pi);
  } else
    release(&pi->lock);
    800046d6:	8526                	mv	a0,s1
    800046d8:	dc8fc0ef          	jal	80000ca0 <release>
}
    800046dc:	60e2                	ld	ra,24(sp)
    800046de:	6442                	ld	s0,16(sp)
    800046e0:	64a2                	ld	s1,8(sp)
    800046e2:	6902                	ld	s2,0(sp)
    800046e4:	6105                	addi	sp,sp,32
    800046e6:	8082                	ret
    pi->readopen = 0;
    800046e8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800046ec:	21c48513          	addi	a0,s1,540
    800046f0:	993fd0ef          	jal	80002082 <wakeup>
    800046f4:	bfd9                	j	800046ca <pipeclose+0x24>
    release(&pi->lock);
    800046f6:	8526                	mv	a0,s1
    800046f8:	da8fc0ef          	jal	80000ca0 <release>
    kfree((char *)pi);
    800046fc:	8526                	mv	a0,s1
    800046fe:	b28fc0ef          	jal	80000a26 <kfree>
    80004702:	bfe9                	j	800046dc <pipeclose+0x36>

0000000080004704 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004704:	7159                	addi	sp,sp,-112
    80004706:	f486                	sd	ra,104(sp)
    80004708:	f0a2                	sd	s0,96(sp)
    8000470a:	eca6                	sd	s1,88(sp)
    8000470c:	e8ca                	sd	s2,80(sp)
    8000470e:	e4ce                	sd	s3,72(sp)
    80004710:	e0d2                	sd	s4,64(sp)
    80004712:	fc56                	sd	s5,56(sp)
    80004714:	1880                	addi	s0,sp,112
    80004716:	84aa                	mv	s1,a0
    80004718:	8aae                	mv	s5,a1
    8000471a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000471c:	a1cfd0ef          	jal	80001938 <myproc>
    80004720:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004722:	8526                	mv	a0,s1
    80004724:	cf4fc0ef          	jal	80000c18 <acquire>
  while (i < n) {
    80004728:	0f405a63          	blez	s4,8000481c <pipewrite+0x118>
    8000472c:	f85a                	sd	s6,48(sp)
    8000472e:	f45e                	sd	s7,40(sp)
    80004730:	f062                	sd	s8,32(sp)
    80004732:	ec66                	sd	s9,24(sp)
    80004734:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004736:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004738:	f9f40c13          	addi	s8,s0,-97
    8000473c:	4b85                	li	s7,1
    8000473e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004740:	21848d13          	addi	s10,s1,536
      sleep_prepare(&pi->nwrite);
    80004744:	21c48c93          	addi	s9,s1,540
    80004748:	a0a1                	j	80004790 <pipewrite+0x8c>
      release(&pi->lock);
    8000474a:	8526                	mv	a0,s1
    8000474c:	d54fc0ef          	jal	80000ca0 <release>
      return -1;
    80004750:	597d                	li	s2,-1
    80004752:	7b42                	ld	s6,48(sp)
    80004754:	7ba2                	ld	s7,40(sp)
    80004756:	7c02                	ld	s8,32(sp)
    80004758:	6ce2                	ld	s9,24(sp)
    8000475a:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000475c:	854a                	mv	a0,s2
    8000475e:	70a6                	ld	ra,104(sp)
    80004760:	7406                	ld	s0,96(sp)
    80004762:	64e6                	ld	s1,88(sp)
    80004764:	6946                	ld	s2,80(sp)
    80004766:	69a6                	ld	s3,72(sp)
    80004768:	6a06                	ld	s4,64(sp)
    8000476a:	7ae2                	ld	s5,56(sp)
    8000476c:	6165                	addi	sp,sp,112
    8000476e:	8082                	ret
      wakeup(&pi->nread);
    80004770:	856a                	mv	a0,s10
    80004772:	911fd0ef          	jal	80002082 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004776:	8566                	mv	a0,s9
    80004778:	89ffd0ef          	jal	80002016 <sleep_prepare>
      release(&pi->lock);
    8000477c:	8526                	mv	a0,s1
    8000477e:	d22fc0ef          	jal	80000ca0 <release>
      sleep();
    80004782:	8d1fd0ef          	jal	80002052 <sleep>
      acquire(&pi->lock);
    80004786:	8526                	mv	a0,s1
    80004788:	c90fc0ef          	jal	80000c18 <acquire>
  while (i < n) {
    8000478c:	07495b63          	bge	s2,s4,80004802 <pipewrite+0xfe>
    if (pi->readopen == 0 || killed(pr)) {
    80004790:	2204a783          	lw	a5,544(s1)
    80004794:	dbdd                	beqz	a5,8000474a <pipewrite+0x46>
    80004796:	854e                	mv	a0,s3
    80004798:	ad7fd0ef          	jal	8000226e <killed>
    8000479c:	f55d                	bnez	a0,8000474a <pipewrite+0x46>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    8000479e:	2184a783          	lw	a5,536(s1)
    800047a2:	21c4a703          	lw	a4,540(s1)
    800047a6:	2007879b          	addiw	a5,a5,512
    800047aa:	fcf703e3          	beq	a4,a5,80004770 <pipewrite+0x6c>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800047ae:	875e                	mv	a4,s7
    800047b0:	015906b3          	add	a3,s2,s5
    800047b4:	8662                	mv	a2,s8
    800047b6:	0509b583          	ld	a1,80(s3)
    800047ba:	0589b503          	ld	a0,88(s3)
    800047be:	e7bfc0ef          	jal	80001638 <copyin>
    800047c2:	03650163          	beq	a0,s6,800047e4 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800047c6:	21c4a783          	lw	a5,540(s1)
    800047ca:	0017871b          	addiw	a4,a5,1
    800047ce:	20e4ae23          	sw	a4,540(s1)
    800047d2:	1ff7f793          	andi	a5,a5,511
    800047d6:	97a6                	add	a5,a5,s1
    800047d8:	f9f44703          	lbu	a4,-97(s0)
    800047dc:	00e78c23          	sb	a4,24(a5)
      i++;
    800047e0:	2905                	addiw	s2,s2,1
    800047e2:	b76d                	j	8000478c <pipewrite+0x88>
        if (i == 0)
    800047e4:	00090863          	beqz	s2,800047f4 <pipewrite+0xf0>
    800047e8:	7b42                	ld	s6,48(sp)
    800047ea:	7ba2                	ld	s7,40(sp)
    800047ec:	7c02                	ld	s8,32(sp)
    800047ee:	6ce2                	ld	s9,24(sp)
    800047f0:	6d42                	ld	s10,16(sp)
    800047f2:	a829                	j	8000480c <pipewrite+0x108>
          i = -1;
    800047f4:	892a                	mv	s2,a0
        break;
    800047f6:	7b42                	ld	s6,48(sp)
    800047f8:	7ba2                	ld	s7,40(sp)
    800047fa:	7c02                	ld	s8,32(sp)
    800047fc:	6ce2                	ld	s9,24(sp)
    800047fe:	6d42                	ld	s10,16(sp)
    80004800:	a031                	j	8000480c <pipewrite+0x108>
    80004802:	7b42                	ld	s6,48(sp)
    80004804:	7ba2                	ld	s7,40(sp)
    80004806:	7c02                	ld	s8,32(sp)
    80004808:	6ce2                	ld	s9,24(sp)
    8000480a:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000480c:	21848513          	addi	a0,s1,536
    80004810:	873fd0ef          	jal	80002082 <wakeup>
  release(&pi->lock);
    80004814:	8526                	mv	a0,s1
    80004816:	c8afc0ef          	jal	80000ca0 <release>
  return i;
    8000481a:	b789                	j	8000475c <pipewrite+0x58>
  int i = 0;
    8000481c:	4901                	li	s2,0
    8000481e:	b7fd                	j	8000480c <pipewrite+0x108>

0000000080004820 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004820:	711d                	addi	sp,sp,-96
    80004822:	ec86                	sd	ra,88(sp)
    80004824:	e8a2                	sd	s0,80(sp)
    80004826:	e4a6                	sd	s1,72(sp)
    80004828:	e0ca                	sd	s2,64(sp)
    8000482a:	fc4e                	sd	s3,56(sp)
    8000482c:	f852                	sd	s4,48(sp)
    8000482e:	f456                	sd	s5,40(sp)
    80004830:	1080                	addi	s0,sp,96
    80004832:	84aa                	mv	s1,a0
    80004834:	89ae                	mv	s3,a1
    80004836:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004838:	900fd0ef          	jal	80001938 <myproc>
    8000483c:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    8000483e:	8526                	mv	a0,s1
    80004840:	bd8fc0ef          	jal	80000c18 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004844:	2184a703          	lw	a4,536(s1)
    80004848:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    8000484c:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004850:	02f71e63          	bne	a4,a5,8000488c <piperead+0x6c>
    80004854:	2244a783          	lw	a5,548(s1)
    80004858:	c3b9                	beqz	a5,8000489e <piperead+0x7e>
    if (killed(pr)) {
    8000485a:	854a                	mv	a0,s2
    8000485c:	a13fd0ef          	jal	8000226e <killed>
    80004860:	e915                	bnez	a0,80004894 <piperead+0x74>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004862:	8552                	mv	a0,s4
    80004864:	fb2fd0ef          	jal	80002016 <sleep_prepare>
    release(&pi->lock);
    80004868:	8526                	mv	a0,s1
    8000486a:	c36fc0ef          	jal	80000ca0 <release>
    sleep();
    8000486e:	fe4fd0ef          	jal	80002052 <sleep>
    acquire(&pi->lock);
    80004872:	8526                	mv	a0,s1
    80004874:	ba4fc0ef          	jal	80000c18 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004878:	2184a703          	lw	a4,536(s1)
    8000487c:	21c4a783          	lw	a5,540(s1)
    80004880:	fcf70ae3          	beq	a4,a5,80004854 <piperead+0x34>
    80004884:	f05a                	sd	s6,32(sp)
    80004886:	ec5e                	sd	s7,24(sp)
    80004888:	e862                	sd	s8,16(sp)
    8000488a:	a829                	j	800048a4 <piperead+0x84>
    8000488c:	f05a                	sd	s6,32(sp)
    8000488e:	ec5e                	sd	s7,24(sp)
    80004890:	e862                	sd	s8,16(sp)
    80004892:	a809                	j	800048a4 <piperead+0x84>
      release(&pi->lock);
    80004894:	8526                	mv	a0,s1
    80004896:	c0afc0ef          	jal	80000ca0 <release>
      return -1;
    8000489a:	5a7d                	li	s4,-1
    8000489c:	a0b5                	j	80004908 <piperead+0xe8>
    8000489e:	f05a                	sd	s6,32(sp)
    800048a0:	ec5e                	sd	s7,24(sp)
    800048a2:	e862                	sd	s8,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800048a4:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800048a6:	faf40c13          	addi	s8,s0,-81
    800048aa:	4b85                	li	s7,1
    800048ac:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800048ae:	05505363          	blez	s5,800048f4 <piperead+0xd4>
    if (pi->nread == pi->nwrite)
    800048b2:	2184a783          	lw	a5,536(s1)
    800048b6:	21c4a703          	lw	a4,540(s1)
    800048ba:	02f70d63          	beq	a4,a5,800048f4 <piperead+0xd4>
    ch = pi->data[pi->nread % PIPESIZE];
    800048be:	1ff7f793          	andi	a5,a5,511
    800048c2:	97a6                	add	a5,a5,s1
    800048c4:	0187c783          	lbu	a5,24(a5)
    800048c8:	faf407a3          	sb	a5,-81(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800048cc:	875e                	mv	a4,s7
    800048ce:	86e2                	mv	a3,s8
    800048d0:	864e                	mv	a2,s3
    800048d2:	05093583          	ld	a1,80(s2)
    800048d6:	05893503          	ld	a0,88(s2)
    800048da:	c99fc0ef          	jal	80001572 <copyout>
    800048de:	03650f63          	beq	a0,s6,8000491c <piperead+0xfc>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800048e2:	2184a783          	lw	a5,536(s1)
    800048e6:	2785                	addiw	a5,a5,1
    800048e8:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800048ec:	2a05                	addiw	s4,s4,1
    800048ee:	0985                	addi	s3,s3,1
    800048f0:	fd4a91e3          	bne	s5,s4,800048b2 <piperead+0x92>
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800048f4:	21c48513          	addi	a0,s1,540
    800048f8:	f8afd0ef          	jal	80002082 <wakeup>
  release(&pi->lock);
    800048fc:	8526                	mv	a0,s1
    800048fe:	ba2fc0ef          	jal	80000ca0 <release>
    80004902:	7b02                	ld	s6,32(sp)
    80004904:	6be2                	ld	s7,24(sp)
    80004906:	6c42                	ld	s8,16(sp)
  return i;
}
    80004908:	8552                	mv	a0,s4
    8000490a:	60e6                	ld	ra,88(sp)
    8000490c:	6446                	ld	s0,80(sp)
    8000490e:	64a6                	ld	s1,72(sp)
    80004910:	6906                	ld	s2,64(sp)
    80004912:	79e2                	ld	s3,56(sp)
    80004914:	7a42                	ld	s4,48(sp)
    80004916:	7aa2                	ld	s5,40(sp)
    80004918:	6125                	addi	sp,sp,96
    8000491a:	8082                	ret
      if (i == 0)
    8000491c:	fc0a1ce3          	bnez	s4,800048f4 <piperead+0xd4>
        i = -1;
    80004920:	8a2a                	mv	s4,a0
    80004922:	bfc9                	j	800048f4 <piperead+0xd4>

0000000080004924 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004924:	1141                	addi	sp,sp,-16
    80004926:	e406                	sd	ra,8(sp)
    80004928:	e022                	sd	s0,0(sp)
    8000492a:	0800                	addi	s0,sp,16
    8000492c:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    8000492e:	0035151b          	slliw	a0,a0,0x3
    80004932:	8921                	andi	a0,a0,8
    perm = PTE_X;
  if (flags & 0x2)
    80004934:	8b89                	andi	a5,a5,2
    80004936:	c399                	beqz	a5,8000493c <flags2perm+0x18>
    perm |= PTE_W;
    80004938:	00456513          	ori	a0,a0,4
  return perm;
}
    8000493c:	60a2                	ld	ra,8(sp)
    8000493e:	6402                	ld	s0,0(sp)
    80004940:	0141                	addi	sp,sp,16
    80004942:	8082                	ret

0000000080004944 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004944:	de010113          	addi	sp,sp,-544
    80004948:	20113c23          	sd	ra,536(sp)
    8000494c:	20813823          	sd	s0,528(sp)
    80004950:	20913423          	sd	s1,520(sp)
    80004954:	21213023          	sd	s2,512(sp)
    80004958:	1400                	addi	s0,sp,544
    8000495a:	892a                	mv	s2,a0
    8000495c:	dea43823          	sd	a0,-528(s0)
    80004960:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004964:	fd5fc0ef          	jal	80001938 <myproc>
    80004968:	84aa                	mv	s1,a0

  begin_op();
    8000496a:	c86ff0ef          	jal	80003df0 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    8000496e:	854a                	mv	a0,s2
    80004970:	aa2ff0ef          	jal	80003c12 <namei>
    80004974:	cd21                	beqz	a0,800049cc <kexec+0x88>
    80004976:	fbd2                	sd	s4,496(sp)
    80004978:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000497a:	a0dfe0ef          	jal	80003386 <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000497e:	04000713          	li	a4,64
    80004982:	4681                	li	a3,0
    80004984:	e5040613          	addi	a2,s0,-432
    80004988:	4581                	li	a1,0
    8000498a:	8552                	mv	a0,s4
    8000498c:	dd5fe0ef          	jal	80003760 <readi>
    80004990:	04000793          	li	a5,64
    80004994:	00f51a63          	bne	a0,a5,800049a8 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004998:	e5042703          	lw	a4,-432(s0)
    8000499c:	464c47b7          	lui	a5,0x464c4
    800049a0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800049a4:	02f70863          	beq	a4,a5,800049d4 <kexec+0x90>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    800049a8:	8552                	mv	a0,s4
    800049aa:	c31fe0ef          	jal	800035da <iunlockput>
    end_op();
    800049ae:	cceff0ef          	jal	80003e7c <end_op>
  }
  return -1;
    800049b2:	557d                	li	a0,-1
    800049b4:	7a5e                	ld	s4,496(sp)
}
    800049b6:	21813083          	ld	ra,536(sp)
    800049ba:	21013403          	ld	s0,528(sp)
    800049be:	20813483          	ld	s1,520(sp)
    800049c2:	20013903          	ld	s2,512(sp)
    800049c6:	22010113          	addi	sp,sp,544
    800049ca:	8082                	ret
    end_op();
    800049cc:	cb0ff0ef          	jal	80003e7c <end_op>
    return -1;
    800049d0:	557d                	li	a0,-1
    800049d2:	b7d5                	j	800049b6 <kexec+0x72>
    800049d4:	f3da                	sd	s6,480(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    800049d6:	8526                	mv	a0,s1
    800049d8:	876fd0ef          	jal	80001a4e <proc_pagetable>
    800049dc:	8b2a                	mv	s6,a0
    800049de:	26050e63          	beqz	a0,80004c5a <kexec+0x316>
    800049e2:	ffce                	sd	s3,504(sp)
    800049e4:	f7d6                	sd	s5,488(sp)
    800049e6:	efde                	sd	s7,472(sp)
    800049e8:	ebe2                	sd	s8,464(sp)
    800049ea:	e7e6                	sd	s9,456(sp)
    800049ec:	e3ea                	sd	s10,448(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049ee:	e8845783          	lhu	a5,-376(s0)
    800049f2:	14078263          	beqz	a5,80004b36 <kexec+0x1f2>
    800049f6:	ff6e                	sd	s11,440(sp)
    800049f8:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800049fc:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800049fe:	4d01                	li	s10,0
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a00:	03800d93          	li	s11,56
    if (ph.vaddr % PGSIZE != 0)
    80004a04:	6c85                	lui	s9,0x1
    80004a06:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a0a:	def43423          	sd	a5,-536(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    80004a0e:	6a85                	lui	s5,0x1
    80004a10:	a085                	j	80004a70 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a12:	00003517          	auipc	a0,0x3
    80004a16:	bae50513          	addi	a0,a0,-1106 # 800075c0 <etext+0x5c0>
    80004a1a:	e1bfb0ef          	jal	80000834 <panic>
    if (sz - i < PGSIZE)
    80004a1e:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004a20:	874a                	mv	a4,s2
    80004a22:	009b86bb          	addw	a3,s7,s1
    80004a26:	4581                	li	a1,0
    80004a28:	8552                	mv	a0,s4
    80004a2a:	d37fe0ef          	jal	80003760 <readi>
    80004a2e:	22a91a63          	bne	s2,a0,80004c62 <kexec+0x31e>
  for (i = 0; i < sz; i += PGSIZE) {
    80004a32:	009a84bb          	addw	s1,s5,s1
    80004a36:	0334f263          	bgeu	s1,s3,80004a5a <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004a3a:	02049593          	slli	a1,s1,0x20
    80004a3e:	9181                	srli	a1,a1,0x20
    80004a40:	95e2                	add	a1,a1,s8
    80004a42:	855a                	mv	a0,s6
    80004a44:	dc4fc0ef          	jal	80001008 <walkaddr>
    80004a48:	862a                	mv	a2,a0
    if (pa == 0)
    80004a4a:	d561                	beqz	a0,80004a12 <kexec+0xce>
    if (sz - i < PGSIZE)
    80004a4c:	409987bb          	subw	a5,s3,s1
    80004a50:	893e                	mv	s2,a5
    80004a52:	fcfcf6e3          	bgeu	s9,a5,80004a1e <kexec+0xda>
    80004a56:	8956                	mv	s2,s5
    80004a58:	b7d9                	j	80004a1e <kexec+0xda>
    sz = sz1;
    80004a5a:	df843903          	ld	s2,-520(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004a5e:	2d05                	addiw	s10,s10,1
    80004a60:	e0843783          	ld	a5,-504(s0)
    80004a64:	0387869b          	addiw	a3,a5,56
    80004a68:	e8845783          	lhu	a5,-376(s0)
    80004a6c:	06fd5d63          	bge	s10,a5,80004ae6 <kexec+0x1a2>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a70:	e0d43423          	sd	a3,-504(s0)
    80004a74:	876e                	mv	a4,s11
    80004a76:	e1840613          	addi	a2,s0,-488
    80004a7a:	4581                	li	a1,0
    80004a7c:	8552                	mv	a0,s4
    80004a7e:	ce3fe0ef          	jal	80003760 <readi>
    80004a82:	1db51e63          	bne	a0,s11,80004c5e <kexec+0x31a>
    if (ph.type != ELF_PROG_LOAD)
    80004a86:	e1842783          	lw	a5,-488(s0)
    80004a8a:	4705                	li	a4,1
    80004a8c:	fce799e3          	bne	a5,a4,80004a5e <kexec+0x11a>
    if (ph.memsz < ph.filesz)
    80004a90:	e4043483          	ld	s1,-448(s0)
    80004a94:	e3843783          	ld	a5,-456(s0)
    80004a98:	1ef4e363          	bltu	s1,a5,80004c7e <kexec+0x33a>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004a9c:	e2843783          	ld	a5,-472(s0)
    80004aa0:	94be                	add	s1,s1,a5
    80004aa2:	1ef4e163          	bltu	s1,a5,80004c84 <kexec+0x340>
    if (ph.vaddr % PGSIZE != 0)
    80004aa6:	de843703          	ld	a4,-536(s0)
    80004aaa:	8ff9                	and	a5,a5,a4
    80004aac:	1c079f63          	bnez	a5,80004c8a <kexec+0x346>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    80004ab0:	e1c42503          	lw	a0,-484(s0)
    80004ab4:	e71ff0ef          	jal	80004924 <flags2perm>
    80004ab8:	86aa                	mv	a3,a0
    80004aba:	8626                	mv	a2,s1
    80004abc:	85ca                	mv	a1,s2
    80004abe:	855a                	mv	a0,s6
    80004ac0:	81ffc0ef          	jal	800012de <uvmalloc>
    80004ac4:	dea43c23          	sd	a0,-520(s0)
    80004ac8:	1c050463          	beqz	a0,80004c90 <kexec+0x34c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004acc:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004ad0:	00098863          	beqz	s3,80004ae0 <kexec+0x19c>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ad4:	e2843c03          	ld	s8,-472(s0)
    80004ad8:	e2042b83          	lw	s7,-480(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    80004adc:	4481                	li	s1,0
    80004ade:	bfb1                	j	80004a3a <kexec+0xf6>
    sz = sz1;
    80004ae0:	df843903          	ld	s2,-520(s0)
    80004ae4:	bfad                	j	80004a5e <kexec+0x11a>
    80004ae6:	7dfa                	ld	s11,440(sp)
  iunlockput(ip);
    80004ae8:	8552                	mv	a0,s4
    80004aea:	af1fe0ef          	jal	800035da <iunlockput>
  end_op();
    80004aee:	b8eff0ef          	jal	80003e7c <end_op>
  p = myproc();
    80004af2:	e47fc0ef          	jal	80001938 <myproc>
    80004af6:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    80004af8:	05053a83          	ld	s5,80(a0)
  sz = PGROUNDUP(sz);
    80004afc:	6c05                	lui	s8,0x1
    80004afe:	1c7d                	addi	s8,s8,-1 # fff <_entry-0x7ffff001>
    80004b00:	9c4a                	add	s8,s8,s2
    80004b02:	77fd                	lui	a5,0xfffff
    80004b04:	00fc7c33          	and	s8,s8,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    80004b08:	4691                	li	a3,4
    80004b0a:	6609                	lui	a2,0x2
    80004b0c:	9662                	add	a2,a2,s8
    80004b0e:	85e2                	mv	a1,s8
    80004b10:	855a                	mv	a0,s6
    80004b12:	fccfc0ef          	jal	800012de <uvmalloc>
    80004b16:	892a                	mv	s2,a0
    80004b18:	e10d                	bnez	a0,80004b3a <kexec+0x1f6>
    proc_freepagetable(pagetable, sz);
    80004b1a:	85e2                	mv	a1,s8
    80004b1c:	855a                	mv	a0,s6
    80004b1e:	fb5fc0ef          	jal	80001ad2 <proc_freepagetable>
  return -1;
    80004b22:	557d                	li	a0,-1
    80004b24:	79fe                	ld	s3,504(sp)
    80004b26:	7a5e                	ld	s4,496(sp)
    80004b28:	7abe                	ld	s5,488(sp)
    80004b2a:	7b1e                	ld	s6,480(sp)
    80004b2c:	6bfe                	ld	s7,472(sp)
    80004b2e:	6c5e                	ld	s8,464(sp)
    80004b30:	6cbe                	ld	s9,456(sp)
    80004b32:	6d1e                	ld	s10,448(sp)
    80004b34:	b549                	j	800049b6 <kexec+0x72>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b36:	4901                	li	s2,0
    80004b38:	bf45                	j	80004ae8 <kexec+0x1a4>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    80004b3a:	75f9                	lui	a1,0xffffe
    80004b3c:	95aa                	add	a1,a1,a0
    80004b3e:	855a                	mv	a0,s6
    80004b40:	971fc0ef          	jal	800014b0 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    80004b44:	80090a13          	addi	s4,s2,-2048
    80004b48:	800a0a13          	addi	s4,s4,-2048
  for (argc = 0; argv[argc]; argc++) {
    80004b4c:	e0043783          	ld	a5,-512(s0)
    80004b50:	6388                	ld	a0,0(a5)
    80004b52:	c545                	beqz	a0,80004bfa <kexec+0x2b6>
  sp = sz;
    80004b54:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004b56:	4481                	li	s1,0
    ustack[argc] = sp;
    80004b58:	e9040b93          	addi	s7,s0,-368
    sp -= strlen(argv[argc]) + 1;
    80004b5c:	b06fc0ef          	jal	80000e62 <strlen>
    80004b60:	0015079b          	addiw	a5,a0,1
    80004b64:	40fc07b3          	sub	a5,s8,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b68:	ff07fc13          	andi	s8,a5,-16
    if (sp < stackbase)
    80004b6c:	134c6563          	bltu	s8,s4,80004c96 <kexec+0x352>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b70:	e0043d03          	ld	s10,-512(s0)
    80004b74:	000d3c83          	ld	s9,0(s10)
    80004b78:	8566                	mv	a0,s9
    80004b7a:	ae8fc0ef          	jal	80000e62 <strlen>
    80004b7e:	0015071b          	addiw	a4,a0,1
    80004b82:	86e6                	mv	a3,s9
    80004b84:	8662                	mv	a2,s8
    80004b86:	85ca                	mv	a1,s2
    80004b88:	855a                	mv	a0,s6
    80004b8a:	9e9fc0ef          	jal	80001572 <copyout>
    80004b8e:	10054663          	bltz	a0,80004c9a <kexec+0x356>
    ustack[argc] = sp;
    80004b92:	00349793          	slli	a5,s1,0x3
    80004b96:	97de                	add	a5,a5,s7
    80004b98:	0187b023          	sd	s8,0(a5) # fffffffffffff000 <end+0xffffffff7ffdb670>
  for (argc = 0; argv[argc]; argc++) {
    80004b9c:	0485                	addi	s1,s1,1
    80004b9e:	008d0793          	addi	a5,s10,8
    80004ba2:	e0f43023          	sd	a5,-512(s0)
    80004ba6:	008d3503          	ld	a0,8(s10)
    80004baa:	f94d                	bnez	a0,80004b5c <kexec+0x218>
  ustack[argc] = 0;
    80004bac:	00349793          	slli	a5,s1,0x3
    80004bb0:	f9078793          	addi	a5,a5,-112
    80004bb4:	97a2                	add	a5,a5,s0
    80004bb6:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004bba:	00349713          	slli	a4,s1,0x3
    80004bbe:	0721                	addi	a4,a4,8
    80004bc0:	40ec0bb3          	sub	s7,s8,a4
  sp -= sp % 16;
    80004bc4:	ff0bfb93          	andi	s7,s7,-16
  sz = sz1;
    80004bc8:	8c4a                	mv	s8,s2
  if (sp < stackbase)
    80004bca:	f54be8e3          	bltu	s7,s4,80004b1a <kexec+0x1d6>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    80004bce:	e9040693          	addi	a3,s0,-368
    80004bd2:	865e                	mv	a2,s7
    80004bd4:	85ca                	mv	a1,s2
    80004bd6:	855a                	mv	a0,s6
    80004bd8:	99bfc0ef          	jal	80001572 <copyout>
    80004bdc:	f2054fe3          	bltz	a0,80004b1a <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004be0:	0609b783          	ld	a5,96(s3)
    80004be4:	0777bc23          	sd	s7,120(a5)
  for (last = s = path; *s; s++)
    80004be8:	df043783          	ld	a5,-528(s0)
    80004bec:	0007c703          	lbu	a4,0(a5)
    80004bf0:	c30d                	beqz	a4,80004c12 <kexec+0x2ce>
    80004bf2:	0785                	addi	a5,a5,1
    if (*s == '/')
    80004bf4:	02f00693          	li	a3,47
    80004bf8:	a801                	j	80004c08 <kexec+0x2c4>
  sp = sz;
    80004bfa:	8c4a                	mv	s8,s2
  for (argc = 0; argv[argc]; argc++) {
    80004bfc:	4481                	li	s1,0
    80004bfe:	b77d                	j	80004bac <kexec+0x268>
  for (last = s = path; *s; s++)
    80004c00:	0785                	addi	a5,a5,1
    80004c02:	fff7c703          	lbu	a4,-1(a5)
    80004c06:	c711                	beqz	a4,80004c12 <kexec+0x2ce>
    if (*s == '/')
    80004c08:	fed71ce3          	bne	a4,a3,80004c00 <kexec+0x2bc>
      last = s + 1;
    80004c0c:	def43823          	sd	a5,-528(s0)
    80004c10:	bfc5                	j	80004c00 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c12:	4641                	li	a2,16
    80004c14:	df043583          	ld	a1,-528(s0)
    80004c18:	16098513          	addi	a0,s3,352
    80004c1c:	a10fc0ef          	jal	80000e2c <safestrcpy>
  oldpagetable = p->pagetable;
    80004c20:	0589b503          	ld	a0,88(s3)
  p->pagetable = pagetable;
    80004c24:	0569bc23          	sd	s6,88(s3)
  p->sz = sz;
    80004c28:	0529b823          	sd	s2,80(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004c2c:	0609b783          	ld	a5,96(s3)
    80004c30:	e6843703          	ld	a4,-408(s0)
    80004c34:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004c36:	0609b783          	ld	a5,96(s3)
    80004c3a:	0377b823          	sd	s7,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c3e:	85d6                	mv	a1,s5
    80004c40:	e93fc0ef          	jal	80001ad2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c44:	0004851b          	sext.w	a0,s1
    80004c48:	79fe                	ld	s3,504(sp)
    80004c4a:	7a5e                	ld	s4,496(sp)
    80004c4c:	7abe                	ld	s5,488(sp)
    80004c4e:	7b1e                	ld	s6,480(sp)
    80004c50:	6bfe                	ld	s7,472(sp)
    80004c52:	6c5e                	ld	s8,464(sp)
    80004c54:	6cbe                	ld	s9,456(sp)
    80004c56:	6d1e                	ld	s10,448(sp)
    80004c58:	bbb9                	j	800049b6 <kexec+0x72>
    80004c5a:	7b1e                	ld	s6,480(sp)
    80004c5c:	b3b1                	j	800049a8 <kexec+0x64>
    80004c5e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c62:	df843583          	ld	a1,-520(s0)
    80004c66:	855a                	mv	a0,s6
    80004c68:	e6bfc0ef          	jal	80001ad2 <proc_freepagetable>
  if (ip) {
    80004c6c:	79fe                	ld	s3,504(sp)
    80004c6e:	7abe                	ld	s5,488(sp)
    80004c70:	7b1e                	ld	s6,480(sp)
    80004c72:	6bfe                	ld	s7,472(sp)
    80004c74:	6c5e                	ld	s8,464(sp)
    80004c76:	6cbe                	ld	s9,456(sp)
    80004c78:	6d1e                	ld	s10,448(sp)
    80004c7a:	7dfa                	ld	s11,440(sp)
    80004c7c:	b335                	j	800049a8 <kexec+0x64>
    80004c7e:	df243c23          	sd	s2,-520(s0)
    80004c82:	b7c5                	j	80004c62 <kexec+0x31e>
    80004c84:	df243c23          	sd	s2,-520(s0)
    80004c88:	bfe9                	j	80004c62 <kexec+0x31e>
    80004c8a:	df243c23          	sd	s2,-520(s0)
    80004c8e:	bfd1                	j	80004c62 <kexec+0x31e>
    80004c90:	df243c23          	sd	s2,-520(s0)
    80004c94:	b7f9                	j	80004c62 <kexec+0x31e>
  sz = sz1;
    80004c96:	8c4a                	mv	s8,s2
    80004c98:	b549                	j	80004b1a <kexec+0x1d6>
    80004c9a:	8c4a                	mv	s8,s2
    80004c9c:	bdbd                	j	80004b1a <kexec+0x1d6>

0000000080004c9e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004c9e:	7179                	addi	sp,sp,-48
    80004ca0:	f406                	sd	ra,40(sp)
    80004ca2:	f022                	sd	s0,32(sp)
    80004ca4:	ec26                	sd	s1,24(sp)
    80004ca6:	e84a                	sd	s2,16(sp)
    80004ca8:	1800                	addi	s0,sp,48
    80004caa:	892e                	mv	s2,a1
    80004cac:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004cae:	fdc40593          	addi	a1,s0,-36
    80004cb2:	c9dfd0ef          	jal	8000294e <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004cb6:	fdc42703          	lw	a4,-36(s0)
    80004cba:	47bd                	li	a5,15
    80004cbc:	02e7ea63          	bltu	a5,a4,80004cf0 <argfd+0x52>
    80004cc0:	c79fc0ef          	jal	80001938 <myproc>
    80004cc4:	fdc42703          	lw	a4,-36(s0)
    80004cc8:	00371793          	slli	a5,a4,0x3
    80004ccc:	0d078793          	addi	a5,a5,208
    80004cd0:	953e                	add	a0,a0,a5
    80004cd2:	651c                	ld	a5,8(a0)
    80004cd4:	c385                	beqz	a5,80004cf4 <argfd+0x56>
    return -1;
  if (pfd)
    80004cd6:	00090463          	beqz	s2,80004cde <argfd+0x40>
    *pfd = fd;
    80004cda:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004cde:	4501                	li	a0,0
  if (pf)
    80004ce0:	c091                	beqz	s1,80004ce4 <argfd+0x46>
    *pf = f;
    80004ce2:	e09c                	sd	a5,0(s1)
}
    80004ce4:	70a2                	ld	ra,40(sp)
    80004ce6:	7402                	ld	s0,32(sp)
    80004ce8:	64e2                	ld	s1,24(sp)
    80004cea:	6942                	ld	s2,16(sp)
    80004cec:	6145                	addi	sp,sp,48
    80004cee:	8082                	ret
    return -1;
    80004cf0:	557d                	li	a0,-1
    80004cf2:	bfcd                	j	80004ce4 <argfd+0x46>
    80004cf4:	557d                	li	a0,-1
    80004cf6:	b7fd                	j	80004ce4 <argfd+0x46>

0000000080004cf8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004cf8:	1101                	addi	sp,sp,-32
    80004cfa:	ec06                	sd	ra,24(sp)
    80004cfc:	e822                	sd	s0,16(sp)
    80004cfe:	e426                	sd	s1,8(sp)
    80004d00:	1000                	addi	s0,sp,32
    80004d02:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d04:	c35fc0ef          	jal	80001938 <myproc>
    80004d08:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004d0a:	0d850793          	addi	a5,a0,216
    80004d0e:	4501                	li	a0,0
    80004d10:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004d12:	6398                	ld	a4,0(a5)
    80004d14:	cb19                	beqz	a4,80004d2a <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004d16:	2505                	addiw	a0,a0,1
    80004d18:	07a1                	addi	a5,a5,8
    80004d1a:	fed51ce3          	bne	a0,a3,80004d12 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d1e:	557d                	li	a0,-1
}
    80004d20:	60e2                	ld	ra,24(sp)
    80004d22:	6442                	ld	s0,16(sp)
    80004d24:	64a2                	ld	s1,8(sp)
    80004d26:	6105                	addi	sp,sp,32
    80004d28:	8082                	ret
      p->ofile[fd] = f;
    80004d2a:	00351793          	slli	a5,a0,0x3
    80004d2e:	0d078793          	addi	a5,a5,208
    80004d32:	963e                	add	a2,a2,a5
    80004d34:	e604                	sd	s1,8(a2)
      return fd;
    80004d36:	b7ed                	j	80004d20 <fdalloc+0x28>

0000000080004d38 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004d38:	715d                	addi	sp,sp,-80
    80004d3a:	e486                	sd	ra,72(sp)
    80004d3c:	e0a2                	sd	s0,64(sp)
    80004d3e:	fc26                	sd	s1,56(sp)
    80004d40:	f84a                	sd	s2,48(sp)
    80004d42:	f052                	sd	s4,32(sp)
    80004d44:	ec56                	sd	s5,24(sp)
    80004d46:	e85a                	sd	s6,16(sp)
    80004d48:	0880                	addi	s0,sp,80
    80004d4a:	8a2e                	mv	s4,a1
    80004d4c:	8ab2                	mv	s5,a2
    80004d4e:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004d50:	fb040593          	addi	a1,s0,-80
    80004d54:	ed9fe0ef          	jal	80003c2c <nameiparent>
    80004d58:	84aa                	mv	s1,a0
    80004d5a:	12050f63          	beqz	a0,80004e98 <create+0x160>
    return 0;

  ilock(dp);
    80004d5e:	e28fe0ef          	jal	80003386 <ilock>

  if (dp->nlink == 0) {
    80004d62:	04a49783          	lh	a5,74(s1)
    80004d66:	cbb9                	beqz	a5,80004dbc <create+0x84>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004d68:	7761                	lui	a4,0xffff8
    80004d6a:	0705                	addi	a4,a4,1 # ffffffffffff8001 <end+0xffffffff7ffd4671>
    80004d6c:	97ba                	add	a5,a5,a4
    80004d6e:	e781                	bnez	a5,80004d76 <create+0x3e>
    80004d70:	fffa0793          	addi	a5,s4,-1
    80004d74:	cba9                	beqz	a5,80004dc6 <create+0x8e>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004d76:	4601                	li	a2,0
    80004d78:	fb040593          	addi	a1,s0,-80
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	bf1fe0ef          	jal	8000396e <dirlookup>
    80004d82:	892a                	mv	s2,a0
    80004d84:	c939                	beqz	a0,80004dda <create+0xa2>
    iunlockput(dp);
    80004d86:	8526                	mv	a0,s1
    80004d88:	853fe0ef          	jal	800035da <iunlockput>
    ilock(ip);
    80004d8c:	854a                	mv	a0,s2
    80004d8e:	df8fe0ef          	jal	80003386 <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004d92:	4789                	li	a5,2
    80004d94:	02fa1e63          	bne	s4,a5,80004dd0 <create+0x98>
    80004d98:	04495783          	lhu	a5,68(s2)
    80004d9c:	37f9                	addiw	a5,a5,-2
    80004d9e:	17c2                	slli	a5,a5,0x30
    80004da0:	93c1                	srli	a5,a5,0x30
    80004da2:	4705                	li	a4,1
    80004da4:	02f76663          	bltu	a4,a5,80004dd0 <create+0x98>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004da8:	854a                	mv	a0,s2
    80004daa:	60a6                	ld	ra,72(sp)
    80004dac:	6406                	ld	s0,64(sp)
    80004dae:	74e2                	ld	s1,56(sp)
    80004db0:	7942                	ld	s2,48(sp)
    80004db2:	7a02                	ld	s4,32(sp)
    80004db4:	6ae2                	ld	s5,24(sp)
    80004db6:	6b42                	ld	s6,16(sp)
    80004db8:	6161                	addi	sp,sp,80
    80004dba:	8082                	ret
    iunlockput(dp);
    80004dbc:	8526                	mv	a0,s1
    80004dbe:	81dfe0ef          	jal	800035da <iunlockput>
    return 0;
    80004dc2:	4901                	li	s2,0
    80004dc4:	b7d5                	j	80004da8 <create+0x70>
    iunlockput(dp);
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	813fe0ef          	jal	800035da <iunlockput>
    return 0;
    80004dcc:	4901                	li	s2,0
    80004dce:	bfe9                	j	80004da8 <create+0x70>
    iunlockput(ip);
    80004dd0:	854a                	mv	a0,s2
    80004dd2:	809fe0ef          	jal	800035da <iunlockput>
    return 0;
    80004dd6:	4901                	li	s2,0
    80004dd8:	bfc1                	j	80004da8 <create+0x70>
    80004dda:	f44e                	sd	s3,40(sp)
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004ddc:	85d2                	mv	a1,s4
    80004dde:	4088                	lw	a0,0(s1)
    80004de0:	c36fe0ef          	jal	80003216 <ialloc>
    80004de4:	89aa                	mv	s3,a0
    80004de6:	cd1d                	beqz	a0,80004e24 <create+0xec>
  ilock(ip);
    80004de8:	d9efe0ef          	jal	80003386 <ilock>
  ip->major = major;
    80004dec:	05599323          	sh	s5,70(s3)
  ip->minor = minor;
    80004df0:	05699423          	sh	s6,72(s3)
  ip->nlink = 1;
    80004df4:	4705                	li	a4,1
    80004df6:	04e99523          	sh	a4,74(s3)
  iupdate(ip);
    80004dfa:	854e                	mv	a0,s3
    80004dfc:	cd6fe0ef          	jal	800032d2 <iupdate>
  if (type == T_DIR) { // Create . and .. entries.
    80004e00:	4705                	li	a4,1
    80004e02:	02ea0763          	beq	s4,a4,80004e30 <create+0xf8>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e06:	0049a603          	lw	a2,4(s3)
    80004e0a:	fb040593          	addi	a1,s0,-80
    80004e0e:	8526                	mv	a0,s1
    80004e10:	d59fe0ef          	jal	80003b68 <dirlink>
    80004e14:	06054563          	bltz	a0,80004e7e <create+0x146>
  iunlockput(dp);
    80004e18:	8526                	mv	a0,s1
    80004e1a:	fc0fe0ef          	jal	800035da <iunlockput>
  return ip;
    80004e1e:	894e                	mv	s2,s3
    80004e20:	79a2                	ld	s3,40(sp)
    80004e22:	b759                	j	80004da8 <create+0x70>
    iunlockput(dp);
    80004e24:	8526                	mv	a0,s1
    80004e26:	fb4fe0ef          	jal	800035da <iunlockput>
    return 0;
    80004e2a:	894e                	mv	s2,s3
    80004e2c:	79a2                	ld	s3,40(sp)
    80004e2e:	bfad                	j	80004da8 <create+0x70>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e30:	0049a603          	lw	a2,4(s3)
    80004e34:	00002597          	auipc	a1,0x2
    80004e38:	7ac58593          	addi	a1,a1,1964 # 800075e0 <etext+0x5e0>
    80004e3c:	854e                	mv	a0,s3
    80004e3e:	d2bfe0ef          	jal	80003b68 <dirlink>
    80004e42:	02054e63          	bltz	a0,80004e7e <create+0x146>
    80004e46:	40d0                	lw	a2,4(s1)
    80004e48:	00002597          	auipc	a1,0x2
    80004e4c:	7a058593          	addi	a1,a1,1952 # 800075e8 <etext+0x5e8>
    80004e50:	854e                	mv	a0,s3
    80004e52:	d17fe0ef          	jal	80003b68 <dirlink>
    80004e56:	02054463          	bltz	a0,80004e7e <create+0x146>
  if (dirlink(dp, name, ip->inum) < 0)
    80004e5a:	0049a603          	lw	a2,4(s3)
    80004e5e:	fb040593          	addi	a1,s0,-80
    80004e62:	8526                	mv	a0,s1
    80004e64:	d05fe0ef          	jal	80003b68 <dirlink>
    80004e68:	00054b63          	bltz	a0,80004e7e <create+0x146>
    dp->nlink++; // for ".."
    80004e6c:	04a4d783          	lhu	a5,74(s1)
    80004e70:	2785                	addiw	a5,a5,1
    80004e72:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e76:	8526                	mv	a0,s1
    80004e78:	c5afe0ef          	jal	800032d2 <iupdate>
    80004e7c:	bf71                	j	80004e18 <create+0xe0>
  ip->nlink = 0;
    80004e7e:	04099523          	sh	zero,74(s3)
  iupdate(ip);
    80004e82:	854e                	mv	a0,s3
    80004e84:	c4efe0ef          	jal	800032d2 <iupdate>
  iunlockput(ip);
    80004e88:	854e                	mv	a0,s3
    80004e8a:	f50fe0ef          	jal	800035da <iunlockput>
  iunlockput(dp);
    80004e8e:	8526                	mv	a0,s1
    80004e90:	f4afe0ef          	jal	800035da <iunlockput>
  return 0;
    80004e94:	79a2                	ld	s3,40(sp)
    80004e96:	bf09                	j	80004da8 <create+0x70>
    return 0;
    80004e98:	892a                	mv	s2,a0
    80004e9a:	b739                	j	80004da8 <create+0x70>

0000000080004e9c <sys_dup>:
{
    80004e9c:	7179                	addi	sp,sp,-48
    80004e9e:	f406                	sd	ra,40(sp)
    80004ea0:	f022                	sd	s0,32(sp)
    80004ea2:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004ea4:	fd840613          	addi	a2,s0,-40
    80004ea8:	4581                	li	a1,0
    80004eaa:	4501                	li	a0,0
    80004eac:	df3ff0ef          	jal	80004c9e <argfd>
    return -1;
    80004eb0:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004eb2:	02054363          	bltz	a0,80004ed8 <sys_dup+0x3c>
    80004eb6:	ec26                	sd	s1,24(sp)
    80004eb8:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004eba:	fd843483          	ld	s1,-40(s0)
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	e39ff0ef          	jal	80004cf8 <fdalloc>
    80004ec4:	892a                	mv	s2,a0
    return -1;
    80004ec6:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004ec8:	00054d63          	bltz	a0,80004ee2 <sys_dup+0x46>
  filedup(f);
    80004ecc:	8526                	mv	a0,s1
    80004ece:	b96ff0ef          	jal	80004264 <filedup>
  return fd;
    80004ed2:	87ca                	mv	a5,s2
    80004ed4:	64e2                	ld	s1,24(sp)
    80004ed6:	6942                	ld	s2,16(sp)
}
    80004ed8:	853e                	mv	a0,a5
    80004eda:	70a2                	ld	ra,40(sp)
    80004edc:	7402                	ld	s0,32(sp)
    80004ede:	6145                	addi	sp,sp,48
    80004ee0:	8082                	ret
    80004ee2:	64e2                	ld	s1,24(sp)
    80004ee4:	6942                	ld	s2,16(sp)
    80004ee6:	bfcd                	j	80004ed8 <sys_dup+0x3c>

0000000080004ee8 <sys_read>:
{
    80004ee8:	7179                	addi	sp,sp,-48
    80004eea:	f406                	sd	ra,40(sp)
    80004eec:	f022                	sd	s0,32(sp)
    80004eee:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ef0:	fd840593          	addi	a1,s0,-40
    80004ef4:	4505                	li	a0,1
    80004ef6:	a75fd0ef          	jal	8000296a <argaddr>
  argint(2, &n);
    80004efa:	fe440593          	addi	a1,s0,-28
    80004efe:	4509                	li	a0,2
    80004f00:	a4ffd0ef          	jal	8000294e <argint>
  if (argfd(0, 0, &f) < 0)
    80004f04:	fe840613          	addi	a2,s0,-24
    80004f08:	4581                	li	a1,0
    80004f0a:	4501                	li	a0,0
    80004f0c:	d93ff0ef          	jal	80004c9e <argfd>
    80004f10:	87aa                	mv	a5,a0
    return -1;
    80004f12:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f14:	0007ca63          	bltz	a5,80004f28 <sys_read+0x40>
  return fileread(f, p, n);
    80004f18:	fe442603          	lw	a2,-28(s0)
    80004f1c:	fd843583          	ld	a1,-40(s0)
    80004f20:	fe843503          	ld	a0,-24(s0)
    80004f24:	caeff0ef          	jal	800043d2 <fileread>
}
    80004f28:	70a2                	ld	ra,40(sp)
    80004f2a:	7402                	ld	s0,32(sp)
    80004f2c:	6145                	addi	sp,sp,48
    80004f2e:	8082                	ret

0000000080004f30 <sys_write>:
{
    80004f30:	7179                	addi	sp,sp,-48
    80004f32:	f406                	sd	ra,40(sp)
    80004f34:	f022                	sd	s0,32(sp)
    80004f36:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f38:	fd840593          	addi	a1,s0,-40
    80004f3c:	4505                	li	a0,1
    80004f3e:	a2dfd0ef          	jal	8000296a <argaddr>
  argint(2, &n);
    80004f42:	fe440593          	addi	a1,s0,-28
    80004f46:	4509                	li	a0,2
    80004f48:	a07fd0ef          	jal	8000294e <argint>
  if (argfd(0, 0, &f) < 0)
    80004f4c:	fe840613          	addi	a2,s0,-24
    80004f50:	4581                	li	a1,0
    80004f52:	4501                	li	a0,0
    80004f54:	d4bff0ef          	jal	80004c9e <argfd>
    80004f58:	87aa                	mv	a5,a0
    return -1;
    80004f5a:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004f5c:	0007ca63          	bltz	a5,80004f70 <sys_write+0x40>
  return filewrite(f, p, n);
    80004f60:	fe442603          	lw	a2,-28(s0)
    80004f64:	fd843583          	ld	a1,-40(s0)
    80004f68:	fe843503          	ld	a0,-24(s0)
    80004f6c:	d34ff0ef          	jal	800044a0 <filewrite>
}
    80004f70:	70a2                	ld	ra,40(sp)
    80004f72:	7402                	ld	s0,32(sp)
    80004f74:	6145                	addi	sp,sp,48
    80004f76:	8082                	ret

0000000080004f78 <sys_close>:
{
    80004f78:	1101                	addi	sp,sp,-32
    80004f7a:	ec06                	sd	ra,24(sp)
    80004f7c:	e822                	sd	s0,16(sp)
    80004f7e:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004f80:	fe040613          	addi	a2,s0,-32
    80004f84:	fec40593          	addi	a1,s0,-20
    80004f88:	4501                	li	a0,0
    80004f8a:	d15ff0ef          	jal	80004c9e <argfd>
    return -1;
    80004f8e:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004f90:	02054163          	bltz	a0,80004fb2 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004f94:	9a5fc0ef          	jal	80001938 <myproc>
    80004f98:	fec42783          	lw	a5,-20(s0)
    80004f9c:	078e                	slli	a5,a5,0x3
    80004f9e:	0d078793          	addi	a5,a5,208
    80004fa2:	953e                	add	a0,a0,a5
    80004fa4:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80004fa8:	fe043503          	ld	a0,-32(s0)
    80004fac:	afeff0ef          	jal	800042aa <fileclose>
  return 0;
    80004fb0:	4781                	li	a5,0
}
    80004fb2:	853e                	mv	a0,a5
    80004fb4:	60e2                	ld	ra,24(sp)
    80004fb6:	6442                	ld	s0,16(sp)
    80004fb8:	6105                	addi	sp,sp,32
    80004fba:	8082                	ret

0000000080004fbc <sys_fstat>:
{
    80004fbc:	1101                	addi	sp,sp,-32
    80004fbe:	ec06                	sd	ra,24(sp)
    80004fc0:	e822                	sd	s0,16(sp)
    80004fc2:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004fc4:	fe040593          	addi	a1,s0,-32
    80004fc8:	4505                	li	a0,1
    80004fca:	9a1fd0ef          	jal	8000296a <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004fce:	fe840613          	addi	a2,s0,-24
    80004fd2:	4581                	li	a1,0
    80004fd4:	4501                	li	a0,0
    80004fd6:	cc9ff0ef          	jal	80004c9e <argfd>
    80004fda:	87aa                	mv	a5,a0
    return -1;
    80004fdc:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004fde:	0007c863          	bltz	a5,80004fee <sys_fstat+0x32>
  return filestat(f, st);
    80004fe2:	fe043583          	ld	a1,-32(s0)
    80004fe6:	fe843503          	ld	a0,-24(s0)
    80004fea:	b82ff0ef          	jal	8000436c <filestat>
}
    80004fee:	60e2                	ld	ra,24(sp)
    80004ff0:	6442                	ld	s0,16(sp)
    80004ff2:	6105                	addi	sp,sp,32
    80004ff4:	8082                	ret

0000000080004ff6 <sys_link>:
{
    80004ff6:	7169                	addi	sp,sp,-304
    80004ff8:	f606                	sd	ra,296(sp)
    80004ffa:	f222                	sd	s0,288(sp)
    80004ffc:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ffe:	08000613          	li	a2,128
    80005002:	ed040593          	addi	a1,s0,-304
    80005006:	4501                	li	a0,0
    80005008:	97ffd0ef          	jal	80002986 <argstr>
    return -1;
    8000500c:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000500e:	10054163          	bltz	a0,80005110 <sys_link+0x11a>
    80005012:	08000613          	li	a2,128
    80005016:	f5040593          	addi	a1,s0,-176
    8000501a:	4505                	li	a0,1
    8000501c:	96bfd0ef          	jal	80002986 <argstr>
    return -1;
    80005020:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005022:	0e054763          	bltz	a0,80005110 <sys_link+0x11a>
    80005026:	ee26                	sd	s1,280(sp)
  begin_op();
    80005028:	dc9fe0ef          	jal	80003df0 <begin_op>
  if ((ip = namei(old)) == 0) {
    8000502c:	ed040513          	addi	a0,s0,-304
    80005030:	be3fe0ef          	jal	80003c12 <namei>
    80005034:	84aa                	mv	s1,a0
    80005036:	cd35                	beqz	a0,800050b2 <sys_link+0xbc>
  ilock(ip);
    80005038:	b4efe0ef          	jal	80003386 <ilock>
  if (ip->type == T_DIR) {
    8000503c:	04449703          	lh	a4,68(s1)
    80005040:	4785                	li	a5,1
    80005042:	06f70d63          	beq	a4,a5,800050bc <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80005046:	04a49783          	lh	a5,74(s1)
    8000504a:	6721                	lui	a4,0x8
    8000504c:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    8000504e:	06e78f63          	beq	a5,a4,800050cc <sys_link+0xd6>
    80005052:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005054:	2785                	addiw	a5,a5,1
    80005056:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000505a:	8526                	mv	a0,s1
    8000505c:	a76fe0ef          	jal	800032d2 <iupdate>
  iunlock(ip);
    80005060:	8526                	mv	a0,s1
    80005062:	bd2fe0ef          	jal	80003434 <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80005066:	fd040593          	addi	a1,s0,-48
    8000506a:	f5040513          	addi	a0,s0,-176
    8000506e:	bbffe0ef          	jal	80003c2c <nameiparent>
    80005072:	892a                	mv	s2,a0
    80005074:	c93d                	beqz	a0,800050ea <sys_link+0xf4>
  ilock(dp);
    80005076:	b10fe0ef          	jal	80003386 <ilock>
  if (dp->nlink == 0) {
    8000507a:	04a91783          	lh	a5,74(s2)
    8000507e:	cfb9                	beqz	a5,800050dc <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80005080:	854a                	mv	a0,s2
    80005082:	00092703          	lw	a4,0(s2)
    80005086:	409c                	lw	a5,0(s1)
    80005088:	04f71e63          	bne	a4,a5,800050e4 <sys_link+0xee>
    8000508c:	40d0                	lw	a2,4(s1)
    8000508e:	fd040593          	addi	a1,s0,-48
    80005092:	ad7fe0ef          	jal	80003b68 <dirlink>
    80005096:	04054763          	bltz	a0,800050e4 <sys_link+0xee>
  iunlockput(dp);
    8000509a:	854a                	mv	a0,s2
    8000509c:	d3efe0ef          	jal	800035da <iunlockput>
  iput(ip);
    800050a0:	8526                	mv	a0,s1
    800050a2:	c66fe0ef          	jal	80003508 <iput>
  end_op();
    800050a6:	dd7fe0ef          	jal	80003e7c <end_op>
  return 0;
    800050aa:	4781                	li	a5,0
    800050ac:	64f2                	ld	s1,280(sp)
    800050ae:	6952                	ld	s2,272(sp)
    800050b0:	a085                	j	80005110 <sys_link+0x11a>
    end_op();
    800050b2:	dcbfe0ef          	jal	80003e7c <end_op>
    return -1;
    800050b6:	57fd                	li	a5,-1
    800050b8:	64f2                	ld	s1,280(sp)
    800050ba:	a899                	j	80005110 <sys_link+0x11a>
    iunlockput(ip);
    800050bc:	8526                	mv	a0,s1
    800050be:	d1cfe0ef          	jal	800035da <iunlockput>
    end_op();
    800050c2:	dbbfe0ef          	jal	80003e7c <end_op>
    return -1;
    800050c6:	57fd                	li	a5,-1
    800050c8:	64f2                	ld	s1,280(sp)
    800050ca:	a099                	j	80005110 <sys_link+0x11a>
    iunlockput(ip);
    800050cc:	8526                	mv	a0,s1
    800050ce:	d0cfe0ef          	jal	800035da <iunlockput>
    end_op();
    800050d2:	dabfe0ef          	jal	80003e7c <end_op>
    return -1;
    800050d6:	57fd                	li	a5,-1
    800050d8:	64f2                	ld	s1,280(sp)
    800050da:	a81d                	j	80005110 <sys_link+0x11a>
    iunlockput(dp);
    800050dc:	854a                	mv	a0,s2
    800050de:	cfcfe0ef          	jal	800035da <iunlockput>
    goto bad;
    800050e2:	a021                	j	800050ea <sys_link+0xf4>
    iunlockput(dp);
    800050e4:	854a                	mv	a0,s2
    800050e6:	cf4fe0ef          	jal	800035da <iunlockput>
  ilock(ip);
    800050ea:	8526                	mv	a0,s1
    800050ec:	a9afe0ef          	jal	80003386 <ilock>
  ip->nlink--;
    800050f0:	04a4d783          	lhu	a5,74(s1)
    800050f4:	37fd                	addiw	a5,a5,-1
    800050f6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050fa:	8526                	mv	a0,s1
    800050fc:	9d6fe0ef          	jal	800032d2 <iupdate>
  iunlockput(ip);
    80005100:	8526                	mv	a0,s1
    80005102:	cd8fe0ef          	jal	800035da <iunlockput>
  end_op();
    80005106:	d77fe0ef          	jal	80003e7c <end_op>
  return -1;
    8000510a:	57fd                	li	a5,-1
    8000510c:	64f2                	ld	s1,280(sp)
    8000510e:	6952                	ld	s2,272(sp)
}
    80005110:	853e                	mv	a0,a5
    80005112:	70b2                	ld	ra,296(sp)
    80005114:	7412                	ld	s0,288(sp)
    80005116:	6155                	addi	sp,sp,304
    80005118:	8082                	ret

000000008000511a <sys_unlink>:
{
    8000511a:	7151                	addi	sp,sp,-240
    8000511c:	f586                	sd	ra,232(sp)
    8000511e:	f1a2                	sd	s0,224(sp)
    80005120:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80005122:	08000613          	li	a2,128
    80005126:	f3040593          	addi	a1,s0,-208
    8000512a:	4501                	li	a0,0
    8000512c:	85bfd0ef          	jal	80002986 <argstr>
    80005130:	14054d63          	bltz	a0,8000528a <sys_unlink+0x170>
    80005134:	eda6                	sd	s1,216(sp)
  begin_op();
    80005136:	cbbfe0ef          	jal	80003df0 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    8000513a:	fb040593          	addi	a1,s0,-80
    8000513e:	f3040513          	addi	a0,s0,-208
    80005142:	aebfe0ef          	jal	80003c2c <nameiparent>
    80005146:	84aa                	mv	s1,a0
    80005148:	c955                	beqz	a0,800051fc <sys_unlink+0xe2>
  ilock(dp);
    8000514a:	a3cfe0ef          	jal	80003386 <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000514e:	00002597          	auipc	a1,0x2
    80005152:	49258593          	addi	a1,a1,1170 # 800075e0 <etext+0x5e0>
    80005156:	fb040513          	addi	a0,s0,-80
    8000515a:	ffefe0ef          	jal	80003958 <namecmp>
    8000515e:	10050b63          	beqz	a0,80005274 <sys_unlink+0x15a>
    80005162:	00002597          	auipc	a1,0x2
    80005166:	48658593          	addi	a1,a1,1158 # 800075e8 <etext+0x5e8>
    8000516a:	fb040513          	addi	a0,s0,-80
    8000516e:	feafe0ef          	jal	80003958 <namecmp>
    80005172:	10050163          	beqz	a0,80005274 <sys_unlink+0x15a>
    80005176:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80005178:	f2c40613          	addi	a2,s0,-212
    8000517c:	fb040593          	addi	a1,s0,-80
    80005180:	8526                	mv	a0,s1
    80005182:	fecfe0ef          	jal	8000396e <dirlookup>
    80005186:	892a                	mv	s2,a0
    80005188:	0e050563          	beqz	a0,80005272 <sys_unlink+0x158>
    8000518c:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000518e:	9f8fe0ef          	jal	80003386 <ilock>
  if (ip->nlink < 1)
    80005192:	04a91783          	lh	a5,74(s2)
    80005196:	06f05863          	blez	a5,80005206 <sys_unlink+0xec>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    8000519a:	04491703          	lh	a4,68(s2)
    8000519e:	4785                	li	a5,1
    800051a0:	06f70963          	beq	a4,a5,80005212 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800051a4:	fc040993          	addi	s3,s0,-64
    800051a8:	4641                	li	a2,16
    800051aa:	4581                	li	a1,0
    800051ac:	854e                	mv	a0,s3
    800051ae:	b2bfb0ef          	jal	80000cd8 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051b2:	4741                	li	a4,16
    800051b4:	f2c42683          	lw	a3,-212(s0)
    800051b8:	864e                	mv	a2,s3
    800051ba:	4581                	li	a1,0
    800051bc:	8526                	mv	a0,s1
    800051be:	e94fe0ef          	jal	80003852 <writei>
    800051c2:	47c1                	li	a5,16
    800051c4:	08f51863          	bne	a0,a5,80005254 <sys_unlink+0x13a>
  if (ip->type == T_DIR) {
    800051c8:	04491703          	lh	a4,68(s2)
    800051cc:	4785                	li	a5,1
    800051ce:	08f70963          	beq	a4,a5,80005260 <sys_unlink+0x146>
  iunlockput(dp);
    800051d2:	8526                	mv	a0,s1
    800051d4:	c06fe0ef          	jal	800035da <iunlockput>
  ip->nlink--;
    800051d8:	04a95783          	lhu	a5,74(s2)
    800051dc:	37fd                	addiw	a5,a5,-1
    800051de:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800051e2:	854a                	mv	a0,s2
    800051e4:	8eefe0ef          	jal	800032d2 <iupdate>
  iunlockput(ip);
    800051e8:	854a                	mv	a0,s2
    800051ea:	bf0fe0ef          	jal	800035da <iunlockput>
  end_op();
    800051ee:	c8ffe0ef          	jal	80003e7c <end_op>
  return 0;
    800051f2:	4501                	li	a0,0
    800051f4:	64ee                	ld	s1,216(sp)
    800051f6:	694e                	ld	s2,208(sp)
    800051f8:	69ae                	ld	s3,200(sp)
    800051fa:	a061                	j	80005282 <sys_unlink+0x168>
    end_op();
    800051fc:	c81fe0ef          	jal	80003e7c <end_op>
    return -1;
    80005200:	557d                	li	a0,-1
    80005202:	64ee                	ld	s1,216(sp)
    80005204:	a8bd                	j	80005282 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005206:	00002517          	auipc	a0,0x2
    8000520a:	3ea50513          	addi	a0,a0,1002 # 800075f0 <etext+0x5f0>
    8000520e:	e26fb0ef          	jal	80000834 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005212:	04c92703          	lw	a4,76(s2)
    80005216:	02000793          	li	a5,32
    8000521a:	f8e7f5e3          	bgeu	a5,a4,800051a4 <sys_unlink+0x8a>
    8000521e:	89be                	mv	s3,a5
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005220:	4741                	li	a4,16
    80005222:	86ce                	mv	a3,s3
    80005224:	f1840613          	addi	a2,s0,-232
    80005228:	4581                	li	a1,0
    8000522a:	854a                	mv	a0,s2
    8000522c:	d34fe0ef          	jal	80003760 <readi>
    80005230:	47c1                	li	a5,16
    80005232:	00f51b63          	bne	a0,a5,80005248 <sys_unlink+0x12e>
    if (de.inum != 0)
    80005236:	f1845783          	lhu	a5,-232(s0)
    8000523a:	ebb1                	bnez	a5,8000528e <sys_unlink+0x174>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000523c:	29c1                	addiw	s3,s3,16
    8000523e:	04c92783          	lw	a5,76(s2)
    80005242:	fcf9efe3          	bltu	s3,a5,80005220 <sys_unlink+0x106>
    80005246:	bfb9                	j	800051a4 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005248:	00002517          	auipc	a0,0x2
    8000524c:	3c050513          	addi	a0,a0,960 # 80007608 <etext+0x608>
    80005250:	de4fb0ef          	jal	80000834 <panic>
    panic("unlink: writei");
    80005254:	00002517          	auipc	a0,0x2
    80005258:	3cc50513          	addi	a0,a0,972 # 80007620 <etext+0x620>
    8000525c:	dd8fb0ef          	jal	80000834 <panic>
    dp->nlink--;
    80005260:	04a4d783          	lhu	a5,74(s1)
    80005264:	37fd                	addiw	a5,a5,-1
    80005266:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000526a:	8526                	mv	a0,s1
    8000526c:	866fe0ef          	jal	800032d2 <iupdate>
    80005270:	b78d                	j	800051d2 <sys_unlink+0xb8>
    80005272:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005274:	8526                	mv	a0,s1
    80005276:	b64fe0ef          	jal	800035da <iunlockput>
  end_op();
    8000527a:	c03fe0ef          	jal	80003e7c <end_op>
  return -1;
    8000527e:	557d                	li	a0,-1
    80005280:	64ee                	ld	s1,216(sp)
}
    80005282:	70ae                	ld	ra,232(sp)
    80005284:	740e                	ld	s0,224(sp)
    80005286:	616d                	addi	sp,sp,240
    80005288:	8082                	ret
    return -1;
    8000528a:	557d                	li	a0,-1
    8000528c:	bfdd                	j	80005282 <sys_unlink+0x168>
    iunlockput(ip);
    8000528e:	854a                	mv	a0,s2
    80005290:	b4afe0ef          	jal	800035da <iunlockput>
    goto bad;
    80005294:	694e                	ld	s2,208(sp)
    80005296:	69ae                	ld	s3,200(sp)
    80005298:	bff1                	j	80005274 <sys_unlink+0x15a>

000000008000529a <sys_open>:

uint64
sys_open(void)
{
    8000529a:	7131                	addi	sp,sp,-192
    8000529c:	fd06                	sd	ra,184(sp)
    8000529e:	f922                	sd	s0,176(sp)
    800052a0:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800052a2:	f4c40593          	addi	a1,s0,-180
    800052a6:	4505                	li	a0,1
    800052a8:	ea6fd0ef          	jal	8000294e <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800052ac:	08000613          	li	a2,128
    800052b0:	f5040593          	addi	a1,s0,-176
    800052b4:	4501                	li	a0,0
    800052b6:	ed0fd0ef          	jal	80002986 <argstr>
    800052ba:	87aa                	mv	a5,a0
    return -1;
    800052bc:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800052be:	0a07c363          	bltz	a5,80005364 <sys_open+0xca>
    800052c2:	f526                	sd	s1,168(sp)

  begin_op();
    800052c4:	b2dfe0ef          	jal	80003df0 <begin_op>

  if (omode & O_CREATE) {
    800052c8:	f4c42783          	lw	a5,-180(s0)
    800052cc:	2007f793          	andi	a5,a5,512
    800052d0:	c3dd                	beqz	a5,80005376 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800052d2:	4681                	li	a3,0
    800052d4:	4601                	li	a2,0
    800052d6:	4589                	li	a1,2
    800052d8:	f5040513          	addi	a0,s0,-176
    800052dc:	a5dff0ef          	jal	80004d38 <create>
    800052e0:	84aa                	mv	s1,a0
    if (ip == 0) {
    800052e2:	c549                	beqz	a0,8000536c <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    800052e4:	04449703          	lh	a4,68(s1)
    800052e8:	478d                	li	a5,3
    800052ea:	00f71763          	bne	a4,a5,800052f8 <sys_open+0x5e>
    800052ee:	0464d703          	lhu	a4,70(s1)
    800052f2:	47a5                	li	a5,9
    800052f4:	0ae7ee63          	bltu	a5,a4,800053b0 <sys_open+0x116>
    800052f8:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    800052fa:	f0dfe0ef          	jal	80004206 <filealloc>
    800052fe:	892a                	mv	s2,a0
    80005300:	c561                	beqz	a0,800053c8 <sys_open+0x12e>
    80005302:	ed4e                	sd	s3,152(sp)
    80005304:	9f5ff0ef          	jal	80004cf8 <fdalloc>
    80005308:	89aa                	mv	s3,a0
    8000530a:	0a054b63          	bltz	a0,800053c0 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    8000530e:	04449703          	lh	a4,68(s1)
    80005312:	478d                	li	a5,3
    80005314:	0cf70363          	beq	a4,a5,800053da <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005318:	4789                	li	a5,2
    8000531a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000531e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005322:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005326:	f4c42783          	lw	a5,-180(s0)
    8000532a:	0017f713          	andi	a4,a5,1
    8000532e:	00174713          	xori	a4,a4,1
    80005332:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005336:	0037f713          	andi	a4,a5,3
    8000533a:	00e03733          	snez	a4,a4
    8000533e:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005342:	4007f793          	andi	a5,a5,1024
    80005346:	c791                	beqz	a5,80005352 <sys_open+0xb8>
    80005348:	04449703          	lh	a4,68(s1)
    8000534c:	4789                	li	a5,2
    8000534e:	08f70d63          	beq	a4,a5,800053e8 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005352:	8526                	mv	a0,s1
    80005354:	8e0fe0ef          	jal	80003434 <iunlock>
  end_op();
    80005358:	b25fe0ef          	jal	80003e7c <end_op>

  return fd;
    8000535c:	854e                	mv	a0,s3
    8000535e:	74aa                	ld	s1,168(sp)
    80005360:	790a                	ld	s2,160(sp)
    80005362:	69ea                	ld	s3,152(sp)
}
    80005364:	70ea                	ld	ra,184(sp)
    80005366:	744a                	ld	s0,176(sp)
    80005368:	6129                	addi	sp,sp,192
    8000536a:	8082                	ret
      end_op();
    8000536c:	b11fe0ef          	jal	80003e7c <end_op>
      return -1;
    80005370:	557d                	li	a0,-1
    80005372:	74aa                	ld	s1,168(sp)
    80005374:	bfc5                	j	80005364 <sys_open+0xca>
    if ((ip = namei(path)) == 0) {
    80005376:	f5040513          	addi	a0,s0,-176
    8000537a:	899fe0ef          	jal	80003c12 <namei>
    8000537e:	84aa                	mv	s1,a0
    80005380:	c11d                	beqz	a0,800053a6 <sys_open+0x10c>
    ilock(ip);
    80005382:	804fe0ef          	jal	80003386 <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    80005386:	04449703          	lh	a4,68(s1)
    8000538a:	4785                	li	a5,1
    8000538c:	f4f71ce3          	bne	a4,a5,800052e4 <sys_open+0x4a>
    80005390:	f4c42783          	lw	a5,-180(s0)
    80005394:	d3b5                	beqz	a5,800052f8 <sys_open+0x5e>
      iunlockput(ip);
    80005396:	8526                	mv	a0,s1
    80005398:	a42fe0ef          	jal	800035da <iunlockput>
      end_op();
    8000539c:	ae1fe0ef          	jal	80003e7c <end_op>
      return -1;
    800053a0:	557d                	li	a0,-1
    800053a2:	74aa                	ld	s1,168(sp)
    800053a4:	b7c1                	j	80005364 <sys_open+0xca>
      end_op();
    800053a6:	ad7fe0ef          	jal	80003e7c <end_op>
      return -1;
    800053aa:	557d                	li	a0,-1
    800053ac:	74aa                	ld	s1,168(sp)
    800053ae:	bf5d                	j	80005364 <sys_open+0xca>
    iunlockput(ip);
    800053b0:	8526                	mv	a0,s1
    800053b2:	a28fe0ef          	jal	800035da <iunlockput>
    end_op();
    800053b6:	ac7fe0ef          	jal	80003e7c <end_op>
    return -1;
    800053ba:	557d                	li	a0,-1
    800053bc:	74aa                	ld	s1,168(sp)
    800053be:	b75d                	j	80005364 <sys_open+0xca>
      fileclose(f);
    800053c0:	854a                	mv	a0,s2
    800053c2:	ee9fe0ef          	jal	800042aa <fileclose>
    800053c6:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800053c8:	8526                	mv	a0,s1
    800053ca:	a10fe0ef          	jal	800035da <iunlockput>
    end_op();
    800053ce:	aaffe0ef          	jal	80003e7c <end_op>
    return -1;
    800053d2:	557d                	li	a0,-1
    800053d4:	74aa                	ld	s1,168(sp)
    800053d6:	790a                	ld	s2,160(sp)
    800053d8:	b771                	j	80005364 <sys_open+0xca>
    f->type = FD_DEVICE;
    800053da:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800053de:	04649783          	lh	a5,70(s1)
    800053e2:	02f91223          	sh	a5,36(s2)
    800053e6:	bf35                	j	80005322 <sys_open+0x88>
    itrunc(ip);
    800053e8:	8526                	mv	a0,s1
    800053ea:	88afe0ef          	jal	80003474 <itrunc>
    800053ee:	b795                	j	80005352 <sys_open+0xb8>

00000000800053f0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800053f0:	7175                	addi	sp,sp,-144
    800053f2:	e506                	sd	ra,136(sp)
    800053f4:	e122                	sd	s0,128(sp)
    800053f6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053f8:	9f9fe0ef          	jal	80003df0 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    800053fc:	08000613          	li	a2,128
    80005400:	f7040593          	addi	a1,s0,-144
    80005404:	4501                	li	a0,0
    80005406:	d80fd0ef          	jal	80002986 <argstr>
    8000540a:	02054363          	bltz	a0,80005430 <sys_mkdir+0x40>
    8000540e:	4681                	li	a3,0
    80005410:	4601                	li	a2,0
    80005412:	4585                	li	a1,1
    80005414:	f7040513          	addi	a0,s0,-144
    80005418:	921ff0ef          	jal	80004d38 <create>
    8000541c:	c911                	beqz	a0,80005430 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000541e:	9bcfe0ef          	jal	800035da <iunlockput>
  end_op();
    80005422:	a5bfe0ef          	jal	80003e7c <end_op>
  return 0;
    80005426:	4501                	li	a0,0
}
    80005428:	60aa                	ld	ra,136(sp)
    8000542a:	640a                	ld	s0,128(sp)
    8000542c:	6149                	addi	sp,sp,144
    8000542e:	8082                	ret
    end_op();
    80005430:	a4dfe0ef          	jal	80003e7c <end_op>
    return -1;
    80005434:	557d                	li	a0,-1
    80005436:	bfcd                	j	80005428 <sys_mkdir+0x38>

0000000080005438 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005438:	7135                	addi	sp,sp,-160
    8000543a:	ed06                	sd	ra,152(sp)
    8000543c:	e922                	sd	s0,144(sp)
    8000543e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005440:	9b1fe0ef          	jal	80003df0 <begin_op>
  argint(1, &major);
    80005444:	f6c40593          	addi	a1,s0,-148
    80005448:	4505                	li	a0,1
    8000544a:	d04fd0ef          	jal	8000294e <argint>
  argint(2, &minor);
    8000544e:	f6840593          	addi	a1,s0,-152
    80005452:	4509                	li	a0,2
    80005454:	cfafd0ef          	jal	8000294e <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    80005458:	08000613          	li	a2,128
    8000545c:	f7040593          	addi	a1,s0,-144
    80005460:	4501                	li	a0,0
    80005462:	d24fd0ef          	jal	80002986 <argstr>
    80005466:	02054563          	bltz	a0,80005490 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    8000546a:	f6841683          	lh	a3,-152(s0)
    8000546e:	f6c41603          	lh	a2,-148(s0)
    80005472:	458d                	li	a1,3
    80005474:	f7040513          	addi	a0,s0,-144
    80005478:	8c1ff0ef          	jal	80004d38 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000547c:	c911                	beqz	a0,80005490 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000547e:	95cfe0ef          	jal	800035da <iunlockput>
  end_op();
    80005482:	9fbfe0ef          	jal	80003e7c <end_op>
  return 0;
    80005486:	4501                	li	a0,0
}
    80005488:	60ea                	ld	ra,152(sp)
    8000548a:	644a                	ld	s0,144(sp)
    8000548c:	610d                	addi	sp,sp,160
    8000548e:	8082                	ret
    end_op();
    80005490:	9edfe0ef          	jal	80003e7c <end_op>
    return -1;
    80005494:	557d                	li	a0,-1
    80005496:	bfcd                	j	80005488 <sys_mknod+0x50>

0000000080005498 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005498:	7135                	addi	sp,sp,-160
    8000549a:	ed06                	sd	ra,152(sp)
    8000549c:	e922                	sd	s0,144(sp)
    8000549e:	e14a                	sd	s2,128(sp)
    800054a0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800054a2:	c96fc0ef          	jal	80001938 <myproc>
    800054a6:	892a                	mv	s2,a0

  begin_op();
    800054a8:	949fe0ef          	jal	80003df0 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800054ac:	08000613          	li	a2,128
    800054b0:	f6040593          	addi	a1,s0,-160
    800054b4:	4501                	li	a0,0
    800054b6:	cd0fd0ef          	jal	80002986 <argstr>
    800054ba:	04054363          	bltz	a0,80005500 <sys_chdir+0x68>
    800054be:	e526                	sd	s1,136(sp)
    800054c0:	f6040513          	addi	a0,s0,-160
    800054c4:	f4efe0ef          	jal	80003c12 <namei>
    800054c8:	84aa                	mv	s1,a0
    800054ca:	c915                	beqz	a0,800054fe <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800054cc:	ebbfd0ef          	jal	80003386 <ilock>
  if (ip->type != T_DIR) {
    800054d0:	04449703          	lh	a4,68(s1)
    800054d4:	4785                	li	a5,1
    800054d6:	02f71963          	bne	a4,a5,80005508 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800054da:	8526                	mv	a0,s1
    800054dc:	f59fd0ef          	jal	80003434 <iunlock>
  iput(p->cwd);
    800054e0:	15893503          	ld	a0,344(s2)
    800054e4:	824fe0ef          	jal	80003508 <iput>
  end_op();
    800054e8:	995fe0ef          	jal	80003e7c <end_op>
  p->cwd = ip;
    800054ec:	14993c23          	sd	s1,344(s2)
  return 0;
    800054f0:	4501                	li	a0,0
    800054f2:	64aa                	ld	s1,136(sp)
}
    800054f4:	60ea                	ld	ra,152(sp)
    800054f6:	644a                	ld	s0,144(sp)
    800054f8:	690a                	ld	s2,128(sp)
    800054fa:	610d                	addi	sp,sp,160
    800054fc:	8082                	ret
    800054fe:	64aa                	ld	s1,136(sp)
    end_op();
    80005500:	97dfe0ef          	jal	80003e7c <end_op>
    return -1;
    80005504:	557d                	li	a0,-1
    80005506:	b7fd                	j	800054f4 <sys_chdir+0x5c>
    iunlockput(ip);
    80005508:	8526                	mv	a0,s1
    8000550a:	8d0fe0ef          	jal	800035da <iunlockput>
    end_op();
    8000550e:	96ffe0ef          	jal	80003e7c <end_op>
    return -1;
    80005512:	557d                	li	a0,-1
    80005514:	64aa                	ld	s1,136(sp)
    80005516:	bff9                	j	800054f4 <sys_chdir+0x5c>

0000000080005518 <sys_exec>:

uint64
sys_exec(void)
{
    80005518:	7105                	addi	sp,sp,-480
    8000551a:	ef86                	sd	ra,472(sp)
    8000551c:	eba2                	sd	s0,464(sp)
    8000551e:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005520:	e2840593          	addi	a1,s0,-472
    80005524:	4505                	li	a0,1
    80005526:	c44fd0ef          	jal	8000296a <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000552a:	08000613          	li	a2,128
    8000552e:	f3040593          	addi	a1,s0,-208
    80005532:	4501                	li	a0,0
    80005534:	c52fd0ef          	jal	80002986 <argstr>
    80005538:	87aa                	mv	a5,a0
    return -1;
    8000553a:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    8000553c:	0e07c063          	bltz	a5,8000561c <sys_exec+0x104>
    80005540:	e7a6                	sd	s1,456(sp)
    80005542:	e3ca                	sd	s2,448(sp)
    80005544:	ff4e                	sd	s3,440(sp)
    80005546:	fb52                	sd	s4,432(sp)
    80005548:	f756                	sd	s5,424(sp)
    8000554a:	f35a                	sd	s6,416(sp)
    8000554c:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000554e:	e3040a13          	addi	s4,s0,-464
    80005552:	10000613          	li	a2,256
    80005556:	4581                	li	a1,0
    80005558:	8552                	mv	a0,s4
    8000555a:	f7efb0ef          	jal	80000cd8 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000555e:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005560:	89d2                	mv	s3,s4
    80005562:	4901                	li	s2,0
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    80005564:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if (argv[i] == 0)
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005568:	6b05                	lui	s6,0x1
    if (i >= NELEM(argv)) {
    8000556a:	02000b93          	li	s7,32
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    8000556e:	00391513          	slli	a0,s2,0x3
    80005572:	85d6                	mv	a1,s5
    80005574:	e2843783          	ld	a5,-472(s0)
    80005578:	953e                	add	a0,a0,a5
    8000557a:	b48fd0ef          	jal	800028c2 <fetchaddr>
    8000557e:	02054663          	bltz	a0,800055aa <sys_exec+0x92>
    if (uarg == 0) {
    80005582:	e2043783          	ld	a5,-480(s0)
    80005586:	c7a1                	beqz	a5,800055ce <sys_exec+0xb6>
    argv[i] = kalloc();
    80005588:	d86fb0ef          	jal	80000b0e <kalloc>
    8000558c:	85aa                	mv	a1,a0
    8000558e:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    80005592:	cd01                	beqz	a0,800055aa <sys_exec+0x92>
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005594:	865a                	mv	a2,s6
    80005596:	e2043503          	ld	a0,-480(s0)
    8000559a:	b72fd0ef          	jal	8000290c <fetchstr>
    8000559e:	00054663          	bltz	a0,800055aa <sys_exec+0x92>
    if (i >= NELEM(argv)) {
    800055a2:	0905                	addi	s2,s2,1
    800055a4:	09a1                	addi	s3,s3,8
    800055a6:	fd7914e3          	bne	s2,s7,8000556e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055aa:	100a0a13          	addi	s4,s4,256
    800055ae:	6088                	ld	a0,0(s1)
    800055b0:	cd31                	beqz	a0,8000560c <sys_exec+0xf4>
    kfree(argv[i]);
    800055b2:	c74fb0ef          	jal	80000a26 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055b6:	04a1                	addi	s1,s1,8
    800055b8:	ff449be3          	bne	s1,s4,800055ae <sys_exec+0x96>
  return -1;
    800055bc:	557d                	li	a0,-1
    800055be:	64be                	ld	s1,456(sp)
    800055c0:	691e                	ld	s2,448(sp)
    800055c2:	79fa                	ld	s3,440(sp)
    800055c4:	7a5a                	ld	s4,432(sp)
    800055c6:	7aba                	ld	s5,424(sp)
    800055c8:	7b1a                	ld	s6,416(sp)
    800055ca:	6bfa                	ld	s7,408(sp)
    800055cc:	a881                	j	8000561c <sys_exec+0x104>
      argv[i] = 0;
    800055ce:	0009079b          	sext.w	a5,s2
    800055d2:	e3040593          	addi	a1,s0,-464
    800055d6:	078e                	slli	a5,a5,0x3
    800055d8:	97ae                	add	a5,a5,a1
    800055da:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800055de:	f3040513          	addi	a0,s0,-208
    800055e2:	b62ff0ef          	jal	80004944 <kexec>
    800055e6:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055e8:	100a0a13          	addi	s4,s4,256
    800055ec:	6088                	ld	a0,0(s1)
    800055ee:	c511                	beqz	a0,800055fa <sys_exec+0xe2>
    kfree(argv[i]);
    800055f0:	c36fb0ef          	jal	80000a26 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055f4:	04a1                	addi	s1,s1,8
    800055f6:	ff449be3          	bne	s1,s4,800055ec <sys_exec+0xd4>
  return ret;
    800055fa:	854a                	mv	a0,s2
    800055fc:	64be                	ld	s1,456(sp)
    800055fe:	691e                	ld	s2,448(sp)
    80005600:	79fa                	ld	s3,440(sp)
    80005602:	7a5a                	ld	s4,432(sp)
    80005604:	7aba                	ld	s5,424(sp)
    80005606:	7b1a                	ld	s6,416(sp)
    80005608:	6bfa                	ld	s7,408(sp)
    8000560a:	a809                	j	8000561c <sys_exec+0x104>
  return -1;
    8000560c:	557d                	li	a0,-1
    8000560e:	64be                	ld	s1,456(sp)
    80005610:	691e                	ld	s2,448(sp)
    80005612:	79fa                	ld	s3,440(sp)
    80005614:	7a5a                	ld	s4,432(sp)
    80005616:	7aba                	ld	s5,424(sp)
    80005618:	7b1a                	ld	s6,416(sp)
    8000561a:	6bfa                	ld	s7,408(sp)
}
    8000561c:	60fe                	ld	ra,472(sp)
    8000561e:	645e                	ld	s0,464(sp)
    80005620:	613d                	addi	sp,sp,480
    80005622:	8082                	ret

0000000080005624 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005624:	7139                	addi	sp,sp,-64
    80005626:	fc06                	sd	ra,56(sp)
    80005628:	f822                	sd	s0,48(sp)
    8000562a:	f426                	sd	s1,40(sp)
    8000562c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000562e:	b0afc0ef          	jal	80001938 <myproc>
    80005632:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005634:	fd840593          	addi	a1,s0,-40
    80005638:	4501                	li	a0,0
    8000563a:	b30fd0ef          	jal	8000296a <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000563e:	fc840593          	addi	a1,s0,-56
    80005642:	fd040513          	addi	a0,s0,-48
    80005646:	f99fe0ef          	jal	800045de <pipealloc>
    return -1;
    8000564a:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    8000564c:	0a054963          	bltz	a0,800056fe <sys_pipe+0xda>
  fd0 = -1;
    80005650:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005654:	fd043503          	ld	a0,-48(s0)
    80005658:	ea0ff0ef          	jal	80004cf8 <fdalloc>
    8000565c:	fca42223          	sw	a0,-60(s0)
    80005660:	08054663          	bltz	a0,800056ec <sys_pipe+0xc8>
    80005664:	fc843503          	ld	a0,-56(s0)
    80005668:	e90ff0ef          	jal	80004cf8 <fdalloc>
    8000566c:	fca42023          	sw	a0,-64(s0)
    80005670:	06054463          	bltz	a0,800056d8 <sys_pipe+0xb4>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    80005674:	4711                	li	a4,4
    80005676:	fc440693          	addi	a3,s0,-60
    8000567a:	fd843603          	ld	a2,-40(s0)
    8000567e:	68ac                	ld	a1,80(s1)
    80005680:	6ca8                	ld	a0,88(s1)
    80005682:	ef1fb0ef          	jal	80001572 <copyout>
    80005686:	00054f63          	bltz	a0,800056a4 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    8000568a:	4711                	li	a4,4
    8000568c:	fc040693          	addi	a3,s0,-64
    80005690:	fd843603          	ld	a2,-40(s0)
    80005694:	963a                	add	a2,a2,a4
    80005696:	68ac                	ld	a1,80(s1)
    80005698:	6ca8                	ld	a0,88(s1)
    8000569a:	ed9fb0ef          	jal	80001572 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000569e:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800056a0:	04055f63          	bgez	a0,800056fe <sys_pipe+0xda>
    p->ofile[fd0] = 0;
    800056a4:	fc442783          	lw	a5,-60(s0)
    800056a8:	078e                	slli	a5,a5,0x3
    800056aa:	0d078793          	addi	a5,a5,208
    800056ae:	97a6                	add	a5,a5,s1
    800056b0:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800056b4:	fc042783          	lw	a5,-64(s0)
    800056b8:	078e                	slli	a5,a5,0x3
    800056ba:	0d078793          	addi	a5,a5,208
    800056be:	94be                	add	s1,s1,a5
    800056c0:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    800056c4:	fd043503          	ld	a0,-48(s0)
    800056c8:	be3fe0ef          	jal	800042aa <fileclose>
    fileclose(wf);
    800056cc:	fc843503          	ld	a0,-56(s0)
    800056d0:	bdbfe0ef          	jal	800042aa <fileclose>
    return -1;
    800056d4:	57fd                	li	a5,-1
    800056d6:	a025                	j	800056fe <sys_pipe+0xda>
    if (fd0 >= 0)
    800056d8:	fc442783          	lw	a5,-60(s0)
    800056dc:	0007c863          	bltz	a5,800056ec <sys_pipe+0xc8>
      p->ofile[fd0] = 0;
    800056e0:	078e                	slli	a5,a5,0x3
    800056e2:	0d078793          	addi	a5,a5,208
    800056e6:	97a6                	add	a5,a5,s1
    800056e8:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    800056ec:	fd043503          	ld	a0,-48(s0)
    800056f0:	bbbfe0ef          	jal	800042aa <fileclose>
    fileclose(wf);
    800056f4:	fc843503          	ld	a0,-56(s0)
    800056f8:	bb3fe0ef          	jal	800042aa <fileclose>
    return -1;
    800056fc:	57fd                	li	a5,-1
}
    800056fe:	853e                	mv	a0,a5
    80005700:	70e2                	ld	ra,56(sp)
    80005702:	7442                	ld	s0,48(sp)
    80005704:	74a2                	ld	s1,40(sp)
    80005706:	6121                	addi	sp,sp,64
    80005708:	8082                	ret
    8000570a:	0000                	unimp
    8000570c:	0000                	unimp
	...

0000000080005710 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005710:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005712:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005714:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005716:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005718:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000571a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000571c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000571e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005720:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005722:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005724:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005726:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005728:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000572a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000572c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000572e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005730:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005732:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005734:	89cfd0ef          	jal	800027d0 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005738:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000573a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000573c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000573e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005740:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005742:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005744:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005746:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005748:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000574a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000574c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000574e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005750:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005752:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005754:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005756:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005758:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000575a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000575c:	10200073          	sret
    80005760:	0001                	nop
    80005762:	00000013          	nop
    80005766:	00000013          	nop
    8000576a:	00000013          	nop

000000008000576e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000576e:	1141                	addi	sp,sp,-16
    80005770:	e406                	sd	ra,8(sp)
    80005772:	e022                	sd	s0,0(sp)
    80005774:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005776:	0c000737          	lui	a4,0xc000
    8000577a:	4785                	li	a5,1
    8000577c:	d71c                	sw	a5,40(a4)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000577e:	c35c                	sw	a5,4(a4)
}
    80005780:	60a2                	ld	ra,8(sp)
    80005782:	6402                	ld	s0,0(sp)
    80005784:	0141                	addi	sp,sp,16
    80005786:	8082                	ret

0000000080005788 <plicinithart>:

void
plicinithart(void)
{
    80005788:	1141                	addi	sp,sp,-16
    8000578a:	e406                	sd	ra,8(sp)
    8000578c:	e022                	sd	s0,0(sp)
    8000578e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005790:	974fc0ef          	jal	80001904 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005794:	0085171b          	slliw	a4,a0,0x8
    80005798:	0c0027b7          	lui	a5,0xc002
    8000579c:	97ba                	add	a5,a5,a4
    8000579e:	40200713          	li	a4,1026
    800057a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    800057a6:	00d5151b          	slliw	a0,a0,0xd
    800057aa:	0c2017b7          	lui	a5,0xc201
    800057ae:	97aa                	add	a5,a5,a0
    800057b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800057b4:	60a2                	ld	ra,8(sp)
    800057b6:	6402                	ld	s0,0(sp)
    800057b8:	0141                	addi	sp,sp,16
    800057ba:	8082                	ret

00000000800057bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800057bc:	1141                	addi	sp,sp,-16
    800057be:	e406                	sd	ra,8(sp)
    800057c0:	e022                	sd	s0,0(sp)
    800057c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057c4:	940fc0ef          	jal	80001904 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    800057c8:	00d5151b          	slliw	a0,a0,0xd
    800057cc:	0c2017b7          	lui	a5,0xc201
    800057d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800057d2:	43c8                	lw	a0,4(a5)
    800057d4:	60a2                	ld	ra,8(sp)
    800057d6:	6402                	ld	s0,0(sp)
    800057d8:	0141                	addi	sp,sp,16
    800057da:	8082                	ret

00000000800057dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800057dc:	1101                	addi	sp,sp,-32
    800057de:	ec06                	sd	ra,24(sp)
    800057e0:	e822                	sd	s0,16(sp)
    800057e2:	e426                	sd	s1,8(sp)
    800057e4:	1000                	addi	s0,sp,32
    800057e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800057e8:	91cfc0ef          	jal	80001904 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    800057ec:	00d5179b          	slliw	a5,a0,0xd
    800057f0:	0c201737          	lui	a4,0xc201
    800057f4:	97ba                	add	a5,a5,a4
    800057f6:	c3c4                	sw	s1,4(a5)
}
    800057f8:	60e2                	ld	ra,24(sp)
    800057fa:	6442                	ld	s0,16(sp)
    800057fc:	64a2                	ld	s1,8(sp)
    800057fe:	6105                	addi	sp,sp,32
    80005800:	8082                	ret

0000000080005802 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005802:	1141                	addi	sp,sp,-16
    80005804:	e406                	sd	ra,8(sp)
    80005806:	e022                	sd	s0,0(sp)
    80005808:	0800                	addi	s0,sp,16
  if (i >= NUM)
    8000580a:	479d                	li	a5,7
    8000580c:	04a7ca63          	blt	a5,a0,80005860 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005810:	0001e797          	auipc	a5,0x1e
    80005814:	04078793          	addi	a5,a5,64 # 80023850 <disk>
    80005818:	97aa                	add	a5,a5,a0
    8000581a:	0187c783          	lbu	a5,24(a5)
    8000581e:	e7b9                	bnez	a5,8000586c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005820:	00451693          	slli	a3,a0,0x4
    80005824:	0001e797          	auipc	a5,0x1e
    80005828:	02c78793          	addi	a5,a5,44 # 80023850 <disk>
    8000582c:	6398                	ld	a4,0(a5)
    8000582e:	9736                	add	a4,a4,a3
    80005830:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005834:	6398                	ld	a4,0(a5)
    80005836:	9736                	add	a4,a4,a3
    80005838:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000583c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005840:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005844:	97aa                	add	a5,a5,a0
    80005846:	4705                	li	a4,1
    80005848:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000584c:	0001e517          	auipc	a0,0x1e
    80005850:	01c50513          	addi	a0,a0,28 # 80023868 <disk+0x18>
    80005854:	82ffc0ef          	jal	80002082 <wakeup>
}
    80005858:	60a2                	ld	ra,8(sp)
    8000585a:	6402                	ld	s0,0(sp)
    8000585c:	0141                	addi	sp,sp,16
    8000585e:	8082                	ret
    panic("free_desc 1");
    80005860:	00002517          	auipc	a0,0x2
    80005864:	dd050513          	addi	a0,a0,-560 # 80007630 <etext+0x630>
    80005868:	fcdfa0ef          	jal	80000834 <panic>
    panic("free_desc 2");
    8000586c:	00002517          	auipc	a0,0x2
    80005870:	dd450513          	addi	a0,a0,-556 # 80007640 <etext+0x640>
    80005874:	fc1fa0ef          	jal	80000834 <panic>

0000000080005878 <virtio_disk_init>:
{
    80005878:	1101                	addi	sp,sp,-32
    8000587a:	ec06                	sd	ra,24(sp)
    8000587c:	e822                	sd	s0,16(sp)
    8000587e:	e426                	sd	s1,8(sp)
    80005880:	e04a                	sd	s2,0(sp)
    80005882:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005884:	00002597          	auipc	a1,0x2
    80005888:	dcc58593          	addi	a1,a1,-564 # 80007650 <etext+0x650>
    8000588c:	0001e517          	auipc	a0,0x1e
    80005890:	0ec50513          	addi	a0,a0,236 # 80023978 <disk+0x128>
    80005894:	b04fb0ef          	jal	80000b98 <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005898:	100017b7          	lui	a5,0x10001
    8000589c:	4398                	lw	a4,0(a5)
    8000589e:	2701                	sext.w	a4,a4
    800058a0:	747277b7          	lui	a5,0x74727
    800058a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800058a8:	14f71863          	bne	a4,a5,800059f8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058ac:	100017b7          	lui	a5,0x10001
    800058b0:	43dc                	lw	a5,4(a5)
    800058b2:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058b4:	4709                	li	a4,2
    800058b6:	14e79163          	bne	a5,a4,800059f8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058ba:	100017b7          	lui	a5,0x10001
    800058be:	479c                	lw	a5,8(a5)
    800058c0:	2781                	sext.w	a5,a5
    800058c2:	12e79b63          	bne	a5,a4,800059f8 <virtio_disk_init+0x180>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800058c6:	100017b7          	lui	a5,0x10001
    800058ca:	47d8                	lw	a4,12(a5)
    800058cc:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058ce:	554d47b7          	lui	a5,0x554d4
    800058d2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800058d6:	12f71163          	bne	a4,a5,800059f8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058da:	100017b7          	lui	a5,0x10001
    800058de:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058e2:	4705                	li	a4,1
    800058e4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058e6:	470d                	li	a4,3
    800058e8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800058ea:	10001737          	lui	a4,0x10001
    800058ee:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800058f0:	c7ffe6b7          	lui	a3,0xc7ffe
    800058f4:	55f68693          	addi	a3,a3,1375 # ffffffffc7ffe55f <end+0xffffffff47fdabcf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800058f8:	8f75                	and	a4,a4,a3
    800058fa:	100016b7          	lui	a3,0x10001
    800058fe:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005900:	472d                	li	a4,11
    80005902:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005904:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005908:	439c                	lw	a5,0(a5)
    8000590a:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000590e:	8ba1                	andi	a5,a5,8
    80005910:	0e078a63          	beqz	a5,80005a04 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005914:	100017b7          	lui	a5,0x10001
    80005918:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    8000591c:	43fc                	lw	a5,68(a5)
    8000591e:	2781                	sext.w	a5,a5
    80005920:	0e079863          	bnez	a5,80005a10 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005924:	100017b7          	lui	a5,0x10001
    80005928:	5bdc                	lw	a5,52(a5)
    8000592a:	2781                	sext.w	a5,a5
  if (max == 0)
    8000592c:	0e078863          	beqz	a5,80005a1c <virtio_disk_init+0x1a4>
  if (max < NUM)
    80005930:	471d                	li	a4,7
    80005932:	0ef77b63          	bgeu	a4,a5,80005a28 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005936:	9d8fb0ef          	jal	80000b0e <kalloc>
    8000593a:	0001e497          	auipc	s1,0x1e
    8000593e:	f1648493          	addi	s1,s1,-234 # 80023850 <disk>
    80005942:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005944:	9cafb0ef          	jal	80000b0e <kalloc>
    80005948:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000594a:	9c4fb0ef          	jal	80000b0e <kalloc>
    8000594e:	87aa                	mv	a5,a0
    80005950:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005952:	6088                	ld	a0,0(s1)
    80005954:	0e050063          	beqz	a0,80005a34 <virtio_disk_init+0x1bc>
    80005958:	0001e717          	auipc	a4,0x1e
    8000595c:	f0073703          	ld	a4,-256(a4) # 80023858 <disk+0x8>
    80005960:	cb71                	beqz	a4,80005a34 <virtio_disk_init+0x1bc>
    80005962:	cbe9                	beqz	a5,80005a34 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005964:	6605                	lui	a2,0x1
    80005966:	4581                	li	a1,0
    80005968:	b70fb0ef          	jal	80000cd8 <memset>
  memset(disk.avail, 0, PGSIZE);
    8000596c:	0001e497          	auipc	s1,0x1e
    80005970:	ee448493          	addi	s1,s1,-284 # 80023850 <disk>
    80005974:	6605                	lui	a2,0x1
    80005976:	4581                	li	a1,0
    80005978:	6488                	ld	a0,8(s1)
    8000597a:	b5efb0ef          	jal	80000cd8 <memset>
  memset(disk.used, 0, PGSIZE);
    8000597e:	6605                	lui	a2,0x1
    80005980:	4581                	li	a1,0
    80005982:	6888                	ld	a0,16(s1)
    80005984:	b54fb0ef          	jal	80000cd8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005988:	100017b7          	lui	a5,0x10001
    8000598c:	4721                	li	a4,8
    8000598e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005990:	4098                	lw	a4,0(s1)
    80005992:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005996:	40d8                	lw	a4,4(s1)
    80005998:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000599c:	649c                	ld	a5,8(s1)
    8000599e:	0007869b          	sext.w	a3,a5
    800059a2:	10001737          	lui	a4,0x10001
    800059a6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800059aa:	9781                	srai	a5,a5,0x20
    800059ac:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059b0:	689c                	ld	a5,16(s1)
    800059b2:	0007869b          	sext.w	a3,a5
    800059b6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800059ba:	9781                	srai	a5,a5,0x20
    800059bc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800059c0:	4785                	li	a5,1
    800059c2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800059c4:	00f48c23          	sb	a5,24(s1)
    800059c8:	00f48ca3          	sb	a5,25(s1)
    800059cc:	00f48d23          	sb	a5,26(s1)
    800059d0:	00f48da3          	sb	a5,27(s1)
    800059d4:	00f48e23          	sb	a5,28(s1)
    800059d8:	00f48ea3          	sb	a5,29(s1)
    800059dc:	00f48f23          	sb	a5,30(s1)
    800059e0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800059e4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800059e8:	07272823          	sw	s2,112(a4)
}
    800059ec:	60e2                	ld	ra,24(sp)
    800059ee:	6442                	ld	s0,16(sp)
    800059f0:	64a2                	ld	s1,8(sp)
    800059f2:	6902                	ld	s2,0(sp)
    800059f4:	6105                	addi	sp,sp,32
    800059f6:	8082                	ret
    panic("could not find virtio disk");
    800059f8:	00002517          	auipc	a0,0x2
    800059fc:	c6850513          	addi	a0,a0,-920 # 80007660 <etext+0x660>
    80005a00:	e35fa0ef          	jal	80000834 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a04:	00002517          	auipc	a0,0x2
    80005a08:	c7c50513          	addi	a0,a0,-900 # 80007680 <etext+0x680>
    80005a0c:	e29fa0ef          	jal	80000834 <panic>
    panic("virtio disk should not be ready");
    80005a10:	00002517          	auipc	a0,0x2
    80005a14:	c9050513          	addi	a0,a0,-880 # 800076a0 <etext+0x6a0>
    80005a18:	e1dfa0ef          	jal	80000834 <panic>
    panic("virtio disk has no queue 0");
    80005a1c:	00002517          	auipc	a0,0x2
    80005a20:	ca450513          	addi	a0,a0,-860 # 800076c0 <etext+0x6c0>
    80005a24:	e11fa0ef          	jal	80000834 <panic>
    panic("virtio disk max queue too short");
    80005a28:	00002517          	auipc	a0,0x2
    80005a2c:	cb850513          	addi	a0,a0,-840 # 800076e0 <etext+0x6e0>
    80005a30:	e05fa0ef          	jal	80000834 <panic>
    panic("virtio disk kalloc");
    80005a34:	00002517          	auipc	a0,0x2
    80005a38:	ccc50513          	addi	a0,a0,-820 # 80007700 <etext+0x700>
    80005a3c:	df9fa0ef          	jal	80000834 <panic>

0000000080005a40 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a40:	711d                	addi	sp,sp,-96
    80005a42:	ec86                	sd	ra,88(sp)
    80005a44:	e8a2                	sd	s0,80(sp)
    80005a46:	e4a6                	sd	s1,72(sp)
    80005a48:	e0ca                	sd	s2,64(sp)
    80005a4a:	fc4e                	sd	s3,56(sp)
    80005a4c:	f852                	sd	s4,48(sp)
    80005a4e:	f456                	sd	s5,40(sp)
    80005a50:	f05a                	sd	s6,32(sp)
    80005a52:	ec5e                	sd	s7,24(sp)
    80005a54:	e862                	sd	s8,16(sp)
    80005a56:	1080                	addi	s0,sp,96
    80005a58:	89aa                	mv	s3,a0
    80005a5a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a5c:	00c52b83          	lw	s7,12(a0)
    80005a60:	001b9b9b          	slliw	s7,s7,0x1
    80005a64:	1b82                	slli	s7,s7,0x20
    80005a66:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005a6a:	0001e517          	auipc	a0,0x1e
    80005a6e:	f0e50513          	addi	a0,a0,-242 # 80023978 <disk+0x128>
    80005a72:	9a6fb0ef          	jal	80000c18 <acquire>
  for (int i = 0; i < NUM; i++) {
    80005a76:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a78:	0001ea97          	auipc	s5,0x1e
    80005a7c:	dd8a8a93          	addi	s5,s5,-552 # 80023850 <disk>
  for (int i = 0; i < 3; i++) {
    80005a80:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005a82:	5c7d                	li	s8,-1
    80005a84:	a8a5                	j	80005afc <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    80005a86:	00fa8733          	add	a4,s5,a5
    80005a8a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005a8e:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    80005a90:	0207c563          	bltz	a5,80005aba <virtio_disk_rw+0x7a>
  for (int i = 0; i < 3; i++) {
    80005a94:	2905                	addiw	s2,s2,1
    80005a96:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a98:	07490663          	beq	s2,s4,80005b04 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    80005a9c:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    80005a9e:	0001e717          	auipc	a4,0x1e
    80005aa2:	db270713          	addi	a4,a4,-590 # 80023850 <disk>
    80005aa6:	4781                	li	a5,0
    if (disk.free[i]) {
    80005aa8:	01874683          	lbu	a3,24(a4)
    80005aac:	fee9                	bnez	a3,80005a86 <virtio_disk_rw+0x46>
  for (int i = 0; i < NUM; i++) {
    80005aae:	2785                	addiw	a5,a5,1
    80005ab0:	0705                	addi	a4,a4,1
    80005ab2:	fe979be3          	bne	a5,s1,80005aa8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005ab6:	0185a023          	sw	s8,0(a1)
      for (int j = 0; j < i; j++)
    80005aba:	01205d63          	blez	s2,80005ad4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005abe:	fa042503          	lw	a0,-96(s0)
    80005ac2:	d41ff0ef          	jal	80005802 <free_desc>
      for (int j = 0; j < i; j++)
    80005ac6:	4785                	li	a5,1
    80005ac8:	0127d663          	bge	a5,s2,80005ad4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005acc:	fa442503          	lw	a0,-92(s0)
    80005ad0:	d33ff0ef          	jal	80005802 <free_desc>
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    80005ad4:	0001e517          	auipc	a0,0x1e
    80005ad8:	d9450513          	addi	a0,a0,-620 # 80023868 <disk+0x18>
    80005adc:	d3afc0ef          	jal	80002016 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005ae0:	0001e517          	auipc	a0,0x1e
    80005ae4:	e9850513          	addi	a0,a0,-360 # 80023978 <disk+0x128>
    80005ae8:	9b8fb0ef          	jal	80000ca0 <release>
    sleep();
    80005aec:	d66fc0ef          	jal	80002052 <sleep>
    acquire(&disk.vdisk_lock);
    80005af0:	0001e517          	auipc	a0,0x1e
    80005af4:	e8850513          	addi	a0,a0,-376 # 80023978 <disk+0x128>
    80005af8:	920fb0ef          	jal	80000c18 <acquire>
  for (int i = 0; i < 3; i++) {
    80005afc:	fa040613          	addi	a2,s0,-96
    80005b00:	4901                	li	s2,0
    80005b02:	bf69                	j	80005a9c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b04:	fa042503          	lw	a0,-96(s0)
    80005b08:	00451693          	slli	a3,a0,0x4

  if (write)
    80005b0c:	0001e797          	auipc	a5,0x1e
    80005b10:	d4478793          	addi	a5,a5,-700 # 80023850 <disk>
    80005b14:	00451713          	slli	a4,a0,0x4
    80005b18:	0a070713          	addi	a4,a4,160
    80005b1c:	973e                	add	a4,a4,a5
    80005b1e:	01603633          	snez	a2,s6
    80005b22:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b24:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b28:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b2c:	6398                	ld	a4,0(a5)
    80005b2e:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b30:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005b34:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005b36:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b38:	6390                	ld	a2,0(a5)
    80005b3a:	00d60833          	add	a6,a2,a3
    80005b3e:	4741                	li	a4,16
    80005b40:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b44:	4585                	li	a1,1
    80005b46:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005b4a:	fa442703          	lw	a4,-92(s0)
    80005b4e:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64)b->data;
    80005b52:	0712                	slli	a4,a4,0x4
    80005b54:	963a                	add	a2,a2,a4
    80005b56:	05898813          	addi	a6,s3,88
    80005b5a:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b5e:	0007b883          	ld	a7,0(a5)
    80005b62:	9746                	add	a4,a4,a7
    80005b64:	40000613          	li	a2,1024
    80005b68:	c710                	sw	a2,8(a4)
  if (write)
    80005b6a:	001b3613          	seqz	a2,s6
    80005b6e:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b72:	8e4d                	or	a2,a2,a1
    80005b74:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b78:	fa842603          	lw	a2,-88(s0)
    80005b7c:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b80:	00451813          	slli	a6,a0,0x4
    80005b84:	02080813          	addi	a6,a6,32
    80005b88:	983e                	add	a6,a6,a5
    80005b8a:	577d                	li	a4,-1
    80005b8c:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80005b90:	0612                	slli	a2,a2,0x4
    80005b92:	98b2                	add	a7,a7,a2
    80005b94:	03068713          	addi	a4,a3,48
    80005b98:	973e                	add	a4,a4,a5
    80005b9a:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b9e:	6398                	ld	a4,0(a5)
    80005ba0:	9732                	add	a4,a4,a2
    80005ba2:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005ba4:	4689                	li	a3,2
    80005ba6:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005baa:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005bae:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005bb2:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005bb6:	6794                	ld	a3,8(a5)
    80005bb8:	0026d703          	lhu	a4,2(a3)
    80005bbc:	8b1d                	andi	a4,a4,7
    80005bbe:	0706                	slli	a4,a4,0x1
    80005bc0:	96ba                	add	a3,a3,a4
    80005bc2:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005bc6:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005bca:	6798                	ld	a4,8(a5)
    80005bcc:	00275783          	lhu	a5,2(a4)
    80005bd0:	2785                	addiw	a5,a5,1
    80005bd2:	00f71123          	sh	a5,2(a4)
    80005bd6:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005bda:	100017b7          	lui	a5,0x10001
    80005bde:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005be2:	0049a783          	lw	a5,4(s3)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005be6:	0001e497          	auipc	s1,0x1e
    80005bea:	d9248493          	addi	s1,s1,-622 # 80023978 <disk+0x128>
  while (b->disk == 1) {
    80005bee:	892e                	mv	s2,a1
    80005bf0:	02b79163          	bne	a5,a1,80005c12 <virtio_disk_rw+0x1d2>
    sleep_prepare(b);
    80005bf4:	854e                	mv	a0,s3
    80005bf6:	c20fc0ef          	jal	80002016 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005bfa:	8526                	mv	a0,s1
    80005bfc:	8a4fb0ef          	jal	80000ca0 <release>
    sleep();
    80005c00:	c52fc0ef          	jal	80002052 <sleep>
    acquire(&disk.vdisk_lock);
    80005c04:	8526                	mv	a0,s1
    80005c06:	812fb0ef          	jal	80000c18 <acquire>
  while (b->disk == 1) {
    80005c0a:	0049a783          	lw	a5,4(s3)
    80005c0e:	ff2783e3          	beq	a5,s2,80005bf4 <virtio_disk_rw+0x1b4>
  }

  disk.info[idx[0]].b = 0;
    80005c12:	fa042903          	lw	s2,-96(s0)
    80005c16:	00491713          	slli	a4,s2,0x4
    80005c1a:	02070713          	addi	a4,a4,32
    80005c1e:	0001e797          	auipc	a5,0x1e
    80005c22:	c3278793          	addi	a5,a5,-974 # 80023850 <disk>
    80005c26:	97ba                	add	a5,a5,a4
    80005c28:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c2c:	0001e997          	auipc	s3,0x1e
    80005c30:	c2498993          	addi	s3,s3,-988 # 80023850 <disk>
    80005c34:	00491713          	slli	a4,s2,0x4
    80005c38:	0009b783          	ld	a5,0(s3)
    80005c3c:	97ba                	add	a5,a5,a4
    80005c3e:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c42:	854a                	mv	a0,s2
    80005c44:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c48:	bbbff0ef          	jal	80005802 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005c4c:	8885                	andi	s1,s1,1
    80005c4e:	f0fd                	bnez	s1,80005c34 <virtio_disk_rw+0x1f4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c50:	0001e517          	auipc	a0,0x1e
    80005c54:	d2850513          	addi	a0,a0,-728 # 80023978 <disk+0x128>
    80005c58:	848fb0ef          	jal	80000ca0 <release>
}
    80005c5c:	60e6                	ld	ra,88(sp)
    80005c5e:	6446                	ld	s0,80(sp)
    80005c60:	64a6                	ld	s1,72(sp)
    80005c62:	6906                	ld	s2,64(sp)
    80005c64:	79e2                	ld	s3,56(sp)
    80005c66:	7a42                	ld	s4,48(sp)
    80005c68:	7aa2                	ld	s5,40(sp)
    80005c6a:	7b02                	ld	s6,32(sp)
    80005c6c:	6be2                	ld	s7,24(sp)
    80005c6e:	6c42                	ld	s8,16(sp)
    80005c70:	6125                	addi	sp,sp,96
    80005c72:	8082                	ret

0000000080005c74 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c74:	1101                	addi	sp,sp,-32
    80005c76:	ec06                	sd	ra,24(sp)
    80005c78:	e822                	sd	s0,16(sp)
    80005c7a:	e426                	sd	s1,8(sp)
    80005c7c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c7e:	0001e497          	auipc	s1,0x1e
    80005c82:	bd248493          	addi	s1,s1,-1070 # 80023850 <disk>
    80005c86:	0001e517          	auipc	a0,0x1e
    80005c8a:	cf250513          	addi	a0,a0,-782 # 80023978 <disk+0x128>
    80005c8e:	f8bfa0ef          	jal	80000c18 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c92:	100017b7          	lui	a5,0x10001
    80005c96:	53bc                	lw	a5,96(a5)
    80005c98:	8b8d                	andi	a5,a5,3
    80005c9a:	10001737          	lui	a4,0x10001
    80005c9e:	d37c                	sw	a5,100(a4)
    80005ca0:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005ca4:	689c                	ld	a5,16(s1)
    80005ca6:	0204d703          	lhu	a4,32(s1)
    80005caa:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005cae:	04f70863          	beq	a4,a5,80005cfe <virtio_disk_intr+0x8a>
    80005cb2:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005cb6:	6898                	ld	a4,16(s1)
    80005cb8:	0204d783          	lhu	a5,32(s1)
    80005cbc:	8b9d                	andi	a5,a5,7
    80005cbe:	078e                	slli	a5,a5,0x3
    80005cc0:	97ba                	add	a5,a5,a4
    80005cc2:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005cc4:	00479713          	slli	a4,a5,0x4
    80005cc8:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005ccc:	9726                	add	a4,a4,s1
    80005cce:	01074703          	lbu	a4,16(a4)
    80005cd2:	e329                	bnez	a4,80005d14 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005cd4:	0792                	slli	a5,a5,0x4
    80005cd6:	02078793          	addi	a5,a5,32
    80005cda:	97a6                	add	a5,a5,s1
    80005cdc:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005cde:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005ce2:	ba0fc0ef          	jal	80002082 <wakeup>

    disk.used_idx += 1;
    80005ce6:	0204d783          	lhu	a5,32(s1)
    80005cea:	2785                	addiw	a5,a5,1
    80005cec:	17c2                	slli	a5,a5,0x30
    80005cee:	93c1                	srli	a5,a5,0x30
    80005cf0:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005cf4:	6898                	ld	a4,16(s1)
    80005cf6:	00275703          	lhu	a4,2(a4)
    80005cfa:	faf71ce3          	bne	a4,a5,80005cb2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005cfe:	0001e517          	auipc	a0,0x1e
    80005d02:	c7a50513          	addi	a0,a0,-902 # 80023978 <disk+0x128>
    80005d06:	f9bfa0ef          	jal	80000ca0 <release>
}
    80005d0a:	60e2                	ld	ra,24(sp)
    80005d0c:	6442                	ld	s0,16(sp)
    80005d0e:	64a2                	ld	s1,8(sp)
    80005d10:	6105                	addi	sp,sp,32
    80005d12:	8082                	ret
      panic("virtio_disk_intr status");
    80005d14:	00002517          	auipc	a0,0x2
    80005d18:	a0450513          	addi	a0,a0,-1532 # 80007718 <etext+0x718>
    80005d1c:	b19fa0ef          	jal	80000834 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
