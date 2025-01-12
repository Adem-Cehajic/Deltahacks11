import SwiftUI

struct MovingGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#afc4d6"),  // Light blue from logo
                Color(hex: "#4682b4"),  // Steel blue
                Color(hex: "#000080")   // Navy
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct PulsatingText: View {
    @State private var scale: CGFloat = 1.0
    let text: String
    
    var body: some View {
        Text(text)
            .font(.custom("DM Sans", size: 32, relativeTo: .title))
            .fontWeight(.medium)
            .foregroundColor(.white)
            .scaleEffect(scale)
            .animation(
                Animation
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: scale
            )
            .onAppear {
                scale = 1.05
            }
    }
}

struct WelcomeView: View {
    let onAppearAction: () -> Void
    let onNext: () -> Void
    @State private var tapped = false
    @State private var textScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            MovingGradientBackground()
            
            VStack {
                Spacer()
                
                // Animated welcome text
                PulsatingText(text: "Tap to Get Started")
                    .scaleEffect(tapped ? 0.8 : 1.0)
                    .opacity(tapped ? 0.0 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: tapped)
                
                Spacer()
            }
        }
        .onAppear {
            onAppearAction()
        }
        .onTapGesture {
            withAnimation {
                tapped = true
            }
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // Delay the transition slightly to show the animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onNext()
            }
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
