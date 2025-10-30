//
//  KontrolerFormularzaOpinii.swift
//  BrainSort
//
//  Feedback form screen
//

import UIKit

class KontrolerFormularzaOpinii: UIViewController {

    private let poletekstowe = UITextView()
    private let przyciskWyslij = UIButton(type: .custom)
    private let licznikZnakow = UILabel()

    private let maksymalnaLiczbaNakow = 500

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        ustawWyglad()
        ustawOgraniczenia()

        // Keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(klawiaturaPokaze(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(klawiaturaUkryje(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func ustawWyglad() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1.0)

        // Title
        let etykietaTytulu = UILabel()
        etykietaTytulu.text = "💬 Send Feedback"
        etykietaTytulu.font = UIFont.boldSystemFont(ofSize: 28)
        etykietaTytulu.textColor = UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0)
        etykietaTytulu.textAlignment = .center
        view.addSubview(etykietaTytulu)

        // Close button
        let przyciskZamknij = UIButton(type: .system)
        przyciskZamknij.setTitle("✕", for: .normal)
        przyciskZamknij.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        przyciskZamknij.setTitleColor(UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0), for: .normal)
        przyciskZamknij.addTarget(self, action: #selector(zamknij), for: .touchUpInside)
        view.addSubview(przyciskZamknij)

        // Description
        let etykietaOpisu = UILabel()
        etykietaOpisu.text = "We'd love to hear your thoughts!\nPlease share your feedback below."
        etykietaOpisu.font = UIFont.systemFont(ofSize: 14)
        etykietaOpisu.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        etykietaOpisu.textAlignment = .center
        etykietaOpisu.numberOfLines = 0
        view.addSubview(etykietaOpisu)

        // Text view
        poletekstowe.font = UIFont.systemFont(ofSize: 16)
        poletekstowe.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        poletekstowe.backgroundColor = .white
        poletekstowe.layer.cornerRadius = 12
        poletekstowe.layer.borderWidth = 1
        poletekstowe.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        poletekstowe.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        poletekstowe.delegate = self
        view.addSubview(poletekstowe)

        // Character counter
        licznikZnakow.text = "0 / \(maksymalnaLiczbaNakow)"
        licznikZnakow.font = UIFont.systemFont(ofSize: 12)
        licznikZnakow.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        licznikZnakow.textAlignment = .right
        view.addSubview(licznikZnakow)

        // Submit button
        przyciskWyslij.setTitle("Send Feedback", for: .normal)
        przyciskWyslij.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        przyciskWyslij.setTitleColor(.white, for: .normal)
        przyciskWyslij.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.5, alpha: 1.0)
        przyciskWyslij.layer.cornerRadius = 12
        przyciskWyslij.addTarget(self, action: #selector(wyslijOpinie), for: .touchUpInside)
        view.addSubview(przyciskWyslij)

        etykietaTytulu.translatesAutoresizingMaskIntoConstraints = false
        przyciskZamknij.translatesAutoresizingMaskIntoConstraints = false
        etykietaOpisu.translatesAutoresizingMaskIntoConstraints = false
        poletekstowe.translatesAutoresizingMaskIntoConstraints = false
        licznikZnakow.translatesAutoresizingMaskIntoConstraints = false
        przyciskWyslij.translatesAutoresizingMaskIntoConstraints = false
    }

    private func ustawOgraniczenia() {
        guard let etykietaTytulu = view.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.text?.contains("Send Feedback") ?? false }),
              let przyciskZamknij = view.subviews.compactMap({ $0 as? UIButton }).first(where: { $0.currentTitle == "✕" }),
              let etykietaOpisu = view.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.text?.contains("We'd love") ?? false })
        else { return }

        NSLayoutConstraint.activate([
            etykietaTytulu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            etykietaTytulu.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            przyciskZamknij.centerYAnchor.constraint(equalTo: etykietaTytulu.centerYAnchor),
            przyciskZamknij.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            etykietaOpisu.topAnchor.constraint(equalTo: etykietaTytulu.bottomAnchor, constant: 16),
            etykietaOpisu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            etykietaOpisu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            poletekstowe.topAnchor.constraint(equalTo: etykietaOpisu.bottomAnchor, constant: 24),
            poletekstowe.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            poletekstowe.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            poletekstowe.heightAnchor.constraint(equalToConstant: 200),

            licznikZnakow.topAnchor.constraint(equalTo: poletekstowe.bottomAnchor, constant: 8),
            licznikZnakow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            przyciskWyslij.topAnchor.constraint(equalTo: licznikZnakow.bottomAnchor, constant: 24),
            przyciskWyslij.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            przyciskWyslij.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            przyciskWyslij.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    // MARK: - Actions

    @objc private func wyslijOpinie() {
        let tekst = poletekstowe.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if tekst.isEmpty {
            pokazAlert(tytul: "Empty Feedback", wiadomosc: "Please write something before submitting.")
            return
        }

        MenadzerGry.wspoldzielony.zapiszOpinie(tekst)

        let dialog = NiestandardoweOknoDialogowe()
        dialog.konfiguruj(
            tytul: "Thank You!",
            wiadomosc: "Your feedback has been saved locally.\nWe appreciate your input!",
            akcje: [(tytul: "OK", styl: .podstawowy, akcja: { [weak self] in
                self?.dismiss(animated: true)
            })]
        )
        dialog.pokaz(w: view)

        poletekstowe.text = ""
        aktualizujLicznikZnakow()
    }

    @objc private func zamknij() {
        view.endEditing(true)
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

    private func aktualizujLicznikZnakow() {
        let liczba = poletekstowe.text.count
        licznikZnakow.text = "\(liczba) / \(maksymalnaLiczbaNakow)"

        if liczba > maksymalnaLiczbaNakow {
            licznikZnakow.textColor = .red
        } else {
            licznikZnakow.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        }
    }

    // MARK: - Keyboard

    @objc private func klawiaturaPokaze(_ powiadomienie: Notification) {
        guard let rozmiarKlawiatury = (powiadomienie.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let dolnaKrawedz = przyciskWyslij.frame.maxY
        let wysokoscKlawiatury = rozmiarKlawiatury.height

        if dolnaKrawedz > view.frame.height - wysokoscKlawiatury {
            let przesuniecie = dolnaKrawedz - (view.frame.height - wysokoscKlawiatury) + 20
            view.frame.origin.y = -przesuniecie
        }
    }

    @objc private func klawiaturaUkryje(_ powiadomienie: Notification) {
        view.frame.origin.y = 0
    }
}

// MARK: - UITextViewDelegate

extension KontrolerFormularzaOpinii: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        aktualizujLicznikZnakow()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let obecnyTekst = textView.text ?? ""
        let nowyTekst = (obecnyTekst as NSString).replacingCharacters(in: range, with: text)

        return nowyTekst.count <= maksymalnaLiczbaNakow
    }
}
