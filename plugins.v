module main

import os
import iui as ui
import dl
import szip
import time

// Basic plugin system

type FNPlMain = fn (mut a ui.Window)

pub fn load_plugins(dir string, mut win ui.Window) ? {
	println('Loading plugins...')
	for file in os.ls(dir) or {['']} {
		println('Loading plugin "' + file + '"...')
		library_file_path := os.join_path(dir, file)
		if os.is_dir(library_file_path) {
			continue
		}

		if file.ends_with('.videaddon') {
			// Uncompiled test
			load_uncompiled(mut win, library_file_path) ?
			continue
		}

		handle := dl.open_opt(library_file_path, dl.rtld_lazy) ?
		f := FNPlMain(dl.sym_opt(handle, 'on_load') ?)
		
		f(mut win)
	}
	println('Loaded plugins.')
}

// Load from source ZIP
fn load_uncompiled(mut win ui.Window, file string) ? {
	tmp := os.temp_dir()
	fold := tmp + '/vide-addons/'
	os.mkdir(fold) or {}
	name := os.base(file.split('.')[0])
	pfold := os.real_path(fold + name + '-compile')
	os.mkdir(pfold) or {}
	base := os.base(pfold)
	file_path := os.real_path(pfold + '/') + base.replace('-compile','')

	mut need_compile := true
	println(file_path + dl.get_shared_library_extension())
	if os.exists(file_path + dl.get_shared_library_extension()) {
		mod_a := os.file_last_mod_unix(file_path + dl.get_shared_library_extension())
		mod_b := os.file_last_mod_unix(file)
		if mod_b <= mod_a {
			need_compile = false
		} else {
			// File changed, needs recompile
			// os.rmdir_all(pfold) or {}
		}
	}

	if need_compile {
		println('Compiling addon...')
		szip.extract_zip_to_dir(file, pfold) or {}
		vexe := get_v_exe(mut win)
		cmd := vexe + ' -skip-unused -d no_backtrace -o ' + os.real_path(pfold + '/' + name) + ' -shared ' + os.real_path(pfold + '/') + '.'

		mut res := os.execute(cmd)
		if res.exit_code != 0 {
			res = os.execute(cmd)
			if res.exit_code != 0 {
				time.sleep(100 * time.millisecond )
				res = os.execute(cmd)
			}
			println(res)
		}
	}

	handle := dl.open_opt(file_path, dl.rtld_lazy) ?
	f := FNPlMain(dl.sym_opt(handle, 'on_load') ?)
		
	f(mut win)
}