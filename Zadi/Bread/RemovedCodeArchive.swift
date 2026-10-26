// Bread cleanup review — 2026-10-26
// All removed or replaced source blocks are preserved below as comments.
// Nothing in this file executes. Teammate files were not edited.

// MARK: - 1. Bread/Components/FoodPopups.swift
// Unused girl-only illustration map; current popup uses shared character/mood assets.
// Original occurrences replaced: 1
//     var characterImage: String {
//         switch self {
//         case .chocolate: return "Girl thinking"
//         case .cheese: return "Girl Approval"
//         case .egg: return "Girl Celebrate"
//         case .chicken: return "Girl Approval"
//         case .turkey: return "Girl Wink"
//         case .lettuce: return "Girl Happy"
//         case .tomato: return "Girl Excited"
//         case .cucumber: return "Girl Happy"
//         case .banana: return "Girl Celebrate"
//         case .strawberry: return "Girl Excited"
//         case .apple: return "Girl Wink"
//         }
//     }
//     
//     
// 

// MARK: - 2. Bread/Components/FoodPopups.swift
// Unused IngredientBenefitPopup, ChocolatePopup and obsolete preview; current UI uses BreadCoachPopup.
// Original occurrences replaced: 1
// // MARK: - Ingredient Popup
// // ToastView decides which message appears; this view only presents it.
// struct IngredientBenefitPopup: View {
//     let benefit: IngredientBenefit
//     @Environment(\.accessibilityReduceMotion) private var reduceMotion
//     // Grow the message font with the user's preferred text size.
//     @ScaledMetric(relativeTo: .title3) private var messageSize: CGFloat = 21
// 
//     private let cream = Color(red: 1, green: 240.0 / 255, blue: 217.0 / 255)
//     private let ink = Color(red: 0.20, green: 0.28, blue: 0.55)
// 
//     var body: some View {
//         // Keep the companion at the physical left edge; only the message uses Arabic reading direction.
//         GeometryReader { geometry in
//             let bubbleWidth = min(310, max(240, geometry.size.width * 0.26))
//             let girlHeight = min(325, geometry.size.height * 0.40)
// 
//             ScrollView {
//                 VStack(alignment: .leading, spacing: 0) {
//                     VStack(spacing: 16) {
//                         Text(benefit.message)
//                             .font(.system(size: messageSize, weight: .semibold))
//                             .foregroundStyle(ink)
//                             .multilineTextAlignment(.center)
//                             .lineSpacing(4)
//                             .fixedSize(horizontal: false, vertical: true)
// 
//                     }
//                     .padding(20)
//                     .frame(width: bubbleWidth)
//                     .background(cream, in: RoundedRectangle(cornerRadius: 26))
//                     .shadow(color: .black.opacity(0.10), radius: 6, y: 3)
//                     .environment(\.layoutDirection, .rightToLeft)
//                     .padding(.leading, 24)
// 
//                     // Small circles make the message look like a thought bubble.
//                     VStack(spacing: 5) {
//                         Circle().frame(width: 16, height: 16)
//                             .offset(x: 10)
//                         Circle().frame(width: 10, height: 10)
//                     }
//                     .foregroundStyle(cream)
//                     .padding(.leading, girlHeight * 0.62)
//                     .padding(.vertical, 6)
//                     .accessibilityHidden(true)
// 
//                     Image(benefit.characterImage)
//                         .resizable()
//                         .scaledToFit()
//                         .frame(height: girlHeight, alignment: .bottom)
//                         // Hide the illustration's cut edge just below the screen.
//                         .offset(y: girlHeight * 0.07)
//                         .accessibilityHidden(true)
//                 }
//                 .padding(.horizontal, 12)
//                 .padding(.top, 12)
//                 .frame(minHeight: geometry.size.height, alignment: .bottomLeading)
//             }
//             .scrollIndicators(.hidden)
//             .clipped()
//             .frame(width: min(geometry.size.width, bubbleWidth + 48))
//         }
//         .ignoresSafeArea(edges: .bottom)
//         .environment(\.layoutDirection, .leftToRight)
//         .accessibilityElement(children: .contain)
//         // Use a fade instead of movement when Reduce Motion is enabled.
//         .transition(reduceMotion ? .opacity : .offset(y: 24).combined(with: .opacity))
//     }
// }
// 
// // MARK: - Chocolate Popup
// struct ChocolatePopup: View {
//     var body: some View {
//         IngredientBenefitPopup(benefit: .chocolate)
//     }
// }
// 
// 
// // MARK: - Preview
// #Preview("Ingredient benefit", traits: .landscapeLeft) {
//     IngredientBenefitPopup(benefit: .strawberry)
// }
// 

// MARK: - 3. Bread/Components/FoodPopups.swift
// Update comment after removing the obsolete illustration mapping.
// Original occurrences replaced: 1
// // Keep the text and matching illustration together for each ingredient.

// MARK: - 4. Bread/Components/FoodPopups.swift
// Reuse ingredient definitions without assuming image names equal benefit IDs.
// Original occurrences replaced: 1
//         let title = ToastBase(rawValue: rawValue)?.title
//             ?? ToastProtein(rawValue: rawValue)?.title
//             ?? ToastVegetable(rawValue: rawValue)?.title
//             ?? ToastFruit(rawValue: rawValue)?.title
//             ?? rawValue
//         return Food(id: rawValue, arabicName: title, icon: rawValue,
//                     isHealthy: self != .chocolate, voice: message)

// MARK: - 5. Bread/App/ToastMain.swift
// Move Bread's small policy adapter beside its ingredient data; reuse shared Coach for encouragement.
// Original occurrences replaced: 1
//     private func react(to benefit: IngredientBenefit, added: Bool) {
//         let reaction = Coach.react(to: benefit.coachFood, added: added, selected: selectedFoods)
//         // Ingredient taps are encouragement, never a declaration that the recipe is finished.
//         if added && benefit == .chocolate {
//             coachMessage = CoachMessage(mood: .thinking, text: "دعنا نفكر", voice: benefit.message)
//         } else if reaction?.mood == .eating {
//             coachMessage = added
//                 ? CoachMessage(mood: .excited, text: "اجل هذا اختيار رائع!!", voice: benefit.message)
//                 : nil
//         } else {
//             coachMessage = reaction
//         }
//         activeBenefit = added ? benefit : nil
//     }
// 
// 

// MARK: - 6. Bread/Pages/ToastPages.swift
// Move already-disabled heading code into the review archive.
// Original occurrences replaced: 1
//            /* Text("ماذا تريد أن تضيف إلى شطيرتك؟")
//                 .font(.system(size: 23, weight: .bold))
//                 .foregroundStyle(.black)
//                 .multilineTextAlignment(.center)
//                 .padding(.horizontal, 16)*/
// 
// 

// MARK: - 7. Bread/Pages/ToastPages.swift
// Move already-disabled heading code into the review archive.
// Original occurrences replaced: 1
//           /*  Text("اختر ما تريد إضافته")
//                 .font(.system(size: 23, weight: .bold))
//                 .foregroundStyle(.black)
//                 .multilineTextAlignment(.center)
//                 .padding(.horizontal, 16)*/
// 
// 

// MARK: - 8. Bread/Pages/ToastPages.swift
// Move already-disabled heading code into the review archive.
// Original occurrences replaced: 1
//           /*  Text("أضف ما تحب إلى شطيرتك!")
//                 .font(.system(size: 23, weight: .bold))
//                 .foregroundStyle(.black)
//                 .multilineTextAlignment(.center)
//                 .padding(.horizontal, 16)*/
// 
// 

// MARK: - 9. Bread/Pages/ToastPages.swift
// Both Next buttons now use one shared Bread component.
// Original occurrences replaced: 2
//             Button(action: next) {
//                 Text("التالي")
//                     .font(.system(size: 19, weight: .bold))
//                     .foregroundStyle(.white)
//                     .padding(.horizontal, 34)
//                     .padding(.vertical, 12)
//                     .background(Color(red: 0.05, green: 0.78, blue: 0.28), in: Capsule())
//             }
//             .buttonStyle(.plain)

// MARK: - 10. Bread/Pages/ToastPages.swift
// Reuse the same button appearance for Finish; disabled state stays on the caller.
// Original occurrences replaced: 1
//             Button(action: finish) {
//                 Text("انتهيت!")
//                     .font(.system(size: 19, weight: .bold))
//                     .foregroundStyle(.white)
//                     .padding(.horizontal, 34)
//                     .padding(.vertical, 12)
//                     .background(Color(red: 0.05, green: 0.78, blue: 0.28))
//                     .clipShape(Capsule())
//             }
//             .buttonStyle(.plain)

// MARK: - 11. Bread/Pages/ToastPages.swift
// Remove unused width input; these two pages use fixed-size FoodCardLabel.
// Original occurrences replaced: 1
// struct BaseSelectionPage: View {
//     let buttonWidth: CGFloat

// MARK: - 12. Bread/Pages/ToastPages.swift
// Remove unused argument from the corresponding preview.
// Original occurrences replaced: 1
// BaseSelectionPage(buttonWidth: 105,

// MARK: - 13. Bread/Pages/ToastPages.swift
// Remove unused width input; these two pages use fixed-size FoodCardLabel.
// Original occurrences replaced: 1
// struct ProteinSelectionPage: View {
//     let buttonWidth: CGFloat

// MARK: - 14. Bread/Pages/ToastPages.swift
// Remove unused argument from the corresponding preview.
// Original occurrences replaced: 1
// ProteinSelectionPage(buttonWidth: 105,

// MARK: - 15. Bread/App/ToastMain.swift
// Remove unused width argument.
// Original occurrences replaced: 1
// BaseSelectionPage(buttonWidth: buttonWidth, selectedBase: selectedBase,

// MARK: - 16. Bread/App/ToastMain.swift
// Remove unused width argument.
// Original occurrences replaced: 1
//                     buttonWidth: buttonWidth, selectedProtein: selectedProtein,

// MARK: - Second cleanup: shared ingredient controls and unused popup identity
// Original replaced/removed blocks follow. Teammate code was not changed.

// Source: Models/FoodIngredients.swift (previous lines 6–6)
// enum ToastBase: String, CaseIterable, Identifiable {

// Source: Models/FoodIngredients.swift (previous lines 9–11)
//
//     // rawValue is the case name as a String, matching this ingredient's identity.
//     var id: String { rawValue }

// Source: Models/FoodIngredients.swift (previous lines 19–20)
//
//     var icon: String { rawValue }

// Source: Models/FoodIngredients.swift (previous lines 46–46)
// enum ToastProtein: String, CaseIterable, Identifiable {

// Source: Models/FoodIngredients.swift (previous lines 50–51)
//
//     var id: String { rawValue }

// Source: Models/FoodIngredients.swift (previous lines 61–62)
//     var icon: String { rawValue }
//

// Source: Models/FoodIngredients.swift (previous lines 67–67)
// enum ToastVegetable: String, CaseIterable, Identifiable {

// Source: Models/FoodIngredients.swift (previous lines 71–72)
//
//     var id: String { rawValue }

// Source: Models/FoodIngredients.swift (previous lines 81–82)
//
//     var icon: String { rawValue }

// Source: Models/FoodIngredients.swift (previous lines 111–111)
// enum ToastFruit: String, CaseIterable, Identifiable {

// Source: Models/FoodIngredients.swift (previous lines 115–116)
//
//     var id: String { rawValue }

// Source: Models/FoodIngredients.swift (previous lines 125–126)
//
//     var icon: String { rawValue }

// Source: Pages/ToastPages.swift (previous lines 3–7)
// // MARK: - Spread Selection
// // Pages receive selections and action closures from ToastView, which owns the recipe.
// struct BaseSelectionPage: View {
//     let selectedBase: ToastBase?
//     let chooseBase: (ToastBase) -> Void

// Source: Pages/ToastPages.swift (previous lines 10–10)
//     // MARK: - UI

// Source: Pages/ToastPages.swift (previous lines 13–21)
//             HStack(spacing: 18) {
//                 ForEach(ToastBase.allCases) { food in
//                     FoodChoiceButton(title: food.title, image: food.icon,
//                                      selected: selectedBase == food) {
//                         chooseBase(food)
//                     }
//                 }
//             }
//

// Source: Pages/ToastPages.swift (previous lines 27–28)
// // MARK: - Spread Preview
// // Empty closures let previews show sample selections without changing a real recipe.

// Source: Pages/ToastPages.swift (previous lines 30–30)
//     BaseSelectionPage( selectedBase: .cheese, chooseBase: { _ in }, next: {})

// Source: Pages/ToastPages.swift (previous lines 34–57)
// // MARK: - Protein Selection
// struct ProteinSelectionPage: View {
//     let selectedProtein: ToastProtein?
//     let chooseProtein: (ToastProtein) -> Void
//     let next: () -> Void
//
//     // MARK: - UI
//     var body: some View {
//         VStack(spacing: 16) {
//             HStack(spacing: 18) {
//                 ForEach(ToastProtein.allCases) { food in
//                     FoodChoiceButton(title: food.title, image: food.icon,
//                                      selected: selectedProtein == food) {
//                         chooseProtein(food)
//                     }
//                 }
//             }
//
//             BreadActionButton(title: "التالي", action: next)
//         }
//     }
// }
//
// // MARK: - Protein Preview

// Source: Pages/ToastPages.swift (previous lines 59–59)
//     ProteinSelectionPage( selectedProtein: .egg, chooseProtein: { _ in }, next: {})

// Source: Pages/ToastPages.swift (previous lines 96–111)
//             HStack(spacing: 18) {
//                 if displaysFruits {
//                     ForEach(ToastFruit.allCases) { fruit in
//                         FoodChoiceButton(title: fruit.title, image: fruit.icon,
//                                          selected: selectedFruits.contains(fruit)) {
//                             toggleFruit(fruit)
//                         }
//                     }
//                 } else {
//                     ForEach(ToastVegetable.allCases) { vegetable in
//                         FoodChoiceButton(title: vegetable.title, image: vegetable.icon,
//                                          selected: selectedVegetables.contains(vegetable)) {
//                             toggleVegetable(vegetable)
//                         }
//                     }
//                 }

// Source: App/ToastMain.swift (previous lines 53–54)
//                 BaseSelectionPage(selectedBase: selectedBase,
//                                   chooseBase: chooseBase, next: advance)

// Source: App/ToastMain.swift (previous lines 56–57)
//                 ProteinSelectionPage(
//                     selectedProtein: selectedProtein,

// Source: App/ToastMain.swift (previous lines 59–59)
//                     chooseProtein: { protein in

// Source: Components/FoodPopups.swift (previous lines 5–5)
// enum IngredientBenefit: String, Identifiable {

// Source: Components/FoodPopups.swift (previous lines 17–18)
//     
//     var id: String { rawValue }
