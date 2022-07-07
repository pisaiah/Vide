// Console Hider - Public Domain
module hc

pub fn hide_console() {
	$if windows {
		hide_console_win()
	} $else {
		// Nope
	}
}
