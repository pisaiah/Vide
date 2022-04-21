module main

import iui as ui
import os
import math

fn settings_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'Settings')
	dump(modal.in_height)
	modal.in_width = 600
	modal.in_height = 320

	mut tb := ui.tabbox(win)
	tb.closable = false

	mut vbox := ui.vbox(win)

	mut work_lbl := ui.label(win, 'Workspace Location')
	work_lbl.pack()

	mut conf := get_config(win)

	workd := os.real_path(conf.get_or_default('workspace_dir').replace('{user_home}',
		'~'))
	folder := os.expand_tilde_to_home(workd)

	mut work := ui.textfield(win, folder)

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

	mut lib_lbl := ui.label(win, 'Path to VEXE')
	lib_lbl.pack()

	home := os.home_dir().replace('\\', '/') // '
	mut vlib := ui.textfield(win, get_v_exe(win).replace(home, '~'))

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

	work_lbl.set_bounds(0, 8, 0, 0)
	lib_lbl.set_bounds(0, 8, 0, 0)
	work.set_bounds(8, 4, 0, 0)
	vlib.set_bounds(8, 4, 0, 0)

	vbox.set_bounds(16, 16, 0, 0)
	vbox.add_child(work_lbl)
	vbox.add_child(work)
	vbox.add_child(lib_lbl)
	vbox.add_child(vlib)

	tb.add_child('General', vbox)

	settings_flags(win, mut conf, tb)
	appearance_tab(win, mut conf, tb)

	// fs_group(win, 20, 170, tb)

	modal.needs_init = false
	mut close := ui.button(win, 'Save & Done')
	close.set_bounds(425, modal.in_height - 42, 160, 30)

	mut can := ui.button(win, 'Cancel')
	can.set_bounds(334, modal.in_height - 42, 85, 30)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Modal)
	})
	modal.add_child(can)

	close.set_click(fn (mut win ui.Window, btn ui.Button) {
		mut conf := get_config(win)
		conf.save()
		win.components = win.components.filter(mut it !is ui.Modal)
	})

	tb.set_bounds(10, 5, modal.in_width - 21, modal.in_height - 55)

	modal.add_child(close)
	modal.add_child(tb)
	win.add_child(modal)
}

fn appearance_tab(win &ui.Window, mut conf Config, tbp voidptr) {
	mut tb := &ui.Tabbox(tbp)

	mut vbox := ui.vbox(win)

	fs_lbl, font_slider := make_font_slider(win)
	tree_padding_lbl, tree_padding_slider := make_tree_width_slider(win)

	vbox.add_child(fs_lbl)
	vbox.add_child(font_slider)
	vbox.add_child(tree_padding_lbl)
	vbox.add_child(tree_padding_slider)
	tb.add_child('Appearance', vbox)
}

fn make_tree_width_slider(win &ui.Window) (ui.Label, &ui.Slider) {
	mut tree_padding_lbl := ui.label(win, 'Project Tree Padding')
	tree_padding_lbl.set_bounds(16, 16, 300, 20)
	tree_padding_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		tree := &ui.Tree(win.get_from_id('proj-tree'))
		lbl.text = 'Project Tree Width (' + tree.width.str() + '):'
		lbl.width = ui.text_width(win, lbl.text)
	}

	mut tree_padding_slider := ui.slider(win, 0, 30, .hor)
	tree_padding_slider.set_bounds(16, 4, 100, 20)
	tree := &ui.Tree(win.get_from_id('proj-tree'))
	tree_padding_slider.cur = (tree.width - 100) / 10
	tree_padding_slider.draw_event_fn = tree_padding_slider_draw
	return tree_padding_lbl, tree_padding_slider
}

fn make_font_slider(win &ui.Window) (ui.Label, &ui.Slider) {
	mut fs_lbl := ui.label(win, 'Font size:')
	fs_lbl.set_bounds(16, 16, 300, 20)
	fs_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		lbl.text = 'Font Size (' + win.font_size.str() + '):'
		lbl.width = ui.text_width(win, lbl.text)
	}

	mut font_slider := ui.slider(win, 0, 14, .hor)
	font_slider.set_bounds(16, 4, 100, 20)
	font_slider.cur = win.font_size - 10
	font_slider.draw_event_fn = font_slider_draw
	return fs_lbl, font_slider
}

fn settings_flags(win &ui.Window, mut conf Config, tbp voidptr) {
	mut tb := &ui.Tabbox(tbp)

	mut flag_lbl := ui.label(win, 'Compiler Flags')
	flag_lbl.set_bounds(20, 20, 300, 30)
	flag_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		lbl.width = ui.text_width(win, lbl.text)
	}

	tb.add_child('Compiler', flag_lbl)

	mut vbox := ui.vbox(win)
	vbox.set_bounds(20, 50, 600, 600)
	vbox.pack()

	flags := ['-skip-unused', '-gc boehm', '-compress', '-cflags -static', '-prod']

	for flag in flags {
		flag_com := create_flag_check(win, flag, mut conf)
		vbox.add_child(flag_com)
	}

	tb.add_child('Compiler', vbox)
}

fn create_flag_check(win &ui.Window, text string, mut conf Config) ui.Checkbox {
	mut gc := ui.checkbox(win, text)
	gc.is_selected = conf.get_or_default('v_flags').contains(text)
	gc.set_bounds(0, 8, 100, 20)
	gc.set_click(check_click)
	return gc
}

fn fs_group(win &ui.Window, x int, y int, tbp voidptr) {
	mut tb := &ui.Tabbox(tbp)
	mut fs_lbl := ui.label(win, 'Font size:')
	fs_lbl.set_bounds(x - 8, y, 300, 20)
	fs_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		lbl.text = 'Font Size (' + win.font_size.str() + '):'
		lbl.width = ui.text_width(win, lbl.text)
	}

	mut font_slider := ui.slider(win, 0, 14, .hor)
	font_slider.set_bounds(x, y + 20, 100, 20)
	font_slider.cur = win.font_size - 10
	font_slider.draw_event_fn = font_slider_draw

	tb.add_child('General', fs_lbl)
	tb.add_child('General', font_slider)
}

fn tree_padding_slider_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	mut tree := &ui.Tree(win.get_from_id('proj-tree'))
	if mut this is ui.Slider {
		fs := tree.width
		new_val := (int(this.cur) * 10) + 100
		if fs == new_val {
			return
		}
		tree.width = new_val
		win.gg.set_cfg(size: new_val)
	}
}

fn font_slider_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	if mut this is ui.Slider {
		fs := win.font_size
		new_val := int(this.cur) + 10
		if fs == new_val {
			return
		}
		win.font_size = new_val
		win.gg.set_cfg(size: new_val)
	}
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
