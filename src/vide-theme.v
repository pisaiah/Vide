module main

import iui as ui
import gx

// Vide Light Theme
pub fn vide_light_theme() &ui.Theme {
	return &ui.Theme{
		name: 'Vide Light'
		text_color: gx.black
		background: gx.rgb(210, 210, 210)
		button_bg_normal: gx.rgb(230, 230, 230)
		button_bg_hover: gx.rgb(229, 241, 251)
		button_bg_click: gx.rgb(204, 228, 247)
		button_border_normal: gx.rgb(190, 190, 190)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(255, 255, 255)
		menubar_border: gx.rgba(0, 0, 0, 0)
		dropdown_background: gx.rgb(93, 135, 191)
		dropdown_border: gx.rgb(93, 135, 191)
		textbox_background: gx.rgb(235, 235, 235)
		textbox_border: gx.rgb(215, 215, 215)
		checkbox_selected: gx.rgb(37, 161, 218)
		checkbox_bg: gx.rgb(254, 254, 254)
		progressbar_fill: gx.rgb(37, 161, 218)
		scroll_track_color: gx.rgb(238, 238, 238)
		scroll_bar_color: gx.rgb(170, 170, 170)
		button_fill_fn: vide_theme_button_fill_fn
		bar_fill_fn: vide_theme_bar_fill_fn
		setup_fn: vide_theme_setup
		menu_bar_fill_fn: vide_theme_menubar_fill_fn
	}
}

// Vide Default Dark Theme
pub fn vide_dark_theme() &ui.Theme {
	return &ui.Theme{
		name: 'Vide Default Dark'
		text_color: gx.rgb(230, 230, 230)
		background: gx.rgb(37,37,39)//gx.rgb(40, 55, 71)
		button_bg_normal: gx.rgb(10, 10, 10)
		button_bg_hover: gx.rgb(70, 70, 70)
		button_bg_click: gx.rgb(50, 50, 50)
		button_border_normal: gx.rgb(130, 130, 130)
		button_border_hover: gx.rgb(0, 120, 215)
		button_border_click: gx.rgb(0, 84, 153)
		menubar_background: gx.rgb(30, 30, 30)
		menubar_border: gx.rgba(0, 0, 0, 0)
		dropdown_background: gx.rgb(83, 107, 138)
		dropdown_border: gx.rgb(93, 135, 191)
		textbox_background: gx.rgb(34, 39, 46)
		textbox_border: gx.rgb(93, 135, 191)//gx.blue//gx.rgb(130, 130, 130)
		checkbox_selected: gx.rgb(130, 170, 220)
		checkbox_bg: gx.rgb(5, 5, 5)
		progressbar_fill: gx.rgb(130, 130, 130)
		scroll_track_color: gx.rgb(0, 0, 0)
		scroll_bar_color: gx.rgb(160, 160, 160)
		button_fill_fn: vide_theme_button_fill_fn
		bar_fill_fn: vide_theme_bar_fill_fn
		setup_fn: vide_theme_setup
		menu_bar_fill_fn: vide_theme_menubar_fill_fn
	}
}

pub fn vide_theme_setup(mut win ui.Window) {
	mut ctx := win.graphics_context
	mut o_file := $embed_file('assets/theme/btn.png')
	mut o_icons := win.create_gg_image(o_file.data(), o_file.len)
	ctx.icon_cache['vide_theme-btn'] = win.gg.cache_image(o_icons)

	mut o_file1 := $embed_file('assets/theme/bar.png')
	o_icons = win.create_gg_image(o_file1.data(), o_file1.len)
	ctx.icon_cache['vide_theme-bar'] = ctx.gg.cache_image(o_icons)

	mut o_file2 := $embed_file('assets/theme/menu.png')
	o_icons = win.create_gg_image(o_file2.data(), o_file2.len)
	ctx.icon_cache['vide_theme-menu'] = ctx.gg.cache_image(o_icons)

	mut o_file3 := $embed_file('assets/theme/barw.png')
	o_icons = win.create_gg_image(o_file3.data(), o_file3.len)
	ctx.icon_cache['vide_theme-bar-w'] = ctx.gg.cache_image(o_icons)
}

pub fn vide_theme_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, ctx &ui.GraphicsContext) {
	if bg == ctx.theme.button_bg_normal {
		ctx.gg.draw_image_by_id(x, y, w, h, ctx.icon_cache['vide_theme-btn'])
	} else {
		ctx.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn vide_theme_bar_fill_fn(x int, y f32, w int, h f32, hor bool, ctx &ui.GraphicsContext) {
	id := if hor { ctx.icon_cache['vide_theme-bar-w'] } else { ctx.icon_cache['vide_theme-bar'] }

	if hor {
		ctx.gg.draw_image_by_id(x, y - 2, w, h + 4, id)
		ctx.gg.draw_rect_empty(x, y - 2, w, h + 4, ctx.theme.scroll_bar_color)
	} else {
		ctx.gg.draw_image_by_id(x - 1, y, w + 3, h, id)
		ctx.gg.draw_rect_empty(x - 2, y, w + 5, h, ctx.theme.scroll_bar_color)
	}
}

pub fn vide_theme_menubar_fill_fn(x int, y int, w int, h int, ctx &ui.GraphicsContext) {
	ctx.gg.draw_image_by_id(x, y, w, h + 1, ctx.icon_cache['vide_theme-menu'])
}
