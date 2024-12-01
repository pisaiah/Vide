module main

import iui as ui
import gx

// Vide Light Theme
pub fn vide_light_theme() &ui.Theme {
	mut theme := ui.theme_default()
	theme.name = 'Vide Light'
	theme.button_fill_fn = vide_theme_button_fill_fn
	theme.bar_fill_fn = vide_theme_bar_fill_fn
	theme.setup_fn = vide_theme_setup
	theme.menu_bar_fill_fn = vide_theme_menubar_fill_fn
	return theme
}

// Vide Default Dark Theme
pub fn vide_dark_theme() &ui.Theme {
	mut theme := ui.theme_dark()
	theme.name = 'Vide Default Dark'
	// theme.button_fill_fn = vide_theme_button_fill_fn
	theme.bar_fill_fn = vide_theme_bar_fill_fn
	theme.setup_fn = vide_theme_setup
	theme.menu_bar_fill_fn = vide_theme_menubar_fill_fn

	// V colors
	theme.accent_fill = gx.rgb(93, 135, 191)
	theme.accent_fill_second = gx.rgb(88, 121, 165)
	theme.accent_fill_third = gx.rgb(83, 107, 138)

	// theme.button_bg_normal = theme.accent_fill_third

	return theme
}

pub fn vide_theme_setup(mut win ui.Window) {
	mut ctx := win.graphics_context
	// mut o_file := $embed_file('assets/theme/btn.png')
	// mut o_icons := win.create_gg_image(o_file.data(), o_file.len)
	// ctx.icon_cache['vide_theme-btn'] = win.gg.cache_image(o_icons)

	// mut o_file1 := $embed_file('assets/theme/bar.png')
	// o_icons = win.create_gg_image(o_file1.data(), o_file1.len)
	// ctx.icon_cache['vide_theme-bar'] = ctx.gg.cache_image(o_icons)

	mut o_file2 := $embed_file('assets/theme/menu.png')
	mut o_icons := win.create_gg_image(o_file2.data(), o_file2.len)
	ctx.icon_cache['vide_theme-menu'] = ctx.gg.cache_image(o_icons)

	// mut o_file3 := $embed_file('assets/theme/barw.png')
	// o_icons = win.create_gg_image(o_file3.data(), o_file3.len)
	// ctx.icon_cache['vide_theme-bar-w'] = ctx.gg.cache_image(o_icons)
}

pub fn vide_theme_button_fill_fn(x int, y int, w int, h int, r int, bg gx.Color, ctx &ui.GraphicsContext) {
	if bg == ctx.theme.button_bg_normal {
		ctx.gg.draw_image_by_id(x - 1, y - 1, w + 2, h + 2, ctx.icon_cache['vide_theme-btn'])
	} else {
		ctx.gg.draw_rounded_rect_filled(x, y, w, h, r, bg)
	}
}

pub fn vide_theme_bar_fill_fn(x int, y f32, w int, h f32, hor bool, ctx &ui.GraphicsContext) {
	if hor {
		hh := h / 2
		ctx.gg.draw_rect_filled(x, y, w, hh, gx.rgb(88, 128, 181))
		ctx.gg.draw_rect_filled(x, y + hh, w, hh, gx.rgb(68, 100, 140))
		ctx.gg.draw_rect_empty(x, y, w, h, ctx.theme.scroll_bar_color)
	} else {
		xx := x - 1
		ww := (w + 2) / 2

		ctx.gg.draw_rect_filled(xx, y, w + 3, h, gx.rgb(88, 128, 181))
		ctx.gg.draw_rect_filled(xx + ww, y, ww + 1, h, gx.rgb(68, 100, 140))
	}
}

pub fn vide_theme_menubar_fill_fn(x int, y int, w int, h int, ctx &ui.GraphicsContext) {
	ctx.gg.draw_image_by_id(x, y, w, h + 1, ctx.icon_cache['vide_theme-menu'])
}
