// Verminal
module main

import iui as ui
import os

fn cmd_cd(mut win ui.Window, mut tbox ui.Textbox, args []string) {
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

fn cmd_dir(mut tbox ui.Textbox, path string, args []string) {
	mut ls := os.ls(os.real_path(path)) or { [''] }
	tbox.lines << ' Directory of "' + path + '".'
	for file in ls {
		tbox.lines << '\t' + file
	}
}

fn cmd_v(mut tbox ui.Textbox, args []string) {
	mut pro := os.execute('cmd /min /c ' + args.join(' '))
	tbox.text = tbox.text + pro.output.trim_space()
}

fn verminal_cmd_exec(mut win ui.Window, mut tbox ui.Textbox, args []string) {
	// Make sure we are in the correct directory
	os.chdir(win.extra_map['path']) or { tbox.lines << err.str() }

	if os.user_os() == 'windows' {
		cmd_exec_win(mut win, mut tbox, args)
	} else {
		cmd_exec_unix(mut win, mut tbox, args)
	}

	win.extra_map['update_scroll'] = 'true'
}

// Linux
fn cmd_exec_unix(mut win ui.Window, mut tbox ui.Textbox, args []string) {
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
	add_new_input_line(mut tbox, win)

	cmd.close() or { tbox.lines << err.str() }
}

// Windows
fn cmd_exec_win(mut win ui.Window, mut tbox ui.Textbox, args []string) {
	mut pro := os.new_process('C:\\Windows\\System32\\cmd.exe')

	mut argsa := ['/min', '/c', args.join(' ')]
	pro.set_args(argsa)

	pro.set_redirect_stdio()
	pro.run()

	for pro.is_alive() {
		mut out := pro.stdout_read()
		mut oute := pro.stderr_read()

		if oute.len > 0 {
			for line in oute.split_into_lines() {
				tbox.lines << line.trim_space()
			}
		}

		if out.len > 0 {
			for line in out.split_into_lines() {
				tbox.lines << line.trim_space()
			}
		}
	}
	add_new_input_line(mut tbox, win)

	pro.close()
}

// Run command without updating a text box
fn run_exec(args []string) []string {
	if os.user_os() == 'windows' {
		return run_exec_win(args)
	} else {
		return run_exec_unix(args)
	}
}

// Linux
fn run_exec_unix(args []string) []string {
	mut cmd := os.Command{
		path: args.join(' ')
	}

	mut content := []string{}
	cmd.start() or { content << err.str() }
	for !cmd.eof {
		out := cmd.read_line()
		if out.len > 0 {
			for line in out.split_into_lines() {
				content << line.trim_space()
			}
		}
	}

	cmd.close() or { content << err.str() }
	return content
}

// Windows;
fn run_exec_win(args []string) []string {
	mut pro := os.new_process('cmd')

	mut argsa := ['/min', '/c', args.join(' ')]
	pro.set_args(argsa)

	pro.set_redirect_stdio()
	pro.run()

	mut content := []string{}
	for pro.is_alive() {
		mut out := pro.stdout_read()
		if out.len > 0 {
			// println(out)
			for line in out.split_into_lines() {
				content << line.trim_space()
			}
		}
	}

	pro.close()
	return content
}
