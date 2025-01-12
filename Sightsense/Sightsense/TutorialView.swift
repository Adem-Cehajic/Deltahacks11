import SwiftUI
import AVFoundation

struct TutorialView: View {
    let tts: AVSpeechSynthesizer
    let onTutorialComplete: () -> Void

    // This script is read during the tutorial
    let tutorialScript = """
Thank you for choosing SightSense! ...
After this tutorial, we will continue to the home screen.
If you want to skip this, tap once on the screen at any point.
With SightSense, you can identify objects around you, track them in real time, and even ask for colors or descriptions.
You can also read printed text by pointing your camera at the text, and SightSense will speak it out loud.
When you speak, your words are analyzed by our AI system, and we’ll do our best to guide you in the right direction.
Thank you. You’ll now be on the home screen where you can talk to SightSense anytime.
"""

    var body: some View {
            VStack {
                Text("Tutorial in progress...")
                    .font(.title2)
                    .padding()
                
                Text("Tap anywhere to skip")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            }
            .onAppear {
                startTutorial()
            }
        }

        private func startTutorial() {
            let utterance = AVSpeechUtterance(string: tutorialScript)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            
            tts.delegate = SpeechDelegate {
                // Automatically advance when speech finishes
                onTutorialComplete()
            }
            tts.speak(utterance)
        }
    }

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
