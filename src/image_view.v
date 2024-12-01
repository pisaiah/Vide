module main

import iui as ui

fn image_view(path string) &ui.ScrollView {
	mut p := ui.Panel.new()

	mut im := ui.Image.new(file: path)
	p.add_child(im)

	mut sv := ui.ScrollView.new(
		view: p
	)
	sv.set_border_painted(false)

	return sv
}
