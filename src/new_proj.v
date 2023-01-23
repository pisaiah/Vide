module main

import iui as ui

fn new_project_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'New Project')

	mut vbox := ui.vbox(win)

	create_input(mut win, mut vbox, 'Name', 25, 15)
	create_input(mut win, mut vbox, 'Description', 25, 65)
	create_input(mut win, mut vbox, 'Version', 25, 115)

	vbox.set_pos(25, 15)
	vbox.pack()
	modal.add_child(vbox)

	mut lic_lbl := ui.label(win, 'License')
	lic_lbl.set_bounds(250, 15, 300, 30)
	lic_lbl.pack()
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

	mut close := ui.button(text: 'Create')
	close.set_bounds(86, 255, 145, 25)

	mut can := ui.button(text: 'Cancel')
	can.set_bounds(20, 255, 60, 25)
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

		mut com := &ui.Tree2(win.get_from_id('proj-tree'))
		refresh_tree(mut win, dir, mut com)
	})

	modal.add_child(close)
	win.add_child(modal)
}

fn lic_change(mut win ui.Window, com ui.Select, old_val string, new_val string) {
	win.extra_map['np-lic'] = new_val
}

fn create_input(mut win ui.Window, mut vbox ui.VBox, title string, x int, y int) &ui.TextField {
	mut work_lbl := ui.label(win, '\n' + title)
	work_lbl.pack()
	vbox.add_child(work_lbl)

	mut work := ui.textfield(win, '')
	work.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = int(f64_max(200, ui.text_width(win, work.text) + work.text.len))
		work.height = ui.text_height(win, 'A{0|') + 8
	}

	work.set_id(mut win, 'NewProj-' + title)
	vbox.add_child(work)

	return work
}
