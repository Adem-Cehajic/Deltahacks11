import SwiftUI

struct LoadingView: View {
    let onComplete: () -> Void

    var body: some View {
        Image("SightsenseLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    onComplete()
                }
            }
    }
}
