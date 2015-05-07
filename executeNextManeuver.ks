// executeNextManeuver.ks
// executes the next maneuver starting at T-0:05
// some maths sourced from: http://ksp-kos.github.io/KOS_DOC/tutorials/exenode.html

// todo:
// make sure we're oriented properly BEFORE going to warp
// port the burn time updating code over to the launch script to get a better circularization burn
// pull the stat-printing code into a separate file so it can be called and extended 

// setup
SAS ON.
SET SASMODE TO "STABILITY".
RCS off.
lock throttle to 0.
gear off.

clearscreen.

// safety
set runmode to 100.

// are we in space?
if ALT:RADAR > 70000 {
    set runmode to 1.
	}
	
set X to NEXTNODE.
set TVAL to 0.
	
set MAXACC to SHIP:MAXTHRUST/SHIP:MASS.
	
set BURNDURATION to X:deltav:mag/MAXACC.
	
set TOLERANCE to 0.5.
	
// main loop
until runmode = 0 {
	set updateHeading to true.
	set targetHeading to X:BURNVECTOR:DIRECTION.

	// orient in direction of burn
	if runmode = 1 {
		set targetHeading to X:BURNVECTOR:DIRECTION.
		set runmode to 2.
	}
	
	// warp to burn
	else if runmode = 2 { 
		set updateHeading to false.
		
		set TVAL to 0.
		// see if it's safe to warp
		if (SHIP:Altitude > 70000) and (X:ETA > 120) {
			if WARP = 0 {
				wait 1.
				SET WARP TO 3.
			}
		}
		else if X:ETA < BURNDURATION/2 + 60 {
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
		if X:ETA < BURNDURATION/2 {
			set TVAL to 1.
		}
		
		set BURNDURATION to X:deltav:mag/MAXACC.
		
		// if the burn is over
		if X:BURNVECTOR:MAG < TOLERANCE {
			set TVAL to 0.
			set runmode to 0.
		}
		
	}	
	
	if updateHeading = true{ lock STEERING to targetHeading. }
	else { set SASMODE to "STABILITY". }
	
	lock throttle to TVAL.
	
	print "RUNMODE:         " + runmode + "     " at (5,4).
	print "STAGE:LIQUIDFUEL " + STAGE:LIQUIDFUEL + "    " at (5,5).
	print "ALTITUDE:        " + round(ship:altitude) + "     " at (5,6).
	print "APOAPSIS:        " + round(ship:apoapsis) + "     " at (5,7).
	print "PERIAPSIS:       " + round(ship:periapsis) + "     " at (5,8).
	print "============= Maneuver Node =============    " at (5,9).
	print "Node in:         " + round(X:ETA) + "    " at (5,10).
	print "DeltaV:          " + round(X:DeltaV:Mag) + "    " at (5, 11).
	print "Burn Duration:   " + round(BURNDURATION) + "    " at (5,12).
}

// final cleanup
unlock steering.
lock throttle to 0.
remove X.
clearscreen.
print "Burn complete".