module main

import iui as ui
import os

// Make an Tree list from files from dir
fn make_tree(mut window ui.Window, fold string, mut tree ui.Tree) ui.Tree {
	mut files := os.ls(fold) or { [] }

	for fi in files {
		if fi.starts_with('.git') || fi.contains('.exe') || fi.contains('.dll') {
			continue
		}
		mut sub := ui.tree(window, fold + '/' + fi)
		sub.set_bounds(4, 4, 100, 25)
		sub.set_click(tree_click)

		if !fi.starts_with('.') {
			make_tree(mut window, fold + '/' + fi, mut sub)
		}
		tree.childs << sub
	}
	return tree
}

// Refresh Tree list
fn refresh_tree(mut window ui.Window, fold string, mut tree ui.Tree) ui.Tree {
	// TODO: Remember open-trees
	tree.childs.clear()
	return make_tree(mut window, fold, mut tree)
}

// If file is .v open in new tab
fn tree_click(mut win ui.Window, tree ui.Tree) {
	txt := tree.text
	if txt.contains('.') {
		for mut com in win.components {
			if mut com is ui.Tabbox {
				new_tab(mut win, txt, mut com)
			}
		}
	}
}
