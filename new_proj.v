module main

import iui as ui

fn new_project_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'New Project')

	name := create_input(mut win, mut modal, 'Name', 25, 15)
	des := create_input(mut win, mut modal, 'Description', 25, 65)
	ver := create_input(mut win, mut modal, 'Version', 25, 115)

	modal.add_child(name)
	modal.add_child(des)
	modal.add_child(ver)

	mut lic_lbl := ui.label(win, 'License')
	lic_lbl.set_bounds(250, 15, 300, 30)
	lic_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text)
	}
	modal.add_child(lic_lbl)

	mut lic := ui.selector(win, 'Choose a License')
	lic.set_bounds(250, 44, 200, 25)

	lic.items << 'Unlicense / CC0'
	lic.items << 'MIT / Boost'
	lic.items << 'GNU GPL v2 or later'
	lic.items << 'Apache License 2.0'
	lic.items << 'Mozilla Public License'
	lic.items << 'All Rights Reserved'
	lic.set_change(lic_change)
	modal.add_child(lic)

	modal.needs_init = false

	mut close := ui.button(win, 'Create')
	close.x = 25 + 50
	close.y = (300) - 45
	close.width = 145
	close.height = 25

	mut can := ui.button(win, 'Cancel')
	can.set_bounds(20, (300 - 45), 50, 25)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.add_child(can)

	close.set_click(fn (mut win ui.Window, btn ui.Button) {
		name := &ui.TextField(win.get_from_id('NewProj-Name')).text
		des := &ui.TextField(win.get_from_id('NewProj-Description')).text
		ver := &ui.TextField(win.get_from_id('NewProj-Version')).text

		lic := win.extra_map['np-lic']
		dir := win.extra_map['workspace']

		args := [name, des, ver, lic]
		create_v(dir, args)

		win.components = win.components.filter(mut it !is ui.Modal)
		for mut com in win.components {
			if mut com is ui.Tree {
				refresh_tree(mut win, dir, mut com)
			}
		}
	})

	modal.add_child(close)
	win.add_child(modal)
}

fn lic_change(mut win ui.Window, com ui.Select, old_val string, new_val string) {
	win.extra_map['np-lic'] = new_val
}

fn create_input(mut win ui.Window, mut modal ui.Modal, title string, x int, y int) &ui.TextField {
	mut work_lbl := ui.label(win, title)
	work_lbl.set_bounds(x, y, 300, 30)
	work_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text)
	}
	modal.add_child(work_lbl)

	mut work := ui.textfield(win, '')
	work.set_bounds(x, y + 30, 300, ui.text_height(win, 'A{'))
	work.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = int(f64_max(200, ui.text_width(win, work.text) + work.text.len))
		work.height = ui.text_height(win, 'A{0|') + 8
	}

	work.set_id(mut win, 'NewProj-' + title)

	return work
}
