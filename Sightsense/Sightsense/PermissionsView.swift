import SwiftUI
import AVFoundation
import Speech

struct PermissionsView: View {
    // Use synthesizer from RootView
    let tts: AVSpeechSynthesizer
    let onPermissionsComplete: () -> Void

    @State private var showExplanation = true

    var body: some View {
        VStack(spacing: 20) {
            if showExplanation {
                Text("We need camera and microphone access to detect objects and hear you speak.")
                    .padding()

                Button("Allow Access") {
                    // Speak "Requesting permissions, please grant access..." if desired
                    requestAllPermissions {
                        onPermissionsComplete()
                    }
                }
            }
        }
        .font(.title2)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
        .padding()
        .onAppear {
            speak(
                "We need camera and microphone access to detect objects and hear you speak. Please tap the Allow Access button to continue."
            )
        }
    }

    private func requestAllPermissions(completion: @escaping () -> Void) {
        // 1) Camera
        AVCaptureDevice.requestAccess(for: .video) { _ in
            // 2) Microphone
            AVAudioSession.sharedInstance().requestRecordPermission { _ in
                // 3) Speech Recognition
                SFSpeechRecognizer.requestAuthorization { _ in
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        tts.speak(utterance)
    }
}
