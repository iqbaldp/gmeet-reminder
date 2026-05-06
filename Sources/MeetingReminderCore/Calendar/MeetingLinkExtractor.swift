import Foundation

public enum MeetingLinkExtractor {
    public static func extract(url: URL?, location: String?, notes: String?) -> URL? {
        let candidates = ([url].compactMap { $0 } + urls(in: [location, notes]))
            .filter { candidate in
                candidate.scheme == "http" || candidate.scheme == "https"
            }

        return candidates.first { candidate in
            isKnownMeetingURL(candidate)
        } ?? candidates.first
    }

    private static func urls(in strings: [String?]) -> [URL] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

        return strings.compactMap { $0 }.flatMap { string in
            let range = NSRange(string.startIndex..<string.endIndex, in: string)
            return detector?.matches(in: string, options: [], range: range).compactMap(\.url) ?? []
        }
    }

    private static func isKnownMeetingURL(_ url: URL) -> Bool {
        guard let host = url.host()?.lowercased() else {
            return false
        }

        return host == "meet.google.com"
            || host.hasSuffix(".zoom.us")
            || host == "zoom.us"
            || host == "teams.microsoft.com"
            || host.hasSuffix(".teams.microsoft.com")
    }
}
