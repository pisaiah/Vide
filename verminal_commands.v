// 
// Verminal - Terminal Emulator in V
// https://github.com/isaiahpatton/verminal
// 
module main

import iui as ui
import os

fn cmd_cd(mut win ui.Window, mut tbox ui.TextEdit, args []string) {
	mut path := win.extra_map['path']
	if args.len == 1 {
		tbox.text = tbox.text + path
		return
	}

	if args[1] == '..' {
		path = path.substr(0, path.replace('\\', '/').last_index('/') or { 0 }) // '
	} else {
		if os.is_abs_path(args[1]) {
			path = os.real_path(args[1])
		} else {
			path = os.real_path(path + '/' + args[1])
		}
	}
	if os.exists(path) {
		win.extra_map['path'] = path
	} else {
		tbox.text = tbox.text + 'Cannot find the path specified: ' + path
	}
}

fn cmd_dir(mut tbox ui.TextEdit, path string, args []string) {
	mut ls := os.ls(os.real_path(path)) or { [''] }
	mut txt := ' Directory of ' + path + '\n\n'
	for file in ls {
		txt = txt + '\t' + file + '\n'
	}
	// os.file_last_mod_unix(os.real_path(path + '/' + file)).str()
	tbox.text = tbox.text + txt
}

fn cmd_v(mut tbox ui.TextEdit, args []string) {
	mut pro := os.execute('cmd /min /c ' + args.join(' '))
	tbox.text = tbox.text + pro.output.trim_space()
}

fn verminal_cmd_exec(mut win ui.Window, mut tbox ui.TextEdit, args []string) {
	// Make sure we are in the correct directory
	os.chdir(win.extra_map['path']) or { tbox.lines << err.str() }

	if os.user_os() == 'windows' {
		cmd_exec_win(mut win, mut tbox, args)
	} else {
		cmd_exec_unix(mut win, mut tbox, args)
	}

	line_height := ui.text_height(win, 'A0{')
	shown_lines := tbox.height / line_height
	tbox.scroll_i = tbox.lines.len - shown_lines
}

// Linux
fn cmd_exec_unix(mut win ui.Window, mut tbox ui.TextEdit, args []string) {
	mut cmd := os.Command{
		path: args.join(' ')
	}

	cmd.start() or { tbox.lines << err.str() }
	for !cmd.eof {
		out := cmd.read_line()
		if out.len > 0 {
			for line in out.split_into_lines() {
				tbox.lines << line.trim_space()
			}
		}
	}
	add_new_input_line(mut tbox)

	cmd.close() or { tbox.lines << err.str() }
}

// Windows;
// os.Command not fully implemented on Windows, so cmd.exe is used
//
fn cmd_exec_win(mut win ui.Window, mut tbox ui.TextEdit, args []string) {
	mut pro := os.new_process('cmd')

	mut argsa := ['/min', '/c', args.join(' ')]
	pro.set_args(argsa)

	pro.set_redirect_stdio()
	pro.run()

	for pro.is_alive() {
		mut out := pro.stdout_read()
		if out.len > 0 {
			for line in out.split_into_lines() {
				tbox.lines << line.trim_space()
			}
		}
	}
	add_new_input_line(mut tbox)

	pro.close()
}
