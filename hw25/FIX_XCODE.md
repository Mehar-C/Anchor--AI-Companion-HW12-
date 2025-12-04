# Fixing Xcode Build Issues

Your project builds successfully from the command line, but Xcode shows errors. Here's how to fix it:

## Step 1: Clean Build Folder

1. In Xcode, go to **Product → Clean Build Folder** (or press **⇧⌘K**)
2. Wait for it to complete

## Step 2: Verify All Files Are Added

1. In the **Project Navigator** (left sidebar), check if you see:
   - ✅ `AnchorApp.swift`
   - ✅ `ContentView.swift`
   - ✅ `Models/` folder with Swift files
   - ✅ `Services/` folder with Swift files
   - ✅ `Views/` folder with Swift files
   - ✅ `Extensions/` folder with Swift files

2. **If any files are missing** (red file icons):
   - Right-click on the **Anchor** folder
   - Select **"Add Files to 'Anchor'..."**
   - Navigate to the `Anchor/` folder
   - Select the missing folders/files
   - Make sure **"Add to targets: Anchor"** is checked ✅
   - Click **Add**

## Step 3: Check Issue Navigator

1. Click the **⚠️ Issue Navigator** icon in the left sidebar (or press **⌘5**)
2. Look at the errors listed
3. Click on each error to see details

## Step 4: Rebuild

1. Press **⌘B** to build (or **Product → Build**)
2. If it still fails, try:
   - **Product → Clean Build Folder** (⇧⌘K)
   - Close Xcode
   - Reopen Xcode
   - Build again (⌘B)

## Step 5: Run the App

Once build succeeds:
1. Select **iPhone 15 Pro Simulator** (or any simulator) from the device selector
2. Press **⌘R** to run

## Common Issues

### "Cannot find type" errors
- Files aren't added to the target
- Solution: Add files to target (Step 2 above)

### "Missing required module" errors
- Clean build folder and rebuild

### Code signing errors
- Go to **Signing & Capabilities** tab
- Select your Team (or "Personal Team")

If you see specific errors, share them and I'll help fix them!

