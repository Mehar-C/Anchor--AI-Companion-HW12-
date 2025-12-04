# 🚀 Test Anchor on Your iPhone - Quick Guide

## Step 1: Connect Your iPhone

1. **Plug your iPhone into your Mac** with a USB cable
2. **Unlock your iPhone** (enter passcode)
3. If you see **"Trust This Computer?"** → Tap **"Trust"**
4. Enter your iPhone passcode to confirm

## Step 2: Open Xcode

1. Open the project: `Anchor.xcodeproj` (if not already open)
2. Or run: `open Anchor.xcodeproj` in terminal

## Step 3: Select Your iPhone

1. Look at the **top toolbar** in Xcode (next to the Play button)
2. Click the **device selector** (currently shows "iPhone 15 Pro" or simulator name)
3. You should see **"Your Name's iPhone"** in the list
4. **Select your iPhone** from the dropdown

## Step 4: Configure Signing (First Time Only)

1. Click on **"Anchor"** (blue project icon) in the left sidebar
2. Select the **"Anchor"** target (under TARGETS)
3. Click the **"Signing & Capabilities"** tab
4. Check **"Automatically manage signing"** ✅
5. Select your **Team**:
   - If you have an Apple Developer account: Select it
   - If not: Select **"Personal Team"** (free, works for your devices)
   - You may need to sign in with your Apple ID

## Step 5: Build and Run

1. Press **⌘R** (Command + R) 
   OR
   Click the **Play button** (▶️) in the top-left
2. Xcode will:
   - Build the app
   - Install it on your iPhone
   - Launch it automatically

## Step 6: Trust Developer (First Time Only)

**On your iPhone:**

1. Go to **Settings → General → VPN & Device Management**
   - (On older iOS: **Settings → General → Device Management**)
2. You'll see your Apple ID/Developer name
3. Tap on it
4. Tap **"Trust [Your Name]"**
5. Confirm by tapping **"Trust"** again

## Step 7: Grant Permissions

When the app launches, you'll be prompted for:

1. **Camera Access** → Tap **"OK"** ✅
   - Required for Presage stress detection
   
2. **Microphone Access** → Tap **"OK"** ✅
   - Required for voice input

3. **Speech Recognition** (if prompted) → Tap **"OK"** ✅
   - Required for voice-to-text

## Step 8: Test the Features! 🎉

### Test Stress Detection (Presage)
- ✅ Look at the camera preview
- ✅ Watch the stress indicator at the top
- ✅ It should update in real-time based on your face
- ✅ Try different expressions/stress levels

### Test AI Conversations (Gemini)
- ✅ Type a message in the text field
- ✅ See AI responses adapt to your stress level
- ✅ Responses change based on calm/rising/spiking

### Test Voice (ElevenLabs)
- ✅ Send a message
- ✅ Listen to the AI speak with natural voice
- ✅ Try the microphone button for voice input

### Test Voice Input
- ✅ Tap the microphone button
- ✅ Speak your message
- ✅ It should convert to text and send

## 🐛 Troubleshooting

### "No devices found"
- ✅ Make sure iPhone is unlocked
- ✅ Check USB cable connection
- ✅ Try a different USB port/cable
- ✅ In Xcode: **Window → Devices and Simulators** - check if iPhone appears

### "Code signing error"
- ✅ Go to **Signing & Capabilities** tab
- ✅ Select your Team (or "Personal Team")
- ✅ Make sure "Automatically manage signing" is checked

### "Untrusted Developer"
- ✅ Go to iPhone **Settings → General → VPN & Device Management**
- ✅ Trust your developer certificate (see Step 6)

### App won't install
- ✅ Make sure iPhone has enough storage
- ✅ Check iPhone is unlocked
- ✅ Try disconnecting and reconnecting cable
- ✅ Clean build: **Product → Clean Build Folder** (⇧⌘K)

### Camera doesn't work
- ✅ Make sure you granted camera permission
- ✅ Check **Settings → Privacy → Camera → Anchor** is enabled
- ✅ Try closing and reopening the app

### No AI responses
- ✅ Check internet connection
- ✅ Check Xcode console for errors
- ✅ Verify API keys are correct in `Config.swift`

### No voice output
- ✅ Check device volume is up
- ✅ Check Xcode console for ElevenLabs errors
- ✅ Verify ElevenLabs API key is correct

## 📱 What to Expect

When the app runs on your iPhone:

1. **Beautiful green gradient background** (animated)
2. **Stress indicator** at top (pulsing, updates in real-time)
3. **Camera preview** showing "Presage Analysis Active"
4. **Conversation area** with chat bubbles
5. **Text input** at bottom
6. **Microphone button** for voice
7. **End Session button**

## 🎯 Quick Test Checklist

- [ ] iPhone connected and unlocked
- [ ] iPhone selected in Xcode
- [ ] Signing configured
- [ ] App installed and running
- [ ] Developer trusted on iPhone
- [ ] Camera permission granted
- [ ] Microphone permission granted
- [ ] Stress indicator updating
- [ ] AI conversations working
- [ ] Voice output working

## 🚀 You're Ready!

Once the app is running:
- **Test stress detection** - watch the indicator change
- **Have a conversation** - see AI adapt to your stress
- **Try voice** - hear natural speech
- **Test voice input** - speak to the AI

**Everything should work now with your real API keys!** 🎉

Need help? Check Xcode console for any error messages and let me know!

