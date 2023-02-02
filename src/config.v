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
	config         = make_config()
)

// Make Config as a 'Fake' Component
struct Config {
	ui.Component_A
pub mut:
	conf map[string]string
}

fn make_config() &Config {
	mut conf := &Config{}
	conf.read()
	return conf
}

fn get_config(win &ui.Window) &Config {
	return config
}

fn (mut this Config) read() {
	home := os.home_dir()
	os.mkdir(home + '/vide/') or {}
	file := home + '/vide/config.txt'

	if !os.exists(file) {
		os.write_file(file, default_config) or {}
	}

	lines := os.read_lines(file) or { ['ERROR while reading file contents'] }
	for line in lines {
		if !line.contains('=') {
			continue
		}
		spl := line.split('=')
		this.conf[spl[0].trim_space()] = spl[1].trim_space()
	}
	ui.debug('Vide: Loaded config.')
}

fn (this &Config) get_value(key string) string {
	if key in this.conf {
		return this.conf[key]
	} else {
		for line in default_config.split_into_lines() {
			if line.starts_with(key) {
				spl := line.split('=')
				unsafe {
					this.conf[spl[0].trim_space()] = spl[1].trim_space()
				}
				return spl[1].trim_space()
			}
		}
	}
	return ''
}

fn (this &Config) set(key string, val string) {
	unsafe {
		this.conf[key] = val
	}
}

fn (this &Config) save() {
	mut con := '# Vide Configuration\n# Last Modified: ' + time.now().str()
	for key, val in this.conf {
		con = con + '\n' + key + ' = ' + val
	}

	home := os.home_dir()
	os.mkdir(home + '/vide/') or {}
	file := home + '/vide/config.txt'

	os.write_file(file, con) or {}
}
