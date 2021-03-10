// tips4java.wordpress.com/2009/05/23/text-com-line-number
package com.javazilla.vide;

import java.awt.Dimension;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Insets;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.text.BadLocationException;
import javax.swing.text.Element;
import javax.swing.text.JTextComponent;
import javax.swing.text.Utilities;

public class TextLineNumber extends JPanel implements DocumentListener {

    private static final long serialVersionUID = 1L;
    private JTextComponent com;
    private final static int HEIGHT = Integer.MAX_VALUE - 1000000;

    private int lastDigits;
    private int lastHeight;

    public TextLineNumber(JTextComponent c) {
        this.com = c;

        setBorder(new EmptyBorder(0,4,0,4));
        lastDigits = 0;
        setFont(c.getFont());
        setPreferredWidth();

        c.getDocument().addDocumentListener(this);
    }

    private void setPreferredWidth() {
        int digits = Math.max(String.valueOf(com.getDocument().getDefaultRootElement().getElementCount()).length(), 3);

        if (lastDigits != digits) {
            lastDigits = digits;
            Insets in = getInsets();
            Dimension d = new Dimension(in.left+in.right+ (getFontMetrics(getFont()).charWidth('0') * digits), HEIGHT);
            setPreferredSize(d);
            setSize(d);
        }
    }

    @Override
    public void paintComponent(Graphics g) {
        super.paintComponent(g);
        ((Graphics2D)g).setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);

        Insets insets = getInsets();

        Rectangle clip = g.getClipBounds();
        int rsOffset = com.viewToModel(new Point(0, clip.y));
        int endOffset = com.viewToModel(new Point(0, clip.y + clip.height));

        while (rsOffset <= endOffset) {
            try {
                g.setColor(getForeground());
                String lineNumber = getTextLineNumber(rsOffset);
                g.drawString(lineNumber, insets.left, getOffsetY(rsOffset, com.getFontMetrics(com.getFont())));

                rsOffset = Utilities.getRowEnd(com, rsOffset) + 1;
            }catch(Exception e) {break;}
        }
    }

    private String getTextLineNumber(int rsoffset) {
        Element root = com.getDocument().getDefaultRootElement();
        int index = root.getElementIndex(rsoffset);
        return (root.getElement(index).getStartOffset() == rsoffset) ? String.valueOf(index + 1) : "";
    }

    private int getOffsetY(int rowStartOffset, FontMetrics fm) throws BadLocationException {
        Rectangle r = com.modelToView(rowStartOffset);
        return (r.y + r.height) - ((r.height == fm.getHeight()) ? fm.getDescent() : 0);
    }

    public void changedUpdate(DocumentEvent e){ documentChanged();}
    public void insertUpdate(DocumentEvent e){ documentChanged(); }
    public void removeUpdate(DocumentEvent e){ documentChanged(); }

    private void documentChanged() {
        SwingUtilities.invokeLater(() -> {
            try {
                Rectangle rect = com.modelToView(com.getDocument().getLength());
                if (rect != null && rect.y != lastHeight) {
                    setPreferredWidth();
                    repaint();
                    lastHeight = rect.y;
                }
            } catch (BadLocationException ignore) {}
        });
    }

}