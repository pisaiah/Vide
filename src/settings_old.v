module main

import iui as ui

fn settings_click_old(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.page(win, 'Settings')

	mut tb := ui.tabbox(win)
	tb.closable = false

	settings_flags(win, mut tb)

	tb.draw_event_fn = fn (mut win ui.Window, mut com ui.Component) {
		ui.set_bounds(mut com, 70, 10, 1920, 1080)
	}

	modal.add_child(tb)
	win.add_child(modal)
}

fn settings_flags(win &ui.Window, mut tb ui.Tabbox) {
	mut flag_lbl := ui.label(win, 'Compiler Flags')
	flag_lbl.set_bounds(20, 20, 300, 30)

	mut vbox := ui.vbox(win)
	vbox.set_bounds(20, 50, 600, 600)
	vbox.pack()

	flags := ['-skip-unused', '-gc boehm', '-compress', '-cflags -static', '-prod']

	for flag in flags {
		flag_com := create_flag_check(win, flag)
		vbox.add_child(flag_com)
	}

	tb.add_child('Compiler', flag_lbl)
	tb.add_child('Compiler', vbox)
}

fn create_flag_check(win &ui.Window, text string) &ui.Checkbox {
	mut gc := ui.check_box(
		text: text
		bounds: ui.Bounds{0, 8, 100, 20}
	)
	gc.is_selected = config.get_value('v_flags').contains(text)
	gc.set_click(check_click)
	return gc
}

fn check_click(mut win ui.Window, box ui.Checkbox) {
	mut valu := config.get_value('v_flags')
	if valu.contains(box.text) {
		valu = valu.replace(box.text, '')
	} else {
		valu = valu + ' ' + box.text
	}
	config.set('v_flags', valu.trim_space())
}
