package com.javazilla.vide;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

public class VCmdRunner {


    public static String runV(String... args) throws IOException {
        File v = new File("include", "v.exe");

        ProcessBuilder b = new ProcessBuilder();
        b.directory(v.getParentFile());
        String[] argu = new String[args.length+1];
        argu[0] = v.getAbsolutePath();
        for (int i = 0; i < args.length; i++)
            argu[i+1] = args[i];
        b.command(argu);

        if (args[0].equalsIgnoreCase("run")) {
            Process pro = b.start();
            new Thread(() -> {
                InputStream is = pro.getInputStream();
                int i = 0;
                try {
                    while ((i = is.read()) != -1) {
                        Vide.barea.append(new String(new byte[] {(byte)i}));
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
                Vide.model.reload();
            }).start();
            return "running"; // Don't freeze while running
        }
        Process pro = b.start();

        String result = "";
        try(java.util.Scanner s = new java.util.Scanner(pro.getInputStream()))  { 
            result += s.useDelimiter("\\A").hasNext() ? s.next() : ""; 
        }
        try(java.util.Scanner s = new java.util.Scanner(pro.getErrorStream()))  { 
            result += s.useDelimiter("\\A").hasNext() ? s.next() : ""; 
        }
        return result;
    }

    public static String runInternal(String... args) {
        File v = new File("include", "v.exe");

        ProcessBuilder b = new ProcessBuilder();
        b.directory(v.getParentFile());
        String[] argu = new String[args.length+1];
        argu[0] = v.getAbsolutePath();
        for (int i = 0; i < args.length; i++)
            argu[i+1] = args[i];
        b.command(argu);

        try {
            Process pro = b.start();
            new Thread(() -> {
                InputStream is = pro.getInputStream();
                int i = 0;
                try {
                   while ((i = is.read()) != -1)
                        System.out.print(new String(new byte[] {(byte)i}));
                } catch (IOException e) {}
                Vide.model.reload();
            }).start();
        } catch (IOException e1) {}
        return "running"; // Don't freeze while running
    }

    public static String runV_NOE(String...args) {
        try {
            return runV(args);
        } catch (IOException e) {
            e.printStackTrace();
            return e.getMessage();
        }
    }

}