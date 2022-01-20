module main

import iui as ui
import os

fn new_file_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'New Project')

	mut des := nf_create_input(mut win, mut modal, 'File Name', 25, 80)
	des.set_text_change(fn (mut win ui.Window, box ui.Textbox) {
		win.extra_map['nf-name'] = box.text
	})
	modal.add_child(des)

	mut lic_lbl := ui.label(win, 'Project')
	lic_lbl.set_bounds(25, 15, 500, 30)
	lic_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text)
	}
	modal.add_child(lic_lbl)

	mut lic := ui.selector(win, 'Project Directory')
	lic.set_bounds(25, 44, 450, 25)

	for mut child in win.components {
		if mut child is ui.Tree {
			for mut kid in child.childs {
				lic.items << kid.text
			}
		}
	}

	lic.set_change(pro_change)
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
		name := win.extra_map['nf-name']
		pdir := win.extra_map['nf-dir']
		mut conf := get_config(mut win)
		dir := conf.get_or_default('workspace_dir')
			.replace('{user_home}', os.home_dir().replace('\\', '/'))

		os.write_file(pdir + '/' + name, '') or {}

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

fn pro_change(mut win ui.Window, com ui.Select, old_val string, new_val string) {
	win.extra_map['nf-dir'] = new_val
}

fn nf_create_input(mut win ui.Window, mut modal ui.Modal, title string, x int, y int) &ui.Textbox {
	mut work_lbl := ui.label(win, title)
	work_lbl.set_bounds(x, y, 300, 30)
	work_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text)
	}
	modal.add_child(work_lbl)

	mut work := ui.textbox(win, '')
	work.set_bounds(x, y + 30, 300, ui.text_height(win, 'A{'))
	work.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = int(f64_max(450, ui.text_width(win, work.text) + work.text.len))
		work.height = ui.text_height(win, 'A{0|') + 8
	}

	work.multiline = false
	return work
}