// deorbitAnywhere.ks

// make sure we're in the right state
SAS OFF.
SET SASMODE TO "STABILITY".
RCS off.
lock throttle to 0.
gear off.

clearscreen.

// initalize basic variables
set targetPeriapsis to 28000.
set parachuteDeployAltitude to 10000.
set runmode to 10.
set updateHeading to true.
set TVAL to 0.

// main loop
until runmode = 0 {

	set targetHeading to RETROGRADE.

	// make sure we're in space
	if runmode = 10 {
		if SHIP:ALTITUDE > 70000 {
			set runmode to 1.
			print "Oh good, we're in space!".
		}
		else {
			set runmode to 0.
			print "You cannot run this program if you're not in space.".
		}
	}
	
	// warp to APOAPSIS, to get the most out of the deorbit burn
	if runmode = 1 {
		if WARP = 0 {
			wait 1.
			SET WARP TO 3.
		}
		
		if ETA:APOAPSIS < 60 {
			SET WARP TO 0.
			
			// point us the right way and wait a bit to get there.
			set SASMODE to "RETROGRADE".
			
			wait 10.
			
			set runmode to 2.
		}
	}
	
	// begin the deorbit burn
	else if runmode = 2 {
		set TVAL to 1.
		
		set targetHEADING to RETROGRADE.
		
		if SHIP:PERIAPSIS < targetPeriapsis
		{
			set runmode to 3.
		}
	}
	
	// prepare to drop the orbital stage
	else if runmode = 3 {
		// force update the throttle.
		set TVAL to 0.
		lock THROTTLE to TVAL.
		set updateHeading to false.
		set SASMODE to "RETROGRADE".
		
		// if we've already slowed down
		if TVAL = 0 {
			set runmode to 4.
		}
	}
	
	else if runmode = 4 {
		wait 5.
		stage.
		set runmode to 5.
	}
	
	// warp to atmosphere
	else if runmode = 5 {
		set updateHeading to true.
		
		if WARP = 0 {
			wait 1.
			SET WARP TO 3.
		}
		
		if SHIP:ALTITUDE < 72000 {
			SET WARP TO 0.
			
			// point us the right way and wait a bit to get there.
			set SASMODE to "RETROGRADE".
			
			wait 10.
			
			set runmode to 6.
		}
	}
	
	// maintain retrograde until the parachute deploy altitude
	else if runmode = 6 { 
		set updateHeading to false.
		set SASMODE to "STABILITY".
		
		if SHIP:ALTITUDE < parachuteDeployAltitude
		{
			stage.
			set runmode to 0.
		}
	}
	
	// TODO:
	// Debug draw lines for target heading and current heading
	
	clearscreen.
	
	if updateHeading = true { lock STEERING to targetHeading. print "Updating heading.".}
	lock throttle to TVAL.
	
	print "RUNMODE:         " + runmode + "     " at (5,4).
	print "ALTITUDE:        " + round(ship:altitude) + "     " at (5,6).
	print "APOAPSIS:        " + round(ship:apoapsis) + "     " at (5,7).
	print "PERIAPSIS:       " + round(ship:periapsis) + "     " at (5,8).
	print "ETA TO AP:       " + round(ETA:APOAPSIS) + "     " at (5,9).
	
	// cleanup
	if runmode = 0 {
		clearscreen.
		
		SAS off.
		Gear on.
		
		print "And now we coast gently back to the planet".
	
	}
	
}