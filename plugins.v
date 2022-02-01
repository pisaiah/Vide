module main

import os
import iui as ui
import dl

// Basic plugin system

type FNPlMain = fn (mut a ui.Window)

pub fn load_plugins(dir string, mut win ui.Window) ? {
	println('Loading plugins...')
	for file in os.ls(dir) or {['']} {
		println('Loading plugin "' + file + '"...')
		library_file_path := os.join_path(dir, file)
		handle := dl.open_opt(library_file_path, dl.rtld_lazy) ?
		f := FNPlMain(dl.sym_opt(handle, 'on_load') ?)
		
		f(mut win)
	}
	println('Loaded plugins.')
}
