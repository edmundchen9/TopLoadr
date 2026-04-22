import Foundation

enum PokemonTCGAPIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from Pokémon TCG API."
        case .httpStatus(let c): return "API returned status \(c)."
        case .decodingFailed: return "Could not read API data."
        }
    }
}

/// Uses https://api.pokemontcg.io/v2 — set `PokémonTCG-API-Key` in Info (or pass key) for higher limits.
struct PokemonTCGAPI {
    private let baseURL = URL(string: "https://api.pokemontcg.io/v2")!
    private let urlSession: URLSession
    private let apiKey: String?

    /// Pass `key` for production; unauthenticated is rate-limited.
    init(urlSession: URLSession = .shared, apiKey: String? = nil) {
        self.urlSession = urlSession
        // Optional: from environment for development
        if let k = apiKey {
            self.apiKey = k
        } else if let env = ProcessInfo.processInfo.environment["POKEMON_TCG_API_KEY"] {
            self.apiKey = env
        } else {
            self.apiKey = nil
        }
    }

    func fetchSets() async throws -> [PTCGSet] {
        var all: [PTCGSet] = []
        var page = 1
        let pageSize = 250
        var total = Int.max
        while all.count < total {
            var components = URLComponents(
                url: baseURL.appendingPathComponent("sets"),
                resolvingAgainstBaseURL: false
            )!
            components.queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "pageSize", value: String(pageSize))
            ]
            var request = URLRequest(url: components.url!)
            if let k = apiKey, !k.isEmpty {
                request.setValue(k, forHTTPHeaderField: "X-Api-Key")
            }
            let (data, response) = try await urlSession.data(for: request)
            try validate(response: response)
            let decoded = try JSONDecoder().decode(SetsListResponse.self, from: data)
            if page == 1 { total = decoded.totalCount }
            if decoded.data.isEmpty { break }
            all.append(contentsOf: decoded.data)
            if decoded.data.count < pageSize { break }
            page += 1
        }
        return all
    }

    /// Fetches all cards in a set (paginates; page size 250 per API spec).
    func fetchAllCardsInSet(setId: String) async throws -> [PTCGCard] {
        var all: [PTCGCard] = []
        var page = 1
        let pageSize = 250
        var totalAvailable = Int.max
        while true {
            let (cards, pageTotal) = try await fetchCardsPage(setId: setId, page: page, pageSize: pageSize)
            if page == 1 { totalAvailable = pageTotal }
            all.append(contentsOf: cards)
            if cards.isEmpty || all.count >= totalAvailable { break }
            page += 1
        }
        return all
    }

    private struct SetsListResponse: Decodable {
        let data: [PTCGSet]
        let totalCount: Int

        private enum Keys: String, CodingKey { case data, totalCount, count }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: Keys.self)
            data = try c.decodeIfPresent([PTCGSet].self, forKey: .data) ?? []
            if let t = try c.decodeIfPresent(Int.self, forKey: .totalCount) {
                totalCount = t
            } else {
                totalCount = try c.decodeIfPresent(Int.self, forKey: .count) ?? data.count
            }
        }
    }

    private struct CardsResponse: Decodable {
        let data: [PTCGCard]
        let totalCount: Int

        private enum Keys: String, CodingKey { case data, totalCount, count }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: Keys.self)
            data = try c.decodeIfPresent([PTCGCard].self, forKey: .data) ?? []
            if let t = try c.decodeIfPresent(Int.self, forKey: .totalCount) {
                totalCount = t
            } else {
                totalCount = try c.decodeIfPresent(Int.self, forKey: .count) ?? data.count
            }
        }
    }

    private func fetchCardsPage(setId: String, page: Int, pageSize: Int) async throws -> ([PTCGCard], Int) {
        // Query: set.id:xxx
        let q = "set.id:\(setId)"
        var components = URLComponents(
            url: baseURL.appendingPathComponent("cards"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        var request = URLRequest(url: components.url!)
        if let k = apiKey, !k.isEmpty {
            request.setValue(k, forHTTPHeaderField: "X-Api-Key")
        }
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response)
        let decoded = try JSONDecoder().decode(CardsResponse.self, from: data)
        return (decoded.data, decoded.totalCount)
    }

    private func validate(response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw PokemonTCGAPIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw PokemonTCGAPIError.httpStatus(http.statusCode)
        }
    }
}
