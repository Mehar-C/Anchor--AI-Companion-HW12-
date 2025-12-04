# How to Run Anchor App

## Option 1: Create New Xcode Project (Recommended - 5 minutes)

### Step 1: Create New Project
1. Open **Xcode**
2. File → New → Project
3. Select **iOS** → **App**
4. Click **Next**
5. Fill in:
   - **Product Name**: `Anchor`
   - **Team**: Select your team
   - **Organization Identifier**: `com.anchor` (or your own)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None
6. Click **Next**
7. Navigate to `/Users/meharchatha/Desktop/hw25`
8. **IMPORTANT**: Uncheck "Create Git repository" if prompted
9. Click **Create**

### Step 2: Replace Default Files
1. **Delete** the default `ContentView.swift` that Xcode created
2. **Delete** the default `AnchorApp.swift` that Xcode created
3. Copy all files from the existing `Anchor/` folder into your new project:
   - Drag the entire `Anchor/` folder into Xcode's project navigator
   - When prompted, select "Copy items if needed" ✅
   - Make sure your target is selected ✅

### Step 3: Add All Source Files
In Xcode, make sure these files are added to your target:
- All `.swift` files in `Anchor/Models/`
- All `.swift` files in `Anchor/Services/`
- All `.swift` files in `Anchor/Views/`
- All `.swift` files in `Anchor/Extensions/`
- `Anchor/AnchorApp.swift`
- `Anchor/ContentView.swift`

### Step 4: Configure Project Settings
1. Select your project in the navigator
2. Select the **Anchor** target
3. Go to **Signing & Capabilities**
4. Select your **Team**
5. Add capabilities:
   - Click **+ Capability**
   - Add **Camera**
   - Add **Microphone**
   - Add **Speech Recognition** (if available)

### Step 5: Add Info.plist Entries
1. If using Xcode 15+, Info.plist might be auto-generated
2. If you see `Info.plist` in the project, make sure it includes:
   - `NSCameraUsageDescription`
   - `NSMicrophoneUsageDescription`
   - `NSSpeechRecognitionUsageDescription`
3. Or add the `Anchor/Info.plist` file to your project

### Step 6: Build and Run
1. Select an **iOS Simulator** or your **iPhone** as the target
2. Press **⌘R** (or click the Play button)
3. If you see errors, see Troubleshooting below

---

## Option 2: Use Terminal (Quick Test)

If you just want to verify the code compiles:

```bash
cd /Users/meharchatha/Desktop/hw25

# Check if Swift is available
swift --version

# Try building (this might not work without proper Xcode project)
# Better to use Xcode as shown in Option 1
```

---

## Option 3: Open in Xcode and Fix Project File

If you want to try fixing the existing project:

1. Open `Anchor.xcodeproj` in Xcode
2. You'll likely see missing file references
3. Right-click on the project → **Add Files to "Anchor"...**
4. Navigate to `Anchor/` folder
5. Select all `.swift` files
6. Make sure "Copy items if needed" is **unchecked**
7. Make sure "Add to targets: Anchor" is **checked**
8. Click **Add**

---

## Quick Setup Checklist

- [ ] Xcode project created
- [ ] All Swift files added to target
- [ ] Camera permission in Info.plist
- [ ] Microphone permission in Info.plist
- [ ] Signing & Capabilities configured
- [ ] Team selected for code signing
- [ ] Build target selected (iPhone or Simulator)

---

## Troubleshooting

### "Cannot find type 'X' in scope"
- Make sure all `.swift` files are added to the target
- Check Target Membership in File Inspector (right panel)

### "Camera not available"
- Run on a **physical iPhone** (simulator has limited camera)
- Check Info.plist has `NSCameraUsageDescription`

### "Code signing error"
- Select your Apple Developer team in Signing & Capabilities
- For simulator, you can use "Personal Team"

### "Missing dependencies"
- All dependencies are built-in (SwiftUI, AVFoundation, etc.)
- No external packages needed for basic functionality

### Build Errors
1. Clean build folder: **Product → Clean Build Folder** (⇧⌘K)
2. Restart Xcode
3. Delete DerivedData: `~/Library/Developer/Xcode/DerivedData`

---

## Running on Device vs Simulator

### iOS Simulator
- ✅ Good for UI testing
- ❌ Camera won't work (limited functionality)
- ✅ Microphone works
- ✅ All other features work

### Physical iPhone
- ✅ Full functionality
- ✅ Camera works
- ✅ All features work
- ⚠️ Requires Apple Developer account (free for development)

---

## Next Steps After Running

1. **Grant Permissions**: When app launches, allow camera and microphone access
2. **Test Features**: 
   - Type a message in the conversation
   - Try voice input (microphone button)
   - Watch stress indicator change
3. **Add API Keys**: For full functionality, add keys to `Config.swift` (see `API_INTEGRATION.md`)

---

## Need Help?

- Check `QUICKSTART.md` for demo setup
- Check `API_INTEGRATION.md` for API configuration
- Check `SETUP.md` for detailed setup

Good luck! 🚀

