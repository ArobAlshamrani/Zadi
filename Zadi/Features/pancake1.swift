
import SwiftUI
import AVFoundation
// MARK: - Toppings

enum PancakeTopping: String, CaseIterable, Identifiable {
    case chocolate, strawberry, banana, honey

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chocolate: return "شوكولاتة"
        case .strawberry: return "فراولة"
        case .banana: return "موز"
        case .honey: return "عسل"
        }
    }

    var cardImage: String {
        rawValue
    }

    var topImage: String {
        switch self {
        case .chocolate: return "chocolateTop"
        case .strawberry: return "strawberryTop"
        case .banana: return "bananaTop"
        case .honey: return "honeyTop"
        }
    }

    static let overlayOrder: [PancakeTopping] = [
        .chocolate, .honey, .banana, .strawberry
    ]
}

// MARK: - Pancake Page


struct PancakePlateView: View {

    // MARK: - Selected Character
    let character: String
    var returnToFoodSelection: (() -> Void)? = nil

    private var isGirl: Bool {
        character == "girl"
    }

    // MARK: - Audio & Navigation
    @Environment(\.returnToHome) private var returnToHome

    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @State private var goToTask = false
    @State private var isFinishing = false
    @State private var firstPancake = false
    @State private var secondPancake = false
    @State private var isCelebrating = false
    @State private var returnToMealMenuAfterDismiss = false
    @State private var selectedToppings: Set<PancakeTopping> = []

    // Girl speech message
    @State private var coachMessage: CoachMessage? = nil
    @Environment(\.dismiss) private var dismiss
    var body: some View {

        GeometryReader { geometry in

            let w = geometry.size.width
            let h = geometry.size.height
            let scale = min(w / 1194, h / 834)

            ZStack {

                // MARK: - Background

                Image("Plate Background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .clipped()
                    .allowsHitTesting(false)

                // MARK: - Pancakes and Toppings

                ZStack {

                    // First pancake
                    Image("pancake")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 285 * scale)
                        .offset(
                            y: firstPancake
                                ? 12 * scale
                                : -500 * scale
                        )
                        .opacity(firstPancake ? 1 : 0)

                    // Second pancake
                    Image("pancake")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 285 * scale)
                        .offset(
                            y: secondPancake
                                ? -8 * scale
                                : -500 * scale
                        )
                        .opacity(secondPancake ? 1 : 0)

                    // Selected toppings
                    ForEach(PancakeTopping.overlayOrder) { topping in

                        if selectedToppings.contains(topping) {

                            Image(topping.topImage)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: toppingWidth(topping) * scale
                                )
                                .offset(
                                    x: toppingX(topping) * scale,
                                    y: toppingY(topping) * scale
                                )
                                .transition(
                                    .asymmetric(
                                        insertion:
                                            .offset(y: -300 * scale)
                                            .combined(with: .opacity),
                                        removal: .opacity
                                    )
                                )
                                .zIndex(
                                    Double(
                                        PancakeTopping.overlayOrder
                                            .firstIndex(of: topping) ?? 0
                                    ) + 1
                                )
                        }
                    }
                }
                .frame(
                    width: 350 * scale,
                    height: 350 * scale
                )
                .position(
                    x: w * 0.50,
                    y: h * 0.28
                )
                .allowsHitTesting(false)

                // MARK: - Question

                
                    .allowsHitTesting(false)

                // MARK: - Topping Cards

                HStack(spacing: 18 * scale) {

                    ForEach(PancakeTopping.allCases) { topping in

                        Button {
                            toggleTopping(topping)
                        } label: {

                            VStack(spacing: 2 * scale) {
                                Image(topping.cardImage)
                                    .resizable()
                                    .scaledToFit()
                                    
                                    .frame(
                                        width: 105 * scale,
                                        height: 90 * scale
                                    )
                                Text(topping.title)
                                    .font(
                                        .system(
                                            size: 21 * scale,
                                            weight: .bold
                                        )
                                    )
                                    .foregroundStyle(
                                        Color(
                                            red: 0.25,
                                            green: 0.35,
                                            blue: 0.55
                                        )
                                    )
                            }
                            .frame(
                                width: 130 * scale,
                                height: 145 * scale
                            )
                            .background(
                                Color(
                                    red: 0.74,
                                    green: 0.74,
                                    blue: 0.77
                                )
                                .opacity(0.92)
                            )                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 25 * scale
                                )
                            )
                            .overlay {
                                RoundedRectangle(
                                    cornerRadius: 25 * scale
                                )
                                .stroke(
                                    selectedToppings.contains(topping)
                                        ? Color.green
                                        : Color.clear,
                                    lineWidth: 4 * scale
                                )
                            }
                            .shadow(
                                color: .black.opacity(0.12),
                                radius: 5
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                .position(
                    x: w * 0.50,
                    y: h * 0.75
                )
                .opacity(isCelebrating ? 0 : 1)
                .allowsHitTesting(!isCelebrating)

                // MARK: - Shared Back & Sound Buttons
                ZadiTopControls(
                        onBack: {
                            speechSynthesizer.stopSpeaking(at: .immediate)
                            Speaker.shared.stop()

                            if let returnToFoodSelection {
                                returnToFoodSelection()
                            } else {
                                dismiss()
                            }
                        },
                        onSound: playPancakeAudio

                )
                .zIndex(100)

                // MARK: - Girl and Bubble

                CharacterView(
                    character: character,
                    message: coachMessage
                )
               .scaleEffect(scale)
               .position(
                   x: w * 0.14,
                   y: h * 0.87
               )
               .opacity(isCelebrating ? 0 : 1)
               .allowsHitTesting(!isCelebrating)


          
                    // MARK: - Finish Button

                    if !selectedToppings.isEmpty && !isCelebrating {

                        ZadiActionButton(
                            title: "خلصت وجبتي",
                            icon: "checkmark.circle.fill"
                        ) {
                            Speaker.shared.stop()

                            withAnimation(.spring(response: 0.5)) {
                                isCelebrating = true
                            }
                        }
                        .scaleEffect(scale)
                        .position(
                            x: w * 0.80,
                            y: h * 0.93
                        )
                    }

                    




            }
            .frame(width: w, height: h)
            .clipped()
            .onAppear {
                startPancakeAnimation()
            }
        }
        .ignoresSafeArea()
        
       
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
                    mealImage: "pancake",

                    // Pancakes with the child's chosen toppings
                    mealArtwork: AnyView(
                        ZStack {

                            Image("pancake")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 165)
                                .offset(y: 8)

                            Image("pancake")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 165)
                                .offset(y: -4)

                            ForEach(PancakeTopping.overlayOrder) { topping in
                                if selectedToppings.contains(topping) {

                                    Image(topping.topImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(
                                            width: toppingWidth(topping) * 0.55
                                        )
                                        .offset(
                                            x: toppingX(topping) * 0.55,
                                            y: toppingY(topping) * 0.55
                                        )
                                }
                            }
                        }
                        .frame(width: 230, height: 190)
                        .scaleEffect(y: 0.70)
                        .offset(y: 15)
                    ),

                    onAnotherMeal: {
                        speechSynthesizer.stopSpeaking(at: .immediate)
                        Speaker.shared.stop()

                        goToTask = false
                        returnToMealMenuAfterDismiss = true
                        isCelebrating = false
                    },

                    onStartTask: {
                        speechSynthesizer.stopSpeaking(at: .immediate)
                        Speaker.shared.stop()
                        goToTask = true
                    }
                )
                .navigationDestination(isPresented: $goToTask) {

                    TaskView(
                        character: character,
                        meal: .pancake,
                        onReturnHome: {
                            goToTask = false
                            isCelebrating = false
                            returnToHome()
                        }
                    )
                }
            }
        }

        .onDisappear {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }

    }

    // MARK: - Play Pancake Audio
    private func playPancakeAudio() {

        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
            return
        }

       
        let instructions = isGirl
            ? "هيا نزيّن البانكيك! اختاري الإضافات التي تحبينها، وعندما تنتهين اضغطي زر انتهيت."
            : "هيا نزيّن البانكيك! اختر الإضافات التي تحبها، وعندما تنتهي اضغط زر انتهيت."

        let message = AVSpeechUtterance(string: instructions)


        message.voice = AVSpeechSynthesisVoice(language: "ar-SA")
        message.rate = 0.45

        speechSynthesizer.speak(message)
    }

    // MARK: - Pancake Animation

    private func startPancakeAnimation() {

        firstPancake = false
        secondPancake = false

        withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
            firstPancake = true
        }

        withAnimation(.easeOut(duration: 0.7).delay(1.2)) {
            secondPancake = true
        }
    }


    // MARK: - Selection Logic

    private func toggleTopping(_ topping: PancakeTopping) {

        let sauceConflict =
            (topping == .chocolate &&
             selectedToppings.contains(.honey))
            ||
            (topping == .honey &&
             selectedToppings.contains(.chocolate))
            
            if sauceConflict {
                
                coachMessage = Coach.pancakeSauceConflict()
                
            } else if selectedToppings.contains(topping) {
                
                withAnimation(.spring()) {
                    _ = selectedToppings.remove(topping)
                }
                
                coachMessage = Coach.pancakeRemoved(
                    name: topping.title
                )
                
            } else {
                
                withAnimation(.spring()) {
                    _ = selectedToppings.insert(topping)
                }
                
                coachMessage = Coach.pancakeAdded(
                    id: topping.rawValue
                )
            }
            
            // Play the new encouragement audio
            if let coachMessage {
                speechSynthesizer.stopSpeaking(at: .immediate)
                Speaker.shared.say(coachMessage.voice)
            }
        }
    
    // MARK: - Girl Messages

    private func toppingMessage(
        _ topping: PancakeTopping
    ) -> String {

        switch topping {

        case .chocolate:
            return " الشوكولاتة لذيذة للغاية "

        case .strawberry:
            return "اختيار جميل! 🍓\nالفراولة تضيف لونًا جميلًا !"

        case .banana:
            return "رائع! 🍌\nالموز إضافة شهية!"

        case .honey:
            return "العسل اختيار لذيذ ومفيد  "
        }
    }

    // MARK: - Topping Sizes

    private func toppingWidth(
        _ topping: PancakeTopping
    ) -> CGFloat {

        switch topping {
        case .chocolate: return 360
        case .strawberry: return 250
        case .banana: return 240
        case .honey: return 300
        }
    }

    // MARK: - Topping X Position

    private func toppingX(
        _ topping: PancakeTopping
    ) -> CGFloat {

        switch topping {
        case .chocolate: return 0
        case .strawberry: return 0
        case .banana: return 5
        case .honey: return 0
        }
    }

    // MARK: - Topping Y Position

    private func toppingY(
        _ topping: PancakeTopping
    ) -> CGFloat {

        switch topping {
        case .chocolate: return -8
        case .strawberry: return -8
        case .banana: return -18
        case .honey: return -10
        }
    }
}
