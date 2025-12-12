#import "yodo1mas_ios_wrapper.h"
#import <Foundation/Foundation.h>

// Objective-C bridge class to handle iOS SDK callbacks
@interface Yodo1IOSAdBridge : NSObject
@property (nonatomic, assign) Yodo1IOSAdWrapper* wrapper;
@end

@implementation Yodo1IOSAdBridge
// TODO: Implement Yodo1 MAS delegate methods
@end

Yodo1IOSAdWrapper::Yodo1IOSAdWrapper() {
    bridge_ = [[Yodo1IOSAdBridge alloc] init];
    bridge_.wrapper = this;
}

Yodo1IOSAdWrapper::~Yodo1IOSAdWrapper() {
    bridge_.wrapper = nullptr;
    bridge_ = nil;
}

// Lifecycle
void Yodo1IOSAdWrapper::initialize(const std::string& appKey) {
    // TODO: Call Yodo1 MAS SDK initialization
    // NSString* nsAppKey = [NSString stringWithUTF8String:appKey.c_str()];
    initialized_ = true;
}

bool Yodo1IOSAdWrapper::isInitialized() const {
    return initialized_;
}

// Privacy settings
void Yodo1IOSAdWrapper::setGDPR(bool consent) {
    // TODO: Call Yodo1 MAS GDPR method
}

void Yodo1IOSAdWrapper::setCCPA(bool doNotSell) {
    // TODO: Call Yodo1 MAS CCPA method
}

void Yodo1IOSAdWrapper::setCOPPA(bool isAgeRestricted) {
    // TODO: Call Yodo1 MAS COPPA method
}

// Banner Ads
void Yodo1IOSAdWrapper::loadBannerAd(const std::string& placementId,
                                       const std::string& size,
                                       const std::string& horizontalAlign,
                                       const std::string& verticalAlign) {
    // TODO: Call Yodo1 MAS banner load method
}

void Yodo1IOSAdWrapper::showBannerAd() {
    // TODO: Call Yodo1 MAS banner show method
}

void Yodo1IOSAdWrapper::hideBannerAd() {
    // TODO: Call Yodo1 MAS banner hide method
}

// Interstitial Ads
void Yodo1IOSAdWrapper::loadInterstitialAd() {
    // TODO: Call Yodo1 MAS interstitial load method
}

bool Yodo1IOSAdWrapper::isInterstitialAdLoaded() const {
    // TODO: Call Yodo1 MAS interstitial isLoaded method
    return false;
}

void Yodo1IOSAdWrapper::showInterstitialAd(const std::string& placementId) {
    // TODO: Call Yodo1 MAS interstitial show method
}

// Rewarded Ads
void Yodo1IOSAdWrapper::loadRewardedAd() {
    // TODO: Call Yodo1 MAS rewarded load method
}

bool Yodo1IOSAdWrapper::isRewardedAdLoaded() const {
    // TODO: Call Yodo1 MAS rewarded isLoaded method
    return false;
}

void Yodo1IOSAdWrapper::showRewardedAd(const std::string& placementId) {
    // TODO: Call Yodo1 MAS rewarded show method
}

// Callbacks
void Yodo1IOSAdWrapper::setInitCallback(InitCallback callback) {
    initCallback_ = callback;
}

void Yodo1IOSAdWrapper::setBannerLoadedCallback(AdLoadedCallback callback) {
    bannerLoadedCallback_ = callback;
}

void Yodo1IOSAdWrapper::setBannerFailedCallback(AdFailedCallback callback) {
    bannerFailedCallback_ = callback;
}

void Yodo1IOSAdWrapper::setInterstitialLoadedCallback(AdLoadedCallback callback) {
    interstitialLoadedCallback_ = callback;
}

void Yodo1IOSAdWrapper::setInterstitialFailedCallback(AdFailedCallback callback) {
    interstitialFailedCallback_ = callback;
}

void Yodo1IOSAdWrapper::setInterstitialClosedCallback(AdClosedCallback callback) {
    interstitialClosedCallback_ = callback;
}

void Yodo1IOSAdWrapper::setRewardedLoadedCallback(AdLoadedCallback callback) {
    rewardedLoadedCallback_ = callback;
}

void Yodo1IOSAdWrapper::setRewardedFailedCallback(AdFailedCallback callback) {
    rewardedFailedCallback_ = callback;
}

void Yodo1IOSAdWrapper::setRewardedEarnedCallback(RewardEarnedCallback callback) {
    rewardedEarnedCallback_ = callback;
}

void Yodo1IOSAdWrapper::setRewardedClosedCallback(AdClosedCallback callback) {
    rewardedClosedCallback_ = callback;
}
