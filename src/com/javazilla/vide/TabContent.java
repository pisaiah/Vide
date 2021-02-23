package com.javazilla.vide;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.Timer;
import java.util.TimerTask;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTextPane;
import static com.javazilla.vide.Vide.barea;

public class TabContent {

    public static void createTab(JTabbedPane tb, File file) {
        for (int i = 0; i< tb.getTabCount(); i++) {
            String title = tb.getTitleAt(i);
            if (title.equals(file.getName())) return;
        }

        JTextPane ar = new JTextPane(Vide.setupStyle());

        try {
            for (String s : Files.readAllLines(file.toPath()))
                ar.setText(ar.getText() + "\n" + s);
            ar.setText(ar.getText().substring(1));
        } catch (IOException e1) {}

        ar.setFont(ar.getFont().deriveFont(12f));
        ar.setBorder(BorderFactory.createEmptyBorder(8,8,8,8));
        ar.addKeyListener(new KeyAdapter() {
            private boolean b;

            @Override
            public void keyPressed(KeyEvent ev) {
                if (ev.getKeyCode() == KeyEvent.VK_S && ev.isControlDown()) {
                    saveCurrent(tb);
                    Vide.saver.setSelected(false);
                    Vide.saver.setIcon(new ImageIcon(Vide.getImage("save2.png",16,16, 250)));
                    b = true;
                }
            }

            @Override
            public void keyTyped(KeyEvent ev) {
                if (!b) Vide.saver.setIcon(new ImageIcon(Vide.getImage("save.png",16,16, 250)));
                b = false;
            }
        });

        JScrollPane sp = new JScrollPane(ar);
        TextLineNumber tln = new TextLineNumber(ar,3);
        sp.setRowHeaderView( tln );
        sp.setName(file.getAbsoluteFile().getAbsolutePath());

        tb.addTab(file.getName(), sp);

        barea.setEditable(false);
        barea.setSize(new Dimension(100,500));
        barea.setBackground(Vide.DARK ? new Color(40,50,60) : new Color(240,240,240)); // light gray
        if (Vide.DARK) barea.setForeground(new Color(200,200,200));

        TimerTask task = new TimerTask() {
            public String last = "";
            public void run() {
                if (last.equals(ar.getText())) return;
                last = ar.getText();
                try {
                    Files.write(file.toPath(), ar.getText().getBytes());
                    barea.setText( VCmdRunner.runV(file.getAbsolutePath()) );
                } catch (IOException e){}
            }
        };
        Timer timer = new Timer("V Compile Thread " + Math.random());
        timer.schedule(task, 1000, 1000);
    }

    public static void saveCurrent(JTabbedPane tb) {
        JScrollPane sp = (JScrollPane) tb.getSelectedComponent();
        JTextPane tp = (JTextPane) sp.getViewport().getComponents()[0];
        File file = new File(sp.getName());
        try {
            Files.write(file.toPath(), tp.getText().getBytes());
        } catch (IOException e) {}
    }

}
