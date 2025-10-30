//
//  FabrykaKafelek.swift
//  BrainSort
//
//  Tile factory for generating random combinations
//

import Foundation

class FabrykaKafelek {

    // Generate all available tiles
    static func wygenerujWszystkieKafelki() -> [Kafelka] {
        var kafelki: [Kafelka] = []

        // Dots (筒)
        for i in 1...9 {
            kafelki.append(Kafelka(identyfikator: "bhdu-\(i)", typKafelki: .bhdu, wartosc: i))
        }

        // Characters (万)
        for i in 1...9 {
            kafelki.append(Kafelka(identyfikator: "nauri-\(i)", typKafelki: .nauri, wartosc: i))
        }

        // Bamboo (条)
        for i in 1...9 {
            kafelki.append(Kafelka(identyfikator: "kiuey-\(i)", typKafelki: .kiuey, wartosc: i))
        }

        // Honor tiles
        for i in 1...7 {
            kafelki.append(Kafelka(identyfikator: "yiusan-\(i)", typKafelki: .yiusan, wartosc: i))
        }

        return kafelki
    }

    // Generate random combination for given difficulty
    static func wygenerujLosowaKombinacje(poziom: PoziomTrudnosci) -> [Kafelka] {
        let wszystkieKafelki = wygenerujWszystkieKafelki()
        let liczbaKafelek = poziom.liczbaKafelek

        // Randomly select tiles
        var wybrane: [Kafelka] = []
        var dostepne = wszystkieKafelki

        for _ in 0..<liczbaKafelek {
            let indeks = Int.random(in: 0..<dostepne.count)
            wybrane.append(dostepne[indeks])
            dostepne.remove(at: indeks)
        }

        return wybrane
    }

    // Generate initial game state
    static func wygenerujStanGry(poziom: PoziomTrudnosci) -> StanGry {
        let oryginalne = wygenerujLosowaKombinacje(poziom: poziom)
        let liczbaBrakujacych = poziom.liczbaBrakujacych
        let liczbaOpcji = poziom.liczbaOpcji

        // Select random positions to hide
        var indeksyDoUkrycia = Set<Int>()
        while indeksyDoUkrycia.count < liczbaBrakujacych {
            indeksyDoUkrycia.insert(Int.random(in: 0..<oryginalne.count))
        }

        // Create current board with missing tiles
        var obecne: [Kafelka?] = []
        var brakujace: [Kafelka] = []

        for (indeks, kafelka) in oryginalne.enumerated() {
            if indeksyDoUkrycia.contains(indeks) {
                obecne.append(nil)
                brakujace.append(kafelka)
            } else {
                obecne.append(kafelka)
            }
        }

        // Generate available tiles (missing tiles + extra distractors for hard mode)
        var dostepne = brakujace

        // Add extra tiles if needed
        if liczbaOpcji > liczbaBrakujacych {
            let wszystkie = wygenerujWszystkieKafelki()
            let dozwolone = wszystkie.filter { !oryginalne.contains($0) }
            let dodatkowe = liczbaOpcji - liczbaBrakujacych

            for _ in 0..<dodatkowe {
                if let losowa = dozwolone.randomElement() {
                    dostepne.append(losowa)
                }
            }
        }

        // Shuffle available tiles
        dostepne.shuffle()

        return StanGry(
            oryginalnePołozenie: oryginalne,
            poczatkowePołozenie: obecne,
            obecnePołozenie: obecne,
            dostepneKafelki: dostepne,
            wybrane: [:],
            liczbaProb: 0,
            poziom: poziom,
            historiaProb: []
        )
    }
}
