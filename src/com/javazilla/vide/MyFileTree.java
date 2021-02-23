package com.javazilla.vide;

import java.awt.Component;
import java.awt.Desktop;
import java.awt.Image;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;
import javax.swing.JTree;
import javax.swing.tree.DefaultTreeCellRenderer;
import javax.swing.tree.TreeModel;
import javax.swing.tree.TreePath;

public class MyFileTree extends JTree {

    private static final long serialVersionUID = 1L;
    public static boolean init = false;

    public MyFileTree(TreeModel m, File open) {
        super(m);
        addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent me) {
              doMouseClicked(me);
            }
          });

        try {
            setCellRenderer(new DefaultTreeCellRenderer() {
                private static final long serialVersionUID = 1L;
                private ImageIcon icon = new ImageIcon(ImageIO.read(Vide.class.getClassLoader().getResourceAsStream("icons/vlogo.png")).getScaledInstance(16, 16, Image.SCALE_SMOOTH));
                private ImageIcon git = new ImageIcon(Vide.getImage("icons/git.png", 16, 16, 200));
                
                @Override
                public Component getTreeCellRendererComponent(JTree tree,
                        Object value, boolean selected, boolean expanded, boolean isLeaf, int row, boolean focused) {
 
                    Component c = super.getTreeCellRendererComponent(tree, value, selected, expanded, isLeaf, row, focused);

                    if ( !init && ((MyFile)value).getFile().getAbsolutePath().equalsIgnoreCase( open.getParentFile().getAbsolutePath() ) ){
                        System.out.println("EXPAND!");
                        init = true;
                        tree.expandPath(tree.getPathForRow(row));
                        return c;
                    }

                    String name = ((MyFile)value).getFile().getName();
                    if (name.endsWith(".v")) setIcon(icon);
                    if (name.startsWith(".git")) setIcon(git);

                    return c;
                }
            });
            
        } catch (IOException e) {
            e.printStackTrace();
        }
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
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

}