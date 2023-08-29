//
// Verminal - Terminal Emulator in V
// https://github.com/isaiahpatton/verminal
//
module main

import iui as ui
import os

pub fn create_box(mut win ui.Window) &ui.Textbox {
	path := os.real_path(os.home_dir())
	win.extra_map['path'] = path

	mut box := ui.text_box([path + '>'])
	box.set_id(mut win, 'vermbox')

	box.subscribe_event('draw', vermbox_draw)

	box.before_txtc_event_fn = before_txt_change
	box.set_bounds(0, 0, 300, 80)

	return box
}

fn vermbox_draw(mut e ui.DrawEvent) {
	mut this := e.ctx.win.get[&ui.Textbox]('vermbox')

	this.caret_y = this.lines.len - 1
	line := this.lines[this.caret_y]
	cp := e.ctx.win.extra_map['path']

	if line.contains(cp + '>') {
		if this.caret_x < cp.len + 1 {
			this.caret_x = cp.len + 1
		}
	}

	hei := (this.lines.len + 1) * ui.get_line_height(e.ctx)
	pw := this.parent.height
	if hei < pw {
		this.height = pw
	} else {
		this.height = hei
	}

	this.width = this.parent.width

	if 'update_scroll' in e.ctx.win.extra_map {
		jump_sv(mut e.ctx.win, this.height, this.lines.len)
		e.ctx.win.extra_map.delete('update_scroll')
	}
}

fn before_txt_change(mut win ui.Window, tb ui.Textbox) bool {
	is_backsp := tb.last_letter == 'backspace'

	if is_backsp {
		txt := tb.lines[tb.caret_y]
		path := win.extra_map['path']
		if txt.ends_with(path + '>') {
			return true
		}
	}

	is_enter := tb.last_letter == 'enter'
	jump_sv(mut win, tb.height, tb.lines.len)

	if is_enter {
		mut tbox := win.get[&ui.Textbox]('vermbox')
		tbox.last_letter = ''

		mut txt := tb.lines[tb.caret_y]
		mut cline := txt // txt[txt.len - 1]
		mut path := win.extra_map['path']

		if cline.contains(path + '>') {
			mut cmd := cline.split(path + '>')[1]
			on_cmd(mut win, tb, cmd)
		}
		return true
	}
	return false
}

fn jump_sv(mut win ui.Window, tbh int, lines int) {
	mut sv := win.get[&ui.ScrollView]('vermsv')
	val := tbh - sv.height
	if lines <= 1 {
		sv.scroll_i = 0
		return
	}
	sv.scroll_i = val / sv.increment
}

fn on_cmd(mut win ui.Window, box ui.Textbox, cmd string) {
	args := cmd.split(' ')

	mut tbox := win.get[&ui.Textbox]('vermbox')
	if args[0] == 'cd' {
		cmd_cd(mut win, mut tbox, args)
		add_new_input_line(mut tbox, win)
	} else if args[0] == 'help' {
		tbox.lines << win.extra_map['verm-help']
		add_new_input_line(mut tbox, win)
	} else if args[0] == 'version' || args[0] == 'ver' {
		tbox.lines << 'Verminal: 0.5, UI: ' + ui.version
		add_new_input_line(mut tbox, win)
	} else if args[0] == 'cls' || args[0] == 'clear' {
		tbox.lines.clear()
		tbox.scroll_i = 0
		add_new_input_line(mut tbox, win)
	} else if args[0] == 'font-size' {
		win.font_size = args[1].int()
		add_new_input_line(mut tbox, win)
	} else if args[0] == 'dira' {
		mut path := win.extra_map['path']
		cmd_dir(mut tbox, path, args)
		add_new_input_line(mut tbox, win)
	} else if args[0] == 'loadfiles' {
		$if emscripten ? {
			C.emscripten_run_script(c'mui.trigger = "lloadfiles"')
		}
		mut com := win.get[&ui.Tree2]('proj-tree')
		if args.len == 1 {
			refresh_tree(mut win, '/home/web_user/.vide/workspace', mut com)
		} else {
			refresh_tree(mut win, args[1], mut com)
		}
	} else if args[0] == 'v' || args[0] == 'dir' || args[0] == 'git' {
		spawn verminal_cmd_exec(mut win, mut tbox, args)
	} else if args[0].len == 2 && args[0].ends_with(':') {
		win.extra_map['path'] = os.real_path(args[0])
		add_new_input_line(mut tbox, win)
		tbox.caret_y += 1
	} else {
		verminal_cmd_exec(mut win, mut tbox, args)
	}

	jump_sv(mut win, box.height, tbox.lines.len)

	win.extra_map['update_scroll'] = 'true'
	win.extra_map['lastcmd'] = cmd
}

fn wasm_save_files() {
	$if emscripten ? {
		C.emscripten_run_script(c'mui.trigger = "savefiles"')
	}
}

fn write_file(path string, text string) ! {
	println('Writing content to ${path}')
	os.write_file(path, text)!
	if path.ends_with('.v') || path.ends_with('.mod') {
		wasm_save_files()
	}
}

fn add_new_input_line(mut tbox ui.Textbox, win &ui.Window) {
	tbox.lines << win.extra_map['path'] + '>'
}
