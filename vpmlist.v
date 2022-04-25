module main

import iui as ui
import os
import math

struct Pack {
	ui.Component_A
mut:
	win   &ui.Window
	label ui.Label
	btn   ui.Button
	show  bool
}

fn module_exists(name string) bool {
	path := os.vmodules_dir().replace('\\', '/') + '/' + name.replace('.', '/') // '
	exists := os.exists(path)
	if exists {
		ls := os.ls(path) or { [''] }
		if ls.len == 1 && ls[0] == '.git' {
			// 'v remove' does not remove git dir?
			os.execute('cmd /c "rmdir /S /Q ' + os.real_path(path) + '"')
			return false
		}
	}
	return exists
}

fn (mut this Pack) draw(ctx &ui.GraphicsContext) {
	box := &ui.TextField(this.win.get_from_id('vpm-search'))
	contain_search := this.label.text.to_lower().contains(box.text.to_lower())

	if !contain_search {
		this.height = 0
		return
	} else {
		this.height = ui.text_height(this.win, 'A{0|') * 2
	}

	this.win.draw_with_offset(mut this.label, this.x + 12, this.y + 8)
	this.win.draw_with_offset(mut this.btn, this.x, this.y)

	line_y := this.y + this.height
	ctx.gg.draw_line(this.x, line_y, this.x + this.width, line_y, ctx.theme.scroll_bar_color)

	// Change buttons

	if !this.is_mouse_rele {
		return
	}

	if ui.point_in(mut this.btn, this.win.mouse_x - this.x, this.win.mouse_y - this.y) {
		this.is_mouse_rele = false

		btn_extra := this.btn.extra.split(' ')[1]

		if this.btn.text.contains('Remove') {
			update_cmd_btn(mut this.win, 'remove', btn_extra, mut this)
			this.btn.text = 'Install'
		} else {
			if this.btn.text.contains('Install') {
				update_cmd_btn(mut this.win, 'install', btn_extra, mut this)
				this.btn.text = 'Remove'
			}
		}

		this.btn.is_mouse_down = false
		this.btn.is_mouse_rele = true
	}
	this.is_mouse_rele = false
}

fn vpm_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'V Package Manager (GUI)')
	modal.set_id(mut win, 'vpm-modal')
	modal.in_height = 420
	modal.top_off = 10

	v := get_v_exe(win)

	// Get all from vpm
	mut res := os.execute(v + ' search a b c d e f g h i j k l m n o p q r s t u v w x y z').output
	mut arr := res.split_into_lines()

	mut installed := os.execute(v + ' list').output
	mut iarr := installed.split_into_lines()
	iarr.delete(0) // Remove "Installed modules" text
	mut installed_pack := []string{}

	for s in iarr {
		installed_pack << s.trim_space()
	}

	mut slbl := ui.label(win, 'Search: ')
	mut tbox := ui.textfield(win, '')

	mut vbox := ui.vbox(win)

	tbox.draw_event_fn = fn (mut win ui.Window, mut box ui.Component) {
		box.x = ui.text_width(win, 'Search: ') + 8
		box.width = math.max(200, ui.text_width(win, box.text + 'a b'))
		box.height = ui.text_height(win, 'A{0|') + 8
	}
	tbox.set_id(mut win, 'vpm-search')

	modal.add_child(slbl)
	modal.add_child(tbox)

	slbl.set_pos(10, 15)
	tbox.set_bounds(60, 5, 100, 30)

	for i in 0 .. arr.len {
		mut txt := arr[i]
		if !txt.contains('[') {
			continue
		}

		mut pack := &Pack{
			win: win
		}
		name := txt.split('[')[1].split(']')[0]

		mut lbl := ui.label(win, name)
		lbl.pack()
		pack.label = lbl

		th := ui.text_height(win, 'A{0|') * 2
		if name in installed_pack {
			create_cmd_btn(mut win, 'remove', name, mut pack)
		} else {
			create_cmd_btn(mut win, 'install', name, mut pack)
		}
		pack.width = 370
		pack.height = th

		vbox.add_child(pack)
	}

	mut slider := ui.slider(win, 0, 100, .vert)
	slider.set_bounds(41, 30, 15, 200)
	slider.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut modal := &ui.Modal(win.get_from_id('vpm-modal'))

		mut this := *com
		vbox := modal.children.filter(it is ui.VBox)[0]
		if mut this is ui.Slider {
			this.y = vbox.y
			this.x = vbox.x - this.width
			this.height = vbox.height
			this.cur = vbox.scroll_i
			this.max = vbox.children.len
		}
	}
	modal.add_child(slider)

	vbox.overflow = false
	vbox.set_bounds(60, 40, 200, 348)
	vbox.draw_event_fn = vpm_vbox_draw_border

	modal.add_child(vbox)
	win.add_child(modal)
}

fn create_cmd_btn(mut win ui.Window, cmd string, name string, mut pack Pack) {
	mut btn := ui.button(win, cmd.title())
	pack.btn = btn

	update_cmd_btn(mut win, cmd, name, mut pack)
}

fn update_cmd_btn(mut win ui.Window, cmd string, name string, mut pack Pack) {
	mut btn := pack.btn
	btn.extra = cmd + ' ' + name
	height := ui.text_height(win, 'A{') + 5
	btn.set_bounds(250, 1, 100, height)
	btn.set_click(fn (mut win ui.Window, btn ui.Button) {
		v := get_v_exe(win)
		res := os.execute(v + ' ' + btn.extra).output
		dump(res)
		if btn.extra.starts_with('remove ') {
			// 'v remove' leaves empty .git dir causing the
			// module to still show as installed in 'v list'
			path := os.real_path(btn.extra.replace_once('remove ', ''))
			os.execute('cmd /c "rmdir /S /Q "' + path + '"')
		}
	})

	pack.btn = btn
}

fn vpm_vbox_draw_border(mut win ui.Window, com &ui.Component) {
	win.draw_bordered_rect(com.rx, com.ry, com.width, com.height, 1, win.theme.textbox_background,
		win.theme.textbox_border)
}
