#pragma once

#include <string>
#include <functional>
#include <memory>

// Abstract base class for ad wrapper implementations
class AdWrapper {
public:
    // Callbacks (use std::function for flexibility)
    using InitCallback = std::function<void(bool success, const std::string& error)>;
    using AdLoadedCallback = std::function<void()>;
    using AdFailedCallback = std::function<void(const std::string& error)>;
    using AdClosedCallback = std::function<void()>;
    using RewardEarnedCallback = std::function<void()>;

    virtual ~AdWrapper() = default;

    // Lifecycle
    virtual void initialize(const std::string& appKey) = 0;
    virtual bool isInitialized() const = 0;

    // Privacy settings (GDPR, CCPA, COPPA)
    virtual void setGDPR(bool consent) = 0;
    virtual void setCCPA(bool doNotSell) = 0;
    virtual void setCOPPA(bool isAgeRestricted) = 0;

    // Banner Ads
    virtual void loadBannerAd(const std::string& placementId,
                              const std::string& size = "Banner",
                              const std::string& horizontalAlign = "Center",
                              const std::string& verticalAlign = "Bottom") = 0;
    virtual void showBannerAd() = 0;
    virtual void hideBannerAd() = 0;

    // Interstitial Ads
    virtual void loadInterstitialAd() = 0;
    virtual bool isInterstitialAdLoaded() const = 0;
    virtual void showInterstitialAd(const std::string& placementId = "") = 0;

    // Rewarded Ads
    virtual void loadRewardedAd() = 0;
    virtual bool isRewardedAdLoaded() const = 0;
    virtual void showRewardedAd(const std::string& placementId = "") = 0;

    // Callbacks
    virtual void setInitCallback(InitCallback callback) = 0;
    virtual void setBannerLoadedCallback(AdLoadedCallback callback) = 0;
    virtual void setBannerFailedCallback(AdFailedCallback callback) = 0;
    virtual void setInterstitialLoadedCallback(AdLoadedCallback callback) = 0;
    virtual void setInterstitialFailedCallback(AdFailedCallback callback) = 0;
    virtual void setInterstitialClosedCallback(AdClosedCallback callback) = 0;
    virtual void setRewardedLoadedCallback(AdLoadedCallback callback) = 0;
    virtual void setRewardedFailedCallback(AdFailedCallback callback) = 0;
    virtual void setRewardedEarnedCallback(RewardEarnedCallback callback) = 0;
    virtual void setRewardedClosedCallback(AdClosedCallback callback) = 0;
};
