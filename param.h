c-----------------------------------------------------------------------
c  PARAMETERS - Always set by CPP macros
c  in,jn,kn = number of array elements in i,j,k direction
c  tiny[huge] = smallest[biggest] number allowed (machine dependent)
c
      integer jn, kn, ijkn,icartx,icarty
      real tiny,huge
      parameter(jn= NO_OF_J_ZONES, kn= NO_OF_K_ZONES)
      parameter(tiny= A_SMALL_NUMBER, huge= A_BIG_NUMBER)
      parameter(ijkn=MAX_OF_IJK)
      parameter(icartx=IMG_X, icarty=IMG_Y)
