import SwiftUI
import Observation

enum RoundPhase {
    case memorise   // the colour is shown
    case choose     // pick it from the grid
    case reveal     // see the result
}

/// Holds all the rules and state for a single-player game.
@MainActor
@Observable
final class GameViewModel {

    // MARK: - Game settings
    static let totalRounds = 5
    static let memoriseSeconds = 3
    static let optionCount = 9
    static let spread = 0.14                      // how close the lookalike shades are
    private static let highScoreKey = "colourClashHighScore"

    // MARK: - State the screens read
    private(set) var round = 1
    private(set) var phase: RoundPhase = .memorise
    private(set) var target = GameColor.random()
    private(set) var options: [GameColor] = []
    private(set) var picked: GameColor?
    private(set) var lastPoints = 0
    private(set) var totalScore = 0
    private(set) var secondsLeft = GameViewModel.memoriseSeconds
    private(set) var isFinished = false
    private(set) var isNewHighScore = false
    private(set) var highScore = UserDefaults.standard.integer(forKey: GameViewModel.highScoreKey)
    private(set) var roundToken = 0               // changes every round so the countdown restarts

    init() {
        startNewGame()
    }

    // MARK: - Calculated values
    var isLastRound: Bool { round >= GameViewModel.totalRounds }
    var maxScore: Int { GameViewModel.totalRounds * 100 }

    var feedback: String {
        switch lastPoints {
        case 100: return "Perfect match!"
        case 70...: return "So close!"
        case 40...: return "Not bad!"
        default: return "Way off!"
        }
    }

    // MARK: - Actions

    func startNewGame() {
        round = 1
        totalScore = 0
        isFinished = false
        isNewHighScore = false
        setUpRound()
    }

    /// Counts down while the colour is on screen, then moves to the choosing phase.
    func runMemoriseCountdown() async {
        guard phase == .memorise else { return }
        while secondsLeft > 0 {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return                            // cancelled (e.g. the player left the game)
            }
            secondsLeft -= 1
        }
        phase = .choose
    }

    func choose(_ option: GameColor) {
        guard phase == .choose else { return }
        picked = option
        lastPoints = points(for: option)
        totalScore += lastPoints
        phase = .reveal
    }

    func nextRound() {
        if isLastRound {
            finishGame()
        } else {
            round += 1
            setUpRound()
        }
    }

    // MARK: - Private helpers

    private func setUpRound() {
        target = GameColor.random()
        var all = [target]                        // the exact colour is always in the grid
        for _ in 1..<GameViewModel.optionCount {
            all.append(target.variant(spread: GameViewModel.spread))
        }
        options = all.shuffled()
        picked = nil
        lastPoints = 0
        secondsLeft = GameViewModel.memoriseSeconds
        phase = .memorise
        roundToken += 1
    }

    /// 100 points for the exact colour, fewer the further the pick is from it.
    private func points(for pick: GameColor) -> Int {
        let ratio = target.distance(to: pick) / GameViewModel.spread
        return max(0, min(100, Int(((1 - ratio) * 100).rounded())))
    }

    private func finishGame() {
        isNewHighScore = totalScore > highScore
        if isNewHighScore {
            highScore = totalScore
            UserDefaults.standard.set(highScore, forKey: GameViewModel.highScoreKey)
        }
        isFinished = true
    }
}