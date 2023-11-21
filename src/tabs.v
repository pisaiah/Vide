module main

import iui as ui
import os
import clipboard

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

	mut sw := ui.Titlebox.new(text: 'Start', children: [app.start_with()], padding: 4)
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
	btn.set_bounds(0, 0, 150, 30)
	btn.subscribe_event('mouse_up', fn [mut app] (mut e ui.MouseEvent) {
		app.new_project(mut e.ctx.win)
	})

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

	if file.ends_with('.vide_test') {
		// TODO
	}

	if file.ends_with('.png') {
		// Test
		p := image_view(file)
		tb.add_child(file, p)
		tb.active_tab = file
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
		e.target.height = tb.height - 26
	})

	code_box.subscribe_event('draw', code_box_draw)

	code_box.subscribe_event('current_line_draw', text_box_active_line_draw)

	code_box.before_txtc_event_fn = text_change

	tb.add_child(file, scroll_view)
	tb.active_tab = file
}

fn execute_syntax_check(file string) {
	vexe := get_v_exe()
	res := os.execute('${vexe} -check-syntax ${file}')
	dump(res)
}

fn image_view(path string) &ui.ScrollView {
	mut p := ui.Panel.new()

	mut im := ui.Image.new(file: path)
	p.add_child(im)

	return ui.ScrollView.new(
		view: p
	)
}

fn code_box_draw(mut e ui.DrawEvent) {
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

		// Copy
		if cb.ctrl_down && cb.last_letter == 'c' {
			cb.ctrl_down = false
			// dump(cb.sel)
		}

		// Paste
		if cb.ctrl_down && cb.last_letter == 'v' {
			do_paste(mut cb)
		}
	}
}

fn do_paste(mut cb ui.Textbox) {
	cb.ctrl_down = false
	mut c := clipboard.new()

	cl := cb.lines[cb.caret_y]
	be := cl[..cb.caret_x]
	af := cl[cb.caret_x..]

	plines := c.get_text().split_into_lines()

	if plines.len == 0 {
		c.destroy()
		return
	}

	if plines.len == 1 {
		cb.lines[cb.caret_y] = be + plines[0] + af
	} else {
		cb.lines[cb.caret_y] = be + plines[0]
		for i in 1 .. plines.len - 1 {
			cb.lines.insert(cb.caret_y + i, plines[i])
		}
		cb.lines.insert(cb.caret_y + (plines.len - 1), plines[plines.len - 1] + af)
		cb.caret_y = cb.caret_y + (plines.len - 1)
		cb.caret_x = plines[plines.len - 1].len
	}

	c.destroy()
}

fn text_change(mut w ui.Window, cb ui.Textbox) bool {
	if cb.last_letter == 'backspace' {
	}

	if cb.ctrl_down && cb.last_letter == 'c' {
		mut x0 := cb.sel.x0
		mut y0 := cb.sel.y0

		mut x1 := cb.sel.x1
		mut y1 := cb.sel.y1

		if y1 > cb.lines.len - 1 {
			y1 = cb.lines.len - 1
		}

		if y1 < y0 {
			sy := if y1 > y0 { y0 } else { y1 }
			ey := if y1 > y0 { y1 } else { y0 }
			y0 = sy
			y1 = ey
			sx := x1
			ex := x0
			x0 = sx
			x1 = ex
		}

		mut lines := []string{}

		fl := cb.lines[y0][x0..]
		el := cb.lines[y1][..x1]

		lines << fl
		for i in (y0 + 1) .. y1 {
			lines << cb.lines[i]
		}
		lines << el

		mut c := clipboard.new()
		c.copy(lines.join('\n'))
		c.destroy()

		return true
	}
	return false
}
