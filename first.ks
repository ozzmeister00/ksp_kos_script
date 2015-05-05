// first.ks
//

SAS ON.
SET SASMODE TO "STABILITY".
RCS off.
lock throttle to 0.
gear off.

clearscreen.

set targetApoapsis to 85000.
set targetPeriapsis to 85000.

set gravityTurnStart to 500.
set gravityTurnEnd to 35000.

// safety
set runmode to 2.

// are we on the ground?
if ALT:RADAR < 50 {
    set runmode to 1.
	}
	
// main loop
until runmode = 0 {

	set targetHeading to heading(90, 90).

	// launch
	if runmode = 1 {
		set TVAL to 1.
		stage.
		set runmode to 2.
	}

	// go straight up until the start of the gravity turn
	else if runmode = 2 {
		set TVAL to 1.
		if SHIP:ALTITUDE > gravityTurnStart
		{
			set runmode to 3.
		}
		if (STAGE:SOLIDFUEL:CAPACITY > 0) and (STAGE:SOLIDFUEL < 0.1)
		{
			stage.
		}
	}
	
	// gravity turn
	else if runmode = 3 {
		set targetPitch to max(5, 90 * (1 - (ALT:RADAR / gravityTurnEnd))).
		set targetHeading to heading(90, targetPitch).
		set TVAL to 1.
		
		if SHIP:APOAPSIS > targetApoapsis {
			set runmode to 4.
		}
	}
	
	else if runmode = 4 { // coast to apoapsis
		set targetHeading to heading ( 90, 3).
		set TVAL to 0.
		// see if it's safe to warp
		if (SHIP:Altitude > 70000) and (ETA:Apoapsis > 60) and (VERTICALSPEED > 0) {
			if WARP = 0 {
				wait 1.
				SET WARP TO 3.
			}
		}
		else if ETA:APOAPSIS < 60 {
			SET WARP TO 0.
			set runmode to 5.
		}
	}
	
	// raise periapsis
	else if runmode = 5 {
	
		set targetHeading to heading( 90, 0).
		//SET SASMODE to "PROGRADE".
	
		if ETA:APOAPSIS < 5 or VERTICALSPEED < 0{
			set TVAL to 1.
		}
		if (SHIP:PERIAPSIS > targetPeriapsis) or (SHIP:APOAPSIS >  targetApoapsis * 1.05){
			set TVAL to 0.
			set runmode to 10.
		}
	}
	
	else if runmode = 10 {
		set TVAL to 0.
		panels on.
		lights on.
		
		set runmode to 11.
	}
	
	else if runmode = 11 {
		SET targetHeading to heading(90,-90).
		set TVAL to 0.
		
		stage.
		
		wait 5.
		
		set AG1 to true.
		
		set runmode to 0.
		
		print "WELCOME TO SPACE.".
	}
	
	// Check for Staging
	if STAGE:LIQUIDFUEL < 0.01 {
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
	
	print "RUNMODE:         " + runmode + "     " at (5,4).
	print "STAGE:LIQUIDFUEL " + STAGE:LIQUIDFUEL + "    " at (5,5).
	print "ALTITUDE:        " + round(ship:altitude) + "     " at (5,6).
	print "APOAPSIS:        " + round(ship:apoapsis) + "     " at (5,7).
	print "PERIAPSIS:       " + round(ship:periapsis) + "     " at (5,8).
	print "ETA TO AP:       " + round(ETA:APOAPSIS) + "     " at (5,9).
	
}