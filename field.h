c-----------------------------------------------------------------------
c  FIELD VARIABLES
c  d = mass density [gm/cm**3]
c  u,v,w = x,y,z components of velocity [cm/sec]
c  p = pressure [dynes]
c
      real d(jn,kn),v(jn,kn),w(jn,kn)
      common /fieldr/ d, v, w
