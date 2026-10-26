import SwiftUI

// MARK: - Spread Selection
// Pages receive selections and action closures from ToastView, which owns the recipe.
struct BaseSelectionPage: View {
    let buttonWidth: CGFloat
    let selectedBase: ToastBase?
    let chooseBase: (ToastBase) -> Void
    let next: () -> Void

    // MARK: - UI
    var body: some View {
        VStack(spacing: 16) {
           /* Text("ماذا تريد أن تضيف إلى شطيرتك؟")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)*/

            HStack(spacing: 18) {
                ForEach(ToastBase.allCases) { food in
                    FoodChoiceButton(title: food.title, image: food.icon,
                                     selected: selectedBase == food) {
                        chooseBase(food)
                    }
                }
            }

            Button(action: next) {
                Text("التالي")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 34)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.05, green: 0.78, blue: 0.28), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Spread Preview
// Empty closures let previews show sample selections without changing a real recipe.
#Preview("1 — Spread selection") {
    BaseSelectionPage(buttonWidth: 105, selectedBase: .cheese, chooseBase: { _ in }, next: {})
        .environment(\.layoutDirection, .rightToLeft)
}

// MARK: - Protein Selection
struct ProteinSelectionPage: View {
    let buttonWidth: CGFloat
    let selectedProtein: ToastProtein?
    let chooseProtein: (ToastProtein) -> Void
    let next: () -> Void

    // MARK: - UI
    var body: some View {
        VStack(spacing: 16) {
          /*  Text("اختر ما تريد إضافته")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)*/

            HStack(spacing: 18) {
                ForEach(ToastProtein.allCases) { food in
                    FoodChoiceButton(title: food.title, image: food.icon,
                                     selected: selectedProtein == food) {
                        chooseProtein(food)
                    }
                }
            }

            Button(action: next) {
                Text("التالي")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 34)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.05, green: 0.78, blue: 0.28), in: Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Protein Preview
#Preview("2 — Protein selection") {
    ProteinSelectionPage(buttonWidth: 105, selectedProtein: .egg, chooseProtein: { _ in }, next: {})
        .environment(\.layoutDirection, .rightToLeft)
}

// MARK: - Topping Selection
struct ToppingsSelectionPage: View {
    let buttonWidth: CGFloat
    let canFinish: Bool
    let selectedBase: ToastBase?
    let hasProtein: Bool
    // This local state remembers the category for plain toast; recipe selections live in ToastView.
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
          /*  Text("أضف ما تحب إلى شطيرتك!")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)*/

            if selectedBase == nil && !hasProtein {
                // $ creates a binding so the picker can both read and update showsFruits.
                Picker("نوع الإضافات", selection: $showsFruits) {
                    Text("فواكه").tag(true)
                    Text("خضروات").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: buttonWidth * 3 + 36)
            }

            HStack(spacing: 18) {
                if displaysFruits {
                    ForEach(ToastFruit.allCases) { fruit in
                        FoodChoiceButton(title: fruit.title, image: fruit.icon,
                                         selected: selectedFruits.contains(fruit)) {
                            toggleFruit(fruit)
                        }
                    }
                } else {
                    ForEach(ToastVegetable.allCases) { vegetable in
                        FoodChoiceButton(title: vegetable.title, image: vegetable.icon,
                                         selected: selectedVegetables.contains(vegetable)) {
                            toggleVegetable(vegetable)
                        }
                    }
                }
            }

            Button(action: finish) {
                Text("انتهيت!")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 34)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.05, green: 0.78, blue: 0.28))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
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
