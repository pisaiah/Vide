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
	win_width  = 270
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
		title: 'New Project'
		state: app
	}, [
		ui.group({
			x: 30
			y: 50
			title: 'New Project'
		}, [
			ui.label(text: ' \n'),
			ui.textbox(
				max_len: 20
				width: 200
				placeholder: 'Project Name...'
				text: &app.project_name
			),
			ui.textbox(
				max_len: 50
				width: 200
				placeholder: 'Description...'
				text: &app.project_description
			),
			ui.label(text: ' \n'),
			ui.button(
				text: 'Create project ...'
				onclick: btn_change_title
			),
		])
	])
	ui.run(app.window)
}

fn btn_change_title(mut app App, btn &ui.Button) {
	println('vide_new_project_command=' + app.project_name + ", " + app.project_description)
	mut home := os.home_dir()
	os.mkdir(home + '/Vide/projects/' + app.project_name)
	mut vfile := home + '/Vide/projects/' +app.project_name + '/' + app.project_name + '.v'
	mut vmod := home + '/Vide/projects/' +app.project_name + '/v.mod'
	if !os.is_file(vfile) {
		os.write_file(vfile, 'module main\n\nfn main() {\n\tprintln("Hello World!")\n}')
		os.write_file(vmod, "Module {\n\tname: '" + app.project_name + "'\n\tdescription: '" + app.project_description + "'\n\tversion: '0.0.0'\n\tdependencies: []\n}")
		ui.message_box('Project created!')
	} else {
		ui.message_box('Project already exists!')
	}
	exit(1)
}