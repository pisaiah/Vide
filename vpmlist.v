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

fn (mut this Pack) draw() {
	if this.show {
		ui.draw_with_offset(mut this.label, this.x, this.y)
		ui.draw_with_offset(mut this.btn, this.x, this.y)

		this.btn.app.gg.draw_rounded_rect_empty(this.x, this.y, this.width, this.height,
			2, this.btn.app.theme.menubar_border)

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
	mut tbox := ui.textbox(win, '')
	tbox.multiline = false
	tbox.draw_event_fn = fn (mut win ui.Window, mut box ui.Component) {
		box.x = ui.text_width(win, 'Search: ') + 8
		box.width = math.max(200, ui.text_width(win, box.text + 'a b'))
		box.height = ui.text_height(win, 'A{0|') + 8
	}
	tbox.text_change_event_fn = fn (mut win ui.Window, box ui.Textbox) {
		win.extra_map['vpm-search'] = box.text
	}
	modal.add_child(slbl)
	modal.add_child(tbox)

	slbl.set_pos(10, 15)
	tbox.set_bounds(60, 5, 100, 30)

	mut sy := ui.text_height(win, 'A{0|') + 25
	for i in 0 .. arr.len {
		mut txt := arr[i]
		if !txt.contains('[') {
			continue
		}

		mut pack := &Pack{}
		name := txt.split('[')[1].split(']')[0]

		// num := txt.split(".")[0]
		mut lbl := ui.label(win, name)
		lbl.pack()
		pack.label = lbl

		th := ui.text_height(win, 'A{0|') + 5

		if name in installed_pack {
			mut btn := ui.button(win, 'Remove')
			btn.set_bounds(250, 1, 100, th)
			pack.btn = btn
		} else {
			mut btn := ui.button(win, 'Install')
			btn.extra = name
			btn.set_bounds(250, 1, 100, th)
			btn.set_click(fn (mut win ui.Window, com ui.Button) {
				println('install clicked ' + com.extra)
			})
			pack.btn = btn
		}
		pack.width = 370
		pack.height = th

		modal.add_child(pack)
		sy += th + 1
		if math.mod(sy, 10) == 0 {
			sy = ui.text_height(win, 'A{0|') + 25
		}
	}

	modal.after_draw_event_fn = vpm_modal_draw

	win.add_child(modal)
}

fn vpm_modal_draw(mut win ui.Window, com &ui.Component) {
	if mut com is ui.Modal {
		mut packs := com.children.filter(it is Pack)
		mut i := 0
		mut sy := ui.text_height(win, 'A{0|') + 25
		max_show := 11
		if com.scroll_i > (packs.len - max_show) {
			com.scroll_i = packs.len - max_show
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
					pack.set_pos(20, sy)
					sy += ui.text_height(win, 'A{0|') + 7
				} else {
					pack.show = false
				}
				i++
			}
		}
		if com.scroll_i > (pl - max_show) && com.scroll_i > max_show {
			com.scroll_i = pl - max_show
		}
	}
}
