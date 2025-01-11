//
//  ContentView.swift
//  Sightsense
//
//  Created by Aiden Ly on 2025-01-11.
//

import SwiftUI

struct ContentView: View {
    private let cameraManager = CameraManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Object Tracker")
                .font(.title)
                .padding()

            Button("Start Camera") {
                cameraManager.start()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Stop Camera") {
                cameraManager.stop()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
