//
//  placeholderApp.swift
//  placeholder
//
//  Created by Aiden Ly on 2025-01-11.
//

import SwiftUI
import UIKit

@main
struct YourAppName: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var isCameraPresented: Bool

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.isCameraPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isCameraPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
