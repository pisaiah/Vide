package com.javazilla.vide;

import java.awt.Color;
import java.awt.Font;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.ProcessBuilder.Redirect;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import javax.swing.JFrame;
import javax.swing.JScrollPane;
import javax.swing.JTextPane;
import javax.swing.text.BadLocationException;
import javax.swing.text.Style;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyleContext;
import javax.swing.text.StyledDocument;

public class Term extends JFrame {

    private static final long serialVersionUID = 1L;
    protected JTextPane area;
    private File currentPath;

    private List<String> commandHistory;
    private int history;

    public Term(File f) {
        this.area = new JTextPane();
        this.commandHistory = new ArrayList<>();
        this.currentPath = f;

        area.setBackground(Color.BLACK);
        area.setForeground(Color.LIGHT_GRAY);
        area.setFont(new Font(Font.MONOSPACED, Font.PLAIN, 12));
        area.setCaretColor(Color.LIGHT_GRAY);
        add(currentPath.getAbsolutePath() + ">");

        area.addKeyListener(new KeyAdapter() {
            @Override
            public void keyPressed(KeyEvent ev) {
                boolean isEnter = ev.getKeyCode() == KeyEvent.VK_ENTER;

                String[] txt = area.getText().split("\n");
                String last = txt[txt.length - 1];
                int caretInLast = area.getCaretPosition()-(area.getText().length() - last.length());

                if (ev.getKeyCode() != KeyEvent.VK_LEFT && ev.getKeyCode() != KeyEvent.VK_RIGHT) {
                    try {
                        if (caretInLast < area.getText().length() - last.length())
                        area.setCaretPosition(area.getText().length());
                    } catch (IllegalArgumentException e) {}
                } else if (ev.getKeyCode() == KeyEvent.VK_LEFT && caretInLast >= last.indexOf(">")+1)  ev.consume();

                boolean isDown = ev.getKeyCode() == KeyEvent.VK_DOWN;
                if (ev.getKeyCode() == KeyEvent.VK_UP || isDown) {
                    ev.consume();
                    int point = commandHistory.size() - 1 - history;
                    if (commandHistory.size() > 0 && point >= 0) {
                        setLine(commandHistory.get(point));
                        if (isDown) history--;
                        else history++;
                    }
                }

                if (isEnter) {
                    history = 0;
                    onCommand(last.substring(last.indexOf(">") + 1));
                    ev.consume();
                }

                if (!last.contains(currentPath.getAbsolutePath() + ">") || isEnter) {
                    StyledDocument d = area.getStyledDocument();
                    Style style = d.getStyle(StyleContext.DEFAULT_STYLE);
                    StyleConstants.setForeground(style, Color.LIGHT_GRAY);
                    try {
                        d.insertString(d.getLength(), (isEnter ? "\n" : "") + currentPath.getAbsolutePath() + ">", style);
                    } catch (BadLocationException e) {
                    }
                }
            }
        });

        setContentPane(new JScrollPane(area));
        setSize(800,460);
        setTitle("Term");
        setLocationRelativeTo(null);
    }

    public void onCommand(String command) {
        this.commandHistory.add(command);
        String[] args = command.split(" ");

        switch (args[0]) {
            case "dir":
                File[] files = currentPath.listFiles();
                for (File f : files) {
                    add(new Date(f.lastModified()) + "\t" + (f.isDirectory() ? "<DIR>" : "") + "\t" + f.getName());
                }
                break;
            case "cls":
            case "clear":
                area.setText("");
                break;
            case "v":
                File v = new File(currentPath, "v");
                if (!v.exists()) v = new File(currentPath, "v.exe");
                system(command.replaceFirst("v ", v.getAbsolutePath().replace('\\','/') + " ").trim().split(" "), true);
                break;
            case "sys":
                system(command.substring(3).trim().split(" "), false);
                break;
            case "cd":
                if (args.length == 1) {
                    add(currentPath.getAbsolutePath());
                    break;
                }
                File newPath = new File(currentPath, args[1]);
                if (newPath.exists()) {
                    currentPath = newPath;
                    break;
                }
                newPath = new File(args[1]);
                if (newPath.exists()) {
                    currentPath = newPath;
                    break;
                }
                break;
            case "help":
                add("===== Help =====", Color.CYAN);
                add("HELP\tDisplay this message");
                add("DIR\tPrints current dir");
                add("CLS\tClears the screen");
                add("CD\tChange current directory");
                add("V\tRun V cmd" + Vide.Version.V_FULL);
                break;
            default:
                add("Unknown command: " + args[0], Color.RED);
                break;
        }
    }

    private void add(String content) {
        add(content, Color.LIGHT_GRAY);
    }

    private void add(String content, Color c) {
        append("\n" + content, c);
    }
    
    private void append(String content, Color c) {
        StyledDocument d = area.getStyledDocument();
        Style style = d.getStyle(StyleContext.DEFAULT_STYLE);
        StyleConstants.setForeground(style, c);
        try {
            d.insertString(d.getLength(), content, style);
        } catch (BadLocationException e) { e.printStackTrace(); }
    }

    private void setLine(String content) {
        String[] txt = area.getText().split("\n");
        String last = txt[txt.length - 1];
        String lastA = last.substring(0, last.indexOf(">"));

        StyledDocument d = area.getStyledDocument();
        Style style = d.getStyle(StyleContext.DEFAULT_STYLE);
        StyleConstants.setForeground(style, Color.LIGHT_GRAY);

        try {
            int start = d.getLength() - (last.length() - lastA.length()) + 1;
            d.remove(start, d.getLength() - start);
            d.insertString(start, content, style);
        } catch (BadLocationException e) {}
    }

    private int lastL;
    private void system(String[] args, boolean block) {
        try {
            Process process = new ProcessBuilder(args).redirectError(Redirect.INHERIT).start();
            
            try (BufferedReader processOutputReader = new BufferedReader(new InputStreamReader(process.getInputStream()));) {
                String readLine;
                while ((readLine = processOutputReader.readLine()) != null) {
                    if (readLine.length() <= 0 && lastL != 0) {
                        lastL = readLine.length();
                        continue;
                    }
                    add(readLine);
                    lastL = readLine.length();
                }
                try {
                    if (block) process.waitFor();
                } catch (InterruptedException e) { e.printStackTrace(); }
            }
            process.destroy();
        } catch (IOException e) { e.printStackTrace(); }
    }

}