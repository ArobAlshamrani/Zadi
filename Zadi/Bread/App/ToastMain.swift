import SwiftUI

// Owns the recipe so selections stay available when pages change.
struct ToastView: View {
    var returnToFoodSelection: (() -> Void)? = nil
    // MARK: - State
    // @State keeps values between view updates and refreshes the UI when they change.
    // The ? makes a selection optional: nil means nothing is selected.
    @State private var selectedBase: ToastBase?
    @State private var selectedProtein: ToastProtein?
    // Sets allow several toppings without storing duplicates.
    @State private var selectedVegetables: Set<ToastVegetable> = []
    @State private var selectedFruits: Set<ToastFruit> = []
    @State private var step: ToastStep = .base
    // Adding an ingredient sets its message; deselecting one clears the popup.
    @State private var activeBenefit: IngredientBenefit?
    // Keep one audio manager for this screen; create it only when needed.
    @State private var ingredientAudio: IngredientAudio?
    @Environment(\.scenePhase) private var scenePhase
    // @Environment reads a system setting instead of storing our own copy.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Computed Properties
    // Computed properties derive values from current selections instead of storing extra state.
    private var canFinish: Bool {
        selectedBase != nil || selectedProtein != nil
            || !selectedFruits.isEmpty || !selectedVegetables.isEmpty
    }

    private var backLabel: String {
        step == .toppings && selectedBase != .chocolate
            ? "الرجوع لاختيار البروتين"
            : "الرجوع لاختيار الشوكولاتة أو الجبن"
    }

    // MARK: - UI
    var body: some View {
        ToastPageLayout(
            showsBackButton: step == .protein || step == .toppings
                || (step == .base && returnToFoodSelection != nil),
            backLabel: step == .base ? "الرجوع لاختيار الوجبة" : backLabel,
            goBack: goBack
        ) { size in
            SandwichView(size: size, selectedBase: selectedBase,
                         selectedProtein: selectedProtein,
                         selectedVegetables: selectedVegetables,
                         selectedFruits: selectedFruits)
        } content: { buttonWidth in
            switch step {
            case .base:
                BaseSelectionPage(buttonWidth: buttonWidth, selectedBase: selectedBase,
                                  chooseBase: chooseBase, next: advance)
            case .protein:
                ProteinSelectionPage(
                    buttonWidth: buttonWidth, selectedProtein: selectedProtein,
                    // This closure sends a tap back to the view that owns the recipe.
                    chooseProtein: { protein in
                        withAnimation {
                            selectedProtein = selectedProtein == protein ? nil : protein
                            // Protein starts the savory path, so earlier fruit choices no longer apply.
                            if selectedProtein != nil {
                                selectedFruits.removeAll()
                            }
                            activeBenefit = selectedProtein != nil ? protein.benefit : nil
                        }
                    },
                    next: advance
                )
            case .toppings:
                ToppingsSelectionPage(
                    buttonWidth: buttonWidth,
                    canFinish: canFinish,
                    selectedBase: selectedBase,
                    hasProtein: selectedProtein != nil,
                    selectedFruits: selectedFruits,
                    selectedVegetables: selectedVegetables,
                    toggleFruit: { fruit in
                        withAnimation(popupAnimation) {
                            selectedFruits.toggle(fruit)
                            activeBenefit = selectedFruits.contains(fruit) ? fruit.benefit : nil
                        }
                    },
                    toggleVegetable: { vegetable in
                        withAnimation(popupAnimation) {
                            selectedVegetables.toggle(vegetable)
                            activeBenefit = selectedVegetables.contains(vegetable) ? vegetable.benefit : nil
                        }
                    },
                    finish: {
                        guard canFinish else { return }
                        ingredientAudio?.stop()
                        withAnimation(.easeInOut(duration: 0.25)) { step = .finished }
                    }
                )
            case .finished:
                FinishedPage(restart: restart)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        // Keep the latest ingredient message visible until it is cleared or the recipe finishes.
        .overlay {
            if let activeBenefit, step != .finished {
                IngredientBenefitPopup(benefit: activeBenefit)
                    .id(activeBenefit)
                    // Let taps reach the ingredient cards beneath the popup.
                    .allowsHitTesting(false)
                    .zIndex(200)
            }
        }
        // React to selection changes, not every time SwiftUI redraws the popup.
        .onChange(of: activeBenefit) {
            playActiveRecording()
        }
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                ingredientAudio?.stop()
            }
        }
        .onDisappear {
            ingredientAudio?.stop()
        }
    }

    // MARK: - Audio
    private func playActiveRecording() {
        guard let activeBenefit, step != .finished, scenePhase == .active else {
            ingredientAudio?.stop()
            return
        }

        if ingredientAudio == nil {
            ingredientAudio = IngredientAudio()
        }
        ingredientAudio?.play(recording: activeBenefit.recordingName)
    }

    // MARK: - Animation
    // Respect Reduce Motion by avoiding the spring animation.
    private var popupAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.8)
    }

    // MARK: - Selection Logic
    // Toggle the spread and keep toppings compatible with the sweet or savory path.
    private func chooseBase(_ base: ToastBase) {
        withAnimation(popupAnimation) {
            selectedBase = selectedBase == base ? nil : base
            activeBenefit = selectedBase != nil ? base.benefit : nil
            // Chocolate pairs with fruit; cheese pairs with protein and vegetables.
            if selectedBase == .chocolate {
                selectedProtein = nil
                selectedVegetables.removeAll()
            } else if selectedBase == .cheese {
                selectedFruits.removeAll()
            }
        }
        // Chocolate goes straight to fruit because this recipe's sweet path has no protein step.
        if selectedBase == .chocolate {
            withAnimation(popupAnimation) {
                step = .toppings
            }
        }
    }

    // MARK: - Navigation
    private func advance() {
        ingredientAudio?.stop()
        withAnimation {
            switch step {
            case .base:
                step = selectedBase == .chocolate ? .toppings : .protein
            case .protein:
                step = .toppings
            case .toppings, .finished:
                break
            }
        }
    }

    // Follow the same sweet or savory path backward and clear the old ingredient message.
    private func goBack() {
        ingredientAudio?.stop()
        withAnimation {
            activeBenefit = nil
            switch step {
            case .protein:
                step = .base
            case .toppings:
                step = selectedBase == .chocolate ? .base : .protein
            case .base:
                returnToFoodSelection?()
            case .finished:
                break
            }
        }
    }

    // Start a fresh recipe, including the page and popup state.
    private func restart() {
        ingredientAudio?.stop()
        withAnimation {
            activeBenefit = nil
            selectedBase = nil
            selectedProtein = nil
            selectedVegetables.removeAll()
            selectedFruits.removeAll()
            step = .base
        }
    }
}



// MARK: - Helpers
private extension Set {
    // mutating lets this helper change the set: tap once to add, again to remove.
    mutating func toggle(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}

// MARK: - Preview
#Preview(traits: .landscapeLeft) {
    ToastView()
}


