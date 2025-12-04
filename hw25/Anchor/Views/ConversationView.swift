import SwiftUI
import AVFoundation
import Speech

enum ConversationMode {
    case text
    case voice
}

struct ConversationView: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var stressMonitor: StressMonitor
    @State private var inputText: String = ""
    @State private var conversationMode: ConversationMode = .text
    @State private var showFullScreenVoice: Bool = false // Explicitly default to false
    
    init() {
        // Ensure we start with text mode - this runs before @State initialization
        // print("🔵 ConversationView init - will default to text mode")
    }
    
    var body: some View {
        // Always show text conversation view - never conditionally hide it
        textConversationView
            .fullScreenCover(isPresented: $showFullScreenVoice) {
                FullScreenVoiceChatInline(isPresented: $showFullScreenVoice)
                    .environmentObject(conversationManager)
                    .environmentObject(stressMonitor)
            }
            .onAppear {
                print("🔵 ConversationView appeared - showFullScreenVoice: \(showFullScreenVoice), mode: \(conversationMode)")
                // ALWAYS start with text mode - force it
                showFullScreenVoice = false
                conversationMode = .text
                print("🔵 Forced text mode - showFullScreenVoice: \(showFullScreenVoice)")
            }
    }
    
    private var textConversationView: some View {
        VStack(spacing: 16) {
            // Presage indicator - inline
            PresageIndicatorInline()
                .environmentObject(stressMonitor)
            
            // Mode toggle - Text or Voice with improved design
            HStack(spacing: 8) {
                Button(action: {
                    print("🔵 Text button tapped")
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        conversationMode = .text
                        showFullScreenVoice = false
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Text")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))   
                    }
                    .foregroundColor(conversationMode == .text ? .white : Color(hex: "4285F4"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(conversationMode == .text ? 
                                      LinearGradient(
                                        colors: [Color(hex: "4285F4"), Color(hex: "34A853")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      ) :
                                      LinearGradient(
                                        colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      )
                                )
                            
                            if conversationMode == .text {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                                    .blur(radius: 1)
                            }
                        }
                    )
                    .shadow(color: conversationMode == .text ? Color(hex: "4285F4").opacity(0.4) : Color.black.opacity(0.05), 
                           radius: conversationMode == .text ? 8 : 3, 
                           x: 0, y: conversationMode == .text ? 4 : 2)
                }
                
                Button(action: {
                    print("🔵 Voice button tapped")
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        conversationMode = .voice
                        // Show full screen voice chat when voice mode is selected
                        showFullScreenVoice = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Voice")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(conversationMode == .voice ? .white : Color(hex: "4285F4"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(conversationMode == .voice ? 
                                      LinearGradient(
                                        colors: [Color(hex: "4285F4"), Color(hex: "34A853")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      ) :
                                      LinearGradient(
                                        colors: [Color.white.opacity(0.9), Color.white.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                      )
                                )
                            
                            if conversationMode == .voice {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                                    .blur(radius: 1)
                            }
                        }
                    )
                    .shadow(color: conversationMode == .voice ? Color(hex: "4285F4").opacity(0.4) : Color.black.opacity(0.05), 
                           radius: conversationMode == .voice ? 8 : 3, 
                           x: 0, y: conversationMode == .voice ? 4 : 2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            VStack(spacing: 16) {
            // Messages with auto-scroll
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(conversationManager.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .frame(maxHeight: 380)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.95),
                                        Color.white.opacity(0.85)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 8)
                    .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                )
                .scrollContentBackground(.hidden)
                .onChange(of: conversationManager.messages.count) { _ in
                    // Auto-scroll to latest message
                    if let lastMessage = conversationManager.messages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // Input area - show text or voice based on mode
            if conversationMode == .text {
                // Enhanced text input with better styling
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .foregroundColor(.black)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(hex: "F5F5F5"))
                                
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.8),
                                                Color(hex: "E0E0E0").opacity(0.5)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                        )
                        .lineLimit(1...4)
                        .onSubmit {
                            if !inputText.isEmpty {
                                sendMessage()
                            }
                        }
                    
                    Button(action: {
                        print("🔵 Send button tapped")
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        sendMessage()
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: inputText.isEmpty ? 
                                        [Color.gray.opacity(0.3), Color.gray.opacity(0.2)] :
                                        [Color(hex: "4285F4"), Color(hex: "34A853")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "arrow.up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(inputText.isEmpty ? Color.gray.opacity(0.6) : .white)
                        }
                    }
                    .disabled(inputText.isEmpty)
                    .scaleEffect(inputText.isEmpty ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: inputText.isEmpty)
                }
            } else {
                // Voice mode - show voice input button
                Button(action: {
                    withAnimation {
                        showFullScreenVoice = true
                    }
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 20))
                        Text("Switch to Full Screen Voice Chat")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "4285F4"), Color(hex: "34A853")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(24)
                }
            }
            }
        }
        .onAppear {
            if conversationManager.messages.isEmpty {
                startInitialConversation()
            }
        }
        .onChange(of: conversationMode) { newMode in
            // Don't auto-show full screen - only show when explicitly requested
            if newMode == .text {
                showFullScreenVoice = false
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else {
            print("⚠️ sendMessage: Input text is empty")
            return
        }
        let text = inputText
        inputText = ""
        
        print("💬 ConversationView: Sending message: '\(text)'")
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        Task {
            print("💬 ConversationView: Task started, calling sendMessage...")
            // sendMessage will automatically generate a response and speak it
            await conversationManager.sendMessage(text, stressLevel: stressMonitor.currentStressLevel)
            print("💬 ConversationView: sendMessage completed, messages count: \(conversationManager.messages.count)")
            
            // Verify the AI response was added and is speaking
            let lastMessage = await MainActor.run {
                conversationManager.messages.last
            }
            
            if let message = lastMessage, message.role == .assistant {
                print("💬 ConversationView: ✅ AI response received and should be speaking")
            } else {
                print("⚠️ ConversationView: No AI response found")
            }
            
            // Scroll to bottom after message is added
            await MainActor.run {
                withAnimation {
                    // Force scroll to bottom
                }
            }
        }
    }
    
    private func startInitialConversation() {
        Task {
            // Only start if no messages exist
            guard conversationManager.messages.isEmpty else {
                print("💬 ConversationView: Conversation already started, skipping initial message")
                return
            }
            
            let initialReading = stressMonitor.readings.last ?? StressReading(
                timestamp: Date(),
                stress: 0.5,
                breathing: 0.5,
                engagement: 0.5
            )
            
            conversationManager.startSession(
                stressLevel: stressMonitor.currentStressLevel,
                initialReading: initialReading
            )
            
            // Add initial AI greeting directly (don't send as user message)
            let greeting = ChatMessage(
                role: .assistant,
                content: "Hi! I'm Anchor. I'm here to support you. How are you feeling right now?",
                timestamp: Date()
            )
            await MainActor.run {
                conversationManager.messages.append(greeting)
                print("💬 ConversationView: Added initial greeting message")
            }
            
            // Speak the greeting
            await conversationManager.speakResponse(greeting.content)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    @State private var appear = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if message.role == .user {
                Spacer(minLength: 50)
            }
            
            HStack(alignment: .top, spacing: 10) {
                // Enhanced avatar for assistant messages
                if message.role == .assistant {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4285F4"), Color(hex: "34A853")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                            .shadow(color: Color(hex: "4285F4").opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                
                // Enhanced message content with better styling
                VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                    Text(message.content)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(message.role == .user ? .white : Color(hex: "1A1A1A"))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(
                            ZStack {
                                if message.role == .user {
                                    // User message - deep green gradient
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Theme.Colors.primaryGradient)
                                } else {
                                    // AI message - white glass
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white)
                                        .shadow(color: Theme.Colors.cardShadow, radius: 4, x: 0, y: 2)
                                }
                            }
                        )
                        .shadow(
                            color: message.role == .user ? 
                            Color(hex: "4285F4").opacity(0.2) : 
                            Color.black.opacity(0.05),
                            radius: message.role == .user ? 8 : 4,
                            x: 0,
                            y: message.role == .user ? 4 : 2
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
                }
            }
            
            if message.role == .assistant {
                Spacer(minLength: 50)
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appear = true
            }
        }
        .onLongPressGesture(minimumDuration: 0) { pressing in
            isPressed = pressing
        } perform: {
            // Long press action if needed
        }
    }
}

// Inline Presage Indicator
struct PresageIndicatorInline: View {
    @EnvironmentObject var stressMonitor: StressMonitor
    @State private var isPulsing = false
    @State private var rotation: Double = 0
    
    var body: some View {
        HStack(spacing: 8) {
            // Pulsing indicator dot
            ZStack {
                Circle()
                    .fill(Color(hex: "4CAF50").opacity(0.3))
                    .frame(width: 12, height: 12)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0.3 : 1.0)
                
                Circle()
                    .fill(Color(hex: "4CAF50"))
                    .frame(width: 8, height: 8)
            }
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            
            // Status text
            VStack(alignment: .leading, spacing: 2) {
                Text("Presage Active")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                if let latestReading = stressMonitor.readings.last {
                    HStack(spacing: 4) {
                        Label("Breathing", systemImage: "lungs.fill")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(.secondary)
                        Text("\(Int(latestReading.breathing * 100))%")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Rotating icon
            Image(systemName: "waveform.path")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4CAF50"))
                .rotationEffect(.degrees(rotation))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: Color(hex: "4CAF50").opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "4CAF50").opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            isPulsing = true
            withAnimation(
                Animation.linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
    }
}

// Full Screen Voice Chat View - Inline
struct FullScreenVoiceChatInline: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var stressMonitor: StressMonitor
    @Binding var isPresented: Bool
    @StateObject private var voiceControl = VoiceControlViewModel()
    @State private var isListening = false
    @State private var isSpeaking = false
    @State private var liveTranscript: String = ""
    @State private var currentResponse: String = ""
    @State private var showTranscript = false
    @State private var isProcessingResponse = false // Lock to prevent loops
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color(hex: "E8F5E9"),
                    Color(hex: "C8E6C9"),
                    Color(hex: "A5D6A7")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .allowsHitTesting(false) // Background shouldn't block
            
            VStack(spacing: 0) {
                // Top bar with close button
                HStack {
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    
                    Spacer()
                    
                    // Presage indicator
                    PresageIndicatorInline()
                        .environmentObject(stressMonitor)
                        .frame(maxWidth: 200)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Main conversation area
                VStack(spacing: 24) {
                    // AI response display
                    if !currentResponse.isEmpty {
                        VStack(spacing: 12) {
                            // AI Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "4285F4"), Color(hex: "34A853")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color(hex: "4285F4").opacity(0.4), radius: 20, x: 0, y: 10)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                                
                                // Speaking animation
                                if isSpeaking {
                                    Circle()
                                        .stroke(Color(hex: "4285F4").opacity(0.3), lineWidth: 3)
                                        .frame(width: 100, height: 100)
                                        .scaleEffect(isSpeaking ? 1.2 : 1.0)
                                        .opacity(isSpeaking ? 0 : 1)
                                        .animation(
                                            Animation.easeInOut(duration: 1.0)
                                                .repeatForever(autoreverses: false),
                                            value: isSpeaking
                                        )
                                }
                            }
                            
                            // Response text
                            Text(currentResponse)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.white.opacity(0.95))
                                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                )
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Live transcript when listening
                    if showTranscript && !liveTranscript.isEmpty {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "waveform")
                                    .foregroundColor(Color(hex: "4285F4"))
                                Text("Listening...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(liveTranscript)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.95))
                                        .shadow(color: Color(hex: "4285F4").opacity(0.3), radius: 10, x: 0, y: 3)
                                )
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .frame(maxHeight: 400)
                
                Spacer()
                
                // Voice control button
                VStack(spacing: 16) {
                    // Main microphone button
                    Button(action: {
                        if isListening {
                            stopListening()
                        } else {
                            startListening()
                        }
                    }) {
                        ZStack {
                            // Pulsing rings when listening
                            if isListening {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .stroke(Color.red.opacity(0.4), lineWidth: 3)
                                        .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                                        .scaleEffect(isListening ? 1.2 : 1.0)
                                        .opacity(isListening ? 0 : 0.6)
                                        .animation(
                                            Animation.easeInOut(duration: 1.5)
                                                .repeatForever(autoreverses: false)
                                                .delay(Double(index) * 0.2),
                                            value: isListening
                                        )
                                }
                            }
                            
                            // Main button
                            Circle()
                                .fill(
                                    isListening ?
                                    LinearGradient(
                                        colors: [Color.red, Color.red.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color(hex: "4285F4"), Color(hex: "34A853")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(
                                    color: (isListening ? Color.red : Color(hex: "4285F4")).opacity(0.4),
                                    radius: 20,
                                    x: 0,
                                    y: 10
                                )
                                .overlay(
                                    Image(systemName: "mic.fill")
                                        .font(.system(size: 40, weight: .semibold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .scaleEffect(isListening ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isListening)
                    
                    // Status text
                    Text(isListening ? "Tap to stop" : isSpeaking ? "AI is speaking..." : "Tap to speak")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                        )
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startInitialVoiceConversation()
        }
        .onChange(of: conversationManager.isSpeaking) { newValue in
            isSpeaking = newValue
        }
    }
    
    private func startListening() {
        isListening = true
        showTranscript = true
        liveTranscript = ""
        voiceControl.startRecording { transcript in
            liveTranscript = transcript
        } onFinal: { finalTranscript in
            Task {
                await handleVoiceInput(finalTranscript)
            }
        }
    }
    
    private func stopListening() {
        print("🔵 Stopping listening, final transcript: '\(liveTranscript)'")
        isListening = false
        
        // Get the final transcript before stopping
        let finalText = liveTranscript.trimmingCharacters(in: .whitespacesAndNewlines)
        
        voiceControl.stopRecording()
        
        // If we have a transcript, process it
        if !finalText.isEmpty {
            Task {
                await handleVoiceInput(finalText)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showTranscript = false
            }
        }
    }
    
    private func handleVoiceInput(_ text: String) async {
        // Prevent processing if we're already handling a response
        if isProcessingResponse {
            print("🔵 Voice chat: Already processing a response, ignoring input: '\(text)'")
            return
        }
        
        // Clean and validate the transcript
        let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedText.isEmpty else {
            print("🔵 Voice input: Empty transcript, ignoring")
            await MainActor.run {
                liveTranscript = ""
                showTranscript = false
                isListening = false
            }
            return
        }
        
        print("🔵 Voice input received: '\(cleanedText)'")
        print("🔵 Voice input length: \(cleanedText.count) characters")
        
        await MainActor.run {
            isProcessingResponse = true // Lock processing
            liveTranscript = ""
            showTranscript = false
            isListening = false
            // Show what the user said while processing
            currentResponse = "You said: \"\(cleanedText.prefix(50))\(cleanedText.count > 50 ? "..." : "")\"\n\nProcessing..."
        }
        
        // Send user's actual speech to conversation manager
        // This will automatically generate a response based on what the user said
        print("🔵 Voice chat: Sending to ConversationManager: '\(cleanedText)'")
        print("🔵 Voice chat: This will be sent to Gemini with full conversation context")
        
        await conversationManager.sendMessage(cleanedText, stressLevel: stressMonitor.currentStressLevel)
        
        // Wait a bit for the response to be generated and added to messages
        var attempts = 0
        while attempts < 20 {
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
            
            let lastMessage = await MainActor.run {
                conversationManager.messages.last
            }
            
            if let message = lastMessage, message.role == .assistant {
                print("🔵 Voice chat: ✅ Got AI response: '\(message.content.prefix(50))...'")
                await MainActor.run {
                    currentResponse = message.content
                }
                
                // The response should already be speaking from sendMessage,
                // but ensure it's speaking if it's not already
                // Wait a moment for isSpeaking to update
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                
                if !conversationManager.isSpeaking {
                    print("🔵 Voice chat: Response not speaking yet, starting speech...")
                    await conversationManager.speakResponse(message.content)
                } else {
                    print("🔵 Voice chat: Response is already being spoken")
                }
                
                // Release lock after processing is complete
                await MainActor.run {
                    isProcessingResponse = false
                }
                return
            }
            
            attempts += 1
        }
        
        // If we didn't get a response, show error
        print("⚠️ Voice chat: No AI response received after waiting")
        await MainActor.run {
            currentResponse = "I'm having trouble processing that. Could you try again?"
            isProcessingResponse = false // Release lock on error
        }
    }
    
    private func startInitialVoiceConversation() {
        Task {
            // Only start initial conversation if no messages exist yet
            guard conversationManager.messages.isEmpty else {
                print("🔵 Voice chat: Conversation already started, skipping initial message")
                return
            }
            
            let initialReading = stressMonitor.readings.last ?? StressReading(
                timestamp: Date(),
                stress: 0.5,
                breathing: 0.5,
                engagement: 0.5
            )
            
            conversationManager.startSession(
                stressLevel: stressMonitor.currentStressLevel,
                initialReading: initialReading
            )
            
            // Send initial greeting only once
            await conversationManager.sendMessage(
                "Hi! I'm Anchor. I'm here to support you. How are you feeling right now?",
                stressLevel: stressMonitor.currentStressLevel
            )
            
            if let lastMessage = conversationManager.messages.last, lastMessage.role == .assistant {
                await MainActor.run {
                    currentResponse = lastMessage.content
                }
                
                await conversationManager.speakResponse(lastMessage.content)
            }
        }
    }
}

// Voice Control View Model
class VoiceControlViewModel: ObservableObject {
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    private var onPartialTranscript: ((String) -> Void)?
    private var onFinalTranscript: ((String) -> Void)?
    
    init() {
        speechRecognizer = SFSpeechRecognizer()
    }
    
    func startRecording(
        onPartial: @escaping (String) -> Void,
        onFinal: @escaping (String) -> Void
    ) {
        onPartialTranscript = onPartial
        onFinalTranscript = onFinal
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                DispatchQueue.main.async {
                    self.beginRecognition()
                }
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating audio session: \(error)")
        }
    }
    
    private func beginRecognition() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("⚠️ Speech recognizer not available")
            return
        }
        
        // Stop any existing recognition first
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true)
            print("✅ Audio session configured for recording")
        } catch {
            print("⚠️ Failed to configure audio session: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else {
            print("⚠️ Failed to create recognition request")
            return
        }
        
        let inputNode = audioEngine.inputNode
        request.shouldReportPartialResults = true
        
        // Store the latest transcript to use when stopping
        var latestTranscript = ""
        
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let result = result {
                    let transcript = result.bestTranscription.formattedString
                    latestTranscript = transcript // Always update latest
                    print("🎤 Speech recognition: '\(transcript)' (isFinal: \(result.isFinal))")
                    
                    // Update live transcript for display
                    self.onPartialTranscript?(transcript)
                    
                    // If final, process immediately
                    if result.isFinal {
                        print("🎤 ✅ Final transcript received: '\(transcript)'")
                        self.onFinalTranscript?(transcript)
                    }
                }
                
                if let error = error {
                    let nsError = error as NSError
                    // Filter out common non-critical errors
                    if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1101 {
                        // Common iOS warning, can be ignored if transcription works
                        print("ℹ️ Speech recognition service warning (can be ignored)")
                    } else {
                        print("⚠️ Speech recognition error: \(error.localizedDescription)")
                        
                        // If we have a transcript but got an error, use the latest transcript
                        if !latestTranscript.isEmpty {
                            print("🎤 Using latest transcript despite error: '\(latestTranscript)'")
                            self.onFinalTranscript?(latestTranscript)
                        } else if result == nil {
                            // Only stop if we got no result at all
                            self.stopRecording()
                        }
                    }
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("✅ Audio engine started - listening for speech")
        } catch {
            print("⚠️ Failed to start audio engine: \(error.localizedDescription)")
            self.stopRecording()
        }
    }
}

#Preview {
    ConversationView()
        .environmentObject(ConversationManager())
        .environmentObject(StressMonitor())
}

