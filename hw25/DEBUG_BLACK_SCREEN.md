# Debugging Black Screen Issue

## Quick Checks

### 1. Check Xcode Console
1. In Xcode, look at the **bottom panel** (Console)
2. Look for **red error messages** or crashes
3. Share any errors you see

### 2. Common Causes

**A. Color Extension Issue**
- The `Color(hex:)` extension might not be working
- Check if `Color+Hex.swift` is added to the target

**B. Camera Permission Blocking**
- Camera might be blocking the UI thread
- Check if you granted camera permission

**C. Initialization Crash**
- One of the services might be crashing on init
- Check console for crash logs

**D. Missing Files**
- Some Swift files might not be added to target
- Check for red file icons in Project Navigator

## Quick Fixes to Try

### Fix 1: Check Console
1. Run the app (⌘R)
2. Immediately check **Xcode Console** (bottom panel)
3. Look for any error messages
4. Share what you see

### Fix 2: Verify Files Are Added
1. In Project Navigator, check all files
2. If any show **red icons**, they're not added to target
3. Right-click → "Add Files to Anchor..."

### Fix 3: Test with Simple View
I can create a simple test view to see if the issue is with ContentView or something else.

## What to Tell Me

1. **What do you see in Xcode Console?** (any errors?)
2. **Does the app crash?** (does it close immediately?)
3. **Is it just black?** (or does it show something briefly then go black?)
4. **Any red file icons** in Project Navigator?

Let me know what you see and I'll fix it!

