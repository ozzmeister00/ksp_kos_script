// hover.ks

clearscreen.
run lib_physics.
run lib_pid.
run lib_controller.
clearscreen.

set agButtonDescs[0] to "GO DN".
set agButtonDescs[1] to "GO UP".
set agButtonDescs[2] to " END ".

print " Seek ALT_RADAR = ".
print "  Cur ALT_RADAR = ".
print "    1g Throttle = ".
print "Throttle Offset = ".
print " Total Throttle = ".

lock shipLatLng to SHIP:GEOPOSITION.
lock surfaceElevation to shipLatLng:TERRAINHEIGHT.
lock betterALTRADAR to max(0.1, ALTITUDE - surfaceElevation).

sas on.

set seekAlt to 20.

declare function goDown {
	set seekAlt to seekAlt - 1.
}.

declare function goUp {
	set seekAlt to seekAlt + 1.
}.

// setting up action mappings on top of axis mappings
when ag1 = true then { goDown(). preserve. }. //set seekAlt to seekAlt + .1. preserve. }.
when ag2 = true then { goUp(). preserve. }.
when ag3 = true then { set runmode to 0. preserve. }.

set ship:control:pilotmainthrottle to 0.

until ship:availablethrust > 0 {
	wait 0.5.
	stage.
}

declare function displayBlock {
	declare parameter startCol, startRow. // define where the texture should be positioned.
	
	print round(seekAlt,2) + "m    " at (startCol, startRow).
	print round(betterALTRADAR,2) + "m    " at (startCol, startRow+1).
	print round(midThrottle,3) + "     " at (startCol, startRow+2).
	print round(thOffset,3) + "     " at (startCol, startRow+3).
	print round(throttle,3) + "     " at (startCol, startRow+4).
}.

// hover exactly against gravity (in principle)
// also known as set point
lock midThrottle to Fg_here()/ship:availablethrust.

// how much to add or subtract from hover throttle
// this is what we let the pid controller control
set thOffset to 0.

lock throttle to midThrottle + thOffset.

// get my pid array
set hoverPID to pid_init(0.02, 0.05, 0.05).

set runmode to 1.

until runmode = 0 {
	// throttle offset is determined by getting the Proportional Integral Derivative of the where we are and where we want to be
	set thOffset to pid_seek(hoverPID, seekAlt, betterALTRADAR).
	displayActionBlock().
	displayBlock(18, 0).
	wait 0.001.
}

wait 0.1.

// once we're done, set us down very gently
set runmode to 1.
set landingAlt to 4.
set descentRate to .1.

until runmode = 0 {
	set thOffset to pid_seek(hoverPID, seekAlt, betterALTRADAR).
	
	// this area should probably be abstracted to a PID controller, as it's a value that needs to change stably over time
	set seekAlt to seekAlt - descentRate.
	
	displayActionBlock().
	displayBlock(18, 0).
	
	wait 0.001.
	
	if landingAlt * 1.05 > betterALTRADAR {
		lock throttle to 0.
		set runmode to 0.
	}	
}

clearscreen.