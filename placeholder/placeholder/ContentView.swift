//
//  ContentView.swift
//  placeholder
//
//  Created by Aiden Ly on 2025-01-11.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var capturedImage: UIImage?
    @State private var isCameraPresented = false

    var body: some View {
        VStack {
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            Button("Open Camera") {
                isCameraPresented = true
            }
            .sheet(isPresented: $isCameraPresented) {
                CameraView(capturedImage: $capturedImage, isCameraPresented: $isCameraPresented)
            }
        }
    }
}
#Preview {
    ContentView()
}
