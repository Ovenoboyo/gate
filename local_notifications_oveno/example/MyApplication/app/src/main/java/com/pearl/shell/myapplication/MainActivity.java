package com.pearl.shell.myapplication;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.util.TypedValue;
import android.widget.TextView;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.aboutphone);

        CustomCardLayout test = findViewById(R.id.cardlayout1);
        Log.d("test", "onCreate: "+test.getTitleView().getText());

        CustomCardLayout test1 = findViewById(R.id.cardlayout2);
        Log.d("test", "onCreate: "+test1.getTitleView().getText());

        TextView textView = new TextView(getApplicationContext());
        String patch = "2019-06-05";
        int patchMonth = Integer.valueOf(patch.substring(5,7));
        int patchYear = Integer.valueOf(patch.substring(0,4));
        Log.d("test", "onCreate: "+patchMonth+patchYear);

        Calendar c = Calendar.getInstance();
        int year = c.get(Calendar.YEAR);
        int month = c.get(Calendar.MONTH);

        Log.d("test", "onCreate og: "+month+year);

        Character


        setCPU();
    }


    private void setCPU() {
        File f = new File("/sys/devices/system/cpu/");
        File[] files = f.listFiles();

        ArrayList<String> list = new ArrayList<>();

        for (File inFile : files) {
            if (inFile.isDirectory()) {
                if (inFile.toString().matches("/sys/devices/system/cpu/cpu[0-9]")) {
                    StringBuilder speed = new StringBuilder();

                    try {
                        Log.d("test", "setCPU: "+inFile.toString());
                        BufferedReader br = new BufferedReader(new FileReader(inFile.toString()+"/cpufreq/scaling_max_freq"));
                        String line;

                        while ((line = br.readLine()) != null) {
                            speed.append(line);
                            speed.append('\n');
                        }
                        br.close();
                    }
                    catch (IOException e) {
                    }
                    list.add(String.valueOf(speed).trim());
                }

            }
        }

        ArrayList<String> newList = new ArrayList<>();
        for (String element : list) {
            if (!newList.contains(element)) {
                newList.add(element);
            }
        }

        ArrayList<String> coreCount = new ArrayList<>(Arrays.asList(new String[10]));

        StringBuilder finalString = new StringBuilder();

        for (int i = 0; i<newList.size(); i++) {
            int k = 0;
            for (int j = 0; j<list.size(); j++) {
                if (list.get(j).equals(newList.get(i))) {
                    k++;
                    coreCount.set(i, ""+k);
                }
            }
        }

        for (int i = 0; i<newList.size(); i++) {
            int speedkhz = Integer.valueOf(newList.get(i));
            double speedghz = ((double)speedkhz) / 1000000;

            finalString.append(coreCount.get(i)).append(" Cores@").append(speedghz).append("GHz\n");

        }

        Log.d("test", "setCPU: "+finalString);
    }

}
