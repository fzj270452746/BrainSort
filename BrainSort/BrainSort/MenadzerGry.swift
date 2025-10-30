//
//  MenadzerGry.swift
//  BrainSort
//
//  Game manager handling game logic and data persistence
//

import Foundation

class MenadzerGry {
    static let wspoldzielony = MenadzerGry()

    private let kluczRekordow = "KluczRekordowGry"
    private let kluczCalkowitychPunktow = "KluczCalkowitychPunktow"

    private init() {}

    // MARK: - Game Logic

    func sprawdzUlozenie(stan: StanGry) -> [WynikPozycji] {
        var wyniki: [WynikPozycji] = []

        for (indeks, kafelka) in stan.obecnePołozenie.enumerated() {
            if let kafelka = kafelka {
                if kafelka == stan.oryginalnePołozenie[indeks] {
                    wyniki.append(.poprawny)
                } else {
                    wyniki.append(.niepoprawny)
                }
            } else {
                wyniki.append(.pusty)
            }
        }

        return wyniki
    }

    func czyWygrana(stan: StanGry) -> Bool {
        for (indeks, kafelka) in stan.obecnePołozenie.enumerated() {
            guard let kafelka = kafelka else { return false }
            if kafelka != stan.oryginalnePołozenie[indeks] {
                return false
            }
        }
        return true
    }

    // MARK: - Score Management

    func zapiszRekord(poziom: PoziomTrudnosci, punkty: Int, liczbaProb: Int) {
        let rekord = RekordGry(
            dataGry: Date(),
            poziom: poziom.rawValue,
            punkty: punkty,
            liczbaProb: liczbaProb
        )

        var rekordy = pobierzRekordy()
        rekordy.append(rekord)

        // Sort by score descending
        rekordy.sort { $0.punkty > $1.punkty }

        // Keep top 50 records
        if rekordy.count > 50 {
            rekordy = Array(rekordy.prefix(50))
        }

        if let zakodowane = try? JSONEncoder().encode(rekordy) {
            UserDefaults.standard.set(zakodowane, forKey: kluczRekordow)
        }

        // Update total score
        let obecneSuma = pobierzCalkowitePunkty()
        UserDefaults.standard.set(obecneSuma + punkty, forKey: kluczCalkowitychPunktow)
    }

    func pobierzRekordy() -> [RekordGry] {
        guard let dane = UserDefaults.standard.data(forKey: kluczRekordow),
              let rekordy = try? JSONDecoder().decode([RekordGry].self, from: dane) else {
            return []
        }
        return rekordy
    }

    func pobierzCalkowitePunkty() -> Int {
        return UserDefaults.standard.integer(forKey: kluczCalkowitychPunktow)
    }

    func pobierzNajlepszychGraczy(limit: Int = 10) -> [RekordGry] {
        let rekordy = pobierzRekordy()
        return Array(rekordy.prefix(limit))
    }

    func pobierzNajlepszychGraczy(poziom: PoziomTrudnosci, limit: Int = 10) -> [RekordGry] {
        let rekordy = pobierzRekordy()
        let odfiltrowane = rekordy.filter { $0.poziom == poziom.rawValue }
        return Array(odfiltrowane.prefix(limit))
    }

    // MARK: - Feedback

    func zapiszOpinie(_ tekst: String) {
        let klucz = "OpiniaGracza_\(Date().timeIntervalSince1970)"
        UserDefaults.standard.set(tekst, forKey: klucz)
    }
}
