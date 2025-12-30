# Use openlibm, otherwise use system libm
USE_OPENLIBM:=0
# Skip all fp exception tests
SKIP_FP_EXCEPT_TEST:=0

# Build and link flags
CFLAGS += -DSKIP_FP_EXCEPT_TEST=$(SKIP_FP_EXCEPT_TEST)
CFLAGS += -pipe -std=c99 -D_POSIX_C_SOURCE=200809L -D_XOPEN_SOURCE=700 
CFLAGS += -Wall -pedantic -Wno-unused-function -Wno-missing-braces -Wno-unused -Wno-overflow
CFLAGS += -Wno-unknown-pragmas -fno-builtin -frounding-math
CFLAGS += -Werror=implicit-function-declaration -Werror=implicit-int -Werror=pointer-sign -Werror=pointer-arith
CFLAGS += -g
CFLAGS += -DLDBL_MANT_DIG=113
LDFLAGS += -g
LDLIBS += -lpthread -lrt

# Choose libm
ifneq ($(USE_OPENLIBM), 1)
  LDLIBS += -lm
  # glibc specific settings
  CFLAGS += -D_FILE_OFFSET_BITS=64
  LDLIBS += -lcrypt -ldl -lresolv -lutil -lpthread
else # Use openlibm
  include openlibm.mk

  CFLAGS += $(CFLAGS_add)
  LDFLAGS += $(LDFLAGS_add)
  LDLIBS += $(OPENLIBM_LIB)
endif # USE_OPENLIBM


# -- [C99]
C99_SRC:=fenv
# Cpp: Classification
C99_SRC+=fpclassify
# TODO: isfinite isinf isnan isnormal signbit
# C99: Trigonometric
C99_SRC+=acos acosf acosl  asin asinf asinl  atan atanf atanl
C99_SRC+=atan2 atan2f atan2l
C99_SRC+=cos cosf cosl  sin sinf sinl  tan tanf tanl
# C99: Hyperbolic
C99_SRC+=acosh acoshf acoshl  asinh asinhf asinhl  atanh atanhf atanhl
C99_SRC+=cosh coshf coshl  sinh sinhf sinhl  tanh tanhf tanhl
# C99: Exponential and logarithmic
C99_SRC+=exp expf expl  exp2 exp2f exp2l  expm1 expm1f expm1l 
C99_SRC+=frexp frexpf frexpl  ilogb ilogbf ilogbl  ldexp ldexpf ldexpl
C99_SRC+=log10 log10f log10l  log1p log1pf log1pl  log2 log2f log2l
C99_SRC+=logb logbf logbl  log logf logl
C99_SRC+=modf modff modfl
C99_SRC+=scalbn scalbnf scalbnl  scalbln scalblnf scalblnl
# C99: Power and Absolute-value
C99_SRC+=pow powf powl  sqrt sqrtf sqrtl  cbrt cbrtf cbrtl
C99_SRC+=hypot hypotf hypotl
C99_SRC+=fabs fabsf fabsl
# C99: Error and gamma
C99_SRC+=erf erff erfl  erfc erfcf erfcl
C99_SRC+=lgamma lgammaf lgammal  tgamma tgammaf tgammal
# C99: Nearest integer
C99_SRC+=ceil ceilf ceill  floor floorf floorl
C99_SRC+=nearbyint nearbyintf nearbyintl
C99_SRC+=rint rintf rintl lrint lrintf lrintl llrint llrintf llrintl
C99_SRC+=round roundf roundl lround lroundf lroundl llround llroundf llroundl
C99_SRC+=trunc truncf truncl
# C99: Remainder
C99_SRC+=fmod fmodf fmodl  remainder remainderf remainderl  remquo remquof remquol
# C99: Manipulation
C99_SRC+=copysign copysignf copysignl
C99_SRC+=nextafter nextafterf nextafterl  nexttoward nexttowardf nexttowardl
# TODO: nan
# C99: Maximum, minimum
C99_SRC+=fdim fdimf fdiml  fmax fmaxf fmaxl  fmin fminf fminl
# C99: Floating multiply-add
C99_SRC+=fma fmaf fmal
# C99: Comparison
C99_SRC+=isless
# TODO: isgreater isgreaterequal islessequal islessgreater isunordered
# -- [C23]
C23_SRC:=exp10 exp10f exp10l
C23_SRC:=pow10 pow10f pow10l
# -- [BSD]
# BSD_SRC:=drem dremf
BSD_SRC+=j0 j0f j1 j1f jn jnf
BSD_SRC+=lgamma_r lgammaf_r lgammal_r
# BSD_SRC+=scalb scalbf
BSD_SRC+=y0 y0f y1 y1f yn ynf
# -- [GNU]
GNU_SRC:=sincos sincosf sincosl

# Collect all c src files
SRCS:=$(C99_SRC:%=src/math/%.c)
# SRCS+=$(C23_SRC:%=src/math/%.c)
SRCS+=$(BSD_SRC:%=src/math/%.c)
SRCS+=$(GNU_SRC:%=src/math/%.c)

SRCS+=$(wildcard src/api/*.c)
SRCS+=$(wildcard src/common/*.c)
_MATH_SRC:=$(sort $(wildcard src/math/*.c))
SRCS:=$(sort $(SRCS))
#
OBJS:=$(SRCS:src/%.c=$(B)/%.o)
LOBJS:=$(SRCS:src/%.c=$(B)/%.lo)
DIRS:=$(patsubst src/%/,%,$(sort $(dir $(SRCS))))
BDIRS:=$(DIRS:%=$(B)/%)
NAMES:=$(SRCS:src/%.c=%)


# Makefile debugging trick:
# call print-VARIABLE to see the runtime value of any variable
# (hardened against any special characters appearing in the output)
print-%:
	@echo '$*=$(subst ','\'',$(subst $(newline),\n,$($*)))'
