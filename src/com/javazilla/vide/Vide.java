package com.javazilla.vide;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Desktop;
import java.awt.Dimension;
import java.awt.Image;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import javax.imageio.ImageIO;
import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JComponent;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTabbedPane;
import javax.swing.JTextArea;
import javax.swing.JTree;
import javax.swing.UIManager;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.DefaultStyledDocument;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyleContext;

import org.sexydock.tabs.jhrome.JhromeTabbedPaneUI;

import com.formdev.flatlaf.FlatDarkLaf;
import com.formdev.flatlaf.FlatLightLaf;

public class Vide {

    public static double VERSION = 0.1;

    public static JTextArea barea = new JTextArea("Compiler output:\n");
    public static JTabbedPane tb;
    public static FileTreeModel model;
    public static JMenu saver;

    public static boolean DARK = false;

    public static void main(String[] args) throws IOException {
        try {
            UIManager.setLookAndFeel( DARK ? new FlatDarkLaf() : new FlatLightLaf() );
        } catch (Exception e2) {}

        JFrame f = new JFrame("VIDE " + VERSION);
        JPanel p = new JPanel(new BorderLayout());
        File file = new File(System.getProperty("user.home"), "Vide\\projects\\MyProject\\MyProject.v");
        file.getAbsoluteFile().getParentFile().mkdirs();
        if (!file.exists()) {
            String name = "MyProject";
            String des  = "example project";
            File fold = new File(file.getAbsoluteFile().getParentFile().getParentFile(), name);
            fold.mkdir();
            File fi = new File(fold, name + ".v");
            String wr = "module main\n\nfn main() {\n\tprintln('Hello World!')\n}";
            try {
                MyFileTree.init = false;
                File mod = new File(fold, "v.mod");
                String mo = "Module {\n\tname: 'MyProject'\n\tdescription: '" + des + "'\n\tversion: '0.0.0'\n\tdependencies: []\n}";
                Files.write(mod.toPath(), mo.getBytes());
                Files.write(fi.toPath(), wr.getBytes());
            } catch (IOException e) {e.printStackTrace();}
        }
        File home = new File(System.getProperty("user.home"), "Vide");
        exportResource("AboutDialog.v", null, home);
        exportResource("NewProjectDialog.v", null, home);
        exportResource("NewFileDialog.v", null, home);
        exportResource("TerminalDialog.v", null, home);
        exportResource("VpmDialog.v", null, home);
        exportResource("icons/vpm.png", "vpm.png", home);
        exportResource("icons/logo.png", "logo.png", home);

        MyFile mf = new MyFile(file.getAbsoluteFile().getParentFile().getParentFile());
        model = new FileTreeModel(mf);

        JMenuBar bar = new JMenuBar();
        bar.setBorder(BorderFactory.createEmptyBorder(4,4,4,4));
        JMenu fileM = bar.add(new JMenu("File"));
        fileM.add(new JMenuItem("New Project..")).addActionListener(l -> VCmdRunner.runInternal("NewProjectDialog.v"));
        fileM.add(new JMenuItem("New File..")).addActionListener(l -> VCmdRunner.runInternal("NewFileDialog.v"));
        fileM.add(new JMenuItem("Run..")).addActionListener(l -> System.out.println(VCmdRunner.runV_NOE("run", file.getAbsolutePath())));
        fileM.add(new JMenuItem("Build..")).addActionListener(l -> { System.out.println(VCmdRunner.runV_NOE(file.getAbsolutePath())); Vide.model.reload();});
        fileM.add(new JMenuItem("Open Terminal")).addActionListener(l -> VCmdRunner.runInternal("TerminalDialog.v"));
        fileM.add(new JMenuItem("Open VPM GUI")).addActionListener(l -> VCmdRunner.runInternal("VpmDialog.v"));
        JMenu helpM = bar.add(new JMenu("Help"));
        helpM.add(new JMenuItem("V Documentation")).addActionListener(l -> {
            try {
                Desktop.getDesktop().browse(new URL("https://github.com/vlang/v/blob/master/doc/docs.md").toURI());
            } catch (IOException | URISyntaxException e1) {}
        });
        helpM.add(new JMenuItem("Vlib docs")).addActionListener(l -> {
            try {
                Desktop.getDesktop().browse(new URL("https://modules.vlang.io/").toURI());
            } catch (IOException | URISyntaxException e1) {}
        });
        helpM.add(new JSeparator());
        
        saver = bar.add(new JMenu(""));
        saver.setIcon(new ImageIcon(getImage("save2.png",16,16, 250)));
        saver.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                TabContent.saveCurrent(tb);
                saver.setSelected(false);
                saver.setIcon(new ImageIcon(getImage("save2.png",16,16, 250)));
            }
        });

        JMenu run = bar.add(new JMenu(""));
        run.setIcon(new ImageIcon(getImage("run.png",16,16, 250)));
        run.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                TabContent.saveCurrent(tb);
                run.setSelected(false);
                System.out.println(VCmdRunner.runV_NOE("run", file.getAbsolutePath()));
            }
        });

        JMenu nf = bar.add(new JMenu(""));
        nf.setIcon(new ImageIcon(getImage("newfile.png",16,16, 250)));
        nf.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                VCmdRunner.runInternal("NewFileDialog.v");
                nf.setSelected(false);
            }
        });
        
        JMenu bd = bar.add(new JMenu(""));
        bd.setIcon(new ImageIcon(getImage("build.png",16,16,250)));
        bd.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                System.out.println(VCmdRunner.runV_NOE(file.getAbsolutePath())); Vide.model.reload();
                bd.setSelected(false);
            }
        });

        helpM.add(new JMenuItem("About VIDE")).addActionListener(l -> 
                VCmdRunner.runV_NOE("run", new File(home, "AboutDialog.v").getAbsolutePath()));
        f.setJMenuBar(bar);
        for (Component c : fileM.getMenuComponents()) ((JComponent)c).setBorder(BorderFactory.createEmptyBorder(7,9,7,9));
        for (Component c : helpM.getMenuComponents()) ((JComponent)c).setBorder(BorderFactory.createEmptyBorder(7,9,7,9));

        final JTree tree = new MyFileTree(model, file);
        tree.setEditable(false);
        tree.setPreferredSize(new Dimension(180,100));
        tree.setFocusable(false);
        tree.setBorder(BorderFactory.createEmptyBorder());
        if (DARK) tree.setBackground(new Color(62, 69, 70));
  
        JScrollPane tsp = new JScrollPane(tree);
        tsp.setFocusable(false);

        p.add(tsp, BorderLayout.WEST);
        p.setFocusable(false);

        tb = new JTabbedPane();
        JhromeTabbedPaneUI ui = new JhromeTabbedPaneUI();
        tb.setUI(ui);

        tb.putClientProperty( JhromeTabbedPaneUI.TAB_CLOSE_BUTTONS_VISIBLE, true );
        tb.putClientProperty( JhromeTabbedPaneUI.CONTENT_PANEL_BORDER, BorderFactory.createMatteBorder(0,0,0,0, Color.WHITE));

        TabContent.createTab(tb, file);

        p.add(tb, BorderLayout.CENTER);
        JScrollPane sp = new JScrollPane(barea);
        sp.setPreferredSize(new Dimension(300,100));
        sp.setFocusable(false);
        sp.setBorder(BorderFactory.createEmptyBorder());
        barea.setFocusable(false);

        JPanel bp = new JPanel(new BorderLayout());
        JLabel ap = new JLabel( new ImageIcon(getImage("logo.png", 60,24, 250)) );
        ap.setOpaque(true);
        ap.setBorder(BorderFactory.createEmptyBorder());
        barea.setBorder(BorderFactory.createEmptyBorder(4,4,4,4));
        ap.setBackground(DARK ? new Color(60, 67, 78) : new Color(230,230,230));
        ap.setPreferredSize(new Dimension(180, 100));
        bp.add(ap, BorderLayout.WEST);
        bp.add(sp, BorderLayout.CENTER);

        ap.setFocusable(false);
        sp.setFocusable(false);
        bp.setFocusable(false);
        p.add(bp, BorderLayout.SOUTH);

        Image iconn = getImage("icon.png", 64, 64, 250);
        f.setIconImage(iconn);

        f.setMinimumSize(new Dimension(840, 550));
        f.setContentPane(p);
        f.setDefaultCloseOperation(3);
        f.setLocationRelativeTo(null);
        f.setVisible(true);
    }

    public static Image getImage(String s,int a, int b, int i) {
        BufferedImage im = null;
        try {
            im = ImageIO.read(Vide.class.getClassLoader().getResourceAsStream("icons/" + s));
        } catch (IOException e){}
        for (int x = 0; x < im.getWidth(); x++) {
            for (int y = 0; y < im.getHeight(); y++) {
                Color c = new Color(im.getRGB(x, y));
                if (c.getRed() > i && c.getGreen() > i && c.getBlue() > i)
                    im.setRGB(x, y, new Color(0,0,0,0).getRGB());
            }
        }
        return im.getScaledInstance(a,b, Image.SCALE_SMOOTH);
    }

    public static DefaultStyledDocument setupStyle() {
        final StyleContext cont = StyleContext.getDefaultStyleContext();
        final AttributeSet attr = cont.addAttribute(cont.getEmptySet(), StyleConstants.Foreground, 
                DARK ? new Color(255, 26, 156) : new Color(150,0,85));
        final AttributeSet attr_string = cont.addAttribute(cont.getEmptySet(), StyleConstants.Foreground, new Color(100,150,0));
        final AttributeSet attr_number = cont.addAttribute(cont.getEmptySet(), StyleConstants.Foreground, new Color(240,170,0));
        final AttributeSet attrBlack = cont.addAttribute(cont.getEmptySet(), StyleConstants.Foreground, 
                DARK ? new Color(200,200,200) : Color.BLACK);

        DefaultStyledDocument doc = new DefaultStyledDocument() {
            private static final long serialVersionUID = 1L;
            String s = "(\\W)*(pub|struct|fn|const|mut|import)";

            public void insertString (int offset, String str, AttributeSet a) throws BadLocationException {
                super.insertString(offset, str, a);

                String text = getText(0, getLength());
                int before = findLastNonWordChar(text, offset);
                if (before < 0) before = 0;
                int after = findFirstNonWordChar(text, offset + str.length());
                int wordL = before;
                int wordR = before;

                while (wordR <= after) {
                    if (wordR == after || String.valueOf(text.charAt(wordR)).matches("\\W")) {
                        setCharacterAttributes(wordL, wordR - wordL, 
                                text.substring(wordL, wordR).matches(s) ? attr : attrBlack, true);
                        refresh(text);
                        wordL = wordR;
                    }
                    wordR++;
                }

                int i = 0;
                for (String s : text.split("\\s+")) {
                    String st = text.substring(i, i + s.length());
                    if (st.contains(".")) {
                        int ab = st.indexOf('.');
                        String str1 = st.substring(ab);
                        if (str1.indexOf('(') != -1) {
                            str1 = str1.substring(0,str1.indexOf('('));
                            setCharacterAttributes(i + ab, (str1).length(), attr_string, true);
                        }
                    }
                    i += s.length() + 1;
                }
            }

            private boolean string = false;
            public boolean refresh(String text) {
                boolean retur = false;
                for (int z = 0; z < text.length(); z++) {
                    char c = text.substring(z,z+1).charAt(0);
                    if ((int)c == 39 && !string) {
                        int end = text.substring(z+1).indexOf('\'');
                        if (end != -1) string = true;
                    } else if ((int) c == 39 && string) string = false;

                    if (string) setCharacterAttributes(z, 1, attr_string, true);
                    if ((int)c >= 48 && (int)c <= 57) {
                        setCharacterAttributes(z, 1, attr_number, true);
                        retur = true;
                    }
                }
                return retur;
            }

            public void remove(int offs, int len) throws BadLocationException {
                super.remove(offs, len);

                String text = getText(0, getLength());
                int before = findLastNonWordChar(text, offs);
                if (before < 0) before = 0;
                int after = findFirstNonWordChar(text, offs);

                setCharacterAttributes(before, after - before,
                        text.substring(before, after).matches(s) ?attr : attrBlack, false);
                refresh(text);
            }
        };
        return doc;
    }

    private static int findLastNonWordChar (String text, int index) {
        while (--index >= 0)
            if (String.valueOf(text.charAt(index)).matches("\\W")) break;
        return index;
    }

    private static int findFirstNonWordChar (String text, int index) {
        while (index < text.length()) {
            if (String.valueOf(text.charAt(index)).matches("\\W")) 
                break;
            index++;
        }
        return index;
    }

    public static Path exportResource(String res, String outn, File folder) {
        try (InputStream stream = Vide.class.getClassLoader().getResourceAsStream(res)) {
            if (stream == null) throw new IOException("Null " + res);
            if (outn == null) outn = res;

            Path p = Paths.get(folder.getAbsolutePath() + File.separator + outn);
            Files.copy(stream, p, StandardCopyOption.REPLACE_EXISTING);
            return p;
        } catch (IOException e) { e.printStackTrace(); return null;}

    }

}