// balance.ks
// used as a platform for testing maths to self-right the controlled ship

// init libraries
clearscreen.

run lib_physics.
run lib_pid.

clearscreen.

// initialize to safe state.
SAS on.
gear off. gear on.
set ship:control:pilotmainthrottle to 0.

// parameters

// functions
declare function displayBlock {

	print " Current Heading:" + round(targetYaw, 2) + " | " + round(targetPitch,2) + "           " at (5, 10).
	print " SpeedX         :" + round(currPitchSpeed, 2) + "    " at (5,11).
	print " SpeedY         :" + round(currYawSpeed, 2) + "    " at (5,12).
	print " xOffset        :" + round(xOffset, 2) + "    " at (5,13).
	print " yOffset        :" + round(yOffset, 2) + "    " at (5,14).
}

// control midpoints
lock midPitch to 0.
lock midYaw to UP:YAW. // make sure we're always facing up

// seek values
set seekPitchSpeed to 0.
set seekYawSpeed to 0.

lock currPitchSpeed to VELOCITY:SURFACE:X.
lock currYawSpeed to VELOCITY:SURFACE:Y.

set xOffset to 0.
set yOffset to 0.

lock targetPitch to midPitch + xOffset.
lock targetYaw to midYaw + yOffset.

set xPID to pid_init(0.02, 0.05, 0.05).
set yPID to pid_init(0.02, 0.05, 0.05).

// set the base runmode
set runmode to 1.
lock steering to R(targetPitch, targetYaw, ship:facing:roll). // let the user define the roll of the ship

// inputs
on ag9 { set runmode to 0. preserve. }.

// need to make sure that we're pitching and yawing relative to our roll so that we can be turning in any direction we want.

until runmode = 0 {
	displayBlock().
	
	set xOffset to pid_seek(xPID, seekPitchSpeed, currPitchSpeed).
	set yOffset to pid_seek(yPID, seekYawSpeed, currYawSpeed).
	
	wait 0.001.
	
}

clearscreen.

print "Balance ending."