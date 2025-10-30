//
//  KontrolerTabeliWynikow.swift
//  BrainSort
//
//  Leaderboard screen
//

import UIKit

class KontrolerTabeliWynikow: UIViewController {

    private let widokTabeli = UITableView()
    private var rekordyLatwe: [RekordGry] = []
    private var rekordyTrudne: [RekordGry] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        ustawWyglad()
        zaladujRekordy()
    }

    // MARK: - Setup

    private func ustawWyglad() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.88, alpha: 1.0)

        // Title
        let etykietaTytulu = UILabel()
        etykietaTytulu.text = "🏆 Leaderboard"
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

        // Table view
        widokTabeli.backgroundColor = .clear
        widokTabeli.separatorStyle = .none
        widokTabeli.delegate = self
        widokTabeli.dataSource = self
        widokTabeli.register(KomorkaRekordu.self, forCellReuseIdentifier: "KomorkaRekordu")
        view.addSubview(widokTabeli)

        // Layout
        etykietaTytulu.translatesAutoresizingMaskIntoConstraints = false
        przyciskZamknij.translatesAutoresizingMaskIntoConstraints = false
        widokTabeli.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            etykietaTytulu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            etykietaTytulu.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            przyciskZamknij.centerYAnchor.constraint(equalTo: etykietaTytulu.centerYAnchor),
            przyciskZamknij.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            widokTabeli.topAnchor.constraint(equalTo: etykietaTytulu.bottomAnchor, constant: 20),
            widokTabeli.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            widokTabeli.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            widokTabeli.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func zaladujRekordy() {
        rekordyLatwe = MenadzerGry.wspoldzielony.pobierzNajlepszychGraczy(poziom: .latwy, limit: 25)
        rekordyTrudne = MenadzerGry.wspoldzielony.pobierzNajlepszychGraczy(poziom: .trudny, limit: 25)
        widokTabeli.reloadData()
    }

    @objc private func zamknij() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension KontrolerTabeliWynikow: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Easy and Hard sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rekordy = section == 0 ? rekordyLatwe : rekordyTrudne
        if rekordy.isEmpty {
            return 1 // Show empty state
        }
        return rekordy.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rekordy = indexPath.section == 0 ? rekordyLatwe : rekordyTrudne

        if rekordy.isEmpty {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            cell.selectionStyle = .none

            let etykieta = UILabel()
            etykieta.text = "No records yet.\nPlay some games!"
            etykieta.numberOfLines = 0
            etykieta.textAlignment = .center
            etykieta.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
            etykieta.font = UIFont.systemFont(ofSize: 14)
            cell.contentView.addSubview(etykieta)

            etykieta.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                etykieta.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
                etykieta.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                etykieta.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                etykieta.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20)
            ])

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "KomorkaRekordu", for: indexPath) as! KomorkaRekordu
        let rekord = rekordy[indexPath.row]
        cell.konfiguruj(rekord: rekord, pozycja: indexPath.row + 1)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "🟢 EASY MODE" : "🔴 HARD MODE"
    }
}

// MARK: - UITableViewDelegate

extension KontrolerTabeliWynikow: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rekordy = indexPath.section == 0 ? rekordyLatwe : rekordyTrudne
        return rekordy.isEmpty ? 100 : 80
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let widokNaglowka = UIView()
        widokNaglowka.backgroundColor = UIColor(red: 0.85, green: 0.82, blue: 0.78, alpha: 1.0)

        let etykieta = UILabel()
        etykieta.text = section == 0 ? "🟢 EASY MODE" : "🔴 HARD MODE"
        etykieta.font = UIFont.boldSystemFont(ofSize: 16)
        etykieta.textColor = UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        widokNaglowka.addSubview(etykieta)

        etykieta.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            etykieta.leadingAnchor.constraint(equalTo: widokNaglowka.leadingAnchor, constant: 20),
            etykieta.centerYAnchor.constraint(equalTo: widokNaglowka.centerYAnchor)
        ])

        return widokNaglowka
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - Record Cell

class KomorkaRekordu: UITableViewCell {

    private let kontenerWidoku = UIView()
    private let etykietaPozycji = UILabel()
    private let etykietaPoziomu = UILabel()
    private let etykietaPunktow = UILabel()
    private let etykietaProb = UILabel()
    private let etykietaDaty = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        ustawWyglad()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func ustawWyglad() {
        backgroundColor = .clear
        selectionStyle = .none

        kontenerWidoku.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        kontenerWidoku.layer.cornerRadius = 12
        kontenerWidoku.layer.shadowColor = UIColor.black.cgColor
        kontenerWidoku.layer.shadowOpacity = 0.1
        kontenerWidoku.layer.shadowOffset = CGSize(width: 0, height: 2)
        kontenerWidoku.layer.shadowRadius = 4
        contentView.addSubview(kontenerWidoku)

        etykietaPozycji.font = UIFont.boldSystemFont(ofSize: 24)
        etykietaPozycji.textColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        etykietaPozycji.textAlignment = .center
        kontenerWidoku.addSubview(etykietaPozycji)

        etykietaPoziomu.font = UIFont.boldSystemFont(ofSize: 14)
        etykietaPoziomu.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        kontenerWidoku.addSubview(etykietaPoziomu)

        etykietaPunktow.font = UIFont.boldSystemFont(ofSize: 20)
        etykietaPunktow.textColor = UIColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0)
        etykietaPunktow.textAlignment = .right
        kontenerWidoku.addSubview(etykietaPunktow)

        etykietaProb.font = UIFont.systemFont(ofSize: 12)
        etykietaProb.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        etykietaProb.textAlignment = .right
        kontenerWidoku.addSubview(etykietaProb)

        etykietaDaty.font = UIFont.systemFont(ofSize: 11)
        etykietaDaty.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        kontenerWidoku.addSubview(etykietaDaty)

        ustawOgraniczenia()
    }

    private func ustawOgraniczenia() {
        kontenerWidoku.translatesAutoresizingMaskIntoConstraints = false
        etykietaPozycji.translatesAutoresizingMaskIntoConstraints = false
        etykietaPoziomu.translatesAutoresizingMaskIntoConstraints = false
        etykietaPunktow.translatesAutoresizingMaskIntoConstraints = false
        etykietaProb.translatesAutoresizingMaskIntoConstraints = false
        etykietaDaty.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            kontenerWidoku.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            kontenerWidoku.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            kontenerWidoku.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            kontenerWidoku.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            etykietaPozycji.leadingAnchor.constraint(equalTo: kontenerWidoku.leadingAnchor, constant: 16),
            etykietaPozycji.centerYAnchor.constraint(equalTo: kontenerWidoku.centerYAnchor),
            etykietaPozycji.widthAnchor.constraint(equalToConstant: 40),

            etykietaPoziomu.leadingAnchor.constraint(equalTo: etykietaPozycji.trailingAnchor, constant: 12),
            etykietaPoziomu.topAnchor.constraint(equalTo: kontenerWidoku.topAnchor, constant: 12),

            etykietaDaty.leadingAnchor.constraint(equalTo: etykietaPozycji.trailingAnchor, constant: 12),
            etykietaDaty.bottomAnchor.constraint(equalTo: kontenerWidoku.bottomAnchor, constant: -12),

            etykietaPunktow.trailingAnchor.constraint(equalTo: kontenerWidoku.trailingAnchor, constant: -16),
            etykietaPunktow.topAnchor.constraint(equalTo: kontenerWidoku.topAnchor, constant: 12),

            etykietaProb.trailingAnchor.constraint(equalTo: kontenerWidoku.trailingAnchor, constant: -16),
            etykietaProb.bottomAnchor.constraint(equalTo: kontenerWidoku.bottomAnchor, constant: -12)
        ])
    }

    func konfiguruj(rekord: RekordGry, pozycja: Int) {
        // Position with medal emoji for top 3
        let tekstPozycji: String
        switch pozycja {
        case 1: tekstPozycji = "🥇"
        case 2: tekstPozycji = "🥈"
        case 3: tekstPozycji = "🥉"
        default: tekstPozycji = "#\(pozycja)"
        }
        etykietaPozycji.text = tekstPozycji

        etykietaPoziomu.text = rekord.poziom
        etykietaPunktow.text = "\(rekord.punkty) pts"
        etykietaProb.text = "\(rekord.liczbaProb) attempts"
        etykietaDaty.text = rekord.dataFormatowana
    }
}
