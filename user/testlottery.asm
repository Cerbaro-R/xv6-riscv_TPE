
user/_testlottery:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <trabalhar>:

#define TEMPO_TESTE 700

void
trabalhar(int tickets, int fim)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
   c:	892e                	mv	s2,a1
  settickets(tickets);
   e:	428000ef          	jal	436 <settickets>

  // usa um limite de tempo
  while(uptime() < fim){

    // trabaio
    for(volatile uint64 i = 0; i < 1000000; i++)
  12:	000f44b7          	lui	s1,0xf4
  16:	23f48493          	addi	s1,s1,575 # f423f <base+0xf322f>
  while(uptime() < fim){
  1a:	40c000ef          	jal	426 <uptime>
  1e:	03255263          	bge	a0,s2,42 <trabalhar+0x42>
    for(volatile uint64 i = 0; i < 1000000; i++)
  22:	fc043c23          	sd	zero,-40(s0)
  26:	fd843783          	ld	a5,-40(s0)
  2a:	fef4e8e3          	bltu	s1,a5,1a <trabalhar+0x1a>
  2e:	fd843783          	ld	a5,-40(s0)
  32:	0785                	addi	a5,a5,1
  34:	fcf43c23          	sd	a5,-40(s0)
  38:	fd843783          	ld	a5,-40(s0)
  3c:	fef4f9e3          	bgeu	s1,a5,2e <trabalhar+0x2e>
  40:	bfe9                	j	1a <trabalhar+0x1a>
      ;
  }

 //fim do tempo, mostrar o resultado
  printf("PID: %d | Tickets: %d | N. escolhido: %d\n",
  42:	3cc000ef          	jal	40e <getpid>
  46:	84aa                	mv	s1,a0
  48:	406000ef          	jal	44e <gettickets>
  4c:	892a                	mv	s2,a0
  4e:	3f0000ef          	jal	43e <getcontator>
  52:	86aa                	mv	a3,a0
  54:	864a                	mv	a2,s2
  56:	85a6                	mv	a1,s1
  58:	00001517          	auipc	a0,0x1
  5c:	95850513          	addi	a0,a0,-1704 # 9b0 <malloc+0xfc>
  60:	79c000ef          	jal	7fc <printf>
         getpid(),
         gettickets(),
         getcontator());

  exit(0);
  64:	4501                	li	a0,0
  66:	328000ef          	jal	38e <exit>

000000000000006a <main>:
}

int
main(void)
{
  6a:	1101                	addi	sp,sp,-32
  6c:	ec06                	sd	ra,24(sp)
  6e:	e822                	sd	s0,16(sp)
  70:	e426                	sd	s1,8(sp)
  72:	1000                	addi	s0,sp,32
  int pid;
  int fim;

  printf("=== TESTE LOTTERY ===\n");
  74:	00001517          	auipc	a0,0x1
  78:	96c50513          	addi	a0,a0,-1684 # 9e0 <malloc+0x12c>
  7c:	780000ef          	jal	7fc <printf>


  fim = uptime() + TEMPO_TESTE;
  80:	3a6000ef          	jal	426 <uptime>
  84:	2bc5049b          	addiw	s1,a0,700

  // Processo 1
  pid = fork();
  88:	2fe000ef          	jal	386 <fork>

  if(pid == 0)
  8c:	e511                	bnez	a0,98 <main+0x2e>
    trabalhar(100, fim);
  8e:	85a6                	mv	a1,s1
  90:	06400513          	li	a0,100
  94:	f6dff0ef          	jal	0 <trabalhar>

  // Processo 2
  pid = fork();
  98:	2ee000ef          	jal	386 <fork>

  if(pid == 0)
  9c:	e509                	bnez	a0,a6 <main+0x3c>
    trabalhar(10, fim);
  9e:	85a6                	mv	a1,s1
  a0:	4529                	li	a0,10
  a2:	f5fff0ef          	jal	0 <trabalhar>

  // Processo 3
  pid = fork();
  a6:	2e0000ef          	jal	386 <fork>

  if(pid == 0)
  aa:	e509                	bnez	a0,b4 <main+0x4a>
    trabalhar(1, fim);
  ac:	85a6                	mv	a1,s1
  ae:	4505                	li	a0,1
  b0:	f51ff0ef          	jal	0 <trabalhar>

  // Espera os três processos terminarem.
  wait(0);
  b4:	4501                	li	a0,0
  b6:	2e0000ef          	jal	396 <wait>
  wait(0);
  ba:	4501                	li	a0,0
  bc:	2da000ef          	jal	396 <wait>
  wait(0);
  c0:	4501                	li	a0,0
  c2:	2d4000ef          	jal	396 <wait>

  printf("=== FIM DO TESTE ===\n");
  c6:	00001517          	auipc	a0,0x1
  ca:	93250513          	addi	a0,a0,-1742 # 9f8 <malloc+0x144>
  ce:	72e000ef          	jal	7fc <printf>

  exit(0);
  d2:	4501                	li	a0,0
  d4:	2ba000ef          	jal	38e <exit>

00000000000000d8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e406                	sd	ra,8(sp)
  dc:	e022                	sd	s0,0(sp)
  de:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  e0:	f8bff0ef          	jal	6a <main>
  exit(r);
  e4:	2aa000ef          	jal	38e <exit>

00000000000000e8 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e406                	sd	ra,8(sp)
  ec:	e022                	sd	s0,0(sp)
  ee:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  f0:	87aa                	mv	a5,a0
  f2:	0585                	addi	a1,a1,1
  f4:	0785                	addi	a5,a5,1
  f6:	fff5c703          	lbu	a4,-1(a1)
  fa:	fee78fa3          	sb	a4,-1(a5)
  fe:	fb75                	bnez	a4,f2 <strcpy+0xa>
    ;
  return os;
}
 100:	60a2                	ld	ra,8(sp)
 102:	6402                	ld	s0,0(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
 110:	00054783          	lbu	a5,0(a0)
 114:	cb91                	beqz	a5,128 <strcmp+0x20>
 116:	0005c703          	lbu	a4,0(a1)
 11a:	00f71763          	bne	a4,a5,128 <strcmp+0x20>
    p++, q++;
 11e:	0505                	addi	a0,a0,1
 120:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
 122:	00054783          	lbu	a5,0(a0)
 126:	fbe5                	bnez	a5,116 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 128:	0005c503          	lbu	a0,0(a1)
}
 12c:	40a7853b          	subw	a0,a5,a0
 130:	60a2                	ld	ra,8(sp)
 132:	6402                	ld	s0,0(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret

0000000000000138 <strlen>:

uint
strlen(const char *s)
{
 138:	1141                	addi	sp,sp,-16
 13a:	e406                	sd	ra,8(sp)
 13c:	e022                	sd	s0,0(sp)
 13e:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 140:	00054783          	lbu	a5,0(a0)
 144:	cf91                	beqz	a5,160 <strlen+0x28>
 146:	00150793          	addi	a5,a0,1
 14a:	86be                	mv	a3,a5
 14c:	0785                	addi	a5,a5,1
 14e:	fff7c703          	lbu	a4,-1(a5)
 152:	ff65                	bnez	a4,14a <strlen+0x12>
 154:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 158:	60a2                	ld	ra,8(sp)
 15a:	6402                	ld	s0,0(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret
  for (n = 0; s[n]; n++)
 160:	4501                	li	a0,0
 162:	bfdd                	j	158 <strlen+0x20>

0000000000000164 <memset>:

void *
memset(void *dst, int c, uint n)
{
 164:	1141                	addi	sp,sp,-16
 166:	e406                	sd	ra,8(sp)
 168:	e022                	sd	s0,0(sp)
 16a:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 16c:	ca19                	beqz	a2,182 <memset+0x1e>
 16e:	87aa                	mv	a5,a0
 170:	1602                	slli	a2,a2,0x20
 172:	9201                	srli	a2,a2,0x20
 174:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 178:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 17c:	0785                	addi	a5,a5,1
 17e:	fee79de3          	bne	a5,a4,178 <memset+0x14>
  }
  return dst;
}
 182:	60a2                	ld	ra,8(sp)
 184:	6402                	ld	s0,0(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret

000000000000018a <strchr>:

char *
strchr(const char *s, char c)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e406                	sd	ra,8(sp)
 18e:	e022                	sd	s0,0(sp)
 190:	0800                	addi	s0,sp,16
  for (; *s; s++)
 192:	00054783          	lbu	a5,0(a0)
 196:	cf81                	beqz	a5,1ae <strchr+0x24>
    if (*s == c)
 198:	00f58763          	beq	a1,a5,1a6 <strchr+0x1c>
  for (; *s; s++)
 19c:	0505                	addi	a0,a0,1
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	fbfd                	bnez	a5,198 <strchr+0xe>
      return (char *)s;
  return 0;
 1a4:	4501                	li	a0,0
}
 1a6:	60a2                	ld	ra,8(sp)
 1a8:	6402                	ld	s0,0(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret
  return 0;
 1ae:	4501                	li	a0,0
 1b0:	bfdd                	j	1a6 <strchr+0x1c>

00000000000001b2 <gets>:

char *
gets(char *buf, int max)
{
 1b2:	711d                	addi	sp,sp,-96
 1b4:	ec86                	sd	ra,88(sp)
 1b6:	e8a2                	sd	s0,80(sp)
 1b8:	e4a6                	sd	s1,72(sp)
 1ba:	e0ca                	sd	s2,64(sp)
 1bc:	fc4e                	sd	s3,56(sp)
 1be:	f852                	sd	s4,48(sp)
 1c0:	f456                	sd	s5,40(sp)
 1c2:	f05a                	sd	s6,32(sp)
 1c4:	ec5e                	sd	s7,24(sp)
 1c6:	e862                	sd	s8,16(sp)
 1c8:	1080                	addi	s0,sp,96
 1ca:	8baa                	mv	s7,a0
 1cc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 1ce:	892a                	mv	s2,a0
 1d0:	4481                	li	s1,0
    cc = read(0, &c, 1);
 1d2:	faf40b13          	addi	s6,s0,-81
 1d6:	4a85                	li	s5,1
  for (i = 0; i + 1 < max;) {
 1d8:	8c26                	mv	s8,s1
 1da:	0014899b          	addiw	s3,s1,1
 1de:	84ce                	mv	s1,s3
 1e0:	0349d463          	bge	s3,s4,208 <gets+0x56>
    cc = read(0, &c, 1);
 1e4:	8656                	mv	a2,s5
 1e6:	85da                	mv	a1,s6
 1e8:	4501                	li	a0,0
 1ea:	1bc000ef          	jal	3a6 <read>
    if (cc < 1)
 1ee:	00a05d63          	blez	a0,208 <gets+0x56>
      break;
    buf[i++] = c;
 1f2:	faf44783          	lbu	a5,-81(s0)
 1f6:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 1fa:	0905                	addi	s2,s2,1
 1fc:	ff678713          	addi	a4,a5,-10
 200:	c319                	beqz	a4,206 <gets+0x54>
 202:	17cd                	addi	a5,a5,-13
 204:	fbf1                	bnez	a5,1d8 <gets+0x26>
    buf[i++] = c;
 206:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 208:	9c5e                	add	s8,s8,s7
 20a:	000c0023          	sb	zero,0(s8)
  return buf;
}
 20e:	855e                	mv	a0,s7
 210:	60e6                	ld	ra,88(sp)
 212:	6446                	ld	s0,80(sp)
 214:	64a6                	ld	s1,72(sp)
 216:	6906                	ld	s2,64(sp)
 218:	79e2                	ld	s3,56(sp)
 21a:	7a42                	ld	s4,48(sp)
 21c:	7aa2                	ld	s5,40(sp)
 21e:	7b02                	ld	s6,32(sp)
 220:	6be2                	ld	s7,24(sp)
 222:	6c42                	ld	s8,16(sp)
 224:	6125                	addi	sp,sp,96
 226:	8082                	ret

0000000000000228 <stat>:

int
stat(const char *n, struct stat *st)
{
 228:	1101                	addi	sp,sp,-32
 22a:	ec06                	sd	ra,24(sp)
 22c:	e822                	sd	s0,16(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	1000                	addi	s0,sp,32
 232:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 234:	4581                	li	a1,0
 236:	198000ef          	jal	3ce <open>
  if (fd < 0)
 23a:	02054263          	bltz	a0,25e <stat+0x36>
 23e:	e426                	sd	s1,8(sp)
 240:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 242:	85ca                	mv	a1,s2
 244:	1a2000ef          	jal	3e6 <fstat>
 248:	892a                	mv	s2,a0
  close(fd);
 24a:	8526                	mv	a0,s1
 24c:	16a000ef          	jal	3b6 <close>
  return r;
 250:	64a2                	ld	s1,8(sp)
}
 252:	854a                	mv	a0,s2
 254:	60e2                	ld	ra,24(sp)
 256:	6442                	ld	s0,16(sp)
 258:	6902                	ld	s2,0(sp)
 25a:	6105                	addi	sp,sp,32
 25c:	8082                	ret
    return -1;
 25e:	57fd                	li	a5,-1
 260:	893e                	mv	s2,a5
 262:	bfc5                	j	252 <stat+0x2a>

0000000000000264 <atoi>:

int
atoi(const char *s)
{
 264:	1141                	addi	sp,sp,-16
 266:	e406                	sd	ra,8(sp)
 268:	e022                	sd	s0,0(sp)
 26a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 26c:	00054683          	lbu	a3,0(a0)
 270:	fd06879b          	addiw	a5,a3,-48
 274:	0ff7f793          	zext.b	a5,a5
 278:	4625                	li	a2,9
 27a:	02f66963          	bltu	a2,a5,2ac <atoi+0x48>
 27e:	872a                	mv	a4,a0
  n = 0;
 280:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 282:	0705                	addi	a4,a4,1
 284:	0025179b          	slliw	a5,a0,0x2
 288:	9fa9                	addw	a5,a5,a0
 28a:	0017979b          	slliw	a5,a5,0x1
 28e:	9fb5                	addw	a5,a5,a3
 290:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 294:	00074683          	lbu	a3,0(a4)
 298:	fd06879b          	addiw	a5,a3,-48
 29c:	0ff7f793          	zext.b	a5,a5
 2a0:	fef671e3          	bgeu	a2,a5,282 <atoi+0x1e>
  return n;
}
 2a4:	60a2                	ld	ra,8(sp)
 2a6:	6402                	ld	s0,0(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  n = 0;
 2ac:	4501                	li	a0,0
 2ae:	bfdd                	j	2a4 <atoi+0x40>

00000000000002b0 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 2b0:	1141                	addi	sp,sp,-16
 2b2:	e406                	sd	ra,8(sp)
 2b4:	e022                	sd	s0,0(sp)
 2b6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b8:	02b57563          	bgeu	a0,a1,2e2 <memmove+0x32>
    while (n-- > 0)
 2bc:	00c05f63          	blez	a2,2da <memmove+0x2a>
 2c0:	1602                	slli	a2,a2,0x20
 2c2:	9201                	srli	a2,a2,0x20
 2c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ca:	0585                	addi	a1,a1,1
 2cc:	0705                	addi	a4,a4,1
 2ce:	fff5c683          	lbu	a3,-1(a1)
 2d2:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 2d6:	fee79ae3          	bne	a5,a4,2ca <memmove+0x1a>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2da:	60a2                	ld	ra,8(sp)
 2dc:	6402                	ld	s0,0(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret
    while (n-- > 0)
 2e2:	fec05ce3          	blez	a2,2da <memmove+0x2a>
    dst += n;
 2e6:	00c50733          	add	a4,a0,a2
    src += n;
 2ea:	95b2                	add	a1,a1,a2
 2ec:	fff6079b          	addiw	a5,a2,-1
 2f0:	1782                	slli	a5,a5,0x20
 2f2:	9381                	srli	a5,a5,0x20
 2f4:	fff7c793          	not	a5,a5
 2f8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fa:	15fd                	addi	a1,a1,-1
 2fc:	177d                	addi	a4,a4,-1
 2fe:	0005c683          	lbu	a3,0(a1)
 302:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 306:	fef71ae3          	bne	a4,a5,2fa <memmove+0x4a>
 30a:	bfc1                	j	2da <memmove+0x2a>

000000000000030c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e406                	sd	ra,8(sp)
 310:	e022                	sd	s0,0(sp)
 312:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 314:	c61d                	beqz	a2,342 <memcmp+0x36>
 316:	1602                	slli	a2,a2,0x20
 318:	9201                	srli	a2,a2,0x20
 31a:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 31e:	00054783          	lbu	a5,0(a0)
 322:	0005c703          	lbu	a4,0(a1)
 326:	00e79863          	bne	a5,a4,336 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 32a:	0505                	addi	a0,a0,1
    p2++;
 32c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 32e:	fed518e3          	bne	a0,a3,31e <memcmp+0x12>
  }
  return 0;
 332:	4501                	li	a0,0
 334:	a019                	j	33a <memcmp+0x2e>
      return *p1 - *p2;
 336:	40e7853b          	subw	a0,a5,a4
}
 33a:	60a2                	ld	ra,8(sp)
 33c:	6402                	ld	s0,0(sp)
 33e:	0141                	addi	sp,sp,16
 340:	8082                	ret
  return 0;
 342:	4501                	li	a0,0
 344:	bfdd                	j	33a <memcmp+0x2e>

0000000000000346 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 34e:	f63ff0ef          	jal	2b0 <memmove>
}
 352:	60a2                	ld	ra,8(sp)
 354:	6402                	ld	s0,0(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret

000000000000035a <sbrk>:

char *
sbrk(int n)
{
 35a:	1141                	addi	sp,sp,-16
 35c:	e406                	sd	ra,8(sp)
 35e:	e022                	sd	s0,0(sp)
 360:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 362:	4585                	li	a1,1
 364:	0b2000ef          	jal	416 <sys_sbrk>
}
 368:	60a2                	ld	ra,8(sp)
 36a:	6402                	ld	s0,0(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret

0000000000000370 <sbrklazy>:

char *
sbrklazy(int n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 378:	4589                	li	a1,2
 37a:	09c000ef          	jal	416 <sys_sbrk>
}
 37e:	60a2                	ld	ra,8(sp)
 380:	6402                	ld	s0,0(sp)
 382:	0141                	addi	sp,sp,16
 384:	8082                	ret

0000000000000386 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 386:	4885                	li	a7,1
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <exit>:
.global exit
exit:
 li a7, SYS_exit
 38e:	4889                	li	a7,2
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <wait>:
.global wait
wait:
 li a7, SYS_wait
 396:	488d                	li	a7,3
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 39e:	4891                	li	a7,4
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <read>:
.global read
read:
 li a7, SYS_read
 3a6:	4895                	li	a7,5
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <write>:
.global write
write:
 li a7, SYS_write
 3ae:	48c1                	li	a7,16
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <close>:
.global close
close:
 li a7, SYS_close
 3b6:	48d5                	li	a7,21
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <kill>:
.global kill
kill:
 li a7, SYS_kill
 3be:	4899                	li	a7,6
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c6:	489d                	li	a7,7
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <open>:
.global open
open:
 li a7, SYS_open
 3ce:	48bd                	li	a7,15
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d6:	48c5                	li	a7,17
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3de:	48c9                	li	a7,18
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e6:	48a1                	li	a7,8
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <link>:
.global link
link:
 li a7, SYS_link
 3ee:	48cd                	li	a7,19
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f6:	48d1                	li	a7,20
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3fe:	48a5                	li	a7,9
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <dup>:
.global dup
dup:
 li a7, SYS_dup
 406:	48a9                	li	a7,10
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 40e:	48ad                	li	a7,11
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 416:	48b1                	li	a7,12
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <pause>:
.global pause
pause:
 li a7, SYS_pause
 41e:	48b5                	li	a7,13
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 426:	48b9                	li	a7,14
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <sync>:
.global sync
sync:
 li a7, SYS_sync
 42e:	48d9                	li	a7,22
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 436:	48dd                	li	a7,23
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <getcontator>:
.global getcontator
getcontator:
 li a7, SYS_getcontator
 43e:	48e1                	li	a7,24
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <getlastlottery>:
.global getlastlottery
getlastlottery:
 li a7, SYS_getlastlottery
 446:	48e5                	li	a7,25
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <gettickets>:
.global gettickets
gettickets:
 li a7, SYS_gettickets
 44e:	48e9                	li	a7,26
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 456:	1101                	addi	sp,sp,-32
 458:	ec06                	sd	ra,24(sp)
 45a:	e822                	sd	s0,16(sp)
 45c:	1000                	addi	s0,sp,32
 45e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 462:	4605                	li	a2,1
 464:	fef40593          	addi	a1,s0,-17
 468:	f47ff0ef          	jal	3ae <write>
}
 46c:	60e2                	ld	ra,24(sp)
 46e:	6442                	ld	s0,16(sp)
 470:	6105                	addi	sp,sp,32
 472:	8082                	ret

0000000000000474 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 474:	715d                	addi	sp,sp,-80
 476:	e486                	sd	ra,72(sp)
 478:	e0a2                	sd	s0,64(sp)
 47a:	f84a                	sd	s2,48(sp)
 47c:	f44e                	sd	s3,40(sp)
 47e:	0880                	addi	s0,sp,80
 480:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 482:	c6d1                	beqz	a3,50e <printint+0x9a>
 484:	0805d563          	bgez	a1,50e <printint+0x9a>
    neg = 1;
    x = -xx;
 488:	40b005b3          	neg	a1,a1
    neg = 1;
 48c:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 48e:	fb840993          	addi	s3,s0,-72
  neg = 0;
 492:	86ce                	mv	a3,s3
  i = 0;
 494:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
 496:	00000817          	auipc	a6,0x0
 49a:	58280813          	addi	a6,a6,1410 # a18 <digits>
 49e:	88ba                	mv	a7,a4
 4a0:	0017051b          	addiw	a0,a4,1
 4a4:	872a                	mv	a4,a0
 4a6:	02c5f7b3          	remu	a5,a1,a2
 4aa:	97c2                	add	a5,a5,a6
 4ac:	0007c783          	lbu	a5,0(a5)
 4b0:	00f68023          	sb	a5,0(a3)
  } while ((x /= base) != 0);
 4b4:	87ae                	mv	a5,a1
 4b6:	02c5d5b3          	divu	a1,a1,a2
 4ba:	0685                	addi	a3,a3,1
 4bc:	fec7f1e3          	bgeu	a5,a2,49e <printint+0x2a>
  if (neg)
 4c0:	00030c63          	beqz	t1,4d8 <printint+0x64>
    buf[i++] = '-';
 4c4:	fd050793          	addi	a5,a0,-48
 4c8:	00878533          	add	a0,a5,s0
 4cc:	02d00793          	li	a5,45
 4d0:	fef50423          	sb	a5,-24(a0)
 4d4:	0028871b          	addiw	a4,a7,2

  while (--i >= 0)
 4d8:	02e05563          	blez	a4,502 <printint+0x8e>
 4dc:	fc26                	sd	s1,56(sp)
 4de:	377d                	addiw	a4,a4,-1
 4e0:	00e984b3          	add	s1,s3,a4
 4e4:	19fd                	addi	s3,s3,-1
 4e6:	99ba                	add	s3,s3,a4
 4e8:	1702                	slli	a4,a4,0x20
 4ea:	9301                	srli	a4,a4,0x20
 4ec:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4f0:	0004c583          	lbu	a1,0(s1)
 4f4:	854a                	mv	a0,s2
 4f6:	f61ff0ef          	jal	456 <putc>
  while (--i >= 0)
 4fa:	14fd                	addi	s1,s1,-1
 4fc:	ff349ae3          	bne	s1,s3,4f0 <printint+0x7c>
 500:	74e2                	ld	s1,56(sp)
}
 502:	60a6                	ld	ra,72(sp)
 504:	6406                	ld	s0,64(sp)
 506:	7942                	ld	s2,48(sp)
 508:	79a2                	ld	s3,40(sp)
 50a:	6161                	addi	sp,sp,80
 50c:	8082                	ret
  neg = 0;
 50e:	4301                	li	t1,0
 510:	bfbd                	j	48e <printint+0x1a>

0000000000000512 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 512:	711d                	addi	sp,sp,-96
 514:	ec86                	sd	ra,88(sp)
 516:	e8a2                	sd	s0,80(sp)
 518:	e4a6                	sd	s1,72(sp)
 51a:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 51c:	0005c483          	lbu	s1,0(a1)
 520:	22048363          	beqz	s1,746 <vprintf+0x234>
 524:	e0ca                	sd	s2,64(sp)
 526:	fc4e                	sd	s3,56(sp)
 528:	f852                	sd	s4,48(sp)
 52a:	f456                	sd	s5,40(sp)
 52c:	f05a                	sd	s6,32(sp)
 52e:	ec5e                	sd	s7,24(sp)
 530:	e862                	sd	s8,16(sp)
 532:	8b2a                	mv	s6,a0
 534:	8a2e                	mv	s4,a1
 536:	8bb2                	mv	s7,a2
  state = 0;
 538:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 53a:	4901                	li	s2,0
 53c:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 53e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 542:	06400c13          	li	s8,100
 546:	a00d                	j	568 <vprintf+0x56>
        putc(fd, c0);
 548:	85a6                	mv	a1,s1
 54a:	855a                	mv	a0,s6
 54c:	f0bff0ef          	jal	456 <putc>
 550:	a019                	j	556 <vprintf+0x44>
    } else if (state == '%') {
 552:	03598363          	beq	s3,s5,578 <vprintf+0x66>
  for (i = 0; fmt[i]; i++) {
 556:	0019079b          	addiw	a5,s2,1
 55a:	893e                	mv	s2,a5
 55c:	873e                	mv	a4,a5
 55e:	97d2                	add	a5,a5,s4
 560:	0007c483          	lbu	s1,0(a5)
 564:	1c048a63          	beqz	s1,738 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 568:	0004879b          	sext.w	a5,s1
    if (state == 0) {
 56c:	fe0993e3          	bnez	s3,552 <vprintf+0x40>
      if (c0 == '%') {
 570:	fd579ce3          	bne	a5,s5,548 <vprintf+0x36>
        state = '%';
 574:	89be                	mv	s3,a5
 576:	b7c5                	j	556 <vprintf+0x44>
        c1 = fmt[i + 1] & 0xff;
 578:	00ea06b3          	add	a3,s4,a4
 57c:	0016c603          	lbu	a2,1(a3)
      if (c1)
 580:	1c060863          	beqz	a2,750 <vprintf+0x23e>
      if (c0 == 'd') {
 584:	03878763          	beq	a5,s8,5b2 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 588:	f9478693          	addi	a3,a5,-108
 58c:	0016b693          	seqz	a3,a3
 590:	f9c60593          	addi	a1,a2,-100
 594:	e99d                	bnez	a1,5ca <vprintf+0xb8>
 596:	ca95                	beqz	a3,5ca <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 598:	008b8493          	addi	s1,s7,8
 59c:	4685                	li	a3,1
 59e:	4629                	li	a2,10
 5a0:	000bb583          	ld	a1,0(s7)
 5a4:	855a                	mv	a0,s6
 5a6:	ecfff0ef          	jal	474 <printint>
        i += 1;
 5aa:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ac:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b75d                	j	556 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5b2:	008b8493          	addi	s1,s7,8
 5b6:	4685                	li	a3,1
 5b8:	4629                	li	a2,10
 5ba:	000ba583          	lw	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	eb5ff0ef          	jal	474 <printint>
 5c4:	8ba6                	mv	s7,s1
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b779                	j	556 <vprintf+0x44>
        c2 = fmt[i + 2] & 0xff;
 5ca:	9752                	add	a4,a4,s4
 5cc:	00274583          	lbu	a1,2(a4)
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 5d0:	f9460713          	addi	a4,a2,-108
 5d4:	00173713          	seqz	a4,a4
 5d8:	8f75                	and	a4,a4,a3
 5da:	f9c58513          	addi	a0,a1,-100
 5de:	18051363          	bnez	a0,764 <vprintf+0x252>
 5e2:	18070163          	beqz	a4,764 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e6:	008b8493          	addi	s1,s7,8
 5ea:	4685                	li	a3,1
 5ec:	4629                	li	a2,10
 5ee:	000bb583          	ld	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	e81ff0ef          	jal	474 <printint>
        i += 2;
 5f8:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fa:	8ba6                	mv	s7,s1
      state = 0;
 5fc:	4981                	li	s3,0
        i += 2;
 5fe:	bfa1                	j	556 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 600:	008b8493          	addi	s1,s7,8
 604:	4681                	li	a3,0
 606:	4629                	li	a2,10
 608:	000be583          	lwu	a1,0(s7)
 60c:	855a                	mv	a0,s6
 60e:	e67ff0ef          	jal	474 <printint>
 612:	8ba6                	mv	s7,s1
      state = 0;
 614:	4981                	li	s3,0
 616:	b781                	j	556 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 618:	008b8493          	addi	s1,s7,8
 61c:	4681                	li	a3,0
 61e:	4629                	li	a2,10
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	e4fff0ef          	jal	474 <printint>
        i += 1;
 62a:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	8ba6                	mv	s7,s1
      state = 0;
 62e:	4981                	li	s3,0
 630:	b71d                	j	556 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 632:	008b8493          	addi	s1,s7,8
 636:	4681                	li	a3,0
 638:	4629                	li	a2,10
 63a:	000bb583          	ld	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	e35ff0ef          	jal	474 <printint>
        i += 2;
 644:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 646:	8ba6                	mv	s7,s1
      state = 0;
 648:	4981                	li	s3,0
        i += 2;
 64a:	b731                	j	556 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 64c:	008b8493          	addi	s1,s7,8
 650:	4681                	li	a3,0
 652:	4641                	li	a2,16
 654:	000be583          	lwu	a1,0(s7)
 658:	855a                	mv	a0,s6
 65a:	e1bff0ef          	jal	474 <printint>
 65e:	8ba6                	mv	s7,s1
      state = 0;
 660:	4981                	li	s3,0
 662:	bdd5                	j	556 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 664:	008b8493          	addi	s1,s7,8
 668:	4681                	li	a3,0
 66a:	4641                	li	a2,16
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	e03ff0ef          	jal	474 <printint>
        i += 1;
 676:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 678:	8ba6                	mv	s7,s1
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bde9                	j	556 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	008b8493          	addi	s1,s7,8
 682:	4681                	li	a3,0
 684:	4641                	li	a2,16
 686:	000bb583          	ld	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	de9ff0ef          	jal	474 <printint>
        i += 2;
 690:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 692:	8ba6                	mv	s7,s1
      state = 0;
 694:	4981                	li	s3,0
        i += 2;
 696:	b5c1                	j	556 <vprintf+0x44>
 698:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 69a:	008b8793          	addi	a5,s7,8
 69e:	8cbe                	mv	s9,a5
 6a0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6a4:	03000593          	li	a1,48
 6a8:	855a                	mv	a0,s6
 6aa:	dadff0ef          	jal	456 <putc>
  putc(fd, 'x');
 6ae:	07800593          	li	a1,120
 6b2:	855a                	mv	a0,s6
 6b4:	da3ff0ef          	jal	456 <putc>
 6b8:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ba:	00000b97          	auipc	s7,0x0
 6be:	35eb8b93          	addi	s7,s7,862 # a18 <digits>
 6c2:	03c9d793          	srli	a5,s3,0x3c
 6c6:	97de                	add	a5,a5,s7
 6c8:	0007c583          	lbu	a1,0(a5)
 6cc:	855a                	mv	a0,s6
 6ce:	d89ff0ef          	jal	456 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d2:	0992                	slli	s3,s3,0x4
 6d4:	34fd                	addiw	s1,s1,-1
 6d6:	f4f5                	bnez	s1,6c2 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 6d8:	8be6                	mv	s7,s9
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	6ca2                	ld	s9,8(sp)
 6de:	bda5                	j	556 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 6e0:	008b8493          	addi	s1,s7,8
 6e4:	000bc583          	lbu	a1,0(s7)
 6e8:	855a                	mv	a0,s6
 6ea:	d6dff0ef          	jal	456 <putc>
 6ee:	8ba6                	mv	s7,s1
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b595                	j	556 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 6f4:	008b8993          	addi	s3,s7,8
 6f8:	000bb483          	ld	s1,0(s7)
 6fc:	cc91                	beqz	s1,718 <vprintf+0x206>
        for (; *s; s++)
 6fe:	0004c583          	lbu	a1,0(s1)
 702:	c985                	beqz	a1,732 <vprintf+0x220>
          putc(fd, *s);
 704:	855a                	mv	a0,s6
 706:	d51ff0ef          	jal	456 <putc>
        for (; *s; s++)
 70a:	0485                	addi	s1,s1,1
 70c:	0004c583          	lbu	a1,0(s1)
 710:	f9f5                	bnez	a1,704 <vprintf+0x1f2>
        if ((s = va_arg(ap, char *)) == 0)
 712:	8bce                	mv	s7,s3
      state = 0;
 714:	4981                	li	s3,0
 716:	b581                	j	556 <vprintf+0x44>
          s = "(null)";
 718:	00000497          	auipc	s1,0x0
 71c:	2f848493          	addi	s1,s1,760 # a10 <malloc+0x15c>
        for (; *s; s++)
 720:	02800593          	li	a1,40
 724:	b7c5                	j	704 <vprintf+0x1f2>
        putc(fd, '%');
 726:	85be                	mv	a1,a5
 728:	855a                	mv	a0,s6
 72a:	d2dff0ef          	jal	456 <putc>
      state = 0;
 72e:	4981                	li	s3,0
 730:	b51d                	j	556 <vprintf+0x44>
        if ((s = va_arg(ap, char *)) == 0)
 732:	8bce                	mv	s7,s3
      state = 0;
 734:	4981                	li	s3,0
 736:	b505                	j	556 <vprintf+0x44>
 738:	6906                	ld	s2,64(sp)
 73a:	79e2                	ld	s3,56(sp)
 73c:	7a42                	ld	s4,48(sp)
 73e:	7aa2                	ld	s5,40(sp)
 740:	7b02                	ld	s6,32(sp)
 742:	6be2                	ld	s7,24(sp)
 744:	6c42                	ld	s8,16(sp)
    }
  }
}
 746:	60e6                	ld	ra,88(sp)
 748:	6446                	ld	s0,80(sp)
 74a:	64a6                	ld	s1,72(sp)
 74c:	6125                	addi	sp,sp,96
 74e:	8082                	ret
      if (c0 == 'd') {
 750:	06400713          	li	a4,100
 754:	e4e78fe3          	beq	a5,a4,5b2 <vprintf+0xa0>
      } else if (c0 == 'l' && c1 == 'd') {
 758:	f9478693          	addi	a3,a5,-108
 75c:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 760:	85b2                	mv	a1,a2
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 762:	4701                	li	a4,0
      } else if (c0 == 'u') {
 764:	07500513          	li	a0,117
 768:	e8a78ce3          	beq	a5,a0,600 <vprintf+0xee>
      } else if (c0 == 'l' && c1 == 'u') {
 76c:	f8b60513          	addi	a0,a2,-117
 770:	e119                	bnez	a0,776 <vprintf+0x264>
 772:	ea0693e3          	bnez	a3,618 <vprintf+0x106>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 776:	f8b58513          	addi	a0,a1,-117
 77a:	e119                	bnez	a0,780 <vprintf+0x26e>
 77c:	ea071be3          	bnez	a4,632 <vprintf+0x120>
      } else if (c0 == 'x') {
 780:	07800513          	li	a0,120
 784:	eca784e3          	beq	a5,a0,64c <vprintf+0x13a>
      } else if (c0 == 'l' && c1 == 'x') {
 788:	f8860613          	addi	a2,a2,-120
 78c:	e219                	bnez	a2,792 <vprintf+0x280>
 78e:	ec069be3          	bnez	a3,664 <vprintf+0x152>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 792:	f8858593          	addi	a1,a1,-120
 796:	e199                	bnez	a1,79c <vprintf+0x28a>
 798:	ee0713e3          	bnez	a4,67e <vprintf+0x16c>
      } else if (c0 == 'p') {
 79c:	07000713          	li	a4,112
 7a0:	eee78ce3          	beq	a5,a4,698 <vprintf+0x186>
      } else if (c0 == 'c') {
 7a4:	06300713          	li	a4,99
 7a8:	f2e78ce3          	beq	a5,a4,6e0 <vprintf+0x1ce>
      } else if (c0 == 's') {
 7ac:	07300713          	li	a4,115
 7b0:	f4e782e3          	beq	a5,a4,6f4 <vprintf+0x1e2>
      } else if (c0 == '%') {
 7b4:	02500713          	li	a4,37
 7b8:	f6e787e3          	beq	a5,a4,726 <vprintf+0x214>
        putc(fd, '%');
 7bc:	02500593          	li	a1,37
 7c0:	855a                	mv	a0,s6
 7c2:	c95ff0ef          	jal	456 <putc>
        putc(fd, c0);
 7c6:	85a6                	mv	a1,s1
 7c8:	855a                	mv	a0,s6
 7ca:	c8dff0ef          	jal	456 <putc>
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	b359                	j	556 <vprintf+0x44>

00000000000007d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d2:	715d                	addi	sp,sp,-80
 7d4:	ec06                	sd	ra,24(sp)
 7d6:	e822                	sd	s0,16(sp)
 7d8:	1000                	addi	s0,sp,32
 7da:	e010                	sd	a2,0(s0)
 7dc:	e414                	sd	a3,8(s0)
 7de:	e818                	sd	a4,16(s0)
 7e0:	ec1c                	sd	a5,24(s0)
 7e2:	03043023          	sd	a6,32(s0)
 7e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ea:	8622                	mv	a2,s0
 7ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f0:	d23ff0ef          	jal	512 <vprintf>
}
 7f4:	60e2                	ld	ra,24(sp)
 7f6:	6442                	ld	s0,16(sp)
 7f8:	6161                	addi	sp,sp,80
 7fa:	8082                	ret

00000000000007fc <printf>:

void
printf(const char *fmt, ...)
{
 7fc:	711d                	addi	sp,sp,-96
 7fe:	ec06                	sd	ra,24(sp)
 800:	e822                	sd	s0,16(sp)
 802:	1000                	addi	s0,sp,32
 804:	e40c                	sd	a1,8(s0)
 806:	e810                	sd	a2,16(s0)
 808:	ec14                	sd	a3,24(s0)
 80a:	f018                	sd	a4,32(s0)
 80c:	f41c                	sd	a5,40(s0)
 80e:	03043823          	sd	a6,48(s0)
 812:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 816:	00840613          	addi	a2,s0,8
 81a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81e:	85aa                	mv	a1,a0
 820:	4505                	li	a0,1
 822:	cf1ff0ef          	jal	512 <vprintf>
}
 826:	60e2                	ld	ra,24(sp)
 828:	6442                	ld	s0,16(sp)
 82a:	6125                	addi	sp,sp,96
 82c:	8082                	ret

000000000000082e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82e:	1141                	addi	sp,sp,-16
 830:	e406                	sd	ra,8(sp)
 832:	e022                	sd	s0,0(sp)
 834:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 836:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83a:	00000797          	auipc	a5,0x0
 83e:	7c67b783          	ld	a5,1990(a5) # 1000 <freep>
 842:	a039                	j	850 <free+0x22>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	6398                	ld	a4,0(a5)
 846:	00e7e463          	bltu	a5,a4,84e <free+0x20>
 84a:	00e6ea63          	bltu	a3,a4,85e <free+0x30>
{
 84e:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 850:	fed7fae3          	bgeu	a5,a3,844 <free+0x16>
 854:	6398                	ld	a4,0(a5)
 856:	00e6e463          	bltu	a3,a4,85e <free+0x30>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85a:	fee7eae3          	bltu	a5,a4,84e <free+0x20>
      break;
  if (bp + bp->s.size == p->s.ptr) {
 85e:	ff852583          	lw	a1,-8(a0)
 862:	6390                	ld	a2,0(a5)
 864:	02059813          	slli	a6,a1,0x20
 868:	01c85713          	srli	a4,a6,0x1c
 86c:	9736                	add	a4,a4,a3
 86e:	02e60563          	beq	a2,a4,898 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
 876:	4790                	lw	a2,8(a5)
 878:	02061593          	slli	a1,a2,0x20
 87c:	01c5d713          	srli	a4,a1,0x1c
 880:	973e                	add	a4,a4,a5
 882:	02e68263          	beq	a3,a4,8a6 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 886:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 888:	00000717          	auipc	a4,0x0
 88c:	76f73c23          	sd	a5,1912(a4) # 1000 <freep>
}
 890:	60a2                	ld	ra,8(sp)
 892:	6402                	ld	s0,0(sp)
 894:	0141                	addi	sp,sp,16
 896:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 898:	4618                	lw	a4,8(a2)
 89a:	9f2d                	addw	a4,a4,a1
 89c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8a0:	6398                	ld	a4,0(a5)
 8a2:	6310                	ld	a2,0(a4)
 8a4:	b7f9                	j	872 <free+0x44>
    p->s.size += bp->s.size;
 8a6:	ff852703          	lw	a4,-8(a0)
 8aa:	9f31                	addw	a4,a4,a2
 8ac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8ae:	ff053683          	ld	a3,-16(a0)
 8b2:	bfd1                	j	886 <free+0x58>

00000000000008b4 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 8b4:	7139                	addi	sp,sp,-64
 8b6:	fc06                	sd	ra,56(sp)
 8b8:	f822                	sd	s0,48(sp)
 8ba:	f04a                	sd	s2,32(sp)
 8bc:	ec4e                	sd	s3,24(sp)
 8be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 8c0:	02051993          	slli	s3,a0,0x20
 8c4:	0209d993          	srli	s3,s3,0x20
 8c8:	09bd                	addi	s3,s3,15
 8ca:	0049d993          	srli	s3,s3,0x4
 8ce:	2985                	addiw	s3,s3,1
 8d0:	894e                	mv	s2,s3
  if ((prevp = freep) == 0) {
 8d2:	00000517          	auipc	a0,0x0
 8d6:	72e53503          	ld	a0,1838(a0) # 1000 <freep>
 8da:	c905                	beqz	a0,90a <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 8dc:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 8de:	4798                	lw	a4,8(a5)
 8e0:	09377663          	bgeu	a4,s3,96c <malloc+0xb8>
 8e4:	f426                	sd	s1,40(sp)
 8e6:	e852                	sd	s4,16(sp)
 8e8:	e456                	sd	s5,8(sp)
 8ea:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 8ec:	8a4e                	mv	s4,s3
 8ee:	6705                	lui	a4,0x1
 8f0:	00e9f363          	bgeu	s3,a4,8f6 <malloc+0x42>
 8f4:	6a05                	lui	s4,0x1
 8f6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 8fe:	00000497          	auipc	s1,0x0
 902:	70248493          	addi	s1,s1,1794 # 1000 <freep>
  if (p == SBRK_ERROR)
 906:	5afd                	li	s5,-1
 908:	a83d                	j	946 <malloc+0x92>
 90a:	f426                	sd	s1,40(sp)
 90c:	e852                	sd	s4,16(sp)
 90e:	e456                	sd	s5,8(sp)
 910:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 912:	00000797          	auipc	a5,0x0
 916:	6fe78793          	addi	a5,a5,1790 # 1010 <base>
 91a:	00000717          	auipc	a4,0x0
 91e:	6ef73323          	sd	a5,1766(a4) # 1000 <freep>
 922:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 924:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 928:	b7d1                	j	8ec <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 92a:	6398                	ld	a4,0(a5)
 92c:	e118                	sd	a4,0(a0)
 92e:	a899                	j	984 <malloc+0xd0>
  hp->s.size = nu;
 930:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 934:	0541                	addi	a0,a0,16
 936:	ef9ff0ef          	jal	82e <free>
  return freep;
 93a:	6088                	ld	a0,0(s1)
      if ((p = morecore(nunits)) == 0)
 93c:	c125                	beqz	a0,99c <malloc+0xe8>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 93e:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 940:	4798                	lw	a4,8(a5)
 942:	03277163          	bgeu	a4,s2,964 <malloc+0xb0>
    if (p == freep)
 946:	6098                	ld	a4,0(s1)
 948:	853e                	mv	a0,a5
 94a:	fef71ae3          	bne	a4,a5,93e <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 94e:	8552                	mv	a0,s4
 950:	a0bff0ef          	jal	35a <sbrk>
  if (p == SBRK_ERROR)
 954:	fd551ee3          	bne	a0,s5,930 <malloc+0x7c>
        return 0;
 958:	4501                	li	a0,0
 95a:	74a2                	ld	s1,40(sp)
 95c:	6a42                	ld	s4,16(sp)
 95e:	6aa2                	ld	s5,8(sp)
 960:	6b02                	ld	s6,0(sp)
 962:	a03d                	j	990 <malloc+0xdc>
 964:	74a2                	ld	s1,40(sp)
 966:	6a42                	ld	s4,16(sp)
 968:	6aa2                	ld	s5,8(sp)
 96a:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 96c:	fae90fe3          	beq	s2,a4,92a <malloc+0x76>
        p->s.size -= nunits;
 970:	4137073b          	subw	a4,a4,s3
 974:	c798                	sw	a4,8(a5)
        p += p->s.size;
 976:	02071693          	slli	a3,a4,0x20
 97a:	01c6d713          	srli	a4,a3,0x1c
 97e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 980:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 984:	00000717          	auipc	a4,0x0
 988:	66a73e23          	sd	a0,1660(a4) # 1000 <freep>
      return (void *)(p + 1);
 98c:	01078513          	addi	a0,a5,16
  }
}
 990:	70e2                	ld	ra,56(sp)
 992:	7442                	ld	s0,48(sp)
 994:	7902                	ld	s2,32(sp)
 996:	69e2                	ld	s3,24(sp)
 998:	6121                	addi	sp,sp,64
 99a:	8082                	ret
 99c:	74a2                	ld	s1,40(sp)
 99e:	6a42                	ld	s4,16(sp)
 9a0:	6aa2                	ld	s5,8(sp)
 9a2:	6b02                	ld	s6,0(sp)
 9a4:	b7f5                	j	990 <malloc+0xdc>
