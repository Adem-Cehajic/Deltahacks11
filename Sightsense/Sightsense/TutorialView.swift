import SwiftUI
import AVFoundation

struct TutorialView: View {
    let tts: AVSpeechSynthesizer
    let onTutorialComplete: () -> Void

    @State private var tutorialFinished = false

    let tutorialScript = """
Thank you for choosing SightSense!
With SightSense, you can identify objects around you, track them in real time, and even ask for colors or descriptions.
You can also read printed text by pointing your camera at the text, and SightSense will speak it out loud.
When you speak, your words are analyzed by our AI system, and we’ll do our best to guide you in the right direction.
After this tutorial, just tap once to finish, and then you’ll be on the home screen where you can talk to SightSense anytime.
"""

    var body: some View {
        VStack {
            Text("Tutorial in progress...")
                .font(.title2)
                .padding()
            if tutorialFinished {
                Text("Tap once to finish.")
                    .font(.headline)
                    .padding()
            }
        }
        .onAppear {
            startTutorial()
        }
        .onTapGesture {
            // If tutorial is done, proceed; else ignore
            if tutorialFinished {
                // Provide a small haptic
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onTutorialComplete()
            }
        }
    }

    private func startTutorial() {
        // Speak the tutorial text
        let utterance = AVSpeechUtterance(string: tutorialScript)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        // ~2 minutes or less depending on speed
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9

        tts.delegate = SpeechDelegate {
            // Called when TTS finishes
            tutorialFinished = true
        }
        tts.speak(utterance)
    }
}

// A small AVSpeechSynthesizerDelegate helper
class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    let onDone: () -> Void
    init(onDone: @escaping () -> Void) {
        self.onDone = onDone
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        onDone()
    }
}
