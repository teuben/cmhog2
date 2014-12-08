dnl Process this file with autoconf to produce a configure script.
AC_INIT(bcdflt.c)

AC_MSG_CHECKING([cmhog2 configuration])


dnl Checks for programs.

dnl AC_CANONICAL_SYSTEM
AC_CANONICAL_HOST
echo "Found CANONICAL_HOST = $host_os"

AC_HEADER_STDC
AC_CHECK_FUNCS(strchr memcpy)

dnl Use native cc if present
AC_MSG_CHECKING([for vendor's cc to be used instead of gcc])
AC_CHECK_PROG(CC, cc, cc)

AC_PROG_CC
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_RANLIB

dnl Check for fortran compiler
AC_MSG_CHECKING(whether we have a good FORTRAN 77 compiler)
AC_CHECK_PROGS(F77, gfortran g77 g95 ifort ifc xlf xlf77 fl32 fort77 fc cf77 frt f90 xlf90)
AC_PROG_F77
if test -n "$F77"; then
  if test -n "$GCC"; then
    AC_F77_LIBRARY_LDFLAGS
    ACX_F77_FUNC_MANGLE
    case $host_os in
      ultrix*)
        CC="$CC -Dmain=MAIN_"
        ;;
      osf*)
        CC="$CC -Dmain=MAIN__"
        ;;
      sunos*)
        CC="$CC -Dmain=MAIN_"
        ;;
    esac
  fi
else
  F77="$CC"
  fortran=no
  AC_MSG_WARN([no FORTRAN compiler])
fi


dnl fix up CPP when GCC is the compiler
dnl should also use gcc if e.g. intel of pgi compiler is used ???
if test -n "$GCC"; then
  CPP="$CPP -traditional"
fi

dnl Check for system name
dnl bug: on solaris with gcc compiler, -DSUN will cause the cvgmt() procedure to fail

case $host_os in
      solaris*)
        SYSTEM="SUN"
	CMFLAGS="$CMFLAGS -DSUN"
	CPP=/lib/cpp
        ;;
      linux*)
        SYSTEM="LINUX"
	CMFLAGS="$CMFLAGS -DLINUX"
        ;;
      unicos*)
        SYSTEM="UNICOS"
	CMFLAGS="$CMFLAGS -DUNICOS"
        ;;

esac
if test -n "$GCC"; then
  SYSTEM="LINUX"
fi
AC_SUBST(SYSTEM)
AC_SUBST(CMFLAGS)


dnl Gridsize

AC_ARG_WITH(pgmax, [ --with-pgmax=MAX-SIZE    max size of image], with_pgmax=$withval, with_pgmax=1024)
PGMAX=$with_pgmax
AC_SUBST(PGMAX)

dnl Checks for libraries.

FITSIO=NO_FITSIO
CFITSIO_INC=""
CFITSIO_LIB=""

AC_ARG_ENABLE(cfitsio, [  --enable-cfitsio        do not use CFITSIO], ok=$enableval, ok=no)
if test "$ok" = "yes"; then
  AC_MSG_CHECKING(whether we have CFITSIO)

  cfdefault=/usr/local
 
  AC_ARG_WITH(cfitsio-prefix, AC_HELP_STRING([--with-cfitsio-prefix=PFX],
        [CFITSIO installation prefix (default: $cfdefault)]),
        cfitsio_config_prefix="$withval", cfitsio_config_prefix="use_default")
 
  if test "$cfitsio_config_prefix" = "use_default"; then
    if test -n "$CFITSIO"; then
      cfitsio_config_prefix="$CFITSIO"
    else
      cfitsio_config_prefix="$cfdefault"
    fi
  fi
 
  if test x$cfitsio_config_prefix != x; then
    cdir="$cfitsio_config_prefix"
    for dir in $cdir/include $cdir/cfitsio $cdir/include/cfitsio $cdir
      do
        if test -f ${dir}/fitsio.h ; then
            CFITSIO_INC="-I${dir}"
            incdir="$dir"
            break;
        fi
      done
 
    if test -n "$CFITSIO_INC"; then
      for dir in $cdir/lib $cdir
        do
          if test -f ${dir}/libcfitsio.a ; then
              CFITSIO_LIB="-L${dir}"
              break;
          fi
        done
    fi
 
    if test -z "$CFITSIO_LIB"; then
       AC_MSG_RESULT($cdir (invalid))
       if test -z "$CFITSIO_INC"; then who="header"; else who="library"; fi
       AC_MSG_ERROR([CFITSIO ${who} not found, please specify valid --with-cfitsio-prefix=DIR])
       FITSIO=NO_FITSIO
    else
       AC_MSG_RESULT(${cdir})
       AC_DEFINE(HAVE_LIBCFITSIO)
       CFITSIO_LIB="$CFITSIO_LIB -lcfitsio"
       rm -f src/include/cfitsio ; ln -s $incdir src/include/cfitsio
       FITSIO=FITSIO
    fi
  fi
fi

AC_SUBST(FITSIO)
AC_SUBST(CFITSIO_LIB)
AC_SUBST(CFITSIO_INC)

dnl Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS(fcntl.h sys/time.h unistd.h)

dnl Checks for typedefs, structures, and compiler characteristics.
AC_C_INLINE
AC_HEADER_TIME

dnl Checks for library functions.
AC_CHECK_FUNCS(mkdir select)

AC_CONFIG_FILES(Makefile cmhog.def)
AC_OUTPUT
