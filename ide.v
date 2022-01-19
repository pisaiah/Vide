module main

import gg
import iui as ui
import os
import examples.ide.hc

const (
	version = '0.0.2'
)

[console]
fn main() {
	// Hide Console
	hc.hide_console_win()

	// TODO: Test with other fonts
	// 		 The Textbox carrot is off with other fonts.

	mut font := $embed_file('assets/DroidSansMono.ttf')
	mut font_path := os.temp_dir() + '/VideFont.ttf'
	os.write_file(font_path, font.to_string()) or {}

	// Create Window
	mut window := ui.window_with_font(ui.get_system_theme(), 'Vide', 800, 500, font_path)

	// our custom config
	mut conf := config(mut window)

	// Set Saved Theme
	set_theme_from_save(mut window)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

	mut file_menu := ui.menuitem('File')
	mut file_img := $embed_file('assets/icons8-file-48.png')
	file_menu.icon = ui.image_from_byte_array_with_size(mut window, file_img.to_bytes(),
		24, 24)

	mut new_proj := ui.menuitem('New Project...')
	new_proj.set_click(new_project_click)
	file_menu.add_child(new_proj)

	mut save := ui.menuitem('Save')
	save.set_click(save_click)
	file_menu.add_child(save)

	mut run := ui.menuitem('Run')
	run.set_click(run_click)
	file_menu.add_child(run)

	mut settings := ui.menuitem('Settings')
	settings.set_click(settings_click)
	file_menu.add_child(settings)

	window.bar.add_child(file_menu)

	mut edit := ui.menuitem('Edit')
	mut edit_img := $embed_file('assets/icons8-edit-24.png')
	edit.icon = ui.image_from_byte_array_with_size(mut window, edit_img.to_bytes(), 24,
		24)
	window.bar.add_child(edit)

	mut help := ui.menuitem('Help')
	mut help_img := $embed_file('assets/icons8-help-24.png')
	help.icon = ui.image_from_byte_array_with_size(mut window, help_img.to_bytes(), 24,
		24)

	mut theme_menu := ui.menuitem('Themes')
	mut theme_img := $embed_file('assets/icons8-themes-48.png')
	theme_menu.icon = ui.image_from_byte_array_with_size(mut window, theme_img.to_bytes(),
		24, 24)

	mut about := ui.menuitem('About iUI')

	mut about_vide := ui.menuitem('About Vide')
	about_vide.set_click(about_click)
	help.add_child(about_vide)

	mut themes := [ui.theme_default(), ui.theme_dark(), ui.theme_dark_hc(),
		ui.theme_black_red(), ui.theme_minty()]
	for theme2 in themes {
		mut item := ui.menuitem(theme2.name)
		item.set_click(on_theme_click)
		theme_menu.add_child(item)
	}

	help.add_child(about)
	window.bar.add_child(help)
	window.bar.add_child(theme_menu)

	mut save_img := $embed_file('assets/icons8-save-48.png')
	mut savee := ui.menuitem('Save')
	mut icon := ui.image_from_byte_array_with_size(mut window, save_img.to_bytes(), 24,
		24)
	savee.icon = icon
	savee.set_click(save_click)
	window.bar.add_child(savee)

	folder := conf.get_or_default('workspace_dir')
		.replace('{user_home}', os.home_dir().replace('\\', '/'))

	window.extra_map['workspace'] = folder
	os.mkdir_all(folder) or {}

	mut tree := ui.tree(window, 'Projects')
	tree.is_selected = true
	tree.set_bounds(0, 27, 150, 200)
	tree.draw_event_fn = fn (mut win ui.Window, mut tree ui.Component) {
		tree.height = gg.window_size().height
	}

	make_tree(mut window, folder, mut tree)

	window.add_child(tree)

	mut tb := ui.tabbox(window)
	tb.set_bounds(200, 35, 200, 80)

	tb.draw_event_fn = on_draw
	window.add_child(tb)

	welcome_tab(mut window, mut tb, folder)

	mut console_box := ui.textbox(window, 'Console Output:')
	window.add_child(console_box)

	window.gg.run()
}

fn welcome_tab(mut window ui.Window, mut tb ui.Tabbox, folder string) {
	mut tbtn1 := ui.label(window,
		'Welcome to Vide! A simple IDE for V made in V.\n
Note: Currently alpha software!\n\nVersion:\n    VIDE' +
		"\n    Isaiah's Widget Toolkit")

	tbtn1.set_pos(10, 90)
	tbtn1.pack()

	mut ver_lbl := ui.label(window, 'version ' + version + '\nversion ' + ui.version)
	ver_lbl.set_pos(220, 155)
	ver_lbl.pack()

	mut logo := window.gg.create_image_from_byte_array(vide_png.to_bytes())
	mut logo_im := ui.image(window, logo)
	logo_im.set_bounds(1, 8, 188, 75)

	tb.add_child('Welcome', tbtn1)
	tb.add_child('Welcome', ver_lbl)
	tb.add_child('Welcome', logo_im)
}

fn new_tab(mut window ui.Window, file string, mut tb ui.Tabbox) {
	mut lines := os.read_lines(file) or { ['ERROR while reading file contents'] }
	mut content := ''
	for mut str in lines {
		if content.len > 0 {
			content = content + '\n' + str.replace('\t', ' '.repeat(8))
		} else {
			content = content + str.replace('\r', '')
		}
	}

	mut code_box := ui.textbox(window, content)
	code_box.draw_event_fn = on_box_draw
	code_box.set_bounds(2, 2, 320, 120)
	code_box.set_codebox(true)
	tb.add_child(file, code_box)
	tb.active_tab = file
}

fn set_console_text(mut win ui.Window, out string) {
	for mut comm in win.components {
		if mut comm is ui.Textbox {
			comm.text = out
		}
	}
}

fn run_v(dir string, mut win ui.Window) {
	mut vexe := 'v'
	if 'VEXE' in os.environ() {
		vexe = os.environ()['VEXE']
	}

	mut out := os.execute(vexe + ' run ' + dir)
	for mut comm in win.components {
		if mut comm is ui.Textbox {
			comm.text = out.output
		}
	}
}
