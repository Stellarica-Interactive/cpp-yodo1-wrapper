# iOS XCFramework Build Instructions

## Prerequisites
- Xcode 14.0 or later
- macOS 12.0 or later
- CocoaPods (if not already installed: `sudo gem install cocoapods`)

## Setup Xcode Project

1. **Create Xcode Project:**
   - Open Xcode
   - Create a new project: **File > New > Project**
   - Choose **Framework** under **iOS**
   - Name it: `Yodo1AdWrapper`
   - Language: **Objective-C**
   - Save it in the `ios/` directory

2. **Add source files:**
   - Drag `../include/ad_wrapper.h` to the project
   - Drag `../include/ad_manager.h` to the project
   - Drag `../include/yodo1mas_ios_wrapper.h` to the project
   - Drag `../src/ios/yodo1mas_ios_wrapper.mm` to the project
   - Drag `../src/common/ad_manager.cpp` to the project

3. **Install CocoaPods dependencies:**
   ```bash
   cd ios
   pod install
   ```

   **Important:** From now on, always open `Yodo1AdWrapper.xcworkspace` instead of the `.xcodeproj` file!

   **After `pod install`:** CocoaPods will regenerate build scripts and remove the resource copy fix. You need to manually edit the Xcode project file:

   Open `Yodo1AdWrapper.xcodeproj/project.pbxproj` in a text editor and find the line with:
   ```
   shellScript = "\"${PODS_ROOT}/Target Support Files/Pods-Yodo1AdWrapper/Pods-Yodo1AdWrapper-resources.sh\"\n";
   ```

   Replace it with:
   ```
   shellScript = "if [ \"$CONFIGURATION\" = \"Release\" ]; then\n    echo \"Skipping resource copy for framework build\"\n    exit 0\nfi\n\"${PODS_ROOT}/Target Support Files/Pods-Yodo1AdWrapper/Pods-Yodo1AdWrapper-resources.sh\"\n";
   ```

   This prevents CocoaPods resource copying from failing during framework archive.

4. **Configure Build Settings** (in the .xcworkspace):
   - Select the `Yodo1AdWrapper` target
   - Go to **Build Settings**
   - Set **C++ Language Dialect** to `C++17` or `GNU++17`
   - Set **Build Libraries for Distribution** to `YES`
   - Add Header Search Paths:
     - `$(PROJECT_DIR)/../include`
     - CocoaPods will automatically add Yodo1MasCore headers

5. **Create Scheme:**
   - Product > Scheme > Edit Scheme
   - Make sure the scheme is marked as **Shared**

6. **Close and reopen** `Yodo1AdWrapper.xcworkspace`

## Build XCFramework

Once the Xcode project is set up:

```bash
cd ios
./build_xcframework.sh
```

This will:
1. Run `pod install` if needed
2. Build for iOS Device (arm64)
3. Build for iOS Simulator (x86_64 + arm64)
4. Create `Yodo1AdWrapper.xcframework`

## Integration with Godot

1. Copy the generated `Yodo1AdWrapper.xcframework` to your Godot project's `ios/plugins/` directory

2. Create a `.gdip` file named `yodo1_ad_wrapper.gdip`:

```ini
[config]
name="Yodo1AdWrapper"
binary="Yodo1AdWrapper.xcframework"

[dependencies]
embedded=["Yodo1AdWrapper.xcframework"]
system=["UIKit.framework", "Foundation.framework", "AdSupport.framework", "AppTrackingTransparency.framework"]

[plist]
NSUserTrackingUsageDescription:string="We use tracking for personalized ads"
SKAdNetworkItems:array=[
    {SKAdNetworkIdentifier:string="v9wttpbfk9.skadnetwork"},
    {SKAdNetworkIdentifier:string="n38lu8286q.skadnetwork"}
]
```

3. In your GDExtension C++ code:

```cpp
#include "ad_manager.h"

void MyGame::_ready() {
    AdWrapper* ads = AdManager::getInstance().getAdWrapper();

    ads->setInitCallback([](bool success, const std::string& error) {
        if (success) {
            print("Yodo1 initialized!");
        }
    });

    ads->initialize("YOUR_YODO1_APP_KEY");
}
```

## Troubleshooting

### Build Fails with "Framework not found Yodo1MasCore"
- Make sure you ran `pod install` in the `ios/` directory
- Make sure you're opening the `.xcworkspace` file, NOT the `.xcodeproj`
- Try cleaning derived data: Xcode > Preferences > Locations > Derived Data > Delete

### Linker Errors
- Ensure C++ Language Dialect is set to C++17 or later
- Verify all source files are added to the target
- Make sure you're building the `.xcworkspace` not the `.xcodeproj`

### Runtime Crashes
- Make sure you call `initialize()` before any other ad methods
- All ad operations should be done after initialization callback succeeds
