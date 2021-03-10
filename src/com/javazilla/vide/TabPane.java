package com.javazilla.vide;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Insets;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTabbedPane;
import javax.swing.border.EmptyBorder;

@SuppressWarnings("serial")
public class TabPane extends JTabbedPane {

    @Override
    public void addTab(String title, Component comp) {
        super.addTab(title,null,comp,null);
        setTabComponentAt((this.getTabCount()-1), new XButton(comp, title, this));
    }

    public class XButton extends JPanel {
        public XButton(Component c, String t, JTabbedPane tb) {
            setOpaque(false);
            setLayout(new BorderLayout());
            ((JLabel)add(new JLabel(t))).setBorder(new EmptyBorder(0,9,0,0));
            JPanel p = new JPanel();
            JButton b = (JButton) p.add(new JButton("x"));
            b.setMargin(new Insets(0,0,0,0));
            b.setBackground(new Color(8,8,8,9));
            b.setBorderPainted(false);
            b.addActionListener(e -> tb.remove(c));
            p.setOpaque(false);
            p.setBorder(new EmptyBorder(0,16,0,0));
            add(p,"East");
        }
    }

}