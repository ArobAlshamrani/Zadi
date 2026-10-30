
import SwiftUI

// Shared page controls: Back/Listen, action-button appearance, and Next/Finish placement.
// Pages supply the actions; these components control how the buttons look and where they appear.

// MARK: - Shared Back and Listen Controls
// Both controls scale with the available height. Back can be hidden when a page does not need it.
struct ZadiTopControls: View {

    let onBack: () -> Void
    let onSound: () -> Void
    var showsBackButton = true
    
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let buttonSize = height * 0.10

            ZStack {

               
                // MARK: - Back Button
                if showsBackButton {
                    ZadiCircleButton(
                        icon: "arrow.left",
                        label: "رجوع",
                        size: buttonSize,
                        action: onBack
                    )
                    .position(
                        x: width * 0.07,
                        y: height * 0.10
                    )
                }


                // MARK: - Listen Button
                ZadiCircleButton(
                    icon: "speaker.wave.2.fill",
                    label: "إعادة تشغيل آخر تسجيل",
                    size: buttonSize,
                    action: onSound
                )
                .position(
                    x: width * 0.93,
                    y: height * 0.10
                )
            }
            .frame(width: width, height: height)
        }
    }
}

// MARK: - Reusable Circle Button
// Draw the same circular style for Back and Listen, with a readable accessibility label.
private struct ZadiCircleButton: View {

    let icon: String
    let label: String
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(
                    size: size * 0.35,
                    weight: .bold
                ))
                .foregroundStyle(
                    Color(red: 0.20, green: 0.30, blue: 0.45)
                )
                .frame(width: size, height: size)
                .background(
                    Color(red: 1.0, green: 0.97, blue: 0.93),
                    in: Circle()
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}

// MARK: - Shared Action Button
// Draw a green 224-by-54-point button. The containing view decides its position.

struct ZadiActionButton: View {

   let title: LocalizedStringKey
   var icon: String? = nil
   let action: () -> Void

   var body: some View {
       Button(action: action) {
           HStack(spacing: 10) {

               if let icon {
                   Image(systemName: icon)
               }

               Text(title)
           }
           .font(.system(
               size: 20,
               weight: .bold,
               design: .rounded
           ))
           .foregroundStyle(.white)
           .frame(width: 224, height: 54)
           .background(
               Color(red: 0.25, green: 0.66, blue: 0.36),
               in: Capsule()
           )
       }
       .buttonStyle(.plain)
   }
}

// MARK: - Shared Meal Celebration Card
// Display a character, congratulatory message, and task button together.
// This card is separate from the full-screen ZadiMealEndingScene.

struct ZadiMealCelebrationCard: View {

   let character: String
   let message: String
   let onStartTask: () -> Void

   @State private var appeared = false

   @Environment(\.accessibilityReduceMotion)
   private var reduceMotion

   var body: some View {

       HStack(spacing: 14) {

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

               Text(message)
                   .font(.system(
                       size: 22,
                       weight: .bold,
                       design: .rounded
                   ))
                   .foregroundStyle(
                       Color(red: 0.22, green: 0.33, blue: 0.48)
                   )
                   .multilineTextAlignment(.center)

               ZadiActionButton(
                   title: "يلا للمهمة!",
                   icon: "star.fill",
                   action: onStartTask
               )
           }
           .frame(maxWidth: .infinity)

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
       .background(
           Color(red: 1.0, green: 0.94, blue: 0.82),
           in: RoundedRectangle(cornerRadius: 32)
       )
       .overlay {
           RoundedRectangle(cornerRadius: 32)
               .stroke(.white, lineWidth: 4)
       }
       .shadow(
           color: .brown.opacity(0.15),
           radius: 7,
           y: 4
       )
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

// MARK: - Food Page Next and Finish Positioning
// Each food page supplies its own button, completion conditions, and action.
// Place this region in an overlay so showing a button does not move the ingredient cards.
struct FoodActionRegion<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            // Scale up on larger screens, while keeping the button at least its original size.
            let scale = max(1, min(geometry.size.width / 1194, geometry.size.height / 834))
            let halfWidth = 112 * scale
            let halfHeight = 27 * scale

            ZStack {
                content
            }
            .frame(width: 224, height: 54)
            .scaleEffect(scale)
            // Position Next and Finish in the same bottom-right area.
            // Limit the center position to leave at least 24 points at the right and bottom edges.
            .position(
                x: min(geometry.size.width * 0.80, geometry.size.width - halfWidth - 24),
                y: min(geometry.size.height * 0.90, geometry.size.height - halfHeight - 24)
            )
        }
        .environment(\.layoutDirection, .leftToRight)
        // Previous layout preserved for reference; the following code is inactive.
        // // Reserve a slot matching ZadiActionButton's 224-by-54-point size.
        // // The slot stays the same even when the page has no action to show.
        // ZStack {
        // content
        // }
        // .frame(width: 224, height: 54)
        // .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        // .padding(.trailing, 24)
        // .padding(.bottom, 24)
        // // Keep the region inside the parent's safe area.
        // // Keep the action on the right regardless of the text direction.
        // .environment(\.layoutDirection, .leftToRight)
        // // Keep the empty area transparent.
    }
}
