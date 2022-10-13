module main

import iui as ui
import gg
// import os
// import szip
// import net.http

// TODO: Redo this.

fn open_install_modal_on_start_if_needed(mut win ui.Window, b voidptr) {
	/*
	v_ver, v_path := get_v_version(win)
	could_find_v := v_path.len < 0 || v_ver.starts_with('V ')

	if !could_find_v {
		show_install_modal(mut win, com)
	}*/
}

fn show_install_modal(mut win ui.Window, com ui.MenuItem) {
	v_ver, v_path := get_v_version(win)
	if v_path.len < 0 {
		return
	}

	v_found := false // v_ver.starts_with('V ')

	mut modal := ui.modal(win, 'V Manager (Non-finished Test)')

	if v_found {
		show_installed_info(win, mut modal, v_ver)
	} else {
		show_install_info(win, mut modal, v_ver)
	}

	win.add_child(modal)
}

// If V is found
fn show_installed_info(win &ui.Window, mut modal ui.Modal, data string) {
	lbl := ui.label(win, 'V Version: ' + data, ui.LabelConfig{
		should_pack: true
		x: 24
		y: 24
	})
	modal.add_child(lbl)

	mut btn := ui.button(win, 'Update V')
	btn.set_pos(24, 64)
	btn.set_click_fn(update_v, 0)
	btn.pack()
	modal.add_child(btn)
}

// If V not found
fn show_install_info(win &ui.Window, mut modal ui.Modal, data string) {
	logo := &gg.Image(win.id_map['vide_logo'])

	modal.text = 'Vide Setup: Install V'
	modal.in_width = 600
	modal.in_height = 360
	modal.top_off = 20

	mut logo_im := ui.image(win, logo)
	logo_im.set_bounds((modal.in_width - 188) / 2, 20, 188, 75)

	lbl_txt := 'Welcome to Vide!\nUnfortunately, Vide was unable to find the V compiler executable.\n\nWould you like to download V, or configure in Settings later'

	lbl := ui.label(win, lbl_txt, ui.LabelConfig{
		should_pack: true
		x: 50
		y: 90
	})

	btn_width := 250
	btn_x := (modal.in_width - btn_width) / 2
	btn_y := 260

	mut dlbtn := ui.button(win, 'Download latest V')
	dlbtn.set_click_fn(download_v, 0)
	dlbtn.set_bounds(btn_x, btn_y, btn_width, 40)

	mut ignore_btn := ui.button(win, 'Ignore / Configure later')
	ignore_btn.set_click(ui.default_modal_close_fn)
	ignore_btn.set_bounds(btn_x, btn_y + 45, btn_width, 40)

	modal.add_child(logo_im)
	modal.add_child(ignore_btn)
	modal.add_child(dlbtn)
	modal.add_child(lbl)

	modal.needs_init = false
}

// Update V
fn update_v(a voidptr, b voidptr, c voidptr) {
	ver, path := get_v_version(a)
	if ver.len < 0 {
		return
	}

	mut btn := &ui.Button(b)
	btn.text = 'Updating...'
	go run_update(path, b)
}

fn run_update(path string, b voidptr) {
	output := run_exec([path, 'up'])
	mut btn := &ui.Button(b)
	println(output)
	btn.text = 'Updated V'
}

// Download V
fn download_v(a voidptr, b voidptr, c voidptr) {
	/*
	url := 'https://github.com/vlang/v/releases/latest/download/v_' + os.user_os() + '.zip'

	temp := os.config_dir() or { os.temp_dir() }
	vide_dir := os.join_path(temp, 'vide-data')
	os.mkdir(vide_dir) or {}

	file := os.join_path(vide_dir, 'v_dl.zip')
	extract_to := os.join_path(vide_dir, 'v_extract')

	/http.download_file(url, file) or {
		// or failed
	}
	os.mkdir(extract_to) or {}

	extract_zip_to_dir(file, extract_to) or {}*/
}

// Fixed version of szip.extract_zip_to_dir
/*
pub fn extract_zip_to_dir(file string, dir string) ?bool {
	mut zip := szip.open(file, .best_speed, .read_only) or { panic(err) }
	total := zip.total() or { return false }
	for i in 0 .. total {
		zip.open_entry_by_index(i) or {}
		do_to := os.real_path(os.join_path(dir, zip.name()))

		os.mkdir_all(os.dir(do_to)) or { println(err) }
		os.write_file(do_to, '') or {}

		if os.is_dir(do_to) {
			continue
		}

		zip.extract_entry(do_to) or {
		}
	}
	return true
}
*/

fn get_v_version(win &ui.Window) (string, string) {
	output := get_v_version_1('v')

	if output.starts_with('error') {
		// Try Again with set path
		v_exe := get_v_exe(win)
		output_new := get_v_version_1(v_exe)
		return output_new, v_exe
	}

	return output, 'v'
}

fn get_v_version_1(path string) string {
	output := run_exec([path, 'version'])

	if output.len == 1 {
		if output[0].starts_with('V ') {
			// Found V
			return output[0]
		}
	}
	return 'error?'
}
