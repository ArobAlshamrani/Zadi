import SwiftUI

// Shared artwork and styling for every food card.
struct FoodCardLabel: View {
    let title: Text
    let image: String
    var selected = false

    var body: some View {
        VStack(spacing: 2) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 116, height: 84)
                .accessibilityHidden(true)

            title
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
        }
        .frame(width: 130, height: 135)
        .background(Color(red: 0.74, green: 0.74, blue: 0.77).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 29))
        .overlay {
            RoundedRectangle(cornerRadius: 29)
                .stroke(.white, lineWidth: selected ? 5 : 0)
        }
        .shadow(color: .white.opacity(selected ? 0.95 : 0), radius: 20)
        .scaleEffect(selected ? 1.06 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 29))
    }
}

struct FoodChoiceButton: View {
    let title: String
    let image: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FoodCardLabel(title: Text(title), image: image, selected: selected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
