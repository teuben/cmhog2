/*
 * grid:   aid grid selection in polar coordinates cmhog version
 *       . see also ggen.src
 *
 *   17-jul-2003   written              Peter Teuben
 *
 */

#include <nemo.h>

string defv[] = {
  "ny=251\n        Number of radial zones",
  "ymin=0.1\n      Minimum radius",
  "ymax=16\n       Maximum radius",
  "yrat=1.02043\n  ratio of neighboring radial cell sizes",
  "dymin=\n        First dy",
  "nz=154\n        Number of angular zones (in half the grid, pi)",
  "tol=1e-6\n      Tolerance in Newton Raphson , if needed",
  "out=\n          Optional output file with radii and cell sizes of zone edges",
  "VERSION=1.0\n   17-jul-03",
  NULL,
};

string usage = "grid selection aid program";

#define MAXRAD 1000

nemo_main()
{
  real y[MAXRAD], dy[MAXRAD];
  real  ymin = getdparam("ymin");
  real  ymax = getdparam("ymax");
  real yrat, dymin, tol, yr, dfndyr, fn, deltyr, erryr, dz, nzy;
  int i, iter;
  int ny = getiparam("ny");
  int nz = getiparam("nz");
  stream outf;


  if (hasvalue("dymin")) {   /* Compute yrat from given value of dymin.  
			      * Newton Raphson iteration
			      */
    dymin = getdparam("dymin");
    tol = getdparam("tol");
    yr = 1.01;
    for(iter=1; iter<20; iter++) {
      fn = (ymax - ymin) - dymin*(pow(yr,(double)ny) - 1.0)/(yr - 1.0);
      dfndyr =  -ny*dymin* (pow(yr,(double)ny) - 1)/(yr - 1.0)
	+ dymin*(pow(yr,(double)ny) - 1.0)/sqr(yr - 1.0);
      deltyr  = -fn/dfndyr;
      erryr  = ABS(deltyr/yr);
      yr += deltyr;
      if (erryr < tol) break;
    }
    if (erryr > tol) error("Newton-Raphson did not converge");

    yrat = yr;
    dy[0] = dymin;
  } else if (hasvalue("yrat")) {       /*  Compute dy(imin) from given value of yrat. */
    
    yrat = getdparam("yrat");
    if (yrat == 1.0)
      dy[0] = (ymax-ymin)/ny;
    else
      dy[0] = (ymax-ymin)*(yrat-1.0)/(pow(yrat,(double)ny) - 1.0);
  } 

  y[0] = ymin;
  y[1] = ymin + dy[0];
  for (i=2; i<=ny; i++) {
    dy[i-1] = dy[i-2] * yrat;
    y[i]    = y[i-1] + dy[i-1];
  }
  dz = ymin * PI / (double)nz;

  if (hasvalue("out")) {
    outf = stropen(getparam("out"),"w");
    for (i=0; i<=ny; i++)
      fprintf(outf,"%d %g %g\n",i+1,y[i],dy[i]);
    strclose(outf);
  }
  nzy = PI * ymin / dy[0];
  yr = pow(ymax/ymin, 1.0/ny);
  printf("ny=%d ymin=%g ymax=%g yrat=%g dymin=%g dz=%g nzy=%g bad_yrat=%g\n",
	 ny,ymin,ymax,yrat,dy[0],dz,nzy,yr);
}
