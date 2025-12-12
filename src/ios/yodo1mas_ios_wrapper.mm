#import "yodo1mas_ios_wrapper.h"
#import <Foundation/Foundation.h>
#import <Yodo1MasCore/Yodo1Mas.h>
#import <Yodo1MasCore/Yodo1MasRewardAd.h>
#import <Yodo1MasCore/Yodo1MasInterstitialAd.h>
#import <Yodo1MasCore/Yodo1MasBannerAdView.h>

// Objective-C bridge class to handle iOS SDK callbacks
@interface Yodo1IOSAdBridge : NSObject <Yodo1MasRewardDelegate, Yodo1MasInterstitialDelegate, Yodo1MasBannerAdViewDelegate>
@property (nonatomic, assign) Yodo1IOSAdWrapper* wrapper;
@property (nonatomic, strong) Yodo1MasBannerAdView* bannerAdView;
@end

@implementation Yodo1IOSAdBridge

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set up delegates for each ad type
        [[Yodo1MasRewardAd sharedInstance] setAdDelegate:self];
        [[Yodo1MasInterstitialAd sharedInstance] setAdDelegate:self];
    }
    return self;
}

#pragma mark - Yodo1MasRewardDelegate

- (void)onRewardAdLoaded:(Yodo1MasRewardAd *)ad {
    if (_wrapper && _wrapper->rewardedLoadedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->rewardedLoadedCallback_();
        });
    }
}

- (void)onRewardAdClosed:(Yodo1MasRewardAd *)ad {
    if (_wrapper && _wrapper->rewardedClosedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->rewardedClosedCallback_();
        });
    }
}

- (void)onRewardAdFailedToLoad:(Yodo1MasRewardAd *)ad withError:(Yodo1MasError *)error {
    if (_wrapper && _wrapper->rewardedFailedCallback_) {
        NSString* errorMsg = [error description] ?: @"Unknown error";
        std::string errorStr = [errorMsg UTF8String];
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->rewardedFailedCallback_(errorStr);
        });
    }
}

- (void)onRewardAdEarned:(Yodo1MasRewardAd *)ad {
    if (_wrapper && _wrapper->rewardedEarnedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->rewardedEarnedCallback_();
        });
    }
}

#pragma mark - Yodo1MasInterstitialDelegate

- (void)onInterstitialAdLoaded:(Yodo1MasInterstitialAd *)ad {
    if (_wrapper && _wrapper->interstitialLoadedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->interstitialLoadedCallback_();
        });
    }
}

- (void)onInterstitialAdClosed:(Yodo1MasInterstitialAd *)ad {
    if (_wrapper && _wrapper->interstitialClosedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->interstitialClosedCallback_();
        });
    }
}

- (void)onInterstitialAdFailedToLoad:(Yodo1MasInterstitialAd *)ad withError:(Yodo1MasError *)error {
    if (_wrapper && _wrapper->interstitialFailedCallback_) {
        NSString* errorMsg = [error description] ?: @"Unknown error";
        std::string errorStr = [errorMsg UTF8String];
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->interstitialFailedCallback_(errorStr);
        });
    }
}

#pragma mark - Yodo1MasBannerAdViewDelegate

- (void)onBannerAdLoaded:(Yodo1MasBannerAdView *)ad {
    if (_wrapper && _wrapper->bannerLoadedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->bannerLoadedCallback_();
        });
    }
}

- (void)onBannerAdFailedToLoad:(Yodo1MasBannerAdView *)ad withError:(Yodo1MasError *)error {
    if (_wrapper && _wrapper->bannerFailedCallback_) {
        NSString* errorMsg = [error description] ?: @"Unknown error";
        std::string errorStr = [errorMsg UTF8String];
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->bannerFailedCallback_(errorStr);
        });
    }
}

@end

#pragma mark - C++ Implementation

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
    NSString* nsAppKey = [NSString stringWithUTF8String:appKey.c_str()];

    [[Yodo1Mas sharedInstance] initMasWithAppKey:nsAppKey
        successful:^{
            initialized_ = true;
            if (initCallback_) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    initCallback_(true, "");
                });
            }
        }
        fail:^(Yodo1MasError * _Nonnull error) {
            initialized_ = false;
            if (initCallback_) {
                NSString* errorMsg = [error description] ?: @"Unknown error";
                std::string errorStr = [errorMsg UTF8String];
                dispatch_async(dispatch_get_main_queue(), ^{
                    initCallback_(false, errorStr);
                });
            }
        }];
}

bool Yodo1IOSAdWrapper::isInitialized() const {
    return initialized_;
}

// Privacy settings
void Yodo1IOSAdWrapper::setGDPR(bool consent) {
    [[Yodo1Mas sharedInstance] setIsGDPRUserConsent:consent];
}

void Yodo1IOSAdWrapper::setCCPA(bool doNotSell) {
    [[Yodo1Mas sharedInstance] setIsCCPADoNotSell:doNotSell];
}

void Yodo1IOSAdWrapper::setCOPPA(bool isAgeRestricted) {
    [[Yodo1Mas sharedInstance] setIsCOPPAAgeRestricted:isAgeRestricted];
}

// Banner Ads (simplified - banner is a UIView that must be managed by the app)
void Yodo1IOSAdWrapper::loadBannerAd(const std::string& placementId,
                                       const std::string& size,
                                       const std::string& horizontalAlign,
                                       const std::string& verticalAlign) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (bridge_.bannerAdView) {
            [bridge_.bannerAdView destroy];
            bridge_.bannerAdView = nil;
        }
        
        NSString* placement = placementId.empty() ? nil : [NSString stringWithUTF8String:placementId.c_str()];
        bridge_.bannerAdView = [[Yodo1MasBannerAdView alloc] initWithPlacement:placement size:Yodo1MasBannerAdSizeBanner];
        [bridge_.bannerAdView setAdDelegate:bridge_];
        [bridge_.bannerAdView loadAd];
        
        // Note: Banner is a UIView that needs to be added to view hierarchy by the app
        // The app should get the view via bridge_.bannerAdView and add it to their view hierarchy
    });
}

void Yodo1IOSAdWrapper::showBannerAd() {
    // Banner is a UIView - visibility is managed by adding/removing from superview
    // This is a no-op in the wrapper, app must manage the view hierarchy
}

void Yodo1IOSAdWrapper::hideBannerAd() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (bridge_.bannerAdView) {
            [bridge_.bannerAdView destroy];
            bridge_.bannerAdView = nil;
        }
    });
}

// Interstitial Ads
void Yodo1IOSAdWrapper::loadInterstitialAd() {
    [[Yodo1MasInterstitialAd sharedInstance] loadAd];
}

bool Yodo1IOSAdWrapper::isInterstitialAdLoaded() const {
    return [[Yodo1MasInterstitialAd sharedInstance] isLoaded];
}

void Yodo1IOSAdWrapper::showInterstitialAd(const std::string& placementId) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Yodo1MasInterstitialAd sharedInstance] showAd];
    });
}

// Rewarded Ads
void Yodo1IOSAdWrapper::loadRewardedAd() {
    [[Yodo1MasRewardAd sharedInstance] loadAd];
}

bool Yodo1IOSAdWrapper::isRewardedAdLoaded() const {
    return [[Yodo1MasRewardAd sharedInstance] isLoaded];
}

void Yodo1IOSAdWrapper::showRewardedAd(const std::string& placementId) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[Yodo1MasRewardAd sharedInstance] showAd];
    });
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
