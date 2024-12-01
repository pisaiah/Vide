module main

import iui as ui
import os

const vide_png0 = $embed_file('assets/ezgif.com-gif-maker(5).png')
const vide_png1 = $embed_file('assets/word.png')

const i_w = 24
const i_h = 24

pub fn (mut app App) iicon(c bool, b []u8) &ui.Image {
	if !c {
		return unsafe { nil }
	}
	return ui.image_from_bytes(mut app.win, b, i_w, i_h)
}

fn (mut app App) make_menubar() {
	// Setup Menubar and items
	mut window := app.win
	window.bar = ui.Menubar.new()
	window.bar.set_padding(4)

	// file_img := $embed_file('assets/file-icon.png')
	// edit_img := $embed_file('assets/icons8-edit-24.png')
	// help_img := $embed_file('assets/help-icon.png')
	save_img := $embed_file('assets/icons8-save-24.png')
	// theme_img := $embed_file('assets/icons8-change-theme-24.png')
	run_img := $embed_file('assets/run.png')
	fmt_img := $embed_file('assets/fmt.png')

	colored := true

	// file_icon := app.iicon(colored, file_img.to_bytes())
	// edit_icon := app.iicon(colored, edit_img.to_bytes())
	// help_icon := app.iicon(colored, help_img.to_bytes())
	save_icon := app.iicon(colored, save_img.to_bytes())
	// theme_icon := app.iicon(colored, theme_img.to_bytes())
	run_icon := app.iicon(colored, run_img.to_bytes())
	fmt_icon := app.iicon(colored, fmt_img.to_bytes())

	file_menu := ui.MenuItem.new(
		text: 'File'
		// icon:     file_icon
		uicon:    '\uE132'
		children: [
			ui.MenuItem.new(
				text:           'New Project..'
				uicon:          '\uE9AF'
				click_event_fn: app.new_project_click
			),
			ui.MenuItem.new(
				text:  'New File...'
				uicon: '\uE132'
				// click_event_fn: new_file_click
			),
			ui.MenuItem.new(
				uicon:          '\uE105'
				text:           'Save'
				click_event_fn: save_click
			),
			ui.MenuItem.new(
				text:           'Run'
				uicon:          '\uEA16'
				click_event_fn: run_click
			),
			ui.MenuItem.new(
				text:  'Manage Modules..'
				uicon: '\uEAE8'
				// click_event_fn: vpm_click_
			),
			ui.MenuItem.new(
				text:           'Settings'
				uicon:          '\uF8B0'
				click_event_fn: settings_click
			),
			ui.MenuItem.new(
				text:  'Manage V'
				uicon: '\uEC7A'
				// click_event_fn: show_install_modal
			),
		]
	)

	edit_menu := ui.MenuItem.new(
		text: 'Edit'
		// icon: edit_icon
		uicon: '\uE104'
	)

	help_menu := ui.MenuItem.new(
		text:  'Help'
		uicon: '\uEA0D'
		// icon:     help_icon
		children: [
			ui.MenuItem.new(
				text:           'About Vide'
				click_event_fn: about_click
			),
			ui.MenuItem.new(
				text:           'Github'
				click_event_fn: gh_click
			),
			ui.MenuItem.new(
				text:           'Discord'
				click_event_fn: dis_click
			),
			ui.MenuItem.new(
				text: 'About iUI'
			),
		]
	)

	mut theme_menu := ui.MenuItem.new(
		text: 'Themes'
		// icon: theme_icon
		uicon: '\uE9D7'
	)

	themes := ui.get_all_themes()
	for theme2 in themes {
		item := ui.MenuItem.new(text: theme2.name, click_event_fn: on_theme_click)
		theme_menu.add_child(item)
	}

	item := ui.MenuItem.new(text: 'Vide Default Dark', click_event_fn: on_theme_click)
	theme_menu.add_child(item)

	item_ := ui.MenuItem.new(text: 'Vide Light Theme', click_event_fn: on_theme_click)
	theme_menu.add_child(item_)

	save_menu := ui.MenuItem.new(
		// text:           'Save'
		icon:           save_icon
		uicon:          '\uE105'
		click_event_fn: save_click
	)

	run_menu := ui.MenuItem.new(
		// text:           'Run'
		icon:           run_icon
		uicon:          '\uEA16'
		click_event_fn: run_click
	)

	fmt_menu := ui.MenuItem.new(
		// text:           'v fmt'
		icon:           fmt_icon
		uicon:          '\uEA5D'
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
	mut modal := ui.Modal.new(
		title:  'About VIDE'
		width:  380
		height: 250
	)

	mut p := ui.Panel.new(
		layout: ui.BoxLayout.new(ori: 1)
	)
	p.set_pos(8, 16)

	mut label := ui.Label.new(
		text: 'Simple IDE for the V Language made in V.\n\nVersion: ${version}\niUI: ${ui.version}'
	)

	label.pack()

	mut copy := ui.Label.new(
		text:    'Copyright © 2021-2025 by Isaiah.'
		em_size: 0.8
		pack:    true
	)
	copy.set_pos(16, 175)

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
