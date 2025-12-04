import SwiftUI
import AVFoundation
import Speech

struct FullScreenVoiceChatView: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @EnvironmentObject var stressMonitor: StressMonitor
    @Binding var isPresented: Bool
    @StateObject private var voiceControl = VoiceControlViewModel()
    @State private var isListening = false
    @State private var isSpeaking = false
    @State private var liveTranscript: String = ""
    @State private var currentResponse: String = ""
    @State private var showTranscript = false
    
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
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 28, height: 28)
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
                                    Image(systemName: isListening ? "mic.fill" : "mic.fill")
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
            // Start initial conversation
            startInitialVoiceConversation()
        }
        .onChange(of: conversationManager.isSpeaking) { speaking in
            isSpeaking = speaking
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
        isListening = false
        voiceControl.stopRecording()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if liveTranscript.isEmpty {
                showTranscript = false
            }
        }
    }
    
    private func handleVoiceInput(_ text: String) async {
        // Clear live transcript
        await MainActor.run {
            liveTranscript = ""
            showTranscript = false
            isListening = false
        }
        
        // Send message to conversation manager
        await conversationManager.sendMessage(text, stressLevel: stressMonitor.currentStressLevel)
        
        // Get the latest AI response
        if let lastMessage = conversationManager.messages.last, lastMessage.role == .assistant {
            await MainActor.run {
                currentResponse = lastMessage.content
            }
            
            // Speak the response using ElevenLabs
            await conversationManager.speakResponse(lastMessage.content)
        }
    }
    
    private func startInitialVoiceConversation() {
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
            
            // Send initial message
            await conversationManager.sendMessage(
                "Hi! I'm Anchor. I'm here to support you. How are you feeling right now?",
                stressLevel: stressMonitor.currentStressLevel
            )
            
            // Get and display the response
            if let lastMessage = conversationManager.messages.last, lastMessage.role == .assistant {
                await MainActor.run {
                    currentResponse = lastMessage.content
                }
                
                // Speak the initial response
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
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }
        
        let inputNode = audioEngine.inputNode
        request.shouldReportPartialResults = true
        
        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let result = result {
                    let transcript = result.bestTranscription.formattedString
                    self.onPartialTranscript?(transcript)
                    
                    if result.isFinal {
                        self.onFinalTranscript?(transcript)
                    }
                }
                
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain != "kAFAssistantErrorDomain" || nsError.code != 1101 {
                        print("Speech recognition error: \(error.localizedDescription)")
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
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
}

import Speech

#Preview {
    FullScreenVoiceChatView(isPresented: .constant(true))
        .environmentObject(ConversationManager())
        .environmentObject(StressMonitor())
}

