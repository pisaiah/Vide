module main

import iui as ui
import os

// Tree v2:

// Make an Tree list from files from dir
fn make_tree2(fold string) &ui.TreeNode {
	files := os.ls(fold) or { [] }

	mut nodes := []&ui.TreeNode{}

	for fi in files {
		if fi.starts_with('.git') || fi.contains('.exe') || fi.contains('.dll') {
			continue
		}
		mut sub := &ui.TreeNode{
			text: fold + '/' + fi
		}

		if !fi.starts_with('.') {
			join := os.join_path(fold, fi)
			subfiles := os.ls(join) or { [] }
			for f in subfiles {
				node := make_tree2(os.join_path(join, f))
				sub.nodes << node
			}
		}
		nodes << sub
	}

	mut node := &ui.TreeNode{
		text: fold
		nodes: nodes
	}

	return node
}

fn tree2_click(mut ctx ui.GraphicsContext, tree &ui.Tree2, node &ui.TreeNode) {
	txt := node.text
	dump(txt)
	path := os.real_path(txt)
	dump(path)
	if !os.is_dir(path) {
		new_tab(mut ctx.win, txt)
	}
}

// Refresh Tree list
fn refresh_tree(mut window ui.Window, fold string, mut tree ui.Tree2) {
	// TODO
	dump('REFRESH')
	tree.children.clear()

	dump(fold)
	files := os.ls(fold) or { [] }
	tree.click_event_fn = tree2_click

	for fi in files {
		mut node := make_tree2(os.join_path(fold, fi))
		tree.add_child(node)
	}
}

/*
fn setup_tree(mut window ui.Window, folder string) &ui.Tree2 {
	mut tree2 := ui.tree2('Projects')
	tree2.set_bounds(4, 28, 300, 200)
	tree2.draw_event_fn = fn (mut win ui.Window, mut tree ui.Component) {
		tree.height = gg.window_size().height - 30
	}

	files := os.ls(folder) or { [] }
	tree2.click_event_fn = tree2_click

	for fi in files {
		mut node := make_tree2(os.join_path(folder, fi))
		tree2.add_child(node)
	}

	tree2.set_id(mut window, 'proj-tree')
	return tree2
}
*/
