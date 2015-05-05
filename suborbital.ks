// suborbital.ks
// used for sending up the suborbital kerbal tourist ship

// initialize
SAS ON.
SET SASMODE TO "STABILITY".
RCS off.
lock throttle to 0.
gear off.

// feedback
clearscreen.

// safety
set runmode to 2.

// are we on the ground?
if ALT:RADAR < 50 {
    set runmode to 1.
	}
	
// main loop
until runmode = 0 {

	set targetHeading to heading(90, 90).

	// launch!
	if runmode = 1 {
		set TVAL to 1.
		stage.
		set runmode to 2.
	}

	// go straight up until we're not
	else if runmode = 2 {
		set TVAL to 1.
		
		// if we start falling, move to the next verb
		if SHIP:VERTICALSPEED < 0{
			set runmode to 3.
		}
	}
	
	// return commands
	else if runmode = 3 {
	}
	
	// Check for Staging
	if STAGE:SOLIDFUEL < 0.01 {
	    lock throttle to 0.
		wait 0.5.
		STAGE.
		wait 0.5.
		lock throttle to TVAL.
	}
	
	// TODO:
	// Debug draw lines for target heading and current heading
	
	lock STEERING to targetHeading.
	lock throttle to TVAL.
	
	print "RUNMODE:         :" + runmode + "     " at (5,4).
	print "STAGE:SOLIDFUEL  :" + STAGE:SOLIDFUEL + "    " at (5,5).
	print "ALTITUDE:        :" + round(ship:altitude) + "     " at (5,6).
	print "APOAPSIS:        :" + round(ship:apoapsis) + "     " at (5,7).
	print "ETA TO AP:       :" + round(ETA:APOAPSIS) + "     " at (5,8).
	
}