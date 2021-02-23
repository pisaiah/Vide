package com.javazilla.vide;

import java.io.File;
import java.util.ArrayList;

import javax.swing.event.TreeModelEvent;
import javax.swing.event.TreeModelListener;
import javax.swing.tree.TreeModel;
import javax.swing.tree.TreeNode;
import javax.swing.tree.TreePath;

class FileTreeModel implements TreeModel {
    private final ArrayList<TreeModelListener>  mListeners  = new ArrayList<>();
    private final MyFile                        mFile;

    public FileTreeModel(final MyFile pFile) {
        mFile = pFile;
    }
    @Override public Object getRoot() {
        return mFile;
    }
    @Override public Object getChild(final Object pParent, final int pIndex) {
        return ((MyFile) pParent).listFiles()[pIndex];
    }
    @Override public int getChildCount(final Object pParent) {
        return ((MyFile) pParent).listFiles().length;
    }
    @Override public boolean isLeaf(final Object pNode) {
        return !((MyFile) pNode).isDirectory();
    }

    @Override public void valueForPathChanged(final TreePath pPath, final Object pNewValue) {
        final MyFile oldTmp = (MyFile) pPath.getLastPathComponent();
        final File oldFile = oldTmp.getFile();
        final String newName = (String) pNewValue;
        final File newFile = new File(oldFile.getParentFile(), newName);
        oldFile.renameTo(newFile);
        System.out.println("Renamed '" + oldFile + "' to '" + newFile + "'.");
        reload();
    }
    @Override public int getIndexOfChild(final Object pParent, final Object pChild) {
        final MyFile[] files = ((MyFile) pParent).listFiles();
        for (int i = 0; i < files.length; i++) {
            if (files[i] == pChild) return i;
        }
        return -1;
    }
    @Override public void addTreeModelListener(final TreeModelListener pL) {
        mListeners.add(pL);
    }
    @Override public void removeTreeModelListener(final TreeModelListener pL) {
        mListeners.remove(pL);
    }

    /**
     *  stolen from http://developer.classpath.org/doc/javax/swing/tree/DefaultTreeModel-source.html
     *
      * <p>
      * Invoke this method if you've modified the TreeNodes upon which this model
      * depends. The model will notify all of its listeners that the model has
      * changed. It will fire the events, necessary to update the layout caches and
      * repaint the tree. The tree will <i>not</i> be properly refreshed if you
      * call the JTree.repaint instead.
      * </p>
      * <p>
      * This method will refresh the information about whole tree from the root. If
      * only part of the tree should be refreshed, it is more effective to call
      * {@link #reload(TreeNode)}.
      * </p>
      */
    public void reload() {
        // Need to duplicate the code because the root can formally be
        // no an instance of the TreeNode.
        final int n = getChildCount(getRoot());
        final int[] childIdx = new int[n];
        final Object[] children = new Object[n];

        for (int i = 0; i < n; i++) {
            childIdx[i] = i;
            children[i] = getChild(getRoot(), i);
        }

        fireTreeStructureChanged(this, new Object[] { getRoot() }, childIdx, children);
    }

    /**
     * stolen from http://developer.classpath.org/doc/javax/swing/tree/DefaultTreeModel-source.html
     *
     * fireTreeStructureChanged
     *
     * @param source the node where the model has changed
     * @param path the path to the root node
     * @param childIndices the indices of the affected elements
     * @param children the affected elements
     */
    protected void fireTreeStructureChanged(final Object source, final Object[] path, final int[] childIndices, final Object[] children) {
        final TreeModelEvent event = new TreeModelEvent(source, path, childIndices, children);
        for (final TreeModelListener l : mListeners) {
            l.treeStructureChanged(event);
        }
    }
}

class MyFile {
    private final File mFile;

    public MyFile(final File pFile) {
        mFile = pFile;
    }

    public boolean isDirectory() {
        return mFile.isDirectory();
    }

    public MyFile[] listFiles() {
        final File[] files = mFile.listFiles();
        if (files == null) return null;
        if (files.length < 1) return new MyFile[0];

        ArrayList<MyFile> list = new ArrayList<>();

        for (int i = 0; i < files.length; i++) {
            final File f = files[i];
            if (f.isDirectory() && f.getName().startsWith(".")) // Hide hidden folders
                continue;
            list.add(new MyFile(f));
        }
        return list.toArray(new MyFile[0]);
    }

    public File getFile() {
        return mFile;
    }

    public String toString() {
        return mFile.getName();
    }
}