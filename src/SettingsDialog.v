/*
 * VIDE: An IDE for V
 *
 * Copyright (c) 2021 Isaiah
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

import ui
import os


const (
	win_width  = 460
	win_height = 370
)

struct App {
mut:
	window     &ui.Window = 0
	group        &ui.Group = 0
	cb_dark     &ui.CheckBox = 0
	path_to_vexe string = @VEXE
	path_to_project_workspace  string = @FILE
}

fn main() {
	mut app := &App{}
	app.cb_dark = ui.checkbox(
		text: 'Dark Theme'
	)

	mut home := os.home_dir()
	os.mkdir(home + '/Vide/') or {}
	mut vfile := home + '/Vide/projects/'
	app.path_to_project_workspace = vfile

	load_settings(mut app)
	app.window = ui.window({
		width: win_width
		height: win_height
		title: 'Vide Settings'
		state: app
	}, [
		ui.group({
			x: 30
			y: 50
			title: 'VIDE Settings'
		}, [
			ui.label(
				text: ' \n'
			),
			ui.label(
				text: 'Path to VEXE to use for compiling:'			
			),
			ui.textbox(
				max_len: 400
				width: 380
				placeholder: 'Path to included vexe'
				text: &app.path_to_vexe
			),
			ui.label(
				text: '\nPath to workspace:'			
			),
			ui.textbox(
				max_len: 400
				width: 380
				placeholder: 'Description...'
				text: &app.path_to_project_workspace
			),
			ui.label(
				text: '\n'			
			),
			app.cb_dark,
			ui.label(
				text: ' \n'
			),
			ui.button(
				text: 'Save settings'
				onclick: btn_save_settings
			),
		])
	])
	ui.run(app.window)
}

fn load_settings(mut app App) {
	mut home := os.home_dir()
	os.mkdir(home + '/Vide/') or {}
	mut vfile := home + '/Vide/settings.txt'

	mut t := os.read_file(vfile) or { 'error' }
	mut splitted := t.split('\n')

	if splitted.len < 4 {
		return
	}

	mut dark := (splitted[1].split('=')[1] == 'true')
	mut vexe := (splitted[2].split('=')[1])
	mut workspace := (splitted[3].split('=')[1])

	app.cb_dark.checked = dark
	app.path_to_vexe = vexe
	app.path_to_project_workspace = workspace
}

fn btn_save_settings(mut app App, btn &ui.Button) {
	mut home := os.home_dir()
	os.mkdir(home + '/Vide/') or {}
	mut vfile := home + '/Vide/settings.txt'
	mut con := '# Vide Settings\n'
		+ 'dark=$app.cb_dark.checked\n' 
		+ 'vexe=' + app.path_to_vexe + '\n' 
		+ 'workspace=' + app.path_to_project_workspace


	if !os.is_file(app.path_to_vexe) {
		ui.message_box('Invalid VEXE path')	
	} else {
		os.write_file(vfile, con) or {}
		ui.message_box('Settings saved!')
		exit(1)
	}
}