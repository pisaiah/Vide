module main

import iui as ui
import os


fn on_theme_click(mut win ui.Window, com ui.MenuItem) {
	theme := ui.theme_by_name(com.text)
	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Vide')

    mut logo := win.gg.create_image(os.resource_abs_path('assets/vide.png'))
	mut logo_im := ui.image(win, logo)
	logo_im.set_bounds( (300/2), 14, 188, 75)

	mut label := ui.label(win, 'Vide - Small IDE for V made in V.\nVersion: ' + version +
		'\nUI Version: ' + ui.version +
		'\n\nCopyright © 2021-2022 Isaiah.\nAll Rights Reserved.')

	label.set_pos(155, 110)
	label.pack()

    modal.add_child(logo_im)
	modal.add_child(label)
	win.add_child(modal)
}

fn save_click(mut win ui.Window, item ui.MenuItem) {
	for mut com in win.components {
		if mut com is ui.Tabbox {
			txt := com.active_tab

			mut tab := com.kids[com.active_tab]
			for mut child in tab {
				if mut child is ui.Textbox {
					set_console_text(mut win, 'Saved file to ' + com.active_tab)
					os.write_file(com.active_tab, child.text) or {
						set_console_text(mut win, 'Unable to save file!')
					}	
				}
			}

			return
		}
	}
}

fn run_click(mut win ui.Window, item ui.MenuItem) {
	for mut com in win.components {
		if mut com is ui.Tabbox {
			txt := com.active_tab
			dir := os.dir(txt)

			go run_v(dir, mut win)

			return
		}
	}
}