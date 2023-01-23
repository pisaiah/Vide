module main

import iui as ui
import os
import gg

const (
	vide_png0 = $embed_file('assets/ezgif.com-gif-maker(5).png')
	vide_png1 = $embed_file('assets/word.png')
)

fn (mut app App) make_menubar() {
	// Setup Menubar and items
	mut window := app.win
	window.bar = ui.menu_bar()

	file_img := $embed_file('assets/icons8-file-48.png')
	edit_img := $embed_file('assets/icons8-edit-24.png')
	help_img := $embed_file('assets/icons8-help-24.png')
	save_img := $embed_file('assets/icons8-save-24.png')
	theme_img := $embed_file('assets/icons8-change-theme-24.png')

	file_icon := ui.image_from_bytes(mut window, file_img.to_bytes(), 24, 22)
	edit_icon := ui.image_from_bytes(mut window, edit_img.to_bytes(), 24, 22)
	help_icon := ui.image_from_bytes(mut window, help_img.to_bytes(), 24, 22)
	save_icon := ui.image_from_bytes(mut window, save_img.to_bytes(), 24, 22)
	theme_icon := ui.image_from_bytes(mut window, theme_img.to_bytes(), 24, 22)

	file_menu := ui.menu_item(
		text: 'File'
		icon: file_icon
		children: [
			ui.menu_item(
				text: 'New Project..'
				click_event_fn: new_project_click
			),
			ui.menu_item(
				text: 'New File...'
				click_event_fn: new_file_click
			),
			ui.menu_item(
				text: 'Save'
				click_event_fn: save_click
			),
			ui.menu_item(
				text: 'Run'
				click_event_fn: run_click
			),
			/*
			ui.menu_item(
				text: 'Vpm UI'
				click_event_fn: vpm_click
			),*/
			ui.menu_item(
				text: 'Manage Modules..'
				click_event_fn: vpm_click_
			),
			ui.menu_item(
				text: 'Settings'
				click_event_fn: settings_click
			),
			ui.menu_item(
				text: 'Manage V'
				click_event_fn: show_install_modal
			),
		]
	)

	edit_menu := ui.menu_item(
		text: 'Edit'
		icon: edit_icon
	)

	help_menu := ui.menu_item(
		text: 'Help'
		icon: help_icon
		children: [
			ui.menu_item(
				text: 'About Vide'
				click_event_fn: about_click
			),
			ui.menu_item(
				text: 'About iUI'
			),
		]
	)

	mut theme_menu := ui.menuitem('Themes')
	theme_menu.icon = theme_icon

	themes := ui.get_all_themes()
	for theme2 in themes {
		item := ui.menu_item(text: theme2.name, click_event_fn: on_theme_click)
		theme_menu.add_child(item)
	}

	save_menu := ui.menu_item(
		text: 'Save'
		icon: save_icon
		click_event_fn: save_click
	)

	window.bar.add_child(file_menu)
	window.bar.add_child(edit_menu)
	window.bar.add_child(help_menu)
	window.bar.add_child(theme_menu)

	window.bar.add_child(save_menu)
}

fn (mut app App) set_theme_from_save() {
	name := app.get_saved_value('theme')
	if name.len > 1 {
		theme := ui.theme_by_name(name)
		app.win.set_theme(theme)
		theme.setup_fn(mut app.win)
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
	mut modal := ui.modal(win, 'About VIDE')
	mut vbox := ui.vbox(win)
	vbox.set_pos(50, 16)

	logo := &gg.Image(win.id_map['vide_logo'])
	mut logo_im := ui.image(win, logo)
	logo_im.set_bounds(4, 2, logo.width, logo.height)

	mut label := ui.label(win,
		'Simple IDE for the V Programming Language made in V.\n\nVersion: ' + version +
		'\nUI Version: ' + ui.version)

	label.set_pos(4, 16)
	label.pack()

	mut copy := ui.label(win, 'Copyright © 2021-2023 by Isaiah.')
	copy.set_pos(265, 225)
	copy.set_config(14, true, false)

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
	for mut sv in tab {
		if mut sv is ui.ScrollView {
			for mut child in sv.children {
				if mut child is ui.TextArea {
					os.write_file(com.active_tab, child.lines.join('\n')) or {
						set_console_text(mut win, 'Unable to save file!')
					}
				}
			}
		}
	}
}

fn run_click(mut win ui.Window, item ui.MenuItem) {
	com := &ui.Tabbox(win.get_from_id('main-tabs'))

	txt := com.active_tab
	dir := os.dir(txt)

	spawn run_v(dir, mut win)
}
