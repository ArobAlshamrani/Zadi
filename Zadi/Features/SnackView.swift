
import SwiftUI
// ONE view for the whole snack section.
// Stage 1: choose a snack  ->  Stage 2: snack on the placemat + suggestion card
// ->  Stage 3: combined food on the placemat + finish button.
struct SnackView: View {

    // MARK: - Settings from the rest of the app (both optional)
    var character = "boy"                 // "boy" or "girl" (CharacterCoach images)
    var onFinish: (() -> Void)? = nil     // runs when the child taps "انهاء الوجبة"
    var onBackToMeals: (() -> Void)? = nil

    // MARK: - Data (edit pictures and labels here only)
    struct Snack: Identifiable {
        let id: String
        let image: String           // Stage 1 card + Stage 2 placemat picture
        let title: String           // Stage 1 label
        // I leave these empty when the snack is ready without an addition.
        var additionImage: String? = nil
        var additionTitle: String? = nil
        var combinedImage: String? = nil
        // previous code here for reference.
        // let additionImage: String   // suggestion card picture
        // let additionTitle: String   // suggestion card label
        // let combinedImage: String   // Stage 3 placemat picture
    }

    static let snacks: [Snack] = [
        // I let apple finish on its own.
        Snack(id: "apple", image: "apple_slices", title: "تفاح"),
        // previous code here for reference.
        // Snack(id: "apple", image: "apple_slices", title: "تفاح",
        //       additionImage: "peanut_butter", additionTitle: "زبدة الفول السوداني",
        //       combinedImage: "apple_peanut_butter"),

        Snack(id: "candy", image: "candies", title: "حلوى",
              additionImage: "mixed_nuts", additionTitle: "مكسرات",
              combinedImage: "candies_nuts"),

        Snack(id: "chips", image: "chips", title: "بطاطس",
              additionImage: "yogurt_dip", additionTitle: "صوص الزبادي",
              combinedImage: "chips_dip"),

        Snack(id: "cookies", image: "cookies", title: "كوكيز",
              additionImage: "milk_cup", additionTitle: "حليب",
              combinedImage: "cookies_milk"),

        
        Snack(id: "popcorn", image: "popcorn", title: "فشار")
        // previous code here for reference.
        // Snack(id: "popcorn", image: "popcorn", title: "فشار",
        //       additionImage: "orange_juice", additionTitle: "عصير البرتقال",
        //       combinedImage: "popcorn_orange_juice")
    ]

    // MARK: - State
    @State private var selected: Snack?        // nil = Stage 1
    @State private var addedAddition = false   // true = Stage 3
    @State private var isShowingEnding = false
    @State private var returnToMealsAfterEnding = false
    @Environment(\.scenePhase) private var scenePhase
    private var stage: Int {
        guard let selected else { return 1 }
        // show the ready stage immediately when there is no suggested addition.
        return addedAddition || selected.additionImage == nil ? 3 : 2
    }
    // previous code here for reference.
    // private var stage: Int { selected == nil ? 1 : (addedAddition ? 3 : 2) }

    // MARK: - Screen
    var body: some View {
        GeometryReader { geo in
            let size = geo.size

            ZStack {
                // Full-screen background
                Image("BaseBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: size.height)
                    .clipped()

                
                if let snack = selected {
                    chosenStage(snack, size: size)
                }

                // Ready snacks keep all five choices visible below the selected artwork.
                // Snacks with additions continue to use their existing suggestion screen.
                if selected == nil || selected?.additionImage == nil {
                    choicesGrid(size: size)
                }
                // Previous selection replaced the cards for every snack:
                // if let snack = selected {
                //     chosenStage(snack, size: size)
                // } else {
                //     choicesGrid(size: size)
                // }

                // Share the approved character size, lowered baseline, and readable bubble.
                CharacterPresentation(
                    character: character,
                    message: selected.map {
                        Coach.snackReaction(id: $0.id, addedAddition: addedAddition)
                    },
                    mood: .thinking,
                    foodLayoutStyle: .foodPages
                )
                // Previous presentation:
                // CharacterPresentation(
                //     character: character,
                //     message: selected.map {
                //         Coach.snackReaction(id: $0.id, addedAddition: addedAddition)
                //     },
                //     mood: .thinking
                // )

                ZadiTopControls(
                    onBack: goBackFromSnack,
                    onSound: playSnackAudio
                )
                .zIndex(100)


            }
            .frame(width: size.width, height: size.height)
            .animation(.easeInOut(duration: 0.3), value: stage)
        }
        .ignoresSafeArea()
        .overlay {
            FoodActionRegion {
                // Apple and popcorn finish directly; other snacks require their existing addition.
                if let snack = selected, addedAddition || snack.additionImage == nil {
                    ZadiActionButton(title: "خلصت وجبتي!", icon: "checkmark.circle.fill") {
                        Coach.stopVoice()
                        isShowingEnding = true
                    }
                    .transition(.opacity)
                }
            }
            // Keep the original stage-change fade after moving Finish into the shared region.
            .animation(.easeInOut(duration: 0.3), value: stage)
        }
        .onDisappear {
            // The ending scene owns playback while it is presented.
            if !isShowingEnding {
                Coach.stopVoice()
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                Coach.stopVoice()
            }
        }
        // Positions stay fixed; Arabic text still reads right-to-left by itself.
        .environment(\.layoutDirection, .leftToRight)
        
        .fullScreenCover(
            isPresented: $isShowingEnding,
            onDismiss: {
                if returnToMealsAfterEnding {

                    returnToMealsAfterEnding = false
                    selected = nil
                    addedAddition = false

                    onFinish?()
                }
            }
        ) {
            if let snack = selected {

                ZadiMealEndingScene(
                    character: character,
                    //show the original snack when it has no combined artwork.
                    mealImage: snack.combinedImage ?? snack.image,
                    // previous code here for reference.
                    // mealImage: snack.combinedImage,
                    onAnotherMeal: {
                        Coach.stopVoice()
                        returnToMealsAfterEnding = true
                        isShowingEnding = false
                    },
                    onStartTask: {},
                    isSnack: true
                )
            }
        }

    }
    
    // MARK: - Shared Back Button
    private func goBackFromSnack() {

        Coach.stopVoice()

        if selected != nil {
            selected = nil
            addedAddition = false
        } else {
            if let onBackToMeals {
                onBackToMeals()
            } else {
                onFinish?()
            }
        }
    }

    // MARK: - Snack Recordings
    private func playSnackAudio() {
        IngredientVoice.shared.replayLast()
    }

    private func playSnackReaction() {
        guard scenePhase == .active, !isShowingEnding, let selected else {
            Coach.stopVoice()
            return
        }

        Coach.play(
            Coach.snackReaction(id: selected.id, addedAddition: addedAddition),
            character: character
        )
    }

    // MARK: - Stage 1: two cards above three
    private func choicesGrid(size: CGSize) -> some View {
        FoodCardGroup {
            ForEach(Self.snacks) { snack in
                // Highlight the current choice while allowing another snack to be selected.
                FoodChoiceButton(usesPressFeedback: true, title: Text(snack.title),
                                 image: snack.image, selected: selected?.id == snack.id) {
                    addedAddition = false
                    selected = snack
                    playSnackReaction()
                }
                // Previous card did not show a persistent selection:
                // FoodChoiceButton(usesPressFeedback: true, title: Text(snack.title), image: snack.image) {
                //     addedAddition = false
                //     selected = snack
                //     playSnackReaction()
                // }
            }
        }
        .environment(\.foodLayoutStyle, FoodLayoutStyle.responsive(to: size))
        .frame(width: FoodLayoutStyle.workspaceWidth(for: size))
        .position(x: size.width * 0.5, y: size.height * FoodLayoutStyle.rowCenterFraction)
        .transition(.opacity)
    }

    // Previous independent grid and card-row implementations are preserved below.
    //     // MARK: - Stage 1: five cards (3 on top, 2 centered below)
    //     private func choicesGrid(size: CGSize) -> some View {
    //
    //         let gap = min(18, size.width * 0.015)
    //
    //         let availableWidth = size.width * 0.66
    //
    //         let cardWidth = min(
    //             size.height * 0.16,
    //             (availableWidth - gap * 4) / 5
    //         )
    //
    //         let cardHeight = size.height * 0.18
    //
    //         return VStack(spacing: size.height * 0.02) {
    //
    //             // Top row: Apple and Candy
    //             cardRow(
    //                 Array(Self.snacks.prefix(2)),
    //                 gap: gap,
    //                 cardWidth: cardWidth,
    //                 cardHeight: cardHeight
    //             )
    //
    //             // Bottom row: Chips, Cookies and Popcorn
    //             cardRow(
    //                 Array(Self.snacks.dropFirst(2)),
    //                 gap: gap,
    //                 cardWidth: cardWidth,
    //                 cardHeight: cardHeight
    //             )
    //         }
    //         .position(
    //             x: size.width * 0.50,
    //             y: size.height * 0.77
    //         )
    //         .transition(.opacity)
    //     }
    //
    //
    //
    //     private func cardRow(_ items: [Snack], gap: CGFloat,
    //                          cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
    //         HStack(spacing: gap) {
    //             ForEach(items) { snack in
    //                 Button {
    //                     addedAddition = false
    //                     selected = snack            // <- opens Stage 2 for this snack
    //                     playSnackReaction()
    //                 } label: {
    //                     card(image: snack.image, title: snack.title,
    //                          width: cardWidth, height: cardHeight)
    //                 }
    //                 .buttonStyle(PressStyle(cornerRadius: cardWidth * 0.24))
    //             }
    //         }
    //     }
    //
    //

    // MARK: - Stages 2 and 3: placemat picture, boy, bubble, suggestion card
    private func chosenStage(_ snack: Snack, size: CGSize) -> some View {

        return ZStack {
            // Picture on the placemat: the snack alone, then the combination
            Image(addedAddition ? (snack.combinedImage ?? snack.image) : snack.image)
            // previous code here for reference.
            // Image(addedAddition ? snack.combinedImage : snack.image)
                .resizable()
                .scaledToFit()
                .frame(height: size.height * 0.40)
                .id(addedAddition)
                .transition(.opacity)
                .position(x: size.width * 0.5, y: size.height * 0.29)

            //only show a suggestion when this snack has an addition.
            if let additionImage = snack.additionImage,
               let additionTitle = snack.additionTitle {
                FoodCardGroup {
                    FoodChoiceButton(usesPressFeedback: true, title: Text(additionTitle),
                                     image: additionImage, selected: addedAddition) {
                        addedAddition = true
                        playSnackReaction()
                    }
                    .disabled(addedAddition)
                }
                .environment(\.foodLayoutStyle, FoodLayoutStyle.responsive(to: size))
                .frame(width: FoodLayoutStyle.workspaceWidth(for: size))
                .position(x: size.width * 0.5, y: size.height * FoodLayoutStyle.rowCenterFraction)
                // Previous suggestion-card implementation:
    //                 Button {
    //                     addedAddition = true
    //                     playSnackReaction()
    //                 } label: {
    //                     card(
    //                         image: additionImage,
    //                         title: additionTitle,
    //                         width: size.height * 0.16,
    //                         height: size.height * 0.18
    //                     )
    //                 }
    //                 .buttonStyle(PressStyle(cornerRadius: size.height * 0.16 * 0.24))
    //                 .disabled(addedAddition)
    //                 .position(x: size.width * 0.5, y: size.height * 0.79)
            }
            // previous code here for reference.
            // // Suggestion card: tapping it adds the food
            // Button {
            //     addedAddition = true
            //     playSnackReaction()
            // } label: {
            //     card(
            //         image: snack.additionImage,
            //         title: snack.additionTitle,
            //         width: size.height * 0.16,
            //         height: size.height * 0.18
            //     )
            // }
            // .buttonStyle(PressStyle(cornerRadius: size.height * 0.16 * 0.24))
            // .disabled(addedAddition)
            // .position(x: size.width * 0.5, y: size.height * 0.79)

            // Finish now sits outside the artwork layout in FoodActionRegion.
            // Previous implementation:
    //             // allow finishing immediately for snacks without an addition.
    //                 if addedAddition || snack.additionImage == nil {
    //             // previous code here for reference.
    //             // // Finish button (Stage 3 only)
    //             //     if addedAddition {
    //
    //                     ZadiActionButton(
    //                         title: "خلصت وجبتي!",
    //                         icon: "checkmark.circle.fill"
    //                     ) {
    //                         Coach.stopVoice()
    //                         isShowingEnding = true
    //                     }
    //                     .position(
    //                         x: size.width * 0.87,
    //                         y: size.height * 0.89
    //                     )
    //                     .transition(.opacity)
    //
    //                 }


          
        }
        .transition(.opacity)
    }

    // Previous card drawing and press style are preserved below.
    // FoodCardLabel draws the shared card; FoodChoiceButton preserves the press feedback.
    //     // MARK: - One gray card: picture on top, white Arabic label at the bottom
    //     private func card(image: String, title: String,
    //                       width: CGFloat, height: CGFloat) -> some View {
    //         VStack(spacing: 0) {
    //             Image(image)
    //                 .resizable()
    //                 .scaledToFit()
    //                 .frame(width: width * 0.68, height: height * 0.52)
    //                 .padding(.top, height * 0.09)
    //
    //             Spacer(minLength: 0)
    //
    //             Text(title)
    //                 .font(.system(size: width * 0.17, weight: .semibold))
    //                 .lineLimit(1)
    //                 .minimumScaleFactor(0.5)      // long names (e.g. peanut butter) shrink to fit
    //                 .foregroundStyle(.white)
    //                 .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
    //                 .padding(.horizontal, width * 0.06)
    //                 .padding(.bottom, height * 0.10)
    //         }
    //         .frame(width: width, height: height)
    //         .background(
    //             RoundedRectangle(cornerRadius: width * 0.24, style: .continuous)
    //                 .fill(LinearGradient(
    //                     colors: [Color(white: 0.82).opacity(0.92), Color(white: 0.72).opacity(0.92)],
    //                     startPoint: .top, endPoint: .bottom))
    //                 .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
    //         )
    //     }
    //
    //     // MARK: - Button look: shrinks and glows white while pressed
    //     private struct PressStyle: ButtonStyle {
    //         let cornerRadius: CGFloat
    //
    //         func makeBody(configuration: Configuration) -> some View {
    //             configuration.label
    //                 .overlay(
    //                     RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    //                         .stroke(Color.white.opacity(configuration.isPressed ? 0.9 : 0), lineWidth: 4)
    //                         .blur(radius: 3)
    //                 )
    //                 .scaleEffect(configuration.isPressed ? 0.95 : 1)
    //                 .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    //         }
    //     }
}

#Preview("Snack", traits: .landscapeLeft) {
    SnackView()
}
