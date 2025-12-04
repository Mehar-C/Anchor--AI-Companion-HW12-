#!/bin/bash

# Anchor Project Setup Script
# This script helps set up the Xcode project

echo "🚀 Anchor Project Setup"
echo "======================"
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ Xcode found"
echo ""

# Create missing directories
echo "📁 Creating required directories..."
mkdir -p "Anchor/Preview Content"
mkdir -p "Anchor/Assets.xcassets/AppIcon.appiconset"
mkdir -p "Anchor/Assets.xcassets/AccentColor.colorset"
mkdir -p "Anchor/Preview Content/Preview Assets.xcassets"

echo "✅ Directories created"
echo ""

# Check project file
if [ -f "Anchor.xcodeproj/project.pbxproj" ]; then
    echo "✅ Xcode project file found"
else
    echo "❌ Xcode project file not found"
    exit 1
fi

echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. Open Anchor.xcodeproj in Xcode:"
echo "   open Anchor.xcodeproj"
echo ""
echo "2. In Xcode, add all source files to the project:"
echo "   - Right-click on 'Anchor' folder in Project Navigator"
echo "   - Select 'Add Files to Anchor...'"
echo "   - Navigate to the Anchor/ folder"
echo "   - Select all .swift files in Models/, Services/, Views/, Extensions/"
echo "   - Make sure 'Add to targets: Anchor' is checked"
echo "   - Click 'Add'"
echo ""
echo "3. Configure Signing & Capabilities:"
echo "   - Select project in navigator"
echo "   - Select 'Anchor' target"
echo "   - Go to 'Signing & Capabilities' tab"
echo "   - Select your Team"
echo ""
echo "4. Build and Run:"
echo "   - Select iPhone Simulator or your device"
echo "   - Press ⌘R to build and run"
echo ""
echo "✨ Setup complete! Open the project in Xcode to continue."
echo ""

