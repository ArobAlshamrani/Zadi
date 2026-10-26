
import SwiftUI

// MARK: - Return Home Action
private struct ReturnToHomeKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var returnToHome: () -> Void {
        get { self[ReturnToHomeKey.self] }
        set { self[ReturnToHomeKey.self] = newValue }
    }
}

// MARK: - Root View
struct RootView: View {

    @State private var showHome = false
    @State private var homeFlowID = UUID()

    var body: some View {
        ZStack {
            if showHome {
                HomeView()
                    .id(homeFlowID)
                    .environment(\.returnToHome) {
                        homeFlowID = UUID()
                    }
                    .transition(.opacity)
            } else {
                SplashView()
                    .transition(.opacity)
            }
        }
        .task {
            guard !showHome else { return }

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
