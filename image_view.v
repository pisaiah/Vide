module main

import stbi
import gx
import iui as ui
import gg
import os

struct ImageViewData {
mut:
	file   stbi.Image
	width  int
	height int
	id     int
}

pub fn make_image_view(file string, mut win ui.Window) &ui.Component {
	mut vbox := ui.vbox(win)

	mut png_file := read(file) or { return vbox }
	mut data := ImageViewData{
		file: png_file
	}

	make_gg_image(mut data, mut win, true)

	data.width = data.file.width
	data.height = data.file.height

	mut img := image(data.id, data.width, data.height)
	vbox.add_child(img)

	file_size := format_size(os.file_size(file))

	mut lbl := ui.label(win, '')
	lbl.draw_event_fn = fn [data, img, file_size] (win &ui.Window, mut com ui.Component) {
		color := get_pixel(img.mx, img.my, data.file)
		mouse_details := '\nMX,MY: $img.mx, $img.my, $color'

		com.text = 'Details:\nImage Size: $data.width x $data.height\nFile Size: ' + file_size +
			'$mouse_details\nPreview Zoom:'
	}
	lbl.set_pos(8, 8)
	lbl.pack()

	btn1 := size_btn(win, data, mut img, 1)
	btn2 := size_btn(win, data, mut img, 2)
	btn4 := size_btn(win, data, mut img, 4)
	btn5 := size_btn(win, data, mut img, 8)
	btn6 := size_btn(win, data, mut img, 16)

	mut hbox := ui.hbox(win)

	vbox.add_child(lbl)
	hbox.add_child(btn1)
	hbox.add_child(btn2)
	hbox.add_child(btn4)
	hbox.add_child(btn5)
	hbox.add_child(btn6)
	hbox.pack()
	hbox.set_pos(12, 8)
	vbox.add_child(hbox)

	vbox.set_pos(24, 24)
	vbox.pack()

	return vbox
}

fn size_btn(win &ui.Window, data ImageViewData, mut img Image, mult int) &ui.Button {
	mut btn := ui.button(win, mult.str() + 'x')
	btn.set_pos(4, 1)
	btn.set_click_fn(fn [data, mut img, mult] (a voidptr, b voidptr, c voidptr) {
		img.width = data.width * mult
		img.height = data.height * mult
		img.zoom = mult
	}, 0)
	btn.pack()
	return &btn
}

fn format_size(val f64) string {
	by := f64(1024)

	kb := val / by
	str := '$kb'.str()[0..4]

	if kb > 1024 {
		mb := kb / by
		str2 := '$mb'.str()[0..4]

		return '$str KB / $str2 MB'
	}
	return '$str KB'
}

fn make_gg_image(mut storage ImageViewData, mut win ui.Window, first bool) {
	if first {
		storage.id = win.gg.new_streaming_image(storage.file.width, storage.file.height,
			4, gg.StreamingImageConfig{
			pixel_format: .rgba8
			mag_filter: .nearest
		})
	}
	win.gg.update_pixel_data(storage.id, storage.file.data)
}

pub fn read(path string) ?stbi.Image {
	return stbi.load(path)
}

// Write as PNG
pub fn write_img(img stbi.Image, path string) {
	stbi.stbi_write_png(path, img.width, img.height, 4, img.data, img.width * 4) or { panic(err) }
}

// Write as JPG
pub fn write_jpg(img stbi.Image, path string) {
	stbi.stbi_write_jpg(path, img.width, img.height, 4, img.data, 80) or { panic(err) }
}

// Get RGB value from image loaded with STBI
pub fn get_pixel(x int, y int, this stbi.Image) gx.Color {
	if x == -1 || y == -1 {
		return gx.rgba(0, 0, 0, 0)
	}

	image := this
	unsafe {
		data := &u8(image.data)
		p := data + (4 * (y * image.width + x))
		r := p[0]
		g := p[1]
		b := p[2]
		a := p[3]
		return gx.Color{r, g, b, a}
	}
}

// Get RGB value from image loaded with STBI
fn set_pixel(image stbi.Image, x int, y int, color gx.Color) bool {
	if x < 0 || x >= image.width {
		return false
	}

	if y < 0 || y >= image.height {
		return false
	}

	unsafe {
		data := &u8(image.data)
		p := data + (4 * (y * image.width + x))
		p[0] = color.r
		p[1] = color.g
		p[2] = color.b
		p[3] = color.a
		return true
	}
}

// IMAGE

// Image - implements Component interface
pub struct Image {
	ui.Component_A
pub mut:
	w    int
	h    int
	mx   int
	my   int
	img  int
	zoom int
}

pub fn image(img int, width int, height int) &Image {
	return &Image{
		img: img
		w: width
		h: height
		width: width
		height: height
		zoom: 1
	}
}

pub fn (mut this Image) draw(ctx &ui.GraphicsContext) {
	ctx.gg.draw_image_with_config(gg.DrawImageConfig{
		img_id: this.img
		img_rect: gg.Rect{
			x: this.x
			y: this.y
			width: this.width
			height: this.height
		}
	})

	color := ctx.theme.text_color
	ctx.gg.draw_rect_empty(this.x, this.y, this.width, this.height, color)

	mx := ctx.win.mouse_x
	my := ctx.win.mouse_y

	// Simple Editing
	mut found := false
	for x in 0 .. this.w {
		for y in 0 .. this.h {
			sx := this.x + (x * this.zoom)
			ex := sx + this.zoom

			sy := this.y + (y * this.zoom)
			ey := sy + this.zoom

			if mx >= sx && mx < ex {
				if my >= sy && my < ey {
					ctx.gg.draw_rect_empty(sx, sy, this.zoom, this.zoom, color)
					this.mx = x
					this.my = y
					found = true
					break
				}
			}
		}
	}
	if !found {
		this.mx = -1
		this.my = -1
	}
}
