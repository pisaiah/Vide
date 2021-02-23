/*
Copyright 2012 James Edwards

This file is part of Jhrome.

Jhrome is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Jhrome is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Jhrome.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.sexydock.tabs.jhrome;

import java.awt.Color;
import java.awt.Component;
import java.awt.GradientPaint;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Insets;
import java.awt.Paint;
import java.awt.Point;
import java.awt.RenderingHints;
import java.awt.Stroke;
import java.awt.geom.Path2D;

import javax.swing.border.Border;

import com.javazilla.vide.Vide;

/**
 * The default (Google Chrome style) border and background for a {@code JhromeTab}.
 * 
 * @author andy.edwards
 */
public class JhromeTabBorder implements Border {
    public final JhromeTabBorderAttributes  attrs   = new JhromeTabBorderAttributes( );
    
    private Path2D openPath;
    private Path2D closedPath;

    public boolean isFlip() {return false;}
    public void setFlip(boolean f) {}
    

    private void updatePaths(int x, int y, int width, int height) {
        if( width < attrs.insets.left + attrs.insets.right ) return;

        openPath = new Path2D.Double( Path2D.WIND_EVEN_ODD );

        openPath.moveTo(x , y + height - attrs.insets.bottom );
        openPath.lineTo(x, y + attrs.insets.top);
        openPath.lineTo(x + width - attrs.insets.right + 4, y + attrs.insets.top );
        openPath.lineTo(x + width - 11, y + height - attrs.insets.bottom );

        closedPath = (Path2D) openPath.clone( );
        closedPath.closePath( );
    }

    public boolean contains(Point p) {
        return closedPath != null ? closedPath.contains(p) : false;
    }

    @Override
    public void paintBorder( Component c , Graphics g , int x , int y , int width , int height ) {
        if(width < attrs.insets.left + attrs.insets.right) return;

        Graphics2D g2 = (Graphics2D) g;
        updatePaths( x, y, width, height);

        Object prevAntialias = g2.getRenderingHint( RenderingHints.KEY_ANTIALIASING );
        g2.setRenderingHint( RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON );

        Stroke prevStroke = g2.getStroke();
        Paint prevPaint = g2.getPaint();

        int a = Vide.DARK ? 100 : 248;
        Color bg1 = new Color(a+5,a+5,a+5);
        Color bg2 = new Color(a,a,a);

        g2.setPaint( new GradientPaint( 0,  y, bg1, 0, y + height - 1, bg2 ) );
        g2.fill(closedPath);

        if(attrs.outlineVisible){
            g2.setStroke(attrs.outlineStroke);
            int o = Vide.DARK ? 80 : 232;
            g2.setColor(new Color(o,o,o));
            g2.draw(openPath);
        }

        g2.setPaint( prevPaint );
        g2.setStroke( prevStroke );
        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, prevAntialias);
    }

    @Override
    public Insets getBorderInsets(Component c) {
        return (Insets) attrs.insets.clone();
    }

    @Override
    public boolean isBorderOpaque() {
        return true;
    }

}