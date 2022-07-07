module main

import iui as ui
import os
import gg

const (
	vide_png = $embed_file('assets/ezgif.com-gif-maker(5).png')
)

fn set_theme_from_save(mut win ui.Window) {
	mut conf := get_config(win)
	name := conf.get_value('theme')
	if name.len > 1 {
		theme := ui.theme_by_name(name)
		win.set_theme(theme)
	}
}

fn on_theme_click(mut win ui.Window, com ui.MenuItem) {
	theme := ui.theme_by_name(com.text)
	mut conf := get_config(win)
	conf.set('theme', com.text)
	conf.save()
	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Vɪᴅᴇ')
	mut vbox := ui.vbox(win)
	vbox.set_pos(70, 16)

	logo := &gg.Image(win.id_map['vide_logo'])
	mut logo_im := ui.image(win, logo)
	logo_im.set_bounds(4, 2, logo.width, logo.height)

	mut label := ui.label(win, 'Small IDE for the V Programming Language made in V.\n\nVersion: ' +
		version + '\nUI Version: ' + ui.version)

	label.set_pos(4, 16)
	label.pack()

	mut copy := ui.label(win, 'Copyright © 2021-2022 ')
	copy.set_pos(16, 270)
	copy.set_config(12, true, false)

	vbox.add_child(logo_im)
	vbox.add_child(label)
	modal.add_child(copy)
	modal.add_child(vbox)
	win.add_child(modal)
}

fn save_click(mut win ui.Window, item ui.MenuItem) {
	do_save(mut win)
}

fn do_save(mut win ui.Window) {
	mut com := &ui.Tabbox(win.get_from_id('main-tabs'))

	mut tab := com.kids[com.active_tab]
	for mut child in tab {
		if mut child is ui.TextArea {
			os.write_file(com.active_tab, child.lines.join('\n')) or {
				set_console_text(mut win, 'Unable to save file!')
			}
		}
	}
}

fn run_click(mut win ui.Window, item ui.MenuItem) {
	com := &ui.Tabbox(win.get_from_id('main-tabs'))

	txt := com.active_tab
	dir := os.dir(txt)

	go run_v(dir, mut win)
}
