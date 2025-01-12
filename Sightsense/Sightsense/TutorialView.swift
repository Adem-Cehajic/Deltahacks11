import SwiftUI
import AVFoundation

struct TutorialView: View {
    let tts: AVSpeechSynthesizer
    let onTutorialComplete: () -> Void

    @State private var opacity: Double = 0
    @StateObject private var speechDelegate: SpeechDelegate
    @State private var gradientColors: [Color] = [Color.blue.opacity(0.6), Color.cyan.opacity(0.8), Color.purple.opacity(0.6)]
    @State private var gradientAnimationToggle = false

    let tutorialScript = """
    
    Welcome to SightSense!
    
    To skip this tutorial and go to the home screen, tap anywhere.
    
    This tutorial will guide you through the app's features.
    
    With SightSense, you can identify objects around you, track them in real time, and ask our highly intellegent machine learning model advanced questions about what you are seeing.
    
    You can also read printed text by pointing your camera at the text, and SightSense will speak it out loud.
    
    When you speak, your words are analyzed by our model, and we'll do our best to guide you in the right direction.
    
    Thank you for choosing SightSense!
    """

    init(tts: AVSpeechSynthesizer, onTutorialComplete: @escaping () -> Void) {
        self.tts = tts
        self.onTutorialComplete = onTutorialComplete
        _speechDelegate = StateObject(wrappedValue: SpeechDelegate(onDone: onTutorialComplete))
    }

    var body: some View {
        ZStack {
            // Enhanced animated gradient background
            LinearGradient(
                gradient: Gradient(colors: gradientAnimationToggle ? gradientColors : gradientColors.reversed()),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: gradientAnimationToggle)
            .onAppear {
                gradientAnimationToggle.toggle()
            }

            VStack(spacing: 40) {
                // Title text with improved styling
                Text("Tutorial in Progress")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()

                // Instructional text with improved styling
                Text("Tap anywhere to skip")
                    .font(.title.weight(.medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .opacity(opacity)
        }
        .contentShape(Rectangle()) // Allows tapping anywhere on screen
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tts.stopSpeaking(at: .immediate)
                onTutorialComplete()
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1
            }
            startTutorial()
        }
    }

    private func startTutorial() {
        let utterance = AVSpeechUtterance(string: tutorialScript)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9 // Slightly slower for accessibility

        tts.delegate = speechDelegate
        tts.speak(utterance)
    }
}

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    let onDone: () -> Void

    init(onDone: @escaping () -> Void) {
        self.onDone = onDone
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onDone()
    }
}

