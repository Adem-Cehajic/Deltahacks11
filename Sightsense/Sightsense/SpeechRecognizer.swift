import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let recognizer = SFSpeechRecognizer()
    private let session = AVAudioSession.sharedInstance()

    var isRunning: Bool {
        audioEngine.isRunning
    }

    func startRecording(completion: @escaping (String) -> Void) {
        guard recognitionTask == nil else { return }
        
        do {
            // Configure audio session
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            
            let node = audioEngine.inputNode
            request = SFSpeechAudioBufferRecognitionRequest()
            guard let request = request else { return }
            
            request.shouldReportPartialResults = true
            
            // Use the input node's native format
            let recordingFormat = node.inputFormat(forBus: 0)
            
            recognitionTask = recognizer?.recognitionTask(with: request) { result, error in
                if let result = result {
                    let bestString = result.bestTranscription.formattedString
                    completion(bestString)
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stopRecording()
                }
            }
            
            node.installTap(onBus: 0,
                          bufferSize: 1024,
                          format: recordingFormat) { buffer, when in
                request.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
        } catch {
            print("Audio engine error: \(error.localizedDescription)")
            stopRecording()
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        request?.endAudio()
        request = nil
        
        try? session.setActive(false)
    }
}
