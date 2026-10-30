//
//  CharacterCoach.swift
//  Projectزادي
//
//  Created by Nouf Fayez on 14/05/1448 AH.
//

import SwiftUI
 
// MARK: - Food (used by every meal screen)
 
struct Food: Hashable {
    let id: String           // used in the logic, e.g. "chicken"
    let arabicName: String   // shown under the icon
    let icon: String         // image name in Assets
    var isHealthy: Bool = true
    var voice: String = ""   // what the character says when this food is picked
    var recording: IngredientVoice.Recording? = nil
}
 
// MARK: - What the character shows and says
 
enum Mood: String {
    case happy, thinking, excited, eating
    // Extra expressions used by the Bread screen. Each needs girl_<mood> and boy_<mood> images.
    case thumbsUp, strong, overjoyed, yummy
}
 
struct CoachMessage {
    let mood: Mood
    let text: String    // short text in the bubble
    let voice: String   // longer explanation (spoken)
    var recording: IngredientVoice.Recording? = nil
}
 
// MARK: - The rules (same for all meals)
 
enum Coach {
    // Missing recordings stay silent; coach reactions never synthesize speech.
    // Invoke playback from a user action, never from CharacterPresentation rendering.
    @MainActor
    static func play(_ message: CoachMessage?, character: String) {
        stopVoice()
        guard let message else { return }

        if let recording = message.recording {
            IngredientVoice.shared.play(
                recording,
                character: character == "girl" ? .girl : .boy
            )
        }
    }

    @MainActor
    static func stopVoice() {
        IngredientVoice.shared.stop()
    }
 
    /// Call this every time the child taps a food.
    /// - food: the food that was tapped
    /// - added: true = added to the plate, false = removed
    /// - selected: all foods on the plate now
    static func react(to food: Food, added: Bool, selected: [Food]) -> CoachMessage? {
        let healthyCount = selected.filter { $0.isHealthy }.count
        let hasUnhealthy = selected.contains { !$0.isHealthy }
 
        // 1) Added something unhealthy → think & suggest something better
        if added && !food.isHealthy {
            return CoachMessage(mood: .thinking,
                                text: "حسنا دعنا نفكر للحظة...",
                                voice: food.voice,
                                recording: food.recording)
        }
 
        // Keep the tapped ingredient's recording even when the visual reaction celebrates balance.
        // 2) The meal is balanced (2 or more healthy foods, nothing unhealthy)
        if healthyCount >= 2 && !hasUnhealthy {
            return CoachMessage(mood: .eating,
                                text: "جميل وجبتك اصبحت مكتملة!",
                                voice: "جميل! وجبتك أصبحت مكتملة ومتوازنة. بالعافية!",
                                recording: added ? food.recording : .interactionHealthy)
        }
 
        // 3) Added something healthy → great choice
        if added {
            return CoachMessage(mood: .excited,
                                text: "اجل هذا اختيار رائع!!",
                                voice: food.voice,
                                recording: food.recording)
        }
 
        // 4) Removed something unhealthy → well done
        if !food.isHealthy {
            return CoachMessage(mood: .excited,
                                text: "أحسنت!",
                                voice: "أحسنت! أصبحت وجبتك صحية أكثر.")
        }
 
        // 5) Removed something healthy → back to normal, say nothing
        return nil
    }
}
 
// MARK: - Food Character Layout Settings
// Adjust character and bubble sizing here for Food Selection, Bread, Rice, Pancake, and Snacks.
// These settings apply only when a page supplies foodLayoutStyle to CharacterPresentation.
// Home, Mission, Task, Ending, and callers using the legacy layout are not changed.
// Moved from App/FoodCharacterLayoutStyle.swift; original files are retained in Archive.
struct FoodCharacterLayoutStyle {
    // Adjust these values to change every food page that explicitly opts in.
    // Preferred visible body height as a fraction of the screen height.
    var bodyHeightFraction: CGFloat = 0.33
    // Keep the preferred body height within these point sizes; available width can limit it further.
    var minimumBodyHeight: CGFloat = 230
    var maximumBodyHeight: CGFloat = 300
    // Increase this value to move the character region farther from the left edge.
    var leadingInset: CGFloat = 12
    // A negative inset lowers the body below the screen edge to hide the waist cut.
    var bottomInset: CGFloat = -20
    // Previous bottom alignment:
    // var bottomInset: CGFloat = 0
    // Reserve this fraction of screen width for all poses, including raised hands.
    var characterRegionWidthFraction: CGFloat = 0.28

    // Bubble width follows the screen width, capped by its maximum and character region.
    var bubbleWidthFraction: CGFloat = 0.25
    var maximumBubbleWidth: CGFloat = 320
    // Space between the bubble and the highest point of any character pose.
    var bubbleGap: CGFloat = 18
    // Arabic text size stays readable; long messages can scroll instead of shrinking.
    var bubbleFontSize: CGFloat = 22
    var bubblePadding: CGFloat = 14
    var bubbleCornerRadius: CGFloat = 22
    var bubbleLineSpacing: CGFloat = 3
    // Keep the bubble below the Back and Listen controls.
    var topControlsClearance: CGFloat = 130

    static let bread = FoodCharacterLayoutStyle()
    // The approved food pages share Bread's size, body baseline, and bubble settings.
    static let foodPages = bread

    func regionWidth(in size: CGSize) -> CGFloat {
        max(0, size.width * characterRegionWidthFraction - leadingInset)
    }

    func bodyHeight(in size: CGSize) -> CGFloat {
        let preferred = min(maximumBodyHeight, max(minimumBodyHeight, size.height * bodyHeightFraction))
        // Fit the widest combined pose envelope, so changing expressions never changes scale.
        let widthLimit = regionWidth(in: size) /
            (FoodCharacterArtwork.maximumLeftReach + FoodCharacterArtwork.maximumRightReach)
        return min(preferred, widthLimit)
    }

    func bubbleWidth(in size: CGSize) -> CGFloat {
        min(maximumBubbleWidth, size.width * bubbleWidthFraction, regionWidth(in: size))
    }
}

// MARK: - Character Artwork Measurements
// These pixel measurements describe the image files, not the desired on-screen size.
// Change them only when the artwork changes; use FoodCharacterLayoutStyle for layout adjustments.
// Moved from App/FoodCharacterArtwork.swift without changing the measurements.
// Measurements use original image pixels, with the origin at the top-left.
// Alpha bounds were measured at opacity > 3%, ignoring almost invisible edge noise.
// bodyTop is the visually inspected crown of the main head shape, excluding bows,
// loose hair tufts, raised hands, and decorative marks. These landmarks are approximate.
// bodyCenterX is the average artwork center near the waist (15–40 pixels above its edge).
// Keeping these measurements separate makes layout settings easy to adjust.
struct FoodCharacterArtwork {
    let canvas: CGSize
    let visibleBounds: CGRect
    let bodyTop: CGFloat
    let bodyCenterX: CGFloat

    var bodyHeight: CGFloat { visibleBounds.maxY - bodyTop }
    var leftReach: CGFloat { (bodyCenterX - visibleBounds.minX) / bodyHeight }
    var rightReach: CGFloat { (visibleBounds.maxX - bodyCenterX) / bodyHeight }
    var topReach: CGFloat { visibleBounds.height / bodyHeight }

    static let measurements: [String: FoodCharacterArtwork] = [
        "boy select page": FoodCharacterArtwork(canvas: CGSize(width: 1168, height: 1424),
            visibleBounds: CGRect(x: 51, y: 50, width: 1066, height: 1322),
            bodyTop: 150, bodyCenterX: 573.83),
        "boy_eating": FoodCharacterArtwork(canvas: CGSize(width: 1380, height: 1328),
            visibleBounds: CGRect(x: 50, y: 48, width: 1281, height: 1228),
            bodyTop: 150, bodyCenterX: 671.17),
        "boy_excited": FoodCharacterArtwork(canvas: CGSize(width: 1268, height: 1412),
            visibleBounds: CGRect(x: 50, y: 48, width: 1168, height: 1314),
            bodyTop: 145, bodyCenterX: 592.92),
        "boy_happy": FoodCharacterArtwork(canvas: CGSize(width: 1168, height: 1424),
            visibleBounds: CGRect(x: 51, y: 50, width: 1066, height: 1322),
            bodyTop: 150, bodyCenterX: 573.83),
        "boy_overjoyed": FoodCharacterArtwork(canvas: CGSize(width: 1552, height: 1420),
            visibleBounds: CGRect(x: 51, y: 48, width: 1462, height: 1321),
            bodyTop: 150, bodyCenterX: 831.33),
        "boy_strong": FoodCharacterArtwork(canvas: CGSize(width: 1268, height: 1412),
            visibleBounds: CGRect(x: 50, y: 48, width: 1168, height: 1314),
            bodyTop: 145, bodyCenterX: 592.92),
        "boy_thinking": FoodCharacterArtwork(canvas: CGSize(width: 1240, height: 1332),
            visibleBounds: CGRect(x: 49, y: 50, width: 1140, height: 1231),
            bodyTop: 160, bodyCenterX: 648.00),
        "boy_thumbsUp": FoodCharacterArtwork(canvas: CGSize(width: 1348, height: 1420),
            visibleBounds: CGRect(x: 51, y: 51, width: 1250, height: 1319),
            bodyTop: 155, bodyCenterX: 647.50),
        "boy_yummy": FoodCharacterArtwork(canvas: CGSize(width: 1208, height: 1332),
            visibleBounds: CGRect(x: 50, y: 51, width: 1109, height: 1229),
            bodyTop: 155, bodyCenterX: 627.17),
        // The replacement selection image is identical to girl_happy, so its measurements match.
        "girl select page": FoodCharacterArtwork(canvas: CGSize(width: 1064, height: 1004),
            visibleBounds: CGRect(x: 41, y: 27, width: 974, height: 933),
            bodyTop: 132, bodyCenterX: 522.92),
        // Previous measurements for 01_smiling.png:
        // "girl select page": FoodCharacterArtwork(canvas: CGSize(width: 266, height: 251),
        //     visibleBounds: CGRect(x: 10, y: 6, width: 246, height: 235),
        //     bodyTop: 33, bodyCenterX: 124.92),
        "girl_eating": FoodCharacterArtwork(canvas: CGSize(width: 1064, height: 1008),
            visibleBounds: CGRect(x: 7, y: 36, width: 1014, height: 930),
            bodyTop: 142, bodyCenterX: 507.25),
        "girl_excited": FoodCharacterArtwork(canvas: CGSize(width: 1344, height: 1220),
            visibleBounds: CGRect(x: 42, y: 41, width: 1260, height: 1136),
            bodyTop: 170, bodyCenterX: 708.67),
        "girl_happy": FoodCharacterArtwork(canvas: CGSize(width: 1064, height: 1004),
            visibleBounds: CGRect(x: 41, y: 27, width: 974, height: 933),
            bodyTop: 132, bodyCenterX: 522.92),
        "girl_overjoyed": FoodCharacterArtwork(canvas: CGSize(width: 1344, height: 1220),
            visibleBounds: CGRect(x: 42, y: 41, width: 1260, height: 1136),
            bodyTop: 170, bodyCenterX: 708.67),
        "girl_strong": FoodCharacterArtwork(canvas: CGSize(width: 1288, height: 1252),
            visibleBounds: CGRect(x: 43, y: 42, width: 1205, height: 1167),
            bodyTop: 155, bodyCenterX: 632.75),
        "girl_thinking": FoodCharacterArtwork(canvas: CGSize(width: 1200, height: 1192),
            visibleBounds: CGRect(x: 44, y: 43, width: 1113, height: 1107),
            bodyTop: 150, bodyCenterX: 582.50),
        "girl_thumbsUp": FoodCharacterArtwork(canvas: CGSize(width: 1144, height: 1192),
            visibleBounds: CGRect(x: 43, y: 43, width: 1058, height: 1105),
            bodyTop: 120, bodyCenterX: 593.33),
        "girl_yummy": FoodCharacterArtwork(canvas: CGSize(width: 1196, height: 1164),
            visibleBounds: CGRect(x: 43, y: 43, width: 1100, height: 1078),
            bodyTop: 145, bodyCenterX: 628.08),
    ]

    // Reserve space for every pose of both characters, not only the current expression.
    // This keeps the body scale, horizontal anchor, and bubble baseline steady.
    // Retain the original selection image as a size reference only.
    // Replacing it with tighter artwork must not resize Bread's already-approved characters.
    private static let normalizationReference = FoodCharacterArtwork(
        canvas: CGSize(width: 266, height: 251),
        visibleBounds: CGRect(x: 10, y: 6, width: 246, height: 235),
        bodyTop: 33, bodyCenterX: 124.92
    )
    private static let poseMeasurements = Array(measurements.values) + [normalizationReference]
    static let maximumLeftReach = poseMeasurements.map(\.leftReach).max() ?? 1
    static let maximumRightReach = poseMeasurements.map(\.rightReach).max() ?? 1
    static let maximumTopReach = poseMeasurements.map(\.topReach).max() ?? 1
    // Previous envelope calculation:
    // static let maximumLeftReach = measurements.values.map(\.leftReach).max() ?? 1
    // static let maximumRightReach = measurements.values.map(\.rightReach).max() ?? 1
    // static let maximumTopReach = measurements.values.map(\.topReach).max() ?? 1
}

// MARK: - Food Character and Speech Bubble Drawing
// Apply the settings and artwork measurements together to keep poses consistently sized.
// Moved from App/FoodCharacterPresentation.swift without changing layout calculations.
// Only callers that supply FoodCharacterLayoutStyle use this presentation.
struct FoodCharacterPresentation: View {
    let imageName: String
    let message: CoachMessage?
    let style: FoodCharacterLayoutStyle
    let artwork: FoodCharacterArtwork

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let bodyHeight = style.bodyHeight(in: size)
            let imageScale = bodyHeight / artwork.bodyHeight
            let baseline = size.height - style.bottomInset
            let bodyCenterX = style.leadingInset +
                FoodCharacterArtwork.maximumLeftReach * bodyHeight
            let bubbleBottom = baseline -
                FoodCharacterArtwork.maximumTopReach * bodyHeight - style.bubbleGap
            let bubbleHeight = max(0, bubbleBottom - style.topControlsClearance)
            let bubbleWidth = style.bubbleWidth(in: size)

            ZStack(alignment: .topLeading) {
                // Use one scale for both dimensions so the artwork never stretches.
                // Align the measured waist edge, ignoring the transparent PNG margin.
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: artwork.canvas.width * imageScale,
                           height: artwork.canvas.height * imageScale)
                    .position(
                        x: bodyCenterX + (artwork.canvas.width / 2 - artwork.bodyCenterX) * imageScale,
                        y: baseline + (artwork.canvas.height / 2 - artwork.visibleBounds.maxY) * imageScale
                    )
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)

                if let message {
                    FoodCharacterBubble(text: message.text, style: style)
                        .frame(width: bubbleWidth, height: bubbleHeight, alignment: .bottom)
                        .position(x: style.leadingInset + style.regionWidth(in: size) / 2,
                                  y: style.topControlsClearance + bubbleHeight / 2)
                }
            }
            .frame(width: size.width, height: size.height)
        }
        // Only this opted-in artwork reaches the physical screen edge.
        .ignoresSafeArea()
        .environment(\.layoutDirection, .leftToRight)
    }
}

private struct FoodCharacterBubble: View {
    let text: String
    let style: FoodCharacterLayoutStyle

    var body: some View {
        // Short messages hug the bottom of the bubble region.
        // Longer messages use its available height instead of shrinking Arabic text.
        ViewThatFits(in: .vertical) {
            FoodCharacterBubbleText(text: text, style: style)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                FoodCharacterBubbleText(text: text, style: style)
            }
            .allowsHitTesting(true)
        }
        .background(.white.opacity(0.95),
                    in: RoundedRectangle(cornerRadius: style.bubbleCornerRadius))
        .environment(\.layoutDirection, .rightToLeft)
    }
}

private struct FoodCharacterBubbleText: View {
    let text: String
    let style: FoodCharacterLayoutStyle

    var body: some View {
        Text(text)
            .font(.system(size: style.bubbleFontSize, weight: .medium, design: .rounded))
            .foregroundStyle(Color(white: 0.25))
            .multilineTextAlignment(.center)
            .lineSpacing(style.bubbleLineSpacing)
            .padding(style.bubblePadding)
            .frame(maxWidth: .infinity)
    }
}

// MARK: - The character with her/his speech bubble (use it on any screen)
 
// One layout for every standalone coach, independent of each page's food canvas.
struct CharacterPresentation: View {
    let character: String
    var message: CoachMessage? = nil
    var imageName: String? = nil
    var mood: Mood = .happy
    var foodLayoutStyle: FoodCharacterLayoutStyle? = nil

    var body: some View {
        let resolvedImage = imageName ?? "\(character)_\((message?.mood ?? mood).rawValue)"
        if let foodLayoutStyle,
           let artwork = FoodCharacterArtwork.measurements[resolvedImage] {
            FoodCharacterPresentation(imageName: resolvedImage, message: message,
                                      style: foodLayoutStyle, artwork: artwork)
        } else {
            // Existing callers and unmeasured images keep their original presentation.
            LegacyCharacterPresentation(character: character, message: message,
                                        imageName: imageName, mood: mood)
        }
    }
}

// Previous shared implementation, preserved here for reference.
// struct CharacterPresentation: View {
//     let character: String
//     var message: CoachMessage? = nil
//     var imageName: String? = nil
//     var mood: Mood = .happy
// 
//     var body: some View {
//         GeometryReader { geometry in
//             let width = geometry.size.width
//             let height = geometry.size.height
//             let characterSize = min(width * 0.22, height * 0.32)
//             let sidePadding = width * 0.025
//             let bottomPadding = height * 0.03
// 
//             VStack(spacing: 8) {
//                 if let message {
//                     Text(message.text)
//                         .font(.system(size: 22, weight: .medium, design: .rounded))
//                         .foregroundStyle(Color(white: 0.25))
//                         .multilineTextAlignment(.center)
//                         .lineLimit(5)
//                         .minimumScaleFactor(0.65)
//                         .padding(12)
//                         .frame(width: characterSize)
//                         .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 22))
//                         .environment(\.layoutDirection, .rightToLeft)
//                 }
// 
//                 Image(imageName ?? "\(character)_\((message?.mood ?? mood).rawValue)")
//                     .resizable()
//                     .scaledToFit()
//                     .frame(width: characterSize, height: characterSize, alignment: .bottom)
//                     .accessibilityHidden(true)
//             }
//             .padding(.leading, sidePadding)
//             .padding(.bottom, bottomPadding)
//             .frame(width: width, height: height, alignment: .bottomLeading)
//         }
//         // The artwork stays on the same physical side on all Arabic meal pages.
//         .environment(\.layoutDirection, .leftToRight)
//         .allowsHitTesting(false)
//     }
// }

// The original layout remains active for pages that have not opted in.
private struct LegacyCharacterPresentation: View {
    let character: String
    var message: CoachMessage? = nil
    var imageName: String? = nil
    var mood: Mood = .happy

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let characterSize = min(width * 0.22, height * 0.32)
            let sidePadding = width * 0.025
            let bottomPadding = height * 0.03

            VStack(spacing: 8) {
                if let message {
                    Text(message.text)
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(white: 0.25))
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .minimumScaleFactor(0.65)
                        .padding(12)
                        .frame(width: characterSize)
                        .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 22))
                        .environment(\.layoutDirection, .rightToLeft)
                }

                Image(imageName ?? "\(character)_\((message?.mood ?? mood).rawValue)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: characterSize, height: characterSize, alignment: .bottom)
                    .accessibilityHidden(true)
            }
            .padding(.leading, sidePadding)
            .padding(.bottom, bottomPadding)
            .frame(width: width, height: height, alignment: .bottomLeading)
        }
        // The artwork stays on the same physical side on all Arabic meal pages.
        .environment(\.layoutDirection, .leftToRight)
        .allowsHitTesting(false)
    }
}

// MARK: - Snack Coach Messages

extension Coach {
    static func snackReaction(id: String, addedAddition: Bool) -> CoachMessage {
        let recording: IngredientVoice.Recording?
        switch (id, addedAddition) {
        case ("apple", false): recording = .snackApple
        case ("chips", false): recording = .snackChips
        case ("popcorn", false): recording = .snackPopcorn
        case ("candy", false): recording = .snackCandy
        case ("candy", true): recording = .snackNuts
        case ("chips", true): recording = .snackChipsYogurt
        case ("cookies", false): recording = .snackCookies
        case ("cookies", true): recording = .snackMilk
        case ("popcorn", true): recording = .snackPopcornOrange
        default: recording = nil
        }

        // I celebrate apple and popcorn without asking for an improvement.
        let isReady = addedAddition || id == "apple" || id == "popcorn"
        return CoachMessage(
            mood: isReady ? .happy : .thinking,
            text: isReady
            // I keep my previous code here for reference.
            // return CoachMessage(
            //     mood: addedAddition ? .happy : .thinking,
            //     text: addedAddition
                ? "أحسنت! هذا رائع!"
                : "لذيذ! لكن دعنا نفكر للحظة.. كيف تحسن اختيارنا؟",
            voice: "",
            recording: recording
        )
    }
}

// MARK: - Pancake Coach Messages

extension Coach {

   // When adding a topping
   static func pancakeAdded(id: String) -> CoachMessage {
       switch id {

       case "chocolate":
           return CoachMessage(
               mood: .excited,
               text: "واو! الشوكولاتة لذيذة! 🍫",
               voice: "واو! أضفت الشوكولاتة إلى البانكيك!",
               recording: .pancakeChocolate
           )

       case "strawberry":
           return CoachMessage(
               mood: .happy,
               text: "اختيار جميل! 🍓",
               voice: "رائع! الفراولة تضيف لونًا جميلًا إلى وجبتك!",
               recording: .pancakeStrawberry
           )

       case "banana":
           return CoachMessage(
               mood: .excited,
               text: "أحسنت! الموز رائع! 🍌",
               voice: "أحسنت! الموز إضافة لذيذة ومغذية!",
               recording: .pancakeBanana
           )

       case "honey":
           return CoachMessage(
               mood: .happy,
               text: "يا سلام! عسل! 🍯",
               voice: "جميل! أضفت العسل إلى البانكيك!",
               recording: .pancakeHoney
           )

       default:
           return CoachMessage(
               mood: .happy,
               text: "اختيار جميل!",
               voice: "اختيار جميل!"
           )
       }
   }

   // When removing a topping
   static func pancakeRemoved(name: String) -> CoachMessage {
       CoachMessage(
           mood: .thinking,
           text: "ماذا نختار الآن؟ 🤔",
           voice: "أزلنا \(name). ماذا تريد أن تختار الآن؟"
       )
   }

   // When selecting honey and chocolate together
   static func pancakeSauceConflict() -> CoachMessage {
       CoachMessage(
           mood: .thinking,
           text: "اختَر صوصًا واحدًا بس! 🍯🍫",
           voice: "يمكنك اختيار العسل أو الشوكولاتة، وليس الاثنين معًا."
       )
   }

   // When finishing the meal
   static func pancakeFinished() -> CoachMessage {
       CoachMessage(
           mood: .eating,
           text: "أحسنت! جهزت وجبتك! 🎉",
           voice: "أحسنت! لقد جهزت وجبتك! بالعافية!"
       )
   }
}

 
