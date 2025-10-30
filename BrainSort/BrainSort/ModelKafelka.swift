//
//  ModelKafelka.swift
//  BrainSort
//
//  Mahjong tile data model
//

import Foundation

// MARK: - Kafelka (Tile)
struct Kafelka: Equatable, Codable {
    let identyfikator: String // Identifier (e.g., "bhdu-1", "nauri-5")
    let typKafelki: TypKafelki // Tile type
    let wartosc: Int // Value (1-9 for suited tiles, 1-7 for honor tiles)

    var nazwaObrazu: String {
        return identyfikator
    }

    static func == (lhs: Kafelka, rhs: Kafelka) -> Bool {
        return lhs.identyfikator == rhs.identyfikator
    }
}

// MARK: - TypKafelki (Tile Type)
enum TypKafelki: String, Codable {
    case bhdu = "bhdu"      //筒 (Dots)
    case nauri = "nauri"    // 万 (Characters)
    case kiuey = "kiuey"    // 条 (Bamboo)
    case yiusan = "yiusan"  // Special tiles (Honor tiles)
}

// MARK: - PoziomTrudnosci (Difficulty Level)
enum PoziomTrudnosci: String {
    case latwy = "Easy"     // Simple mode: 6 tiles total, 3 missing
    case trudny = "Hard"    // Hard mode: 8 tiles total, 4 missing

    var liczbaKafelek: Int {
        switch self {
        case .latwy: return 6
        case .trudny: return 8
        }
    }

    var liczbaBrakujacych: Int {
        switch self {
        case .latwy: return 3
        case .trudny: return 4
        }
    }

    var liczbaOpcji: Int {
        switch self {
        case .latwy: return 3
        case .trudny: return 5
        }
    }

    func punktyDlaProb(_ proby: Int) -> Int {
        switch self {
        case .latwy:
            if proby <= 5 { return 200 }
            else if proby <= 10 { return 100 }
            else { return 50 }
        case .trudny:
            if proby <= 10 { return 500 }
            else if proby <= 25 { return 200 }
            else { return 100 }
        }
    }
}

// MARK: - RekordGry (Game Record)
struct RekordGry: Codable {
    let dataGry: Date // Game date
    let poziom: String // Difficulty level
    let punkty: Int // Score
    let liczbaProb: Int // Number of attempts

    var dataFormatowana: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: dataGry)
    }
}

// MARK: - StanGry (Game State)
struct StanGry {
    let oryginalnePołozenie: [Kafelka] // Original combination (correct answer)
    let poczatkowePołozenie: [Kafelka?] // Initial board state (with some tiles shown)
    var obecnePołozenie: [Kafelka?] // Current board state (nil = empty slot)
    let dostepneKafelki: [Kafelka] // Available tiles for player
    var wybrane: [Int: Int] // Mapping: board position -> hand tile index
    var liczbaProb: Int // Number of attempts
    let poziom: PoziomTrudnosci // Difficulty level
    var historiaProb: [ProbaUlozenia] // History of attempts

    mutating func resetujWybor() {
        // Reset to initial state (show only the original visible tiles)
        obecnePołozenie = poczatkowePołozenie
        wybrane.removeAll()
    }
}

// MARK: - ProbaUlozenia (Attempt Record)
struct ProbaUlozenia {
    let numer: Int // Attempt number
    let ulozenie: [Kafelka?] // The arrangement
    let wyniki: [WynikPozycji] // Result for each position
    let wybranePozycje: Set<Int> // Positions filled by player
}

// MARK: - WynikPozycji (Position Result)
enum WynikPozycji {
    case poprawny // Correct
    case niepoprawny // Incorrect
    case pusty // Empty
}
