#include "yodo1mas_wrapper.h"
#include <memory>

#if defined(__ANDROID__)
    #include "../android/cpp/yodo1mas_android_bridge.h"
#elif defined(__APPLE__)
    #include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
        #include "../ios/yodo1mas_ios_bridge.h"
    #endif
#endif

// Platform-specific implementation
class Yodo1MasWrapper::Impl {
public:
    bool initialized = false;

    // Callbacks
    InitCallback initCallback;
    AdLoadedCallback bannerLoadedCallback;
    AdFailedCallback bannerFailedCallback;
    AdLoadedCallback interstitialLoadedCallback;
    AdFailedCallback interstitialFailedCallback;
    AdClosedCallback interstitialClosedCallback;
    AdLoadedCallback rewardedLoadedCallback;
    AdFailedCallback rewardedFailedCallback;
    RewardEarnedCallback rewardedEarnedCallback;
    AdClosedCallback rewardedClosedCallback;

    // Platform bridge handles
#if defined(__ANDROID__)
    AndroidBridge* androidBridge = nullptr;
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    IOSBridge* iosBridge = nullptr;
#endif

    Impl() {
#if defined(__ANDROID__)
        androidBridge = new AndroidBridge(this);
#elif defined(__APPLE__) && TARGET_OS_IPHONE
        iosBridge = new IOSBridge(this);
#endif
    }

    ~Impl() {
#if defined(__ANDROID__)
        delete androidBridge;
#elif defined(__APPLE__) && TARGET_OS_IPHONE
        delete iosBridge;
#endif
    }
};

// Singleton implementation
Yodo1MasWrapper& Yodo1MasWrapper::getInstance() {
    static Yodo1MasWrapper instance;
    return instance;
}

Yodo1MasWrapper::Yodo1MasWrapper() : pImpl(new Impl()) {}

Yodo1MasWrapper::~Yodo1MasWrapper() {
    delete pImpl;
}

// Lifecycle
void Yodo1MasWrapper::initialize(const std::string& appKey) {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->initialize(appKey);
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->initialize(appKey);
    }
#endif
}

bool Yodo1MasWrapper::isInitialized() const {
    return pImpl->initialized;
}

// Privacy settings
void Yodo1MasWrapper::setGDPR(bool consent) {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->setGDPR(consent);
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->setGDPR(consent);
    }
#endif
}

void Yodo1MasWrapper::setCCPA(bool doNotSell) {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->setCCPA(doNotSell);
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->setCCPA(doNotSell);
    }
#endif
}

void Yodo1MasWrapper::setCOPPA(bool isAgeRestricted) {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->setCOPPA(isAgeRestricted);
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->setCOPPA(isAgeRestricted);
    }
#endif
}

// Banner Ads
void Yodo1MasWrapper::loadBannerAd(const std::string& placementId,
                                    const std::string& size,
                                    const std::string& horizontalAlign,
                                    const std::string& verticalAlign) {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->loadBannerAd(placementId, size, horizontalAlign, verticalAlign);
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->loadBannerAd(placementId, size, horizontalAlign, verticalAlign);
    }
#endif
}

void Yodo1MasWrapper::showBannerAd() {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->showBannerAd();
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->showBannerAd();
    }
#endif
}

void Yodo1MasWrapper::hideBannerAd() {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->hideBannerAd();
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->hideBannerAd();
    }
#endif
}

// Interstitial Ads
void Yodo1MasWrapper::loadInterstitialAd() {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->loadInterstitialAd();
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->loadInterstitialAd();
    }
#endif
}

bool Yodo1MasWrapper::isInterstitialAdLoaded() const {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        return pImpl->androidBridge->isInterstitialAdLoaded();
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        return pImpl->iosBridge->isInterstitialAdLoaded();
    }
#endif
    return false;
}

void Yodo1MasWrapper::showInterstitialAd(const std::string& placementId) {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->showInterstitialAd(placementId);
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->showInterstitialAd(placementId);
    }
#endif
}

// Rewarded Ads
void Yodo1MasWrapper::loadRewardedAd() {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->loadRewardedAd();
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->loadRewardedAd();
    }
#endif
}

bool Yodo1MasWrapper::isRewardedAdLoaded() const {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        return pImpl->androidBridge->isRewardedAdLoaded();
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        return pImpl->iosBridge->isRewardedAdLoaded();
    }
#endif
    return false;
}

void Yodo1MasWrapper::showRewardedAd(const std::string& placementId) {
#if defined(__ANDROID__)
    if (pImpl->androidBridge) {
        pImpl->androidBridge->showRewardedAd(placementId);
    }
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    if (pImpl->iosBridge) {
        pImpl->iosBridge->showRewardedAd(placementId);
    }
#endif
}

// Callbacks
void Yodo1MasWrapper::setInitCallback(InitCallback callback) {
    pImpl->initCallback = callback;
}

void Yodo1MasWrapper::setBannerLoadedCallback(AdLoadedCallback callback) {
    pImpl->bannerLoadedCallback = callback;
}

void Yodo1MasWrapper::setBannerFailedCallback(AdFailedCallback callback) {
    pImpl->bannerFailedCallback = callback;
}

void Yodo1MasWrapper::setInterstitialLoadedCallback(AdLoadedCallback callback) {
    pImpl->interstitialLoadedCallback = callback;
}

void Yodo1MasWrapper::setInterstitialFailedCallback(AdFailedCallback callback) {
    pImpl->interstitialFailedCallback = callback;
}

void Yodo1MasWrapper::setInterstitialClosedCallback(AdClosedCallback callback) {
    pImpl->interstitialClosedCallback = callback;
}

void Yodo1MasWrapper::setRewardedLoadedCallback(AdLoadedCallback callback) {
    pImpl->rewardedLoadedCallback = callback;
}

void Yodo1MasWrapper::setRewardedFailedCallback(AdFailedCallback callback) {
    pImpl->rewardedFailedCallback = callback;
}

void Yodo1MasWrapper::setRewardedEarnedCallback(RewardEarnedCallback callback) {
    pImpl->rewardedEarnedCallback = callback;
}

void Yodo1MasWrapper::setRewardedClosedCallback(AdClosedCallback callback) {
    pImpl->rewardedClosedCallback = callback;
}
