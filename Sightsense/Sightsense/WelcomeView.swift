import SwiftUI

struct WelcomeView: View {
    let onAppearAction: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Text("Tap to Get Started")
                .font(.title)
                .foregroundColor(.primary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            // Speak the text once this view appears
            onAppearAction()
        }
        .onTapGesture {
            // The user taps once, we go to next
            onNext()
        }
    }
}
