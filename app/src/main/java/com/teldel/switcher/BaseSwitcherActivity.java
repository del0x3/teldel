package com.teldel.switcher;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;
import moe.shizuku.server.IRemoteProcess;
import moe.shizuku.server.IShizukuService;
import rikka.shizuku.Shizuku;

public abstract class BaseSwitcherActivity extends Activity {

    private static final String TAG = "TeldelSwitcher";
    private final Handler handler = new Handler(Looper.getMainLooper());
    private boolean executedShizuku = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        executeAll();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        executedShizuku = false;
        executeAll();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacksAndMessages(null);
    }

    protected abstract boolean isStock();
    protected abstract String getScriptPath();
    protected abstract String getSuccessMessage();

    private void executeAll() {
        boolean stock = isStock();

        // 1. Direct System Settings (Instant, 100% Autonomous, Reboot-Proof)
        applyDirectSettings(stock);

        // 2. Launch Target Home Screen
        launchHomeScreen(stock);

        Toast.makeText(getApplicationContext(), getSuccessMessage(), Toast.LENGTH_SHORT).show();

        // 3. Shizuku Deep Execution (Freeze/Unfreeze apps & Role Manager)
        runShizukuIfAvailable();
    }

    private void runShizukuIfAvailable() {
        if (Shizuku.pingBinder()) {
            executeShizukuProcess();
        } else {
            Shizuku.OnBinderReceivedListener listener = new Shizuku.OnBinderReceivedListener() {
                @Override
                public void onBinderReceived() {
                    Shizuku.removeBinderReceivedListener(this);
                    executeShizukuProcess();
                }
            };
            Shizuku.addBinderReceivedListenerSticky(listener);
            handler.postDelayed(this::cleanupAndExit, 1500);
        }
    }

    private void executeShizukuProcess() {
        if (executedShizuku) return;
        executedShizuku = true;

        if (Shizuku.checkSelfPermission() != PackageManager.PERMISSION_GRANTED) {
            Log.w(TAG, "Shizuku permission not granted");
            cleanupAndExit();
            return;
        }

        new Thread(() -> {
            try {
                IBinder binder = Shizuku.getBinder();
                IShizukuService service = IShizukuService.Stub.asInterface(binder);
                IRemoteProcess process = service.newProcess(new String[]{"sh", getScriptPath()}, null, null);
                int code = process.waitFor();
                Log.i(TAG, "Shizuku script finished with code: " + code);
            } catch (Exception e) {
                Log.e(TAG, "Shizuku execution error: " + e.getMessage());
            } finally {
                handler.post(this::cleanupAndExit);
            }
        }).start();
    }

    private void cleanupAndExit() {
        try {
            finishAndRemoveTask();
        } catch (Throwable ignored) {
            finish();
        }
    }

    private void putSecureInt(String name, int val) {
        try {
            boolean res = Settings.Secure.putInt(getContentResolver(), name, val);
            Log.i(TAG, "putSecureInt " + name + "=" + val + " -> " + res);
        } catch (Throwable t) {
            Log.w(TAG, "putSecureInt " + name + " error: " + t.getMessage());
        }
    }

    private void putGlobalInt(String name, int val) {
        try {
            boolean res = Settings.Global.putInt(getContentResolver(), name, val);
            Log.i(TAG, "putGlobalInt " + name + "=" + val + " -> " + res);
        } catch (Throwable t) {
            Log.w(TAG, "putGlobalInt " + name + " error: " + t.getMessage());
        }
    }

    private void putGlobalFloat(String name, float val) {
        try {
            boolean res = Settings.Global.putFloat(getContentResolver(), name, val);
            Log.i(TAG, "putGlobalFloat " + name + "=" + val + " -> " + res);
        } catch (Throwable t) {
            Log.w(TAG, "putGlobalFloat " + name + " error: " + t.getMessage());
        }
    }

    private void putSystemInt(String name, int val) {
        try {
            boolean res = Settings.System.putInt(getContentResolver(), name, val);
            Log.i(TAG, "putSystemInt " + name + "=" + val + " -> " + res);
        } catch (Throwable t) {
            Log.w(TAG, "putSystemInt " + name + " error: " + t.getMessage());
        }
    }

    private void applyDirectSettings(boolean stock) {
        // Display Colors: AOSP daltonizer and Extra Dim
        putSecureInt("accessibility_display_daltonizer_enabled", stock ? 0 : 1);
        putSecureInt("accessibility_display_daltonizer", stock ? -1 : 0);
        putSecureInt("reduce_bright_colors_activated", stock ? 0 : 1);
        putSystemInt("greyscale_mode", stock ? 0 : 1);

        // Window & Transition Animations
        float anim = stock ? 1.0f : 0.0f;
        putGlobalFloat("window_animation_scale", anim);
        putGlobalFloat("transition_animation_scale", anim);
        putGlobalFloat("animator_duration_scale", anim);

        // Notifications & Badging
        int notif = stock ? 1 : 0;
        putGlobalInt("heads_up_notifications_enabled", notif);
        putSecureInt("notification_badging", notif);

        // Sensory Feedback (Sound & Haptics)
        putSystemInt("sound_effects_enabled", notif);
        putSystemInt("haptic_feedback_enabled", notif);
    }

    private void launchHomeScreen(boolean stock) {
        try {
            Intent home = new Intent(Intent.ACTION_MAIN);
            home.addCategory(Intent.CATEGORY_HOME);
            if (stock) {
                home.setComponent(new ComponentName("com.sec.android.app.launcher", "com.sec.android.app.launcher.activities.LauncherActivity"));
            } else {
                home.setPackage("app.olauncher");
            }
            home.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
            startActivity(home);
        } catch (Exception e) {
            Log.e(TAG, "launchHomeScreen error: " + e.getMessage());
        }
    }
}
