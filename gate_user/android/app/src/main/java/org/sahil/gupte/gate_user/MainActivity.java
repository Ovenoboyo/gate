package org.sahil.gupte.gate_user;

import android.app.Notification;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.PowerManager;
import android.provider.Settings;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    Log.d("mainactivity", "onCreate: here");
    Intent intent = new Intent();
    String packageName = getPackageName();
    PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
    if (pm.isIgnoringBatteryOptimizations(packageName))
      intent.setAction(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS);
    else {
      intent.setAction(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS);
      intent.setData(Uri.parse("package:" + packageName));
    }
    startActivity(intent);
  }
}
