module main

import iui as ui
import os

const vide_png0 = $embed_file('assets/ezgif.com-gif-maker(5).png')
const vide_png1 = $embed_file('assets/word.png')

fn (mut app App) make_menubar() {
	// Setup Menubar and items
	mut window := app.win
	window.bar = ui.menu_bar()

	file_img := $embed_file('assets/file-icon.png')
	edit_img := $embed_file('assets/icons8-edit-24.png')
	help_img := $embed_file('assets/help-icon.png')
	save_img := $embed_file('assets/icons8-save-24.png')
	theme_img := $embed_file('assets/icons8-change-theme-24.png')
	run_img := $embed_file('assets/run.png')
	fmt_img := $embed_file('assets/fmt.png')

	i_w := 26
	i_h := 26

	file_icon := ui.image_from_bytes(mut window, file_img.to_bytes(), i_w, i_h)
	edit_icon := ui.image_from_bytes(mut window, edit_img.to_bytes(), i_w, i_h)
	help_icon := ui.image_from_bytes(mut window, help_img.to_bytes(), i_w, i_h)
	save_icon := ui.image_from_bytes(mut window, save_img.to_bytes(), i_w, i_h)
	theme_icon := ui.image_from_bytes(mut window, theme_img.to_bytes(), i_w, i_h)
	run_icon := ui.image_from_bytes(mut window, run_img.to_bytes(), i_w, i_h)
	fmt_icon := ui.image_from_bytes(mut window, fmt_img.to_bytes(), i_w, i_h)

	file_menu := ui.menu_item(
		text: 'File'
		icon: file_icon
		children: [
			ui.menu_item(
				text: 'New Project..'
				click_event_fn: app.new_project_click
			),
			ui.menu_item(
				text: 'New File...'
				// click_event_fn: new_file_click
			),
			ui.menu_item(
				text: 'Save'
				click_event_fn: save_click
			),
			ui.menu_item(
				text: 'Run'
				click_event_fn: run_click
			),
			ui.menu_item(
				text: 'Manage Modules..'
				// click_event_fn: vpm_click_
			),
			ui.menu_item(
				text: 'Settings'
				click_event_fn: settings_click
			),
			ui.menu_item(
				text: 'Manage V'
				// click_event_fn: show_install_modal
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
				text: 'Github'
				click_event_fn: gh_click
			),
			ui.menu_item(
				text: 'Discord'
				click_event_fn: dis_click
			),
			ui.menu_item(
				text: 'About iUI'
			),
		]
	)

	mut theme_menu := ui.menu_item(
		text: 'Themes'
		icon: theme_icon
	)

	themes := ui.get_all_themes()
	for theme2 in themes {
		item := ui.menu_item(text: theme2.name, click_event_fn: on_theme_click)
		theme_menu.add_child(item)
	}

	item := ui.menu_item(text: 'Vide Default Dark', click_event_fn: on_theme_click)
	theme_menu.add_child(item)

	item_ := ui.menu_item(text: 'Vide Light Theme', click_event_fn: on_theme_click)
	theme_menu.add_child(item_)

	save_menu := ui.menu_item(
		text: 'Save'
		icon: save_icon
		click_event_fn: save_click
	)

	run_menu := ui.menu_item(
		text: 'Run'
		icon: run_icon
		click_event_fn: run_click
	)

	fmt_menu := ui.menu_item(
		text: 'v fmt'
		icon: fmt_icon
		click_event_fn: fmt_click
	)

	window.bar.add_child(file_menu)
	window.bar.add_child(edit_menu)
	window.bar.add_child(help_menu)
	window.bar.add_child(theme_menu)

	window.bar.add_child(save_menu)
	window.bar.add_child(run_menu)
	window.bar.add_child(fmt_menu)
}

fn (mut app App) set_theme_from_save() {
	/*
	name := app.get_saved_value('theme')
	if name.len > 1 {
		theme := ui.theme_by_name(name)
		app.win.set_theme(theme)
		theme.setup_fn(mut app.win)
	}*/
}

fn settings_click(mut win ui.Window, com ui.MenuItem) {
	mut app := win.get[&App]('app')
	// file := os.join_path(app.confg.cfg_dir, 'config.yml')
	// new_tab(win, file)
	app.show_settings()
}

fn on_theme_click(mut win ui.Window, com ui.MenuItem) {
	if com.text == 'Vide Default Dark' {
		mut vt := vide_dark_theme()
		win.set_theme(vt)
		return
	}
	if com.text == 'Vide Light Theme' {
		mut vt := vide_light_theme()
		win.set_theme(vt)
		return
	}

	theme := ui.theme_by_name(com.text)

	mut app := win.get[&App]('app')
	app.confg.theme = com.text
	app.confg.save()
	win.set_theme(theme)
}

fn gh_click(mut win ui.Window, com ui.MenuItem) {
	ui.open_url('https://github.com/pisaiah/vide')
}

fn dis_click(mut win ui.Window, com ui.MenuItem) {
	ui.open_url('https://discord.gg/NruVtYBf5g')
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About VIDE')

	modal.in_width = 430
	modal.in_height = 250

	mut p := ui.Panel.new()
	p.set_pos(8, 16)

	mut label := ui.Label.new(
		text: 'Simple IDE for the V Language made in V.\n\nVersion: ${version}\niUI: ${ui.version}'
	)

	label.set_pos(4, 16)
	label.pack()

	mut copy := ui.Label.new(text: 'Copyright © 2021-2023 by Isaiah.')
	copy.set_pos(16, 175)
	copy.set_config(14, true, false)

	p.add_child(label)
	modal.add_child(copy)
	modal.add_child(p)
	win.add_child(modal)
}

fn save_click(mut win ui.Window, item ui.MenuItem) {
	do_save(mut win)
}

fn do_save(mut win ui.Window) {
	mut com := win.get[&ui.Tabbox]('main-tabs')

	mut tab := com.kids[com.active_tab]
	for mut sv in tab {
		if mut sv is ui.ScrollView {
			for mut child in sv.children {
				if mut child is ui.Textbox {
					write_file(com.active_tab, child.lines.join('\n')) or {
						// set_console_text(mut win, 'Unable to save file!')
					}
				}
			}
		}
	}
}

fn refresh_current_tab(mut win ui.Window, file string) {
	mut com := win.get[&ui.Tabbox]('main-tabs')

	mut tab := com.kids[com.active_tab]
	for mut sv in tab {
		if mut sv is ui.ScrollView {
			for mut child in sv.children {
				if mut child is ui.Textbox {
					old_x := child.caret_x
					old_y := child.caret_y

					lines := os.read_lines(file) or { child.lines }
					child.lines = lines

					child.caret_x = old_x
					child.caret_y = old_y
				}
			}
		}
	}
}

fn run_click(mut win ui.Window, item ui.MenuItem) {
	com := win.get[&ui.Tabbox]('main-tabs')

	txt := com.active_tab
	mut dir := os.dir(txt)

	if dir.ends_with('src') {
		dir = os.dir(dir)
	}

	args := ['v', '-skip-unused', 'run', dir]

	mut tbox := win.get[&ui.Textbox]('vermbox')

	spawn verminal_cmd_exec(mut win, mut tbox, args)

	jump_sv(mut win, tbox.height, tbox.lines.len)

	win.extra_map['update_scroll'] = 'true'
	win.extra_map['lastcmd'] = args.join(' ')
}

fn fmt_click(mut win ui.Window, item ui.MenuItem) {
	com := win.get[&ui.Tabbox]('main-tabs')

	txt := com.active_tab
	/*
	mut dir := os.dir(txt)

	if dir.ends_with('src') {
		dir = os.dir(dir)
	}*/

	do_save(mut win)

	args := ['v', 'fmt', '-w', txt]

	mut tbox := win.get[&ui.Textbox]('vermbox')

	verminal_cmd_exec(mut win, mut tbox, args)

	jump_sv(mut win, tbox.height, tbox.lines.len)

	refresh_current_tab(mut win, txt)

	win.extra_map['update_scroll'] = 'true'
	win.extra_map['lastcmd'] = args.join(' ')
}
