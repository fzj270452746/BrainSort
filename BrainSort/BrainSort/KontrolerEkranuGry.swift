//
//  KontrolerEkranuGry.swift
//  BrainSort
//
//  Game play screen with tile interaction
//

import UIKit

// MARK: - NSLayoutConstraint Extension
extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

class KontrolerEkranuGry: UIViewController {

    // MARK: - Properties

    private let poziom: PoziomTrudnosci
    private var stanGry: StanGry!
    private var calkowitePunkty: Int = 0 // Cumulative score for this session
    private var liczbaRozgrywek: Int = 0 // Number of rounds completed

    private let warstwaGradientu = CAGradientLayer()

    // UI Components
    private let widokPrzewijania = UIScrollView()
    private let kontenerTresci = UIView()

    private let przyciskPowrot = UIButton(type: .system)
    private let etykietaTytulu = UILabel()
    private let etykietaProb = UILabel()
    private let etykietaPunktow = UILabel()
    private let etykietaCalkowitychPunktow = UILabel()

    private let kontenerPlanszy = UIView()
    private var widokiKafelekPlanszy: [WidokKafelki] = []

    private let kontenerReki = UIView()
    private var widokiKafelekReki: [WidokKafelki] = []

    private let przyciskSprawdz = UIButton(type: .custom)
    private let przyciskResetuj = UIButton(type: .custom)
    private let przyciskNowaGra = UIButton(type: .custom)

    private let kontenerHistorii = UIView()
    private let widokPrzewijaniHistorii = UIScrollView()
    private let stosHistorii = UIStackView()

    private var wybranaKafelkaReki: Int?

    // MARK: - Initialization

    init(poziom: PoziomTrudnosci) {
        self.poziom = poziom
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        inicjalizujGre()
        ustawWyglad()
        ustawOgraniczenia()
        odswiezInterfejs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        warstwaGradientu.frame = view.bounds
    }

    // MARK: - Setup

    private func inicjalizujGre() {
        stanGry = FabrykaKafelek.wygenerujStanGry(poziom: poziom)
    }

    private func ustawWyglad() {
        // Background
        warstwaGradientu.colors = [
            UIColor(red: 0.15, green: 0.25, blue: 0.35, alpha: 1.0).cgColor,
            UIColor(red: 0.25, green: 0.35, blue: 0.45, alpha: 1.0).cgColor
        ]
        view.layer.insertSublayer(warstwaGradientu, at: 0)

        // Scroll view
        widokPrzewijania.showsVerticalScrollIndicator = false
        view.addSubview(widokPrzewijania)
        widokPrzewijania.addSubview(kontenerTresci)

        // Back button
        przyciskPowrot.setTitle("← Back", for: .normal)
        przyciskPowrot.setTitleColor(.white, for: .normal)
        przyciskPowrot.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        przyciskPowrot.addTarget(self, action: #selector(powrot), for: .touchUpInside)
        kontenerTresci.addSubview(przyciskPowrot)

        // Title
        etykietaTytulu.text = poziom == .latwy ? "EASY MODE" : "HARD MODE"
        etykietaTytulu.font = UIFont.boldSystemFont(ofSize: 24)
        etykietaTytulu.textColor = .white
        etykietaTytulu.textAlignment = .center
        kontenerTresci.addSubview(etykietaTytulu)

        // Attempts label
        etykietaProb.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        etykietaProb.textColor = UIColor.white.withAlphaComponent(0.9)
        etykietaProb.textAlignment = .center
        kontenerTresci.addSubview(etykietaProb)

        // Score label
        etykietaPunktow.font = UIFont.boldSystemFont(ofSize: 18)
        etykietaPunktow.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        etykietaPunktow.textAlignment = .center
        kontenerTresci.addSubview(etykietaPunktow)

        // Total score label
        etykietaCalkowitychPunktow.font = UIFont.boldSystemFont(ofSize: 16)
        etykietaCalkowitychPunktow.textColor = UIColor(red: 0.5, green: 0.9, blue: 1.0, alpha: 1.0)
        etykietaCalkowitychPunktow.textAlignment = .center
        kontenerTresci.addSubview(etykietaCalkowitychPunktow)

        // Board container
        kontenerPlanszy.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        kontenerPlanszy.layer.cornerRadius = 16
        kontenerTresci.addSubview(kontenerPlanszy)

        stworzWidokiKafelekPlanszy()

        // Hand container
        kontenerReki.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        kontenerReki.layer.cornerRadius = 16
        kontenerTresci.addSubview(kontenerReki)

        stworzWidokiKafelekReki()

        // Check button
        przyciskSprawdz.setTitle("✓ Check", for: .normal)
        przyciskSprawdz.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        przyciskSprawdz.setTitleColor(.white, for: .normal)
        przyciskSprawdz.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.5, alpha: 1.0)
        przyciskSprawdz.layer.cornerRadius = 12
        przyciskSprawdz.addTarget(self, action: #selector(sprawdzUlozenie), for: .touchUpInside)
        kontenerTresci.addSubview(przyciskSprawdz)

        // Reset button
        przyciskResetuj.setTitle("↻ Reset", for: .normal)
        przyciskResetuj.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        przyciskResetuj.setTitleColor(.white, for: .normal)
        przyciskResetuj.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        przyciskResetuj.layer.cornerRadius = 12
        przyciskResetuj.addTarget(self, action: #selector(resetujWybor), for: .touchUpInside)
        kontenerTresci.addSubview(przyciskResetuj)

        // New game button (top-right corner)
        przyciskNowaGra.setTitle("🔄 New", for: .normal)
        przyciskNowaGra.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        przyciskNowaGra.setTitleColor(.white, for: .normal)
        przyciskNowaGra.backgroundColor = UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 1.0)
        przyciskNowaGra.layer.cornerRadius = 8
        przyciskNowaGra.addTarget(self, action: #selector(rozpocznijNowaGre), for: .touchUpInside)
        kontenerTresci.addSubview(przyciskNowaGra)

        // History container
        kontenerHistorii.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        kontenerHistorii.layer.cornerRadius = 16
        kontenerTresci.addSubview(kontenerHistorii)

        let etykietaHistorii = UILabel()
        etykietaHistorii.text = "Attempt History"
        etykietaHistorii.font = UIFont.boldSystemFont(ofSize: 16)
        etykietaHistorii.textColor = .white
        etykietaHistorii.textAlignment = .center
        kontenerHistorii.addSubview(etykietaHistorii)
        etykietaHistorii.translatesAutoresizingMaskIntoConstraints = false

        widokPrzewijaniHistorii.showsHorizontalScrollIndicator = false
        kontenerHistorii.addSubview(widokPrzewijaniHistorii)
        widokPrzewijaniHistorii.translatesAutoresizingMaskIntoConstraints = false

        stosHistorii.axis = .vertical
        stosHistorii.spacing = 8
        stosHistorii.alignment = .fill
        widokPrzewijaniHistorii.addSubview(stosHistorii)
        stosHistorii.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            etykietaHistorii.topAnchor.constraint(equalTo: kontenerHistorii.topAnchor, constant: 12),
            etykietaHistorii.leadingAnchor.constraint(equalTo: kontenerHistorii.leadingAnchor, constant: 12),
            etykietaHistorii.trailingAnchor.constraint(equalTo: kontenerHistorii.trailingAnchor, constant: -12),

            widokPrzewijaniHistorii.topAnchor.constraint(equalTo: etykietaHistorii.bottomAnchor, constant: 8),
            widokPrzewijaniHistorii.leadingAnchor.constraint(equalTo: kontenerHistorii.leadingAnchor, constant: 12),
            widokPrzewijaniHistorii.trailingAnchor.constraint(equalTo: kontenerHistorii.trailingAnchor, constant: -12),
            widokPrzewijaniHistorii.bottomAnchor.constraint(equalTo: kontenerHistorii.bottomAnchor, constant: -12),
            widokPrzewijaniHistorii.heightAnchor.constraint(equalToConstant: 150),

            stosHistorii.topAnchor.constraint(equalTo: widokPrzewijaniHistorii.topAnchor),
            stosHistorii.leadingAnchor.constraint(equalTo: widokPrzewijaniHistorii.leadingAnchor),
            stosHistorii.trailingAnchor.constraint(equalTo: widokPrzewijaniHistorii.trailingAnchor),
            stosHistorii.bottomAnchor.constraint(equalTo: widokPrzewijaniHistorii.bottomAnchor),
            stosHistorii.widthAnchor.constraint(equalTo: widokPrzewijaniHistorii.widthAnchor)
        ])
    }

    private func stworzWidokiKafelekPlanszy() {
        let liczba = stanGry.oryginalnePołozenie.count

        for indeks in 0..<liczba {
            let widok = WidokKafelki()
            widok.tag = indeks
            widok.dodajAkcjeDotyku(cel: self, akcja: #selector(dotknietoPozycjePlanszy(_:)))
            kontenerPlanszy.addSubview(widok)
            widokiKafelekPlanszy.append(widok)
        }
    }

    private func stworzWidokiKafelekReki() {
        for (indeks, _) in stanGry.dostepneKafelki.enumerated() {
            let widok = WidokKafelki()
            widok.tag = indeks
            widok.dodajAkcjeDotyku(cel: self, akcja: #selector(dotknietoPozycjeReki(_:)))
            kontenerReki.addSubview(widok)
            widokiKafelekReki.append(widok)
        }
    }

    private func ustawOgraniczenia() {
        widokPrzewijania.translatesAutoresizingMaskIntoConstraints = false
        kontenerTresci.translatesAutoresizingMaskIntoConstraints = false
        przyciskPowrot.translatesAutoresizingMaskIntoConstraints = false
        etykietaTytulu.translatesAutoresizingMaskIntoConstraints = false
        etykietaProb.translatesAutoresizingMaskIntoConstraints = false
        etykietaPunktow.translatesAutoresizingMaskIntoConstraints = false
        etykietaCalkowitychPunktow.translatesAutoresizingMaskIntoConstraints = false
        kontenerPlanszy.translatesAutoresizingMaskIntoConstraints = false
        kontenerReki.translatesAutoresizingMaskIntoConstraints = false
        przyciskSprawdz.translatesAutoresizingMaskIntoConstraints = false
        przyciskResetuj.translatesAutoresizingMaskIntoConstraints = false
        przyciskNowaGra.translatesAutoresizingMaskIntoConstraints = false
        kontenerHistorii.translatesAutoresizingMaskIntoConstraints = false

        let rozmiarKafelki: CGFloat = 60
        let odstep: CGFloat = 8

        // Calculate maximum available width for board container
        // Use view.bounds.width to account for iPad compatibility mode
        let maksymalnaSzerokoscPlanszy = view.bounds.width - 40 // 20px padding on each side

        NSLayoutConstraint.activate([
            widokPrzewijania.topAnchor.constraint(equalTo: view.topAnchor),
            widokPrzewijania.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            widokPrzewijania.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            widokPrzewijania.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            kontenerTresci.topAnchor.constraint(equalTo: widokPrzewijania.topAnchor),
            kontenerTresci.leadingAnchor.constraint(equalTo: widokPrzewijania.leadingAnchor),
            kontenerTresci.trailingAnchor.constraint(equalTo: widokPrzewijania.trailingAnchor),
            kontenerTresci.bottomAnchor.constraint(equalTo: widokPrzewijania.bottomAnchor),
            kontenerTresci.widthAnchor.constraint(equalTo: widokPrzewijania.widthAnchor),

            przyciskPowrot.topAnchor.constraint(equalTo: kontenerTresci.safeAreaLayoutGuide.topAnchor, constant: 8),
            przyciskPowrot.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 16),

            przyciskNowaGra.topAnchor.constraint(equalTo: kontenerTresci.safeAreaLayoutGuide.topAnchor, constant: 8),
            przyciskNowaGra.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -16),
            przyciskNowaGra.heightAnchor.constraint(equalToConstant: 36),
            przyciskNowaGra.widthAnchor.constraint(equalToConstant: 70),

            etykietaTytulu.topAnchor.constraint(equalTo: przyciskPowrot.bottomAnchor, constant: 20),
            etykietaTytulu.centerXAnchor.constraint(equalTo: kontenerTresci.centerXAnchor),

            etykietaProb.topAnchor.constraint(equalTo: etykietaTytulu.bottomAnchor, constant: 8),
            etykietaProb.centerXAnchor.constraint(equalTo: kontenerTresci.centerXAnchor),

            etykietaPunktow.topAnchor.constraint(equalTo: etykietaProb.bottomAnchor, constant: 4),
            etykietaPunktow.centerXAnchor.constraint(equalTo: kontenerTresci.centerXAnchor),

            etykietaCalkowitychPunktow.topAnchor.constraint(equalTo: etykietaPunktow.bottomAnchor, constant: 4),
            etykietaCalkowitychPunktow.centerXAnchor.constraint(equalTo: kontenerTresci.centerXAnchor),

            kontenerPlanszy.topAnchor.constraint(equalTo: etykietaCalkowitychPunktow.bottomAnchor, constant: 20),
            kontenerPlanszy.centerXAnchor.constraint(equalTo: kontenerTresci.centerXAnchor),
            kontenerPlanszy.widthAnchor.constraint(lessThanOrEqualToConstant: maksymalnaSzerokoscPlanszy),
            kontenerPlanszy.widthAnchor.constraint(equalToConstant: poziom == .trudny ? 4 * (rozmiarKafelki + odstep) + 32 : 3 * (rozmiarKafelki + odstep) + 32).withPriority(.defaultHigh),
            kontenerPlanszy.heightAnchor.constraint(equalToConstant: 2 * (rozmiarKafelki + odstep) + 16),

            kontenerReki.topAnchor.constraint(equalTo: kontenerPlanszy.bottomAnchor, constant: 24),
            kontenerReki.centerXAnchor.constraint(equalTo: kontenerTresci.centerXAnchor),
            kontenerReki.widthAnchor.constraint(equalToConstant: CGFloat(poziom.liczbaOpcji) * rozmiarKafelki + CGFloat(poziom.liczbaOpcji - 1) * odstep + 24),
            kontenerReki.heightAnchor.constraint(equalToConstant: rozmiarKafelki + 24),

            przyciskSprawdz.topAnchor.constraint(equalTo: kontenerReki.bottomAnchor, constant: 24),
            przyciskSprawdz.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 20),
            przyciskSprawdz.heightAnchor.constraint(equalToConstant: 50),
            przyciskSprawdz.widthAnchor.constraint(equalTo: kontenerTresci.widthAnchor, multiplier: 0.45, constant: -25),

            przyciskResetuj.topAnchor.constraint(equalTo: kontenerReki.bottomAnchor, constant: 24),
            przyciskResetuj.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -20),
            przyciskResetuj.heightAnchor.constraint(equalToConstant: 50),
            przyciskResetuj.widthAnchor.constraint(equalTo: kontenerTresci.widthAnchor, multiplier: 0.45, constant: -25),

            kontenerHistorii.topAnchor.constraint(equalTo: przyciskSprawdz.bottomAnchor, constant: 24),
            kontenerHistorii.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 20),
            kontenerHistorii.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -20),
            kontenerHistorii.bottomAnchor.constraint(equalTo: kontenerTresci.bottomAnchor, constant: -20)
        ])

        // Board tiles - Grid layout for both modes
        for (indeks, widok) in widokiKafelekPlanszy.enumerated() {
            widok.translatesAutoresizingMaskIntoConstraints = false

            if poziom == .trudny {
                // 2x4 grid layout for hard mode
                let row = indeks / 4  // 0 or 1
                let col = indeks % 4  // 0, 1, 2, or 3

                NSLayoutConstraint.activate([
                    widok.leadingAnchor.constraint(equalTo: kontenerPlanszy.leadingAnchor, constant: 16 + CGFloat(col) * (rozmiarKafelki + odstep)),
                    widok.topAnchor.constraint(equalTo: kontenerPlanszy.topAnchor, constant: 8 + CGFloat(row) * (rozmiarKafelki + odstep)),
                    widok.widthAnchor.constraint(equalToConstant: rozmiarKafelki),
                    widok.heightAnchor.constraint(equalToConstant: rozmiarKafelki)
                ])
            } else {
                // 2x3 grid layout for easy mode (6 tiles)
                let row = indeks / 3  // 0 or 1
                let col = indeks % 3  // 0, 1, or 2

                NSLayoutConstraint.activate([
                    widok.leadingAnchor.constraint(equalTo: kontenerPlanszy.leadingAnchor, constant: 16 + CGFloat(col) * (rozmiarKafelki + odstep)),
                    widok.topAnchor.constraint(equalTo: kontenerPlanszy.topAnchor, constant: 8 + CGFloat(row) * (rozmiarKafelki + odstep)),
                    widok.widthAnchor.constraint(equalToConstant: rozmiarKafelki),
                    widok.heightAnchor.constraint(equalToConstant: rozmiarKafelki)
                ])
            }
        }

        // Hand tiles - Single row layout for all difficulties
        for (indeks, widok) in widokiKafelekReki.enumerated() {
            widok.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                widok.leadingAnchor.constraint(equalTo: kontenerReki.leadingAnchor, constant: 12 + CGFloat(indeks) * (rozmiarKafelki + odstep)),
                widok.centerYAnchor.constraint(equalTo: kontenerReki.centerYAnchor),
                widok.widthAnchor.constraint(equalToConstant: rozmiarKafelki),
                widok.heightAnchor.constraint(equalToConstant: rozmiarKafelki)
            ])
        }
    }

    // MARK: - UI Update

    private func odswiezInterfejs() {
        etykietaProb.text = "Attempts: \(stanGry.liczbaProb)"

        let obecnePunkty = poziom.punktyDlaProb(stanGry.liczbaProb + 1)
        etykietaPunktow.text = "Potential Score: \(obecnePunkty)"
        etykietaCalkowitychPunktow.text = "Total Score: \(calkowitePunkty) | Rounds: \(liczbaRozgrywek)"

        // Update board tiles
        for (indeks, widok) in widokiKafelekPlanszy.enumerated() {
            widok.konfiguruj(kafelka: stanGry.obecnePołozenie[indeks])
            widok.ustawPodswietlenie(false)
        }

        // Update hand tiles
        for (indeks, widok) in widokiKafelekReki.enumerated() {
            let kafelka = stanGry.dostepneKafelki[indeks]
            let jestUzywana = stanGry.wybrane.values.contains(indeks)
            widok.konfiguruj(kafelka: jestUzywana ? nil : kafelka)

            if let wybrana = wybranaKafelkaReki, wybrana == indeks {
                widok.ustawPodswietlenie(true)
            } else {
                widok.ustawPodswietlenie(false)
            }
        }
    }

    // MARK: - Interactions

    @objc private func dotknietoPozycjeReki(_ rozpoznawacz: UITapGestureRecognizer) {
        guard let widok = rozpoznawacz.view as? WidokKafelki else { return }
        let indeks = widok.tag

        // Check if tile is already used
        if stanGry.wybrane.values.contains(indeks) {
            return
        }

        if wybranaKafelkaReki == indeks {
            wybranaKafelkaReki = nil
        } else {
            wybranaKafelkaReki = indeks
        }

        odswiezInterfejs()
    }

    @objc private func dotknietoPozycjePlanszy(_ rozpoznawacz: UITapGestureRecognizer) {
        guard let widok = rozpoznawacz.view as? WidokKafelki else { return }
        let pozycjaPlanszy = widok.tag

        // Only allow placing tiles in empty slots
        if stanGry.oryginalnePołozenie[pozycjaPlanszy] == stanGry.obecnePołozenie[pozycjaPlanszy] {
            return // This is a fixed tile
        }

        if let wybranaReka = wybranaKafelkaReki {
            // Place the selected tile
            let kafelka = stanGry.dostepneKafelki[wybranaReka]
            stanGry.obecnePołozenie[pozycjaPlanszy] = kafelka
            stanGry.wybrane[pozycjaPlanszy] = wybranaReka
            wybranaKafelkaReki = nil
        } else {
            // Remove tile from board
            if let indeksReki = stanGry.wybrane[pozycjaPlanszy] {
                stanGry.wybrane.removeValue(forKey: pozycjaPlanszy)
                stanGry.obecnePołozenie[pozycjaPlanszy] = nil
            }
        }

        odswiezInterfejs()
    }

    @objc private func sprawdzUlozenie() {
        // Check if all positions are filled
        for kafelka in stanGry.obecnePołozenie {
            if kafelka == nil {
                pokazAlert(tytul: "Incomplete", wiadomosc: "Please fill all positions before checking.")
                return
            }
        }

        stanGry.liczbaProb += 1
        let wyniki = MenadzerGry.wspoldzielony.sprawdzUlozenie(stan: stanGry)

        // Add to history
        let proba = ProbaUlozenia(
            numer: stanGry.liczbaProb,
            ulozenie: stanGry.obecnePołozenie,
            wyniki: wyniki,
            wybranePozycje: Set(stanGry.wybrane.keys)
        )
        stanGry.historiaProb.append(proba)

        // Check win
        if MenadzerGry.wspoldzielony.czyWygrana(stan: stanGry) {
            pokazWynik()
        } else {
            pokazWynikiProby(wyniki: wyniki)
            dodajDoHistorii(proba: proba)
        }

        odswiezInterfejs()
    }

    @objc private func resetujWybor() {
        wybranaKafelkaReki = nil
        stanGry.resetujWybor()

        // Clear validation icons and borders
        widokiKafelekPlanszy.forEach {
            $0.ustawKolorObramowania(.clear, szerokosc: 0)
            $0.ukryjIkoneWalidacji()
        }

        odswiezInterfejs()
    }

    @objc private func powrot() {
        dismiss(animated: true)
    }

    // MARK: - Helpers

    private func pokazWynikiProby(wyniki: [WynikPozycji]) {
        for (indeks, wynik) in wyniki.enumerated() {
            let widok = widokiKafelekPlanszy[indeks]

            // Only show validation for tiles placed by the player
            let czyWybranyPrzezGracza = stanGry.wybrane.keys.contains(indeks)

            if czyWybranyPrzezGracza {
                switch wynik {
                case .poprawny:
                    animujPoprawnaKafelke(widok: widok)
                case .niepoprawny:
                    animujBlednaKafelke(widok: widok)
                case .pusty:
                    break
                }
            }
        }
    }

    private func animujPoprawnaKafelke(widok: WidokKafelki) {
        widok.ustawKolorObramowania(UIColor.green, szerokosc: 3)
        widok.pokazIkoneWalidacji("✓", kolor: UIColor.green)

        UIView.animate(withDuration: 0.3, animations: {
            widok.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                widok.transform = .identity
            }
        }
    }

    private func animujBlednaKafelke(widok: WidokKafelki) {
        widok.ustawKolorObramowania(UIColor.red, szerokosc: 3)
        widok.pokazIkoneWalidacji("✗", kolor: UIColor.red)

        UIView.animate(withDuration: 0.1, animations: {
            widok.transform = CGAffineTransform(translationX: -5, y: 0)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                widok.transform = CGAffineTransform(translationX: 5, y: 0)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    widok.transform = .identity
                }
            }
        }
    }

    private func dodajDoHistorii(proba: ProbaUlozenia) {
        let widokHistorii = stworzWidokHistorii(proba: proba)
        stosHistorii.insertArrangedSubview(widokHistorii, at: 0)

        // Scroll to top
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.widokPrzewijaniHistorii.setContentOffset(.zero, animated: true)
        }
    }

    private func stworzWidokHistorii(proba: ProbaUlozenia) -> UIView {
        let kontener = UIView()
        kontener.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        kontener.layer.cornerRadius = 8

        let etykieta = UILabel()
        etykieta.text = "Attempt #\(proba.numer)"
        etykieta.font = UIFont.boldSystemFont(ofSize: 12)
        etykieta.textColor = .white
        kontener.addSubview(etykieta)
        etykieta.translatesAutoresizingMaskIntoConstraints = false

        let stos = UIStackView()
        stos.axis = .horizontal
        stos.spacing = 4
        stos.distribution = .fillEqually
        kontener.addSubview(stos)
        stos.translatesAutoresizingMaskIntoConstraints = false

        for (indeks, kafelka) in proba.ulozenie.enumerated() {
            let miniaturaWidok = UIImageView()
            miniaturaWidok.contentMode = .scaleAspectFit
            miniaturaWidok.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            miniaturaWidok.layer.cornerRadius = 4
            miniaturaWidok.clipsToBounds = true

            if let kafelka = kafelka {
                miniaturaWidok.image = UIImage(named: kafelka.nazwaObrazu)
            }

            // Only show validation markers for positions filled by player
            let czyWybranyPrzezGracza = proba.wybranePozycje.contains(indeks)
            let wynik = proba.wyniki[indeks]

            if czyWybranyPrzezGracza {
                switch wynik {
                case .poprawny:
                    miniaturaWidok.layer.borderColor = UIColor.green.cgColor
                    miniaturaWidok.layer.borderWidth = 2

                    let ikona = UILabel()
                    ikona.text = "✓"
                    ikona.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                    ikona.textColor = .green
                    ikona.backgroundColor = UIColor.white.withAlphaComponent(0.95)
                    ikona.textAlignment = .center
                    ikona.layer.cornerRadius = 7
                    ikona.clipsToBounds = true
                    miniaturaWidok.addSubview(ikona)
                    ikona.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        ikona.centerXAnchor.constraint(equalTo: miniaturaWidok.centerXAnchor),
                        ikona.centerYAnchor.constraint(equalTo: miniaturaWidok.centerYAnchor),
                        ikona.widthAnchor.constraint(equalToConstant: 14),
                        ikona.heightAnchor.constraint(equalToConstant: 14)
                    ])
                case .niepoprawny:
                    miniaturaWidok.layer.borderColor = UIColor.red.cgColor
                    miniaturaWidok.layer.borderWidth = 2

                    let ikona = UILabel()
                    ikona.text = "✗"
                    ikona.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                    ikona.textColor = .red
                    ikona.backgroundColor = UIColor.white.withAlphaComponent(0.95)
                    ikona.textAlignment = .center
                    ikona.layer.cornerRadius = 7
                    ikona.clipsToBounds = true
                    miniaturaWidok.addSubview(ikona)
                    ikona.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        ikona.centerXAnchor.constraint(equalTo: miniaturaWidok.centerXAnchor),
                        ikona.centerYAnchor.constraint(equalTo: miniaturaWidok.centerYAnchor),
                        ikona.widthAnchor.constraint(equalToConstant: 14),
                        ikona.heightAnchor.constraint(equalToConstant: 14)
                    ])
                case .pusty:
                    break
                }
            }

            stos.addArrangedSubview(miniaturaWidok)
        }

        NSLayoutConstraint.activate([
            etykieta.topAnchor.constraint(equalTo: kontener.topAnchor, constant: 8),
            etykieta.leadingAnchor.constraint(equalTo: kontener.leadingAnchor, constant: 8),

            stos.topAnchor.constraint(equalTo: etykieta.bottomAnchor, constant: 4),
            stos.leadingAnchor.constraint(equalTo: kontener.leadingAnchor, constant: 8),
            stos.trailingAnchor.constraint(equalTo: kontener.trailingAnchor, constant: -8),
            stos.bottomAnchor.constraint(equalTo: kontener.bottomAnchor, constant: -8),
            stos.heightAnchor.constraint(equalToConstant: 40)
        ])

        return kontener
    }

    private func pokazWynik() {
        let punkty = poziom.punktyDlaProb(stanGry.liczbaProb)

        // Add to cumulative score
        calkowitePunkty += punkty
        liczbaRozgrywek += 1

        let wiadomosc = """
        Congratulations!

        Attempts: \(stanGry.liczbaProb)
        Round Score: \(punkty) points
        Total Score: \(calkowitePunkty) points
        """

        let dialog = NiestandardoweOknoDialogowe()
        dialog.konfiguruj(
            tytul: "Success!",
            wiadomosc: wiadomosc,
            akcje: [
                (tytul: "Continue", styl: .podstawowy, akcja: { [weak self] in
                    self?.kontynuujGre()
                }),
                (tytul: "Back to Menu", styl: .wtorny, akcja: { [weak self] in
                    self?.zakonczSesje()
                })
            ]
        )
        dialog.pokaz(w: view)

        // Add celebration particles
        dodajEfektSwietowania()
    }

    private func kontynuujGre() {
        // Continue playing, start new round but keep cumulative score
        inicjalizujGre()
        wybranaKafelkaReki = nil

        // Clear history
        stosHistorii.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Reset tile views
        widokiKafelekPlanszy.forEach {
            $0.ustawKolorObramowania(.clear, szerokosc: 0)
            $0.ukryjIkoneWalidacji()
        }

        odswiezInterfejs()
    }

    @objc private func rozpocznijNowaGre() {
        // Save current session score before starting fresh
        if calkowitePunkty > 0 {
            MenadzerGry.wspoldzielony.zapiszRekord(poziom: poziom, punkty: calkowitePunkty, liczbaProb: liczbaRozgrywek)
        }

        // Reset cumulative scores
        calkowitePunkty = 0
        liczbaRozgrywek = 0

        // Start fresh game
        inicjalizujGre()
        wybranaKafelkaReki = nil

        // Clear history
        stosHistorii.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Reset tile views
        widokiKafelekPlanszy.forEach {
            $0.ustawKolorObramowania(.clear, szerokosc: 0)
            $0.ukryjIkoneWalidacji()
        }

        odswiezInterfejs()
    }

    private func zakonczSesje() {
        // Save session score to leaderboard
        if calkowitePunkty > 0 {
            MenadzerGry.wspoldzielony.zapiszRekord(poziom: poziom, punkty: calkowitePunkty, liczbaProb: liczbaRozgrywek)
        }

        dismiss(animated: true)
    }

    private func pokazAlert(tytul: String, wiadomosc: String) {
        let dialog = NiestandardoweOknoDialogowe()
        dialog.konfiguruj(
            tytul: tytul,
            wiadomosc: wiadomosc,
            akcje: [(tytul: "OK", styl: .podstawowy, akcja: nil)]
        )
        dialog.pokaz(w: view)
    }

    private func dodajEfektSwietowania() {
        let emiter = CAEmitterLayer()
        emiter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        emiter.emitterShape = .line
        emiter.emitterSize = CGSize(width: view.bounds.width, height: 1)

        let komorka = CAEmitterCell()
        komorka.birthRate = 10
        komorka.lifetime = 5.0
        komorka.velocity = 200
        komorka.velocityRange = 100
        komorka.emissionLongitude = .pi
        komorka.emissionRange = .pi / 4
        komorka.scale = 0.05
        komorka.scaleRange = 0.02
        komorka.contents = UIImage(systemName: "star.fill")?.cgImage
        komorka.color = UIColor.yellow.cgColor

        emiter.emitterCells = [komorka]
        view.layer.addSublayer(emiter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            emiter.removeFromSuperlayer()
        }
    }
}
