module main

import iui as ui
import gg

// Size components
fn on_runebox_draw(mut win ui.Window, mut tb ui.Component) {
	mut x_off := 0
	mut y_off := 0
	for mut com in win.components {
		if mut com is ui.Tabbox {
			x_off = com.x
			y_off = com.height - 28
			break
		}
	}
	if tb.height != y_off {
		tb.height = y_off
	}
	width := gg.window_size().width - x_off - 8

	if tb.width != width {
		tb.width = width
	}
}

// Size components
fn on_draw(mut win ui.Window, mut tb ui.Component) {
	mut tree := &ui.Tree(win.get_from_id('proj-tree'))
	x_off := tree.x + tree.width
	y_off := gg.window_size().height - tree.y - 123

	if tb.x != x_off {
		tb.x = x_off
	}

	if tb.height != y_off {
		tb.height = y_off - 4
	}
	width := gg.window_size().width - x_off - 4

	if tb.width != width {
		tb.width = width
	}

	mut com := &ui.TextArea(win.get_from_id('consolebox'))
	com.x = x_off
	com.y = y_off + 32
	com.height = 110
	com.width = width
}
