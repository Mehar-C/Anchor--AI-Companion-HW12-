# How to Run Anchor in Xcode

## Step 1: Open the Project

1. **Open Xcode** (if not already open)
2. **File → Open** (or press ⌘O)
3. Navigate to `/Users/meharchatha/Desktop/hw25`
4. Select `Anchor.xcodeproj`
5. Click **Open**

OR use Terminal:
```bash
cd /Users/meharchatha/Desktop/hw25
open Anchor.xcodeproj
```

## Step 2: Verify Files Are Added

After opening, check the Project Navigator (left sidebar):

1. Look for the **Anchor** folder
2. You should see:
   - `AnchorApp.swift`
   - `ContentView.swift`
   - `Models/` folder
   - `Services/` folder
   - `Views/` folder
   - `Extensions/` folder

**If files are missing** (red file icons):
1. Right-click on the **Anchor** folder in Project Navigator
2. Select **"Add Files to 'Anchor'..."**
3. Navigate to the `Anchor/` folder
4. Select all the subfolders (`Models`, `Services`, `Views`, `Extensions`)
5. Make sure **"Add to targets: Anchor"** is checked ✅
6. Make sure **"Copy items if needed"** is **unchecked** ❌
7. Click **Add**

## Step 3: Select Your Target Device

At the top of Xcode, next to the Play button:

1. Click the device selector (shows "Any iOS Device" or a device name)
2. Choose one of:
   - **iPhone 15 Simulator** (or any iOS Simulator) - Good for testing UI
   - **Your iPhone** (if connected via USB) - Full functionality including camera

## Step 4: Configure Signing (First Time Only)

1. Click on **"Anchor"** in the Project Navigator (blue icon at top)
2. Select the **"Anchor"** target (under TARGETS)
3. Click the **"Signing & Capabilities"** tab
4. Check **"Automatically manage signing"** ✅
5. Select your **Team** from the dropdown:
   - If you have an Apple Developer account, select it
   - If not, select **"Personal Team"** (free, works for simulator and your own devices)

## Step 5: Build and Run

1. Press **⌘R** (Command + R) 
   OR
   Click the **Play button** (▶️) in the top-left toolbar

2. Xcode will:
   - Build the project (you'll see progress in the status bar)
   - Launch the simulator (if using simulator) or install on your device
   - Run the app

## Step 6: Grant Permissions

When the app launches, you'll be prompted for:
- **Camera Access** - Click "OK" (needed for Presage stress detection)
- **Microphone Access** - Click "OK" (needed for voice input)

## What You Should See

When the app runs successfully:
- ✅ Calming green gradient background
- ✅ Stress level indicator at the top
- ✅ Camera preview area (may show placeholder on simulator)
- ✅ Conversation interface
- ✅ Microphone button
- ✅ "End Session" button

## Troubleshooting

### "No such module" errors
- Make sure all `.swift` files are added to the target
- Clean build: **Product → Clean Build Folder** (⇧⌘K)
- Rebuild: **Product → Build** (⌘B)

### "Code signing" errors
- Go to Signing & Capabilities
- Select your Team
- Or use "Personal Team" for development

### Camera doesn't work
- **Simulator**: Camera has limited functionality - this is normal
- **Physical Device**: Make sure you granted camera permission

### Build fails
1. Check the **Issue Navigator** (⚠️ icon in left sidebar)
2. Look for red error icons
3. Fix any errors shown
4. Try building again

## Quick Commands

- **Build**: ⌘B
- **Run**: ⌘R
- **Stop**: ⌘.
- **Clean Build Folder**: ⇧⌘K

## Next Steps

Once the app is running:
1. Try typing a message in the conversation
2. Test the microphone button for voice input
3. Watch the stress indicator change
4. Tap "End Session" to see the summary

For full functionality, add API keys to `Config.swift` (see `API_INTEGRATION.md`)

