module main

import iui as ui
import os
import math
import os.font
import gg
// import iui.extra.dialogs
// import net.http

fn settings_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.page(win, 'Settings')

	// modal.top_off = 16
	// modal.in_width = 600
	// modal.in_height = 355
	// mut tb := ui.tabbox(win)
	// tb.closable = false

	mut vbox := ui.vbox(win)

	mut lbl := title_label(win, 'General')
	vbox.add_child(lbl)

	vbox.set_bounds(16, 16, 0, 0)

	modal.needs_init = false
	mut close := ui.button(win, 'Save & Done')
	close.set_bounds(130, 7, 250, 30)

	mut can := ui.button(win, 'Cancel')
	can.set_bounds(21, 7, 100, 30)
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

	vbox.draw_event_fn = fn (win &ui.Window, mut com ui.Component) {
		size := win.gg.window_size()
		x_pos := (size.width / 3) - (com.width / 2)
		ui.set_pos(mut com, x_pos, 24)
	}

	mut conf := get_config(win)

	general_section(win, mut conf, mut vbox)
	appearance_section(win, mut conf, mut vbox)

	// Spacer
	spacer := title_label(win, '  ')
	vbox.add_child(spacer)

	mut sv := ui.scroll_view(
		view: vbox
	)

	sv.draw_event_fn = fn (win &ui.Window, mut com ui.Component) {
		size := win.gg.window_size()
		ui.set_bounds(mut com, 20, 54, size.width - 40, size.height - 155)
	}

	modal.add_child(close)
	modal.add_child(sv)
	win.add_child(modal)
}

fn title_label(win &ui.Window, text string) &ui.Label {
	mut lbl := ui.label(win, text)
	lbl.pack()
	lbl.set_pos(0, 16)
	lbl.set_config(16, false, true)
	return &lbl
}

fn general_section(win &ui.Window, mut conf Config, mut vbox ui.VBox) {
	mut work_lbl := ui.label(win, 'Workspace Location')
	work_lbl.pack()

	workd := os.real_path(conf.get_value('workspace_dir').replace('{user_home}', '~'))
	folder := os.expand_tilde_to_home(workd)

	mut work := ui.textfield(win, folder)
	mut dialog_btn := ui.button(win, 'Choose Folder')
	mut dialog_btn_ref := &dialog_btn

	work.draw_event_fn = fn [dialog_btn_ref] (mut win ui.Window, mut work ui.Component) {
		work.width = math.max(ui.text_width(win, work.text + 'a b'), 300)
		work.height = win.graphics_context.line_height + 8
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

	work_lbl.set_bounds(32, 8, 0, 0)
	lib_lbl.set_bounds(32, 8, 0, 0)
	work.set_bounds(32, 0, 0, 0)
	vlib.set_bounds(32, 4, 0, 0)

	mut hbox := ui.hbox(win)
	hbox.set_pos(0, 4)
	hbox.pack()

	/*
	dialog_btn.set_click_fn(fn (a voidptr, b voidptr, c voidptr) {
		mut work := &ui.TextField(c)
		val := dialogs.select_folder_dialog('Select Workspace Directory', work.text)
		if val.len > 0 && os.exists(val) {
			work.text = val

			mut win := &ui.Window(a)
			mut conf := get_config(win)
			conf.set('workspace_dir', work.text.replace(os.home_dir().replace('\\', '/'),
				'~')) // '
		}
	}, work)*/
	dialog_btn.set_pos(4, 0)
	dialog_btn.pack()

	hbox.add_child(work)
	hbox.add_child(dialog_btn)

	vbox.add_child(work_lbl)
	vbox.add_child(hbox)
	vbox.add_child(lib_lbl)
	vbox.add_child(vlib)
}

fn appearance_section(win &ui.Window, mut conf Config, mut vbox ui.VBox) {
	// mut vbox := ui.vbox(win)

	mut lbl := title_label(win, 'Appearance')
	vbox.add_child(lbl)

	fs_lbl, font_slider := make_font_slider(win)
	tree_padding_lbl, tree_padding_slider := make_tree_width_slider(win)

	vbox.add_child(fs_lbl)
	vbox.add_child(font_slider)
	vbox.add_child(tree_padding_lbl)
	vbox.add_child(tree_padding_slider)

	font_lbl := ui.label(win, 'Main Font', ui.LabelConfig{
		x: 32
		y: 16
		should_pack: true
	})
	vbox.add_child(font_lbl)

	mut font_box := ui.selector(win, 'Font', ui.SelectConfig{
		bounds: ui.Bounds{32, 8, 250, 35}
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

	// tb.add_child('Appearance', vbox)
}

// Downloads JetBrainsMono
fn download_font() {
	os.mkdir(os.resource_abs_path('assets')) or {}
	path := os.resource_abs_path('assets/JetBrainsMono-Regular.ttf')
	url := 'https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Regular.ttf'
	// http.download_file(url, path) or { return }
}
