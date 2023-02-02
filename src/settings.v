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

	mut vbox := ui.vbox(win)

	vbox.set_bounds(16, 16, 0, 0)

	modal.needs_init = false
	mut close := ui.button(text: 'Save & Done')
	close.set_bounds(310, -54, 200, 30)

	mut can := ui.button(text: 'Cancel')
	can.set_bounds(220, -54, 80, 30)
	can.set_click(fn (mut win ui.Window, btn ui.Button) {
		win.components = win.components.filter(mut it !is ui.Page)
	})
	modal.add_child(can)

	close.set_click(fn (mut win ui.Window, btn ui.Button) {
		config.save()
		win.components = win.components.filter(mut it !is ui.Page)
	})

	vbox.draw_event_fn = fn (mut win ui.Window, mut com ui.Component) {
		size := win.gg.window_size()
		x_pos := (size.width / 3) - (com.width / 2)
		ui.set_pos(mut com, x_pos, 0)
	}
	win.id_map['setting_box'] = vbox

	general_section(win, mut vbox)
	appearance_section(win, mut vbox)
	cloud_section(win, mut vbox)

	// Spacer
	spacer := title_label(win, '  ')
	vbox.add_child(spacer)

	mut sv := ui.scroll_view(
		view: vbox
	)

	sv.draw_event_fn = fn (mut win ui.Window, mut com ui.Component) {
		size := win.gg.window_size()
		ui.set_bounds(mut com, 5, 4, size.width - 10, size.height - 90)
	}

	modal.add_child(close)
	modal.add_child(sv)
	win.add_child(modal)
}

fn title_label(win &ui.Window, text string) &ui.Label {
	mut lbl := ui.label(win, text)
	lbl.pack()
	lbl.set_pos(0, 16)
	lbl.set_config(4, false, true)
	return &lbl
}

fn cloud_section(win &ui.Window, mut vbox ui.VBox) {
	mut box := ui.vbox(win)
	box.set_pos(16, 0)

	mut field := ui.text_field(text: 'TODO  ')
	field.set_bounds(8, 0, 400, 30)

	mut fb := ui.title_box('Server URL', [field])
	box.add_child(fb)

	mut tb := ui.title_box('Cloud Compile (*Coming soon*)', [box])
	tb.set_bounds(0, 16, 600, 25)
	vbox.add_child(tb)
}

fn general_section(win &ui.Window, mut vbox ui.VBox) {
	mut work_lbl := ui.label(win, 'Workspace Location')
	work_lbl.pack()

	workd := os.real_path(config.get_value('workspace_dir').replace('\{user_home}', '~'))
	folder := os.expand_tilde_to_home(workd)

	mut work := ui.text_field(text: folder)
	mut dialog_btn := ui.button(text: 'Pick Folder')

	work.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = math.max(ui.text_width(win, work.text + 'a b'), 300)
		work.height = win.graphics_context.line_height + 8
	}
	work.text_change_event_fn = fn (a voidptr, b voidptr) {
		work := &ui.TextField(b)
		config.set('workspace_dir', work.text.replace(os.home_dir().replace('\\', '/'),
			'~')) // '
	}

	mut lib_lbl := ui.label(win, 'Path to VEXE (ex: C:/v/v.exe) (no shortcuts/symlinks)')
	lib_lbl.pack()

	home := os.home_dir().replace('\\', '/') // '
	mut vlib := ui.text_field(text: get_v_exe(win).replace(home, '~'))

	vlib.draw_event_fn = fn (mut win ui.Window, mut work ui.Component) {
		work.width = math.max(250, ui.text_width(win, work.text + 'a b'))
		work.height = win.graphics_context.line_height + 10
	}
	vlib.text_change_event_fn = fn (win_ptr voidptr, box_ptr voidptr) {
		mut win := &ui.Window(win_ptr)
		work := &ui.TextField(box_ptr)

		config.set('v_exe', work.text.replace(os.home_dir().replace('\\', '/'), '~')) // '
	}

	work_lbl.set_bounds(32, 8, 0, 0)
	lib_lbl.set_bounds(32, 16, 0, 0)
	work.set_bounds(32, 0, 0, 0)
	vlib.set_bounds(32, 4, 0, 0)

	mut hbox := ui.hbox(win)
	hbox.set_pos(0, 4)
	hbox.width = 500
	// hbox.pack()

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
	dialog_btn.set_pos(2, 0)
	dialog_btn.pack()

	hbox.add_child(work)
	hbox.add_child(dialog_btn)

	mut box := ui.vbox(win)
	box.add_child(work_lbl)
	box.add_child(hbox)
	box.add_child(lib_lbl)
	box.add_child(vlib)

	mut tb := ui.title_box('General', [box])
	tb.set_bounds(0, 16, 600, 1)
	vbox.add_child(tb)
}

fn create_font_slider(win &ui.Window) &ui.Titlebox {
	mut vbox := ui.hbox(win)
	vbox.set_bounds(4, 0, 140, 37)

	mut field := ui.numeric_field(win.font_size)
	field.set_bounds(4, 0, 90, 35)
	vbox.add_child(field)

	mut btn := ui.button(
		text: 'Set'
		bounds: ui.Bounds{2, 0, 40, 35}
	)
	btn.parent = &ui.Component_A(field)
	btn.subscribe_event('mouse_up', fn (mut e ui.MouseEvent) {
		txt := e.target.parent.text
		e.ctx.win.font_size = txt.int()
		e.ctx.font_size = txt.int()
		config.set('font_size', txt)
	})
	vbox.add_child(btn)

	mut tb := ui.title_box('Font Size', [vbox])
	tb.set_pos(16, 0)

	return tb
}

fn tree_padding_slider_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	mut tree := win.get[&ui.Tree2]('proj-tree')
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

fn create_tree_width_slider(win &ui.Window) &ui.Titlebox {
	mut tree_padding_slider := ui.slider(win, 0, 30, .hor)
	tree_padding_slider.set_bounds(8, 8, 100, 25)
	tree := win.get[&ui.Tree2]('proj-tree')
	tree_padding_slider.cur = (tree.width - 100) / 10
	tree_padding_slider.draw_event_fn = tree_padding_slider_draw

	mut tb := ui.title_box('File Tree Width', [tree_padding_slider])
	tb.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		tree := e.ctx.win.get[&ui.Tree2]('proj-tree')
		e.target.text = 'File Tree Width (${tree.width}):'
	})
	tb.set_bounds(16, 0, 200, 30)

	return tb
}

fn appearance_section(win &ui.Window, mut vbox ui.VBox) {
	font_size_box := create_font_slider(win)
	tree_padding_box := create_tree_width_slider(win)

	mut hbox := ui.hbox(win)

	hbox.add_child(font_size_box)
	hbox.add_child(tree_padding_box)

	hbox.set_bounds(0, 0, 500, 100)
	hbox.parent = vbox

	mut font_box := ui.selector(win, 'Font', ui.SelectConfig{
		bounds: ui.Bounds{8, 2, 200, 35}
		items: [
			'Default Font',
			'Anomaly Mono',
			'Agave-Regular',
			'JetBrainsMono',
			'System SegoeUI',
		]
	})
	font_box.set_change(sel_change)

	mut box := ui.vbox(win)
	box.add_child(hbox)

	mut fb := ui.title_box('Main Font', [font_box])
	fb.set_pos(16, 8)

	box.add_child(fb)

	mut tb := ui.title_box('Appearance', [box])
	tb.set_bounds(0, 16, 600, 100)
	box.subscribe_event('draw', fn [mut tb] (mut e ui.DrawEvent) {
		mut fb := e.target.children[1]
		mut sb := fb.children[0]
		if mut sb is ui.Select {
			mut hei := 0
			for ch in e.target.children {
				hei += ch.y + ch.height
			}

			if sb.show_items {
				subs := (sb.items.len + 1) * sb.sub_height
				fb.height = subs + (e.ctx.line_height * 2)
			} else {
				fb.height = sb.height
			}
			tb.height = hei
		}
	})

	vbox.add_child(tb)
}

// Font selector change
fn sel_change(mut win ui.Window, com ui.Select, old_val string, new_val string) {
	mut path := os.resource_abs_path('assets/' + new_val.replace(' ', '-') + '.ttf')

	if new_val == 'JetBrainsMono' {
		exists := os.exists(path)
		if !exists {
			download_font()
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
	config.set('main_font', path)
}

// Downloads JetBrainsMono
fn download_font() {
	os.mkdir(os.resource_abs_path('assets')) or {}
	path := os.resource_abs_path('assets/JetBrainsMono.ttf')

	mut embed := $embed_file('assets/JetBrainsMono.ttf')
	os.write_file_array(path, embed.to_bytes()) or {
		// Oh no!
	}
}
