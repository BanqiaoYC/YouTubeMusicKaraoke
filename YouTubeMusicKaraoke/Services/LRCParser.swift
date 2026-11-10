import Foundation

enum LRCParser {
    static func parse(_ source: String) -> [LyricLine] {
        let pattern = #"\[(\d{2}):(\d{2})(?:\.(\d{1,3}))?\](.*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        var output: [LyricLine] = []
        for (index, rawLine) in source.components(separatedBy: .newlines).enumerated() {
            let ns = rawLine as NSString
            let range = NSRange(location: 0, length: ns.length)
            guard let match = regex.firstMatch(in: rawLine, range: range), match.numberOfRanges == 5,
                  let minRange = Range(match.range(at: 1), in: rawLine),
                  let secRange = Range(match.range(at: 2), in: rawLine),
                  let textRange = Range(match.range(at: 4), in: rawLine),
                  let minutes = Double(rawLine[minRange]), let seconds = Double(rawLine[secRange]) else { continue }
            var fraction = 0.0
            if let fracRange = Range(match.range(at: 3), in: rawLine) {
                let digits = String(rawLine[fracRange])
                fraction = (Double(digits) ?? 0) / pow(10.0, Double(digits.count))
            }
            output.append(LyricLine(id: index, time: minutes * 60 + seconds + fraction, text: String(rawLine[textRange])))
        }
        return output.sorted { $0.time < $1.time }
    }
}
