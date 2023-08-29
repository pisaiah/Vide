module main

import iui as ui
import gg
import gx
import os

fn (mut app App) welcome_tab(folder string) {
	mut title_lbl := ui.Label.new(text: 'V')
	mut title2 := ui.Label.new(text: 'IDE')
	title_lbl.set_config(58, true, true)
	title2.set_config(42, true, false)

	mut info_lbl := ui.Label.new(
		text: 'Welcome to Vide!\nSimple IDE for the V Language made in V.\n\nVersion: ${version}, UI version: ${ui.version}'
	)
	info_lbl.set_config(0, false, true)

	padding_top := 25

	mut vbox := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori: 1
		)
	)

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

	mut lbox := app.links_box()
	lbox.set_pos(1, 0)

	mut box := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori: 0
			hgap: 25
		)
	)
	box.set_pos(0, padding_top)

	box.add_child(vbox)
	box.add_child(lbox)

	app.tb.add_child('Welcome', box)
}

fn (mut app App) links_box() &ui.Panel {
	mut box := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori: 1
		)
	)

	mut title := ui.Label.new(text: 'Useful Links:')
	title.set_config(2, false, false)
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

	return box
}

fn new_tab(window &ui.Window, file string) {
	dump('opening ' + file)
	mut tb := window.get[&ui.Tabbox]('main-tabs')

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

	mut code_box := ui.text_box(lines)
	code_box.text = file

	code_box.set_bounds(0, 0, 620, 250)

	mut scroll_view := ui.scroll_view(
		bounds: ui.Bounds{0, 0, 620, 250}
		view: code_box
		increment: 16
		padding: 0
	)

	scroll_view.set_border_painted(false)

	scroll_view.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		mut tb := e.ctx.win.get[&ui.Tabbox]('main-tabs')
		e.target.width = tb.width
		e.target.height = tb.height - 30
	})

	code_box.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		mut tb := e.ctx.win.get[&ui.Tabbox]('main-tabs')
		mut cb := e.target
		file := e.target.text

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
				write_file(file, cb.lines.join('\n')) or {}
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
