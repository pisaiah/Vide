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

const (
	win_width  = 350
	win_height = 350
)

struct App {
mut:
	window     &ui.Window = 0
	group        &ui.Label = 0
	project_name string
	project_description  string
}

fn main() {
	mut app := &App{}
	app.group = ui.label(
				text: &app.project_name
			)
	app.window = ui.window({
		width: win_width
		height: win_height
		title: 'New Project'
		state: app
	}, [
		ui.group({
			x: 10
			y: 10
			title: ' '
		}, [
			
			ui.textbox(
				max_len: 100
				width: 300
				placeholder: 'command'
				text: &app.project_description
			),
			ui.button(
				text: 'Create project ...'
				onclick: btn_change_title
			),
		]),
		ui.group({
				x:10
				y:78
				title: 'Test'
			}, [
				app.group
			]),
	])
	ui.run(app.window)
}

fn btn_change_title(mut app App, btn &ui.Button) {
	mut s := exec(app.project_description) or { return }
	mut st := s.output
	app.group.set_text( st )
}