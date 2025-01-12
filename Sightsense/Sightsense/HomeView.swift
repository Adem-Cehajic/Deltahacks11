import SwiftUI
import AVFoundation

struct HomeView: View {
    @ObservedObject private var speechRecognizer = SpeechRecognizer()
    private let cameraManager = CameraManager()

    @State private var isListening = false
    @State private var finalRecognizedText = ""

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
                            // Reset any previous recognized text
                            finalRecognizedText = ""
                            
                            // Start continuous speech recognition
                            speechRecognizer.startRecording { recognizedText in
                                // Keep updating finalRecognizedText as partial results come in
                                finalRecognizedText = recognizedText
                                print("Partial (or final) recognized text: \(recognizedText)")
                            }

                        } else {
                            // Stop listening and send to server
                            speak("Waiting")
                            speechRecognizer.stopRecording()
                            
                            // Send the final recognized text to the backend
                            sendRecognizedTextToServer(finalRecognizedText)
                        }
                    }
            }
        }
        .onAppear {
            speak("Tap to begin your request")
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        synthesizer.speak(utterance)
    }
    
    private func sendRecognizedTextToServer(_ recognizedText: String) {
        guard let url = URL(string: "http://172.18.51.126:8000/speech") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
        }.resume()
    }
}
