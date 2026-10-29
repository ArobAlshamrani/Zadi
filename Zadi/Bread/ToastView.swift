
import SwiftUI
import AVFoundation

// MARK: - Toast Meal
struct ToastView: View {

    let character: String
    var returnToFoodSelection: (() -> Void)? = nil

    @Environment(\.returnToHome) private var returnToHome
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var goToTask = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var coachMessage: CoachMessage?

    @State private var selectedBase: ToastBase?
    @State private var selectedProtein: ToastProtein?
    @State private var selectedVegetables: Set<ToastVegetable> = []
    @State private var selectedFruits: Set<ToastFruit> = []
    @State private var step: ToastStep = .base

    @State private var activeBenefit: IngredientBenefit?
    @State private var ingredientAudio: IngredientAudio?
    @State private var isCelebrating = false
    @State private var returnToMealMenuAfterDismiss = false

    // Finish is available after the first ingredient.
    private var canFinish: Bool {
        selectedBase != nil ||
        selectedProtein != nil ||
        !selectedVegetables.isEmpty ||
        !selectedFruits.isEmpty
    }

    private var backLabel: String {
        step == .toppings && selectedBase != .chocolate
            ? "الرجوع لاختيار البروتين"
            : "الرجوع لاختيار الجبن أو الشوكولاتة"
    }

    // MARK: - Main Page
    var body: some View {

        ToastPageLayout(
            showsBackButton: false,
            backLabel: step == .base
                ? "الرجوع لاختيار الوجبة"
                : backLabel,
            goBack: goBack
        ) { size in

            SandwichView(
                size: size,
                selectedBase: selectedBase,
                selectedProtein: selectedProtein,
                selectedVegetables: selectedVegetables,
                selectedFruits: selectedFruits
            )

        } content: { buttonWidth in

            switch step {

            // MARK: - Step 1: Spread
            case .base:

                VStack(spacing: 10) {

                    IngredientChoiceRow(
                        ingredients: ToastBase.allCases,
                        isSelected: { selectedBase == $0 },
                        choose: chooseBase
                    )

                   

                }

            // MARK: - Step 2: Protein
            case .protein:

                VStack(spacing: 10) {

                    IngredientChoiceRow(
                        ingredients: ToastProtein.allCases,
                        isSelected: { selectedProtein == $0 },
                        choose: chooseProtein
                    )

                  


                }

            // MARK: - Step 3: Toppings
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

                            react(
                                to: fruit.benefit,
                                added: selectedFruits.contains(fruit)
                            )
                        }
                    },

                    toggleVegetable: { vegetable in
                        withAnimation(popupAnimation) {
                            selectedVegetables.toggle(vegetable)

                            react(
                                to: vegetable.benefit,
                                added: selectedVegetables.contains(vegetable)
                            )
                        }
                    },

                    finish: finishMeal
                )

          
           
                // MARK: - Step 4: Celebration
                case .finished:
                    EmptyView()
                }
            }

            // MARK: - Celebration Stars
        
        .overlay {
            if step == .protein {
                GeometryReader { geometry in
                    ZadiActionButton(
                        title: " خلصت وجبتي",
                        icon: "checkmark.circle.fill",
                        action: finishMeal
                    )
                    .disabled(selectedProtein == nil)
                    .opacity(selectedProtein == nil ? 0.5 : 1)
                    .scaleEffect(0.94)
                    .position(
                        x: geometry.size.width * 0.80,
                        y: geometry.size.height * 0.93
                    )
                }
            }
        }

            .overlay {

            if step == .finished {
                CelebrationSparkles()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }

        // MARK: - Shared Back & Sound Buttons
        .overlay {
            if step != .finished {
                ZadiTopControls(
                    onBack: goBack,
                    onSound: playToastAudio
                )
            }
        }

        // MARK: - Character Reactions
        .overlay {
            if let coachMessage, step != .finished {

                GeometryReader { geometry in

                    let scale = min(
                        geometry.size.width / 1194,
                        geometry.size.height / 834
                    )

                    CharacterView(
                        character: character,
                        message: coachMessage
                    )
                    .scaleEffect(scale)
                    .position(
                        x: geometry.size.width * 0.14,
                        y: geometry.size.height * 0.87
                    )
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }
        }

        // MARK: - Audio Lifecycle
        .onChange(of: activeBenefit) {
            playActiveRecording()
        }

        .onChange(of: scenePhase) {
            if scenePhase != .active {
                ingredientAudio?.stop()
                speechSynthesizer.stopSpeaking(at: .immediate)
            }
        }

        .onDisappear {
            ingredientAudio?.stop()
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)

        
        // MARK: - Shared Ending Scene

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
                    mealImage: "toast",

                    mealArtwork: AnyView(
                        SandwichView(
                            size: 165,
                            selectedBase: selectedBase,
                            selectedProtein: selectedProtein,
                            selectedVegetables: selectedVegetables,
                            selectedFruits: selectedFruits
                        )
                        .scaleEffect(y: 0.65)
                        .offset(y: 20)
                    ),

                    onAnotherMeal: {
                        ingredientAudio?.stop()
                        speechSynthesizer.stopSpeaking(at: .immediate)

                        goToTask = false
                        returnToMealMenuAfterDismiss = true
                        isCelebrating = false
                    },

                    onStartTask: {
                        ingredientAudio?.stop()
                        speechSynthesizer.stopSpeaking(at: .immediate)
                        goToTask = true
                    }
                )

                .navigationDestination(isPresented: $goToTask) {
                    TaskView(
                        character: character,
                        meal: .bread,
                        onReturnHome: {
                            goToTask = false
                            isCelebrating = false
                            returnToHome()
                        }
                    )
                }
            } // نهاية NavigationStack
        } // نهاية fullScreenCover

        } // نهاية body

        // MARK: - Shared Finish Button
        private var finishButton: some View {

        ZadiActionButton(
            title: "خلصت وجبتي!",
            icon: "checkmark.circle.fill",
            action: finishMeal
        )
    }

    // MARK: - Finish Meal
    private func finishMeal() {

        guard canFinish, step != .finished else {
            return
        }

        ingredientAudio?.stop()
        activeBenefit = nil

        speechSynthesizer.stopSpeaking(at: .immediate)

    
        // Celebration has no new audio.
        withAnimation(
            reduceMotion ? nil : .spring(response: 0.5)
        ) {
            coachMessage = nil
            step = .finished
        }

        isCelebrating = true
    }


    // MARK: - Selected Foods
    private var selectedFoods: [Food] {

        var benefits: [IngredientBenefit] = []

        if let selectedBase {
            benefits.append(selectedBase.benefit)
        }

        if let selectedProtein {
            benefits.append(selectedProtein.benefit)
        }

        benefits += ToastFruit.allCases
            .filter { selectedFruits.contains($0) }
            .map(\.benefit)

        benefits += ToastVegetable.allCases
            .filter { selectedVegetables.contains($0) }
            .map(\.benefit)

        return benefits.map(\.coachFood)
    }

    // MARK: - Ingredient Reaction
    private func react(
        to benefit: IngredientBenefit,
        added: Bool
    ) {

        coachMessage = benefit.coachReaction(
            added: added,
            selected: selectedFoods
        )

        activeBenefit = added ? benefit : nil
    }

    // MARK: - Existing Instructions Audio
    private func playToastAudio() {

        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            return
        }

        ingredientAudio?.stop()

        let isGirl = character == "girl"
        let instructions: String

        switch step {

        case .base:
            instructions = isGirl
                ? "اختاري الجبن أو الشوكولاتة، ثم اضغطي التالي."
                : "اختر الجبن أو الشوكولاتة، ثم اضغط التالي."

        case .protein:
            instructions = isGirl
                ? "اختاري البروتين الذي تحبينه، ثم اضغطي التالي."
                : "اختر البروتين الذي تحبه، ثم اضغط التالي."

        case .toppings:
            instructions = isGirl
                ? "اختاري الإضافات التي تحبينها، ثم اضغطي انتهيت."
                : "اختر الإضافات التي تحبها، ثم اضغط انتهيت."

        case .finished:
            return
        }

        let utterance = AVSpeechUtterance(
            string: instructions
        )

        utterance.voice = AVSpeechSynthesisVoice(
            language: "ar-SA"
        )

        utterance.rate = 0.45
        speechSynthesizer.speak(utterance)
    }

    // MARK: - Ingredient Recordings
    private func playActiveRecording() {

        guard
            let activeBenefit,
            step != .finished,
            scenePhase == .active
        else {
            ingredientAudio?.stop()
            return
        }

        if ingredientAudio == nil {
            ingredientAudio = IngredientAudio()
        }

        ingredientAudio?.play(
            recording: activeBenefit.recordingName
        )
    }

    // MARK: - Animation
    private var popupAnimation: Animation {

        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .spring(
                response: 0.45,
                dampingFraction: 0.8
            )
    }

    // MARK: - Choose Spread
    private func chooseBase(_ base: ToastBase) {

        withAnimation(popupAnimation) {

            selectedBase = selectedBase == base ? nil : base

            if selectedBase == .chocolate {

                selectedProtein = nil
                selectedVegetables.removeAll()

            } else if selectedBase == .cheese {

                selectedFruits.removeAll()
            }

            react(
                to: base.benefit,
                added: selectedBase != nil
            )
        }

        // Chocolate skips the protein step.
        
        guard let selectedBase else { return }

        withAnimation(popupAnimation) {
            step = selectedBase == .chocolate
                ? .toppings
                : .protein
        }    }

    // MARK: - Choose Protein
    private func chooseProtein(_ protein: ToastProtein) {

        withAnimation(popupAnimation) {

            selectedProtein =
                selectedProtein == protein ? nil : protein

            if selectedProtein != nil {
                selectedFruits.removeAll()
            }

            react(
                to: protein.benefit,
                added: selectedProtein != nil
            )
        }
    }

    // MARK: - Next Step
    private func advance() {

        // Prevent moving forward without selecting an ingredient.
        switch step {

        case .base where selectedBase == nil:
            return

        case .protein where selectedProtein == nil:
            return

        default:
            break
        }

        ingredientAudio?.stop()

        withAnimation(popupAnimation) {

            switch step {

            case .base:
                step = selectedBase == .chocolate
                    ? .toppings
                    : .protein

            case .protein:
                step = .toppings

            case .toppings, .finished:
                break
            }
        }
    }

    // MARK: - Back Navigation
    private func goBack() {

        ingredientAudio?.stop()
        speechSynthesizer.stopSpeaking(at: .immediate)

        activeBenefit = nil
        coachMessage = nil

        switch step {

       
        case .protein:
            withAnimation(popupAnimation) {
                selectedBase = nil
                selectedProtein = nil
                selectedFruits.removeAll()
                selectedVegetables.removeAll()
                step = .base
            }

        case .toppings:
            withAnimation(popupAnimation) {
                selectedFruits.removeAll()
                selectedVegetables.removeAll()

                if selectedBase == .chocolate {
                    selectedBase = nil
                    selectedProtein = nil
                    step = .base
                } else {
                    selectedProtein = nil
                    step = .protein
                }
            }


        case .base:
            if let returnToFoodSelection {
                returnToFoodSelection()
            } else {
                dismiss()
            }

        case .finished:
            break
        }
    }
}



// MARK: - Toast Celebration Card

private struct ToastCelebrationView: View {

   let character: String
   let onStartTask: () -> Void

   @State private var appeared = false

   @Environment(\.accessibilityReduceMotion)
   private var reduceMotion

   var body: some View {

       HStack(alignment: .center, spacing: 14) {

           // MARK: - Celebration Text and Button

           VStack(spacing: 11) {

               Text(
                   character == "girl"
                   ? "✨ واااو! أبدعتِ! ✨"
                   : "✨ واااو! أبدعت! ✨"
               )
               .font(.system(
                   size: 29,
                   weight: .heavy,
                   design: .rounded
               ))
               .foregroundStyle(
                   Color(red: 0.76, green: 0.35, blue: 0.12)
               )

               Text(
                   character == "girl"
                   ? "جهزتِ شطيرتك بنفسك! 🥪"
                   : "جهزت شطيرتك بنفسك! 🥪"
               )
               .font(.system(
                   size: 22,
                   weight: .bold,
                   design: .rounded
               ))
               .foregroundStyle(
                   Color(red: 0.22, green: 0.33, blue: 0.48)
               )

               ZadiActionButton(
                   title: "يلا للمهمة!",
                   icon: "star.fill",
                   action: onStartTask
               )
           }
           .frame(maxWidth: .infinity)
           .multilineTextAlignment(.center)

           // MARK: - Happy Character

           Image("\(character)_excited")
               .resizable()
               .scaledToFit()
               .frame(width: 150, height: 165)
               .accessibilityHidden(true)
       }
       .environment(\.layoutDirection, .leftToRight)
       .padding(.horizontal, 26)
       .padding(.vertical, 14)
       .frame(maxWidth: 730)

       // MARK: - Card Background

       .background {
           RoundedRectangle(cornerRadius: 32)
               .fill(
                   Color(
                       red: 1.0,
                       green: 0.94,
                       blue: 0.82
                   )
               )
       }

       // MARK: - Card Border

       .overlay {
           RoundedRectangle(cornerRadius: 32)
               .stroke(
                   Color.white.opacity(0.95),
                   lineWidth: 4
               )
       }

       .shadow(
           color: .brown.opacity(0.15),
           radius: 7,
           y: 4
       )

       .padding(.horizontal, 16)
       .offset(y: -10)

       // MARK: - Entrance Animation

       .scaleEffect(appeared ? 1 : 0.92)
       .opacity(appeared ? 1 : 0)

       .onAppear {
           if reduceMotion {
               appeared = true
           } else {
               withAnimation(
                   .spring(
                       response: 0.55,
                       dampingFraction: 0.75
                   )
               ) {
                   appeared = true
               }
           }
       }
   }
}






// MARK: - Celebration Sparkles
// Brief stars around the plate, then they disappear.

private struct CelebrationSparkles: View {

    @State private var expanded = false
    @State private var fadedOut = false

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    private struct Sparkle {

        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let symbol: String
        let color: Color
    }

    private let stars: [Sparkle] = [

        Sparkle(
            x: -0.25, y: -0.15,
            size: 27,
            symbol: "star.fill",
            color: .yellow
        ),

        Sparkle(
            x: -0.32, y: 0.02,
            size: 19,
            symbol: "sparkle",
            color: .orange
        ),

        Sparkle(
            x: -0.25, y: 0.20,
            size: 22,
            symbol: "star.fill",
            color: .pink
        ),

        Sparkle(
            x: -0.12, y: -0.24,
            size: 22,
            symbol: "sparkle",
            color: .yellow
        ),

        Sparkle(
            x: 0.12, y: -0.24,
            size: 25,
            symbol: "star.fill",
            color: .orange
        ),

        Sparkle(
            x: 0.25, y: -0.15,
            size: 27,
            symbol: "star.fill",
            color: .yellow
        ),

        Sparkle(
            x: 0.32, y: 0.02,
            size: 20,
            symbol: "sparkle",
            color: .pink
        ),

        Sparkle(
            x: 0.25, y: 0.20,
            size: 24,
            symbol: "star.fill",
            color: .orange
        ),

        Sparkle(
            x: 0.00, y: 0.24,
            size: 19,
            symbol: "sparkle",
            color: .yellow
        )
    ]

    var body: some View {

        GeometryReader { geometry in

            ForEach(
                stars.indices,
                id: \.self
            ) { index in

                let star = stars[index]

                Image(systemName: star.symbol)
                    .font(.system(
                        size: star.size,
                        weight: .bold
                    ))
                    .foregroundStyle(star.color)
                    .shadow(
                        color: star.color.opacity(0.25),
                        radius: 5
                    )
                    .position(
                        x: geometry.size.width * 0.5,
                        y: geometry.size.height * 0.34
                    )
                    .offset(
                        x: geometry.size.width
                            * star.x
                            * (expanded ? 1 : 0.2),

                        y: geometry.size.height
                            * star.y
                            * (expanded ? 1 : 0.2)
                    )
                    .scaleEffect(
                        expanded ? 1 : 0.2
                    )
                    .opacity(
                        fadedOut
                            ? 0
                            : (expanded ? 1 : 0)
                    )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)

        .task {

            if reduceMotion {
                return
            }

            withAnimation(
                .spring(
                    response: 0.75,
                    dampingFraction: 0.7
                )
            ) {
                expanded = true
            }

            do {

                try await Task.sleep(
                    for: .seconds(1.7)
                )

                withAnimation(
                    .easeOut(duration: 0.5)
                ) {
                    fadedOut = true
                }

            } catch {
                // Stop if the child leaves the screen.
            }
        }
    }
}

// MARK: - Set Helper
private extension Set {

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
