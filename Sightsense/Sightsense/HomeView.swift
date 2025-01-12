import SwiftUI
import AVFoundation

struct HomeView: View {
    @ObservedObject private var speechRecognizer = SpeechRecognizer()
    private let cameraManager = CameraManager()
    
    @State private var isListening = false
    @State private var isSpeaking = false // Tracks if the microphone is actively picking up input
    @State private var finalRecognizedText = ""
    @State private var serverResponseText = "" // Holds the server's response
    @State private var buttonStatusText = "Awaiting command" // Tracks button status text
    @State private var hasUsedButton = false // Tracks if the button has been used
    
    // Text-to-speech synthesizer
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 175/255, green: 196/255, blue: 214/255)
                .ignoresSafeArea()
            
            VStack {
                Spacer() // Push content down slightly
                
                // Title text
                Text("SightSense")
                    .font(.largeTitle)
                    .foregroundColor(.black)
                    .padding(.bottom, 20) // Add space below the title
                    .padding(.top, -30)   // Raise the title slightly higher
                
                // Circle button with animation
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .background(Circle().fill(Color.blue))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isSpeaking ? 1.4 : 1.0) // Pulsate when speaking
                    .animation(
                        isSpeaking
                            ? Animation.easeInOut(duration: 0.75).repeatForever(autoreverses: true)
                            : .default,
                        value: isSpeaking
                    )
                    .onTapGesture {
                        handleTapGesture()
                    }
                
                // Status text below the button
                Text(buttonStatusText)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                Spacer() // Add space between the button and the response box
                
                // Response text box
                Text(serverResponseText.isEmpty ? "Response will appear here" : serverResponseText)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                
                Spacer() // Push everything up slightly from the bottom
            }
        }
        .onAppear {
            speak("Tap to begin your request")
        }
    }
    
    // Handles tap gesture on the circle button
    private func handleTapGesture() {
        isListening.toggle()
        
        if isListening {
            // Start listening
            buttonStatusText = "Listening..."
            speak("Listening")
            finalRecognizedText = ""
            serverResponseText = ""
            
            speechRecognizer.startRecording { recognizedText in
                finalRecognizedText = recognizedText
                print("Partial (or final) recognized text: \(recognizedText)")
                
                isSpeaking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isSpeaking = false
                }
            }
        } else {
            // Stop listening and send to server
            buttonStatusText = "Processing request"
            speak("Processing your request")
            speechRecognizer.stopRecording()
            sendRecognizedTextToServer(finalRecognizedText)
        }
        
        hasUsedButton = true
    }
    
    // Speaks the given text using AVSpeechSynthesizer
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        synthesizer.speak(utterance)
}
    
    private func sendRecognizedTextToServer(_ recognizedText: String) {
        guard let url = URL(string: "http://172.18.179.5:8000/speech") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = ["query": recognizedText]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON:", error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error:", error)
                return
            }
            guard let data = data else {
                print("No data returned")
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    // Update the UI with the server's response text
                    self.serverResponseText = responseString
                    
                    // Trigger Text-to-Speech for the server's response
                    self.speak(responseString)
                    
                    // Start sending frames if the response matches the specific string
                    if responseString == "Ok, I will begin reading the text, please point your camera towards it" {
                        self.cameraManager.start()
                    }
                }
            } else {
                print("Unable to decode server response as string")
            }
        }
        
        task.resume()
    }
    
}


