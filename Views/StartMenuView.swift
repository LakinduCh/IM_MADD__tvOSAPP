import SwiftUI

/// The start menu: choose Single Player or (soon) Multiplayer.
struct StartMenuView: View {
    let onSinglePlayer: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Text("COLOUR CLASH")
                .font(.system(size: 100, weight: .heavy, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [.pink, .orange, .yellow],
                                                startPoint: .leading,
                                                endPoint: .trailing))

            Text("Memorise the colour. Find it again. Beat your best score.")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(spacing: 24) {
                Button(action: onSinglePlayer) {
                    Label("Single Player", systemImage: "person.fill")
                        .font(.title2.weight(.semibold))
                        .frame(width: 500)
                        .padding(.vertical, 12)
                }

                // Multiplayer is planned for later, so it is switched off for now.
                Button(action: {}) {
                    VStack(spacing: 4) {
                        Label("Multiplayer", systemImage: "person.2.fill")
                            .font(.title2.weight(.semibold))
                        Text("Coming soon")
                            .font(.callout)
                    }
                    .frame(width: 500)
                    .padding(.vertical, 12)
                }
                .disabled(true)
            }
            .buttonStyle(.card)
            .padding(.top, 20)
        }
        .padding(60)
    }
}