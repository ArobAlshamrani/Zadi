
import SwiftUI

struct SplashView: View {

    // MARK: - Animation States
    @State private var isPulsing = false
    @State private var isBackgroundLight = false

    var body: some View {
        ZStack {

            // MARK: - Background
            Color(red: 0.71, green: 0.90, blue: 1.0)
                .ignoresSafeArea()

            // MARK: - Background Fade
            Color.white
                .opacity(isBackgroundLight ? 0.30 : 0)
                .ignoresSafeArea()
                .animation(
                    .easeInOut(duration: 1.8),
                    value: isBackgroundLight
                )

            // MARK: - Animated Logo
            Image("ZadiLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 450)
                .padding(40)
                .scaleEffect(isPulsing ? 1.04 : 0.94)
                .animation(
                    .easeInOut(duration: 0.85)
                        .repeatForever(autoreverses: true),
                    value: isPulsing
                )
                .accessibilityLabel("شعار زادي")
        }
        .onAppear {
            isPulsing = true
            isBackgroundLight = true
        }
    }
}

#Preview {
    SplashView()
}
