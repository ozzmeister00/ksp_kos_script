// hover.ks

// TODO: It looks like stability mode isn't disengaging when it's supposed to!

// libraries
clearscreen.
runpath("ksp_kos_script\libs\lib_physics.ks").
runpath("ksp_kos_script\libs\lib_controller.ks").
runpath("ksp_kos_script\libs\lib_maths.ks").
clearscreen.

// parameters
set seekAlt to 15.
set descentRate to .1.
set landingAlt to 10.

// locked variables
lock shipLatLng to SHIP:GEOPOSITION.
lock surfaceElevation to shipLatLng:TERRAINHEIGHT.
lock betterALTRADAR to max(0.1, ALTITUDE - surfaceElevation).

// go to known state
sas off.
rcs off.
lights off.

// button descriptions
set agButtonDescs[0] to "GO DN".
set agButtonDescs[1] to "GO UP".
set agButtonDescs[4] to " LND ".

// interaction
declare function goDown {
	set seekAlt to seekAlt - 1.
}.

declare function goUp {
	set seekAlt to seekAlt + 1.
}.

// setting up action mappings
on ag1 { goDown(). preserve. }.
on ag2 { goUp(). preserve. }.
on ag5 { set runmode to 0. preserve.}.

set ship:control:pilotmainthrottle to 0.

SET hoverPID TO PIDLOOP(0.1, .01, .06, -1.0, 1.0).

Stage.

lock midThrottle to Fg_here()/ship:availablethrust.

declare function displayBlock {
	declare parameter startCol, startRow. // define where the texture should be positioned.
	
    print " RUNMODE : " + runmode at (startCol, startRow).
    print " seekAlt : " + round(seekAlt,2) + "          " at (startCol, startRow+1).
    print " betterALTRADAR : " + round(betterALTRADAR,2) + "          " at (startCol, startRow+2).
    print " thrott  : " + round(thrott, 2) + "          " at (startCol, startRow + 3).
    print " midThrottle  : " + round(midThrottle, 2) + "          " at (startCol, startRow + 4).
    
}.

set runmode to 1.

LOCK STEERING TO R(0,0,-90) + HEADING(90,90). // point up
SET thrott TO 1.
LOCK THROTTLE TO thrott + midThrottle.

until runmode = 0 {
	// throttle offset is determined by getting the Proportional Integral Derivative of the where we are and where we want to be
    
    SET hoverPID:SETPOINT TO seekAlt.
    SET thrott TO hoverPID:UPDATE(TIME:SECONDS, betterALTRADAR).
    
	displayActionBlock().
	displayBlock(5, 5).
 
	wait 0.001.
}

unlock steering.
set throttle to 0.
unlock throttle.

clearscreen.