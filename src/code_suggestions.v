module main

import iui as ui
import gx
import os

const (
	modules = ['arrays', 'benchmark', 'bitfield', 'cli', 'clipboard', 'clipboard.dummy',
		'clipboard.x11', 'compress', 'compress.deflate', 'compress.gzip', 'compress.zlib', 'context',
		'context.onecontext', 'crypto', 'crypto.aes', 'crypto.bcrypt', 'crypto.blowfish',
		'crypto.cipher', 'crypto.des', 'crypto.ed25519', 'crypto.ed25519.internal.edwards25519',
		'crypto.hmac', 'crypto.internal.subtle', 'crypto.md5', 'crypto.pem', 'crypto.rand',
		'crypto.rc4', 'crypto.sha1', 'crypto.sha256', 'crypto.sha512', 'datatypes', 'datatypes.fsm',
		'main', 'db', 'db.mssql', 'db.mysql', 'db.pg', 'db.sqlite', 'dl', 'dl.loader', 'dlmalloc',
		'encoding', 'encoding.base32', 'encoding.base58', 'encoding.base64', 'encoding.binary',
		'encoding.csv', 'encoding.hex', 'encoding.html', 'encoding.leb128', 'encoding.utf8',
		'encoding.utf8.east_asian', 'eventbus', 'flag', 'fontstash', 'gg', 'gg.m4', 'gx', 'hash',
		'hash.crc32', 'hash.fnv1a', 'io', 'io.util', 'json', 'json.cjson', 'log', 'maps', 'math',
		'math.big', 'math.bits', 'math.complex', 'math.fractions', 'math.internal', 'math.stats',
		'math.unsigned', 'math.vec', 'mssql', 'mysql', 'net', 'net.conv', 'net.ftp', 'net.html',
		'net.http', 'net.http.chunked', 'net.http.mime', 'net.mbedtls', 'net.openssl', 'net.smtp',
		'net.ssl', 'net.unix', 'net.urllib', 'net.websocket', 'orm', 'os', 'os.cmdline',
		'os.filelock', 'os.font', 'os.notify', 'pg', 'picoev', 'picohttpparser', 'rand',
		'rand.buffer', 'rand.config', 'rand.constants', 'rand.mt19937', 'rand.musl', 'rand.pcg32',
		'rand.seed', 'rand.splitmix64', 'rand.sys', 'rand.wyrand', 'rand.xoroshiro128pp', 'readline',
		'regex', 'runtime', 'semver', 'sokol', 'sokol.audio', 'sokol.c', 'sokol.f', 'sokol.gfx',
		'sokol.memory', 'sokol.sapp', 'sokol.sfons', 'sokol.sgl', 'sqlite', 'stbi', 'strconv',
		'strings', 'strings.textscanner', 'sync', 'sync.pool', 'sync.stdatomic', 'szip', 'term',
		'term.termios', 'term.ui', 'time', 'time.misc', 'toml', 'toml.ast', 'toml.ast.walker',
		'toml.checker', 'toml.decoder', 'toml.input', 'toml.parser', 'toml.scanner', 'toml.to',
		'toml.token', 'toml.util', 'vweb', 'vweb.assets', 'vweb.csrf', 'vweb.sse', 'wasm', 'x',
		'x.json2', 'x.ttf']
)

fn find_all_dot_match(sub string, mut e ui.DrawTextlineEvent) ([]string, int, int) {
	doti := sub.index('.') or { return [''], 0, 0 }
	dot := sub[0..(doti + 1)]
	aft := sub[(doti + 1)..]

	dw := e.ctx.gg.text_width(dot)
	sw := e.ctx.gg.text_width(sub)
	wid := sw - dw

	trim := dot.trim_space()

	mut mats := find_all_matches(mut e.ctx.win, trim, aft)
	mats.sort(a.len > b.len)
	return mats, dw, wid
}

fn text_box_active_line_draw(mut e ui.DrawTextlineEvent) {
	mut box := e.target
	if mut box is ui.Textbox {
		txt := box.lines[e.line]

		sub := txt[0..box.caret_x].replace('\t', ' '.repeat(8))

		line_height := ui.get_line_height(e.ctx)

		mut mats, mut dw, _ := []string{}, 0, 0

		if sub.index('.') or { -1 } != -1 {
			mats, dw, _ = find_all_dot_match(sub, mut e)
		}

		if sub.starts_with('import ') && sub.len > 'import '.len {
			spl := sub.split('import ')[1]
			for s in modules {
				if s.starts_with(spl) {
					mats << s
				}
			}
			if mats.len == 1 && sub.contains(mats[0]) {
				return
			}
			dw = e.ctx.text_width('import ')
		}

		if mats.len == 0 {
			return
		}

		mut max_wid := e.ctx.gg.text_width(mats[0] + ' ')
		if max_wid < 200 {
			max_wid = 200
		}

		height := line_height * mats.len
		bg := e.ctx.theme.background

		x := e.x + dw - 4

		e.ctx.gg.draw_rect_empty(x, e.y, max_wid, line_height, gx.blue)
		e.ctx.gg.draw_rect_filled(x, e.y + line_height + 2, max_wid, height, bg)
		e.ctx.gg.draw_rect_empty(x, e.y + line_height + 2, max_wid, height, gx.blue)

		r := e.ctx.theme.text_color.r // ((e.ctx.theme.text_color.r / 2) + bg.r) / 2
		color := gx.rgb(r, r, r)
		conf := gx.TextCfg{
			color: color
			size: e.ctx.win.font_size + box.fs
		}

		for i, mat in mats {
			e.ctx.draw_text(e.x + dw, e.y + line_height + 2 + (line_height * i), mat,
				e.ctx.font, conf)
		}
	}
}

fn find_all_matches(mut win ui.Window, mod string, str string) []string {
	if str.len <= 0 {
		return []
	}
	strs := find_all_fn_in_vlib(mut win, mod)

	for st in strs {
		if st == str {
			return [st]
		}
	}

	mut matches := []string{}
	for st in strs {
		if st.contains(str) && !matches.contains(st) {
			matches << st
		}
	}
	return matches
}

fn all_vlib_mod(mut win ui.Window) []string {
	id := 'vlib'
	if id in win.extra_map {
		return win.extra_map[id].split(' ')
	}

	mut arr := []string{}
	mut vlib := os.dir(get_v_exe()).replace('\\', '/') + '/vlib'
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
	mut vlib := os.dir(get_v_exe()).replace('\\', '/') + '/vlib'
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
