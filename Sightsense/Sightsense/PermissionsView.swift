import SwiftUI
import AVFoundation
import Speech

struct PermissionsView: View {
    let onPermissionsComplete: () -> Void

    @State private var showExplanation = true

    var body: some View {
        VStack(spacing: 20) {
            if showExplanation {
                Text("We need camera and microphone access to detect objects and hear you speak.")
                    .padding()
                Button("Allow Access") {
                    requestAllPermissions {
                        onPermissionsComplete()
                    }
                }
            } else {
 
            }
        }
        .font(.title2)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
        .padding()
        .onAppear {
            // Possibly speak explanation here if desired
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
}
