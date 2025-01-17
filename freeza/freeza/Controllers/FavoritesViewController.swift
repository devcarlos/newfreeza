import Foundation
import UIKit
import RealmSwift

class FavoritesViewController: UITableViewController {
    let viewModel = FavoritesViewModel()
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let errorLabel = UILabel()
    let tableFooterView = UIView()
    var urlToDisplay: URL?

    var isSafeEnabled: Bool = UserDefaults().bool(forKey: "SAFE_ENABLED")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureViews()
        self.loadEntries()
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

    private func loadEntries() {
        self.activityIndicatorView.startAnimating()
        self.viewModel.loadEntries {
            self.entriesReloaded()
        }
    }

    private func configureViews() {
        func configureActivityIndicatorView() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicatorView)
        }

        func configureTableView() {
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 110.0
        }

        func configureToolbar() {
            self.configureErrorLabelFrame()

            let errorItem = UIBarButtonItem(customView: self.errorLabel)
            let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let retryItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(FavoritesViewController.retryFromErrorToolbar))
            let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            let closeItem = UIBarButtonItem(image: UIImage(named: "close-button"), style: .plain, target: self, action: #selector(FavoritesViewController.dismissErrorToolbar))

            fixedSpaceItem.width = 12

            self.toolbarItems = [errorItem, flexSpaceItem, retryItem, fixedSpaceItem, closeItem]
        }

        configureActivityIndicatorView()
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

        if self.viewModel.hasError {
            self.errorLabel.text = self.viewModel.errorMessage
            self.navigationController?.setToolbarHidden(false, animated: true)
        }
    }
}

extension FavoritesViewController { // UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let entryTableViewCell = tableView.dequeueReusableCell(withIdentifier: EntryTableViewCell.cellId, for: indexPath as IndexPath) as! EntryTableViewCell

        entryTableViewCell.entry = self.viewModel.entries[indexPath.row]
        entryTableViewCell.isUserInteractionEnabled = true
        entryTableViewCell.delegate = self

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

extension FavoritesViewController {
    func presentImage(withURL url: URL) {
        self.urlToDisplay = url

        guard let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "URLViewController") as? URLViewController else {
            return
        }
        vc.url = self.urlToDisplay
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension FavoritesViewController: EntryTableViewCellProtocol {
    func didUpdateFavorites() {
        self.loadEntries()
    }
}
