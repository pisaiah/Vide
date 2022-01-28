module main

import iui as ui
import os
import time

const (
	default_config = [
		'# Vide Configuration',
		'workspace_dir = ~/vide/workspace',
		'v_flags = -skip-unused',
	].join_lines()
)

// Make Config as a 'Fake' Component
struct Config {
	ui.Component_A
pub mut:
	window &ui.Window
	conf   map[string]string
}

fn config(mut win ui.Window) &Config {
	mut config := &Config{
		window: win
	}
	win.add_child(config)
	config.read()
	return config
}

fn get_config(mut win ui.Window) &Config {
	for mut child in win.components {
		if mut child is Config {
			return child
		}
	}
	return 0
}

fn (mut this Config) read() {
	home := os.home_dir()
	os.mkdir(home + '/vide/') or {}
	file := home + '/vide/config.txt'

	if !os.exists(file) {
		os.write_file(file, default_config) or {}
	}

	mut lines := os.read_lines(file) or { ['ERROR while reading file contents'] }
	for line in lines {
		if !line.contains('=') {
			continue
		}
		spl := line.split('=')
		this.conf[spl[0].trim_space()] = spl[1].trim_space()
	}
	ui.debug('Vide: Loaded config.')
}

fn (mut this Config) get_or_default(key string) string {
	if key in this.conf {
		return this.conf[key]
	} else {
		for line in default_config.split_into_lines() {
			if line.starts_with(key) {
				spl := line.split('=')
				this.conf[spl[0].trim_space()] = spl[1].trim_space()
				return spl[1].trim_space()
			}
		}
	}
	return ''
}

fn (mut this Config) set(key string, val string) {
	this.conf[key] = val
}

fn (mut this Config) save() {
	mut con := '# Vide Configuration\n# Last Modified: ' + time.now().str()
	for key, val in this.conf {
		con = con + '\n' + key + ' = ' + val
	}

	home := os.home_dir()
	os.mkdir(home + '/vide/') or {}
	file := home + '/vide/config.txt'

	os.write_file(file, con) or {}
}
