package com.stellaricainteractive.ads;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.collection.ArraySet;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;

import java.util.Set;

public final class Yodo1GodotPlugin extends GodotPlugin {
    private static final String TAG = "Yodo1GodotPlugin";

    static {
        // Try loading native library with different possible names
        boolean loaded = false;
        String[] libNames = {
            "bachey.android.template_release.arm64",
            "bachey.android.template_debug.arm64",
            "bachey.android.template_release.armv7",
            "bachey.android.template_debug.armv7",
            "bachey.android.template_release.x86_64",
            "bachey.android.template_debug.x86_64",
            "bachey"
        };

        for (String libName : libNames) {
            try {
                System.loadLibrary(libName);
                Log.d("Yodo1GodotPlugin", "Successfully loaded library: " + libName);
                loaded = true;
                break;
            } catch (UnsatisfiedLinkError e) {
                // Try next variant
            }
        }

        if (!loaded) {
            Log.w("Yodo1GodotPlugin", "Native library not found - JNI methods will not be available");
        }
    }

    private static native void nativeSetActivity(Activity activity);

    public Yodo1GodotPlugin(Godot godot) {
        super(godot);
        Log.d(TAG, "Yodo1GodotPlugin constructor called");
    }

    @NonNull
    @Override
    public String getPluginName() {
        return "Yodo1GodotPlugin";
    }

    @Override
    public android.view.View onMainCreate(Activity activity) {
        Log.d(TAG, "onMainCreate - setting activity for Yodo1MasNativeBridge");

        // Set the activity in the native bridge
        Yodo1MasNativeBridge.setActivity(activity);

        // Also pass to native C++ side if needed
        nativeSetActivity(activity);

        return null;
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new ArraySet<>();

        // Define signals that can be emitted to Godot
        signals.add(new SignalInfo("yodo1_initialized", Boolean.class, String.class));
        signals.add(new SignalInfo("banner_loaded"));
        signals.add(new SignalInfo("banner_failed", String.class));
        signals.add(new SignalInfo("interstitial_loaded"));
        signals.add(new SignalInfo("interstitial_failed", String.class));
        signals.add(new SignalInfo("interstitial_closed"));
        signals.add(new SignalInfo("rewarded_loaded"));
        signals.add(new SignalInfo("rewarded_failed", String.class));
        signals.add(new SignalInfo("rewarded_earned"));
        signals.add(new SignalInfo("rewarded_closed"));

        return signals;
    }
}
