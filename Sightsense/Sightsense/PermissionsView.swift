import SwiftUI
import AVFoundation
import Speech

struct PermissionsView: View {
    let tts: AVSpeechSynthesizer
    let onPermissionsComplete: () -> Void
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tap anywhere to allow SightSense to use your camera and microphone")
                .font(.title2)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .opacity(opacity)
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tts.stopSpeaking(at: .immediate)
                requestAllPermissions {
                    onPermissionsComplete()
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1
            }
            speak("Tap anywhere on the screen to allow SightSense to use your camera and microphone. This helps us guide you and understand your requests.")
        }
    }
    
    private func requestAllPermissions(completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            AVAudioSession.sharedInstance().requestRecordPermission { _ in
                SFSpeechRecognizer.requestAuthorization { _ in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
}

extension PermissionsView {
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        tts.speak(utterance)
    }
}
