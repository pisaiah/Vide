module main

import iui as ui

fn (mut app App) new_project_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'New Project')

	modal.top_off = 10
	modal.in_height = 370

	mut ip := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1)
	)

	ip.add_child(create_input(mut win, 'Name', 'my project'))
	ip.add_child(create_input(mut win, 'Description', 'Hello world!'))
	ip.add_child(create_input(mut win, 'Version', '0.0.0'))

	ip.set_pos(25, 5)
	modal.add_child(ip)

	mut lic := make_license_section(win)

	lic_sv := ui.scroll_view(
		view: lic
		bounds: ui.Bounds{-5, 0, 210, 150}
		padding: 0
	)

	mut lic_tb := ui.title_box('License', [lic_sv])
	lic_tb.set_bounds(25, 125, 5, 25)
	modal.add_child(lic_tb)

	mut templ := make_templ_section(win)
	mut templ_tb := ui.title_box('Template', [templ])
	templ_tb.set_bounds(260, 125, 5, 25)
	modal.add_child(templ_tb)

	modal.needs_init = false

	mut close := ui.button(
		text: 'Create'
		bounds: ui.Bounds{114, 334, 160, 28}
	)

	mut can := ui.button(
		text: 'Cancel'
		bounds: ui.Bounds{10, 334, 100, 28}
	)
	can.set_area_filled(false)
	can.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.ctx.win.components = e.ctx.win.components.filter(mut it !is ui.Modal)
	})
	modal.add_child(can)

	win.extra_map['np-lic'] = 'MIT'
	win.extra_map['np-templ'] = 'hello_world'

	close.subscribe_event('mouse_up', app.new_project_click_close)

	modal.add_child(close)
	win.add_child(modal)
}

fn (mut app App) new_project_click_close(mut e ui.MouseEvent) {
	mut win := e.ctx.win
	name := win.get[&ui.TextField]('NewProj-Name').text
	des := win.get[&ui.TextField]('NewProj-Description').text
	ver := win.get[&ui.TextField]('NewProj-Version').text

	lic := win.extra_map['np-lic']
	dir := app.confg.workspace_dir
	templ := win.extra_map['np-templ']

	new_project(
		name: name
		description: des
		version: ver
		license: lic
		template: templ
		app: app
	)

	win.components = win.components.filter(mut it !is ui.Modal)

	mut com := win.get[&ui.Tree2]('proj-tree')
	refresh_tree(mut win, dir, mut com)
}

fn make_license_section(window &ui.Window) &ui.Panel {
	mut p := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1)
	)

	choices := ['MIT', 'Unlicense / CC0', 'GPL', 'Apache', 'Mozilla Public', 'All Rights Reserved']

	mut group := ui.buttongroup[ui.Checkbox]()
	for choice in choices {
		mut box := ui.check_box(text: choice)
		box.set_bounds(5, 4, 190, 30)
		box.subscribe_event('draw', checkbox_pack_height)

		group.add(box)
		p.add_child(box)
	}

	group.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.ctx.win.extra_map['np-lic'] = e.target.text
	})

	group.setup()
	return p
}

fn make_templ_section(window &ui.Window) &ui.Panel {
	mut hbox := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1)
	)

	choices := ['hello_world', 'web']

	mut group := ui.buttongroup[ui.Checkbox]()
	for choice in choices {
		mut box := ui.check_box(text: choice)
		box.set_bounds(0, 4, 190, 30)
		box.subscribe_event('draw', checkbox_pack_height)

		group.add(box)
		hbox.add_child(box)
	}

	group.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		e.ctx.win.extra_map['np-templ'] = e.target.text
	})

	group.setup()
	return hbox
}

fn checkbox_pack_height(mut e ui.DrawEvent) {
	e.target.height = e.ctx.line_height + 4
}

fn create_input(mut win ui.Window, title string, val string) &ui.Panel {
	mut box := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori: 0
			vgap: 1
		)
	)

	mut work_lbl := ui.Label.new(text: title)

	work_lbl.set_bounds(0, 0, 125, 30)
	box.add_child(work_lbl)

	mut work := ui.TextField.new(text: val)

	work.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		txt := e.target.text
		e.target.width = int(f64_max(200, e.ctx.text_width(txt) + txt.len))
		e.target.height = e.ctx.line_height + 8
	})

	work.set_id(mut win, 'NewProj-' + title)
	box.add_child(work)

	return box
}
