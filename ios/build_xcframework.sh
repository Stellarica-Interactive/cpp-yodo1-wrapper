#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building Yodo1 Ad Wrapper XCFramework...${NC}"

# Directories
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$SCRIPT_DIR/build"
FRAMEWORK_NAME="Yodo1AdWrapper"
WORKSPACE="$SCRIPT_DIR/$FRAMEWORK_NAME.xcworkspace"

# Check if workspace exists (CocoaPods)
if [ ! -d "$WORKSPACE" ]; then
    echo -e "${GREEN}Installing CocoaPods dependencies...${NC}"
    cd "$SCRIPT_DIR"
    pod install
    cd -
fi

# Clean previous builds
echo -e "${GREEN}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
rm -rf "$SCRIPT_DIR/$FRAMEWORK_NAME.xcframework"

# Create build directory
mkdir -p "$BUILD_DIR"

# Build for iOS Device (arm64)
echo -e "${GREEN}Building for iOS Device (arm64)...${NC}"
xcodebuild archive \
  -workspace "$WORKSPACE" \
  -scheme "$FRAMEWORK_NAME" \
  -destination "generic/platform=iOS" \
  -archivePath "$BUILD_DIR/ios.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  ONLY_ACTIVE_ARCH=NO

# Build for iOS Simulator (x86_64 + arm64)
echo -e "${GREEN}Building for iOS Simulator (x86_64 + arm64)...${NC}"
xcodebuild archive \
  -workspace "$WORKSPACE" \
  -scheme "$FRAMEWORK_NAME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$BUILD_DIR/ios-simulator.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  ONLY_ACTIVE_ARCH=NO

# Create XCFramework
echo -e "${GREEN}Creating XCFramework...${NC}"
xcodebuild -create-xcframework \
  -framework "$BUILD_DIR/ios.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
  -framework "$BUILD_DIR/ios-simulator.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
  -output "$SCRIPT_DIR/$FRAMEWORK_NAME.xcframework"

echo -e "${BLUE}✅ XCFramework created successfully at: $SCRIPT_DIR/$FRAMEWORK_NAME.xcframework${NC}"
echo -e "${BLUE}You can now use this XCFramework in your project!${NC}"
