module library

import iui as ui

//
// Example Plugin
//
[export: 'on_load']
pub fn on_load(mut win ui.Window) {
	for mut item in win.bar.items {
		mut img := $embed_file('assets/icons8-file-24.png')
		if item.text == 'File' {
			img = $embed_file('assets/icons8-file-24.png')
		}
		if item.text == 'Help' {
			img = $embed_file('assets/icons8-help-24.png')
		}
		if item.text == 'Save' {
			img = $embed_file('assets/icons8-save-24.png')
		}
		if item.text == 'Themes' {
			img = $embed_file('assets/icons8-themes-24.png')
		}
		if item.text == 'Edit' {
			img = $embed_file('assets/icons8-edit-24.png')
		}
		item.icon = ui.image_from_byte_array_with_size(mut win, img.to_bytes(), 24, 24)
	}
}
