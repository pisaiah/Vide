package com.javazilla.vide;

import static com.javazilla.vide.VCmdRunner.run;
import static com.javazilla.vide.VCmdRunner.runV;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Desktop;
import java.awt.Dimension;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;

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

import com.formdev.flatlaf.FlatDarkLaf;
import com.formdev.flatlaf.FlatLightLaf;

public class Vide {

    public static double VERSION = 0.1;

    public static JTextArea barea = new JTextArea("Compiler output:\n");
    public static JTabbedPane tb;
    public static FileTreeModel model;
    public static JMenu saver;

    public static ImageIcon save1 = getImage("save.png",16);
    public static ImageIcon save2 = getImage("save2.png",16);

    public static boolean DARK = false;
    public static int FONT = 12;

    public static void main(String[] args) throws IOException {
        JFrame f = new JFrame("VIDE " + VERSION);
        JPanel p = new JPanel(new BorderLayout());
        File file = new File(System.getProperty("user.home"), "Vide\\projects\\MyProject\\MyProject.v");

        File home = new File(System.getProperty("user.home"), "Vide");
        for (String s : new String[] {"About","NewProject","NewFile","Terminal","Vpm","Settings"})
            exportResource(s + "Dialog.v", null, home);
        exportResource("icons/vpm.png", "vpm.png", home);
        exportResource("icons/logo.png", "logo.png", home);
        
        File sett = new File(home, "settings.txt");
        List<String> li = Files.readAllLines(sett.toPath());
        if (li.size() > 0) {
            file = new File(li.get(3).split("=")[1], "MyProject\\MyProject.v");
            DARK = li.get(1).equals("dark=true");
            FONT = Integer.valueOf(li.get(4).substring(5));
        }

        try {
            UIManager.setLookAndFeel(DARK ? new FlatDarkLaf() : new FlatLightLaf());
        } catch (Exception e) {}

        file.getAbsoluteFile().getParentFile().mkdirs();
        if (!file.exists()) {
            try {
                MyFileTree.init = false;
                String mo = "Module {\n\tname: 'MyProject'\n\tdescription: 'example'\n\tversion: '0.0.0'\n\tdependencies: []\n}";
                Files.write(new File(file.getAbsoluteFile().getParentFile(), "v.mod").toPath(), mo.getBytes());
                Files.write(file.toPath(), "module main\n\nfn main() {\n\tprintln('Hello World!')\n}".getBytes());
            } catch (IOException e) {e.printStackTrace();}
        }

        MyFile mf = new MyFile(file.getAbsoluteFile().getParentFile().getParentFile());
        model = new FileTreeModel(mf);

        JMenuBar bar = new JMenuBar();
        bar.setBorder(BorderFactory.createEmptyBorder(4,4,4,4));
        JMenu fileM = bar.add(new JMenu("File"));
        fileM.add(new JMenuItem("New Project")).addActionListener(l -> run("NewProjectDialog"));
        fileM.add(new JMenuItem("New File")).addActionListener(l -> run("NewFileDialog"));
        fileM.add(new JMenuItem("Run")).addActionListener(l -> runV("run", TabContent.file(tb).getAbsolutePath()));
        fileM.add(new JMenuItem("Build")).addActionListener(l -> { runV(TabContent.file(tb).getAbsolutePath()); Vide.model.reload();});
        fileM.add(new JMenuItem("Open Terminal")).addActionListener(l -> run("TerminalDialog"));
        fileM.add(new JMenuItem("Open VPM GUI")).addActionListener(l -> run("VpmDialog"));
        fileM.add(new JMenuItem("Settings")).addActionListener(l -> run("SettingsDialog"));
        JMenu helpM = bar.add(new JMenu("Help"));
        helpM.add(new JMenuItem("V Documentation")).addActionListener(l -> browse("github.com/vlang/v/blob/master/doc/docs.md"));
        helpM.add(new JMenuItem("Vlib docs")).addActionListener(l -> browse("modules.vlang.io"));
        helpM.add(new JSeparator());

        saver = bar.add(new JMenu(""));
        saver.setIcon(save2);
        saver.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                TabContent.saveCurrent(tb);
                saver.setSelected(false);
                saver.setIcon(save2);
            }
        });

        JMenu run = bar.add(new JMenu(""));
        run.setIcon(getImage("run.png",16));
        run.addMouseListener(mouse(run, () -> {
            TabContent.saveCurrent(tb);
            runV("run", TabContent.file(tb).getAbsolutePath());
        }));

        JMenu nf = bar.add(new JMenu(""));
        nf.setIcon(getImage("newfile.png",16));
        nf.addMouseListener(mouse(nf, ()-> run("NewFileDialog")));

        JMenu bd = bar.add(new JMenu(""));
        bd.setIcon(getImage("build.png",16));
        bd.addMouseListener(mouse(bd, () -> {runV(TabContent.file(tb).getAbsolutePath()); Vide.model.reload();}));

        helpM.add(new JMenuItem("About VIDE")).addActionListener(l -> run("AboutDialog"));
        f.setJMenuBar(bar);
        for (JMenu m : new JMenu[] {fileM, helpM})
            for (Component c : m.getMenuComponents()) ((JComponent)c).setBorder(BorderFactory.createEmptyBorder(7,9,7,9));

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

        TabContent.createTab((tb = new TabPane()), file);

        p.add(tb, BorderLayout.CENTER);
        JScrollPane sp = new JScrollPane(barea);
        sp.setPreferredSize(new Dimension(300,100));
        sp.setFocusable(false);
        sp.setBorder(BorderFactory.createEmptyBorder());
        barea.setFocusable(false);

        JPanel bp = new JPanel(new BorderLayout());
        JLabel ap = new JLabel(getImage("logo.png", 60,24));
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

        f.setIconImage(getImage("icon.png", 64).getImage());

        f.setMinimumSize(new Dimension(840, 550));
        f.setContentPane(p);
        f.setDefaultCloseOperation(3);
        f.setLocationRelativeTo(null);
        f.setVisible(true);
    }

    public static MouseAdapter mouse(JMenu men, Runnable r) {
        return new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                men.setSelected(false);
                r.run();
            }
        };
    }

    public static void browse(String url) {
        try {
            Desktop.getDesktop().browse(new URL("https://" + url).toURI());
        } catch (Exception e1) {}
    }

    public static ImageIcon getImage(String s, int... a) {
        BufferedImage i = null;
        try {
            i = ImageIO.read(Vide.class.getClassLoader().getResourceAsStream("icons/" + s));
        } catch (IOException e){}
        for (int x = 0; x < i.getWidth(); x++) {
            for (int y = 0; y < i.getHeight(); y++) {
                Color c = new Color(i.getRGB(x, y));
                int z = 250;
                if (c.getRed()>z && c.getGreen()>z && c.getBlue()>z) i.setRGB(x,y,0);
            }
        }
        return new ImageIcon(i.getScaledInstance(a[0],a[a.length-1], 4));
    }

    public static Path exportResource(String res, String outn, File folder) {
        try (InputStream stream = Vide.class.getClassLoader().getResourceAsStream(res)) {
            if (stream == null) throw new IOException(res);
            if (outn == null) outn = res;

            Path p = Paths.get(folder.getAbsolutePath() + File.separator + outn);
            Files.copy(stream, p, StandardCopyOption.REPLACE_EXISTING);
            return p;
        } catch (IOException e){ e.printStackTrace(); return null;}

    }

}