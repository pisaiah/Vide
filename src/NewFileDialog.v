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
	win_width  = 370
	win_height = 300
)

struct App {
mut:
	window     &ui.Window = 0
	group        &ui.Group = 0
	project_name string
	project_description  string
}

fn main() {
	mut app := &App{}
	app.window = ui.window({
		width: win_width
		height: win_height
		title: 'New File'
		state: app
	}, [
		ui.group({
			x: 30
			y: 30
			title: 'New File'
		}, [
			ui.label(
				text: '\nFolder: (relative to workspace)\n'
			),
			ui.textbox(
				max_len: 50
				width: 300
				placeholder: 'Project name...'
				text: &app.project_name
			),
			ui.label(
				text: '\nFile name:\n'
			),
			ui.textbox(
				max_len: 50
				width: 300
				placeholder: 'File name....'
				text: &app.project_description
			),
			ui.label(
				text: ' \n'
			),
			ui.button(
				text: 'Create new file ...'
				onclick: btn_change_title
			),
		])
	])
	ui.run(app.window)
}

fn btn_change_title(mut app App, btn &ui.Button) {
	mut home := os.home_dir()
	os.mkdir(home + '/Vide/projects/' + app.project_name) or { println('Error creating folder') }
	mut vfile := home + '/Vide/projects/' + app.project_name + '/' + app.project_description
	if !os.is_file(vfile) {
		os.write_file(vfile, 'module main\n\nfn main() {\n\tprintln("Hello World!")\n}') or { println('Error writing file') }
		ui.message_box('File created!')
	} else {
		ui.message_box('File already exists!')
	}
	exit(1)
}