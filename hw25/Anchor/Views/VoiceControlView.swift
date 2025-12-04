import SwiftUI
import Speech

struct VoiceControlView: View {
    @EnvironmentObject var conversationManager: ConversationManager
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var liveTranscript: String = ""
    @State private var showTranscript = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Real-time transcript display
            if showTranscript && !liveTranscript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(Color(hex: "4CAF50"))
                            .font(.caption)
                        Text("Listening...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(liveTranscript)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.black) // High contrast text color
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white) // Solid white for better contrast
                                .shadow(color: Color(hex: "4CAF50").opacity(0.3), radius: 10, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color(hex: "4CAF50").opacity(0.5), Color(hex: "66BB6A").opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                }
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            HStack(spacing: 16) {
                // Enhanced voice input button
                Button(action: {
                    print("Microphone button tapped")
                    toggleRecording()
                }) {
                ZStack {
                    // Pulsing ring when recording
                    if isRecording {
                        Circle()
                            .stroke(Color.red.opacity(0.4), lineWidth: 3)
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseScale)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: pulseScale
                            )
                    }
                    
                    // Main button
                    Circle()
                        .fill(
                            isRecording ?
                            LinearGradient(
                                colors: [Color.red, Color.red.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(hex: "4CAF50"), Color(hex: "66BB6A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: isRecording ? "mic.fill" : "mic.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(
                            color: (isRecording ? Color.red : Color(hex: "4CAF50")).opacity(0.4),
                            radius: 12,
                            x: 0,
                            y: 4
                        )
                }
            }
            .onChange(of: isRecording) { recording in
                if recording {
                    pulseScale = 1.3
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                } else {
                    pulseScale = 1.0
                }
            }
            
            // Enhanced speaking indicator
            if conversationManager.isSpeaking {
                HStack(spacing: 12) {
                    // Animated sound waves
                    HStack(spacing: 3) {
                        ForEach(0..<5) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "4CAF50"))
                                .frame(width: 3, height: CGFloat.random(in: 8...20))
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatForever()
                                        .delay(Double(index) * 0.1),
                                    value: conversationManager.isSpeaking
                                )
                        }
                    }
                    
                    Text("Speaking...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "4CAF50"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .transition(.scale.combined(with: .opacity))
            }
            }
        }
        .frame(maxWidth: .infinity)
        .allowsHitTesting(true)
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        // Request authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    // Check if recognizer is available
                    guard let recognizer = self.speechRecognizer, recognizer.isAvailable else {
                        print("⚠️ Speech recognizer not available")
                        return
                    }
                    self.isRecording = true
                    self.beginSpeechRecognition()
                case .denied, .restricted:
                    print("⚠️ Speech recognition denied or restricted")
                case .notDetermined:
                    print("⚠️ Speech recognition not determined")
                @unknown default:
                    print("⚠️ Unknown speech recognition authorization status")
                }
            }
        }
    }
    
    private func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        
        // Deactivate audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error)")
        }
        
        // Clear transcript after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if liveTranscript.isEmpty {
                showTranscript = false
            }
        }
    }
    
    private func beginSpeechRecognition() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("⚠️ Speech recognizer not available")
            return
        }
        
        // Configure audio session for recording
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session configured for recording")
        } catch {
            print("⚠️ Failed to configure audio session: \(error.localizedDescription)")
            stopRecording()
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else {
            print("⚠️ Failed to create recognition request")
            return
        }
        
        let inputNode = audioEngine.inputNode
        request.shouldReportPartialResults = true
        
        // Check if audio engine is running
        guard !audioEngine.isRunning else {
            print("⚠️ Audio engine already running")
            return
        }
        
        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            DispatchQueue.main.async {
                if let result = result {
                    let transcript = result.bestTranscription.formattedString
                    
                    // Update live transcript in real-time
                    liveTranscript = transcript
                    showTranscript = true
                    
                    // Send final transcript when recognition is complete
                    if result.isFinal {
                        Task {
                            await conversationManager.sendMessage(
                                transcript,
                                stressLevel: .calm // This should come from stress monitor
                            )
                        }
                        // Clear transcript after sending
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            liveTranscript = ""
                            showTranscript = false
                        }
                    }
                }
                
                if let error = error {
                    // Filter out common non-critical errors
                    let nsError = error as NSError
                    if nsError.domain == "kAFAssistantErrorDomain" && nsError.code == 1101 {
                        // This is a common iOS error that can be ignored if partial results are working
                        print("ℹ️ Speech recognition service warning (can be ignored if transcription works)")
                    } else {
                        print("⚠️ Speech recognition error: \(error.localizedDescription)")
                        if result == nil {
                            // Only stop if we got no result at all
                            stopRecording()
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
            print("✅ Audio engine started successfully")
        } catch {
            print("⚠️ Failed to start audio engine: \(error.localizedDescription)")
            stopRecording()
        }
    }
}

#Preview {
    VoiceControlView()
        .environmentObject(ConversationManager())
}

