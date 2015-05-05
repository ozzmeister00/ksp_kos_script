SET countdown TO 10.
SET TURNSTARTALTITUDE TO 500.
SET TURNENDALTITUDE TO 36000.
SET TURNMIDALTITUDE TO 15000.

// ALTITUDE HEADING CONTROLS
WHEN SHIP:ALTITUDE > TURNSTARTALTITUDE THEN
{
    PRINT "STARTING GRAVITY TURN".
    LOCK STEERING TO HEADING(90, 5).
}

WHEN SHIP:ALTITUDE > TURNMIDALTITUDE THEN
{
    PRINT "MIDTURN".
    LOCK STEERING TO HEADING(90, 45).
}

WHEN SHIP:ALTITUDE > TURNENDALTITUDE THEN
{
     PRINT "FINISHING GRAVITY TURN".
    LOCK STEERING TO HEADING (90, 0).
}


PRINT "Counting Down:".
UNTIL countdown = 0 {
    Print "..." + countdown.
    SET countdown to countdown - 1.
    Wait 1.
}

PRINT "Main throttle to 100, 2 second launchpad hold.".

lock throttle to 1.0.
//lock steering to up.
SAS ON.
SET SASMODE TO "STABILITYASSIST".

wait 2.

// STAGING LOGIC

when stage:liquidfuel < 0.001 THEN {
    print "Staging".
    Stage.
    preserve.
}

WHEN STAGE:SOLIDFUEL < 0.001 THEN {
    PRINT "DROPPING SOLID BOOSTERS".
    STAGE.
}

wait until ship:altitude > 70000.