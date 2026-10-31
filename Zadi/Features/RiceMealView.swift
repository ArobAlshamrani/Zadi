
import SwiftUI

// MARK: - Rice Meal View

struct RiceMealView: View {
    
    // MARK: - Character & Navigation
    
    var character: String = "boy"
    
    var returnToFoodSelection: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.returnToHome) private var returnToHome
    
    @State private var goToTask = false
    @State private var isCelebrating = false
    @State private var returnToMealMenuAfterDismiss = false
    // MARK: - Selected Ingredients
    
    @State private var selected: Set<String> = []
    
    // Character reaction
    @State private var message: CoachMessage?
    
    // MARK: - Available Foods
    
    let foods = [
        
        Food(
            id: "chicken",
            arabicName: "دجاج",
            icon: "riceChickenIngredient",
            voice: "الدجاج مليء بالبروتين، يجعل عضلاتك قوية!",
            recording: .riceChicken
        ),
        
        Food(
            id: "yogurt",
            arabicName: "زبادي",
            icon: "yogurt",
            voice: "الزبادي مفيد لعظامك وأسنانك!",
            recording: .riceYogurt
        ),
        
        Food(
            id: "salad",
            arabicName: "سلطة",
            icon: "salad",
            voice: "السلطة مليئة بالفيتامينات، تجعلك نشيطا وصحيا!",
            recording: .riceSalad
        ),
        
        Food(
            id: "fries",
            arabicName: "بطاطس",
            icon: "potato",
            isHealthy: false,
            voice: "البطاطس المقلية لذيذة، لكن فيها زيت كثير. ما رأيك أن تجرب السلطة بدلا منها؟",
            recording: .riceFries
        )
    ]
    
    // MARK: - Meal Images
    
    let mealImages: [Set<String>: String] = [
        
        []: "Rice_only",
        
        ["chicken"]: "Rice_chicken",
        ["yogurt"]: "Rice_yogurt",
        ["fries"]: "Rice_fries",
        ["salad"]: "Rice_salad",
        
        ["chicken", "yogurt"]: "Rice_chicken_yogurt",
        ["chicken", "fries"]: "Rice_chicken_fries",
        ["chicken", "salad"]: "Rice_chicken_salad",
        
        ["yogurt", "fries"]: "Rice_yogurt_fries",
        ["yogurt", "salad"]: "Rice_yogurt_salad",
        ["fries", "salad"]: "Rice_fries_salad",
        
        ["chicken", "yogurt", "fries"]:
            "Rice_chicken_yogurt_fries",
        
        ["chicken", "yogurt", "salad"]:
            "Rice_chicken_yogurt_salad",
        
        ["chicken", "fries", "salad"]:
            "Rice_chicken_salad_fries",
        
        ["yogurt", "fries", "salad"]:
            "Rice_yogurt_fries_salad",
        
        ["chicken", "yogurt", "fries", "salad"]:
            "RiceWithAllFour"
    ]
    
    // MARK: - Selection Logic
    
    func toggle(_ food: Food) {
        guard scenePhase == .active, !isCelebrating else { return }
        
        let added = !selected.contains(food.id)
        
        withAnimation(.spring()) {
            
            if added {
                selected.insert(food.id)
            } else {
                selected.remove(food.id)
            }
        }
        
        let onPlate = foods.filter {
            selected.contains($0.id)
        }
        
        message = Coach.react(
            to: food,
            added: added,
            selected: onPlate
        )
        
        Coach.play(message, character: character)
    }
    
    // MARK: - Rice Instructions Audio
    
    private func playRiceAudio() {
        IngredientVoice.shared.replayLast()
    }
    
    // MARK: - Main Screen
    
    var body: some View {
        
        GeometryReader { geometry in
            let canvas = CGSize(width: 1366, height: 1100)
            let scale = min(geometry.size.width / canvas.width, geometry.size.height / canvas.height)

        ZStack {
            
            // MARK: - Shared Back & Sound Buttons
            
            
            // MARK: - Rice Plate
            
            if let meal = mealImages[selected] {
                
                Image(meal)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 305)
                    .id(meal)
                    .transition(
                        .scale(scale: 0.85)
                        .combined(with: .opacity)
                    )
                    .position(x: 695, y: 308)
            }
            
            // MARK: - Food Selection Cards
            
            // now place cards and Finish outside the scaled artwork canvas.
            // previous controls here for reference.
            //             HStack(spacing: 44) {
            //
            //                 ForEach(foods, id: \.self) { food in
            //                     foodButton(food)
            //                 }
            //             }
            //             .environment(
            //                 \.layoutDirection,
            //                  .leftToRight
            //             )
            //             .position(x: 695, y: 853)
            //             .opacity(isCelebrating ? 0 : 1)
            //             .allowsHitTesting(!isCelebrating)
            //
            //             // MARK: - Finish Button
            //
            //             // Appears only after the first ingredient
            //
            //             if !selected.isEmpty && !isCelebrating {
            //
            //                 ZadiActionButton(
            //                     title: "خلصت وجبتي!",
            //                     icon: "checkmark.circle.fill"
            //                 ) {
            //
            //                     Coach.stopVoice()
            //
            //                     withAnimation(
            //                         .spring(
            //                             response: 0.5,
            //                             dampingFraction: 0.75
            //                         )
            //                     ) {
            //                         isCelebrating = true
            //                     }
            //                 }
            //
            //                 .scaleEffect(1.25)
            //                 .position(x: 1150, y: 1025)
            //                 .zIndex(20)
            //             }
            //            
            
            
            
            
        } // نهاية ZStack — لا تحذفينه
        
        // MARK: - Screen Layout
        
        .frame(width: canvas.width, height: canvas.height)
        
        .background {
            Image("KitchenBackGround")
                .resizable()
                .scaledToFill()
        }
        
        .ignoresSafeArea()
        // use the same status-bar visibility as Bread so our safe-area actions line up.
        .statusBarHidden(false)
        // .statusBarHidden()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
      
        // MARK: - Full Screen Celebration


        .fullScreenCover(
            isPresented: $isCelebrating,
            onDismiss: {

                if returnToMealMenuAfterDismiss {

                    returnToMealMenuAfterDismiss = false

                    if let returnToFoodSelection {
                        returnToFoodSelection()
                    } else {
                        dismiss()
                    }
                }
            }
        ) {

            NavigationStack {

                ZadiMealEndingScene(
                    character: character,
                    mealImage: mealImages[selected] ?? "Rice_only",

                    onAnotherMeal: {
                        Coach.stopVoice()
                        goToTask = false
                        returnToMealMenuAfterDismiss = true
                        isCelebrating = false
                    },

                    onStartTask: {
                        Coach.stopVoice()
                        goToTask = true
                    }
                )

                .navigationDestination(isPresented: $goToTask) {

                    TaskView(
                        character: character,
                        meal: .rice,
                        onReturnHome: {
                            goToTask = false
                            isCelebrating = false
                            returnToHome()
                        }
                    )
                }
            }
        }


        
        // MARK: - Stop Audio When Leaving
        
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                Coach.stopVoice()
            }
        }
        .onDisappear {
            // The ending scene owns playback while it is presented.
            if !isCelebrating {
                Coach.stopVoice()
            }
        }
        .scaleEffect(scale)
        .frame(width: geometry.size.width, height: geometry.size.height)
        .overlay {
            // use the same card sizes and stable row position as Bread and Food Selection.
            FoodCardGroup {
                ForEach(foods, id: \.id) { food in
                    foodButton(food)
                }
            }
            .environment(\.foodLayoutStyle, FoodLayoutStyle.responsive(to: geometry.size))
            .environment(\.layoutDirection, .leftToRight)
            .frame(width: FoodLayoutStyle.workspaceWidth(for: geometry.size))
            .position(x: FoodLayoutStyle.fourCardCenterX(for: geometry.size),
                      y: geometry.size.height * FoodLayoutStyle.rowCenterFraction)
            // Previous row placement:
            // .position(x: geometry.size.width * 0.5,
            //           y: geometry.size.height * FoodLayoutStyle.rowCenterFraction)
            .opacity(isCelebrating ? 0 : 1)
            .allowsHitTesting(!isCelebrating)
        }
        .overlay {
            // Share Bread's measured character size and lowered baseline.
            CharacterPresentation(character: character, message: message,
                                  foodLayoutStyle: .foodPages)
                // Previous presentation:
                // CharacterPresentation(character: character, message: message)
                .opacity(isCelebrating ? 0 : 1)
        }
        }
        .ignoresSafeArea()
        .overlay {
            // keep Finish separate from cards, so showing it never moves their row.
            FoodActionRegion {
                if !selected.isEmpty && !isCelebrating {
                    ZadiActionButton(title: "خلصت وجبتي!", icon: "checkmark.circle.fill") {
                        Coach.stopVoice()
                        // keep original celebration animation and completion rule.
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                            isCelebrating = true
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Food Button
    
    func foodButton(_ food: Food) -> some View {
        // reuse shared card while Rice still owns the selection and recording.
        FoodChoiceButton(title: Text(food.arabicName), image: food.icon,
                         selected: selected.contains(food.id)) {
            toggle(food)
        }
    }

    // previous Rice card here for reference.
            //     func foodButton(_ food: Food) -> some View {
            //
            //         let isSelected = selected.contains(food.id)
            //
            //         return Button {
            //
            //             toggle(food)
            //
            //         } label: {
            //
            //             VStack(spacing: 2) {
            //
            //                 Image(food.icon)
            //                     .resizable()
            //                     .scaledToFit()
            //                     .frame(
            //                         width: 145,
            //                         height: 112
            //                     )
            //
            //                 Text(food.arabicName)
            //                     .font(
            //                         .system(
            //                             size: 28,
            //                             weight: .bold,
            //                             design: .rounded
            //                         )
            //                     )
            //                     .foregroundStyle(.white)
            //                     .shadow(
            //                         color: .black.opacity(0.35),
            //                         radius: 2,
            //                         y: 2
            //                     )
            //             }
            //             .frame(
            //                 width: 172,
            //                 height: 190
            //             )
            //             .background(
            //                 Color(
            //                     red: 0.74,
            //                     green: 0.74,
            //                     blue: 0.77
            //                 )
            //                 .opacity(0.92)
            //             )
            //             .clipShape(
            //                 RoundedRectangle(cornerRadius: 34)
            //             )
            //             .overlay {
            //
            //                 RoundedRectangle(cornerRadius: 34)
            //                     .stroke(
            //                         .white,
            //                         lineWidth: isSelected ? 5 : 0
            //                     )
            //             }
            //             .shadow(
            //                 color: .white.opacity(
            //                     isSelected ? 0.95 : 0
            //                 ),
            //                 radius: 20
            //             )
            //             .scaleEffect(
            //                 isSelected ? 1.06 : 1
            //             )
            //         }
            //
            //         .buttonStyle(.plain)
            //     }

} // نهاية RiceMealView

// MARK: - Preview

#Preview(traits: .landscapeLeft) {
    RiceMealView()
}

