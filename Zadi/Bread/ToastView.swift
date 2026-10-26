import SwiftUI

// Keep the selected ingredients here so they stay visible between steps.
struct ToastView: View {
    // FoodSelectionPage passes in the selected boy or girl.
    let character: String
    @State private var coachMessage: CoachMessage?
    var returnToFoodSelection: (() -> Void)? = nil
    // MARK: - State
    // Choose one spread and one protein; nil means that choice is empty.
    @State private var selectedBase: ToastBase?
    @State private var selectedProtein: ToastProtein?
    // Sets allow several toppings without storing duplicates.
    @State private var selectedVegetables: Set<ToastVegetable> = []
    @State private var selectedFruits: Set<ToastFruit> = []
    @State private var step: ToastStep = .base
    // Track the ingredient recording separately from the character's message.
    @State private var activeBenefit: IngredientBenefit?
    // Keep one audio manager for this screen; create it only when needed.
    @State private var ingredientAudio: IngredientAudio?
    @Environment(\.scenePhase) private var scenePhase
    // Use the device's Reduce Motion setting for the popup animation below.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Computed Properties
    // Allow finishing once at least one ingredient has been added.
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
            // Swap the step controls while keeping the same recipe and toast preview.
            switch step {
            case .base:
                IngredientSelectionPage(ingredients: ToastBase.allCases, selected: selectedBase,
                                        choose: chooseBase, next: advance)
            case .protein:
                IngredientSelectionPage(
                    ingredients: ToastProtein.allCases, selected: selectedProtein,
                    // This closure sends a tap back to the view that owns the recipe.
                    choose: { protein in
                        withAnimation {
                            selectedProtein = selectedProtein == protein ? nil : protein
                            // Protein starts the savory path, so earlier fruit choices no longer apply.
                            if selectedProtein != nil {
                                selectedFruits.removeAll()
                            }
                            react(to: protein.benefit, added: selectedProtein != nil)
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
                            react(to: fruit.benefit, added: selectedFruits.contains(fruit))
                        }
                    },
                    toggleVegetable: { vegetable in
                        withAnimation(popupAnimation) {
                            selectedVegetables.toggle(vegetable)
                            react(to: vegetable.benefit, added: selectedVegetables.contains(vegetable))
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
        // Reuse my teammate's CharacterView with the selected character and Bread's message.
        // Keep the same character scaling and placement as the Pancake screen.
        .overlay {
            if let coachMessage, step != .finished {
                GeometryReader { geometry in
                    let scale = min(geometry.size.width / 1194, geometry.size.height / 834)
                    CharacterView(character: character, message: coachMessage)
                        .scaleEffect(scale)
                        .position(x: geometry.size.width * 0.14, y: geometry.size.height * 0.87)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }
        // Play the recording when the ingredient changes, not when the view redraws.
        .onChange(of: activeBenefit) {
            playActiveRecording()
        }
        // Stop the recording when the app becomes inactive or this screen closes.
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                ingredientAudio?.stop()
            }
        }
        .onDisappear {
            ingredientAudio?.stop()
        }
    }

    // Convert the recipe into the Food values used by my teammate's coach rules.
    private var selectedFoods: [Food] {
        var benefits: [IngredientBenefit] = []
        if let selectedBase { benefits.append(selectedBase.benefit) }
        if let selectedProtein { benefits.append(selectedProtein.benefit) }
        benefits += ToastFruit.allCases.filter { selectedFruits.contains($0) }.map(\.benefit)
        benefits += ToastVegetable.allCases.filter { selectedVegetables.contains($0) }.map(\.benefit)
        return benefits.map(\.coachFood)
    }

    // Choose the message and expression, then update which recording should play.
    private func react(to benefit: IngredientBenefit, added: Bool) {
        coachMessage = benefit.coachReaction(added: added, selected: selectedFoods)
        activeBenefit = added ? benefit : nil
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
            // Chocolate pairs with fruit; cheese pairs with protein and vegetables.
            if selectedBase == .chocolate {
                selectedProtein = nil
                selectedVegetables.removeAll()
            } else if selectedBase == .cheese {
                selectedFruits.removeAll()
            }
            react(to: base.benefit, added: selectedBase != nil)
        }
        // Chocolate goes straight to fruit because this recipe's sweet path has no protein step.
        if selectedBase == .chocolate {
            withAnimation(popupAnimation) {
                step = .toppings
            }
        }
    }

    // MARK: - Navigation
    // Move through spread, protein, and toppings; chocolate skips the protein step.
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
            coachMessage = nil
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
            coachMessage = nil
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
    // Tap once to add a topping, then tap it again to remove it.
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
    ToastView(character: "girl")
}


