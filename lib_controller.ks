// controller.ks
// Messing around with the idea of using action groups to toggle visual buttons
// that then affect code state
// max window extents 50x36

@LAZYGLOBAL off.

clearscreen.

// populate the list of button axises
// look up your button axis in this array
declare global agAxisMapping to list().
declare local i to 7.

until i < 0 {
	agAxisMapping:add(false).
	set i to i - 1.
}

on ag1 { set agAxisMapping[0] to not agAxisMapping[0]. preserve. }.
on ag2 { set agAxisMapping[1] to not agAxisMapping[1]. preserve. }.
on ag3 { set agAxisMapping[2] to not agAxisMapping[2]. preserve. }.
on ag4 { set agAxisMapping[3] to not agAxisMapping[3]. preserve. }.
on ag5 { set agAxisMapping[4] to not agAxisMapping[4]. preserve. }.
on ag6 { set agAxisMapping[5] to not agAxisMapping[5]. preserve. }.
on ag7 { set agAxisMapping[6] to not agAxisMapping[6]. preserve. }.
on ag8 { set agAxisMapping[7] to not agAxisMapping[7]. preserve. }.
on ag9 { set runmode to 0.}. // always have a way out

// make a list of button descriptions
declare global agButtonDescs to list().

set i to 7.
until i < 0 {
	agButtonDescs:add("     ").
	set i to i - 1.
}

declare local buttonActive to "*****".
declare local buttonInactive to "     ".

declare function displayActionBlock {
	// print out the static visuals
	print "_________________________________________________" at (0, 30).
	print "|  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |" at (0, 32).
	print "|     |     |     |     |     |     |     |     |" at (0, 33).
	print "|_____|_____|_____|_____|_____|_____|_____|_____|" at (0, 35).	
	
	// print out the status bar to line 31
	declare local i to 0.
	
	until i >= 47 {
		if mod(i, 6) = 0 {
			print "|" at (i, 31).
			if agAxisMapping[round(i/6)] > 0 {
				print buttonActive at (i+1, 31).
			}
			else {
				print buttonInactive at (i+1, 31).
			}
		}
		set i to i + 1.
	}
	print "|" at (48, 31).
	
	// print out the description bar to line 34
	set i to 0.
	
	until i >= 47 {
		if mod(i, 6) = 0 {
			print "|" at (i, 34).
			print agButtonDescs[round(i/6)] at (i+1, 34).
		}
		set i to i + 1.
	}
	
	print "|" at (48, 34).
	
}.

