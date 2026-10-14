import SwiftUI

/// Decides which screen is showing: the start menu or the game.
struct RootView: View {
    enum Screen { case menu, playing }

    @State private var screen: Screen = .menu
    @State private var game = GameViewModel()

    var body: some View {
        ZStack {
            AppBackground()

            switch screen {
            case .menu:
                StartMenuView(onSinglePlayer: {
                    game.startNewGame()
                    screen = .playing
                })

            case .playing:
                Group {
                    if game.isFinished {
                        FinalResultView(vm: game, onMenu: { screen = .menu })
                    } else {
                        RoundView(vm: game)
                    }
                }
                // The Menu button on the Apple TV remote returns to the start menu.
                .onExitCommand { screen = .menu }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screen)
    }
}

/// The purple gradient behind every screen.
struct AppBackground: View {
    var body: some View {
        LinearGradient(colors: [Color(red: 0.08, green: 0.06, blue: 0.18),
                                Color(red: 0.22, green: 0.10, blue: 0.38)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}