AC_PREREQ(2.52)

AC_INIT([Apertium Sardinian-Italian], [1.1.0], [apertium-stuff@lists.sourceforge.net], [apertium-srd-ita], [https://wiki.apertium.org/wiki/Apertium-srd-ita])
AM_INIT_AUTOMAKE
AC_PROG_AWK

PKG_CHECK_MODULES(APERTIUM, apertium >= 3.7.1)
PKG_CHECK_MODULES(LTTOOLBOX, lttoolbox >= 3.5.3)
PKG_CHECK_MODULES(CG3, cg3 >= 1.3.2)
PKG_CHECK_MODULES(APERTIUM_LEX_TOOLS, apertium-lex-tools >= 0.2.7)

AC_PATH_PROGS(ZCAT, [gzcat zcat], [false])
AS_IF([test x$ZCAT = xfalse], [AC_MSG_ERROR([You don't have zcat nor gzcat installed])])

m4_ifdef([AP_CHECK_LING],[],[AC_MSG_ERROR([AP_CHECK_LING not defined, is apertium.m4 in ACLOCAL_PATH? See: https://wiki.apertium.org/wiki/Installation_troubleshooting])])

AP_CHECK_LING([1], [apertium-srd], [1.3.0])
AP_CHECK_LING([2], [apertium-ita], [1.1.0])

AP_MKINCLUDE

AC_OUTPUT([Makefile])
