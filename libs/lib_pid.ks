// lib_pid.ks
// generic pid controller routine to be used by other scripts.
// this controller operates without being aware of the path to perform the i or d ops
// instead, you just keep updating it with the position information and it dervices them from it as it goes

// compiler directive!
// means you have to declare shit
@LAZYGLOBAL off.

// make a list of pid tuning parameters, Kp, Ki, Kd.
declare function pid_init {
	declare parameter // function parameters!
		Kp, // position gain
		Ki, // gain of intengral
		Kd. // gain of derivative
	
	// declare var name to value creates a local variable!
	declare local SeekP to 0.
	declare local P to 0.	// Phenomenon P being affected
	declare local I to 0. // Crudely approximate Integral of P.
	declare local D to 0. // Crudely approximate derivative of P
	
	declare local oldT to -1. // time at previous run
	declare local oldInput to 0. // previous return value
	
	// pid value list
	declare local pidArray to list().
	pidArray:add(Kp).
	pidArray:add(Ki).
	pidArray:add(Kd).
	pidArray:add(SeekP).
	pidArray:add(P).
	pidArray:add(I).
	pidArray:add(D).
	pidArray:add(oldT).
	pidArray:add(oldInput).
	
	return pidArray.
}.

// very dumb pid controller that just figures out what input you need to set to get from your current
// value to your seek value based on time
declare function pid_seek {
	declare parameter
		pidArray, // the array from pid_init
		seekVal, // value we want
		curVal. // value we currently have
		
	declare local Kp to pidArray[0].
	declare local Ki to pidArray[1].
	declare local Kd to pidArray[2].
	declare local oldS to pidArray[3].
	declare local oldP to pidArray[4].
	declare local oldI to pidArray[5].
	declare local oldD to pidArray[6].
	declare local oldT to pidArray[7].
	declare local oldInput to pidArray[8].
	
	declare local P to seekVal - curVal.
	declare local I to 0.
	declare local D to 0.
	declare local newInput to oldInput.
	
	declare local t to time:seconds.
	declare local dT to t - oldT.
	
	if oldT < 0 {
	}
	else {
		if dT = 0 {
			set newInput to oldInput.
		}
		else {
			set I to (oldI + P)*dT. // fake integral of P
			set D to (P - oldP)/dT. // fake derivative to P
			set newInput to Kp*P + Ki*I + Kd*D.
		}
	}
	
	set pidArray[3] to seekVal.
	set pidArray[4] to P.
	set pidArray[5] to I.
	set pidArray[6] to D.
	set pidArray[7] to t.
	set pidArray[8] to newInput.
	
	return newInput.
}.