import SwiftUI

enum ConversationMode {
    case text
    case voice
}

struct GeminiConversationView: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var stressMonitor: StressMonitor
    @State private var inputText: String = ""
    @State private var conversationMode: ConversationMode = .text
    @State private var showModePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Presage indicator at top
            PresageIndicatorView()
                .environmentObject(stressMonitor)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            // Mode toggle
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        conversationMode = .text
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "keyboard")
                            .font(.system(size: 14, weight: .medium))
                        Text("Text")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(conversationMode == .text ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(conversationMode == .text ? Color(hex: "4CAF50") : Color.white.opacity(0.8))
                    )
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        conversationMode = .voice
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text("Voice")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(conversationMode == .voice ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(conversationMode == .voice ? Color(hex: "4CAF50") : Color.white.opacity(0.8))
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Messages - Gemini style
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(conversationManager.messages) { message in
                            GeminiMessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .frame(maxHeight: 400)
                .onChange(of: conversationManager.messages.count) { _ in
                    if let lastMessage = conversationManager.messages.last {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // Input area - Gemini style
            if conversationMode == .text {
                GeminiInputField(
                    text: $inputText,
                    onSend: {
                        sendMessage()
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else {
                GeminiVoiceInput()
                    .environmentObject(conversationManager)
                    .environmentObject(stressMonitor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
        }
        .background(Color.white.opacity(0.95))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 5)
        .onAppear {
            if conversationManager.messages.isEmpty {
                startInitialConversation()
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        let text = inputText
        inputText = ""
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        Task {
            await conversationManager.sendMessage(text, stressLevel: stressMonitor.currentStressLevel)
        }
    }
    
    private func startInitialConversation() {
        Task {
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
            
            await conversationManager.sendMessage(
                "Hi! I'm Anchor. I'm here to support you. How are you feeling right now?",
                stressLevel: stressMonitor.currentStressLevel
            )
        }
    }
}

struct GeminiMessageBubble: View {
    let message: ChatMessage
    @State private var appear = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                // Gemini-style avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4285F4"), Color(hex: "34A853")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(message.role == .user ? .white : .black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.role == .user ?
                            Color(hex: "4285F4") :
                            Color(hex: "F1F3F4")
                    )
                    .cornerRadius(18)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
            }
            
            if message.role == .user {
                Spacer(minLength: 40)
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appear = true
            }
        }
    }
}

struct GeminiInputField: View {
    @Binding var text: String
    var onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundColor(.black)
                .font(.system(size: 16, weight: .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "F1F3F4"))
                )
                .lineLimit(1...4)
                .onSubmit {
                    if !text.isEmpty {
                        onSend()
                    }
                }
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(text.isEmpty ? Color.gray.opacity(0.4) : Color(hex: "4285F4"))
            }
            .disabled(text.isEmpty)
            .scaleEffect(text.isEmpty ? 0.9 : 1.0)
            .animation(.spring(response: 0.3), value: text.isEmpty)
        }
    }
}

struct GeminiVoiceInput: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var stressMonitor: StressMonitor
    
    var body: some View {
        VoiceControlView()
            .environmentObject(conversationManager)
    }
}

#Preview {
    GeminiConversationView()
        .environmentObject(ConversationManager())
        .environmentObject(StressMonitor())
}

