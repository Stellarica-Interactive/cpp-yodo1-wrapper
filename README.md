# Yodo1Mas Native Wrapper Library

Cross-platform C++ wrapper for Yodo1Mas SDK producing:
- **Android**: AAR library with JNI bridge
- **iOS**: XCFramework (dynamic library) with Objective-C++ bridge
- **Interface**: Pure C++ singleton API callable from Godot GDExtension or native code

## Architecture

```
┌─────────────────────────────────────┐
│   Godot Game (C++)                  │
│   calls: Yodo1MasWrapper::init()    │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  C++ Interface (yodo1mas_wrapper.h) │
│  - Pure C++ singleton               │
│  - Platform-agnostic API            │
└──────────────┬──────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼─────┐   ┌─────▼──────┐
│ iOS Bridge │   │ Android    │
│ (.mm)      │   │ Bridge     │
│ Obj-C++    │   │ (JNI)      │
└──────┬─────┘   └─────┬──────┘
       │               │
┌──────▼─────┐   ┌─────▼──────┐
│ Yodo1Mas   │   │ Yodo1Mas   │
│ iOS SDK    │   │ Android    │
│ (CocoaPods)│   │ SDK (Maven)│
└────────────┘   └────────────┘
```

## Project Structure

```
cpp-yodo1-wrapper/
├── README.md
├── include/
│   └── yodo1mas_wrapper.h          # Public C++ API
├── src/
│   ├── common/
│   │   └── yodo1mas_wrapper.cpp    # Common implementation
│   ├── ios/
│   │   ├── yodo1mas_ios_bridge.h
│   │   ├── yodo1mas_ios_bridge.mm  # Objective-C++ bridge
│   │   └── Podfile                 # CocoaPods for Yodo1Mas SDK
│   └── android/
│       ├── java/
│       │   └── com/yodo1/wrapper/
│       │       └── Yodo1MasJNI.java
│       ├── cpp/
│       │   ├── yodo1mas_android_bridge.h
│       │   └── yodo1mas_android_bridge.cpp  # JNI bridge
│       └── build.gradle            # Gradle with Yodo1Mas dependency
├── ios/
│   ├── Yodo1MasWrapper.xcodeproj   # Builds XCFramework
│   └── build_xcframework.sh        # Build script
└── android/
    ├── build.gradle                # Builds AAR
    └── build_aar.sh                # Build script
```

## Features

### Privacy Compliance
- GDPR consent management
- CCPA (Do Not Sell) support
- COPPA age restriction

### Ad Formats
- **Banner Ads**: Customizable size and positioning
- **Interstitial Ads**: Full-screen ads with load state checking
- **Rewarded Ads**: Video ads with reward callbacks

### Callbacks
All ad events are exposed via `std::function` callbacks:
- Initialization (success/failure)
- Ad loaded/failed/closed
- Reward earned

## Usage Example

```cpp
#include "yodo1mas_wrapper.h"

void MyGame::ready() {
    auto& yodo1 = Yodo1MasWrapper::getInstance();

    yodo1.setInitCallback([](bool success, const std::string& error) {
        if (success) {
            print("Yodo1Mas initialized!");
        }
    });

    yodo1.setRewardedEarnedCallback([]() {
        print("User earned reward!");
        // Give player coins, etc.
    });

    yodo1.initialize("YOUR_APP_KEY");
}

void MyGame::show_rewarded_ad() {
    auto& yodo1 = Yodo1MasWrapper::getInstance();
    if (yodo1.isRewardedAdLoaded()) {
        yodo1.showRewardedAd();
    } else {
        yodo1.loadRewardedAd();
    }
}
```

## Integration with Godot

### iOS
1. Copy `Yodo1MasWrapper.xcframework` to `ios/plugins/`
2. Create a `.gdip` file:
```ini
[config]
name="Yodo1MasWrapper"
binary="Yodo1MasWrapper.xcframework"

[dependencies]
system=["UIKit.framework", "Foundation.framework", "AdSupport.framework"]

[plist]
NSUserTrackingUsageDescription:string="We use tracking for ads"
```

### Android
Copy `yodo1mas-wrapper.aar` to `android/plugins/` (Godot auto-includes it)

## Building

### iOS XCFramework
```bash
cd ios
./build_xcframework.sh
```

### Android AAR
```bash
cd android
./build_aar.sh
```

## Requirements

- **iOS**: iOS 13.0+, Xcode 14+
- **Android**: API 21+, NDK 25.2+
- **Yodo1Mas SDK**: 4.17.1 (both platforms)

## License

See LICENSE file for details.
