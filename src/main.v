// Vɪᴅᴇ - A simple IDE for V
// (c) 2021-2023 Isaiah.
module main

import iui as ui
import os
import gg
import gx

const (
	version = '0.1-pre'
)

[heap]
struct App {
mut:
	win             &ui.Window
	tb              &ui.Tabbox
	collapse_tree   bool
	collapse_search bool = true
	shown_activity  int
	activty_speed   int = 20
	confg           &Config
}

pub fn C.emscripten_run_script(&char)

fn main() {
	vide_home := os.join_path(os.home_dir(), '.vide')
	folder := os.join_path(vide_home, 'workspace')

	os.mkdir_all(folder) or {}

	confg := make_config()

	mut win := ui.make_window(
		width: 900
		height: 550
		title: 'Vide'
		font_size: 18
		font_path: confg.font_path
	)

	win.set_theme(vide_dark_theme())

	mut app := &App{
		win: win
		tb: ui.tabbox(win)
		confg: confg
	}
	
	win.id_map['app'] = app

	app.make_menubar()

	mut hbox := ui.hbox(win)
	hbox.overflow_full = false

	tree := app.setup_tree(mut win, folder)

	activity_bar := app.make_activity_bar()
	hbox.add_child(activity_bar)

	hbox.add_child(tree)

	// Search box
	search := app.setup_search(mut win, folder)
	hbox.add_child(search)
	// end;

	app.tb.set_id(mut win, 'main-tabs')
	app.tb.set_bounds(0, 0, 400, 200)
	app.welcome_tab('')

	mut console_box := create_box(mut win)
	console_box.z_index = 2
	console_box.set_id(mut win, 'consolebox')

	mut sv := ui.scroll_view(
		view: console_box
		increment: 5
		bounds: ui.Bounds{
			width: 300
			height: 100
		}
		padding: 0
	)
	sv.set_id(mut win, 'vermsv')

	mut spv := ui.split_view(
		first: app.tb
		second: sv
		min_percent: 20
		h1: 70
		h2: 20
		bounds: ui.Bounds{
			y: 28
			x: 2
			width: 400
			height: 400
		}
	)

	hbox.subscribe_event('draw', content_pane_fill_window)
	app.tb.subscribe_event('draw', tabbox_fill_width)
	sv.subscribe_event('draw', terminal_scrollview_fill)
	spv.subscribe_event('draw', splitview_fill)

	hbox.add_child(spv)

	win.add_child(hbox)
	win.gg.run()
}

// fn C.emscripten_run_script()

fn (mut app App) make_activity_bar() &ui.VBox {
	mut activity_bar := ui.vbox(app.win)
	activity_bar.set_bounds(0, 25, 41, 100)

	activity_bar.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		hei := e.ctx.gg.window_size().height
		e.ctx.theme.menu_bar_fill_fn(e.target.x, e.target.y, e.target.width, hei, e.ctx)
	})

	// Explore Button
	img_wide_file := $embed_file('assets/explore.png')
	mut calb := app.icon_btn(img_wide_file.to_bytes(), app.win)

	activity_bar.add_child(calb)

	calb.subscribe_event('mouse_up', app.calb_click)

	// Search Button
	img_search_file := $embed_file('assets/search.png')
	mut serb := app.icon_btn(img_search_file.to_bytes(), app.win)

	activity_bar.add_child(serb)

	serb.subscribe_event('mouse_up', app.serb_click)

	// Git Commit satus Button
	img_gitm_file := $embed_file('assets/merge.png')
	mut gitb := app.icon_btn(img_gitm_file.to_bytes(), app.win)

	activity_bar.add_child(gitb)

	gitb.subscribe_event('mouse_up', app.calb_click)

	return activity_bar
}

fn (mut app App) icon_btn(data []u8, win &ui.Window) &ui.Button {
	mut ggc := win.gg
	gg_im := ggc.create_image_from_byte_array(data) or { return ui.button(text: 'NO IMG') }
	cim := ggc.cache_image(gg_im)
	mut btn := ui.button_with_icon(cim)

	btn.set_bounds(4, 5, 33, 46)
	btn.z_index = 5
	btn.set_area_filled(false)
	btn.icon_height = 32
	return btn
}

fn (mut app App) setup_tree(mut window ui.Window, folder string) &ui.ScrollView {
	mut tree2 := ui.tree('My Workspace')
	tree2.set_bounds(0, 0, 250, 200)
	tree2.needs_pack = true

	files := os.ls(folder) or { [] }
	tree2.click_event_fn = tree2_click

	for fi in files {
		mut node := make_tree2(os.join_path(folder, fi))
		tree2.add_child(node)
	}

	mut sv := ui.scroll_view(
		view: tree2
		bounds: ui.Bounds{1, 28, 250, 200}
		// padding: 0
	)
	sv.subscribe_event('draw', app.proj_tree_draw)
	tree2.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		e.target.width = e.target.parent.width
	})

	tree2.set_id(mut window, 'proj-tree')
	return sv // tree2
}

fn (mut app App) setup_search(mut window ui.Window, folder string) &ui.ScrollView {
	mut search_box := &ui.Panel{
		x: 2
		y: 0
		width: 200
		height: 250
		layout: ui.FlowLayout{}
	}

	search_box.set_layout(ui.BoxLayout{ ori: 1 })

	search_box.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		e.ctx.gg.draw_rect_empty(e.target.x, e.target.y, e.target.width, e.target.height,
			gx.blue)
	})

	search_field := ui.text_field(
		text: 'Search ...'
		bounds: ui.Bounds{1, 1, 190, 25}
	)
	search_box.add_child(search_field)

	mut stb := ui.title_box('Search', [search_box])
	stb.set_bounds(4, 4, 200, 250)

	// hbox.add_child(stb)

	mut sv := ui.scroll_view(
		view: stb
		bounds: ui.Bounds{1, 28, 240, 200}
		// padding: 0
	)
	sv.subscribe_event('draw', app.search_pane_draw)
	stb.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		e.target.width = e.target.parent.width - 7
	})

	stb.set_id(mut window, 'stb')
	return sv // tree2
}

fn get_v_exe() string {
	mut saved := '' // config.get_value('v_exe').replace('\{user_home}', '~')
	dump(saved)
	saved = saved.replace('~', os.home_dir().replace('\\', '/'))

	if saved.len <= 0 {
		mut vexe := 'v'
		$if windows {
			vexe = 'v.exe'
		}
		if 'VEXE' in os.environ() {
			vexe = os.environ()['VEXE'].replace('\\', '/')
		}
		vexe = vexe.replace(os.home_dir().replace('\\', '/'), '~')
		// config.set('v_exe', vexe)
		// config.save()
		return vexe
	} else {
		return saved
	}
}
