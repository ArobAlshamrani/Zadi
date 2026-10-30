import SwiftUI

// Open the chosen meal from this menu; entering Bread starts a fresh recipe.
struct FoodSelectionPage: View {
    // Use the selected boy or girl on this page and pass the choice to Bread and Rice.
    let character: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var showsToast = false
    @State private var showsRice = false
    @State private var showsPancake = false
    @State private var showsSnack = false

    var body: some View {
        page
            .navigationBarBackButtonHidden(true)
            .onChange(of: scenePhase) {
                if scenePhase != .active {
                    Coach.stopVoice()
                }
            }
            .onDisappear {
                // A meal owns playback once its selection flag is set.
                if !showsToast && !showsPancake && !showsRice && !showsSnack {
                    Coach.stopVoice()
                }
            }
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
    }

    private func playMealRecording(_ recording: IngredientVoice.Recording) {
        Coach.stopVoice()
        IngredientVoice.shared.play(
            recording,
            character: character == "girl" ? .girl : .boy
        )
    }

    // Each meal's back action clears its flag to show the menu again.
    @ViewBuilder
    private var page: some View {
       
        if showsToast {
            ToastView(
                character: character,
                returnToFoodSelection: {
                    showsToast = false
                }
            )

        } else if showsPancake {
            PancakePlateView(
                character: character,
                returnToFoodSelection: {
                    showsPancake = false
                }
            )


        
        } else if showsSnack {

            SnackView(
                character: character,
                onFinish: {
                    showsSnack = false
                },
                onBackToMeals: {
                    showsSnack = false
                }
            )

        } else if showsRice {


            RiceMealView(
                character: character,
                returnToFoodSelection: { showsRice = false }
            )
            .overlay {
                ZadiTopControls(
                    onBack: {
                        Coach.stopVoice()
                        showsRice = false
                    },
                    onSound: { IngredientVoice.shared.replayLast() }
                )
                // I give Rice's Back and Listen controls the full page, just like Bread.
                .ignoresSafeArea()
                // I previously left this overlay inside the safe area.
            }

        } else {

            GeometryReader { geometry in
                // Keep geometry-derived frames valid even during transient layout changes.
                let width = geometry.size.width.isFinite ? max(0, geometry.size.width) : 0
                let height = geometry.size.height.isFinite ? max(0, geometry.size.height) : 0
                // I use the same card sizes and reserved workspace as Bread.
                let cardStyle = FoodLayoutStyle.responsive(to: geometry.size)
                let cardWorkspaceWidth = FoodLayoutStyle.workspaceWidth(for: geometry.size)
                // I keep my previous sizing here for reference.
    //                 let contentWidth = max(0, width - 32)
    //                 let spacing: CGFloat = 18
    //                 // I use Bread's card scale, keeping the mini at full size.
    //                 let cardScale = max(1, min(width / 1194, height / 834))

                ZStack(alignment: .bottomLeading) {
                    Image("BaseBackground")
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: height)
                        .clipped()
                        .accessibilityHidden(true)

                    // Use the same visible body size and lowered baseline as Bread.
                    CharacterPresentation(
                        character: character,
                        imageName: "\(character) select page",
                        foodLayoutStyle: .foodPages
                    )
                    // Previous presentation:
                    // CharacterPresentation(
                    //     character: character,
                    //     imageName: "\(character) select page"
                    // )

                    // I position my title above the card area without changing its row center.
                    Text("اختار وجبتك لليوم !")
                        .font(.title.bold())
                        .foregroundStyle(Color(red: 0.20, green: 0.27, blue: 0.65))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .frame(width: cardWorkspaceWidth)
                        .position(x: FoodLayoutStyle.fourCardCenterX(for: geometry.size),
                                  y: height * FoodLayoutStyle.rowCenterFraction - cardStyle.cardHeight / 2 - 2 * cardStyle.cardSpacing)
                    // Previous title placement:
                    // .position(x: width * 0.5,
                    //           y: height * FoodLayoutStyle.rowCenterFraction - cardStyle.cardHeight / 2 - 2 * cardStyle.cardSpacing)

                    FoodCardGroup {
                        FoodChoiceButton(title: Text("خبز"), image: "Bread") {
                            playMealRecording(.breadPlain)
                            showsToast = true
                        }
                        FoodChoiceButton(title: Text("بانكيك"), image: "PancakeSelect") {
                            playMealRecording(.pancakePlain)
                            showsPancake = true
                        }
                        FoodChoiceButton(title: Text("وجبات خفيفة"), image: "popcorn") {
                            Coach.stopVoice()
                            showsSnack = true
                        }
                        FoodChoiceButton(title: Text("أرز"), image: "RiceBowl") {
                            playMealRecording(.ricePlain)
                            showsRice = true
                        }
                    }
                    .environment(\.foodLayoutStyle, cardStyle)
                    .environment(\.layoutDirection, .rightToLeft)
                    .frame(width: cardWorkspaceWidth)
                    .position(x: FoodLayoutStyle.fourCardCenterX(for: geometry.size),
                              y: height * FoodLayoutStyle.rowCenterFraction)
                    // Previous row placement:
                    // .position(x: width * 0.5, y: height * FoodLayoutStyle.rowCenterFraction)

                    // I keep my previous independent card sizing here for reference.
    //                     // I keep the title separate so it cannot move my meal-card row.
    //                     Text("اختار وجبتك لليوم !")
    //                         .font(.title.bold())
    //                         .foregroundStyle(Color(red: 0.20, green: 0.27, blue: 0.65))
    //                         .minimumScaleFactor(0.7)
    //                         .lineLimit(1)
    //                         .frame(width: min(contentWidth / cardScale, 598))
    //                         .scaleEffect(cardScale)
    //                         .position(x: width * 0.5, y: height * 0.75 - 110 * cardScale)
    //
    //                     ScrollView(.horizontal) {
    //                         HStack(spacing: spacing) {
    //                             FoodChoiceButton(title: Text("خبز"), image: "Bread", cardHeight: 145) {
    //                                 playMealRecording(.breadPlain)
    //                                 showsToast = true
    //                             }
    //                             FoodChoiceButton(title: Text("بانكيك"), image: "PancakeSelect", cardHeight: 145) {
    //                                 playMealRecording(.pancakePlain)
    //                                 showsPancake = true
    //                             }
    //                             FoodChoiceButton(title: Text("وجبات خفيفة"), image: "popcorn", cardHeight: 145) {
    //                                 Coach.stopVoice()
    //                                 showsSnack = true
    //                             }
    //                             FoodChoiceButton(title: Text("أرز"), image: "RiceBowl", cardHeight: 145) {
    //                                 playMealRecording(.ricePlain)
    //                                 showsRice = true
    //                             }
    //                         }
    //                         .padding(12)
    //                     }
    //                     // I allow space around my 145-point cards so their edges remain visible.
    //                     .frame(width: min(contentWidth / cardScale, 598), height: 169)
    //                     .environment(\.layoutDirection, .rightToLeft)
    //                     .scaleEffect(cardScale)
    //                     // I align my meal cards with Bread's ingredient row.
    //                     .position(x: width * 0.5, y: height * 0.75)
    //
                    // I keep my previous title and card layout here for reference.
                    // VStack(spacing: spacing * 0.5) {
                    // Text("اختار وجبتك لليوم !")
                    // .font(.title.bold())
                    // .foregroundStyle(Color(red: 0.20, green: 0.27, blue: 0.65))
                    // .minimumScaleFactor(0.7)
                    // .lineLimit(1)
                    // 
                    // ScrollView(.horizontal) {
                    // HStack(spacing: spacing) {
                    // FoodChoiceButton(title: Text("خبز"), image: "Bread") {
                    // playMealRecording(.breadPlain)
                    // showsToast = true
                    // }
                    // FoodChoiceButton(title: Text("بانكيك"), image: "PancakeSelect") {
                    // playMealRecording(.pancakePlain)
                    // showsPancake = true
                    // }
                    // FoodChoiceButton(title: Text("وجبات خفيفة"), image: "popcorn") {
                    // Coach.stopVoice()
                    // showsSnack = true
                    // }
                    // FoodChoiceButton(title: Text("أرز"), image: "RiceBowl") {
                    // playMealRecording(.ricePlain)
                    // showsRice = true
                    // }
                    // }
                    // .padding(12)
                    // }
                    // .frame(width: min(contentWidth, 598), height: 159)
                    // }
                    // .environment(\.layoutDirection, .rightToLeft)
                    // .frame(width: contentWidth)
                    // .position(x: width * 0.5, y: height * 0.785)
                }
                .frame(width: width, height: height)
                .overlay {
                    ZadiTopControls(
                        onBack: {
                            Coach.stopVoice()
                            dismiss()
                        },
                        onSound: {
                            IngredientVoice.shared.replayLast()
                        }
                    )
                    .zIndex(100)
                }
            }
            .ignoresSafeArea()

        }
    }
}

#Preview(traits: .landscapeLeft) {
    FoodSelectionPage(character: "girl")
}
