import SwiftUI

/// One round of the game: memorise, choose, then reveal.
struct RoundView: View {
    let vm: GameViewModel

    // Three fixed columns for the 3x3 grid of shades.
    private let columns = Array(repeating: GridItem(.fixed(260), spacing: 40), count: 3)

    var body: some View {
        VStack(spacing: 30) {
            header

            Group {
                switch vm.phase {
                case .memorise: memoriseView
                case .choose:   chooseView
                case .reveal:   revealView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
        }
        .padding(60)
        .animation(.easeInOut(duration: 0.35), value: vm.phase)
        // Restarts the countdown at the start of every round.
        .task(id: vm.roundToken) {
            await vm.runMemoriseCountdown()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Round \(vm.round) of \(GameViewModel.totalRounds)")
            Spacer()
            Text("Score: \(vm.totalScore)")
        }
        .font(.title2.weight(.semibold))
    }

    // MARK: - Phase 1: memorise

    private var memoriseView: some View {
        VStack(spacing: 24) {
            Text("Remember this colour!")
                .font(.title)
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(vm.target.color)
                .frame(maxWidth: 900, maxHeight: 420)
                .overlay {
                    Text("\(vm.secondsLeft)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(radius: 8)
                }
        }
    }

    // MARK: - Phase 2: choose

    private var chooseView: some View {
        VStack(spacing: 24) {
            Text("Which one was it?")
                .font(.title)
            LazyVGrid(columns: columns, spacing: 40) {
                ForEach(Array(vm.options.enumerated()), id: \.element.id) { index, option in
                    Button {
                        vm.choose(option)
                    } label: {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(option.color)
                            .frame(width: 260, height: 130)
                    }
                    .buttonStyle(.card)
                    .accessibilityLabel("Colour option \(index + 1)")
                }
            }
        }
    }

    // MARK: - Phase 3: reveal

    private var revealView: some View {
        VStack(spacing: 30) {
            HStack(spacing: 60) {
                swatch(title: "Target", color: vm.target)
                if let picked = vm.picked {
                    swatch(title: "Your pick", color: picked)
                }
            }

            Text(vm.feedback)
                .font(.title)
            Text("+\(vm.lastPoints) points")
                .font(.largeTitle.bold())
                .foregroundStyle(.yellow)

            Button(vm.isLastRound ? "See Results" : "Next Round") {
                vm.nextRound()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func swatch(title: String, color: GameColor) -> some View {
        VStack(spacing: 16) {
            Text(title).font(.title3)
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(color.color)
                .frame(width: 380, height: 240)
            Text(color.hex)
                .font(.title3.monospaced())
        }
    }
}