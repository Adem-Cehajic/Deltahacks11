import SwiftUI
import AVFoundation
import Speech

struct PermissionsView: View {
    let tts: AVSpeechSynthesizer
    let onPermissionsComplete: () -> Void
    
    @State private var showGradient = false
    @State private var textOpacity = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "#afc4d6"),
                    Color(hex: "#4682b4")
                ],
                startPoint: showGradient ? .topLeading : .bottomLeading,
                endPoint: showGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .animation(.linear(duration: 3.0).repeatForever(autoreverses: true), value: showGradient)
            
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 40)
                
                Text("Welcome to")
                    .font(.custom("DM Sans", size: 24))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("SightSense")
                    .font(.custom("DM Sans", size: 42))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 24) {
                    Image("Eye")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 120)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    
                    VStack(spacing: 12) {
                        Text("We need your permission")
                            .font(.custom("DM Sans", size: 28))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Text("To help identify objects and respond to your commands, we need access to your camera and microphone")
                            .font(.custom("DM Sans", size: 18))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 32)
                            .lineSpacing(4)
                    }
                }
                .padding(.top, 32)
                
                Spacer()
                
                Text("Tap anywhere to continue")
                    .font(.custom("DM Sans", size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 24)
            }
            .padding(.vertical)
            .opacity(textOpacity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("SightSense needs camera and microphone access. Tap anywhere to grant permissions.")
        }
        .onAppear {
            showGradient = true
            withAnimation(.easeIn(duration: 1.0)) {
                textOpacity = 1.0
            }
            speak("SightSense needs camera and microphone access to help identify objects and hear your commands. Tap anywhere to grant permissions.")
        }
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            requestAllPermissions()
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        tts.speak(utterance)
    }
    
    private func requestAllPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                print("Camera access denied")
            }
        }
        
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("Speech recognition access denied")
            }
        }
        
        onPermissionsComplete()
    }
}

