module main

import iui as ui
import gg

// Size components
fn on_box_draw(mut win ui.Window, mut tb ui.Component) {
	mut x_off := 0
	mut y_off := 0
	mut ty := 0
	for mut com in win.components {
		if mut com is ui.Tabbox {
			x_off = com.x
			y_off = com.height - 28
			ty = com.y
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

	if mut tb is ui.Textbox {
		on_box_draw_1(mut win, mut tb, x_off, ty)
	}
}

// Size components
fn on_draw(mut win ui.Window, mut tb ui.Component) {
	mut x_off := 0
	mut y_off := 0
	for mut com in win.components {
		if mut com is ui.Tree {
			x_off = com.x + com.width
			y_off = gg.window_size().height - com.y - 20
			break
		}
	}
	if tb.x != x_off {
		tb.x = x_off
	}
	y_off -= 100
	if tb.height != y_off {
		tb.height = y_off - 4
	}
	width := gg.window_size().width - x_off - 4

	if tb.width != width {
		tb.width = width
	}
	for mut com in win.components {
		if mut com is ui.Textbox {
			com.x = x_off
			com.y = y_off + 32
			com.height = 110
			com.width = width
		}
	}
}
