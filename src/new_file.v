module main

import iui as ui
import os
// import extra

fn new_file_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'New File')

	mut des := nf_create_input(mut win, mut modal, 'File Name', 25, 80)
	des.set_text_change(fn (win voidptr, box voidptr) {
		mut wind := &ui.Window(win)
		wind.extra_map['nf-name'] = &ui.TextField(box).text
	})
	des.set_id(mut win, 'new-file-name-box')
	modal.add_child(des)

	mut lic_lbl := ui.label(win, 'Project')
	lic_lbl.set_bounds(25, 15, 500, 30)
	modal.add_child(lic_lbl)

	mut fold_lbl := ui.label(win, ' ')

	mut fold_btn := ui.button(text: 'Pick Directory')

	fold_btn.set_click_fn(fn (a voidptr, b voidptr, c voidptr) {
		mut win := &ui.Window(a)
		mut conf := get_config(win)
		dir := conf.get_value('workspace_dir').replace('\{user_home}', os.real_path(os.home_dir()))

		/*
		path_change_fn := file_picker_path_change

		picker_conf := extra.FilePickerConfig{
			in_modal: true
			path: dir
			path_change_fn: path_change_fn
		}

		extra.open_file_picker(mut win, picker_conf, c)*/
	}, fold_lbl)

	fold_btn.set_bounds(25, 44, 200, 25)
	fold_lbl.set_bounds(230, 44, 190, 25)

	modal.add_child(fold_btn)
	modal.add_child(fold_lbl)

	modal.needs_init = false

	mut close := ui.button(
		text: 'Create'
		bounds: ui.Bounds{100, 250, 200, 30}
	)

	mut can := ui.button(text: 'Cancel')
	can.set_bounds(20, 250, 75, 30)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.add_child(can)

	close.set_click(fn (mut win ui.Window, btn ui.Button) {
		name := win.extra_map['nf-name']
		pdir := win.extra_map['nf-dir']
		mut conf := get_config(win)
		dir := conf.get_value('workspace_dir').replace('\{user_home}', os.real_path(os.home_dir()))

		os.write_file(pdir + '/' + name, '') or {}

		win.components = win.components.filter(mut it !is ui.Modal)
		mut com := &ui.Tree2(win.get_from_id('proj-tree'))
		refresh_tree(mut win, dir, mut com)
	})

	modal.add_child(close)
	win.add_child(modal)
}

fn file_picker_path_change(a voidptr, b voidptr) {
	/*
	picker := &extra.FilePicker(a)

	mut lbl := &ui.Label(b)

	path := picker.get_dir()
	lbl.text = path
	lbl.app.extra_map['nf-dir'] = path

	file_name := picker.get_file_name()

	if file_name.len > 0 {
		if !os.exists(picker.get_full_path()) {
			lbl.app.extra_map['nf-name'] = file_name
			mut name_box := &ui.TextField(lbl.app.get_from_id('new-file-name-box'))
			name_box.text = file_name
		}
	}*/
}

fn nf_create_input(mut win ui.Window, mut modal ui.Modal, title string, x int, y int) &ui.TextField {
	mut work_lbl := ui.label(win, title)
	work_lbl.set_bounds(x, y, 300, 30)
	work_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text)
	}
	modal.add_child(work_lbl)

	mut work := ui.textfield(win, '')
	work.set_bounds(x, y + 30, 300, ui.text_height(win, 'A{'))
	work.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = int(f64_max(450, ui.text_width(win, work.text) + work.text.len))
		work.height = ui.text_height(win, 'A{0|') + 8
	}

	// work.multiline = false
	return work
}
