import SwiftUI

// View for a moving gradient background
struct MovingGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#afc4d6"),  // Light blue
                Color(hex: "#4682b4"),  // Steel blue
                Color(hex: "#000080")   // Navy
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                Animation.linear(duration: 5.0)
                    .repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
        }
    }
}

// View for pulsating text
struct PulsatingText: View {
    @State private var scale: CGFloat = 1.0
    let text: String
    
    var body: some View {
        Text(text)
            .font(.custom("DM Sans", size: 32, relativeTo: .title))
            .fontWeight(.medium)
            .foregroundColor(.white)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.05
                }
            }
    }
}

// Main Welcome View
struct WelcomeView: View {
    let onAppearAction: () -> Void
    let onNext: () -> Void
    @State private var tapped = false
    
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

extension Color {
    init(hex: String) {
        // Ensure the input string is sanitized
        let sanitizedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitizedHex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch sanitizedHex.count {
        case 3: // Short hex (e.g., "#FFF" -> "#FFFFFF")
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // Standard hex (e.g., "#RRGGBB")
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB hex (e.g., "#AARRGGBB")
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default: // Default to opaque black for invalid input
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
