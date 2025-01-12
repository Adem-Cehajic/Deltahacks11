import SwiftUI
import AVFoundation

struct HomeView: View {
    @ObservedObject private var speechRecognizer = SpeechRecognizer()
    private let cameraManager = CameraManager()

    @State private var isListening = false
    
    // Text-to-speech synthesizer
    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            Color(red: 175/255, green: 196/255, blue: 214/255)
                .ignoresSafeArea()
            
            VStack {
                Text("SightSense")
                    .font(.largeTitle)
                    .padding(.bottom, 50)

                // Circle with white outline and stronger pulsing effect
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .background(Circle().fill(Color.blue))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isListening ? 1.4 : 1.0) // Larger scale for a stronger pulse
                    .animation(
                        Animation.easeInOut(duration: 0.75)
                            .repeatForever(autoreverses: true),
                        value: isListening
                    )
                    .onTapGesture {
                        isListening.toggle()
                        if isListening {
                            // Start listening
                            speak("Listening")
                            speechRecognizer.startRecording { recognizedText in
                                print("Recognized text: \(recognizedText)")
                                sendRecognizedTextToServer(recognizedText)
                            }
                        } else {
                            // Stop listening
                            speak("Processing your request")
                            speechRecognizer.stopRecording()
                        }
                    }
            }
        }
        // When the view appears, announce instructions
        .onAppear {
            speak("Tap to begin your request")
            // You can start camera detection here if needed
            // cameraManager.startCameraDetection()
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        synthesizer.speak(utterance)
    }
    
    func sendRecognizedTextToServer(_ recognizedText: String) {
        // Replace with your actual backend URL or IP + route
        guard let url = URL(string: "http://127.0.0.1:800") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create JSON payload, for example {"query": "..."}
        let parameters = ["query": recognizedText]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                return
            }
            guard let data = data else {
                print("No data returned")
                return
            }
            // Optionally handle a JSON response from Python
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
        }.resume()
    }

}
