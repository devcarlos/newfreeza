import Foundation
import UIKit
import RealmSwift

class TopEntriesViewController: UITableViewController {

    @IBOutlet weak var safeButton: UIBarButtonItem!

    let viewModel = TopEntriesViewModel(withClient: RedditClient())
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let errorLabel = UILabel()
    let tableFooterView = UIView()
    let moreButton = UIButton(type: .system)
    var urlToDisplay: URL?

    var isSafeEnabled: Bool = true {
        didSet {
            let named = isSafeEnabled ? "safe-on" : "safe-off"
            safeButton.image = UIImage(named: named)
            safeButton.tintColor = isSafeEnabled ? .red : .black
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureViews()
        self.loadEntries()

        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadEntries()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { [weak self] _ in

            self?.configureErrorLabelFrame()

        }, completion: nil)
    }

    @objc func retryFromErrorToolbar() {
        self.loadEntries()
        self.dismissErrorToolbar()
    }

    @objc func dismissErrorToolbar() {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }

    @objc func moreButtonTapped() {
        self.moreButton.isEnabled = false
        self.loadEntries()
    }

    private func loadEntries() {
        self.activityIndicatorView.startAnimating()
        self.viewModel.loadEntries {
            self.entriesReloaded()
        }
    }

    private func configureViews() {
        func configureNavBar() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicatorView)
            isSafeEnabled = UserDefaults().bool(forKey: "SAFE_ENABLED")
        }

        func configureTableView() {
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 110.0

            self.tableFooterView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 80)
            self.tableFooterView.addSubview(self.moreButton)

            self.moreButton.frame = self.tableFooterView.bounds
            self.moreButton.setTitle("More...", for: [])
            self.moreButton.setTitle("Loading...", for: .disabled)
            self.moreButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            self.moreButton.addTarget(self, action: #selector(TopEntriesViewController.moreButtonTapped), for: .touchUpInside)
        }

        func configureToolbar() {
            self.configureErrorLabelFrame()

            let errorItem = UIBarButtonItem(customView: self.errorLabel)
            let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let retryItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(TopEntriesViewController.retryFromErrorToolbar))
            let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            let closeItem = UIBarButtonItem(image: UIImage(named: "close-button"), style: .plain, target: self, action: #selector(TopEntriesViewController.dismissErrorToolbar))

            fixedSpaceItem.width = 12

            self.toolbarItems = [errorItem, flexSpaceItem, retryItem, fixedSpaceItem, closeItem]
        }

        configureNavBar()
        configureTableView()
        configureToolbar()
    }

    private func configureErrorLabelFrame() {
        self.errorLabel.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width - 92, height: 22)
    }

    private func entriesReloaded() {
        self.activityIndicatorView.stopAnimating()
        self.tableView.reloadData()

        self.tableView.tableFooterView = self.tableFooterView
        self.moreButton.isEnabled = true

        if self.viewModel.hasError {
            self.errorLabel.text = self.viewModel.errorMessage
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
    }

    @IBAction func safeAction(_ sender: UIBarButtonItem) {
        safeToggle()
    }
}

extension TopEntriesViewController { // UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entryTableViewCell = tableView.dequeueReusableCell(withIdentifier: EntryTableViewCell.cellId, for: indexPath as IndexPath) as! EntryTableViewCell

        entryTableViewCell.entry = self.viewModel.entries[indexPath.row]
        entryTableViewCell.isUserInteractionEnabled = true

        return entryTableViewCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = self.viewModel.entries[indexPath.row]

        let entryTableViewCell: EntryTableViewCell = tableView.cellForRow(at: indexPath) as! EntryTableViewCell

        if entry.over18 && isSafeEnabled {
            entryTableViewCell.doShake()
            return
        }

        if let url = entry.url {
            self.presentImage(withURL: url)
        }
    }
}

extension TopEntriesViewController {
    func presentImage(withURL url: URL) {
        self.urlToDisplay = url

        guard let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "URLViewController") as? URLViewController else {
            return
        }
        vc.url = self.urlToDisplay
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func safeToggle()  {
        isSafeEnabled.toggle()
        UserDefaults().set(isSafeEnabled, forKey: "SAFE_ENABLED")
    }
}
