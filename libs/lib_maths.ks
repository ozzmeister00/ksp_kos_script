// lib_maths.ks
// contains helpful maths functions

@LAZYGLOBAL off.

declare function lerp {
	declare parameter
		a,
		b,
		c.
		
	return a + c*(b - a).
}

declare function getSteeringError {
	declare parameter seek.
		
	declare local targetPitchVec to V(0,0,0).
	declare local targetYawVec to V(0,0,0).
	declare local rErr to V(0,0,0).
	declare local yawerr to V(0,0,0).
	declare local pitcherr to V(0,0,0).
	declare local sign to 1.
		
	set targetPitchVec to vxcl(ship:facing:rightvector, seek:forevector):normalized.
	set targetYawVec to vxcl(ship:facing:upvector, seek:forevector):normalized.
	
	set rErr to V(0,0,0).
	set yawerr to ship:facing:upvector * vcrs(targetYawVec, ship:facing:forevector).
	set yawerr to arcsin(yawerr).
	
	if ship:facing:forevector * targetYawVec < 0
	{
		set sign to yawerr / abs(yawerr).
		set yawerr to sign*180 - yawerr.
	}
	
	set rErr:X to yawerr.

	set pitcherr to ship:facing:rightvector * vcrs(ship:facing:forevector, targetPitchVec).
	set pitcherr to arcsin(pitcherr).
	
	if ship:facing:forevector * targetPitchVec < 0
	{
		set sign to pitcherr/abs(pitcherr).
		set pitcherr to sign*180 - pitcherr.
	}
	
	set rErr:y to pitcherr.
	
	return rErr.
}