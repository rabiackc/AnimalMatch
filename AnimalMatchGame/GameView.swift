import SwiftUI

struct GameView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Oyuna Hoş Geldin!")
                .font(.largeTitle)
                .bold()

            Text("Burada oyun ekranı olacak.")
                .font(.headline)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    GameView()
}

