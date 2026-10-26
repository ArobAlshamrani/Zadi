// BreadRemovedCode.swift
// Archive of code removed from the Bread section. Comments only: nothing here compiles or runs.
// Teammate files were not edited.
//
// PART 1: Earlier cleanup, copied word for word from RemovedCodeArchive.swift.
// PART 2: Reuse cleanup (added below, one step at a time).

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

// MARK: - PART 2: Reuse cleanup

// MARK: - P2-1. Bread/Components/ToastDesign.swift — bread layer centering
// Removed: breadLayer(size:) and its call. Same centering math as SpreadLayer, so both now use
// one private helper, SandwichView.centeredArtwork(_:canvas:bounds:scale:).
// scaleX and scaleY were always equal (both reduce to size / bounds.width), so one scale replaces them.
// No teammate component replaces this: it was a Bread-only duplicate.
// Original call (previous line 104):
//             breadLayer(size: size)
// Original helper (previous lines 152–170):
//     // Center the visible bread rather than the PNG canvas, which includes uneven transparent margins.
//     private func breadLayer(size: CGFloat) -> some View {
//         let canvas = ToastArtwork.breadCanvas
//         let bounds = ToastArtwork.breadBounds
// 
//         let breadWidth = size
//         let breadHeight = size * bounds.height / bounds.width
//         let scaleX = breadWidth / bounds.width
//         let scaleY = breadHeight / bounds.height
// 
//         return Image("toast")
//             .resizable()
//             .frame(width: canvas.width * scaleX, height: canvas.height * scaleY)
//             .offset(
//                 x: (canvas.width / 2 - bounds.midX) * scaleX,
//                 y: (canvas.height / 2 - bounds.midY) * scaleY
//             )
//             .frame(width: size, height: size)
//     }

// MARK: - P2-2. Bread/Components/ToastDesign.swift — spread layer centering
// Removed: SpreadLayer view and its call. Replaced by the same SandwichView.centeredArtwork helper
// with the identical scale formula. The .offset, .id, .zIndex and .transition modifiers are unchanged.
// No teammate component replaces this: it was a Bread-only duplicate.
// Original call (previous line 109):
//                 SpreadLayer(base: base, size: size)
// Original view (previous lines 197–218):
// // MARK: - Spread Artwork
// // Use visible artwork bounds so transparent margins do not make the spread look off-center.
// private struct SpreadLayer: View {
//     let base: ToastBase
//     let size: CGFloat
// 
//     // MARK: - UI
//     var body: some View {
//         let canvas = base.canvasSize
//         let bounds = base.artworkBounds
//         let scale = size * base.spreadScale / max(bounds.width, bounds.height)
// 
//         Image(base.toppingImage)
//             .resizable()
//             .frame(width: canvas.width * scale, height: canvas.height * scale)
//             .offset(
//                 x: (canvas.width / 2 - bounds.midX) * scale,
//                 y: (canvas.height / 2 - bounds.midY) * scale
//             )
//             .frame(width: size, height: size)
//     }
// }

// MARK: - P2-3. Bread/Components/ToastDesign.swift — fruit image modifiers
// Removed: the fruit layer's own Image/resizable/scaledToFit/frame chain. It repeated the existing
// SandwichView.topping(_:size:) helper (same modifiers, same order), which vegetables already use.
// Replacement: topping(fruit.piecesImage, size: size * fruit.scale). Rotation, offset, zIndex,
// transition and the if !selectedFruits.isEmpty wrapper are unchanged.
// No teammate component replaces this: it was a Bread-only duplicate.
// Original code (previous lines 137–140, checkpoint 83e09b8 lines 134–137):
//                     Image(fruit.piecesImage)
//                         .resizable()
//                         .scaledToFit()
//                         .frame(width: size * fruit.scale, height: size * fruit.scale)

// MARK: - P2-4. Bread/Pages/FoodSelectionPage.swift — MealSelectionButton
// Removed: MealSelectionButton. It duplicated FoodChoiceButton (Button + FoodCardLabel + .plain +
// accessibility label) with selected always false. Replaced by Bread's FoodChoiceButton, whose
// selected now defaults to false. Titles stay localizable: Text("خبز") uses LocalizedStringKey.
// No teammate component replaces this: both buttons are Bread code.
// Original struct (previous lines 138–150):
// private struct MealSelectionButton: View {
//     let title: LocalizedStringResource
//     let image: String
//     let action: () -> Void
// 
//     var body: some View {
//         Button(action: action) {
//             FoodCardLabel(title: Text(title), image: image)
//         }
//         .buttonStyle(.plain)
//         .accessibilityLabel(Text(title))
//     }
// }
// Original call sites (previous lines 94–105), now FoodChoiceButton(title: Text("…"), …):
//                                 MealSelectionButton(title: "خبز", image: "Bread") {
//                                     showsToast = true
//                                 }
//                                 MealSelectionButton(title: "بانكيك", image: "Pancake") {
//                                     showsPancake = true
//                                 }
//                                 MealSelectionButton(title: "وجبات خفيفة", image: "popcorn") {
//                                     // This meal will be connected when its screen is available.
//                                 }
//                                 MealSelectionButton(title: "أرز", image: "RiceBowl") {
//                                     showsRice = true
//                                 }

// MARK: - P2-5. Bread/Components/FoodButtons.swift — FoodChoiceButton title and selected
// Replaced: title is now Text (so meal titles keep localization) and selected defaults to false
// (so meal cards need not pass it). The label is passed straight to FoodCardLabel and accessibilityLabel.
// Original lines (previous lines 38–40 and 45):
//     let title: String
//     let image: String
//     let selected: Bool
//             FoodCardLabel(title: Text(title), image: image, selected: selected)

// MARK: - P2-6. Bread/Pages/ToastPages.swift — FoodChoiceButton call
// Replaced: the ingredient title is wrapped in Text(...) for the new title type.
// Text(String) shows the string verbatim, exactly as FoodChoiceButton did before.
// Original line (previous line 12):
//                 FoodChoiceButton(title: food.title, image: food.icon,

// MARK: - P2-7. Back buttons → CircleBackButton (Bread/Components/FoodButtons.swift)
// The same chevron-in-a-circle button was written out 4 times in Bread. The teammates' only back
// button (inline in Features/MissionView.swift, lines 161–187) is not a callable view, so it cannot be
// reused without editing their file. CircleBackButton copies that MissionView design exactly; each
// caller keeps its own position, action and accessibility label. MissionView.swift was not modified.
// Approved visual change: Pancake/Rice back buttons gain the gray-blue color and shadow; the
// Food Selection back button gains the shadow. The Toast back button looks the same.

// P2-7a. Original from Bread/Components/ToastDesign.swift (previous lines 65–81):
//                 if showsBackButton {
//                     Button(action: goBack) {
//                         Image(systemName: "chevron.left")
//                             .font(.system(size: 22, weight: .bold))
//                             .foregroundStyle(Color(red: 0.30, green: 0.40, blue: 0.55))
//                             .frame(width: 52, height: 52)
//                             .background(.white.opacity(0.85), in: Circle())
//                             .shadow(color: .black.opacity(0.12), radius: 5, y: 3)
//                     }
//                     .buttonStyle(.plain)
//                     .position(
//                         x: max(geometry.safeAreaInsets.leading + 34, width * 0.055),
//                         y: max(geometry.safeAreaInsets.top + 34, height * 0.09)
//                     )
//                     .zIndex(100)
//                     .accessibilityLabel(backLabel)
//                 }

// P2-7b. Original from Bread/Pages/FoodSelectionPage.swift — Pancake back (previous lines 25–37):
//                 .overlay(alignment: .topLeading) {
//                     Button {
//                         showsPancake = false
//                     } label: {
//                         Image(systemName: "chevron.left")
//                             .font(.system(size: 22, weight: .bold))
//                             .frame(width: 52, height: 52)
//                             .background(.white.opacity(0.85), in: Circle())
//                     }
//                     .buttonStyle(.plain)
//                     .padding(24)
//                     .accessibilityLabel("الرجوع لاختيار الوجبة")
//                 }

// P2-7c. Original from Bread/Pages/FoodSelectionPage.swift — Rice back (previous lines 47–59):
//                     .overlay(alignment: .topLeading) {
//                         Button {
//                             showsRice = false
//                         } label: {
//                             Image(systemName: "chevron.left")
//                                 .font(.system(size: 22, weight: .bold))
//                                 .frame(width: 52, height: 52)
//                                 .background(.white.opacity(0.85), in: Circle())
//                         }
//                         .buttonStyle(.plain)
//                         .padding(24)
//                         .accessibilityLabel("الرجوع لاختيار الوجبة")
//                     }

// P2-7d. Original from Bread/Pages/FoodSelectionPage.swift — back to Mission (previous lines 116–130):
//                 .overlay(alignment: .topLeading) {
//                     Button {
//                         dismiss()
//                     } label: {
//                         Image(systemName: "chevron.left")
//                             .font(.system(size: 22, weight: .bold))
//                             .foregroundStyle(Color(red: 0.30, green: 0.40, blue: 0.55))
//                             .frame(width: 52, height: 52)
//                             .background(.white.opacity(0.85), in: Circle())
//                     }
//                     .buttonStyle(.plain)
//                     .padding(.leading, max(geometry.safeAreaInsets.leading + 8, width * 0.055 - 26))
//                     .padding(.top, max(geometry.safeAreaInsets.top + 8, height * 0.09 - 26))
//                     .accessibilityLabel("الرجوع لنبدأ")
//                 }

// MARK: - P2-8. Bread/Components/FoodPopups.swift — coachReaction(added:selected:)
// Replaced: added ingredients now get their own short text and face from the new
// IngredientBenefit.addedReaction list (chocolate: .thinking; others: .thumbsUp / .strong /
// .overjoyed / .yummy — moods added to the teammate's Mood enum, CharacterCoach.swift).
// Before, every healthy ingredient showed the same Coach text "اجل هذا اختيار رائع!!" and chocolate
// showed "دعنا نفكر". Removals still use the teammate's Coach.react with the same result (verified:
// 77 removal cases identical before and after). The long benefit messages and audio are unchanged.
// Original function (previous lines 112–124):
//     func coachReaction(added: Bool, selected: [Food]) -> CoachMessage? {
//         let food = coachFood
//         let reaction = Coach.react(to: food, added: added, selected: selected)
//         if added && self == .chocolate {
//             return CoachMessage(mood: .thinking, text: "دعنا نفكر", voice: message)
//         }
//         // Ingredient taps must not declare the recipe complete. Ask the shared coach
//         // for its single-ingredient encouragement instead of copying that message.
//         if reaction?.mood == .eating {
//             return added ? Coach.react(to: food, added: true, selected: [food]) : nil
//         }
//         return reaction
//     }

// MARK: - P2-9. Bread/Components/FoodPopups.swift — BreadCoachPopup, BreadSpeechTail and previews
// Removed: Bread's own copy of the coach popup (character image + speech bubble with a tail).
// Replaced by the teammate's CharacterView (Features/CharacterCoach.swift), reused unchanged and
// placed in ToastView's overlay the same way PancakePlateView places it (scaled, 14% / 87%).
// CharacterView shows the same "\(character)_\(mood)" images, so the approved short messages and
// boy/girl expressions are unchanged. Audio is unaffected: neither view plays sound.
// Original code (previous lines 140–207), deleted only after this copy was saved:
// // Bread-specific placement; the coach and popup remain unchanged.
// struct BreadCoachPopup: View {
//     let character: String
//     let message: CoachMessage
// 
//     var body: some View {
//         GeometryReader { geometry in
//             let characterWidth = min(260, geometry.size.width * 0.19)
//             let characterHeight = min(320, geometry.size.height * 0.38)
//             let bubbleWidth = min(220, geometry.size.width * 0.16)
// 
//             ZStack(alignment: .bottomLeading) {
//                 Image("\(character)_\(message.mood.rawValue)")
//                     .resizable()
//                     .scaledToFit()
//                     .frame(width: characterWidth, height: characterHeight, alignment: .bottom)
//                     // The portraits end at the torso. Seat that edge at the screen edge.
//                     .offset(y: 28)
//                     .accessibilityHidden(true)
// 
//                 Text(message.text)
//                     .font(.system(size: 20, weight: .bold, design: .rounded))
//                     .foregroundStyle(Color(white: 0.25))
//                     .multilineTextAlignment(.center)
//                     .fixedSize(horizontal: false, vertical: true)
//                     .padding(.horizontal, 24)
//                     .padding(.vertical, 16)
//                     .frame(width: bubbleWidth)
//                     .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 26))
//                     .overlay(alignment: .bottomLeading) {
//                         BreadSpeechTail()
//                             .fill(.white.opacity(0.92))
//                             .frame(width: 44, height: 38)
//                             .offset(x: 12, y: 37)
//                     }
//                     .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
//                     .offset(x: characterWidth * 0.70, y: -characterHeight * 0.42)
//             }
//             .animation(.spring, value: message.text)
//             .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
//         }
//         .ignoresSafeArea(edges: .bottom)
//         .environment(\.layoutDirection, .leftToRight)
//     }
// }
// 
// private struct BreadSpeechTail: Shape {
//     func path(in rect: CGRect) -> Path {
//         Path { path in
//             path.move(to: CGPoint(x: rect.width * 0.35, y: 0))
//             path.addLine(to: CGPoint(x: 0, y: rect.height))
//             path.addLine(to: CGPoint(x: rect.width, y: 0))
//             path.closeSubpath()
//         }
//     }
// }
// 
// #Preview("Bread coach girl", traits: .landscapeLeft) {
//     BreadCoachPopup(character: "girl", message: CoachMessage(
//         mood: .thinking, text: "حسنا دعنا نفكر للحظة...", voice: ""))
//         .background(Color.gray.opacity(0.15))
// }
// 
// #Preview("Bread coach boy", traits: .landscapeLeft) {
//     BreadCoachPopup(character: "boy", message: CoachMessage(
//         mood: .excited, text: "اجل هذا اختيار رائع!!", voice: ""))
//         .background(Color.gray.opacity(0.15))
// }

// MARK: - P2-10. Bread/App/ToastMain.swift — popup overlay
// Replaced: the overlay now shows the teammate's CharacterView (same placement as PancakePlateView)
// instead of BreadCoachPopup. Visibility rule is unchanged: shown only when coachMessage exists and
// the recipe is not finished; taps still pass through (allowsHitTesting(false)).
// Original overlay (previous lines 102–108):
//         .overlay(alignment: .bottomLeading) {
//             if let coachMessage, step != .finished {
//                 BreadCoachPopup(character: character, message: coachMessage)
//                     .allowsHitTesting(false)
//                     .zIndex(200)
//             }
//         }

// MARK: - Archived IngredientBenefit.message
// Bread uses short popup reactions and prerecorded MP3s; this long text is no longer used.
//     // Keep the full benefit text for the coach; the bubble uses the shorter text below.
//     // Bread plays MP3s chosen by IngredientAudio, rather than reading this text aloud.
//     var message: String {
//         switch self {
//         case .chocolate:
//             return "الشوكولاتة لذيذة! لكن جسمنا يحتاج إلى أطعمة متنوعة ليبقى قويًا. ما رأيك أن نضيف بعض الفواكه؟"
//             
//         case .cheese:
//             return "الجبن يمنحنا الكالسيوم الذي يساعد على تقوية عظامنا وأسناننا!"
//             
//         case .egg:
//             return "البيض مليء بالبروتين الذي يساعد على بناء عضلاتنا!"
//             
//         case .chicken:
//             return "الدجاج يمنح عضلاتنا ما تحتاجه لنلعب ونتحرك بنشاط!"
//             
//         case .turkey:
//             return "الديك الرومي مصدر للبروتين الذي يساعد جسمنا على إصلاح خلاياه وتجديدها!"
//             
//         case .lettuce:
//             return "الخس يساعدنا على هضم الطعام بسهولة!"
//             
//         case .tomato:
//             return "الطماطم تحتوي على فيتامين ج، الذي يساعد جسمنا على الاستفادة من الحديد الموجود في الطعام!"
//             
//         case .cucumber:
//             return "الخيار يحتوي على فيتامين ك، الذي يساعد على الحفاظ على صحة عظامنا!"
//             
//         case .banana:
//             return "الموز يمنحنا طاقة للعب والقفز!"
//             
//         case .strawberry:
//             return "الفراولة تحتوي على فيتامين ج، الذي يساعد جسمنا على مقاومة الأمراض!"
//             
//         case .apple:
//             return "التفاح يحتوي على مواد مفيدة تساعد على حماية خلايا جسمنا!"
//         }
//     }
// 
