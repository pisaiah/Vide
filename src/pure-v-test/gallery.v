module main

import os
import kjlaw89.viup

//#flag windows "path\\to\\manifest.syso"

const (
	version = '1.0.0'
	about   = '
This is version $version of VIUP Control Gallery demo.

It gives a simple overview of all of the available controls and some sample use cases.
	'
)

fn main() {
	//vlogo := image.load(os.resource_abs_path('./v-logo.png'), 'resize=64x64') ?
	//vlogo.set_handle('logo')

	// Create our menu with the typical "File | Edit | About" layout
	menu_event := viup.ActionFunc(menu_clicked)
	menu := viup.menu([
		viup.sub_menu('&File', viup.menu([
			viup.menu_item('&Open File...', 'name=MenuOpen').on_action(menu_event),
			viup.menu_item('&Save File...', 'name=MenuSave').on_action(menu_event),
			viup.menu_sep(),
			viup.menu_item('E&xit', 'name=MenuExit').on_action(menu_event),
		])),
		viup.sub_menu('&Edit', viup.menu([
			viup.menu_item('Debug &Window', 'name=MenuDebugWindow').on_action(menu_event),
			viup.menu_item('Debug &Control', 'name=MenuDebugControl').on_action(menu_event),
		])),
		viup.sub_menu('&Help', viup.menu([
			viup.menu_item('&Repository', 'name=MenuRepository').on_action(menu_event),
			viup.menu_sep(),
			viup.menu_item('&About', 'name=MenuAbout').on_action(menu_event),
		])),
	])

	hbox := viup.hbox([
		viup.vbox([
			viup.tabs([
				viup.hbox([
                    viup.text('Test', 'expand=yes', 'multiline=YES', 'formatting=yes')
					viup.fill(),
				], 'tabtitle=Tab 1'),
				viup.hbox([
					viup.label('In tab 2'),
				], 'tabtitle=Tab 2'),
				viup.hbox([
					viup.label('In tab 3'),
				], 'tabtitle=Tab 3', 'PADDING=0x32', 'FORMATTING=yes'),
			], 'SHOWCLOSE=yes'),
		], 'gap=10'),
	], 'margin=1x1')

	// Create our window to display - size will be
	// automatically calculated by components

	dialog := viup.dialog(viup.scroll(hbox), 'MainWindow', 'title=Vide', 'SIZE=HALFxHALF')
	dialog.set_menu('app_menu', menu)
	dialog.show_xy(viup.pos_center, viup.pos_center)

	viup.main_loop()
	viup.close()
}

// menu_clicked handles when different menu items are clicked
fn menu_clicked(control &viup.Control) viup.FuncResult {
	name := control.get_attr('name')
	match name {
		'MenuAbout' {
			viup.message_dialog('title=About', 'value=$about', 'dialogtype=information').popup(viup.pos_current,
				viup.pos_current)
		}
		'MenuExit' {
			return .close
		}
		'MenuOpen' {
			dialog := viup.file_dialog('title=Open file...')
			dialog.popup(viup.pos_current, viup.pos_current)

			if dialog.get_int('status') == 0 {
				value := dialog.get_attr('value')

				viup.message_dialog('title=File Opened', "value=The file '$value' was opened.",
					'dialogtype=information').popup(viup.pos_current, viup.pos_current)
			}
		}
		'MenuDebugControl' {
			focused := viup.get_focused()
			focused.debug_props()
		}
		'MenuDebugWindow' {
			window := viup.get_handle('MainWindow')
			window.debug() // when autofree is enabled this will cause a crash as the mainwindow will go out of scope and be freed
		}
		'MenuRepository' {
			viup.help('https://github.com/kjlaw89/viup')
		}
		'MenuSave' {
			dialog := viup.file_dialog('title=Save file...', 'dialogtype=save')
			dialog.popup(viup.pos_current, viup.pos_current)

			if dialog.get_int('status') != -1 {
				value := dialog.get_attr('value')

				viup.message_dialog('buttons=OKCANCEL', 'dialogtype=warning', 'title=File Save',
					"value=The file '$value' was not actually saved, but this is where you would do it.").popup(viup.pos_current,
					viup.pos_current)
			}
		}
		else {
			println('Menu $name')
		}
	}

	return .cont
}

// numbers_changed handles when the spinner or slider are updated
// and links all three controls together automatically
fn numbers_changed(control &viup.Control) viup.FuncResult {
	value := control.get_attr('value')
	viup.get_handle('spin1').set_attr('value', value.int().str())
	viup.get_handle('slider1').set_attr('value', value)
	viup.get_handle('progress1').set_attr('value', value)

	return .cont
}

// button_clicked shows a dialog when the test button is clicked
fn button_clicked(control &viup.Control) viup.FuncResult {
	viup.message('Button Click', 'Button clicked!')
	return .cont
}

// font_button_clicked shows a font dialog when the font button is clicked
fn font_button_clicked(control &viup.Control) viup.FuncResult {
	font := control.get_font().show_picker()
	control.set_font(font).set_attr('title', font.face)

	return .cont
}

// color_button_clicked shows a color dialog when the color button is clicked
fn color_button_clicked(control &viup.Control) viup.FuncResult {
	color, table := control.get_bgcolor().show_picker()
	println(table)
	control.set_bgcolor(color)

	return .cont
}
