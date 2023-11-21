module main

import iui as ui
import gg

// Change the width of the project tree to correspond with the collapse state.
fn (mut app App) proj_tree_draw(mut e ui.DrawEvent) {
	if app.shown_activity != 0 {
		e.target.width = -1
		return
	}

	if app.collapse_tree {
		mx := app.win.mouse_x
		if mx < e.target.width || mx < e.target.x {
			if e.target.width < 250 {
				e.target.width += app.activty_speed
			}
			return
		}

		if e.target.width > app.activty_speed {
			e.target.width -= app.activty_speed
		}
		if e.target.width <= app.activty_speed {
			e.target.width = 0
		}
	} else {
		if e.target.width < 250 {
			e.target.width += app.activty_speed
		}
	}

	height := gg.window_size().height - 32

	if height > 0 {
		e.target.height = height
	}
}

// Change the width of the project tree to correspond with the collapse state.
fn (mut app App) search_pane_draw(mut e ui.DrawEvent) {
	if app.shown_activity != 1 {
		e.target.width = -1
		return
	}

	if app.collapse_search {
		mx := app.win.mouse_x
		if mx < e.target.width || mx < e.target.x {
			if e.target.width < 250 {
				e.target.width += app.activty_speed
			}
			return
		}

		if e.target.width > app.activty_speed {
			e.target.width -= app.activty_speed
		}
		if e.target.width <= app.activty_speed {
			e.target.width = 0
		}
	} else {
		if e.target.width < 250 {
			e.target.width += app.activty_speed
		}
	}

	height := gg.window_size().height - 32

	if height > 0 {
		e.target.height = height
	}
}

// Change the collapse state when the button is clicked
fn (mut app App) calb_click(mut e ui.MouseEvent) {
	if app.shown_activity != 0 {
		app.shown_activity = 0
		app.collapse_tree = false
	} else {
		app.collapse_tree = !app.collapse_tree
	}
}

// Change the collapse state when the button is clicked
fn (mut app App) serb_click(mut e ui.MouseEvent) {
	if app.shown_activity != 1 {
		app.shown_activity = 1
		app.collapse_search = false
	} else {
		app.collapse_search = !app.collapse_search
	}
}

// Set the width of the verminal's ScrollView to
// the width of the SplitView (aka the parent)
fn terminal_scrollview_fill(mut e ui.DrawEvent) {
	e.target.width = e.target.parent.width
}

// Set the width and height of the SplitView to fill the content area.
fn splitview_fill(mut e ui.DrawEvent) {
	size := e.ctx.gg.window_size()

	w := size.width - e.target.rx - 1
	h := size.height - 30

	if w < 0 || h < 0 {
		return
	}

	e.target.width = w
	e.target.height = h
}

// Have the main HBox's size be set to the window size
@[deprecated: 'Not needed with latest ui, as we use Panel now']
fn content_pane_fill_window(mut e ui.DrawEvent) {
}

// Have Tabbox take up the full width of the SplitView
fn tabbox_fill_width(mut e ui.DrawEvent) {
	size := e.ctx.gg.window_size()
	wid := size.width - e.target.x - 1
	if wid < 0 {
		return
	}
	e.target.width = wid
}
