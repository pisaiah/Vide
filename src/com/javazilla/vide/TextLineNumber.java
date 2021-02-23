// https://tips4java.wordpress.com/2009/05/23/text-component-line-number/

package com.javazilla.vide;

import java.awt.Dimension;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Insets;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.HashMap;

import javax.swing.JPanel;
import javax.swing.SwingUtilities;
import javax.swing.border.EmptyBorder;
import javax.swing.event.CaretEvent;
import javax.swing.event.CaretListener;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.text.AttributeSet;
import javax.swing.text.BadLocationException;
import javax.swing.text.Element;
import javax.swing.text.JTextComponent;
import javax.swing.text.StyleConstants;
import javax.swing.text.Utilities;

public class TextLineNumber extends JPanel implements CaretListener, DocumentListener, PropertyChangeListener {

    private static final long serialVersionUID = 1L;
    private JTextComponent component;
    private final static int HEIGHT = Integer.MAX_VALUE - 1000000;

    private boolean updateFont;
    private float digitAlignment;
    private int minimumDisplayDigits;
    private int lastDigits;
    private int lastHeight;
    private int lastLine;

    private HashMap<String, FontMetrics> fonts;

    public TextLineNumber(JTextComponent component, int minimumDisplayDigits) {
        this.component = component;

        setBorder(new EmptyBorder(0,4,0,4));
        lastDigits = 0;
        this.minimumDisplayDigits = minimumDisplayDigits;
        setPreferredWidth();

        component.getDocument().addDocumentListener(this);
        component.addCaretListener(this);
        component.addPropertyChangeListener("font", this);
    }

    private void setPreferredWidth() {
        Element root = component.getDocument().getDefaultRootElement();
        int lines = root.getElementCount();
        int digits = Math.max(String.valueOf(lines).length(), minimumDisplayDigits);

        if (lastDigits != digits) {
            lastDigits = digits;
            FontMetrics fontMetrics = getFontMetrics(getFont());
            int width = fontMetrics.charWidth('0') * digits;
            Insets insets = getInsets();
            int preferredWidth = insets.left + insets.right + width;

            Dimension d = getPreferredSize();
            d.setSize(preferredWidth, HEIGHT);
            setPreferredSize(d);
            setSize(d);
        }
    }

    @Override
    public void paintComponent(Graphics g) {
        super.paintComponent(g);
        ((Graphics2D)g).setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);

        FontMetrics fontMetrics = component.getFontMetrics( component.getFont() );
        Insets insets = getInsets();
        int availableWidth = getSize().width - insets.left - insets.right;

        Rectangle clip = g.getClipBounds();
        int rowStartOffset = component.viewToModel( new Point(0, clip.y) );
        int endOffset = component.viewToModel( new Point(0, clip.y + clip.height) );

        while (rowStartOffset <= endOffset) {
            try {
                g.setColor(getForeground());
                String lineNumber = getTextLineNumber(rowStartOffset);
                int stringWidth = fontMetrics.stringWidth( lineNumber );
                int x = (int)((availableWidth - stringWidth) * digitAlignment) + insets.left;
                int y = getOffsetY(rowStartOffset, fontMetrics);
                g.drawString(lineNumber, x, y);

                rowStartOffset = Utilities.getRowEnd(component, rowStartOffset) + 1;
            }catch(Exception e) {break;}
        }
    }

    private String getTextLineNumber(int rowStartOffset) {
        Element root = component.getDocument().getDefaultRootElement();
        int index = root.getElementIndex( rowStartOffset );
        Element line = root.getElement( index );

        return (line.getStartOffset() == rowStartOffset) ? String.valueOf(index + 1) : "";
    }

    private int getOffsetY(int rowStartOffset, FontMetrics fontMetrics) throws BadLocationException {
        Rectangle r = component.modelToView( rowStartOffset );
        int lineHeight = fontMetrics.getHeight();
        int y = r.y + r.height;
        int descent = 0;

        if (r.height == lineHeight)
            descent = fontMetrics.getDescent();
        else {
            if (fonts == null) fonts = new HashMap<String, FontMetrics>();

            Element root = component.getDocument().getDefaultRootElement();
            int index = root.getElementIndex( rowStartOffset );
            Element line = root.getElement( index );

            for (int i = 0; i < line.getElementCount(); i++){
                Element child = line.getElement(i);
                AttributeSet as = child.getAttributes();
                String fontFamily = (String)as.getAttribute(StyleConstants.FontFamily);
                Integer fontSize = (Integer)as.getAttribute(StyleConstants.FontSize);
                String key = fontFamily + fontSize;

                FontMetrics fm = fonts.get(key);

                if (fm == null) {
                    Font font = new Font(fontFamily, Font.PLAIN, fontSize);
                    fm = component.getFontMetrics(font);
                    fonts.put(key, fm);
                }

                descent = Math.max(descent, fm.getDescent());
            }
        }

        return y - descent;
    }

    @Override
    public void caretUpdate(CaretEvent e) {
        int currentLine = component.getDocument().getDefaultRootElement().getElementIndex(component.getCaretPosition());
        if (lastLine != currentLine){
            repaint();
            lastLine = currentLine;
        }
    }

    @Override
    public void changedUpdate(DocumentEvent e){
        documentChanged();
    }

    @Override
    public void insertUpdate(DocumentEvent e){
        documentChanged();
    }

    @Override
    public void removeUpdate(DocumentEvent e){
        documentChanged();
    }

    private void documentChanged() {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                try {
                    int endPos = component.getDocument().getLength();
                    Rectangle rect = component.modelToView(endPos);

                    if (rect != null && rect.y != lastHeight) {
                        setPreferredWidth();
                        repaint();
                        lastHeight = rect.y;
                    }
                } catch (BadLocationException ignore) {}
            }
        });
    }

    @Override
    public void propertyChange(PropertyChangeEvent evt) {
        if (evt.getNewValue() instanceof Font) {
            if (updateFont) {
                Font newFont = (Font) evt.getNewValue();
                setFont(newFont);
                lastDigits = 0;
                setPreferredWidth();
            } else repaint();
        }
    }

}