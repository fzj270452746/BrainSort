//
//  WidokKafelki.swift
//  BrainSort
//
//  Mahjong tile view component
//

import UIKit

class WidokKafelki: UIView {

    private let widokObrazu = UIImageView()
    private let nakładkaPodswietlenia = UIView()
    private var etykietaWalidacji: UILabel?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        ustawWyglad()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        ustawWyglad()
    }

    private func ustawWyglad() {
        backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1.0)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0).cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4

        // Image view
        widokObrazu.contentMode = .scaleAspectFit
        widokObrazu.clipsToBounds = true
        addSubview(widokObrazu)

        widokObrazu.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widokObrazu.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            widokObrazu.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            widokObrazu.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            widokObrazu.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])

        // Highlight overlay
        nakładkaPodswietlenia.backgroundColor = UIColor.yellow.withAlphaComponent(0.3)
        nakładkaPodswietlenia.layer.cornerRadius = 8
        nakładkaPodswietlenia.isHidden = true
        addSubview(nakładkaPodswietlenia)

        nakładkaPodswietlenia.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nakładkaPodswietlenia.topAnchor.constraint(equalTo: topAnchor),
            nakładkaPodswietlenia.leadingAnchor.constraint(equalTo: leadingAnchor),
            nakładkaPodswietlenia.trailingAnchor.constraint(equalTo: trailingAnchor),
            nakładkaPodswietlenia.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Configuration

    func konfiguruj(kafelka: Kafelka?) {
        if let kafelka = kafelka {
            widokObrazu.image = UIImage(named: kafelka.nazwaObrazu)
            backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1.0)
            widokObrazu.alpha = 1.0
        } else {
            widokObrazu.image = nil
            backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.3)
            widokObrazu.alpha = 0.0
        }
    }

    func ustawPodswietlenie(_ podswietlone: Bool) {
        nakładkaPodswietlenia.isHidden = !podswietlone

        if podswietlone {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        }
    }

    func ustawKolorObramowania(_ kolor: UIColor, szerokosc: CGFloat) {
        layer.borderColor = kolor.cgColor
        layer.borderWidth = szerokosc
    }

    func dodajAkcjeDotyku(cel: Any, akcja: Selector) {
        let rozpoznawacz = UITapGestureRecognizer(target: cel, action: akcja)
        addGestureRecognizer(rozpoznawacz)
        isUserInteractionEnabled = true
    }

    func pokazIkoneWalidacji(_ ikona: String, kolor: UIColor) {
        // Remove existing validation icon if any
        etykietaWalidacji?.removeFromSuperview()

        // Create new validation icon
        let etykieta = UILabel()
        etykieta.text = ikona
        etykieta.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        etykieta.textColor = kolor
        etykieta.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        etykieta.textAlignment = .center
        etykieta.layer.cornerRadius = 12
        etykieta.clipsToBounds = true
        addSubview(etykieta)

        etykieta.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            etykieta.centerXAnchor.constraint(equalTo: centerXAnchor),
            etykieta.centerYAnchor.constraint(equalTo: centerYAnchor),
            etykieta.widthAnchor.constraint(equalToConstant: 24),
            etykieta.heightAnchor.constraint(equalToConstant: 24)
        ])

        etykietaWalidacji = etykieta

        // Animate icon appearance
        etykieta.alpha = 0
        etykieta.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            etykieta.alpha = 1.0
            etykieta.transform = .identity
        })
    }

    func ukryjIkoneWalidacji() {
        etykietaWalidacji?.removeFromSuperview()
        etykietaWalidacji = nil
    }
}
