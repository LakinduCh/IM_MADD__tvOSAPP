import SwiftUI

/// One colour used in the game, stored as red/green/blue values from 0 to 1.
struct GameColor: Identifiable, Equatable {
    let id = UUID()
    let red: Double
    let green: Double
    let blue: Double

    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }

    /// The colour as a hex code, e.g. "#FF8800".
    var hex: String {
        String(format: "#%02X%02X%02X",
               Int((red * 255).rounded()),
               Int((green * 255).rounded()),
               Int((blue * 255).rounded()))
    }

    /// A random colour, kept away from the extremes so lookalike shades stay valid.
    static func random() -> GameColor {
        GameColor(red: .random(in: 0.15...0.85),
                  green: .random(in: 0.15...0.85),
                  blue: .random(in: 0.15...0.85))
    }

    /// A similar-looking shade. Every channel moves by at least 30% of `spread`,
    /// so a lookalike is never identical to the original.
    func variant(spread: Double) -> GameColor {
        func offset() -> Double {
            let size = Double.random(in: (spread * 0.3)...spread)
            return Bool.random() ? size : -size
        }
        return GameColor(red: min(max(red + offset(), 0), 1),
                         green: min(max(green + offset(), 0), 1),
                         blue: min(max(blue + offset(), 0), 1))
    }

    /// How far apart two colours are, from 0 (same) to about 1 (opposite corners).
    func distance(to other: GameColor) -> Double {
        let dr = red - other.red
        let dg = green - other.green
        let db = blue - other.blue
        return (dr * dr + dg * dg + db * db).squareRoot() / 3.0.squareRoot()
    }
}