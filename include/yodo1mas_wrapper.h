#pragma once

#include <string>
#include <functional>

class Yodo1MasWrapper {
public:
    // Singleton instance
    static Yodo1MasWrapper& getInstance();

    // Lifecycle
    void initialize(const std::string& appKey);
    bool isInitialized() const;

    // Privacy settings (GDPR, CCPA, COPPA)
    void setGDPR(bool consent);
    void setCCPA(bool doNotSell);
    void setCOPPA(bool isAgeRestricted);

    // Banner Ads
    void loadBannerAd(const std::string& placementId,
                      const std::string& size = "Banner",
                      const std::string& horizontalAlign = "Center",
                      const std::string& verticalAlign = "Bottom");
    void showBannerAd();
    void hideBannerAd();

    // Interstitial Ads
    void loadInterstitialAd();
    bool isInterstitialAdLoaded() const;
    void showInterstitialAd(const std::string& placementId = "");

    // Rewarded Ads
    void loadRewardedAd();
    bool isRewardedAdLoaded() const;
    void showRewardedAd(const std::string& placementId = "");

    // Callbacks (use std::function for flexibility)
    using InitCallback = std::function<void(bool success, const std::string& error)>;
    using AdLoadedCallback = std::function<void()>;
    using AdFailedCallback = std::function<void(const std::string& error)>;
    using AdClosedCallback = std::function<void()>;
    using RewardEarnedCallback = std::function<void()>;

    void setInitCallback(InitCallback callback);
    void setBannerLoadedCallback(AdLoadedCallback callback);
    void setBannerFailedCallback(AdFailedCallback callback);
    void setInterstitialLoadedCallback(AdLoadedCallback callback);
    void setInterstitialFailedCallback(AdFailedCallback callback);
    void setInterstitialClosedCallback(AdClosedCallback callback);
    void setRewardedLoadedCallback(AdLoadedCallback callback);
    void setRewardedFailedCallback(AdFailedCallback callback);
    void setRewardedEarnedCallback(RewardEarnedCallback callback);
    void setRewardedClosedCallback(AdClosedCallback callback);

private:
    Yodo1MasWrapper();
    ~Yodo1MasWrapper();
    Yodo1MasWrapper(const Yodo1MasWrapper&) = delete;
    Yodo1MasWrapper& operator=(const Yodo1MasWrapper&) = delete;

    class Impl;
    Impl* pImpl; // Platform-specific implementation
};
