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
	win_width  = 710
	win_height = 400
)

struct App {
mut:
	window     &ui.Window = 0
	group        &ui.Label = 0
	project_name string
	project_description  string
}

fn main() {
	mut home := os.home_dir()
	mut vpm_image := home + '/Vide/vpm.png'
	mut app := &App{}
	app.group = ui.label(
		text: &app.project_name
	)
	app.window = ui.window({
		width: win_width
		height: win_height
		title: 'VIDE VPM GUI'
		state: app
	}, [
		ui.row({
			margin: (
				left: 16, 
				right: 16
				bottom: 32,
				top:8
			)
		}, [
			ui.column({
				margin: (
					left: 8, 
					right: 32,
					bottom: 32,
					top:0
				)
			},[
				ui.picture(
					width: 100
					height: 50
					path: vpm_image
				),
			]),
			ui.column({
				margin: (
					left: 25, 
					right: 8,
					bottom: 32,
					top:0
				)
			},[ 
				ui.label(text: ' '),
			]),
			ui.column({
				margin: (
					left: 34, 
					right: 32,
					bottom: 32,
					top:8
				)
			},[
				ui.button(
					width: 170
					text: 'List installed modules'
					onclick: btn_list_modules
				),
			]),
			ui.column({
				margin: (
					left: 42, 
					right: 32,
					bottom: 32,
					top:8
				)
			},[
				ui.button(
					width: 200
					text: 'Update all outdated modules'
					onclick: btn_upgrade_modules
				),
			]),
		]),
		ui.row({
			margin: (
				left: 24, 
				right: 16
				bottom: 16,
				top:52
			)
		}, [
			
			ui.textbox(
				max_len: 200
				width: 400
				placeholder: ''
				text: &app.project_description
			),
			ui.column({
				margin: (
					left: 4, 
					right: 4,
					bottom: 0,
					top:0
				)
			},[
				ui.button(
					width: 134
					text: 'Send as command'
					onclick: btn_change_title
				) 
			]),
		]),
		ui.row({
			margin: (
				left: 16, 
				right: 16
				bottom: 16,
				top:35
			)
		}, [
			ui.row({
				margin: (
					left: 4, 
					right: 4,
					bottom: 0,
					top:0
				)
			},[
				ui.button(
					width: 134
					text: 'Search'
					onclick: btn_search_modules
				),
				ui.label(text: ' '),
				ui.button(
					width: 134
					text: 'Install'
					onclick: btn_install_module
				),
				ui.label(text: ' '),
				ui.button(
					width: 134
					text: 'Remove'
					onclick: btn_remove_module
				),
				ui.label(text: ' '),
				ui.button(
					width: 134
					text: 'Update'
					onclick: btn_update_module
				) 
			]),
		]),
		ui.label(text: '\n')
		ui.column({
			margin: (
				left: 16
				right: 16
				bottom: 8
				top: 60
			)
		}, [
			app.group
		]),
	])
	ui.run(app.window)
}

fn btn_change_title(mut app App, e &ui.Button) {
	mut s := exec(app.project_description) or { return }
	mut st := s.output.replace('\r', '')
	app.group.set_text( st )
}

fn btn_list_modules(mut app App, e &ui.Button) {
	mut s := exec('v list') or { return }
	mut st := s.output.replace('\r', '')
	ui.message_box( st )
}

fn btn_search_modules(mut app App, e &ui.Button) {
	mut s := exec('v search ' + app.project_description) or { return }
	mut st := s.output.replace('\r', '')
	ui.message_box( st )
}

fn btn_upgrade_modules(mut app App, e &ui.Button) {
	mut s := exec('v upgrade') or { return }
	mut st := s.output.replace('\r', '')
	ui.message_box( st )
}

fn btn_update_module(mut app App, e &ui.Button) {
	mut s := exec('v update ' + app.project_description) or { return }
	mut st := s.output.replace('\r', '')
	ui.message_box( st )
}

fn btn_install_module(mut app App, e &ui.Button) {
	mut s := exec('v install ' + app.project_description) or { return }
	mut st := s.output.replace('\r', '')
	ui.message_box( st )
}

fn btn_remove_module(mut app App, e &ui.Button) {
	mut s := exec('v remove ' + app.project_description) or { return }
	mut st := s.output.replace('\r', '')
	ui.message_box( st )
}