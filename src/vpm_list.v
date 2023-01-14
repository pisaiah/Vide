module main

import iui as ui
import os
import gx

struct Package {
	ui.Component_A
mut:
	win   &ui.Window
	label ui.Label
	btn   ui.Button
	show  bool
}

fn (mut this Package) draw(ctx &ui.GraphicsContext) {
	page := &ui.Page(ctx.win.get_from_id('vpm-modal'))
	sear := &ui.TextField(ctx.win.get_from_id('vpm-search'))

	label_text := this.label.text.to_lower()
	search_text := sear.text.to_lower()

	if !label_text.contains(search_text) {
		this.width = 0
		return
	}

	pw := page.width - 40

	can_fit := if pw < 400 { 1 } else { pw / 400 }

	this.width = (pw / can_fit) - 5

	mid_y := this.y + (this.height / 2) - (ctx.line_height / 2)

	x := this.x + 4

	ctx.win.draw_with_offset(mut this.label, x + 10, mid_y)

	endy := this.x + this.width - this.btn.width - 15
	midy := this.y + (this.height / 2) - (this.btn.height / 2)

	ctx.win.draw_with_offset(mut this.btn, endy, midy)
	ctx.gg.draw_rect_empty(x, this.y, this.width - 8, this.height, gx.blue)

	// Change buttons
	if !this.is_mouse_rele {
		return
	}

	if ui.point_in_raw(mut this.btn, this.win.mouse_x, this.win.mouse_y) {
		this.is_mouse_rele = false

		btn_extra := this.btn.extra.split(' ')[1]

		if this.btn.text.contains('Remove') {
			update_comd_btn(mut this.win, 'remove', btn_extra, mut this)
			this.btn.text = 'Install'
		} else {
			if this.btn.text.contains('Install') {
				update_comd_btn(mut this.win, 'install', btn_extra, mut this)
				this.btn.text = 'Remove'
			}
		}

		this.btn.is_mouse_down = false
		this.btn.is_mouse_rele = true
	}
	this.is_mouse_rele = false
}

fn vpm_click_(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.page(win, 'V Package Manager (GUI)')
	modal.set_id(mut win, 'vpm-modal')

	mut slbl := ui.label(win, 'Search: ')
	mut tbox := ui.textfield(win, '')

	mut vbox := ui.hbox(win)

	tbox.draw_event_fn = fn (mut win ui.Window, mut box ui.Component) {
		modal := &ui.Page(win.get_from_id('vpm-modal'))
		tw := ui.text_width(win, ' Search: ') + 20
		box.x = tw
		box.width = modal.width - (tw * 2) - 28
		box.height = ui.text_height(win, 'A{0|') + 8
	}
	tbox.set_id(mut win, 'vpm-search')

	modal.add_child(slbl)
	modal.add_child(tbox)

	slbl.set_pos(15, 10)
	tbox.set_bounds(80, 5, 100, 30)

	// Load results async
	// go load_modules_(mut win, mut vbox)
	load_modules_(mut win, mut vbox)

	vbox.set_pos(2, 2)
	vbox.draw_event_fn = vpm_vbox_draw

	mut sv := ui.scroll_view(
		view: vbox
		bounds: ui.Bounds{20, 40, 600, 400}
	)
	sv.xbar_width = 25
	sv.draw_event_fn = vpm_sv_draw_border

	modal.add_child(sv)
	win.add_child(modal)
}

fn vpm_vbox_draw(mut win ui.Window, mut com ui.Component) {
	modal := &ui.Page(win.get_from_id('vpm-modal'))

	if modal.width < 900 {
		com.width = modal.width - 8 - 28
		return
	}
	com.width = modal.width - 30
}

fn vpm_sv_draw_border(mut win ui.Window, mut com ui.Component) {
	modal := &ui.Page(win.get_from_id('vpm-modal'))
	com.x = 1
	com.width = modal.width - 2
	com.height = modal.height - modal.top_off - 44
}

fn load_modules_(mut win ui.Window, mut vbox ui.HBox) {
	v := get_v_exe(win)
	mut res := os.execute(v + ' search a b c d e f g h i j k l m n o p q r s t u v w x y z').output
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

		name := txt.split('[')[1].split(']')[0]

		lbl := ui.label(win, name, ui.LabelConfig{
			should_pack: true
		})

		btn_txt := if name in installed_pack { 'remove' } else { 'install' }

		mut pack := &Package{
			win: win
			label: lbl
			btn: create_cmd_btn(mut win, btn_txt)
		}

		update_comd_btn(mut win, btn_txt, name, mut pack)

		pack.width = 400
		pack.height = 40

		vbox.add_child(pack)
	}
	win.gg.refresh_ui()
}

fn update_comd_btn(mut win ui.Window, cmd string, name string, mut pack Package) {
	mut btn := pack.btn
	btn.extra = cmd + ' ' + name

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

fn create_cmd_btn(mut win ui.Window, cmd string) &ui.Button {
	mut btn := ui.button(win, cmd.title())
	return &btn
}
