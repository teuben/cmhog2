#! /bin/csh -f
#
#  This scripts takes an HDF output snapshot file from cmhog
#  (bar hydro, polar coordinates), projects it to a requested
#  sky view as to be able to compare it with an existing maps
#  (mostly meant for a velocity field). It will need a reference
#  map in order for pixel by pixel comparison
#
#  In the model the bar is assumed oriented along Y axis (PA=0), and 
#  flows CCW as seen from the positive Z axis.
#  For CW rotating galaxies the code adds 180 to 'inc' and/or 'pa'
#
#  Observations are assumed to have their reference pixel to
#  coincide with the center (ra0,dec0,vsys), although we expect
#  to relax this condition in a future version of this script.
#
#  The new convention for rot=1 means CCW, rot=-1 means CW, denoting
#  the sign of the galaxy angular momentum vector, where the positive
#  Z axis points to the observer (hence doppler recession is -vz).
#
#   9-may-03  Derived from mkbar_cube.csh

set version=9-may-03

if ($#argv == 0) then
  echo Usage: $0 in=HDF_DATASET out=BASENAME refmap=FITSFILE...
  echo Version: $version
  echo Gridding and projecting 2D CMHOG hydro models to specified bar viewing angles
  echo Creates maps to be compared to a refman
  echo Optional parameters:  
  echo "   pa, inc, phi, rot (1=ccw)"
  echo "   rmax, n, beam, color, clean, cube, denlog"
  echo "   nvel, vmax"
  echo "   wcs, pscale, vscale, vsys"
  echo "   par, inden"
  echo "You also need the NEMO environment"
  exit 0
endif

# 			Required Keywords
unset in
unset out
unset refmap
# 			Geometry (defaults are for some reasonable galaxy)
set pa=30
set inc=60
set phi=30
set rot=1
#                       Spatial gridding (n cells from -rmax : rmax)
set rmax=6
set n=200
set beam=0.25
set color=1
set clean=1
set denlog=0

#			Velocity gridding for cube  (nvel cells from -vmax : vmax)
set nvel=50
set vmax=250

#                       WCS definition (and mapping) if derived from an observation (cube)
set wcs=1

set pscale=1
set vscale=1
set vsys=0

#                       extra scaling for hydro data into the snapshot (usefull if no wcs)
set hpscale=1
set hvscale=1


#
set par=""
set inden=""
#			Parse commandline to (re)set keywords
foreach a ($*)
  set $a
  if (-e "$par") then
    source $par
  else if (X != X$par) then
    echo Warning, par=$par does not exist
  endif
  set par=""
end

#               Fixed constants (p: arcsec -> degrees    v: km/s -> m/s)
#               probably should not be changed
set puscale=2.77777777777e-4
set vuscale=1e3

#
#  fix inc/pa for ccw(rot=1) or cw(rot=-1) cases for NEMO's euler angles
#
if ($rot == -1) then
   set inc=$inc+180
else if ($rot == 1) then
   set pa=$pa+180
else
   echo "Bad rotation, must be 1 (ccw) or -1 (cw)"
   exit 1
endif
#		Report
echo     Files: in=$in out=$out 
echo -n "Grid: rmax=$rmax n=$n beam=$beam "
if ($wcs) then
   echo \(`nemoinp "$beam*$pscale"` arcsec\)
else
   echo ""
endif
echo Projection: phi=$phi inc=$inc pa=$pa
#               Derived quantities
set cell=`nemoinp "2*$rmax/$n"`
set range="-${rmax}:${rmax}"
echo -n "      Derived: cell=$cell"
if ($wcs) then
   echo \(`nemoinp "2*$rmax/$n*$pscale"` arcsec\)
else
   echo ""
endif

if ($wcs) then
    if (-e "$refmap") then
	echo DEPRECATING USING A REFMAP....
	#   referencing for the 3rd axis
	set nz=(`fitshead $refmap | grep ^NAXIS3 | awk '{print $3}'`)
	set pz=(`fitshead $refmap | grep ^CRPIX3 | awk '{print $3}'`)
	set vz=(`fitshead $refmap | grep ^CRVAL3 | awk '{print $3}'`)
	set dz=(`fitshead $refmap | grep ^CDELT3 | awk '{print $3}'`)
    
	# step in model cube, if vscale=1
	set dz1=`nemoinp "2*$vmax/$nz"`
	# 
	set vref=`nemoinp "($vz-$vsys*$vuscale)/($dz1)+$nvel/2+0.5"`
	#set vscale=`nemoinp "$vscale*(2*$vmax/$nvel)/($dz/1000)"`
    endif

    set refcen=`nemoinp $n/2+0.5`
    set vref=`nemoinp $nvel/2+0.5`
    set crpix=$refcen,$refcen,$vref

    #  cdelt in new units
    set dv=`nemoinp "2*$vmax*$vuscale/$nvel*$vscale"`
    set dp=`nemoinp "2*$rmax*$puscale/$n*$pscale"`
    set cdelt=-$dp,$dp,$dv

    # RA/DEC: just report how much the reference pixel in the reference cube is offset from out (ra0,dec0)
    set ra00=`echo $ra0 | awk -F: '{printf("%.10f\n",((($3/60+$2)/60)+$1)*15)}'`
    set dec00=`echo $dec0 | awk -F: '{printf("%.10f\n",(($3/60+$2)/60)+$1)}'`
    echo RA0,DEC0=$ra0,$dec0
    echo RA00,DEC00=$ra00,$dec00
    set crval=$ra00,$dec00,`nemoinp "$vsys*$vuscale"`
    if (-e "$refmap") then
	set vx=(`fitshead $refmap | grep ^CRVAL1 | awk '{print $3}'`)
	set vy=(`fitshead $refmap | grep ^CRVAL2 | awk '{print $3}'`)
	echo Offset in RA and DEC: `nemoinp "(($vx)-($ra00))*3600"`  `nemoinp "(($vy)-($dec00))*3600"` arcsec
	echo $nz $pz $vz $dz 
    endif
    echo Vsys at OBS pixel: `nemoinp "($vsys*$vuscale-$vz)/$dz+$pz"` 
    echo CRPIX:   $crpix
    echo CRVAL:   $crval
    echo CDELT:   $cdelt
    set wcspars=(crpix=$crpix crval=$crval cdelt=$cdelt radecvel=t)
    if (-e "$refmap") then
	set wcspars=($wcspars refmap=$refmap)
    endif
    #  BUG?:  the mod-cube is assumed to be centered at their own WCS of (0,0,0)
    #         the obs-cube has a positional reference pixel which is assumed
    #         to coincide with (0,0), however
else
  set wcspars=()
endif


set comment="$0 $in $out $pa,$inc,$phi,$range,$n,$beam"

echo WCSPARS: $wcspars
echo COMMENT: $comment

#> nemo.need tabtos tabmath snaptrans snaprotate snapadd snapgrid ccdsmooth ccdmath ccdfits fitshead

set tmp=tmp$$
if (! -e $out.den.fits) then

    # convert the half-plane HDF file to a full plane snapshot file

    tsd in=$in out=$tmp.tab coord=t
    if (-e "$inden") then
      echo "Taking densities from $inden instead in $in"
      tsd in=$inden out=$tmp.tab.den coord=t
      mv $tmp.tab  $tmp.tab.vel
      tabmath $tmp.tab.vel,$tmp.tab.den $tmp.tab %1,%2,%3,%4,%10 all
    endif
    if ($status) goto cleanup
    tabtos in=$tmp.tab out=$tmp.s0 block1=x,y,vx,vy,mass
    snaptrans in=$tmp.s0 out=$tmp.s1 ctypei=cyl ctypeo=cart
    snaprotate in=$tmp.s1 out=$tmp.s2 theta=180 order=z
    snapadd $tmp.s1,$tmp.s2 $tmp.s3

    # project for skyview, and create a intensity and velocity field

    snaprotate $tmp.s3 - \
        "atand(tand($phi)/cosd($inc)),$inc,$pa" zyz |\
	snapscale - $tmp.snap rscale=$hpscale vscale=$hvscale

    echo -n "Projected model velocities:"
    snapprint $tmp.snap -vz | tabhist - tab=t |& grep min

    foreach mom (0 1 2)
         snapgrid in=$tmp.snap out=$tmp.$mom \
                xrange=$range yrange=$range nx=$n ny=$n moment=$mom mean=t
         ccdsmooth in=$tmp.$mom out=$tmp.$mom.s gauss=$beam
    end
    ccdmath $tmp.1.s,$tmp.0.s $tmp.vel %1/%2
    ## BUG: ifgt() doesn't work
    ##    ccdmath $tmp.0.s - "ifgt(%1,0,log(%1),-10)" | ccdfits - $out.den.fits
    ccdmath $tmp.0.s - "log(%1)" | ccdmath - - "ifeq(%1,0,-10,%1)" |\
        ccdfits - $out.den.fits  \
        object=$in comment="$comment" $wcspars 
    ccdmath $tmp.2.s,$tmp.0.s,$tmp.vel - "sqrt(%1/%2-%3*%3)" |\
        ccdfits - $out.sig.fits \
        object=$in comment="$comment" $wcspars 
    ccdfits $tmp.vel $out.vel.fits \
        object=$in comment="$comment" $wcspars 

    if ($clean) rm -fr $tmp.*
else
    echo Warning: skipping gridding and projecting
endif

exit 0

cleanup:
    echo Some error occured
    if ($clean) rm $tmp.*



