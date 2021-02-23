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
import gx

const (
	win_width   = 270
	win_height  = 255
)


struct State {
mut:
	window     &ui.Window = voidptr(0)
}

fn main() {
	mut app := &State{
	}
	window := ui.window({
		resizable: false
		width: win_width
		height: win_height
		state: app
		always_on_top: true
		title: 'About VIDE'
	}, [
		ui.row({
			stretch: true
			margin: {
				top: 10
				left: 10
				right: 10
				bottom: 10
			}
		}, [
			ui.column({
				stretch: true
				alignment: .center
			}, [
				ui.picture(
					width: 250
					height: 100
					path: os.resource_abs_path('logo.png')
				),
				ui.label(text : '\nVIDE - The IDE for V\n'),
				ui.label(text: 'Version 0.1\n\nCopyright (C) 2021')
			]),
		]),
	])
	app.window = window
	ui.run(window)
}
