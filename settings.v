module main

import iui as ui
import os
import math

fn settings_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'Settings')

	mut work_lbl := ui.label(win, 'Workspace Location')
	work_lbl.set_bounds(20, 10, 300, 30)
	work_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text + ' ') + 10
	}
	modal.add_child(work_lbl)

	mut conf := get_config(mut win)
	folder := conf.get_or_default('workspace_dir')
		.replace('{user_home}', os.home_dir().replace('\\', '/'))

	mut work := ui.textbox(win, folder)
	work.set_bounds(20, 40, 300, ui.text_height(win, 'A{'))
	work.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text + 'a b')
		work.height = ui.text_height(win, 'A{0|') + 8
	}
	work.text_change_event_fn = fn (mut win ui.Window, work ui.Textbox) {
		mut conf := get_config(mut win)
		conf.set('workspace_dir', work.text.replace(os.home_dir().replace('\\', '/'), '{user_home}'))
	}
	work.multiline = false
	modal.add_child(work)

	mut lib_lbl := ui.label(win, 'Path to VEXE')
	lib_lbl.set_bounds(20, 65, 300, 30)
	lib_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text + ' ') + 10
	}
	modal.add_child(lib_lbl)

	mut vlib := ui.textbox(win, get_v_exe(mut win))
	vlib.set_bounds(20, 90, 300, ui.text_height(win, 'A{'))
	vlib.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = math.max(200, ui.text_width(win, work.text + 'a b'))
		work.height = ui.text_height(win, 'A{0|') + 8
	}
	vlib.text_change_event_fn = fn (mut win ui.Window, work ui.Textbox) {
		mut conf := get_config(mut win)
		conf.set('v_exe', work.text.replace(os.home_dir().replace('\\', '/'), '{user_home}'))
	}
	vlib.multiline = false
	modal.add_child(vlib)

	mut flag_lbl := ui.label(win, 'Compiler Flags')
	flag_lbl.set_bounds(20, 130, 300, 30)
	flag_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		lbl.width = ui.text_width(win, lbl.text)
	}
	mut skip_unused := ui.checkbox(win, '-skip-unused')
	skip_unused.is_selected = conf.get_or_default('v_flags').contains('-skip-unused')
	skip_unused.set_bounds(20, 160, 300, 20)
	skip_unused.set_click(check_click)

	mut gc := ui.checkbox(win, '-gc boehm')
	gc.is_selected = conf.get_or_default('v_flags').contains('-gc boehm')
	gc.set_bounds(20, 185, 300, 20)
	gc.set_click(check_click)

	modal.add_child(flag_lbl)
	modal.add_child(skip_unused)
	modal.add_child(gc)

	fs_group(mut win, mut modal, 20,240)

	modal.needs_init = false
	mut close := ui.button(win, 'Save & Done')
	close.set_bounds(270 + 80, 258, 141, 25)

	mut can := ui.button(win, 'Cancel')
	can.set_bounds(265, 258, 80, 25)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.add_child(can)

	close.set_click(fn (mut win ui.Window, btn ui.Button) {
		mut conf := get_config(mut win)
		conf.save()
		win.components = win.components.filter(mut it !is ui.Modal)
	})

	modal.add_child(close)
	win.add_child(modal)
}

fn fs_group(mut win ui.Window, mut modal ui.Modal, x int, y int) {
	mut fs_lbl := ui.label(win, 'Font size:')
	fs_lbl.set_bounds(x - 8, y, 300, 20)
	fs_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		lbl.text = 'Font Size (' + win.font_size.str() + '):'
		lbl.width = ui.text_width(win, lbl.text)
	}

	mut fs_dec := ui.button(win, ' - ')
	fs_dec.set_click(fs_dec_click)
	fs_dec.set_bounds(x, y+20, 30, 20)
	fs_dec.pack()

	mut fs_inc := ui.button(win, ' + ')
	fs_inc.set_click(fs_inc_click)
	fs_inc.set_bounds(x+33, y+20, 30, 20)
	fs_inc.pack()

	modal.add_child(fs_lbl) 
	modal.add_child(fs_dec)
	modal.add_child(fs_inc)
}

fn check_click(mut win ui.Window, box ui.Checkbox) {
	mut conf := get_config(mut win)
	mut valu := conf.get_or_default('v_flags')
	if valu.contains(box.text) {
		valu = valu.replace(box.text, '')
	} else {
		valu = valu + " " + box.text
	}
	conf.set('v_flags', valu.trim_space())
}

fn fs_inc_click(mut win ui.Window, com ui.Button) {
	fs := win.font_size+1
	if fs > 20 {
		return
	}
	win.font_size = fs
	win.gg.set_cfg(size:fs)
}

fn fs_dec_click(mut win ui.Window, com ui.Button) {
	fs := win.font_size-1
	if fs < 10 {
		return
	}
	win.font_size = fs
	win.gg.set_cfg(size:fs)
}
