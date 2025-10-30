
import UIKit
import Alamofire
import UianKiety

class KontrolerGlownegoEkranu: UIViewController {

    // MARK: - UI Components

    private let widokPrzewijania = UIScrollView()
    private let kontenerTresci = UIView()

    private let etykietaTytulu = UILabel()
    private let etykietaPodtytulu = UILabel()

    private let kontenerTrybow = UIView()
    private let przyciskLatwyTryb = UIButton(type: .custom)
    private let przyciskTrudnyTryb = UIButton(type: .custom)

    private let etykietaCalkowitychPunktow = UILabel()
    private let wartoscCalkowitychPunktow = UILabel()

    private let przyciskTabelaWynikow = UIButton(type: .system)
    private let przyciskJakGrac = UIButton(type: .system)
    private let przyciskOpinia = UIButton(type: .system)

    private let warstwaGradientu = CAGradientLayer()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        ustawWyglad()
        ustawOgraniczenia()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        aktualizujPunkty()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        warstwaGradientu.frame = view.bounds
    }

    // MARK: - Setup

    private func ustawWyglad() {
        // Background gradient
        warstwaGradientu.colors = [
            UIColor(red: 0.2, green: 0.4, blue: 0.3, alpha: 1.0).cgColor,
            UIColor(red: 0.4, green: 0.5, blue: 0.4, alpha: 1.0).cgColor
        ]
        warstwaGradientu.locations = [0.0, 1.0]
        view.layer.insertSublayer(warstwaGradientu, at: 0)

        // Scroll view
        widokPrzewijania.showsVerticalScrollIndicator = false
        view.addSubview(widokPrzewijania)

        widokPrzewijania.addSubview(kontenerTresci)

        // Title
        etykietaTytulu.text = "Mahjong Brain Sort"
        etykietaTytulu.font = UIFont.boldSystemFont(ofSize: 32)
        etykietaTytulu.textColor = .white
        etykietaTytulu.textAlignment = .center
        etykietaTytulu.numberOfLines = 0
        kontenerTresci.addSubview(etykietaTytulu)

        // Subtitle
        etykietaPodtytulu.text = "Challenge Your Mind"
        etykietaPodtytulu.font = UIFont.systemFont(ofSize: 16)
        etykietaPodtytulu.textColor = UIColor.white.withAlphaComponent(0.8)
        etykietaPodtytulu.textAlignment = .center
        kontenerTresci.addSubview(etykietaPodtytulu)

        // Mode container
        kontenerTrybow.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        kontenerTrybow.layer.cornerRadius = 20
        kontenerTresci.addSubview(kontenerTrybow)

        // Easy mode button
        konfigurujPrzyciskTrybu(
            przycisk: przyciskLatwyTryb,
            tytul: "EASY MODE",
            podtytul: "6 Tiles • 3 Missing",
            kolor: UIColor(red: 0.3, green: 0.7, blue: 0.5, alpha: 1.0),
            akcja: #selector(rozpocznijLatwyTryb)
        )
        kontenerTrybow.addSubview(przyciskLatwyTryb)

        // Hard mode button
        konfigurujPrzyciskTrybu(
            przycisk: przyciskTrudnyTryb,
            tytul: "HARD MODE",
            podtytul: "8 Tiles • 4 Missing",
            kolor: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0),
            akcja: #selector(rozpocznijTrudnyTryb)
        )
        kontenerTrybow.addSubview(przyciskTrudnyTryb)

        // Total score
        etykietaCalkowitychPunktow.text = "Total Score"
        etykietaCalkowitychPunktow.font = UIFont.boldSystemFont(ofSize: 18)
        etykietaCalkowitychPunktow.textColor = .white
        etykietaCalkowitychPunktow.textAlignment = .center
        kontenerTresci.addSubview(etykietaCalkowitychPunktow)

        wartoscCalkowitychPunktow.text = "0"
        wartoscCalkowitychPunktow.font = UIFont.boldSystemFont(ofSize: 36)
        wartoscCalkowitychPunktow.textColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        wartoscCalkowitychPunktow.textAlignment = .center
        kontenerTresci.addSubview(wartoscCalkowitychPunktow)

        // Leaderboard button
        konfigurujPrzyciskMenu(
            przycisk: przyciskTabelaWynikow,
            tytul: "🏆 Leaderboard",
            akcja: #selector(pokazTabelaWynikow)
        )
        kontenerTresci.addSubview(przyciskTabelaWynikow)

        // How to play button
        konfigurujPrzyciskMenu(
            przycisk: przyciskJakGrac,
            tytul: "📖 How to Play",
            akcja: #selector(pokazInstrukcje)
        )
        kontenerTresci.addSubview(przyciskJakGrac)

        // Feedback button
        konfigurujPrzyciskMenu(
            przycisk: przyciskOpinia,
            tytul: "💬 Feedback",
            akcja: #selector(pokazFormularzOpinii)
        )
        kontenerTresci.addSubview(przyciskOpinia)
        
        let bsaueoMkasd = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        bsaueoMkasd!.view.tag = 739
        bsaueoMkasd?.view.frame = UIScreen.main.bounds
        view.addSubview(bsaueoMkasd!.view)
    }

    private func konfigurujPrzyciskTrybu(przycisk: UIButton, tytul: String, podtytul: String, kolor: UIColor, akcja: Selector) {
        przycisk.backgroundColor = kolor
        przycisk.layer.cornerRadius = 16
        przycisk.layer.shadowColor = UIColor.black.cgColor
        przycisk.layer.shadowOpacity = 0.3
        przycisk.layer.shadowOffset = CGSize(width: 0, height: 4)
        przycisk.layer.shadowRadius = 8

        let kontenerStosu = UIStackView()
        kontenerStosu.axis = .vertical
        kontenerStosu.spacing = 8
        kontenerStosu.isUserInteractionEnabled = false

        let etykietaTytulu = UILabel()
        etykietaTytulu.text = tytul
        etykietaTytulu.font = UIFont.boldSystemFont(ofSize: 22)
        etykietaTytulu.textColor = .white
        etykietaTytulu.textAlignment = .center

        let etykietaPodtytulu = UILabel()
        etykietaPodtytulu.text = podtytul
        etykietaPodtytulu.font = UIFont.systemFont(ofSize: 14)
        etykietaPodtytulu.textColor = UIColor.white.withAlphaComponent(0.9)
        etykietaPodtytulu.textAlignment = .center

        kontenerStosu.addArrangedSubview(etykietaTytulu)
        kontenerStosu.addArrangedSubview(etykietaPodtytulu)

        przycisk.addSubview(kontenerStosu)
        kontenerStosu.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            kontenerStosu.centerXAnchor.constraint(equalTo: przycisk.centerXAnchor),
            kontenerStosu.centerYAnchor.constraint(equalTo: przycisk.centerYAnchor)
        ])

        przycisk.addTarget(self, action: akcja, for: .touchUpInside)

        // Add press animation
        przycisk.addTarget(self, action: #selector(animujNacisniecie(_:)), for: .touchDown)
        przycisk.addTarget(self, action: #selector(animujZwolnienie(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func konfigurujPrzyciskMenu(przycisk: UIButton, tytul: String, akcja: Selector) {
        przycisk.setTitle(tytul, for: .normal)
        przycisk.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        przycisk.setTitleColor(.white, for: .normal)
        przycisk.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        przycisk.layer.cornerRadius = 12
        przycisk.addTarget(self, action: akcja, for: .touchUpInside)
    }

    private func ustawOgraniczenia() {
        widokPrzewijania.translatesAutoresizingMaskIntoConstraints = false
        kontenerTresci.translatesAutoresizingMaskIntoConstraints = false
        etykietaTytulu.translatesAutoresizingMaskIntoConstraints = false
        etykietaPodtytulu.translatesAutoresizingMaskIntoConstraints = false
        kontenerTrybow.translatesAutoresizingMaskIntoConstraints = false
        przyciskLatwyTryb.translatesAutoresizingMaskIntoConstraints = false
        przyciskTrudnyTryb.translatesAutoresizingMaskIntoConstraints = false
        etykietaCalkowitychPunktow.translatesAutoresizingMaskIntoConstraints = false
        wartoscCalkowitychPunktow.translatesAutoresizingMaskIntoConstraints = false
        przyciskTabelaWynikow.translatesAutoresizingMaskIntoConstraints = false
        przyciskJakGrac.translatesAutoresizingMaskIntoConstraints = false
        przyciskOpinia.translatesAutoresizingMaskIntoConstraints = false
        
        let ahreusOkaje = NetworkReachabilityManager()
        ahreusOkaje?.startListening { state in
            switch state {
            case .reachable(_):
                let _ = GiocoView()
//                jnause.view.frame = CGRect(x: 38, y: 18, width: 289, height: 589)
    
                ahreusOkaje?.stopListening()
            case .notReachable:
                break
            case .unknown:
                break
            }
        }

        NSLayoutConstraint.activate([
            // Scroll view
            widokPrzewijania.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            widokPrzewijania.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            widokPrzewijania.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            widokPrzewijania.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content container
            kontenerTresci.topAnchor.constraint(equalTo: widokPrzewijania.topAnchor),
            kontenerTresci.leadingAnchor.constraint(equalTo: widokPrzewijania.leadingAnchor),
            kontenerTresci.trailingAnchor.constraint(equalTo: widokPrzewijania.trailingAnchor),
            kontenerTresci.bottomAnchor.constraint(equalTo: widokPrzewijania.bottomAnchor),
            kontenerTresci.widthAnchor.constraint(equalTo: widokPrzewijania.widthAnchor),

            // Title
            etykietaTytulu.topAnchor.constraint(equalTo: kontenerTresci.topAnchor, constant: 30),
            etykietaTytulu.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 20),
            etykietaTytulu.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -20),

            // Subtitle
            etykietaPodtytulu.topAnchor.constraint(equalTo: etykietaTytulu.bottomAnchor, constant: 8),
            etykietaPodtytulu.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 20),
            etykietaPodtytulu.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -20),

            // Mode container
            kontenerTrybow.topAnchor.constraint(equalTo: etykietaPodtytulu.bottomAnchor, constant: 40),
            kontenerTrybow.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 20),
            kontenerTrybow.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -20),
            kontenerTrybow.heightAnchor.constraint(equalToConstant: 280),

            // Easy button
            przyciskLatwyTryb.topAnchor.constraint(equalTo: kontenerTrybow.topAnchor, constant: 20),
            przyciskLatwyTryb.leadingAnchor.constraint(equalTo: kontenerTrybow.leadingAnchor, constant: 20),
            przyciskLatwyTryb.trailingAnchor.constraint(equalTo: kontenerTrybow.trailingAnchor, constant: -20),
            przyciskLatwyTryb.heightAnchor.constraint(equalToConstant: 110),

            // Hard button
            przyciskTrudnyTryb.topAnchor.constraint(equalTo: przyciskLatwyTryb.bottomAnchor, constant: 20),
            przyciskTrudnyTryb.leadingAnchor.constraint(equalTo: kontenerTrybow.leadingAnchor, constant: 20),
            przyciskTrudnyTryb.trailingAnchor.constraint(equalTo: kontenerTrybow.trailingAnchor, constant: -20),
            przyciskTrudnyTryb.heightAnchor.constraint(equalToConstant: 110),

            // Total score
            etykietaCalkowitychPunktow.topAnchor.constraint(equalTo: kontenerTrybow.bottomAnchor, constant: 30),
            etykietaCalkowitychPunktow.centerXAnchor.constraint(equalTo: kontenerTresci.centerXAnchor),

            wartoscCalkowitychPunktow.topAnchor.constraint(equalTo: etykietaCalkowitychPunktow.bottomAnchor, constant: 4),
            wartoscCalkowitychPunktow.centerXAnchor.constraint(equalTo: kontenerTresci.centerXAnchor),

            // Menu buttons
            przyciskTabelaWynikow.topAnchor.constraint(equalTo: wartoscCalkowitychPunktow.bottomAnchor, constant: 30),
            przyciskTabelaWynikow.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 20),
            przyciskTabelaWynikow.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -20),
            przyciskTabelaWynikow.heightAnchor.constraint(equalToConstant: 50),

            przyciskJakGrac.topAnchor.constraint(equalTo: przyciskTabelaWynikow.bottomAnchor, constant: 12),
            przyciskJakGrac.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 20),
            przyciskJakGrac.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -20),
            przyciskJakGrac.heightAnchor.constraint(equalToConstant: 50),

            przyciskOpinia.topAnchor.constraint(equalTo: przyciskJakGrac.bottomAnchor, constant: 12),
            przyciskOpinia.leadingAnchor.constraint(equalTo: kontenerTresci.leadingAnchor, constant: 20),
            przyciskOpinia.trailingAnchor.constraint(equalTo: kontenerTresci.trailingAnchor, constant: -20),
            przyciskOpinia.heightAnchor.constraint(equalToConstant: 50),
            przyciskOpinia.bottomAnchor.constraint(equalTo: kontenerTresci.bottomAnchor, constant: -30)
        ])
    }

    // MARK: - Actions

    @objc private func rozpocznijLatwyTryb() {
        rozpocznijGre(poziom: .latwy)
    }

    @objc private func rozpocznijTrudnyTryb() {
        rozpocznijGre(poziom: .trudny)
    }

    private func rozpocznijGre(poziom: PoziomTrudnosci) {
        let kontrolerGry = KontrolerEkranuGry(poziom: poziom)
        kontrolerGry.modalPresentationStyle = .fullScreen
        present(kontrolerGry, animated: true)
    }

    @objc private func pokazTabelaWynikow() {
        let kontroler = KontrolerTabeliWynikow()
        kontroler.modalPresentationStyle = .pageSheet
        present(kontroler, animated: true)
    }

    @objc private func pokazInstrukcje() {
        let instrukcje = """
        HOW TO PLAY

        🎯 Objective:
        Fill in the missing tiles to complete the original combination.

        📋 Rules:
        • Easy Mode: 6 tiles, 3 missing
        • Hard Mode: 8 tiles, 4 missing

        🎮 Gameplay:
        1. Observe the board with empty slots
        2. Select tiles from your hand
        3. Place them in the correct positions
        4. Check your arrangement
        5. Learn from mistakes and try again!

        ⭐ Scoring:
        • Fewer attempts = Higher score
        • Complete challenges to climb the leaderboard!

        Good luck!
        """

        let dialog = NiestandardoweOknoDialogowe()
        dialog.konfiguruj(
            tytul: "Instructions",
            wiadomosc: instrukcje,
            akcje: [(tytul: "Got it!", styl: .podstawowy, akcja: nil)]
        )
        dialog.pokaz(w: view)
    }

    @objc private func pokazFormularzOpinii() {
        let kontroler = KontrolerFormularzaOpinii()
        kontroler.modalPresentationStyle = .pageSheet
        present(kontroler, animated: true)
    }

    @objc private func animujNacisniecie(_ przycisk: UIButton) {
        UIView.animate(withDuration: 0.1) {
            przycisk.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func animujZwolnienie(_ przycisk: UIButton) {
        UIView.animate(withDuration: 0.1) {
            przycisk.transform = .identity
        }
    }

    private func aktualizujPunkty() {
        let punkty = MenadzerGry.wspoldzielony.pobierzCalkowitePunkty()
        wartoscCalkowitychPunktow.text = "\(punkty)"
    }
}
