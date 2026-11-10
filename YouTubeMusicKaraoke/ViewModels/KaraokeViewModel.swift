import Foundation
import Combine

@MainActor
final class KaraokeViewModel: ObservableObject {
    @Published var title = "示範歌曲"
    @Published var artist = "Demo Artist"
    @Published var lyrics = LRCParser.parse("""
    [00:00.00]YouTube Music Karaoke
    [00:04.00]將來在這裡顯示同步歌詞
    [00:08.00]目前使用示範時間軸
    [00:12.00]尚未連接 YouTube Music 播放
    """)
    @Published var currentTime: TimeInterval = 0
    @Published var isPlaying = false
    @Published var errorMessage: String?

    private var timer: AnyCancellable?

    var currentIndex: Int {
        max(0, lyrics.lastIndex(where: { $0.time <= currentTime }) ?? 0)
    }

    func togglePlayback() {
        isPlaying.toggle()
        timer?.cancel()
        guard isPlaying else { return }
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            guard let self else { return }
            self.currentTime += 0.1
            if let last = self.lyrics.last, self.currentTime > last.time + 5 {
                self.isPlaying = false
                self.timer?.cancel()
            }
        }
    }

    func loadLyrics(title: String, artist: String) async {
        do {
            let tracks = try await LRCLIBService().search(title: title, artist: artist)
            guard let track = tracks.first, let synced = track.syncedLyrics else {
                errorMessage = "找不到同步歌詞。"
                return
            }
            lyrics = LRCParser.parse(synced)
            self.title = track.name
            self.artist = track.artistName
            currentTime = 0
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
