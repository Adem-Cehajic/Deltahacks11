import AVFoundation
import UIKit

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var lastFrameTime: TimeInterval = 0
    var fps: Double = 10 // Adjustable FPS

    override init() {
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        captureSession.sessionPreset = .medium

        // Configure camera input
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input) else { return }

        captureSession.addInput(input)

        // Configure video output
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)

        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
    }

    func start() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastFrameTime >= 1.0 / fps else { return }
        lastFrameTime = currentTime

        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Convert image buffer to UIImage
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()

        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)

            // Send frame to Python backend
            sendFrameToBackend(image: uiImage)
        }
    }

    private func sendFrameToBackend(image: UIImage) {
        guard let url = URL(string: "PLACEHOLDER_URL"),
              let jpegData = image.jpegData(compressionQuality: 0.8) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        URLSession.shared.uploadTask(with: request, from: jpegData) { data, response, error in
            if let error = error {
                print("Error uploading frame:", error)
                return
            }

            print("Frame uploaded successfully")
        }.resume()
    }
}
