module main

import iui as ui
import gg

// Size components
fn on_runebox_draw(mut win ui.Window, mut tb ui.Component) {
	mut com := &ui.Tabbox(win.get_from_id('main-tabs'))

	x_off := com.x
	y_off := com.height - 31

	if tb.height != y_off {
		tb.height = y_off
	}
	width := gg.window_size().width - x_off - 5

	if tb.width != width {
		tb.width = width
	}
}

fn on_text_area_draw(mut win ui.Window, mut tb ui.Component) {
	mut com := &ui.Tabbox(win.get_from_id('main-tabs'))

	x_off := com.x
	y_off := com.height - 31

	if mut tb is ui.TextArea {
		line_height := ui.get_line_height(win.graphics_context)
		if tb.height != y_off {
			max_height := (tb.lines.len * line_height) + tb.padding_y
			if max_height > y_off {
				tb.height = max_height
			} else {
				tb.height = y_off
			}
		}
	}
	width := gg.window_size().width - x_off - 5 - 16 // 16 = Scrollbar width
	if tb.width != width {
		tb.width = width
	}
}

// Size components
fn on_draw(mut win ui.Window, mut tb ui.Component) {
	tree := &ui.Tree(win.get_from_id('proj-tree'))
	x_off := tree.x + tree.width + 4

	y_off := gg.window_size().height - 170

	if tb.height != y_off {
		tb.height = y_off
	}
	width := gg.window_size().width - x_off - 4

	if tb.width != width {
		tb.width = width
	}

	mut com := &ui.TextArea(win.get_from_id('consolebox'))
	com.x = x_off
	com.y = tb.y + tb.height + 4
	com.height = 128
	com.width = width
}
