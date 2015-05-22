// hover.ks

// TODO: It looks like stability mode isn't disengaging when it's supposed to!

// libraries
clearscreen.
run lib_physics.
run lib_pid.
run lib_controller.
run lib_maths.
clearscreen.

// parameters
set seekAlt to 15.
set descentRate to .1.
set landingAlt to 10.
set horizSpeedMax to 15.
set horizDeflectionMax to 45.
set horizSpeedTolerance to 0.1.

// locked variables
lock shipLatLng to SHIP:GEOPOSITION.
lock surfaceElevation to shipLatLng:TERRAINHEIGHT.
lock betterALTRADAR to max(0.1, ALTITUDE - surfaceElevation).

// go to known state
sas on.
rcs off.
lights off.

// button descriptions
set agButtonDescs[0] to "GO DN".
set agButtonDescs[1] to "GO UP".
set agButtonDescs[2] to "STLBZ".
set agButtonDescs[3] to "HORIZ".
set agButtonDescs[4] to " LND ".

// interaction
declare function goDown {
	set seekAlt to seekAlt - 1.
}.

declare function goUp {
	set seekAlt to seekAlt + 1.
}.

declare function stabilizer {
	
	set agAxisMapping[2] to not agAxisMapping[2].
	
	set agAxisMapping[3] to false.
	
	if agAxisMapping[2] = true {
		lock steering to R(targetPitch, targetYaw, 180).
		
		set pitchOffset to 0.
		set yawOffset to 0.
	}
	else {
		unlock steering.
	}
}.

declare function killHorizontal {
	set agAxisMapping[3] to not agAxisMapping[3].
	
	// turn off the balancer visual
	set agAxisMapping[2] to false.
	
	if agAxisMapping[3] = true {
		lock steering to R(targetPitch, targetYaw, 180).
		
		set xOffset to 0.
		set yOffset to 0.
	}
	else {
		unlock steering.
	}
}.

// setting up action mappings
on ag1 { goDown(). preserve. }.
on ag2 { goUp(). preserve. }.

// setting up axis mappings
on ag3 { stabilizer(). preserve.}.
on ag4 { killHorizontal(). preserve.}.
on ag5 { set agAxisMapping[4] to not agAxisMapping[4]. preserve.}.

set ship:control:pilotmainthrottle to 0.

until ship:availablethrust > 0 {
	wait 0.5.
	stage.
}

declare function displayBlock {
	declare parameter startCol, startRow. // define where the texture should be positioned.
	
	// information dispaly
	print " Seek ALT_RADAR : " + round(seekAlt,2) + "     " at (startCol, startRow).
	print " Cur ALT_RADAR  : " + round(betterALTRADAR,2) + "      " at (startCol, startRow+1).
	print " Current Heading: " + round(targetYaw, 2) + " | " + round(targetPitch,2) + "           " at (startCol,startRow+2).
	print " SpeedX         : " + round(currPitchSpeed, 2) + "    " at (startCol,startRow+3).
	print " SpeedY         : " + round(currYawSpeed, 2) + "    " at (startCol,startRow+4).
	print "                  " at (startCol, startRow+5).
	print " pitchOffset    : " + round(pitchOffset, 3) + "    " at (startCol, startRow+6).
	print " yawOffset    : " + round(pitchOffset, 3) + "    " at (startCol, startRow+7).
}.

// hover exactly against gravity (in principle)
// also known as set point
lock midThrottle to Fg_here()/ship:availablethrust.

// how much to add or subtract from hover throttle
// this is what we let the pid controller control
set thOffset to 0.

// set the control state
lock throttle to midThrottle + thOffset.

// set up the hover pid
set hoverPID to pid_init(0.02, 0.05, 0.05).

// ** BALANCING PIDs ** //

// control midpoints (where we want to be pointing)
lock midPitch to 0.
lock midYaw to UP:YAW. // make sure we're always facing up

// seek values
set seekPitchSpeed to 0.
set seekYawSpeed to 0.

lock currPitchSpeed to VELOCITY:SURFACE:X.
lock currYawSpeed to VELOCITY:SURFACE:Y.

set xOffset to 0.
set yOffset to 0.

set xPID to pid_init(0.02, 0.05, 0.05).
set yPID to pid_init(0.02, 0.05, 0.05).

set pitchOffset to 0.
set yawOffset to 0.

lock targetPitch to midPitch + xOffset + pitchOffset.
lock targetYaw to midYaw + yOffset - yawOffset.

set runmode to 1.

until runmode = 0 {
	// throttle offset is determined by getting the Proportional Integral Derivative of the where we are and where we want to be
	set thOffset to pid_seek(hoverPID, seekAlt, betterALTRADAR).
	
	displayActionBlock().
	displayBlock(5, 5).
		
	// continuously update stabilizer mode
	if agAxisMapping[2] = true {
		set xOffset to pid_seek(xPID, seekPitchSpeed, currPitchSpeed).
		set yOffset to pid_seek(yPID, seekYawSpeed, currYawSpeed).
		set pitchOffset to 0.
		set yawOffset to 0.
	}
	
	// handle continuous updates for killHorizontal mode
	if agAxisMapping[3] = true {
		set xOffset to 0.
		set yOffset to 0.
		set pitchOffset to (currYawSpeed / horizSpeedMax) * horizDeflectionMax.
		set yawOffset to ((currPitchSpeed / horizSpeedMax) * horizDeflectionMax).
		
		// exit the horizontal kill velocity mode if we're within tolerances of horizontal velocity
		if abs(currPitchSpeed + currYawSpeed) < horizSpeedTolerance {
			killHorizontal().
			stabilizer().
		}
		
	}
	
	// landing mode
	if agAxisMapping[4] = true {
		set seekAlt to max(landingAlt, seekAlt - descentRate).
		
		if landingAlt * 1.05 > betterALTRADAR {
			lock throttle to 0.
			set runmode to 0.
		}	
	}
	
	wait 0.001.
}

unlock steering.
set throttle to 0.
unlock throttle.

clearscreen.