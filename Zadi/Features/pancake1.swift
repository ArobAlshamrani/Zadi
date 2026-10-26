
import SwiftUI

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

    @State private var firstPancake = false
    @State private var secondPancake = false

    @State private var selectedToppings: Set<PancakeTopping> = []

    // Girl speech message
    @State private var coachMessage: CoachMessage? = nil
    var body: some View {

        GeometryReader { geometry in

            let w = geometry.size.width
            let h = geometry.size.height
            let scale = min(w / 1194, h / 834)

            ZStack {

                // MARK: - Background

                Image("KitchenBackGround")
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

                            VStack(spacing: 8 * scale) {

                                Image(topping.cardImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: 75 * scale,
                                        height: 70 * scale
                                    )

                                Text(topping.title)
                                    .font(
                                        .system(
                                            size: 17 * scale,
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
                                height: 135 * scale
                            )
                            .background(Color.white)
                            .clipShape(
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

               
                // MARK: - Girl and Bubble

               CharacterView(
                   character: "girl",
                   message: coachMessage
               )
               .scaleEffect(scale)
               .position(
                   x: w * 0.14,
                   y: h * 0.87
               )

                // MARK: - Finish Button

                if !selectedToppings.isEmpty {

                    Button {

                        // No final alert.
                        // Girl congratulates the child instead.
                       
                        withAnimation(.spring(response: 0.4)) {
                            coachMessage = CoachMessage(
                                mood: .eating,
                                text: "أحسنت! جهزت وجبتك! 🎉",
                                voice: "أحسنت! لقد جهزت وجبتك!"
                            )
                        }


                    } label: {

                        Text("انتهيت!")
                            .font(
                                .system(
                                    size: 20 * scale,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(.white)
                            .padding(.horizontal, 30 * scale)
                            .padding(.vertical, 10 * scale)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: w * 0.50,
                        y: h * 0.90
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

        // Prevent chocolate and honey together
        let sauceConflict =
            (topping == .chocolate &&
             selectedToppings.contains(.honey))
            ||
            (topping == .honey &&
             selectedToppings.contains(.chocolate))

        if sauceConflict {

            coachMessage = CoachMessage(
                mood: .thinking,
                text: "اختَر صوصًا واحدًا بس! 🍯🍫",
                voice: "يمكنك اختيار العسل أو الشوكولاتة فقط."
            )
            return
        }

        if selectedToppings.contains(topping) {

            withAnimation {
                selectedToppings.remove(topping)
            }

            coachMessage = CoachMessage(
                mood: .thinking,
                text: "ماذا نضيف الآن؟ 🤔",
                voice: "ماذا تريد أن تضيف الآن؟"
            )

        } else {

            withAnimation {
                selectedToppings.insert(topping)
            }

            coachMessage = CoachMessage(
                mood: .excited,
                text: toppingMessage(topping),
                voice: "رائع! اختيار جميل!"
            )
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
