#import "yodo1mas_ios_wrapper.h"
#import <Foundation/Foundation.h>
#import <Yodo1MasCore/Yodo1Mas.h>
#import <Yodo1MasCore/Yodo1MasRewardAd.h>
#import <Yodo1MasCore/Yodo1MasInterstitialAd.h>
#import <Yodo1MasCore/Yodo1MasBannerAdView.h>

// Objective-C bridge class to handle iOS SDK callbacks
@interface Yodo1IOSAdBridge : NSObject <Yodo1MasRewardAdDelegate, Yodo1MasInterstitialAdDelegate, Yodo1MasBannerAdDelegate>
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

#pragma mark - Yodo1MasRewardAdDelegate

- (void)onAdOpened:(Yodo1MasAdEvent *)event {
    // Reward ad opened
}

- (void)onAdClosed:(Yodo1MasAdEvent *)event {
    if (_wrapper && _wrapper->rewardedClosedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->rewardedClosedCallback_();
        });
    }
}

- (void)onAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
    if (_wrapper && _wrapper->rewardedFailedCallback_) {
        NSString* errorMsg = error.message ?: @"Unknown error";
        std::string errorStr = [errorMsg UTF8String];
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->rewardedFailedCallback_(errorStr);
        });
    }
}

- (void)onAdRewardEarned:(Yodo1MasAdEvent *)event {
    if (_wrapper && _wrapper->rewardedEarnedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->rewardedEarnedCallback_();
        });
    }
}

#pragma mark - Yodo1MasInterstitialAdDelegate

- (void)onInterstitialAdOpened:(Yodo1MasAdEvent *)event {
    // Interstitial opened
}

- (void)onInterstitialAdClosed:(Yodo1MasAdEvent *)event {
    if (_wrapper && _wrapper->interstitialClosedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->interstitialClosedCallback_();
        });
    }
}

- (void)onInterstitialAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
    if (_wrapper && _wrapper->interstitialFailedCallback_) {
        NSString* errorMsg = error.message ?: @"Unknown error";
        std::string errorStr = [errorMsg UTF8String];
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->interstitialFailedCallback_(errorStr);
        });
    }
}

- (void)onInterstitialAdLoaded:(Yodo1MasAdEvent *)event {
    if (_wrapper && _wrapper->interstitialLoadedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->interstitialLoadedCallback_();
        });
    }
}

#pragma mark - Yodo1MasBannerAdDelegate

- (void)onBannerAdOpened:(Yodo1MasAdEvent *)event {
    // Banner opened
}

- (void)onBannerAdClosed:(Yodo1MasAdEvent *)event {
    // Banner closed
}

- (void)onBannerAdError:(Yodo1MasAdEvent *)event error:(Yodo1MasError *)error {
    if (_wrapper && _wrapper->bannerFailedCallback_) {
        NSString* errorMsg = error.message ?: @"Unknown error";
        std::string errorStr = [errorMsg UTF8String];
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->bannerFailedCallback_(errorStr);
        });
    }
}

- (void)onBannerAdLoaded:(Yodo1MasAdEvent *)event {
    if (_wrapper && _wrapper->bannerLoadedCallback_) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _wrapper->bannerLoadedCallback_();
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
                NSString* errorMsg = error.message ?: @"Unknown error";
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

// Banner Ads
void Yodo1IOSAdWrapper::loadBannerAd(const std::string& placementId,
                                       const std::string& size,
                                       const std::string& horizontalAlign,
                                       const std::string& verticalAlign) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!bridge_.bannerAdView) {
            bridge_.bannerAdView = [[Yodo1MasBannerAdView alloc] init];
            [bridge_.bannerAdView setAdDelegate:bridge_];

            // Set alignment
            Yodo1MasAdBannerAlign align = Yodo1MasBannerBottom | Yodo1MasBannerHorizontalCenter;
            if (verticalAlign == "Top") align = Yodo1MasBannerTop;
            if (horizontalAlign == "Left") align |= Yodo1MasBannerLeft;
            else if (horizontalAlign == "Right") align |= Yodo1MasBannerRight;

            [bridge_.bannerAdView setAlign:align];
        }

        // Load banner
        [bridge_.bannerAdView loadAd];
    });
}

void Yodo1IOSAdWrapper::showBannerAd() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (bridge_.bannerAdView) {
            [bridge_.bannerAdView showAd];
        }
    });
}

void Yodo1IOSAdWrapper::hideBannerAd() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (bridge_.bannerAdView) {
            [bridge_.bannerAdView dismissAd];
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
        UIViewController* rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC) {
            [[Yodo1MasInterstitialAd sharedInstance] showAdWithViewController:rootVC];
        }
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
        UIViewController* rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC) {
            [[Yodo1MasRewardAd sharedInstance] showAdWithViewController:rootVC];
        }
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
