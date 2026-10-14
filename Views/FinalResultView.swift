import SwiftUI

/// Shown after the last round: final score, rating and high score.
struct FinalResultView: View {
    let vm: GameViewModel
    let onMenu: () -> Void

    private var rating: String {
        switch vm.totalScore {
        case 400...: return "Colour Master"
        case 300...: return "Sharp Eye"
        case 200...: return "Getting There"
        default:     return "Keep Practising"
        }
    }

    var body: some View {
        VStack(spacing: 30) {
            Text("Game Over")
                .font(.system(size: 80, weight: .heavy, design: .rounded))

            Text("\(vm.totalScore) / \(vm.maxScore)")
                .font(.system(size: 110, weight: .bold, design: .rounded))
                .foregroundStyle(.yellow)

            Text(rating)
                .font(.largeTitle)

            if vm.isNewHighScore {
                Text("New high score!")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.green)
            } else {
                Text("High score: \(vm.highScore)")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 40) {
                Button("Play Again") { vm.startNewGame() }
                Button("Main Menu", action: onMenu)
            }
            .buttonStyle(.card)
            .font(.title2.weight(.semibold))
            .padding(.top, 20)
        }
        .padding(60)
    }
}