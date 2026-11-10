import SwiftUI

struct ContentView: View {
    @StateObject private var model = KaraokeViewModel()

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(model.title).font(.title2.bold())
                Text(model.artist).foregroundStyle(.secondary)
            }
            Spacer()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(Array(model.lyrics.enumerated()), id: \.element.id) { index, line in
                            Text(line.text)
                                .font(index == model.currentIndex ? .title2.bold() : .body)
                                .foregroundStyle(index == model.currentIndex ? Color.primary : Color.secondary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .id(line.id)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: model.currentIndex) { _, index in
                    guard model.lyrics.indices.contains(index) else { return }
                    withAnimation { proxy.scrollTo(model.lyrics[index].id, anchor: .center) }
                }
            }
            Spacer()
            HStack(spacing: 28) {
                Button { model.currentTime = max(0, model.currentTime - 10) } label: { Image(systemName: "gobackward.10").font(.title) }
                Button { model.togglePlayback() } label: { Image(systemName: model.isPlaying ? "pause.fill" : "play.fill").font(.largeTitle) }
                Button { model.currentTime += 10 } label: { Image(systemName: "goforward.10").font(.title) }
            }
            Text("\(model.currentTime, specifier: "%.1f") 秒")
                .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            if let message = model.errorMessage { Text(message).font(.caption).foregroundStyle(.red) }
        }
        .padding()
    }
}
