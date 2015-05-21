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