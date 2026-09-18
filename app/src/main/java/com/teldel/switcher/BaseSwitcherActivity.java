package com.teldel.switcher;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.widget.Toast;
import moe.shizuku.server.IRemoteProcess;
import moe.shizuku.server.IShizukuService;
import rikka.shizuku.Shizuku;

public abstract class BaseSwitcherActivity extends Activity {

    private final Handler handler = new Handler(Looper.getMainLooper());
    private boolean executed = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        checkAndRun();
    }

    protected abstract String getScriptPath();
    protected abstract String getSuccessMessage();

    private void checkAndRun() {
        if (Shizuku.pingBinder()) {
            performAction();
        } else {
            Shizuku.addBinderReceivedListenerSticky(new Shizuku.OnBinderReceivedListener() {
                @Override
                public void onBinderReceived() {
                    Shizuku.removeBinderReceivedListener(this);
                    performAction();
                }
            });

            handler.postDelayed(() -> {
                if (!executed && !Shizuku.pingBinder()) {
                    Toast.makeText(getApplicationContext(), "Shizuku service is not running!", Toast.LENGTH_LONG).show();
                    finish();
                }
            }, 1500);
        }
    }

    private void performAction() {
        if (executed) return;
        executed = true;

        if (Shizuku.checkSelfPermission() != PackageManager.PERMISSION_GRANTED) {
            Toast.makeText(getApplicationContext(), "Granting Shizuku permission...", Toast.LENGTH_SHORT).show();
            Shizuku.requestPermission(100);
            finish();
            return;
        }

        Toast.makeText(getApplicationContext(), "Switching mode...", Toast.LENGTH_SHORT).show();

        new Thread(() -> {
            try {
                IBinder binder = Shizuku.getBinder();
                IShizukuService service = IShizukuService.Stub.asInterface(binder);
                IRemoteProcess process = service.newProcess(
                    new String[]{"sh", getScriptPath()}, null, null
                );
                int code = process.waitFor();
                handler.post(() -> {
                    if (code == 0) {
                        Toast.makeText(getApplicationContext(), getSuccessMessage(), Toast.LENGTH_LONG).show();
                    } else {
                        Toast.makeText(getApplicationContext(), "Failed: code " + code, Toast.LENGTH_LONG).show();
                    }
                    finish();
                });
            } catch (Exception e) {
                handler.post(() -> {
                    Toast.makeText(getApplicationContext(), "Error: " + e.getMessage(), Toast.LENGTH_LONG).show();
                    finish();
                });
            }
        }).start();
    }
}
