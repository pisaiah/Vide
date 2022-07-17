module main

import iui as ui
import os

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
	mut modal := ui.page(win, 'V Package Manager (GUI)')
	modal.set_id(mut win, 'vpm-modal')

	mut slbl := ui.label(win, 'Search: ')
	mut tbox := ui.textfield(win, '')

	mut vbox := ui.vbox(win)

	slbl.draw_event_fn = fn (mut win ui.Window, mut lbl ui.Component) {
		modal := &ui.Page(win.get_from_id('vpm-modal'))
		if modal.width > 900 {
			lbl.x = (modal.width / 8) - (lbl.width / 2)
		} else {
			lbl.x = 4
		}
	}

	tbox.draw_event_fn = fn (mut win ui.Window, mut box ui.Component) {
		modal := &ui.Page(win.get_from_id('vpm-modal'))
		if modal.width > 900 {
			box.x = (modal.width / 8) + (ui.text_width(win, ' Search: '))
			box.width = (modal.width / 2) - box.x
		} else {
			tw := ui.text_width(win, ' Search: ')
			box.x = tw
			box.width = modal.width - (tw * 2) - 28
		}
		box.height = ui.text_height(win, 'A{0|') + 8
	}
	tbox.set_id(mut win, 'vpm-search')

	modal.add_child(slbl)
	modal.add_child(tbox)

	slbl.set_pos(10, 10)
	tbox.set_bounds(80, 5, 100, 30)

	// Load results async
	go load_modules(mut win, mut vbox)

	mut slider := ui.slider(win, 0, 100, .vert)
	slider.set_bounds(41, 30, 24, 200)
	slider.draw_event_fn = fn (mut win ui.Window, com &ui.Component) {
		mut modal := &ui.Page(win.get_from_id('vpm-modal'))

		mut this := *com
		mut vbox := modal.children.filter(it is ui.VBox)[0]
		if mut this is ui.Slider {
			this.y = 0
			this.x = modal.width - this.width - 3
			this.height = (modal.height - modal.top_off) - 4
			if this.is_mouse_rele || this.is_mouse_down {
				vbox.scroll_i = int(this.cur)
			}
			this.cur = vbox.scroll_i
			this.max = vbox.children.len
		}
	}
	modal.add_child(slider)

	vbox.overflow = false
	vbox.set_bounds(0, 40, 200, 348)
	vbox.draw_event_fn = vpm_vbox_draw_border

	modal.add_child(vbox)
	win.add_child(modal)
}

fn load_modules(mut win ui.Window, mut vbox ui.VBox) {
	v := get_v_exe(win)
	mut res := os.execute(v + ' search a b c d e f g h i j k l m n o p q r s t u v w x y z').output
	dump(res)
	mut arr := res.split_into_lines()

	installed := os.execute(v + ' list').output
	mut iarr := installed.split_into_lines()
	iarr.delete(0) // Remove "Installed modules" text
	mut installed_pack := []string{}

	for s in iarr {
		installed_pack << s.trim_space()
	}

	for i in 0 .. arr.len {
		txt := arr[i]
		if !txt.contains('[') {
			continue
		}

		mut pack := &Pack{
			win: win
		}
		name := txt.split('[')[1].split(']')[0]

		lbl := ui.label(win, name, ui.LabelConfig{
			should_pack: true
		})
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
	win.gg.refresh_ui()
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
	btn.set_bounds(250, 5, 100, height)
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

fn vpm_vbox_draw_border(mut win ui.Window, mut com ui.Component) {
	win.draw_bordered_rect(com.rx, com.ry, com.width, com.height, 1, win.theme.textbox_background,
		win.theme.textbox_border)

	mut modal := &ui.Page(win.get_from_id('vpm-modal'))

	if modal.width < 900 {
		com.x = 4
		com.width = modal.width - 8 - 28
		return
	}

	com.x = (modal.width / 8)
	com.width = modal.width - (modal.width / 4)
	com.height = modal.height - modal.top_off - 60
}
