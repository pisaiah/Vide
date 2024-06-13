module main

import iui as ui

struct MyPopup {
	ui.Popup
mut:
	texts []string
	p     &ui.Panel
	sv    &ui.ScrollView
}

fn code_popup() &MyPopup {
	mut p := ui.Panel.new(
		layout: ui.BoxLayout.new(
			ori: 1
			vgap: 1
			hgap: 1
		)
	)
	p.set_bounds(0, 0, 300, 150)

	mut sv := ui.ScrollView.new(
		view: p
		bounds: ui.Bounds{0, 0, 300, 150}
	)

	mut pop := &MyPopup{
		p: p
		sv: sv
	}

	pop.add_child(sv)
	pop.set_bounds(0, 0, 300, 150)

	return pop
}

fn (mut this MyPopup) set_texts(mut tb ui.Textbox, lines []string, aft int) {
	this.p.children.clear()
	for line in lines {
		mut o := ui.Label.new(
			text: line
		)
		o.subscribe_event('draw', fn (mut e ui.MouseEvent) {
			e.target.height = e.ctx.line_height
			e.target.width = e.target.parent.width - 2

			is_in := ui.is_in(e.target, e.ctx.win.mouse_x, e.ctx.win.mouse_y)

			if is_in {
				e.ctx.gg.draw_rect_filled(e.target.x, e.target.y, e.target.width, e.target.height,
					e.ctx.theme.button_bg_hover)
			}
		})
		o.subscribe_event('mouse_up', fn [mut tb, mut this, aft] (mut e ui.MouseEvent) {
			bef := tb.lines[tb.caret_y][0..(tb.caret_x - aft)]
			ln := bef + e.target.text

			tb.lines[tb.caret_y] = ln
			tb.caret_x = ln.len

			this.hide(e.ctx)
		})
		o.set_bounds(0, 0, 100, 30)
		this.p.add_child(o)
	}
}
