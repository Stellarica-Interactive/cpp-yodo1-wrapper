package com.bachey.ads;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;

import java.lang.ref.WeakReference;

import com.yodo1.mas.Yodo1Mas;
import com.yodo1.mas.Yodo1MasSdkConfiguration;
import com.yodo1.mas.error.Yodo1MasError;
import com.yodo1.mas.banner.Yodo1MasBannerAdView;
import com.yodo1.mas.banner.Yodo1MasBannerAdSize;
import com.yodo1.mas.banner.Yodo1MasBannerAdListener;

import com.yodo1.mas.interstitial.Yodo1MasInterstitialAd;
import com.yodo1.mas.interstitial.Yodo1MasInterstitialAdListener;

import com.yodo1.mas.reward.Yodo1MasRewardAd;
import com.yodo1.mas.reward.Yodo1MasRewardAdListener;

public final class Yodo1MasNativeBridge {

    private static final Handler MAIN = new Handler(Looper.getMainLooper());
    private static WeakReference<Activity> sActivity = new WeakReference<>(null);

    private static volatile boolean sInitialized = false;

    private static Yodo1MasBannerAdView sBannerView = null;
    private static FrameLayout sBannerContainer = null;

    // ---- Native callbacks (you implement these in JNI/C++) ----
    private static native void nativeOnInit(boolean success, String error);

    private static native void nativeOnBannerLoaded();
    private static native void nativeOnBannerFailed(String error);

    private static native void nativeOnInterstitialLoaded();
    private static native void nativeOnInterstitialFailed(String error);
    private static native void nativeOnInterstitialClosed();

    private static native void nativeOnRewardedLoaded();
    private static native void nativeOnRewardedFailed(String error);
    private static native void nativeOnRewardedEarned();
    private static native void nativeOnRewardedClosed();

    private Yodo1MasNativeBridge() {}

    /** Call once from the host app (Activity) early (e.g. onCreate / plugin entry). */
    public static void setActivity(Activity activity) {
        sActivity = new WeakReference<>(activity);
    }

    private static Activity requireActivity() {
        Activity a = sActivity.get();
        if (a == null) throw new IllegalStateException("Yodo1MasNativeBridge Activity is null. Call setActivity().");
        return a;
    }

    private static void runOnUi(Runnable r) {
        if (Looper.myLooper() == Looper.getMainLooper()) r.run();
        else MAIN.post(r);
    }

    // -------------------------
    // Lifecycle
    // -------------------------
    public static void initialize(final String appKey) {
        runOnUi(() -> {
            final Activity activity = requireActivity();

            // Set up listeners *before* init (recommended pattern).
            hookInterstitialListener();
            hookRewardedListener();

            // Banner uses a view listener; we hook when we create the view.

            // Init MAS SDK
            Yodo1Mas.getInstance().initMas(activity, appKey, new Yodo1Mas.InitListener() {
                @Override
                public void onMasInitSuccessful() {
                    sInitialized = true;
                    nativeOnInit(true, "");
                }

                @Override
                public void onMasInitSuccessful(Yodo1MasSdkConfiguration configuration) {
                    sInitialized = true;
                    nativeOnInit(true, "");
                }

                @Override
                public void onMasInitFailed(@NonNull Yodo1MasError error) {
                    sInitialized = false;
                    nativeOnInit(false, error.toString());
                }
            });
        });
    }

    public static boolean isInitialized() {
        return sInitialized;
    }

    // -------------------------
    // Privacy (call BEFORE init if possible)
    // -------------------------
    public static void setGDPR(boolean consent) {
        Yodo1Mas.getInstance().setGDPR(consent);
    }

    public static void setCCPA(boolean doNotSell) {
        Yodo1Mas.getInstance().setCCPA(doNotSell);
    }

    public static void setCOPPA(boolean isAgeRestricted) {
        Yodo1Mas.getInstance().setCOPPA(isAgeRestricted);
    }

    // -------------------------
    // Banner
    // -------------------------
    public static void loadBanner(final String size, final String hAlign, final String vAlign) {
        runOnUi(() -> {
            Activity activity = requireActivity();

            ensureBannerContainer(activity);

            // Destroy old banner if any
            if (sBannerView != null) {
                sBannerContainer.removeView(sBannerView);
                sBannerView.destroy();
                sBannerView = null;
            }

            sBannerView = new Yodo1MasBannerAdView(activity);

            // Map string size -> enum (extend as you want)
            Yodo1MasBannerAdSize adSize = parseBannerSize(size);
            sBannerView.setAdSize(adSize);

            // Layout + gravity from (hAlign,vAlign)
            FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
            );
            lp.gravity = parseGravity(hAlign, vAlign);
            sBannerView.setLayoutParams(lp);

            sBannerView.setAdListener(new Yodo1MasBannerAdListener() {
                @Override public void onBannerAdLoaded(Yodo1MasBannerAdView view) { nativeOnBannerLoaded(); }

                @Override public void onBannerAdFailedToLoad(Yodo1MasBannerAdView view, @NonNull Yodo1MasError error) {
                    nativeOnBannerFailed(error.toString());
                }

                @Override public void onBannerAdOpened(Yodo1MasBannerAdView view) {}

                @Override public void onBannerAdFailedToOpen(Yodo1MasBannerAdView view, @NonNull Yodo1MasError error) {
                    nativeOnBannerFailed(error.toString());
                }

                @Override public void onBannerAdClosed(Yodo1MasBannerAdView view) {}
            });

            sBannerContainer.addView(sBannerView);
            sBannerView.loadAd(); // per docs  [oai_citation:1‡Yodo1](https://developers.yodo1.com/docs/sdk/guides/android/ad-formats)
        });
    }

    public static void showBanner() {
        runOnUi(() -> {
            if (sBannerView != null) sBannerView.setVisibility(android.view.View.VISIBLE);
        });
    }

    public static void hideBanner() {
        runOnUi(() -> {
            if (sBannerView != null) sBannerView.setVisibility(android.view.View.GONE);
        });
    }

    // -------------------------
    // Interstitial
    // -------------------------
    public static void loadInterstitial() {
        runOnUi(() -> {
            Activity a = requireActivity();
            if (a == null) return;
            Yodo1MasInterstitialAd.getInstance().loadAd(a);
        });
    }

    public static boolean isInterstitialLoaded() {
        return Yodo1MasInterstitialAd.getInstance().isLoaded();
    }

    public static void showInterstitial(final String placementIdOrEmpty) {
        runOnUi(() -> {
            Activity activity = requireActivity();
            if (!Yodo1MasInterstitialAd.getInstance().isLoaded()) return;

            if (placementIdOrEmpty != null && !placementIdOrEmpty.isEmpty()) {
                Yodo1MasInterstitialAd.getInstance().showAd(activity, placementIdOrEmpty);
            } else {
                Yodo1MasInterstitialAd.getInstance().showAd(activity);
            }
        });
    }

    private static void hookInterstitialListener() {
        Yodo1MasInterstitialAd.getInstance().setAdListener(new Yodo1MasInterstitialAdListener() {
            @Override public void onInterstitialAdLoaded(Yodo1MasInterstitialAd ad) { nativeOnInterstitialLoaded(); }

            @Override public void onInterstitialAdFailedToLoad(Yodo1MasInterstitialAd ad, @NonNull Yodo1MasError error) {
                nativeOnInterstitialFailed(error.toString());
            }

            @Override public void onInterstitialAdOpened(Yodo1MasInterstitialAd ad) {}

            @Override public void onInterstitialAdFailedToOpen(Yodo1MasInterstitialAd ad, @NonNull Yodo1MasError error) {
                nativeOnInterstitialFailed(error.toString());
            }

            @Override public void onInterstitialAdClosed(Yodo1MasInterstitialAd ad) { nativeOnInterstitialClosed(); }
        });
    }

    // -------------------------
    // Rewarded
    // -------------------------
    public static void loadRewarded() {
        runOnUi(() -> {
            Activity a = requireActivity();
            if (a == null) return;
            Yodo1MasRewardAd.getInstance().loadAd(a);
        });
    }

    public static boolean isRewardedLoaded() {
        return Yodo1MasRewardAd.getInstance().isLoaded();
    }

    public static void showRewarded(final String placementIdOrEmpty) {
        runOnUi(() -> {
            Activity activity = requireActivity();
            if (!Yodo1MasRewardAd.getInstance().isLoaded()) return;

            if (placementIdOrEmpty != null && !placementIdOrEmpty.isEmpty()) {
                Yodo1MasRewardAd.getInstance().showAd(activity, placementIdOrEmpty);
            } else {
                Yodo1MasRewardAd.getInstance().showAd(activity);
            }
        });
    }

    private static void hookRewardedListener() {
        Yodo1MasRewardAd.getInstance().setAdListener(new Yodo1MasRewardAdListener() {
            @Override public void onRewardAdLoaded(Yodo1MasRewardAd ad) { nativeOnRewardedLoaded(); }

            @Override public void onRewardAdFailedToLoad(Yodo1MasRewardAd ad, @NonNull Yodo1MasError error) {
                nativeOnRewardedFailed(error.toString());
            }

            @Override public void onRewardAdOpened(Yodo1MasRewardAd ad) {}

            @Override public void onRewardAdFailedToOpen(Yodo1MasRewardAd ad, @NonNull Yodo1MasError error) {
                nativeOnRewardedFailed(error.toString());
            }

            @Override public void onRewardAdEarned(Yodo1MasRewardAd ad) { nativeOnRewardedEarned(); }

            @Override public void onRewardAdClosed(Yodo1MasRewardAd ad) { nativeOnRewardedClosed(); }
        });
    }

    // -------------------------
    // Helpers
    // -------------------------
    private static void ensureBannerContainer(Activity activity) {
        if (sBannerContainer != null) return;

        // Add an overlay container on top of the activity content.
        ViewGroup root = activity.findViewById(android.R.id.content);

        sBannerContainer = new FrameLayout(activity);
        sBannerContainer.setLayoutParams(new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
        ));

        root.addView(sBannerContainer);
    }

    private static int parseGravity(String h, String v) {
        int gh;
        if ("Right".equalsIgnoreCase(h)) gh = Gravity.END;
        else if ("Center".equalsIgnoreCase(h)) gh = Gravity.CENTER_HORIZONTAL;
        else gh = Gravity.START;

        int gv;
        if ("Bottom".equalsIgnoreCase(v)) gv = Gravity.BOTTOM;
        else if ("Center".equalsIgnoreCase(v)) gv = Gravity.CENTER_VERTICAL;
        else gv = Gravity.TOP;

        return gh | gv;
    }

    private static Yodo1MasBannerAdSize parseBannerSize(String size) {
        if (size == null) return Yodo1MasBannerAdSize.Banner;
        switch (size) {
            case "LargeBanner":
                return Yodo1MasBannerAdSize.LargeBanner;
            case "SmartBanner":
                return Yodo1MasBannerAdSize.SmartBanner;
            case "IABMediumRectangle":
                return Yodo1MasBannerAdSize.IABMediumRectangle;
            case "AdaptiveBanner":
                return Yodo1MasBannerAdSize.AdaptiveBanner;
            case "Banner":
            default:
                return Yodo1MasBannerAdSize.Banner;
        }
    }
}