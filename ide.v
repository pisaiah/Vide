import gg
import iui as ui
import time
import os

const (
	version = '0.1'
)

[console]
fn main() {
	// Create Window
	mut window := ui.window(ui.get_system_theme(), 'Vide - IDE for V. [0.1]', 800, 500)

	// Setup Menubar and items
	window.bar = ui.menubar(window, window.theme)

    mut file_menu := ui.menuitem('File')

	mut save := ui.menuitem('Save')
	save.set_click(save_click)
	file_menu.add_child(save)

    mut run := ui.menuitem('Run')
	run.set_click(run_click)
	file_menu.add_child(run)

	window.bar.add_child(file_menu)
	window.bar.add_child(ui.menuitem('Edit'))

	mut help := ui.menuitem('Help')
	mut theme_menu := ui.menuitem('Themes')
	mut about := ui.menuitem('About iUI')

	for i := 0; i < 3; i++ {
		mut item := ui.menuitem('Item ' + i.str())
		help.add_child(item)
	}

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

	folder := os.home_dir().replace('\\', '/') + '/vide/workspace'
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

	mut tbtn1 := ui.label(window,
		'Welcome to Vide! A simple IDE for V made in V.\n
Note: Currently alpha software!\n\nDefault Workspace dir:     ' +
		folder + '\nDefault font size:\t14px\n\nVersion:\n\tVIDE\t\t\t     version ' + version +
		"\n\tIsaiah's UI Widget Toolkit\tversion " + ui.version)

	tbtn1.set_pos(1, 90)
	tbtn1.pack()

	mut logo := window.gg.create_image(os.resource_abs_path('vide.png'))
	mut logo_im := ui.image(window, logo)
	logo_im.set_bounds(1, 8, 188, 75)

	tb.add_child('Welcome', tbtn1)
	tb.add_child('Welcome', logo_im)

	mut console_box := ui.textbox(window, 'Console Output:')
	window.add_child(console_box)

	window.gg.run()
}

fn new_tab(mut window ui.Window, file string, mut tb ui.Tabbox) {
	mut lines := os.read_lines(file) or { ['ERROR while reading file contents'] }
	mut content := ''
	for mut str in lines {
		if content.len > 0 {
			content = content + '\n' + str.replace('\t', ' '.repeat(8))
		} else {
			content = content + str
		}
	}

	mut code_box := ui.textbox(window, content)
	code_box.draw_event_fn = on_box_draw
	code_box.set_bounds(2, 2, 320, 120)
	code_box.set_codebox(true)
	tb.add_child(file, code_box)
	tb.active_tab = file
}

fn make_tree(mut window ui.Window, fold string, mut tree ui.Tree) ui.Tree {
	mut files := os.ls(fold) or { [] }

	for fi in files {
		if fi.starts_with('.git') {
			continue
		}
		mut sub := ui.tree(window, fold + '/' + fi)
		sub.set_bounds(4, 4, 100, 25)
		sub.set_click(tree_click)

		if !fi.starts_with('.') {
			make_tree(mut window, fold + '/' + fi, mut sub)
		}
		tree.childs << sub
	}
	return tree
}

fn tree_click(mut win ui.Window, tree ui.Tree) {
	txt := tree.text
	if txt.ends_with('.v') {
		for mut com in win.components {
			if mut com is ui.Tabbox {
				new_tab(mut win, txt, mut com)
			}
		}
	}
}

fn on_box_draw(mut win ui.Window, mut tb ui.Component) {
	mut x_off := 0
	mut y_off := 0
	for mut com in win.components {
		if mut com is ui.Tabbox {
			x_off = com.x
			y_off = com.height - 28
			break
		}
	}
	if tb.height != y_off {
		tb.height = y_off
	}
	width := gg.window_size().width - x_off - 8

	if tb.width != width {
		tb.width = width
	}
}

fn on_draw(mut win ui.Window, mut tb ui.Component) {
	mut x_off := 0
	mut y_off := 0
	for mut com in win.components {
		if mut com is ui.Tree {
			x_off = com.x + com.width
			y_off = gg.window_size().height - com.y - 12
			break
		}
	}
	if tb.x != x_off {
		tb.x = x_off
	}
	y_off -= 100
	if tb.height != y_off {
		tb.height = y_off - 4
	}
	width := gg.window_size().width - x_off - 4

	if tb.width != width {
		tb.width = width
	}
	for mut com in win.components {
		if mut com is ui.Textbox {
			com.x = x_off
			com.y = y_off + 38
			com.height = 99
			com.width = width
		}
	}
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

fn set_console_text(mut win ui.Window, out string) {
	for mut comm in win.components {
		if mut comm is ui.Textbox {
			comm.text = out
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

fn run_v(dir string, mut win ui.Window) {
	mut out := os.execute(@VEXE + ' run ' + dir)
	for mut comm in win.components {
		if mut comm is ui.Textbox {
			comm.text = out.str()
		}
	}
}

fn on_theme_click(mut win ui.Window, com ui.MenuItem) {
	theme := ui.theme_by_name(com.text)
	win.set_theme(theme)
}

fn about_click(mut win ui.Window, com ui.MenuItem) {
	mut modal := ui.modal(win, 'About Vide')

    mut logo := win.gg.create_image(os.resource_abs_path('vide.png'))
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
