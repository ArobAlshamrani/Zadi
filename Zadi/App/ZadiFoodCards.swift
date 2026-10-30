import SwiftUI

// Shared cards for Food Selection, Bread, Rice, Pancake, and Snacks.
// Sizing, appearance, and row arrangement stay separate so each is easy to adjust.
// Original source files are preserved in Archive; previous code remains commented below.

// MARK: - Card Sizes, Text, and Spacing
// Adjust FoodLayoutStyle values to resize the cards across the food pages.
struct FoodLayoutStyle {
    // Change these base values to resize all food cards using the shared style.
    var cardWidth: CGFloat = 130
    var cardHeight: CGFloat = 145
    var imageWidth: CGFloat = 116
    var imageHeight: CGFloat = 84
    var labelFontSize: CGFloat = 23
    var cardSpacing: CGFloat = 18
    var rowSpacing: CGFloat = 18
    var cornerRadius: CGFloat = 29
    var labelHeight: CGFloat? = 52
    var labelPadding: CGFloat = 8
    var labelLineLimit = 2
    var minimumTextScale: CGFloat = 0.9
    var contentSpacing: CGFloat = 2
    var selectionPadding: CGFloat = 12

    // keep cards readable on the mini and limit their growth on larger iPads.
    static let minimumScale: CGFloat = 1
    static let maximumScale: CGFloat = 1.2
    static let rowCenterFraction: CGFloat = 0.75

    static func responsive(to size: CGSize) -> FoodLayoutStyle {
        let scale = min(maximumScale, max(minimumScale, min(size.width / 1194, size.height / 834)))
        var style = FoodLayoutStyle()
        style.cardWidth *= scale
        style.cardHeight *= scale
        style.imageWidth *= scale
        style.imageHeight *= scale
        style.labelFontSize *= scale
        style.cardSpacing *= scale
        style.rowSpacing *= scale
        style.cornerRadius *= scale
        style.labelHeight = style.labelHeight.map { $0 * scale }
        style.labelPadding *= scale
        style.contentSpacing *= scale
        style.selectionPadding *= scale
        return style
    }

    // Reserve space beside the cards for the character and action button.
    static func workspaceWidth(for size: CGSize) -> CGFloat {
        max(0, size.width * 0.54)
    }

    // Four cards need extra room beside the larger shared character.
    // Move only the row horizontally; keep card sizes and row height unchanged.
    static func fourCardCenterX(for size: CGSize) -> CGFloat {
        let cards = responsive(to: size)
        let rowWidth = min(4 * cards.cardWidth + 3 * cards.cardSpacing,
                           max(0, workspaceWidth(for: size) - 2 * cards.selectionPadding))
        let characterRight = size.width * FoodCharacterLayoutStyle.foodPages.characterRegionWidthFraction
        let clearance = cards.cardSpacing + cards.selectionPadding
        let preferredCenter = max(size.width * 0.5, characterRight + clearance + rowWidth / 2)
        return min(preferredCenter, size.width - cards.selectionPadding - rowWidth / 2)
    }

    // Preserve the original dimensions for callers without the shared page style.
    static func legacy(cardHeight: CGFloat) -> FoodLayoutStyle {
        var style = FoodLayoutStyle()
        style.cardHeight = cardHeight
        style.labelHeight = nil
        style.labelPadding = 0
        style.labelLineLimit = 1
        style.minimumTextScale = 0.65
        return style
    }
}

private struct FoodLayoutStyleKey: EnvironmentKey {
    static let defaultValue: FoodLayoutStyle? = nil
}

extension EnvironmentValues {
    // Pass the page's resolved sizes to its cards through the environment.
    var foodLayoutStyle: FoodLayoutStyle? {
        get { self[FoodLayoutStyleKey.self] }
        set { self[FoodLayoutStyleKey.self] = newValue }
    }
}

// MARK: - Card Appearance and Selection Feedback
// FoodCardLabel draws the card; FoodChoiceButton runs the action supplied by each page.
// Previous appearance options are preserved for reference.
// enum FoodCardAppearance {
//     case standard
//     case pancake
// }

// Shared artwork and styling for every food card.
struct FoodCardLabel: View {
    @Environment(\.foodLayoutStyle) private var pageStyle
    let title: Text
    let image: String
    var selected = false
    // Keep the original size as a fallback for pages without a shared style.
    var cardHeight: CGFloat = 135
    // Previous setting: var appearance: FoodCardAppearance = .standard

    var body: some View {
        // Use the shared page settings when available; otherwise use the original dimensions.
        let style = pageStyle ?? FoodLayoutStyle.legacy(cardHeight: cardHeight)
        VStack(spacing: style.contentSpacing) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: style.imageWidth, height: style.imageHeight)
                .accessibilityHidden(true)

            title
                .font(.system(size: style.labelFontSize, weight: .bold, design: .rounded))
                .lineLimit(style.labelLineLimit)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(style.minimumTextScale)
                .frame(width: style.cardWidth - 2 * style.labelPadding, height: style.labelHeight)
                // All migrated food cards use the same white labels.
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
                // Previous Pancake-specific appearance:
                // .foregroundStyle(appearance == .pancake
                //                  ? Color(red: 0.25, green: 0.35, blue: 0.55) : .white)
                // .shadow(color: .black.opacity(appearance == .pancake ? 0 : 0.35), radius: 2, y: 2)
                // Previous presentation:
                // .foregroundStyle(.white)
                // .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
        }
        .frame(width: style.cardWidth, height: style.cardHeight)
        // Previous dimensions: .frame(width: 130, height: 135).
        .background(Color(red: 0.74, green: 0.74, blue: 0.77).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: style.cornerRadius)
                .stroke(.white, lineWidth: selected ? 5 : 0)
                // Previous Pancake-specific outline:
                // .stroke(appearance == .pancake ? .green : .white,
                //         lineWidth: selected ? (appearance == .pancake ? 4 * style.cardWidth / 130 : 5) : 0)
        }
        // Selection uses the same glow and enlargement on every migrated food page.
        .shadow(color: .white.opacity(selected ? 0.95 : 0), radius: 20)
        .scaleEffect(selected ? 1.06 : 1)
        // Previous Pancake-specific feedback:
        // .shadow(color: appearance == .pancake ? .black.opacity(0.12) : .white.opacity(selected ? 0.95 : 0),
        //         radius: appearance == .pancake ? 5 : 20)
        // .scaleEffect(selected && appearance == .standard ? 1.06 : 1)
        // Previous selection feedback:
        // .stroke(.white, lineWidth: selected ? 5 : 0)
        // .shadow(color: .white.opacity(selected ? 0.95 : 0), radius: 20)
        // .scaleEffect(selected ? 1.06 : 1)
        .contentShape(RoundedRectangle(cornerRadius: style.cornerRadius))
    }
    // Previous card presentation preserved for reference.
    //     var body: some View {
    //         VStack(spacing: 2) {
    //             Image(image)
    //                 .resizable()
    //                 .scaledToFit()
    //                 .frame(width: 116, height: 84)
    //                 .accessibilityHidden(true)
    //
    //             title
    //                 .font(.system(size: 23, weight: .bold, design: .rounded))
    //                 .lineLimit(1)
    //                 .minimumScaleFactor(0.65)
    //                 .foregroundStyle(.white)
    //                 .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
    //         }
    //         .frame(width: 130, height: cardHeight)
    //         // Previous dimensions: .frame(width: 130, height: 135).
    //         .background(Color(red: 0.74, green: 0.74, blue: 0.77).opacity(0.92))
    //         .clipShape(RoundedRectangle(cornerRadius: 29))
    //         .overlay {
    //             RoundedRectangle(cornerRadius: 29)
    //                 .stroke(.white, lineWidth: selected ? 5 : 0)
    //         }
    //         .shadow(color: .white.opacity(selected ? 0.95 : 0), radius: 20)
    //         .scaleEffect(selected ? 1.06 : 1)
    //         .contentShape(RoundedRectangle(cornerRadius: 29))
    //     }
}

// Shared by ingredient choices and the meal-selection cards.
// Each screen supplies the action to run when its button is tapped.
struct FoodChoiceButton: View {
    @Environment(\.foodLayoutStyle) private var pageStyle
    // Snacks keeps its short press animation; other pages retain plain button feedback.
    var usesPressFeedback = false
    let title: Text
    let image: String
    var selected = false
    // Allow callers without a shared style to supply their own card height.
    var cardHeight: CGFloat = 135
    // Previous setting: var appearance: FoodCardAppearance = .standard
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            FoodCardLabel(title: title, image: image, selected: selected, cardHeight: cardHeight)
            // Previous call:
            // FoodCardLabel(title: title, image: image, selected: selected,
            //               cardHeight: cardHeight, appearance: appearance)
            // FoodCardLabel(title: title, image: image, selected: selected, cardHeight: cardHeight)
            // FoodCardLabel(title: title, image: image, selected: selected)
        }
        .buttonStyle(FoodChoicePressStyle(enabled: usesPressFeedback,
                                          cornerRadius: pageStyle?.cornerRadius ?? 29))
        // Previous style: .buttonStyle(.plain)
        .accessibilityLabel(title)
        // Let VoiceOver announce when this ingredient is selected.
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

// Preserve the snack press animation without duplicating the card drawing.
private struct FoodChoicePressStyle: ButtonStyle {
    let enabled: Bool
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        if enabled {
            configuration.label
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(configuration.isPressed ? 0.9 : 0), lineWidth: 4)
                        .blur(radius: 3)
                )
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        } else {
            // Plain callers receive no extra animation modifiers.
            configuration.label
        }
        // Previous draft:
        // configuration.label
        // .overlay(
        // RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        // .stroke(Color.white.opacity(enabled && configuration.isPressed ? 0.9 : 0), lineWidth: 4)
        // .blur(radius: 3)
        // )
        // .scaleEffect(enabled && configuration.isPressed ? 0.95 : 1)
        // .animation(enabled ? .easeOut(duration: 0.12) : nil, value: configuration.isPressed)
    }
}

// MARK: - Card Rows and Arrangement
// FoodCardGroup uses FoodCardRows to center and wrap cards within the available workspace.
struct FoodCardGroup<Content: View>: View {
    @Environment(\.foodLayoutStyle) private var pageStyle
    @Environment(\.layoutDirection) private var direction
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        FoodCardRows(style: pageStyle ?? FoodLayoutStyle(), direction: direction) {
            content
        }
    }
}

struct FoodCardRows: Layout {
    let style: FoodLayoutStyle
    var direction: LayoutDirection = .leftToRight

    // Center short rows and arrange five cards as two above three when space allows.
    // If the workspace is narrower, it will wrap instead of making the text too small.
    func rowCounts(count: Int, availableWidth: CGFloat) -> [Int] {
        guard count > 0 else { return [] }
        let usableWidth = max(0, availableWidth - 2 * style.selectionPadding)
        let capacity = max(1, min(4, Int((usableWidth + style.cardSpacing) / (style.cardWidth + style.cardSpacing))))
        if count == 5 && capacity >= 3 { return [2, 3] }
        if count == 4 && capacity == 3 { return [2, 2] }
        var remaining = count
        var rows: [Int] = []
        while remaining > 0 {
            let next = min(capacity, remaining)
            rows.append(next)
            remaining -= next
        }
        return rows
    }

    private func width(for proposal: ProposedViewSize, count: Int) -> CGFloat {
        let columns = min(count, count == 5 ? 3 : 4)
        let ideal = CGFloat(columns) * style.cardWidth
            + CGFloat(max(0, columns - 1)) * style.cardSpacing + 2 * style.selectionPadding
        guard let width = proposal.width, width.isFinite else { return ideal }
        return max(style.cardWidth + 2 * style.selectionPadding, width)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let width = width(for: proposal, count: subviews.count)
        let rows = rowCounts(count: subviews.count, availableWidth: width)
        return CGSize(width: width, height: CGFloat(rows.count) * style.cardHeight
                      + CGFloat(max(0, rows.count - 1)) * style.rowSpacing + 2 * style.selectionPadding)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = rowCounts(count: subviews.count, availableWidth: bounds.width)
        var index = 0
        var y = bounds.minY + style.selectionPadding + style.cardHeight / 2
        for count in rows {
            let rowWidth = CGFloat(count) * style.cardWidth + CGFloat(count - 1) * style.cardSpacing
            for column in 0..<count {
                // Let SwiftUI handle Arabic mirroring without reversing the columns twice.
                let visualColumn = column
                // Previous expression: direction == .rightToLeft ? count - 1 - column : column
                let x = bounds.midX - rowWidth / 2 + style.cardWidth / 2
                    + CGFloat(visualColumn) * (style.cardWidth + style.cardSpacing)
                subviews[index].place(at: CGPoint(x: x, y: y), anchor: .center,
                                      proposal: ProposedViewSize(width: style.cardWidth, height: style.cardHeight))
                index += 1
            }
            y += style.cardHeight + style.rowSpacing
        }
    }
}

#Preview("Five cards — two above three", traits: .landscapeLeft) {
    GeometryReader { geometry in
        FoodCardGroup {
            FoodChoiceButton(title: Text("تفاح"), image: "apple") {}
            FoodChoiceButton(title: Text("فراولة"), image: "strawberry") {}
            FoodChoiceButton(title: Text("موز"), image: "banana") {}
            FoodChoiceButton(title: Text("خبز"), image: "Bread") {}
            FoodChoiceButton(title: Text("وجبات خفيفة"), image: "popcorn") {}
        }
        .environment(\.foodLayoutStyle, FoodLayoutStyle.responsive(to: geometry.size))
        .environment(\.layoutDirection, .rightToLeft)
        .frame(width: FoodLayoutStyle.workspaceWidth(for: geometry.size))
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
}
