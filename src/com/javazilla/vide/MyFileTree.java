package com.javazilla.vide;

import java.awt.Component;
import java.awt.Desktop;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.io.IOException;

import javax.swing.ImageIcon;
import javax.swing.JTree;
import javax.swing.tree.DefaultTreeCellRenderer;
import javax.swing.tree.TreeModel;
import javax.swing.tree.TreePath;

public class MyFileTree extends JTree {

    private static final long serialVersionUID = 1L;
    public static boolean init = false;
    private ImageIcon icon = new ImageIcon(Vide.getImage("vlogo.png",16,16,250));
    private ImageIcon git = new ImageIcon(Vide.getImage("git.png",16,16,150));

    public MyFileTree(TreeModel m, File open) {
        super(m);
        addMouseListener(new MouseAdapter(){public void mouseClicked(MouseEvent me){doMouseClicked(me);}});

        setCellRenderer(new DefaultTreeCellRenderer() {
            private static final long serialVersionUID = 1L;
            
            @Override
            public Component getTreeCellRendererComponent(JTree tree, Object val, boolean sl, boolean ex, boolean lef, int rw, boolean fc) {
                Component c = super.getTreeCellRendererComponent(tree, val, selected, ex, lef, rw, fc);

                if ( !init && ((MyFile)val).getFile().getAbsolutePath().equalsIgnoreCase(open.getParentFile().getAbsolutePath()) ){
                    init = true;
                    tree.expandPath(tree.getPathForRow(rw));
                    return c;
                }

                String name = ((MyFile)val).getFile().getName();
                if (name.endsWith(".v")) setIcon(icon);
                if (name.startsWith(".git")) setIcon(git);

                return c;
            }
        });
    }

    void doMouseClicked(MouseEvent me) {
        TreePath tp = this.getPathForLocation(me.getX(), me.getY());
        if (tp != null && me.getClickCount() > 1) {
            MyFile s = (MyFile)tp.getLastPathComponent();
            String path = s.getFile().getAbsolutePath();
            if (path.endsWith(".v")) {
                TabContent.createTab(Vide.tb, s.getFile());
            } else {
                if (!s.getFile().isDirectory()) {
                    try {
                        Desktop.getDesktop().open(s.getFile());
                    } catch (IOException e) {}
                }
            }
        }
    }

}