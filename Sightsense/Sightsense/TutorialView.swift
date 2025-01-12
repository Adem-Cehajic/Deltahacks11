import SwiftUI
import AVFoundation

struct TutorialView: View {
    let tts: AVSpeechSynthesizer
    let onTutorialComplete: () -> Void
    @State private var opacity: Double = 0

    let tutorialScript = """
Thank you for choosing SightSense! ...
After this tutorial, we will continue to the home screen.
If you want to skip this, tap once on the screen at any point.
With SightSense, you can identify objects around you, track them in real time, and even ask for colors or descriptions.
You can also read printed text by pointing your camera at the text, and SightSense will speak it out loud.
When you speak, your words are analyzed by our AI system, and we'll do our best to guide you in the right direction.
Thank you. You'll now be on the home screen where you can talk to SightSense anytime.
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .opacity(opacity)
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
        
        tts.delegate = SpeechDelegate {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onTutorialComplete()
            }
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
