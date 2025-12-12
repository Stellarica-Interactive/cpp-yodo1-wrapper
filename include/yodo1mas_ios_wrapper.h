#pragma once

#include "yodo1mas_wrapper.h"

// Forward declaration for Objective-C++ bridge
#ifdef __OBJC__
@class Yodo1IOSAdBridge;
#else
typedef struct objc_object Yodo1IOSAdBridge;
#endif

// Concrete iOS implementation of AdWrapper
class Yodo1IOSAdWrapper : public AdWrapper {
public:
    Yodo1IOSAdWrapper();
    ~Yodo1IOSAdWrapper() override;

    // Lifecycle
    void initialize(const std::string& appKey) override;
    bool isInitialized() const override;

    // Privacy settings
    void setGDPR(bool consent) override;
    void setCCPA(bool doNotSell) override;
    void setCOPPA(bool isAgeRestricted) override;

    // Banner Ads
    void loadBannerAd(const std::string& placementId,
                      const std::string& size = "Banner",
                      const std::string& horizontalAlign = "Center",
                      const std::string& verticalAlign = "Bottom") override;
    void showBannerAd() override;
    void hideBannerAd() override;

    // Interstitial Ads
    void loadInterstitialAd() override;
    bool isInterstitialAdLoaded() const override;
    void showInterstitialAd(const std::string& placementId = "") override;

    // Rewarded Ads
    void loadRewardedAd() override;
    bool isRewardedAdLoaded() const override;
    void showRewardedAd(const std::string& placementId = "") override;

    // Callbacks
    void setInitCallback(InitCallback callback) override;
    void setBannerLoadedCallback(AdLoadedCallback callback) override;
    void setBannerFailedCallback(AdFailedCallback callback) override;
    void setInterstitialLoadedCallback(AdLoadedCallback callback) override;
    void setInterstitialFailedCallback(AdFailedCallback callback) override;
    void setInterstitialClosedCallback(AdClosedCallback callback) override;
    void setRewardedLoadedCallback(AdLoadedCallback callback) override;
    void setRewardedFailedCallback(AdFailedCallback callback) override;
    void setRewardedEarnedCallback(RewardEarnedCallback callback) override;
    void setRewardedClosedCallback(AdClosedCallback callback) override;

private:
    bool initialized_ = false;
    Yodo1IOSAdBridge* bridge_ = nullptr;

    // Callbacks
    InitCallback initCallback_;
    AdLoadedCallback bannerLoadedCallback_;
    AdFailedCallback bannerFailedCallback_;
    AdLoadedCallback interstitialLoadedCallback_;
    AdFailedCallback interstitialFailedCallback_;
    AdClosedCallback interstitialClosedCallback_;
    AdLoadedCallback rewardedLoadedCallback_;
    AdFailedCallback rewardedFailedCallback_;
    RewardEarnedCallback rewardedEarnedCallback_;
    AdClosedCallback rewardedClosedCallback_;
};
