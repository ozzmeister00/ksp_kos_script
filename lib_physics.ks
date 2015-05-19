// lib_physics.ks
// some basic physics functions

@LAZYGLOBAL off.

declare function g_here {
	return constant():G * ((ship:body:mass)/((ship:altitude + body:radius)^2)).
}

declare function Fg_here {
	return ship:mass*g_here().
}