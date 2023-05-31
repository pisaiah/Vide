module main

import iui as ui
import os

struct Config {
mut:
	cfg_dir       string = os.join_path(os.home_dir(), '.vide')
	workspace_dir string
	vexe          string
	font_path     string
	font_size     int    = 16
	theme         string = 'Vide Default Dark'
}

fn make_config() &Config {
	mut cfg := &Config{}

	file := os.join_path(cfg.cfg_dir, 'config.yml')

	if !os.exists(file) {
		cfg.load_defaults()
	} else {
		cfg.load_from_file()
	}

	cfg.save()

	return cfg
}

fn (mut this Config) load_from_file() {
	file := os.join_path(this.cfg_dir, 'config.yml')

	lines := os.read_lines(file) or { [''] }
	for line in lines {
		spl := line.split(': ')
		if spl[0].starts_with('# ') {
			continue
		}
		match spl[0] {
			'cfg_dir' { this.cfg_dir = spl[1] }
			'workspace_dir' { this.workspace_dir = spl[1] }
			'vexe' { this.vexe = spl[1] }
			'font_path' { this.font_path = spl[1] }
			'font_size' { this.font_size = spl[1].int() }
			'theme' { this.theme = spl[1] }
			else {}
		}
	}
}

fn (mut this Config) save() {
	file := os.join_path(this.cfg_dir, 'config.yml')

	data := [
		'# Vide Configuration',
		'cfg_dir: ${this.cfg_dir}',
		'workspace_dir: ${this.workspace_dir}',
		'vexe: ${this.vexe}',
		'font_path: ${this.font_path}',
		'font_size: ${this.font_size}',
		'theme: ${this.theme}',
	]

	mut lic := ['\n\n# LICENSE.txt:', '#', '# Copyright (c) 2021-2023 Isaiah\n#',
		'# Permission is hereby granted, free of charge, to any person obtaining a copy of this',
		'# software and associated documentation files (the “Software”), to deal in the Software',
		'# without restriction, including without limitation the rights to use, copy, modify, merge',
		'# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons',
		'# to whom the Software is furnished to do so, subject to the following conditions:\n#',
		'# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n#',
		'# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.']

	os.write_file(file, data.join('\n') + lic.join('\n')) or {}
}

fn (mut this Config) load_defaults() {
	dot_vide := os.join_path(os.home_dir(), '.vide')

	os.mkdir(dot_vide) or {}

	this.cfg_dir = dot_vide
	this.workspace_dir = os.join_path(dot_vide, 'workspace')

	mut font_path := os.join_path(dot_vide, 'FiraCode-Regular.ttf')
	if !os.exists(font_path) {
		mut font_file := $embed_file('assets/FiraCode-Regular.ttf')
		os.write_file_array(font_path, font_file.to_bytes()) or { font_path = ui.default_font() }
	}
	this.font_path = font_path
	this.vexe = 'v'
}
