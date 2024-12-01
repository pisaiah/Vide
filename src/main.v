// VIDE - A simple IDE for V
// (c) 2021-2024 Isaiah.
module main

import iui as ui
import os

const version = '0.1-pre'

@[heap]
pub struct App {
mut:
	win             &ui.Window
	tb              &ui.Tabbox
	collapse_tree   bool
	collapse_search bool = true
	shown_activity  int
	activty_speed   int = 30
	confg           &Config
	popup           &MyPopup
}

pub fn C.emscripten_run_script(&char)

fn main() {
	vide_home := os.join_path(os.home_dir(), '.vide')
	mut folder := os.join_path(vide_home, 'workspace')

	os.mkdir_all(folder) or {}

	confg := make_config()

	mut win := ui.Window.new(
		width:     900
		height:    550
		title:     'Vide'
		font_size: confg.font_size
		font_path: confg.font_path
		ui_mode:   true
	)

	$if windows {
		ui.set_power_save(true)
	}

	if os.exists(confg.workspace_dir) {
		folder = confg.workspace_dir
	}

	win.set_theme(vide_dark_theme())

	mut app := &App{
		win:   win
		tb:    ui.Tabbox.new()
		confg: confg
		popup: code_popup()
	}

	win.id_map['app'] = app

	app.make_menubar()

	mut hbox := ui.Panel.new(
		layout: ui.BoxLayout.new(
			hgap: 0
			vgap: 0
		)
	)

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

	for name in app.confg.open_paths {
		if os.exists(name) {
			new_tab(win, name)
		}
	}

	mut console_box := create_box(mut win)
	console_box.z_index = 2
	console_box.set_id(mut win, 'consolebox')

	mut sv := ui.ScrollView.new(
		view:      console_box
		increment: 5
		bounds:    ui.Bounds{
			width:  300
			height: 100
		}
		padding:   0
	)
	sv.noborder = true
	sv.set_id(mut win, 'vermsv')

	mut spv := ui.SplitView.new(
		first:       app.tb
		second:      sv
		min_percent: 20
		h1:          70
		h2:          20
		bounds:      ui.Bounds{
			y:      3
			x:      2
			width:  400
			height: 400
		}
	)

	app.tb.subscribe_event('draw', tabbox_fill_width)
	sv.subscribe_event('draw', terminal_scrollview_fill)
	spv.subscribe_event('draw', splitview_fill)

	hbox.add_child(spv)

	win.add_child(hbox)
	win.gg.run()
}

fn (mut app App) make_activity_bar() &ui.NavPane {
	mut np := ui.NavPane.new(
		pack:      true
		collapsed: true
	)

	mut item1 := ui.NavPaneItem.new(
		icon: '\uED43'
		text: 'Workspace'
	)

	mut item2 := ui.NavPaneItem.new(
		icon: '\uF002'
		text: 'Search'
	)

	mut item3 := ui.NavPaneItem.new(
		icon: '\uEAE7'
		text: 'Git'
	)

	mut item4 := ui.NavPaneItem.new(
		icon: '\uE713'
		text: 'Settings'
	)

	item1.subscribe_event('mouse_up', app.calb_click)
	item2.subscribe_event('mouse_up', app.serb_click)
	item3.subscribe_event('mouse_up', app.calb_click)
	item4.subscribe_event('mouse_up', app.settings_btn_click)

	np.add_child(item1)
	np.add_child(item2)
	np.add_child(item3)
	np.add_child(item4)

	return np
}

fn (mut app App) settings_btn_click(e &ui.MouseEvent) {
	mut tar := e.target
	if mut tar is ui.NavPaneItem {
		tar.unselect()
	}

	app.show_settings()
}

@[deprecated: 'Replaced by ui.NavPane']
fn (mut app App) make_activity_bar_old() &ui.Panel {
	mut activity_bar := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori:  1
			hgap: 4
		)
	)
	activity_bar.set_bounds(0, 0, 40, 200)

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
	gg_im := ggc.create_image_from_byte_array(data) or { return ui.Button.new(text: 'NO IMG') }
	cim := ggc.cache_image(gg_im)
	mut btn := ui.Button.new(icon: cim)

	btn.set_bounds(0, 5, 33, 46)
	btn.z_index = 5

	// btn.border_radius = -1
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

	mut sv := ui.ScrollView.new(
		view:    tree2
		bounds:  ui.Bounds{1, 3, 250, 200}
		padding: 0
	)
	sv.subscribe_event('draw', app.proj_tree_draw)
	tree2.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		e.target.width = e.target.parent.width
	})

	tree2.set_id(mut window, 'proj-tree')
	return sv // tree2
}

fn (mut app App) setup_search(mut window ui.Window, folder string) &ui.ScrollView {
	mut search_box := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori: 1
		)
	)

	search_box.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		// e.ctx.gg.draw_rect_empty(e.target.x, e.target.y, e.target.width, e.target.height,
		//	gx.blue)
		e.target.width = 200
		e.target.height = 100 + e.target.children[1].height
	})

	mut search_field := ui.text_field(
		text:   'Search ...'
		bounds: ui.Bounds{1, 1, 190, 25}
	)
	search_box.add_child(search_field)

	mut search_out := ui.Panel.new(layout: ui.BoxLayout.new(ori: 1))
	search_box.add_child(search_out)
	search_out.set_bounds(0, 0, 200, 0)

	search_field.subscribe_event('before_text_change', fn [mut app, mut search_field, mut search_out] (mut e ui.TextChangeEvent) {
		if search_field.last_letter != 'enter' {
			return
		}
		search_out.children.clear()

		txt := e.target.text
		dir := app.confg.workspace_dir
		read_files(dir, txt, mut search_out, e.ctx)

		dump(e.target.text)
	})

	mut stb := ui.Titlebox.new(text: 'Search', children: [search_box])
	stb.set_bounds(4, 4, 200, 250)

	// hbox.add_child(stb)
	mut sv := ui.ScrollView.new(
		view:    stb
		bounds:  ui.Bounds{1, 4, 240, 200}
		padding: 0
	)
	sv.subscribe_event('draw', app.search_pane_draw)
	stb.subscribe_event('draw', fn (mut e ui.DrawEvent) {
		e.target.width = e.target.parent.width - 7
	})

	stb.set_id(mut window, 'stb')
	return sv // tree2
}

fn read_files(dir string, txt string, mut search_out ui.Panel, ctx &ui.GraphicsContext) {
	ls := os.ls(dir) or { [] }

	for file in ls {
		jp := os.join_path(dir, file)
		if os.is_dir(jp) {
			read_files(jp, txt, mut search_out, ctx)
			continue
		}

		if !(file.ends_with('.v') || file.ends_with('.md') || file.ends_with('.c')) {
			continue
		}

		lines := os.read_lines(jp) or { [] }
		for i, line in lines {
			if line.contains(txt) {
				mut btn := ui.Label.new(text: '${file}: ${i + 1}:\n${line.trim_space()}')
				btn.pack_do(ctx)
				search_out.add_child(btn)
			}
		}
	}
	if search_out.children.len > 0 {
		dump(search_out.children.len)
		search_out.set_bounds(0, 0, 200, search_out.children.len * (search_out.children[0].height +
			5))
	}
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
