#include "ad_manager.h"
#include "ad_wrapper.h"

#if defined(__ANDROID__)
    #include "yodo1mas_android_wrapper.h"
#elif defined(__APPLE__)
    #include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
        #include "yodo1mas_ios_wrapper.h"
    #endif
#endif

// Singleton implementation
AdManager& AdManager::getInstance() {
    static AdManager instance;
    return instance;
}

// Constructor - creates the platform-specific AdWrapper
AdManager::AdManager() {
#if defined(__ANDROID__)
    adWrapper_ = new Yodo1AndroidAdWrapper();
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    adWrapper_ = new Yodo1IOSAdWrapper();
#else
    #error "Unsupported platform"
#endif
}

// Get the ad wrapper pointer
AdWrapper* AdManager::getAdWrapper() {
    return adWrapper_;
}
