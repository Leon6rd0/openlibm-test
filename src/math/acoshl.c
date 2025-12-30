#include <stdint.h>
#include <stdio.h>
#include "mtest.h"

/* 定义一个宏来标记当前架构是否有匹配的测试数据 */
#if (LDBL_MANT_DIG == 53) || (LDBL_MANT_DIG == 64)
    #define HAS_MATCHING_DATA 1
#else
    #define HAS_MATCHING_DATA 0
#endif

static struct l_l t[] = {
#if LDBL_MANT_DIG == 53
#include "sanity/acosh.h"
#include "special/acosh.h"

#elif LDBL_MANT_DIG == 64
#include "sanity/acoshl.h"
#include "special/acoshl.h"

#endif
{ .r = -1 }
};

int main(void)
{
	/* 核心修改 2: 打印当前精度信息 */
	printf("INFO: System LDBL_MANT_DIG = %d\n", LDBL_MANT_DIG);
	/* 核心修改 3: 如果没有匹配的数据，打印提示并优雅退出 */
	if (!HAS_MATCHING_DATA) {
        	printf("SKIP: No matching test vectors for this precision.\n");
        	return 0; /* 返回 0 表示“测试通过/跳过”，不会打断 make 流程 */
    }
	#pragma STDC FENV_ACCESS ON
	long double y;
	float d;
	int e, i, err = 0;
	struct l_l *p;

	for (i = 0; i < sizeof t/sizeof *t; i++) {
		p = t + i;

		if (p->r < 0)
			continue;
		fesetround(p->r);
		feclearexcept(FE_ALL_EXCEPT);
		y = acoshl(p->x);
		e = fetestexcept(INEXACT|INVALID|DIVBYZERO|UNDERFLOW|OVERFLOW);

		if (!checkexcept(e, p->e, p->r)) {
			printf("%s:%d: bad fp exception: %s acoshl(%La)=%La, want %s",
				p->file, p->line, rstr(p->r), p->x, p->y, estr(p->e));
			printf(" got %s\n", estr(e));
			err++;
		}
		d = ulperrl(y, p->y, p->dy);
		if (!checkulp(d, p->r)) {
			printf("%s:%d: %s acoshl(%La) want %La got %La ulperr %.3f = %a + %a\n",
				p->file, p->line, rstr(p->r), p->x, p->y, y, d, d-p->dy, p->dy);
			err++;
		}
	}
	return !!err;
}
