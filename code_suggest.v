module main

import gg
import iui as ui
import os
import gx

fn codebox_text_change(mut win ui.Window, box ui.Textbox) {
	if box.ctrl_down {
		if box.last_letter == 's' {
			println('SAVE REQUEST!')
			do_save(mut win)
		}
	}

	// Text Suggestions
	mut indx := box.carrot_top + 1
	mut mtxt := ''
	spl := box.text.split_into_lines()
	if (indx - 1) < spl.len {
		mtxt = spl[indx - 1]
	}
	mtxt = mtxt.substr_ni(0, box.carrot_left)
	mut splt := mtxt.split(' ')
	fin := splt[splt.len - 1]
	win.extra_map['fin'] = fin
}

fn on_box_draw_1(mut win ui.Window, mut box ui.Textbox, tx int, ty int) {
	fin := win.extra_map['fin']

	mut is_fin := false
	for str in all_vlib_mod(mut win) {
		if fin.starts_with(str + '.') {
			is_fin = true
		}
	}

	if is_fin {
		mut indx := box.carrot_top + 1
		mut mtxt := ''
		spl := box.text.split_into_lines()
		if (indx - 1) < spl.len {
			mtxt = spl[indx - 1]
		}
		mtxt = mtxt.substr_ni(0, box.carrot_left)
		mut splt := mtxt.split(' ')

		last_ym := win.gg.text_height('A{')
		mut lt := last_ym * (box.carrot_top) - (last_ym * box.scroll_i)
		mut lw := 0
		mut splt_i := 0
		mut aft := ''
		mut mod := fin.split('.')[0]
		for atxt in splt {
			if splt_i == splt.len - 1 {
				alen := (atxt.last_index('.') or { -1 }) + 1
				aft = atxt.substr_ni(alen, atxt.len)
				lw += 5
			}
			lw += ui.text_width(win, atxt + ' ')
			splt_i++
		}
		sug := match_fn(mut win, mod, aft)
		lw = (lw - ui.text_width(win, ' ')) + (box.padding_x - 4)

		mut r := ((win.theme.text_color.r / 2) + win.theme.background.r) / 2
		color := gx.rgb(r, r, r)

		win.gg.draw_text(box.x + tx + lw, ty + box.y + lt + 26, sug.replace_once(aft,
			''), gx.TextCfg{
			size: win.font_size
			color: color
		})
	}
}

fn match_fn(mut win ui.Window, mod string, str string) string {
	if str.len <= 0 {
		return ''
	}
	strs := find_all_fn_in_vlib(mut win, mod)

	for st in strs {
		if st == str {
			return st
		}
	}

	for st in strs {
		if st.starts_with(str) {
			return st
		}
	}
	return ''
}

fn all_vlib_mod(mut win ui.Window) []string {
	id := 'vlib'
	if id in win.extra_map {
		return win.extra_map[id].split(' ')
	}

	mut arr := []string{}
	mut vlib := os.dir(get_v_exe(mut win)).replace('\\', '/') + '/vlib'
	for file in os.ls(vlib) or { [''] } {
		arr << file
	}
	win.extra_map[id] = arr.join(' ')
	return arr
}

fn find_all_fn_in_vlib(mut win ui.Window, mod string) []string {
	id := 'sug-' + mod
	if id in win.extra_map {
		return win.extra_map[id].split(' ')
	}

	mut arr := []string{}
	mut vlib := os.dir(get_v_exe(mut win)).replace('\\', '/') + '/vlib'
	mut mod_dir := vlib + '/' + mod
	for file in os.ls(mod_dir) or { [''] } {
		lines := os.read_lines(mod_dir + '/' + file) or { [''] }
		for line in lines {
			if line.starts_with('pub fn') && !line.starts_with('pub fn (') {
				name := line.split('pub fn ')[1].split('(')[0]
				arr << name
			}
		}
	}
	win.extra_map[id] = arr.join(' ')
	return arr
}

fn get_v_exe(mut win ui.Window) string {
	mut conf := get_config(mut win)
	mut saved := conf.get_or_default('v_exe').replace('{user_home}', os.home_dir().replace('\\',
		'/'))

	if saved.len <= 0 {
		mut vexe := 'v'
		$if windows {
			vexe = 'v.exe'
		}
		if 'VEXE' in os.environ() {
			vexe = os.environ()['VEXE'].replace('\\', '/')
		}
		vexe = vexe.replace(os.home_dir().replace('\\', '/'), '{user_home}')
		conf.set('v_exe', vexe)
		conf.save()
		return vexe
	} else {
		return saved
	}
}
