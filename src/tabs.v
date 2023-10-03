module main

import iui as ui
import gg
import gx
import os

fn (mut app App) welcome_tab(folder string) {
	mut logo := ui.image_from_bytes(mut app.win, vide_png1.to_bytes(), 229, 90)
	logo.set_bounds(-10, 0, 229, 90)

	mut info_lbl := ui.Label.new(
		text: 'Simple IDE for V made in V.'
	)
	info_lbl.set_config(0, false, true)

	padding_top := 5

	mut vbox := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1, vgap: 10)
	)

	info_lbl.set_pos(0, 0)
	info_lbl.pack()

	mut hbox := ui.Panel.new(
		layout: ui.BoxLayout.new(hgap: 0, vgap: 0)
	)

	hbox.add_child(logo)
	hbox.set_bounds(0, 0, 230, 51)

	vbox.add_child(hbox)
	vbox.add_child(info_lbl)

	mut sw := ui.Titlebox.new(text: 'Start', children: [app.start_with()])
	vbox.add_child(sw)

	mut lbox := app.links_box()
	lbox.set_pos(1, 0)

	mut box := ui.Panel.new(
		layout: ui.BorderLayout.new(hgap: 25)
	)
	box.set_bounds(0, padding_top, 550, 350)
	box.subscribe_event('draw', center_box)

	mut sbox := app.south_panel()

	box.add_child_with_flag(vbox, ui.borderlayout_center)
	box.add_child_with_flag(lbox, ui.borderlayout_east)
	box.add_child_with_flag(sbox, ui.borderlayout_south)

	mut sv := ui.ScrollView.new(
		view: box
	)

	app.tb.add_child('Welcome', sv)
}

fn center_box(mut e ui.DrawEvent) {
	pw := e.target.parent.width
	x := (pw / 2) - (e.target.width / 2)
	if pw > 550 {
		e.target.set_x(x / 2)
	}
}

fn (mut app App) start_with() &ui.Panel {
	mut p := ui.Panel.new(layout: ui.BoxLayout.new())

	mut btn := ui.Button.new(text: 'New Project')
	btn.set_bounds(0, 0, 150, 25)
	btn.subscribe_event('mouse_up', fn [mut app] (mut e ui.MouseEvent) {
		app.new_project(mut e.ctx.win)
	})

	p.set_bounds(0, 0, 160, 50)
	p.add_child(btn)
	return p
}

fn (mut app App) south_panel() &ui.Panel {
	mut p := ui.Panel.new()

	res := os.execute('${app.confg.vexe} version')

	mut out := res.output
	if !out.contains('V ') {
		out = 'Error executing "v version"\nPlease see Settings'
	}

	mut btn := ui.Label.new(text: 'Compiler: ${out}')
	btn.set_config(14, true, true)
	btn.pack()

	p.add_child(btn)
	return p
}

fn (mut app App) links_box() &ui.Panel {
	mut box := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1, vgap: 6)
	)

	mut title := ui.Label.new(text: 'Useful Links:')
	title.set_config(2, false, false)
	title.pack()
	box.add_child(title)

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
		mut link := ui.link(
			text: spl[0]
			url: 'https://' + spl[1]
		)
		link.set_bounds(4, 0, 150, 25)
		box.add_child(link)
	}

	mut vv := ui.Label.new(text: 'Vide™ ${version}\niUI ${ui.version}')
	vv.set_pos(0, 10)
	// vv.pack()
	vv.set_config(14, true, false)
	vv.set_bounds(5, 8, 150, 40)

	box.add_child(vv)
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

/*
fn code_textarea_draw_line_event(mut e ui.DrawTextlineEvent) {
	mut cb := e.target

	if mut cb is ui.TextArea {
		if cb.caret_top == e.line {
			dump(e.line)
		}
	}
}
*/
