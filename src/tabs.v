module main

import iui as ui
import gg
import gx
import os

fn (mut app App) welcome_tab(folder string) {
	mut title_lbl := ui.label(app.win, 'V')
	mut title2 := ui.label(app.win, 'IDE')
	title_lbl.set_config(58, true, true)
	title2.set_config(42, true, false)

	mut info_lbl := ui.label(app.win,
		'Welcome to Vide!\nSimple IDE for the V Language made in V.\n\nVersion: ' + version +
		', UI version: ' + ui.version)
	info_lbl.set_config(0, false, true)

	padding_left := 28
	padding_top := 25

	mut vbox := ui.vbox(app.win)

	title_lbl.set_bounds(0, 0, 28, 50)
	title2.set_bounds(0, 11, 200, 50)
	info_lbl.set_pos(5, 4)
	info_lbl.pack()

	mut hbox := ui.hbox(app.win)

	hbox.add_child(title_lbl)
	hbox.add_child(title2)
	hbox.pack()

	vbox.add_child(hbox)
	vbox.add_child(info_lbl)

	vbox.pack()

	mut lbox := app.links_box()
	lbox.set_pos(50, 0)

	mut box := ui.hbox(app.win)
	box.set_pos(padding_left, padding_top)

	box.add_child(vbox)
	box.add_child(lbox)
	box.pack()

	app.tb.add_child('Welcome', box)
}

fn (mut app App) links_box() &ui.VBox {
	mut box := ui.vbox(app.win)

	mut title := ui.label(app.win, 'Useful Links:')
	title.set_config(4, false, false)
	title.pack()
	box.add_child(title)

	padding := ui.Bounds{
		x: 12
		y: 12
	}

	links := [
		'V Documentation|vlang.io/docs',
		'V stdlib docs|modules.vlang.io',
		'V on Github|github.com/vlang/v',
		'Vide on Github|github.com/isaiahpatton/vide',
		'Vide on Discord|discord.gg/NruVtYBf5g',
		'r/vlang|reddit.com/r/vlang',
	]

	for val in links {
		spl := val.split('|')
		link := ui.link(
			text: spl[0]
			url: 'https://' + spl[1]
			bounds: padding
			pack: true
		)
		box.add_child(link)
	}

	box.pack()
	return box
}

fn new_tab(mut window ui.Window, file string) {
	dump('opening ' + file)
	mut tb := &ui.Tabbox(window.get_from_id('main-tabs'))

	if file in tb.kids {
		// Don't remake already open tab
		tb.active_tab = file
		return
	}

	if file.ends_with('.png') {
		// Test
		// comp := make_image_view(file, mut window)
		// tb.add_child(file, comp)
		// tb.active_tab = file
		return
	}

	lines := os.read_lines(file) or { ['ERROR while reading file contents'] }

	mut code_box := ui.text_box(lines) // ui.textarea(window, lines)
	// mut code_box := ui.textarea(window, lines)

	// code_box.text_change_event_fn = codebox_text_change
	// code_box.after_draw_event_fn = on_text_area_draw
	// code_box.line_draw_event_fn = draw_code_suggest
	// code_box.active_line_draw_event = text_area_testing
	// code_box.hide_border = true
	// code_box.padding_x = 8
	// code_box.padding_y = 8
	code_box.set_bounds(0, 0, 620, 250)

	mut scroll_view := ui.scroll_view(
		bounds: ui.Bounds{0, 0, 620, 250}
		view: code_box
		increment: 16
		padding: 0
	)

	// scroll_view.after_draw_event_fn = on_runebox_draw
	scroll_view.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		mut tb := e.ctx.win.get[&ui.Tabbox]('main-tabs')
		e.target.width = tb.width
		e.target.height = tb.height - 30
	})

	code_box.subscribe_event('draw', fn [file] (mut e ui.DrawEvent) {
		mut tb := e.ctx.win.get[&ui.Tabbox]('main-tabs')
		mut cb := e.target

		if mut cb is ui.Textbox {
			e.target.width = tb.width
			hei := ui.get_line_height(e.ctx) * (cb.lines.len + 1)
			min := tb.height - 30
			if hei > min {
				cb.height = hei
			} else if cb.height < min {
				cb.height = min
			}
			
			// Do save
			if cb.ctrl_down && cb.last_letter == 's' {
				cb.ctrl_down = false
				os.write_file(file, cb.lines.join('\n')) or {}
				
				execute_syntax_check(file)
			}
		}
	})

	code_box.subscribe_event('current_line_draw', text_box_active_line_draw)

	tb.add_child(file, scroll_view)
	tb.active_tab = file
}

fn execute_syntax_check(file string) {
	vexe := get_v_exe()
	res := os.execute('${vexe} -check-syntax ${file}')
	dump(res)
}


fn code_textarea_draw_line_event(mut e ui.DrawTextlineEvent) {
	mut cb := e.target

	if mut cb is ui.TextArea {
		if cb.caret_top == e.line {
			dump(e.line)
		}
	}
}
