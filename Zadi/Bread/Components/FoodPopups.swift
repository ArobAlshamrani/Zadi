import SwiftUI

// MARK: - Ingredient Messages
// Ingredient information used by the shared coach and Bread's prerecorded audio.
enum IngredientBenefit: String {
    case chocolate
    case cheese
    case egg
    case chicken
    case turkey
    case lettuce
    case tomato
    case cucumber
    case banana
    case strawberry
    case apple
    
    var message: String {
        switch self {
        case .chocolate:
            return "الشوكولاتة لذيذة! لكن جسمنا يحتاج إلى أطعمة متنوعة ليبقى قويًا. ما رأيك أن نضيف بعض الفواكه؟"
            
        case .cheese:
            return "الجبن يمنحنا الكالسيوم الذي يساعد على تقوية عظامنا وأسناننا!"
            
        case .egg:
            return "البيض مليء بالبروتين الذي يساعد على بناء عضلاتنا!"
            
        case .chicken:
            return "الدجاج يمنح عضلاتنا ما تحتاجه لنلعب ونتحرك بنشاط!"
            
        case .turkey:
            return "الديك الرومي مصدر للبروتين الذي يساعد جسمنا على إصلاح خلاياه وتجديدها!"
            
        case .lettuce:
            return "الخس يساعدنا على هضم الطعام بسهولة!"
            
        case .tomato:
            return "الطماطم تحتوي على فيتامين ج، الذي يساعد جسمنا على الاستفادة من الحديد الموجود في الطعام!"
            
        case .cucumber:
            return "الخيار يحتوي على فيتامين ك، الذي يساعد على الحفاظ على صحة عظامنا!"
            
        case .banana:
            return "الموز يمنحنا طاقة للعب والقفز!"
            
        case .strawberry:
            return "الفراولة تحتوي على فيتامين ج، الذي يساعد جسمنا على مقاومة الأمراض!"
            
        case .apple:
            return "التفاح يحتوي على مواد مفيدة تساعد على حماية خلايا جسمنا!"
        }
    }
    
}
// MARK: - Food-to-Message Mapping
// Extensions add a benefit property to existing food types without changing their definitions.
extension ToastBase {
    var benefit: IngredientBenefit {
        switch self {
        case .chocolate: return .chocolate
        case .cheese: return .cheese
        }
    }
}

extension ToastProtein {
    var benefit: IngredientBenefit {
        switch self {
        case .egg: return .egg
        case .chicken: return .chicken
        case .turkey: return .turkey
        }
    }
}

extension ToastFruit {
    var benefit: IngredientBenefit {
        switch self {
        case .banana: return .banana
        case .strawberry: return .strawberry
        case .apple: return .apple
        }
    }
}

extension ToastVegetable {
    var benefit: IngredientBenefit {
        switch self {
        case .lettuce: return .lettuce
        case .tomato: return .tomato
        case .cucumber: return .cucumber
        }
    }
}

// Bread adapts its ingredients to the shared coach
extension IngredientBenefit {
    var coachFood: Food {
        // Match by benefit because artwork names can differ from ingredient IDs (e.g. "Chicken").
        let title = ToastBase.allCases.first { $0.benefit == self }?.title
            ?? ToastProtein.allCases.first { $0.benefit == self }?.title
            ?? ToastVegetable.allCases.first { $0.benefit == self }?.title
            ?? ToastFruit.allCases.first { $0.benefit == self }?.title
            ?? rawValue
        return Food(id: rawValue, arabicName: title, icon: rawValue,
                    isHealthy: self != .chocolate, voice: message)
    }
}

extension IngredientBenefit {
    func coachReaction(added: Bool, selected: [Food]) -> CoachMessage? {
        let food = coachFood
        let reaction = Coach.react(to: food, added: added, selected: selected)
        if added && self == .chocolate {
            return CoachMessage(mood: .thinking, text: "دعنا نفكر", voice: message)
        }
        // Ingredient taps must not declare the recipe complete. Ask the shared coach
        // for its single-ingredient encouragement instead of copying that message.
        if reaction?.mood == .eating {
            return added ? Coach.react(to: food, added: true, selected: [food]) : nil
        }
        return reaction
    }
}

// Bread-specific placement; the coach and popup remain unchanged.
struct BreadCoachPopup: View {
    let character: String
    let message: CoachMessage

    var body: some View {
        GeometryReader { geometry in
            let characterWidth = min(260, geometry.size.width * 0.19)
            let characterHeight = min(320, geometry.size.height * 0.38)
            let bubbleWidth = min(220, geometry.size.width * 0.16)

            ZStack(alignment: .bottomLeading) {
                Image("\(character)_\(message.mood.rawValue)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: characterWidth, height: characterHeight, alignment: .bottom)
                    // The portraits end at the torso. Seat that edge at the screen edge.
                    .offset(y: 28)
                    .accessibilityHidden(true)

                Text(message.text)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(white: 0.25))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .frame(width: bubbleWidth)
                    .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 26))
                    .overlay(alignment: .bottomLeading) {
                        BreadSpeechTail()
                            .fill(.white.opacity(0.92))
                            .frame(width: 44, height: 38)
                            .offset(x: 12, y: 37)
                    }
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                    .offset(x: characterWidth * 0.70, y: -characterHeight * 0.42)
            }
            .animation(.spring, value: message.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .ignoresSafeArea(edges: .bottom)
        .environment(\.layoutDirection, .leftToRight)
    }
}

private struct BreadSpeechTail: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.width * 0.35, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            path.closeSubpath()
        }
    }
}

#Preview("Bread coach girl", traits: .landscapeLeft) {
    BreadCoachPopup(character: "girl", message: CoachMessage(
        mood: .thinking, text: "حسنا دعنا نفكر للحظة...", voice: ""))
        .background(Color.gray.opacity(0.15))
}

#Preview("Bread coach boy", traits: .landscapeLeft) {
    BreadCoachPopup(character: "boy", message: CoachMessage(
        mood: .excited, text: "اجل هذا اختيار رائع!!", voice: ""))
        .background(Color.gray.opacity(0.15))
}
