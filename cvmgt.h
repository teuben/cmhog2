c
c	on some machines this arithmetic statement function
c	will work, on strict ansi (e.g. the f2c compiler) you
c	will need the cvmgt.src function, on the cray CVMGT is
c	an inline vector instruction
c
#ifdef SUN
      real aa,bb,cvmgt
      integer ii
      cvmgt(aa,bb,ii) = ii*aa + (1-ii)*bb
#endif SUN
#ifdef CONVEX
      real aa,bb,cvmgt
      integer ii
      cvmgt(aa,bb,ii) = -ii*aa + (1+ii)*bb
#endif CONVEX
