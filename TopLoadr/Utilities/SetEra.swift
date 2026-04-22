import Foundation

// MARK: - Eras (tab order: oldest product blocks → newest → specialty → misc)

/// Booster shop eras. Main blocks map from API `set.series` unless overridden (specialty / misc) by set id.
enum SetEra: Int, CaseIterable, Identifiable, Comparable {
    case wotcVintage
    case neoSeries
    case ecardSeries
    case exSeries
    case diamondAndPearl
    case heartGoldSoulSilver
    case blackAndWhite
    case xySeries
    case sunAndMoon
    case swordAndShield
    case scarletAndViolet
    case megaEvolution
    /// Premium / special expansions (Prismatic, Legendary Treasures, Shining Fates, etc.); see `SpecialtySetIds`.
    case specialtySets
    /// POP, McDonald’s, Black Star promos, vending, energy-only, other oddballs.
    case misc

    var id: Int { rawValue }

    var shortTitle: String {
        switch self {
        case .wotcVintage: return "WotC"
        case .neoSeries: return "Neo"
        case .ecardSeries: return "e-Card"
        case .exSeries: return "EX"
        case .diamondAndPearl: return "DP"
        case .heartGoldSoulSilver: return "HGSS"
        case .blackAndWhite: return "B&W"
        case .xySeries: return "XY"
        case .sunAndMoon: return "S&M"
        case .swordAndShield: return "SWSH"
        case .scarletAndViolet: return "S&V"
        case .megaEvolution: return "Mega"
        case .specialtySets: return "Special"
        case .misc: return "Misc"
        }
    }

    var title: String {
        switch self {
        case .wotcVintage: return "WotC Vintage (Base – Gym)"
        case .neoSeries: return "Neo Series"
        case .ecardSeries: return "e-Card Series"
        case .exSeries: return "EX Series"
        case .diamondAndPearl: return "Diamond & Pearl"
        case .heartGoldSoulSilver: return "HeartGold & SoulSilver"
        case .blackAndWhite: return "Black & White"
        case .xySeries: return "XY"
        case .sunAndMoon: return "Sun & Moon"
        case .swordAndShield: return "Sword & Shield"
        case .scarletAndViolet: return "Scarlet & Violet"
        case .megaEvolution: return "Mega Evolution"
        case .specialtySets: return "Specialty sets"
        case .misc: return "Misc (POP, promos, etc.)"
        }
    }

    static let preferredSelectionOrder: [SetEra] = [
        .megaEvolution,
        .scarletAndViolet,
        .swordAndShield,
        .sunAndMoon,
        .xySeries,
        .blackAndWhite,
        .heartGoldSoulSilver,
        .diamondAndPearl,
        .exSeries,
        .ecardSeries,
        .neoSeries,
        .wotcVintage,
        .specialtySets,
        .misc
    ]

    static func < (lhs: SetEra, rhs: SetEra) -> Bool { lhs.rawValue < rhs.rawValue }
}

// MARK: - Specialty (explicit set ids)

/// Premium / “special set” **product lines**; API still tags many with a main `series` (e.g. `sv8pt5` is Scarlet & Violet).
/// Add new set ids as premium expansions are released.
enum SpecialtySetIds {
    static let ids: Set<String> = {
        // WotC / early
        var s: Set<String> = ["base6", "si1"] // Legendary Collection, Southern Islands
        s.formUnion([ // Black & White / XY premium
            "bw11", // Legendary Treasures
            "xy12" // Evolutions
        ])
        s.formUnion([ // Sun & Moon
            "g1", "det1", "sm35", "sm75", "sm115", "sma"
        ])
        s.formUnion([ // Sword & Shield “special” boxes / mini-sets
            "swsh35", "swsh45", "swsh45sv", "cel25", "cel25c", "dc1", "pgo" // Shining Fates, Celebrations, Double Crisis, Pokémon GO, …
        ])
        s.formUnion([ // Scarlet & Violet (mini / subset expansions, etc.)
            "sv3pt5", "sv4pt5", "sv8pt5" // 151, Paldean Fates, Prismatic Evolutions (ids may change by API; verify in docs)
        ])
        s.formUnion([ // Mega
            "me2pt5" // Ascended Heroes
        ])
        s.formUnion([ // B&W
            "dv1" // Dragon Vault
        ])
        return s
    }()
}

// MARK: - Mapping

/// Maps API `set.id`, `name`, and `series` into `SetEra`.
enum SetEraMapper {
    static func era(for set: PTCGSet) -> SetEra {
        let id = set.id
        let idLower = id.lowercased()
        let s = (set.series ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = s.lowercased()
        let nameL = set.name.lowercased()

        if SpecialtySetIds.ids.contains(idLower) { return .specialtySets }
        if idLower.hasPrefix("mcd") { return .misc }
        if idLower.hasPrefix("pop") { return .misc }
        if nameL.contains("vending") { return .misc }
        if miscPromoStyleIds.contains(idLower) { return .misc }
        if lower == "pop" { return .misc }
        if nameL.contains("black star promos") { return .misc }
        if nameL.contains("mcdonald") { return .misc }

        if lower == "mega evolution" { return .megaEvolution }
        if lower == "scarlet & violet" { return .scarletAndViolet }
        if lower == "sword & shield" { return .swordAndShield }
        if lower == "sun & moon" { return .sunAndMoon }
        if lower == "xy" { return .xySeries }
        if lower == "black & white" { return .blackAndWhite }
        if lower == "heartgold & soulsilver" { return .heartGoldSoulSilver }
        if lower == "diamond & pearl" || lower == "platinum" { return .diamondAndPearl }
        if lower == "ex" || lower == "np" { return .exSeries }
        if lower == "e-card" { return .ecardSeries }
        if lower == "neo" { return .neoSeries }
        if lower == "base" || lower == "gym" { return .wotcVintage }

        if lower == "other" || s.isEmpty { return .misc }

        return .misc
    }

    /// Black Star promos, standalone energy SKUs, and similar; not the main “specialty” product line list.
    private static let miscPromoStyleIds: Set<String> = [
        "bwp", "dpp", "hsp", "xyp", "smp", "swshp", "svp", "sve", "mep" // SVE energies, MEP if present
    ]

    static func groupSetsByEra(_ sets: [PTCGSet]) -> [SetEra: [PTCGSet]] {
        var out: [SetEra: [PTCGSet]] = Dictionary(uniqueKeysWithValues: SetEra.allCases.map { ($0, []) })
        for s in sets {
            out[era(for: s), default: []].append(s)
        }
        for e in SetEra.allCases {
            out[e] = (out[e] ?? []).sorted(by: compareRelease)
        }
        return out
    }

    private static func compareRelease(_ a: PTCGSet, _ b: PTCGSet) -> Bool {
        let da = releaseSortDate(a) ?? .distantPast
        let db = releaseSortDate(b) ?? .distantPast
        if da != db { return da > db }
        return a.name < b.name
    }

    private static let releaseParsers: [DateFormatter] = {
        let a = DateFormatter()
        a.locale = Locale(identifier: "en_US_POSIX")
        a.timeZone = TimeZone(secondsFromGMT: 0)
        a.dateFormat = "yyyy/MM/dd"
        let b = DateFormatter()
        b.locale = Locale(identifier: "en_US_POSIX")
        b.timeZone = TimeZone(secondsFromGMT: 0)
        b.dateFormat = "yyyy-MM-dd"
        return [a, b]
    }()

    static func releaseSortDate(_ set: PTCGSet) -> Date? {
        guard let r = set.releaseDate, !r.isEmpty else { return nil }
        for f in releaseParsers {
            if let d = f.date(from: r) { return d }
        }
        return nil
    }
}
