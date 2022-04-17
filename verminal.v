//
// Verminal - Terminal Emulator in V
// https://github.com/isaiahpatton/verminal
//
module main

import iui as ui
import os

pub fn create_box(win_ptr voidptr) &ui.TextArea {
	mut win := &ui.Window(win_ptr)

	path := os.real_path(os.home_dir())
	win.extra_map['path'] = path

	mut box := ui.textarea(win, ['Verminal 0.4', path + '>'])
	box.code_syntax_on = false
	box.set_id(mut win, 'vermbox')
	box.draw_event_fn = box_draw
	box.before_txtc_event_fn = before_txt_change
	box.padding_y = 8

	return box
}

fn box_draw(mut win ui.Window, com &ui.Component) {
	mut this := *com
	if mut this is ui.TextArea {
		this.caret_top = this.lines.len - 1
		line := this.lines[this.caret_top]

		cp := win.extra_map['path']

		if line.contains(cp + '>') {
			if this.caret_left < cp.len + 1 {
				this.caret_left = cp.len + 1
			}
		}
	}
}

fn before_txt_change(mut win ui.Window, tb ui.TextArea) bool {
	mut is_backsp := tb.last_letter == 'backspace'

	if is_backsp {
		txt := tb.lines[tb.caret_top]
		path := win.extra_map['path']
		if txt.ends_with(path + '>') {
			return true
		}
	}

	mut is_enter := tb.last_letter == 'enter'

	if is_enter {
		mut txt := tb.lines[tb.caret_top]
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

fn on_cmd(mut win ui.Window, box ui.TextArea, cmd string) {
	args := cmd.split(' ')

	mut tbox := &ui.TextArea(win.get_from_id('vermbox')) //(mut win)
	if args[0] == 'cd' {
		cmd_cd(mut win, mut tbox, args)
		add_new_input_line(mut tbox)
	} else if args[0] == 'help' {
		tbox.lines << win.extra_map['verm-help']
		add_new_input_line(mut tbox)
	} else if args[0] == 'version' || args[0] == 'ver' {
		tbox.lines << 'Verminal - A terminal emulator written in V'
		tbox.lines << '\tVersion: 0.3'
		tbox.lines << '\tUI Version: ' + ui.version
		add_new_input_line(mut tbox)
	} else if args[0] == 'cls' || args[0] == 'clear' {
		tbox.lines.clear()
		tbox.scroll_i = 0
		add_new_input_line(mut tbox)
	} else if args[0] == 'font-size' {
		win.font_size = args[1].int()
		add_new_input_line(mut tbox)
	} else if args[0] == 'dira' {
		mut path := win.extra_map['path']
		cmd_dir(mut tbox, path, args)
		add_new_input_line(mut tbox)
	} else if args[0] == 'v' || args[0] == 'dir' || args[0] == 'git' {
		go verminal_cmd_exec(mut win, mut tbox, args)
	} else if args[0].len == 2 && args[0].ends_with(':') {
		win.extra_map['path'] = os.real_path(args[0])
		add_new_input_line(mut tbox)
		tbox.caret_top += 1
	} else {
		verminal_cmd_exec(mut win, mut tbox, args)
	}

	win.extra_map['lastcmd'] = cmd
}

fn add_new_input_line(mut tbox ui.TextArea) {
	tbox.lines << tbox.win.extra_map['path'] + '>'
}
