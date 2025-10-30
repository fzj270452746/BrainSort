//
//  NiestandardoweOknoDialogowe.swift
//  BrainSort
//
//  Custom alert dialog with beautiful design
//

import UIKit

class NiestandardoweOknoDialogowe: UIView {

    private let kontenerWidoku = UIView()
    private let etykietaTytulu = UILabel()
    private let etykietaWiadomosci = UILabel()
    private let stosGuzikow = UIStackView()

    private var przyciski: [UIButton] = []
    private var akcje: [(() -> Void)?] = []

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        ustawWyglad()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func ustawWyglad() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        alpha = 0

        // Container
        kontenerWidoku.backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1.0)
        kontenerWidoku.layer.cornerRadius = 20
        kontenerWidoku.layer.shadowColor = UIColor.black.cgColor
        kontenerWidoku.layer.shadowOpacity = 0.3
        kontenerWidoku.layer.shadowOffset = CGSize(width: 0, height: 10)
        kontenerWidoku.layer.shadowRadius = 20
        kontenerWidoku.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        addSubview(kontenerWidoku)

        // Title
        etykietaTytulu.font = UIFont.boldSystemFont(ofSize: 24)
        etykietaTytulu.textColor = UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0)
        etykietaTytulu.textAlignment = .center
        etykietaTytulu.numberOfLines = 0
        kontenerWidoku.addSubview(etykietaTytulu)

        // Message
        etykietaWiadomosci.font = UIFont.systemFont(ofSize: 16)
        etykietaWiadomosci.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        etykietaWiadomosci.textAlignment = .center
        etykietaWiadomosci.numberOfLines = 0
        kontenerWidoku.addSubview(etykietaWiadomosci)

        // Button stack
        stosGuzikow.axis = .vertical
        stosGuzikow.spacing = 12
        stosGuzikow.distribution = .fillEqually
        kontenerWidoku.addSubview(stosGuzikow)

        ustawOgraniczenia()
    }

    private func ustawOgraniczenia() {
        kontenerWidoku.translatesAutoresizingMaskIntoConstraints = false
        etykietaTytulu.translatesAutoresizingMaskIntoConstraints = false
        etykietaWiadomosci.translatesAutoresizingMaskIntoConstraints = false
        stosGuzikow.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            kontenerWidoku.centerXAnchor.constraint(equalTo: centerXAnchor),
            kontenerWidoku.centerYAnchor.constraint(equalTo: centerYAnchor),
            kontenerWidoku.widthAnchor.constraint(equalToConstant: 300),

            etykietaTytulu.topAnchor.constraint(equalTo: kontenerWidoku.topAnchor, constant: 24),
            etykietaTytulu.leadingAnchor.constraint(equalTo: kontenerWidoku.leadingAnchor, constant: 20),
            etykietaTytulu.trailingAnchor.constraint(equalTo: kontenerWidoku.trailingAnchor, constant: -20),

            etykietaWiadomosci.topAnchor.constraint(equalTo: etykietaTytulu.bottomAnchor, constant: 16),
            etykietaWiadomosci.leadingAnchor.constraint(equalTo: kontenerWidoku.leadingAnchor, constant: 20),
            etykietaWiadomosci.trailingAnchor.constraint(equalTo: kontenerWidoku.trailingAnchor, constant: -20),

            stosGuzikow.topAnchor.constraint(equalTo: etykietaWiadomosci.bottomAnchor, constant: 24),
            stosGuzikow.leadingAnchor.constraint(equalTo: kontenerWidoku.leadingAnchor, constant: 20),
            stosGuzikow.trailingAnchor.constraint(equalTo: kontenerWidoku.trailingAnchor, constant: -20),
            stosGuzikow.bottomAnchor.constraint(equalTo: kontenerWidoku.bottomAnchor, constant: -20),
            stosGuzikow.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }

    // MARK: - Configuration

    func konfiguruj(tytul: String, wiadomosc: String, akcje: [(tytul: String, styl: StylPrzycisku, akcja: (() -> Void)?)]) {
        etykietaTytulu.text = tytul
        etykietaWiadomosci.text = wiadomosc

        // Clear previous buttons
        stosGuzikow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        przyciski.removeAll()
        self.akcje.removeAll()

        // Add buttons
        for (indeks, konfiguracja) in akcje.enumerated() {
            let przycisk = stworzPrzycisk(tytul: konfiguracja.tytul, styl: konfiguracja.styl, tag: indeks)
            stosGuzikow.addArrangedSubview(przycisk)
            przyciski.append(przycisk)
            self.akcje.append(konfiguracja.akcja)
        }
    }

    private func stworzPrzycisk(tytul: String, styl: StylPrzycisku, tag: Int) -> UIButton {
        let przycisk = UIButton(type: .system)
        przycisk.setTitle(tytul, for: .normal)
        przycisk.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        przycisk.layer.cornerRadius = 12
        przycisk.tag = tag
        przycisk.addTarget(self, action: #selector(obsluzKliknieciePrzycisku(_:)), for: .touchUpInside)

        switch styl {
        case .podstawowy:
            przycisk.backgroundColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
            przycisk.setTitleColor(.white, for: .normal)
        case .wtorny:
            przycisk.backgroundColor = UIColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 1.0)
            przycisk.setTitleColor(.white, for: .normal)
        case .anuluj:
            przycisk.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            przycisk.setTitleColor(.white, for: .normal)
        }

        przycisk.heightAnchor.constraint(equalToConstant: 50).isActive = true

        return przycisk
    }

    @objc private func obsluzKliknieciePrzycisku(_ przycisk: UIButton) {
        let tag = przycisk.tag
        ukryj {
            if tag < self.akcje.count {
                self.akcje[tag]?()
            }
        }
    }

    // MARK: - Show/Hide

    func pokaz(w widoku: UIView) {
        frame = widoku.bounds
        widoku.addSubview(self)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.alpha = 1
            self.kontenerWidoku.transform = .identity
        }
    }

    func ukryj(zakonczenie: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.kontenerWidoku.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
            zakonczenie?()
        }
    }

    enum StylPrzycisku {
        case podstawowy  // Primary
        case wtorny      // Secondary
        case anuluj      // Cancel
    }
}
