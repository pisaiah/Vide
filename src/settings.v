module main

import iui as ui
import os
import math
import os.font
import iui.extra.dialogs
import net.http

fn settings_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.page(win, 'Settings')

	// modal.top_off = 16
	// modal.in_width = 600
	// modal.in_height = 355
	mut tb := ui.tabbox(win)
	tb.closable = false

	mut vbox := ui.vbox(win)

	mut work_lbl := ui.label(win, 'Workspace Location')
	work_lbl.pack()

	mut conf := get_config(win)

	workd := os.real_path(conf.get_value('workspace_dir').replace('{user_home}', '~'))
	folder := os.expand_tilde_to_home(workd)

	mut work := ui.textfield(win, folder)
	mut dialog_btn := ui.button(win, 'Choose Folder')
	mut dialog_btn_ref := &dialog_btn

	work.draw_event_fn = fn [dialog_btn_ref] (mut win ui.Window, mut work ui.Component) {
		work.width = math.max(ui.text_width(win, work.text + 'a b'), 300)
		work.height = dialog_btn_ref.height // ui.text_height(win, 'A{0|') + 8
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
		work.width = math.max(250, ui.text_width(win, work.text + 'a b'))
		work.height = win.graphics_context.line_height + 10
	}
	vlib.text_change_event_fn = fn (win_ptr voidptr, box_ptr voidptr) {
		mut win := &ui.Window(win_ptr)
		work := &ui.TextField(box_ptr)

		mut conf := get_config(win)
		conf.set('v_exe', work.text.replace(os.home_dir().replace('\\', '/'), '~')) // '
	}

	work_lbl.set_bounds(0, 8, 0, 0)
	lib_lbl.set_bounds(0, 8, 0, 0)
	work.set_bounds(8, 0, 0, 0)
	vlib.set_bounds(8, 4, 0, 0)

	mut hbox := ui.hbox(win)
	hbox.set_pos(0, 4)
	hbox.pack()

	dialog_btn.set_click_fn(fn [mut work] (a voidptr, b voidptr, c voidptr) {
		val := dialogs.select_folder_dialog('Select Workspace Directory', work.text)
		if val.len > 0 && os.exists(val) {
			work.text = val

			mut win := &ui.Window(a)
			mut conf := get_config(win)
			conf.set('workspace_dir', work.text.replace(os.home_dir().replace('\\', '/'),
				'~')) // '
		}
	}, 0)
	dialog_btn.set_pos(4, 0)
	dialog_btn.pack()

	hbox.add_child(work)
	hbox.add_child(dialog_btn)

	vbox.set_bounds(16, 16, 0, 0)
	vbox.add_child(work_lbl)
	vbox.add_child(hbox)
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
	can.set_bounds(330, modal.in_height - 42, 85, 30)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Page)
	})
	modal.add_child(can)

	close.set_click(fn (mut win ui.Window, btn ui.Button) {
		mut conf := get_config(win)
		conf.save()
		win.components = win.components.filter(mut it !is ui.Page)
	})

	mut can_btn := &can
	mut close_btn := &close
	tb.draw_event_fn = fn [modal, mut tb, mut can_btn, mut close_btn] (win &ui.Window, mut com ui.Component) {
		tb.set_bounds(70, 10, modal.width - 140, modal.height - modal.top_off - 99)

		ctx := win.graphics_context
		tb.tab_height_active = ctx.line_height * 2
		tb.tab_height_inactive = ctx.line_height * 2
		tb.inactive_offset = -1
		tb.active_offset = -4

		btn_y := modal.height - 68 - modal.top_off
		btn_x := modal.width - 320

		can_btn.set_bounds(btn_x, btn_y, 85, 35)
		close_btn.set_bounds(btn_x + 99, btn_y, 165, 35)
	}

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

	font_lbl := ui.label(win, 'Main Font', ui.LabelConfig{
		x: 16
		y: 16
		should_pack: true
	})
	vbox.add_child(font_lbl)

	mut font_box := ui.selector(win, 'Font', ui.SelectConfig{
		bounds: ui.Bounds{16, 8, 250, 35}
		items: [
			'Default Font',
			'Anomaly Mono',
			'KARISMA_',
			'Agave-Regular',
			'JetBrainsMono-Regular',
			'System SegoeUI',
		]
	})
	font_box.set_change(sel_change)

	vbox.add_child(font_box)

	tb.add_child('Appearance', vbox)
}

// Downloads JetBrainsMono
fn download_jbm() {
	os.mkdir(os.resource_abs_path('assets')) or {}
	path := os.resource_abs_path('assets/JetBrainsMono-Regular.ttf')
	url := 'https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf'
	http.download_file(url, path) or { return }
}

fn sel_change(mut win ui.Window, com ui.Select, old_val string, new_val string) {
	mut path := os.resource_abs_path('assets/' + new_val.replace(' ', '-') + '.ttf')

	if new_val == 'JetBrainsMono-Regular' {
		exists := os.exists(path)
		if !exists {
			download_jbm()
		}
	}

	if new_val == 'Default Font' {
		path = font.default()
	}
	if new_val.starts_with('System ') {
		path = 'C:/windows/fonts/' + new_val.split('System ')[1].to_lower() + '.ttf'
	}

	font := win.add_font(new_val, path)
	win.graphics_context.font = font
	mut conf := get_config(win)
	conf.set('main_font', path)
}

fn make_tree_width_slider(win &ui.Window) (ui.Label, &ui.Slider) {
	mut tree_padding_lbl := ui.label(win, 'Project Tree Padding')
	tree_padding_lbl.set_bounds(16, 16, 300, 20)
	tree_padding_lbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		tree := &ui.Tree(win.get_from_id('proj-tree'))
		lbl.text = 'Project Tree Width ($tree.width):'
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

	mut font_slider := ui.slider(win, 0, 28, .hor)
	font_slider.set_bounds(16, 4, 200, 20)
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
	gc.is_selected = conf.get_value('v_flags').contains(text)
	gc.set_bounds(0, 8, 100, 20)
	gc.set_click(check_click)
	return gc
}

fn tree_padding_slider_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	mut tree := &ui.Tree(win.get_from_id('proj-tree'))
	this.y = win.font_size - 12
	this.height = win.font_size + 4
	if mut this is ui.Slider {
		fs := tree.width
		new_val := (int(this.cur) * 10) + 100
		if fs == new_val {
			return
		}
		tree.width = new_val
		win.graphics_context.set_cfg(size: new_val)
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

		mut conf := get_config(win)
		conf.set('font_size', new_val.str())

		this.y = new_val - 12
		this.height = new_val + 4

		win.font_size = new_val
		win.graphics_context.set_cfg(size: new_val)
	}
}

fn check_click(mut win ui.Window, box ui.Checkbox) {
	mut conf := get_config(win)
	mut valu := conf.get_value('v_flags')
	if valu.contains(box.text) {
		valu = valu.replace(box.text, '')
	} else {
		valu = valu + ' ' + box.text
	}
	conf.set('v_flags', valu.trim_space())
}
