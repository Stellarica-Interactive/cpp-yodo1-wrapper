#include "yodo1mas_wrapper.h"

#if defined(__ANDROID__)
    #include "yodo1mas_android_wrapper.h"
#elif defined(__APPLE__)
    #include <TargetConditionals.h>
    #if TARGET_OS_IPHONE
        #include "yodo1mas_ios_wrapper.h"
    #endif
#endif

// Singleton implementation - returns the platform-specific implementation
AdWrapper& AdManager::getInstance() {
#if defined(__ANDROID__)
    static Yodo1AndroidAdWrapper instance;
    return instance;
#elif defined(__APPLE__) && TARGET_OS_IPHONE
    static Yodo1IOSAdWrapper instance;
    return instance;
#else
    #error "Unsupported platform"
#endif
}
