module main

import iui as ui
import os
import math

fn settings_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'Settings')

	mut tb := ui.tabbox(win)
	tb.closable = false

	mut work_lbl := ui.label(win, 'Workspace Location')
	work_lbl.set_bounds(20, 10, 300, 30)
	work_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = ui.text_width(win, work.text + ' ') + 10
	}
	tb.add_child('General', work_lbl)

	mut conf := get_config(win)

	workd := os.real_path(conf.get_or_default('workspace_dir').replace('{user_home}',
		'~'))
	folder := os.expand_tilde_to_home(workd)

	mut work := ui.textfield(win, folder)
	work.set_bounds(20, 40, 300, ui.text_height(win, 'A{'))
	work.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = math.max(ui.text_width(win, work.text + 'a b'), 200)
		work.height = ui.text_height(win, 'A{0|') + 8
	}
	work.text_change_event_fn = fn (a voidptr, b voidptr) {
		mut conf := get_config(&ui.Window(a))
		work := &ui.TextField(b)
		conf.set('workspace_dir', work.text.replace(os.home_dir().replace('\\', '/'),
			'~')) // '
	}
	// work.multiline = false
	tb.add_child('General', work)

	mut lib_lbl := ui.label(win, 'Path to VEXE')
	lib_lbl.set_bounds(20, 65, 300, 30)
	lib_lbl.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		wid := ui.text_width(win, work.text + ' ') + 10
		work.width = math.max(200, wid)
	}
	tb.add_child('General', lib_lbl)

	home := os.home_dir().replace('\\', '/') // '
	mut vlib := ui.textfield(win, get_v_exe(win).replace(home, '~'))
	vlib.set_bounds(20, 90, 300, ui.text_height(win, 'A{'))
	vlib.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = math.max(200, ui.text_width(win, work.text + 'a b'))
		work.height = ui.text_height(win, 'A{0|') + 8
	}
	vlib.text_change_event_fn = fn (win_ptr voidptr, box_ptr voidptr) {
		mut win := &ui.Window(win_ptr)
		work := &ui.TextField(box_ptr)

		mut conf := get_config(win)
		conf.set('v_exe', work.text.replace(os.home_dir().replace('\\', '/'), '~')) // '
	}
	tb.add_child('General', vlib)

	settings_flags(mut win, mut modal, mut conf, tb)

	// 240
	fs_group(mut win, mut modal, 20, 150, tb)

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
		mut conf := get_config(win)
		conf.save()
		win.components = win.components.filter(mut it !is ui.Modal)
	})

	tb.set_bounds(10, 5, modal.in_width - 21, 245)

	modal.add_child(close)
	modal.add_child(tb)
	win.add_child(modal)
}

fn settings_flags(mut win ui.Window, mut modal ui.Modal, mut conf Config, tbp voidptr) {
	mut tb := &ui.Tabbox(tbp)
	println(tb.kids.len)

	mut flag_lbl := ui.label(win, 'Compiler Flags')
	flag_lbl.set_bounds(20, 20, 300, 30)
	flag_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		lbl.width = ui.text_width(win, lbl.text)
	}

	tb.add_child('Compiler', flag_lbl)

	mut skip_unused := create_flag_check(mut win, 20, 50, '-skip-unused', mut conf)
	mut gc := create_flag_check(mut win, 20, 75, '-gc boehm', mut conf)
	mut compress := create_flag_check(mut win, 20, 100, '-compress', mut conf)

	tb.add_child('Compiler', skip_unused)
	tb.add_child('Compiler', gc)
	tb.add_child('Compiler', compress)
}

fn create_flag_check(mut win ui.Window, x int, y int, text string, mut conf Config) ui.Checkbox {
	mut gc := ui.checkbox(win, text)
	gc.is_selected = conf.get_or_default('v_flags').contains(text)
	gc.set_bounds(x, y, 100, 20)
	gc.set_click(check_click)
	return gc
}

fn fs_group(mut win ui.Window, mut modal ui.Modal, x int, y int, tbp voidptr) {
	mut tb := &ui.Tabbox(tbp)
	mut fs_lbl := ui.label(win, 'Font size:')
	fs_lbl.set_bounds(x - 8, y, 300, 20)
	fs_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		lbl.text = 'Font Size (' + win.font_size.str() + '):'
		lbl.width = ui.text_width(win, lbl.text)
	}

	mut fs_dec := ui.button(win, ' - ')
	fs_dec.set_click(fs_dec_click)
	fs_dec.set_bounds(x, y + 20, 30, 20)
	fs_dec.pack()

	mut fs_inc := ui.button(win, ' + ')
	fs_inc.set_click(fs_inc_click)
	fs_inc.set_bounds(x + 33, y + 20, 30, 20)
	fs_inc.pack()

	tb.add_child('General', fs_lbl)
	tb.add_child('General', fs_dec)
	tb.add_child('General', fs_inc)
}

fn check_click(mut win ui.Window, box ui.Checkbox) {
	mut conf := get_config(win)
	mut valu := conf.get_or_default('v_flags')
	if valu.contains(box.text) {
		valu = valu.replace(box.text, '')
	} else {
		valu = valu + ' ' + box.text
	}
	conf.set('v_flags', valu.trim_space())
}

fn fs_inc_click(mut win ui.Window, com ui.Button) {
	fs := win.font_size + 1
	if fs > 24 {
		return
	}
	win.font_size = fs
	win.gg.set_cfg(size: fs)
}

fn fs_dec_click(mut win ui.Window, com ui.Button) {
	fs := win.font_size - 1
	if fs < 8 {
		return
	}
	win.font_size = fs
	win.gg.set_cfg(size: fs)
}
