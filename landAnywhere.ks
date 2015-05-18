// landAnywhere.ks
// Used for landing on a non-atmo body

// parameters
set targetOrbit to 30000. // the orbit from which to start the descent burn

// initialization
SAS ON.
SET SASMODE TO "STABILITY".
RCS off.
lock throttle to 0.
gear on.

clearscreen.

set updateHeading to true.
set targetHeading to RETROGRADE.

set ORBITBODY to SHIP:BODY.
set MAXACC to SHIP:MAXTHRUST/SHIP:MASS.

// safety checks
set runmode to 100.
	
if SHIP:STATUS != "LANDED" {
	set runmoe to 1.
}
	
// main loop
until runmode = 0 {
	set updateHeading to true.
	set targetHeading to RETROGRADE.

	if runmode = 1 {
		
	}
	else if runmode = 2 {
		
	}
	
	
	
	
	// coasting phase
	else if runmode = 4 { 
		set updateHeading to false.
		
		set tval to 0.
		// see if it's safe to warp
		if 0 = 1 {
			if WARP = 0 {
				wait 1.
				SET WARP TO 3.
			}
		}
		else if ETA:APOAPSIS < 120 {
			SET WARP TO 0.
			set runmode to 5.
		}
		
	}
	
	if updateHeading = true { lock STEERING to targetHeading. }
	else { set SASMODE to "STABILITY". }
	
	lock throttle to tval.
	
	// status prinouts
	print "RUNMODE:         " + runmode + "     " at (5,4).
	print "STAGE:LIQUIDFUEL " + STAGE:LIQUIDFUEL + "    " at (5,5).
	print "ALTITUDE:        " + round(ship:altitude) + "     " at (5,6).
	print "APOAPSIS:        " + round(ship:apoapsis) + "     " at (5,7).
	print "PERIAPSIS:       " + round(ship:periapsis) + "     " at (5,8).
	
}

// final cleanup

SAS off.
clearscreen.