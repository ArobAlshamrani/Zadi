
import SwiftUI

// MARK: - Shared Back & Sound Buttons
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


                // MARK: - Sound Button
                ZadiCircleButton(
                    icon: "speaker.wave.2.fill",
                    label: "استمع إلى التعليمات",
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
