import SwiftUI


// Shared presentation requirements for Bread's ingredient choices.
protocol BreadIngredient: RawRepresentable, Identifiable, Hashable where RawValue == String {
    var title: String { get }
    var benefit: IngredientBenefit { get }
}

extension BreadIngredient {
    var id: String { rawValue }
    var icon: String { rawValue }
}

// MARK: - Spreads
// CaseIterable provides allCases for the pickers; Identifiable gives each choice a stable identity.
enum ToastBase: String, CaseIterable, BreadIngredient {
    case chocolate
    case cheese

    var title: String {
        switch self {
        case .chocolate: return "شوكولاتة"
        case .cheese: return "جبن"
        }
    }

    var spreadScale: CGFloat { self == .chocolate ? 0.96 : 0.84 }

    // Full image dimensions and visible bounds are both needed to account for transparent margins.
    var canvasSize: CGSize {
        self == .chocolate
            ? CGSize(width: 833, height: 736)
            : CGSize(width: 813, height: 690)
    }

    var artworkBounds: CGRect {
        self == .chocolate
            ? CGRect(x: 41, y: 29, width: 761, height: 656)
            : CGRect(x: 48, y: 31, width: 756, height: 623)
    }

    var toppingImage: String {
        switch self {
        case .chocolate: return "chocolate spread"
        case .cheese: return "cheese slice"
        }
    }
}

// MARK: - Proteins
enum ToastProtein: String, CaseIterable, BreadIngredient {
    case egg
    case chicken = "Chicken"
    case turkey

    var title: String {
        switch self {
        case .egg: return "بيض"
        case .chicken: return "دجاج"
        case .turkey: return "ديك رومي"
        }
    }

    var toppingImage: String { rawValue }
}

// MARK: - Vegetables
enum ToastVegetable: String, CaseIterable, BreadIngredient {
    case lettuce
    case tomato
    case cucumber

    var title: String {
        switch self {
        case .lettuce: return "خس"
        case .tomato: return "طماطم"
        case .cucumber: return "خيار"
        }
    }

    var toppingImage: String {
        switch self {
        case .lettuce: return "lettuce"
        case .tomato: return "tomatoSlice"
        case .cucumber: return "cucumber"
        }
    }

    var scale: CGFloat {
        switch self {
        case .lettuce: return 0.86
        case .tomato: return 0.59
        case .cucumber: return 0.39
        }
    }

    // Larger layer values draw on top, keeping smaller toppings visible.
    var layer: Double {
        switch self {
        case .lettuce: return 3
        case .tomato: return 4
        case .cucumber: return 5
        }
    }
}

// MARK: - Fruits
enum ToastFruit: String, CaseIterable, BreadIngredient {
    case banana
    case strawberry
    case apple

    var title: String {
        switch self {
        case .banana: return "موز"
        case .strawberry: return "فراولة"
        case .apple: return "تفاح"
        }
    }

    var scale: CGFloat {
        switch self {
        case .banana: return 0.88
        case .strawberry: return 0.85
        case .apple: return 0.87
        }
    }

    // Fixed differences make stacked fruit look natural without moving on every view update.
    var rotation: Double {
        switch self {
        case .banana: return -3
        case .strawberry: return 4
        case .apple: return -1
        }
    }

    var offset: CGSize {
        switch self {
        case .banana: return CGSize(width: -0.012, height: 0.008)
        case .strawberry: return CGSize(width: 0.014, height: -0.012)
        case .apple: return CGSize(width: 0.004, height: 0.014)
        }
    }

    var piecesImage: String {
        switch self {
        case .banana: return "Banana Slices"
        case .strawberry: return "Strawberry Pieces"
        case .apple: return "Apple Pieces"
        }
    }

    var layer: Double {
        switch self {
        case .banana: return 3
        case .strawberry: return 4
        case .apple: return 5
        }
    }
}

// MARK: - Recipe Pages
enum ToastStep {
    case base
    case protein
    case toppings
    case finished
}


// MARK: - Shared Artwork Measurements
// Measurements come from the image assets; visible bounds exclude transparent margins.
enum ToastArtwork {
    static let breadCanvas = CGSize(width: 705, height: 700)
    static let breadBounds = CGRect(x: 10, y: 0, width: 690, height: 683)
    static let proteinScale: CGFloat = 0.95
    static let sweetLayerOffsetY: CGFloat = -0.025
}
