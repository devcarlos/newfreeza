import UIKit

protocol EntryTableViewCellProtocol: AnyObject {
    func didUpdateFavorites()
}

class EntryTableViewCell: UITableViewCell {
    static let cellId = "EntryTableViewCell"

    weak var delegate: EntryTableViewCellProtocol?

    var entry: EntryViewModel? {
        didSet {
            self.configureForEntry()
        }
    }

    var isFavorite: Bool = false {
        didSet {
            let named = isFavorite ? "heart-filled" : "heart"
            let image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
            favoriteButton.setImage(image, for: .normal)
            favoriteButton.tintColor = isFavorite ? .red : .black
        }
    }

    @IBOutlet private var thumbnailButton: UIButton!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var commentsCountLabel: UILabel!
    @IBOutlet private var ageLabel: UILabel!
    @IBOutlet private var entryTitleLabel: UILabel!
    @IBOutlet private var favoriteButton: UIButton!

    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureViews()
    }

    private func configureViews() {
        func configureThumbnailImageView() {
            self.thumbnailButton.layer.borderColor = UIColor.black.cgColor
            self.thumbnailButton.layer.borderWidth = 1
        }

        func configureCommentsCountLabel() {
            self.commentsCountLabel.layer.cornerRadius = self.commentsCountLabel.bounds.size.height / 2
        }

        configureThumbnailImageView()
        configureCommentsCountLabel()
    }

    private func configureForEntry() {
        guard let entry = self.entry else {
            return
        }

        self.thumbnailButton.setImage(entry.thumbnail, for: [])
        self.authorLabel.text = entry.author
        self.commentsCountLabel.text = entry.commentsCount
        self.ageLabel.text = entry.age
        self.entryTitleLabel.text = entry.title
        self.favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)

        entry.loadThumbnail { [weak self] in
            self?.thumbnailButton.setImage(entry.thumbnail, for: [])
        }

        isFavorite = checkFavorite()

        if entry.over18 {
            if #available(iOS 10.0, *) {
                let blur = UIBlurEffect(style: .regular)
                let blurView = UIVisualEffectView(effect: blur)
                blurView.frame = self.thumbnailButton.bounds
                blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.thumbnailButton.addSubview(blurView)
            } else {
                let blurView = UIView()
                blurView.backgroundColor = .black
                blurView.alpha = 0.3
                blurView.frame = self.thumbnailButton.bounds
                blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.thumbnailButton.addSubview(blurView)
            }

            let nsfwImage = UIImage(named: "NSFW")
            let nsfwBadge = UIImageView(image: nsfwImage)
            let side: CGFloat = 36
            nsfwBadge.frame = CGRect(x: self.thumbnailButton.frame.size.width/2 - side/2, y: self.thumbnailButton.frame.size.height/2 - side/2, width: side, height: side)
            nsfwBadge.contentMode = .scaleAspectFill
            self.thumbnailButton.addSubview(nsfwBadge)
        }
    }
}

extension EntryTableViewCell  {
    func doShake() {
        guard let entry = entry else {
            return
        }
        
        if entry.over18 {
            if #available(iOS 10.0, *) {
                self.contentView.shakev1()
            } else {
                self.contentView.shakev2()
            }
        }
    }

    @objc
    func toggleFavorite() {
        isFavorite.toggle()
        isFavorite ? saveFavorite() : deleteFavorite()

        delegate?.didUpdateFavorites()
    }

    func saveFavorite() {
        guard let entry = self.entry else {
            return
        }

        let favorite = Favorite(entry: entry.model)
        Persistence.shared.createOrUpdate(object: favorite)
    }

    func deleteFavorite() {
        guard let entry = self.entry else {
            return
        }

        let predicate = NSPredicate(format: "title = %@", entry.model.title ?? "")

        let favorites = Persistence.shared.fetch(with: predicate, sortDescriptors: [])

        guard let favorite = favorites.first else {
            return
        }

        Persistence.shared.delete(object: favorite)
    }

    func checkFavorite() -> Bool {
        guard let entry = self.entry else {
            return false
        }

        let favorite = Favorite(entry: entry.model)
        let predicate = NSPredicate(format: "title = %@", favorite.title ?? "")
        let favorites = Persistence.shared.fetch(with: predicate, sortDescriptors: [])

        return favorites.count == 1
    }
}
