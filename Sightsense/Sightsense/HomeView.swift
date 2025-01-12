import SwiftUI
import AVFoundation

struct HomeView: View {
    @ObservedObject private var speechRecognizer = SpeechRecognizer()

    private let cameraManager = CameraManager()

    @State private var isListening = false

    var body: some View {
        ZStack {
            Color(red: 175/255, green: 196/255, blue: 214/255)
                .ignoresSafeArea()
            VStack {
                Text("SightSense")
                    .font(.largeTitle)
                    .padding(.bottom, 50)

                Circle()
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isListening ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isListening
                    )
                    .onTapGesture {
                        isListening.toggle()
                        if isListening {
                            // Start listening
                            speechRecognizer.startRecording { recognizedText in
                                print("Recognized text: \(recognizedText)")
                                // Send recognizedText to Python backend
                            }
                        } else {
                            speechRecognizer.stopRecording()
                        }
                    }
            }
        }
        .onAppear {
            // Start camera detection here after
        }
    }
}
