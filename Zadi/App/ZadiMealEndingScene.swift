
import SwiftUI

// MARK: - Shared Meal Ending Scene

struct ZadiMealEndingScene: View {

    let character: String
    let mealImage: String
    var mealArtwork: AnyView? = nil
    let onAnotherMeal: () -> Void
    let onStartTask: () -> Void
    var isSnack = false
    @State private var appeared = false

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    var body: some View {

        GeometryReader { geometry in

            let w = geometry.size.width
            let h = geometry.size.height
            let scale = min(w / 1194, h / 834)

            ZStack {

                // MARK: - Sketch Background

                Image("MealEndingBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: w, height: h)
                    .clipped()

                // MARK: - Title

                VStack(spacing: 5 * scale) {

                    Text("✨ رائع! ✨")
                        .font(.system(
                            size: 48 * scale,
                            weight: .heavy,
                            design: .rounded
                        ))

                    Text(isSnack ? "سناكك اللذيذ جاهز!" : "وجبتك اللذيذة جاهزة!")                        .font(.system(
                            size: 36 * scale,
                            weight: .bold,
                            design: .rounded
                        ))
                }
                .foregroundStyle(
                    Color(
                        red: 0.12,
                        green: 0.24,
                        blue: 0.55
                    )
                )
                .multilineTextAlignment(.center)
                .position(
                    x: w * 0.5,
                    y: h * 0.16
                )

                // MARK: - Happy Character

                Image(character == "girl" ? "EndingGirl" : "EndingBoy")                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 350 * scale,
                        height: 365 * scale
                    )
                    .offset(
                        y: appeared ? 0 : 40 * scale
                    )
                    .opacity(appeared ? 1 : 0)
                    .position(
                        x: w * 0.5,
                        y: h * 0.51
                    )

             
                // MARK: - Zadi Plate and Selected Meal

                ZStack {

                    // MARK: - Original Zadi Plate

                    Image("ZadiPlate")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: 380 * scale,
                            height: 380 * scale
                        )
                        // Make the plate look natural on the table
                        .scaleEffect(y: 0.44)
                        .frame(
                            width: 380 * scale,
                            height: 175 * scale
                        )
                        .shadow(
                            color: .black.opacity(0.15),
                            radius: 6 * scale,
                            y: 5 * scale
                        )

                    // MARK: - Child's Selected Meal

                    if let mealArtwork {
                        mealArtwork
                            .frame(
                                width: 300 * scale,
                                height: 195 * scale
                            )
                            .offset(y: -22 * scale)
                    } else {
                        Image(mealImage)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 300 * scale,
                                height: 195 * scale
                            )
                            .offset(y: -22 * scale)
                    }

                }
                
                .frame(
                    width: 410 * scale,
                    height: 230 * scale
                )
                .scaleEffect(0.85)
                .position(
                    x: w * 0.5,
                    y: h * 0.77
                )


               
                // MARK: - Ending Buttons

             
                HStack(spacing: 30 * scale) {

                    if isSnack {

                        // Snack: one Finish button only
                        ZadiActionButton(
                            title: "إنهاء",
                            icon: "checkmark.circle.fill",
                            action: onAnotherMeal
                        )

                    } else {

                        // Meals: choose another meal
                        Button(action: onAnotherMeal) {

                            Label(
                                "اختيار وجبة أخرى",
                                systemImage: "arrow.clockwise"
                            )
                            .font(.system(
                                size: 19,
                                weight: .bold,
                                design: .rounded
                            ))
                            .foregroundStyle(
                                Color(red: 0.20, green: 0.30, blue: 0.45)
                            )
                            .frame(width: 224, height: 54)
                            .background(
                                Color.white,
                                in: Capsule()
                            )
                        }
                        .buttonStyle(.plain)

                        // Meals: go to the task
                        ZadiActionButton(
                            title: "يلا للمهمة!",
                            icon: "star.fill",
                            action: onStartTask
                        )
                    }
                }

                .environment(\.layoutDirection, .leftToRight)
                .scaleEffect(1.15 * scale)
                .position(
                    x: w * 0.5,
                    y: h * 0.92
                )

            }
            .frame(width: w, height: h)
            .clipped()
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .onAppear {

            if reduceMotion {
                appeared = true
            } else {
                withAnimation(
                    .spring(
                        response: 0.65,
                        dampingFraction: 0.75
                    )
                ) {
                    appeared = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Rice Ending", traits: .landscapeLeft) {
    ZadiMealEndingScene(
        character: "girl",
        mealImage: "Rice_chicken",
        onAnotherMeal: {},
        onStartTask: {}
    )
}
