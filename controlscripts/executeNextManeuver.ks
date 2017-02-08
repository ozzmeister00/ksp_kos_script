// executeNextManeuver.ks
// executes the next maneuver starting at T-0:05
// some maths sourced from: http://ksp-kos.github.io/KOS_DOC/tutorials/exenode.html

// todo:
// make sure we're oriented properly BEFORE going to warp
// port the burn time updating code over to the launch script to get a better circularization burn
// pull the stat-printing code into a separate file so it can be called and extended 
// http://www.reddit.com/r/Kos/comments/2xqiuc/steering_pid_controller_accounting_for_angular/
// http://www.reddit.com/r/Kos/comments/2m95li/autoland_for_spaceplanes/

// libraries
runpath("ksp_kos_script\libs\lib_pid.ks").
runpath("ksp_kos_script\libs\lib_controller.ks").
runpath("ksp_kos_script\libs\lib_maths.ks").

// parameters
set TOLERANCE to 0.5.
set THROTTLEDOWNTOLERANCE to .0125.
set STEERINGTOLERANCE to 1.

// setup
SAS off.
RCS off.
lock throttle to 0.
gear off.

clearscreen.
	
set X to NEXTNODE.
set tval to 0.
	
// calculate the burn duration
set MAXACC to SHIP:MAXTHRUST/SHIP:MASS.
set burnDuration to X:deltav:mag/MAXACC.
set THROTTLEDOWNTIME to burnDuration * THROTTLEDOWNTOLERANCE.	
	
set targetHeading to X:BURNVECTOR:DIRECTION.

lock currentHeading to SHIP:FACING.

set INITIALBURNVECTOR to X:BURNVECTOR:DIRECTION.
	
// p-gain - speed of response time
// i-gain - gets you where you want at the speed you want 
// d-gain - prevents overshoot
	
set pitchPID to pid_init(1, 0.25, 1).
set yawPID to pid_init(1, 0.25, 1).
set throttlePID to pid_init(0.02, 0.05, 0.05).
	
set xOffset to 0.
set yOffset to 0.
	
lock midPitch to 0.
lock midYaw to 0.
	
lock targetPitch to midPitch + xOffset.
lock targetYaw to midYaw + yOffset.
	
lock steeringError to getSteeringError(targetHeading).
lock yErr to steeringError:X/180.
lock xErr to steeringError:Y/180.
	
// main loop
until runmode = 0 {
	set updateHeading to true.
	
	set targetHeading to X:BURNVECTOR:DIRECTION.
	
	// orient in direction of burn
	if runmode = 1 {
	
		set targetHeading to X:BURNVECTOR:DIRECTION.
		
		if VANG(SHIP:FACING:VECTOR, targetHeading:VECTOR) < STEERINGTOLERANCE
		{
			set runmode to 2.
		}
	}
	
	// warp to burn
	else if runmode = 2 { 
		
		set updateHeading to false.
		
		set tval to 0.
		// see if it's safe to warp
		if (SHIP:Altitude > 70000) and (X:ETA > 120) {
			if WARP = 0 {
				wait 1.
				SET WARP TO 3.
			}
		}
		else if X:ETA < burnDuration/2 + 60 {
			SET WARP TO 0.
			set runmode to 3.
		}
		
	}
	
	// execute burn
	else if runmode = 3 {
	
		set updateHeading to true.
		
		set targetHeading to X:BURNVECTOR:DIRECTION.
		SET SASMODE to "STABILITY".
	
		// throttle up!
		if X:ETA < burnDuration/2 {
			set tval to 1.
		}
		
		set burnDuration to X:DELTAV:MAG/MAXACC.
		
		// if we're at the point where we need to throttle down
		if burnDuration < THROTTLEDOWNTIME {
			set runmode to 4.
		}
		
	}	
	// throttling down
	else if runmode = 4 {
	
		set updateHeading to true.
		// lock to the initial burn vector so that we don't end up drifting during the last part of the burn.
		set targetHeading to INITIALBURNVECTOR.
		set SASMODE to "STABILITY".
	
		set tval to 0.25.
	
		set burnDuration to X:deltav:mag/MAXACC * 0.25.
	
		// if the burn is over
		if X:BURNVECTOR:MAG < TOLERANCE {
			set tval to 0.
			set runmode to 5.
		}
		
	}
	
	// final wrapup runmode
	else if runmode = 5 {
		set tval to 0.
		set runmode to 0.
	}
	
	if updateHeading = true { 
		SAS off.
	
		set xOffset to pid_seek(pitchPID, 0, xErr).
		set yOffset to pid_seek(yawPID, 0, yErr).
	
		set ship:control:yaw to targetYaw.
		set ship:control:pitch to targetPitch.
		
	}
	else { 
		set ship:control:NEUTRALIZE to true.
		SAS on.
		set SASMODE to "STABILITY". 
	}
	
	lock throttle to tval.
	
	print "RUNMODE:         " + runmode + "     " at (5,4).
	print "STAGE:LIQUIDFUEL " + STAGE:LIQUIDFUEL + "    " at (5,5).
	print "ALTITUDE:        " + round(ship:altitude) + "     " at (5,6).
	print "APOAPSIS:        " + round(ship:apoapsis) + "     " at (5,7).
	print "PERIAPSIS:       " + round(ship:periapsis) + "     " at (5,8).
	print "============= Maneuver Node =============    " at (5,9).
	print "Node in:         " + round(X:ETA) + "    " at (5,10).
	print "DeltaV:          " + round(X:DeltaV:Mag) + "    " at (5, 11).
	print "Burn Duration:   " + round(burnDuration) + "    " at (5,12).
	print "=============    Steering   =============    " at (5,13).
	print "Target Pitch/Yaw:     " + round(targetPitch, 2) + "  |  " + round (targetYaw, 2) +  "    " at (5, 14).
	print "Current Heading:      " + round(currentHeading:pitch, 2) + " | " + round(currentHeading:yaw, 2) + "    " at (5,15).
	print "Seek Heading:         " + round(targetHeading:pitch, 2) + " | " + round(targetHeading:yaw, 2) + "    " at (5, 16).
	print "Heading Error:        " + round(xErr, 2) + " | " + round(yErr, 2) + "       " at (5,17).
	
	wait 0.001.
}

// final cleanup
lock throttle to 0.
unlock steering.
set ship:control:NEUTRALIZE to true.
remove X.
clearscreen.
print "Burn complete".
SAS on.
unlock throttle.