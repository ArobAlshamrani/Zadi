//
//  CharacterCoach.swift
//  Projectزادي
//
//  Created by Nouf Fayez on 14/05/1448 AH.
//

import SwiftUI
import AVFoundation
 
// MARK: - Food (used by every meal screen)
 
struct Food: Hashable {
    let id: String           // used in the logic, e.g. "chicken"
    let arabicName: String   // shown under the icon
    let icon: String         // image name in Assets
    var isHealthy: Bool = true
    var voice: String = ""   // what the character says when this food is picked
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
}
 
// MARK: - The rules (same for all meals)
 
enum Coach {
 
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
                                voice: food.voice)
        }
 
        // 2) The meal is balanced (2 or more healthy foods, nothing unhealthy)
        if healthyCount >= 2 && !hasUnhealthy {
            return CoachMessage(mood: .eating,
                                text: "جميل وجبتك اصبحت مكتملة!",
                                voice: "جميل! وجبتك أصبحت مكتملة ومتوازنة. بالعافية!")
        }
 
        // 3) Added something healthy → great choice
        if added {
            return CoachMessage(mood: .excited,
                                text: "اجل هذا اختيار رائع!!",
                                voice: food.voice)
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
 
// MARK: - Voice (Arabic, built into the iPad)
 
final class Speaker {
    static let shared = Speaker()
    private let synthesizer = AVSpeechSynthesizer()
 
    func say(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)   // stop the previous sentence
        guard !text.isEmpty else { return }
 
        let sentence = AVSpeechUtterance(string: text)
        sentence.voice = AVSpeechSynthesisVoice(language: "ar-SA")
        sentence.rate = 0.45                       // a bit slow, for kids
        synthesizer.speak(sentence)
    }
 
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
 
// MARK: - The character with her/his speech bubble (use it on any screen)
 
struct CharacterView: View {
    let character: String          // "girl" or "boy"
    let message: CoachMessage?     // nil = just smiling, no bubble
 
    var body: some View {
        let mood = message?.mood ?? .happy
 
        Image("\(character)_\(mood.rawValue)")
            .resizable()
            .scaledToFit()
            .frame(width: 287, height: 287)
            // The bubble sits above the character's head
            .overlay(alignment: .top) {
                if let message {
                    bubble(message.text)
                        .alignmentGuide(.top) { $0[.bottom] - 10 }
                        .offset(x: 70)
                        .id(message.text)
                        .transition(.scale(scale: 0.6, anchor: .bottomLeading).combined(with: .opacity))
                }
            }
            .animation(.spring, value: message?.text)
    }
 
    // White thought bubble with the short text + two small dots
    func bubble(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color(white: 0.25))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 26))
 
            Circle().fill(.white.opacity(0.92)).frame(width: 18, height: 18).padding(.leading, 30)
            Circle().fill(.white.opacity(0.92)).frame(width: 11, height: 11).padding(.leading, 22)
        }
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}
 

// MARK: - Pancake Coach Messages

extension Coach {

   // When the child adds a topping
   static func pancakeAdded(id: String) -> CoachMessage {

       switch id {

       case "chocolate":
           return CoachMessage(
               mood: .excited,
               text: "واو! الشوكولاتة لذيذة! 🍫",
               voice: "واو! أضفت الشوكولاتة إلى البانكيك!"
           )

       case "strawberry":
           return CoachMessage(
               mood: .happy,
               text: "اختيار جميل! 🍓",
               voice: "رائع! الفراولة تضيف لونًا جميلًا إلى وجبتك!"
           )

       case "banana":
           return CoachMessage(
               mood: .excited,
               text: "أحسنت! الموز رائع! 🍌",
               voice: "أحسنت! الموز إضافة لذيذة ومغذية!"
           )

       case "honey":
           return CoachMessage(
               mood: .happy,
               text: "يا سلام! عسل! 🍯",
               voice: "جميل! أضفت العسل إلى البانكيك!"
           )

       default:
           return CoachMessage(
               mood: .happy,
               text: "اختيار جميل!",
               voice: "اختيار جميل!"
           )
       }
   }

   // When the child removes a topping
   static func pancakeRemoved(name: String) -> CoachMessage {
       CoachMessage(
           mood: .thinking,
           text: "ماذا نختار الآن؟ 🤔",
           voice: "أزلنا \(name). ماذا تريد أن تختار الآن؟"
       )
   }

   // When the child tries honey and chocolate together
   static func pancakeSauceConflict() -> CoachMessage {
       CoachMessage(
           mood: .thinking,
           text: "اختَر صوصًا واحدًا بس! 🍯🍫",
           voice: "يمكنك اختيار العسل أو الشوكولاتة، وليس الاثنين معًا."
       )
   }

   // When the child finishes
   static func pancakeFinished() -> CoachMessage {
       CoachMessage(
           mood: .eating,
           text: "أحسنت! جهزت وجبتك! 🎉",
           voice: "أحسنت! لقد جهزت وجبتك! بالعافية!"
       )
   }
}
