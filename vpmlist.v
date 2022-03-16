module main

import iui as ui
import os
import math

struct Pack {
	ui.Component_A
mut:
	label ui.Label
	btn   ui.Button
	show  bool
}

fn module_exists(name string) bool {
	path := os.vmodules_dir().replace('\\', '/') + '/' + name.replace('.', '/')
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

fn (mut this Pack) draw() {
	if this.show {
		ui.draw_with_offset(mut this.label, this.x, this.y)
		ui.draw_with_offset(mut this.btn, this.x, this.y)

		this.btn.app.gg.draw_rounded_rect_empty(this.x - 4, this.y - 1, this.width, this.height + 3,
			2, this.btn.app.theme.scroll_bar_color)

		// Change buttons
		installed := module_exists(this.label.text)
		if installed && this.btn.text.contains('Install') {
			create_cmd_btn(mut this.btn.app, 'remove', this.btn.extra, mut this)
		} else {
			if !installed && this.btn.text.contains('Remove') {
				create_cmd_btn(mut this.btn.app, 'install', this.btn.extra, mut this)
			}
		}

		// println('LT: ' + this.label.text + ', exist?: ' + installed.str())
		if this.is_mouse_rele {
			if ui.point_in(mut this.btn, this.btn.app.click_x - this.x, this.btn.app.click_y - this.y) {
				this.btn.is_mouse_down = false
				this.btn.is_mouse_rele = true
				this.is_mouse_rele = false
			}
		}
	}
}

fn vpm_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'V Package Manager (GUI)')
	modal.set_id(mut win, 'vpm-modal')
	modal.in_height = 400
	modal.top_off = 10

	v := get_v_exe(mut win)

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
	mut tbox := ui.textbox(win, ' ')
	tbox.multiline = false
	tbox.draw_event_fn = fn (mut win ui.Window, mut box ui.Component) {
		box.x = ui.text_width(win, 'Search: ') + 8
		box.width = math.max(200, ui.text_width(win, box.text + 'a b'))
		box.height = ui.text_height(win, 'A{0|') + 8
	}
	tbox.text_change_event_fn = fn (mut win ui.Window, box ui.Textbox) {
		win.extra_map['vpm-search'] = box.text.trim_space()
	}
	modal.add_child(slbl)
	modal.add_child(tbox)

	slbl.set_pos(10, 15)
	tbox.set_bounds(60, 5, 100, 30)

	for i in 0 .. arr.len {
		mut txt := arr[i]
		if !txt.contains('[') {
			continue
		}

		mut pack := &Pack{}
		name := txt.split('[')[1].split(']')[0]

		mut lbl := ui.label(win, name)
		lbl.pack()
		pack.label = lbl

		th := ui.text_height(win, 'A{0|') + 8
		if name in installed_pack {
			create_cmd_btn(mut win, 'remove', name, mut pack)
		} else {
			create_cmd_btn(mut win, 'install', name, mut pack)
		}
		pack.width = 370
		pack.height = th

		modal.add_child(pack)
	}

	mut slider := ui.slider(win, 0, 100, .vert)
	slider.set_bounds(41, 10, 15, 200)
	slider.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut modal := &ui.Modal(win.get_from_id('vpm-modal'))
		mut packs := modal.children.filter(it is Pack)

		mut this := *com
		if mut this is ui.Slider {
			mut sy := ui.text_height(win, 'A{0|') + 25
			ms := ui.text_height(win, 'A{0|') + 10
			max_show := ((400 - sy - (ms * 2)) / ms)

			this.y = sy
			this.cur = modal.scroll_i
			this.height = (max_show + 1) * packs[0].height
			this.max = win.extra_map['vpm-pl'].int()
		}
	}
	modal.add_child(slider)

	modal.after_draw_event_fn = vpm_modal_draw

	win.add_child(modal)
}

fn create_cmd_btn(mut win ui.Window, cmd string, name string, mut pack Pack) {
	mut btn := ui.button(win, cmd.title())
	btn.extra = cmd + ' ' + name
	height := ui.text_height(win, 'A{') + 5
	btn.set_bounds(250, 1, 100, height)
	btn.set_click(fn (mut win ui.Window, btn ui.Button) {
		v := get_v_exe(mut win)
		res := os.execute(v + ' ' + btn.extra).output
		println(res)
		if btn.extra.starts_with('remove ') {
			// 'v remove' leaves empty .git dir causing the
			// module to still show as installed in 'v list'
			path := os.real_path(btn.extra.replace_once('remove ', ''))
			os.execute('cmd /c "rmdir /S /Q "' + path + '"')
		}
	})
	pack.btn = btn
}

[deprecated: 'Replaced by ui.Slider']
fn draw_scrollbar(mut com ui.Modal, cl int, spl_len int, ep int) {
}


fn vpm_modal_draw(mut win ui.Window, comp &ui.Component) {
    mut com := *comp
	if mut com is ui.Modal {
		mut packs := com.children.filter(it is Pack)
		mut i := 0
		mut sy := ui.text_height(win, 'A{0|') + 25
		ms := ui.text_height(win, 'A{0|') + 10
		max_show := ((400 - sy - (ms * 2)) / ms)
		if com.scroll_i > (packs.len - 1) {
			com.scroll_i = packs.len - 1
		}
		mut pl := packs.len
		for mut pack in packs {
			if mut pack is Pack {
				contain_search := pack.label.text.to_lower().contains(win.extra_map['vpm-search'].to_lower())
				if win.extra_map['vpm-search'].len > 0 && !contain_search {
					pack.show = false
					pl--
					continue
				}
				if i >= com.scroll_i && i < (com.scroll_i + max_show) {
					pack.show = true
					pack.set_pos(60, sy)
					sy += ms
				} else {
					pack.show = false
				}
				i++
			}
		}
		if com.scroll_i > (pl - 1) && com.scroll_i > max_show {
			com.scroll_i = pl - max_show
		}
		win.extra_map['vpm-pl'] = pl.str()
	}
}
