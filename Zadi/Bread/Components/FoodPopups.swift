import SwiftUI

// MARK: - Ingredient Messages
// Keep the text and matching illustration together for each ingredient.
enum IngredientBenefit: String, Identifiable {
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
    
    var id: String { rawValue }
    
    var characterImage: String {
        switch self {
        case .chocolate: return "Girl thinking"
        case .cheese: return "Girl Approval"
        case .egg: return "Girl Celebrate"
        case .chicken: return "Girl Approval"
        case .turkey: return "Girl Wink"
        case .lettuce: return "Girl Happy"
        case .tomato: return "Girl Excited"
        case .cucumber: return "Girl Happy"
        case .banana: return "Girl Celebrate"
        case .strawberry: return "Girl Excited"
        case .apple: return "Girl Wink"
        }
    }
    
    
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

// MARK: - Ingredient Popup
// ToastView decides which message appears; this view only presents it.
struct IngredientBenefitPopup: View {
    let benefit: IngredientBenefit
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // Grow the message font with the user's preferred text size.
    @ScaledMetric(relativeTo: .title3) private var messageSize: CGFloat = 21

    private let cream = Color(red: 1, green: 240.0 / 255, blue: 217.0 / 255)
    private let ink = Color(red: 0.20, green: 0.28, blue: 0.55)

    var body: some View {
        // Keep the companion at the physical left edge; only the message uses Arabic reading direction.
        GeometryReader { geometry in
            let bubbleWidth = min(310, max(240, geometry.size.width * 0.26))
            let girlHeight = min(325, geometry.size.height * 0.40)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 16) {
                        Text(benefit.message)
                            .font(.system(size: messageSize, weight: .semibold))
                            .foregroundStyle(ink)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                    }
                    .padding(20)
                    .frame(width: bubbleWidth)
                    .background(cream, in: RoundedRectangle(cornerRadius: 26))
                    .shadow(color: .black.opacity(0.10), radius: 6, y: 3)
                    .environment(\.layoutDirection, .rightToLeft)
                    .padding(.leading, 24)

                    // Small circles make the message look like a thought bubble.
                    VStack(spacing: 5) {
                        Circle().frame(width: 16, height: 16)
                            .offset(x: 10)
                        Circle().frame(width: 10, height: 10)
                    }
                    .foregroundStyle(cream)
                    .padding(.leading, girlHeight * 0.62)
                    .padding(.vertical, 6)
                    .accessibilityHidden(true)

                    Image(benefit.characterImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: girlHeight, alignment: .bottom)
                        // Hide the illustration's cut edge just below the screen.
                        .offset(y: girlHeight * 0.07)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .frame(minHeight: geometry.size.height, alignment: .bottomLeading)
            }
            .scrollIndicators(.hidden)
            .clipped()
            .frame(width: min(geometry.size.width, bubbleWidth + 48))
        }
        .ignoresSafeArea(edges: .bottom)
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityElement(children: .contain)
        // Use a fade instead of movement when Reduce Motion is enabled.
        .transition(reduceMotion ? .opacity : .offset(y: 24).combined(with: .opacity))
    }
}

// MARK: - Chocolate Popup
struct ChocolatePopup: View {
    var body: some View {
        IngredientBenefitPopup(benefit: .chocolate)
    }
}


// MARK: - Preview
#Preview("Ingredient benefit", traits: .landscapeLeft) {
    IngredientBenefitPopup(benefit: .strawberry)
}
