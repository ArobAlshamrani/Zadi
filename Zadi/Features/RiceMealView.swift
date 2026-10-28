
import SwiftUI

// MARK: - Rice Meal View

struct RiceMealView: View {
    
    // MARK: - Character & Navigation
    
    var character: String = "boy"
    
    var returnToFoodSelection: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
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
            voice: "الدجاج مليء بالبروتين، يجعل عضلاتك قوية!"
        ),
        
        Food(
            id: "yogurt",
            arabicName: "زبادي",
            icon: "yogurt",
            voice: "الزبادي مفيد لعظامك وأسنانك!"
        ),
        
        Food(
            id: "salad",
            arabicName: "سلطة",
            icon: "salad",
            voice: "السلطة مليئة بالفيتامينات، تجعلك نشيطا وصحيا!"
        ),
        
        Food(
            id: "fries",
            arabicName: "بطاطس",
            icon: "potato",
            isHealthy: false,
            voice: "البطاطس المقلية لذيذة، لكن فيها زيت كثير. ما رأيك أن تجرب السلطة بدلا منها؟"
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
            "Rice_chicken_fries_salad",
        
        ["yogurt", "fries", "salad"]:
            "Rice_yogurt_fries_salad",
        
        ["chicken", "yogurt", "fries", "salad"]:
            "RiceWithAllFour"
    ]
    
    // MARK: - Selection Logic
    
    func toggle(_ food: Food) {
        
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
        
        // Keep the existing ingredient audio
        Speaker.shared.say(message?.voice ?? "")
    }
    
    // MARK: - Rice Instructions Audio
    
    private func playRiceAudio() {
        
        let instructions = character == "girl"
        ? "اختاري مع الرز الإضافة التي تحبينها. يمكنك اختيار الدجاج أو الزبادي أو السلطة أو البطاطس."
        : "اختر مع الرز الإضافة التي تحبها. يمكنك اختيار الدجاج أو الزبادي أو السلطة أو البطاطس."
        
        Speaker.shared.say(instructions)
    }
    
    // MARK: - Main Screen
    
    var body: some View {
        
        ZStack {
            
            // MARK: - Shared Back & Sound Buttons
            
            ZadiTopControls(
                onBack: {
                    
                    Speaker.shared.stop()
                    
                    if let returnToFoodSelection {
                        returnToFoodSelection()
                    } else {
                        dismiss()
                    }
                },
                
                onSound: playRiceAudio
            )
            .zIndex(100)
            
            .opacity(isCelebrating ? 0 : 1)
            .allowsHitTesting(!isCelebrating)
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
            
            HStack(spacing: 58) {
                
                ForEach(foods, id: \.self) { food in
                    foodButton(food)
                }
            }
            .environment(
                \.layoutDirection,
                 .leftToRight
            )
            .position(x: 761, y: 853)
            .opacity(isCelebrating ? 0 : 1)
            .allowsHitTesting(!isCelebrating)
            
            // MARK: - Character & Speech Bubble
            
            CharacterView(
                character: character,
                message: message
            )
            .position(x: 152, y: 897)
            .opacity(isCelebrating ? 0 : 1)
            .allowsHitTesting(!isCelebrating)
            
            // MARK: - Finish Button
            
            // Appears only after the first ingredient
            
            if !selected.isEmpty && !isCelebrating {
                
                ZadiActionButton(
                    title: "خلصت وجبتي!",
                    icon: "checkmark.circle.fill"
                ) {
                    
                    Speaker.shared.stop()
                    
                    withAnimation(
                        .spring(
                            response: 0.5,
                            dampingFraction: 0.75
                        )
                    ) {
                        isCelebrating = true
                    }
                }
                .position(x: 761, y: 1035)
                .zIndex(20)
            }
            
            
            
            
            
        } // نهاية ZStack — لا تحذفينه
        
        // MARK: - Screen Layout
        
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
        .background {
            Image("KitchenBackGround")
                .resizable()
                .scaledToFill()
        }
        
        .ignoresSafeArea()
        .statusBarHidden()
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
                        Speaker.shared.stop()
                        goToTask = false
                        returnToMealMenuAfterDismiss = true
                        isCelebrating = false
                    },

                    onStartTask: {
                        Speaker.shared.stop()
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
        
        .onDisappear {
            Speaker.shared.stop()
        }
    }
    
    
    // MARK: - Food Button
    
    func foodButton(_ food: Food) -> some View {
        
        let isSelected = selected.contains(food.id)
        
        return Button {
            
            toggle(food)
            
        } label: {
            
            VStack(spacing: 2) {
                
                Image(food.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 178,
                        height: 137
                    )
                
                Text(food.arabicName)
                    .font(
                        .system(
                            size: 35,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.white)
                    .shadow(
                        color: .black.opacity(0.35),
                        radius: 2,
                        y: 2
                    )
            }
            .frame(
                width: 198,
                height: 221
            )
            .background(
                Color(
                    red: 0.74,
                    green: 0.74,
                    blue: 0.77
                )
                .opacity(0.92)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 44)
            )
            .overlay {
                
                RoundedRectangle(cornerRadius: 44)
                    .stroke(
                        .white,
                        lineWidth: isSelected ? 5 : 0
                    )
            }
            .shadow(
                color: .white.opacity(
                    isSelected ? 0.95 : 0
                ),
                radius: 20
            )
            .scaleEffect(
                isSelected ? 1.06 : 1
            )
        }
        
        .buttonStyle(.plain)
    }

} // نهاية RiceMealView

// MARK: - Preview

#Preview(traits: .landscapeLeft) {
    RiceMealView()
}
