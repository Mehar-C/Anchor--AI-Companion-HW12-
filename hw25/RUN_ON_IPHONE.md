# Running Anchor on Your iPhone

## Step 1: Connect Your iPhone

1. **Connect your iPhone to your Mac** using a USB cable
2. **Unlock your iPhone** (enter passcode if prompted)
3. On your iPhone, if you see **"Trust This Computer?"** → Tap **"Trust"**
4. Enter your iPhone passcode to confirm

## Step 2: Select Your iPhone in Xcode

1. In Xcode, look at the **top toolbar** (next to the Play button)
2. Click the **device selector** (currently shows "iPhone 15 Pro" or similar)
3. You should see your iPhone listed (e.g., "John's iPhone")
4. **Select your iPhone** from the dropdown

## Step 3: Configure Code Signing

1. Click on **"Anchor"** (blue project icon) in the Project Navigator
2. Select the **"Anchor"** target (under TARGETS)
3. Click the **"Signing & Capabilities"** tab
4. Check **"Automatically manage signing"** ✅
5. Select your **Team**:
   - If you have an **Apple Developer account**: Select it
   - If you **don't have one**: Select **"Personal Team"** (free, works for your own devices)
   - You may need to sign in with your Apple ID

## Step 4: Build and Run

1. Press **⌘R** (or click the Play button ▶️)
2. Xcode will:
   - Build the app
   - Install it on your iPhone
   - Launch it automatically

## Step 5: Trust the Developer on iPhone

**First time only:**

1. On your iPhone, go to **Settings → General → VPN & Device Management**
   - (On older iOS: **Settings → General → Device Management**)
2. You'll see your Apple ID/Developer name
3. Tap on it
4. Tap **"Trust [Your Name]"**
5. Confirm by tapping **"Trust"**

## Step 6: Launch the App

1. The app should launch automatically after installation
2. If not, find the **Anchor** app icon on your iPhone home screen
3. Tap it to open

## Step 7: Grant Permissions

When the app launches, you'll be prompted for:
- **Camera Access** → Tap **"OK"** (required for Presage stress detection)
- **Microphone Access** → Tap **"OK"** (required for voice input)

## Troubleshooting

### "No devices found"
- Make sure iPhone is unlocked
- Check USB cable connection
- Try a different USB port/cable
- In Xcode: **Window → Devices and Simulators** - check if iPhone appears

### "Code signing error"
- Make sure you selected your Team in Signing & Capabilities
- Try selecting "Personal Team" if you don't have a developer account
- You may need to sign in with your Apple ID in Xcode preferences

### "Untrusted Developer"
- Go to iPhone Settings → General → VPN & Device Management
- Trust your developer certificate (see Step 5 above)

### App won't install
- Make sure iPhone has enough storage
- Check iPhone is unlocked
- Try disconnecting and reconnecting the cable

### Camera doesn't work
- Make sure you granted camera permission
- Check Settings → Privacy → Camera → Anchor is enabled

## Benefits of Running on iPhone

✅ **Full camera functionality** (simulator has limited camera)
✅ **Real microphone input**
✅ **Better performance**
✅ **Test on actual device**
✅ **All features work properly**

## Quick Checklist

- [ ] iPhone connected via USB
- [ ] iPhone unlocked and trusted
- [ ] iPhone selected as target in Xcode
- [ ] Code signing configured (Team selected)
- [ ] Build and run (⌘R)
- [ ] Trust developer on iPhone (first time)
- [ ] Grant camera/microphone permissions

Once running, you'll see the full Anchor experience with working camera and all features!

