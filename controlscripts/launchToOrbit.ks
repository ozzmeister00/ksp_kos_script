// launchToOrbit.ks
// todo: launch into user-defined orbit and inclination
// todo: launch into a rendevous orbit with a target
// todo: dock with target

SAS OFF.
SET SASMODE TO "STABILITY".
RCS off.
lock throttle to 0.
gear off.

clearscreen.

set targetApoapsis to 100000.
set targetPeriapsis to 100000.

set gravityTurnStart to 500.
set gravityTurnEnd to 55000.

set updateHeading to true.

// safety
set runmode to 2.

// are we on the ground?
if ALT:RADAR < 50 {
    set runmode to 1.
	}
	
// declare a do-once for solid fuel jettison
when ship:solidfuel < 0.1 then {
	stage.
}
	
// main loop
until runmode = 0 {
	set updateHeading to true.
	set targetHeading to PROGRADE.
	
	// launch
	if runmode = 1 {
	
		set targetHeading to UP.
		set TVAL to 1.
		stage.
		set runmode to 2.
		
	}

	// go straight up until the start of the gravity turn
	else if runmode = 2 {

		set targetHeading to UP.
	
		set TVAL to 1.
		if SHIP:ALTITUDE > gravityTurnStart
		{
			set runmode to 3.
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
	
	// coast to apoapsis
	else if runmode = 4 { 
		set updateHeading to false.
		
		set TVAL to 0.
		// see if it's safe to warp
		if (SHIP:Altitude > 70000) and (ETA:APOAPSIS > 60) and (VERTICALSPEED > 0) {
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
	
	// add a new node with the target periapsis, then trigger executeNextManeuver to handle that node.
	else if runmode = 5 {
	
		set updateHeading to false.
		
		set tval to 0.
		
		// something is broken in here
		set ORBITBODY to SHIP:BODY.
		set deltaA to SHIP:MAXTHRUST/SHIP:MASS.
		set radiusAtAP to ORBITBODY:RADIUS + (targetApoapsis).
		set orbitalVelocity to ORBITBODY:RADIUS * sqrt(9.81/radiusAtAp).
		set apVelocity to sqrt(ORBITBODY:MU * ((2/radiusAtAp)-(1/SHIP:OBT:SEMIMAJORAXIS))).
		set deltaV to (orbitalVelocity - apVelocity).
		set timeToBurn to deltaV/deltaA.
		set circNode to node(TIME:SECONDS+ETA:APOAPSIS, 0, 0, deltaV).
		add circNode.
		
		set runMode to 0.
		
	}
	
	// Check for Staging
	list engines in engineList.
	for eng in engineList
		if eng:flameout{
			stage.
		}
	
	// stage if there's no liquid fuel left in the stage
	if STAGE:LIQUIDFUEL < 0.05{
		stage.
	}
		
	// TODO:
	// Debug draw lines for target heading and current heading
	
	if updateHeading = true{ lock STEERING to targetHeading. }
	else { set SASMODE to "STABILITY". }
	
	lock throttle to TVAL.
	
	print "RUNMODE:         " + runmode + "     " at (5,4).
	print "STAGE:LIQUIDFUEL " + STAGE:LIQUIDFUEL + "    " at (5,5).
	print "ALTITUDE:        " + round(ship:altitude) + "     " at (5,6).
	print "APOAPSIS:        " + round(ship:apoapsis) + "     " at (5,7).
	print "PERIAPSIS:       " + round(ship:periapsis) + "     " at (5,8).
	print "ETA TO AP:       " + round(ETA:APOAPSIS) + "     " at (5,9).
	print "TVAL:            " + round(tval, 3) + "       " at (5,10).
	
	wait 0.001.
}

// final cleanup

SAS off.
//clearscreen.

// execute the circularization burn.
runpath("ksp_kos_script\controlscripts\executeNextManeuver.ks").