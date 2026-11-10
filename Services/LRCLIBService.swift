import Foundation

struct LRCLIBService {
    struct Track: Decodable {
        let id: Int
        let name: String
        let artistName: String
        let syncedLyrics: String?
        let plainLyrics: String?
    }

    func search(title: String, artist: String) async throws -> [Track] {
        var components = URLComponents(string: "https://lrclib.net/api/search")!
        components.queryItems = [URLQueryItem(name: "track_name", value: title), URLQueryItem(name: "artist_name", value: artist)]
        var request = URLRequest(url: components.url!)
        request.setValue("YouTubeMusicKaraoke/1.0", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([Track].self, from: data)
    }
}
