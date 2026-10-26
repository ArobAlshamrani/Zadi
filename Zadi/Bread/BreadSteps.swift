import SwiftUI

// MARK: - Shared Ingredient Controls
struct IngredientChoiceRow<Ingredient: BreadIngredient>: View {
    let ingredients: [Ingredient]
    let isSelected: (Ingredient) -> Bool
    // Send ingredient taps back to ToastView, where the recipe is stored.
    let choose: (Ingredient) -> Void

    var body: some View {
        HStack(spacing: 18) {
            ForEach(ingredients) { food in
                FoodChoiceButton(title: Text(food.title), image: food.icon,
                                 selected: isSelected(food)) {
                    choose(food)
                }
            }
        }
    }
}

// Spread and protein steps share their layout; ToastView owns their selections.
struct IngredientSelectionPage<Ingredient: BreadIngredient>: View {
    let ingredients: [Ingredient]
    let selected: Ingredient?
    let choose: (Ingredient) -> Void
    let next: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            IngredientChoiceRow(ingredients: ingredients,
                                isSelected: { selected == $0 }, choose: choose)
            BreadActionButton(title: "التالي", action: next)
        }
    }
}

#Preview("1 — Spread selection") {
    IngredientSelectionPage(ingredients: ToastBase.allCases,
                            selected: .cheese, choose: { _ in }, next: {})
        .environment(\.layoutDirection, .rightToLeft)
}

#Preview("2 — Protein selection") {
    IngredientSelectionPage(ingredients: ToastProtein.allCases,
                            selected: .egg, choose: { _ in }, next: {})
        .environment(\.layoutDirection, .rightToLeft)
}

// MARK: - Topping Selection
struct ToppingsSelectionPage: View {
    let buttonWidth: CGFloat
    let canFinish: Bool
    let selectedBase: ToastBase?
    let hasProtein: Bool
    // Remember the displayed category here; ToastView keeps the selected ingredients.
    @State private var showsFruits = true
    let selectedFruits: Set<ToastFruit>
    let selectedVegetables: Set<ToastVegetable>
    let toggleFruit: (ToastFruit) -> Void
    let toggleVegetable: (ToastVegetable) -> Void
    let finish: () -> Void

    // MARK: - Selection Logic
    // Plain toast can use either category. Chocolate uses fruit; cheese or protein uses vegetables.
    private var displaysFruits: Bool {
        !hasProtein && (selectedBase == .chocolate || (selectedBase == nil && showsFruits))
    }

    // MARK: - UI
    var body: some View {
        VStack(spacing: 16) {
            if selectedBase == nil && !hasProtein {
                // Without a spread or protein, let the child switch between fruit and vegetables.
                Picker("نوع الإضافات", selection: $showsFruits) {
                    Text("فواكه").tag(true)
                    Text("خضروات").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: buttonWidth * 3 + 36)
            }

            if displaysFruits {
                IngredientChoiceRow(ingredients: ToastFruit.allCases,
                                    isSelected: selectedFruits.contains, choose: toggleFruit)
            } else {
                IngredientChoiceRow(ingredients: ToastVegetable.allCases,
                                    isSelected: selectedVegetables.contains, choose: toggleVegetable)
            }

            BreadActionButton(title: "انتهيت!", action: finish)
            .disabled(!canFinish)
            .opacity(canFinish ? 1 : 0.5)
        }
    }
}

// MARK: - Topping Previews
#Preview("3 — Fruit selection") {
    ToppingsSelectionPage(
        buttonWidth: 105, canFinish: true, selectedBase: .chocolate,
        hasProtein: false, selectedFruits: [.apple], selectedVegetables: [],
        toggleFruit: { _ in }, toggleVegetable: { _ in }, finish: {}
    )
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("3 — Vegetable selection") {
    ToppingsSelectionPage(
        buttonWidth: 105, canFinish: true, selectedBase: .cheese,
        hasProtein: true, selectedFruits: [], selectedVegetables: [.lettuce],
        toggleFruit: { _ in }, toggleVegetable: { _ in }, finish: {}
    )
    .environment(\.layoutDirection, .rightToLeft)
}

// MARK: - Finished Recipe
struct FinishedPage: View {
    let restart: () -> Void

    // MARK: - UI
    var body: some View {
        VStack(spacing: 16) {

            Text("🎉 أحسنت!")
                .font(.system(size: 35, weight: .bold))
                .foregroundStyle(.black)

            Text("لقد صنعت شطيرتك!")
                .font(.system(size: 23))
                .foregroundStyle(.black)

            Button(action: restart) {
                Text("ابدأ من جديد")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 12)
                    .background(.blue)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

}

// MARK: - Finished Preview
#Preview("4 — Finished meal") {
    FinishedPage(restart: {})
        .environment(\.layoutDirection, .rightToLeft)
}
