
import SwiftUI

struct RootView: View {

    @State private var showHome = false

    var body: some View {
        ZStack {
            if showHome {
                HomeView()
                    .transition(.opacity)
            } else {
                SplashView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2))

            withAnimation(.easeInOut(duration: 0.5)) {
                showHome = true
            }
        }
    }
}

#Preview {
    RootView()
}
