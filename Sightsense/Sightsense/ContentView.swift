import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var showLogo = true // Controls logo visibility
    @State private var showPrompt = false // Controls prompt visibility
    @State private var showCameraStatusText = false // Controls camera status text visibility
    @State private var audioPlayer: AVAudioPlayer?

    private let cameraManager = CameraManager()

    var body: some View {
        ZStack {
            // Set the background color using RGB values for hex #afc4d6
            Color(red: 175 / 255, green: 196 / 255, blue: 214 / 255)
                .ignoresSafeArea() // Ensures the background covers the entire screen

            if showLogo {
                Image("SightsenseLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .transition(.opacity)
                    .onAppear {
                        playSound() // Play sound when the logo appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Adjust fade duration as needed
                            withAnimation(.easeOut(duration: 1)) {
                                showLogo = false
                                showPrompt = true
                            }
                        }
                    }
            }

            if showPrompt {
                VStack {
                    Text("Tap anywhere to continue")
                        .font(.title)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 1)) {
                                showPrompt = false
                                showCameraStatusText = true
                                cameraManager.start() // Start capturing frames when user taps
                            }
                        }
                }
            }

            if showCameraStatusText {
                Text("Looking around with the camera...")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "soundfileplaceholder", withExtension: "mp3") else { return } // Replace with sound file name

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound:", error.localizedDescription)
        }
    }
}
