package com.javazilla.vide;

import static com.javazilla.vide.Vide.barea;

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
import javax.swing.JScrollPane;
import javax.swing.JTabbedPane;
import javax.swing.JTextPane;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.DefaultStyledDocument;
import static javax.swing.text.StyleConstants.Foreground;
import javax.swing.text.StyleContext;

public class TabContent {

    public static void createTab(JTabbedPane tb, File file) {
        JTextPane ar = new JTextPane(setupStyle());

        try {
            for (String s : Files.readAllLines(file.toPath()))
                ar.setText(ar.getText() + "\n" + s);
            ar.setText(ar.getText().substring(1));
        } catch (IOException e1) {}

        ar.setFont(ar.getFont().deriveFont(Vide.FONT + 0f));
        ar.setBorder(BorderFactory.createEmptyBorder(8,8,8,8));
        ar.addKeyListener(new KeyAdapter() {
            private boolean b;

            @Override
            public void keyPressed(KeyEvent ev) {
                if (ev.getKeyCode() == KeyEvent.VK_S && ev.isControlDown()) {
                    saveCurrent(tb);
                    Vide.saver.setSelected(false);
                    Vide.saver.setIcon(Vide.save2);
                    b = true;
                }
            }

            @Override
            public void keyTyped(KeyEvent ev) {
                if (!b) Vide.saver.setIcon(Vide.save1);
                b = false;
            }
        });

        JScrollPane sp = new JScrollPane(ar);
        TextLineNumber tln = new TextLineNumber(ar);
        sp.setRowHeaderView(tln);
        sp.setName(file.getAbsoluteFile().getAbsolutePath());

        if (Vide.DARK) {
            tb.setOpaque(true);
            tb.setBackground(new Color(70, 74, 80));
        }
        tb.addTab(file.getName(), sp);

        barea.setEditable(false);
        barea.setSize(new Dimension(100,500));
        barea.setBackground(Vide.DARK ? new Color(40,50,60) : new Color(240,240,240)); // light gray
        if (Vide.DARK) barea.setForeground(new Color(200,200,200));

        File tmp = new File(new File(System.getProperty("java.io.tmpdir"), "vide"), (int)(Math.random()*1000) + "tmp-" + file.getName());
        tmp.getParentFile().mkdirs();
        tmp.deleteOnExit();
        TimerTask task = new TimerTask() {
            public String last = "";
            public void run() {
                if (last.equals(ar.getText())) return;
                last = ar.getText();
                try {
                    Files.write(tmp.toPath(), ar.getText().getBytes());
                    String s = VCmdRunner.v(tmp.getAbsolutePath())
                            .replace(tmp.getAbsoluteFile().getParentFile().getAbsolutePath(), "");
                    if (s.indexOf("tmp-") != -1) s = s.split("tmp-")[1];
                    barea.setText(s);
                    for (File f : tmp.getParentFile().listFiles()) f.deleteOnExit();
                } catch (IOException e){e.printStackTrace();}
            }
        };
        Timer timer = new Timer("VThread " + Math.random());
        timer.schedule(task, 2000, 1000);
    }

    public static File file(JTabbedPane tb) {
        return new File(tb.getSelectedComponent().getName());
    }

    public static void font(JTabbedPane tb, float f) {
        JTextPane tp = (JTextPane) ((JScrollPane) tb.getSelectedComponent()).getViewport().getComponents()[0];
        tp.setFont(tp.getFont().deriveFont(f));
    }

    public static void saveCurrent(JTabbedPane tb) {
        JTextPane tp = (JTextPane) ((JScrollPane) tb.getSelectedComponent()).getViewport().getComponents()[0];
        try {
            Files.write(file(tb).toPath(), tp.getText().getBytes());
        } catch (IOException e){}
    }

    public static DefaultStyledDocument setupStyle() {
        final StyleContext cont = StyleContext.getDefaultStyleContext();
        final AttributeSet att = cont.addAttribute(cont.getEmptySet(), Foreground, Vide.DARK ? new Color(255,26,156) : new Color(150,0,85));
        final AttributeSet attNum = cont.addAttribute(cont.getEmptySet(), Foreground, new Color(240,170,0));
        final AttributeSet attBl = cont.addAttribute(cont.getEmptySet(), Foreground, Vide.DARK ? new Color(200,200,200) : Color.BLACK);

        @SuppressWarnings("serial")
        DefaultStyledDocument doc = new DefaultStyledDocument() {
            String s = "(\\W)*(pub|struct|fn|const|mut|import)";

            public void insertString (int b, String str, AttributeSet a) throws BadLocationException {
                super.insertString(b, str, a);

                String txt = getText(0, getLength());
                int be = findNonWordChar(txt, b, true);
                int af = findNonWordChar(txt, b + str.length(),false);
                int wL = be;
                int wR = be;

                while (wR <= af) {
                    if (wR == af || String.valueOf(txt.charAt(wR)).matches("\\W")) {
                        setCharacterAttributes(wL, wR-wL, txt.substring(wL,wR).matches(s) ? att : attBl, true);
                        wL = wR;
                    }
                    wR++;
                }
                refresh(txt);
            }

            public boolean refresh(String txt) {
                boolean r = false;
                for (int z = 0; z < txt.length(); z++) {
                    int c = (int)txt.substring(z,z+1).charAt(0);
                    if (c >= 48 && c <= 57) {
                        setCharacterAttributes(z, 1, attNum, true);
                        r = true;
                    }
                }
                return r;
            }

            public void remove(int b, int len) throws BadLocationException {
                super.remove(b, len);

                String txt = getText(0, getLength());
                int be = findNonWordChar(txt, b, true);
                int af = findNonWordChar(txt, b, false);

                setCharacterAttributes(be, af-be, txt.substring(be,af).matches(s) ? att : attBl, false);
                refresh(txt);
            }
        };
        return doc;
    }

    private static int findNonWordChar(String text, int index, boolean l) {
        while (l ? --index >= 0 : index++ < text.length())
            if (String.valueOf(text.charAt(index)).matches("\\W"))  break;
        return l ? Math.max(0,index) : index-1;
    }

}
