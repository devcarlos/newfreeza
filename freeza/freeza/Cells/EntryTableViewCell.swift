import UIKit

class EntryTableViewCell: UITableViewCell {
    static let cellId = "EntryTableViewCell"

    var entry: EntryViewModel? {
        didSet {
            self.configureForEntry()
        }
    }

    @IBOutlet private var thumbnailButton: UIButton!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var commentsCountLabel: UILabel!
    @IBOutlet private var ageLabel: UILabel!
    @IBOutlet private var entryTitleLabel: UILabel!

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

        entry.loadThumbnail { [weak self] in
            self?.thumbnailButton.setImage(entry.thumbnail, for: [])
        }

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

            let nsfwLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            nsfwLabel.frame = self.thumbnailButton.bounds
            nsfwLabel.textAlignment = NSTextAlignment.center
            nsfwLabel.text = "NSFW"
            nsfwLabel.textColor = .lightGray
            nsfwLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            nsfwLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.thumbnailButton.addSubview(nsfwLabel)
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
}
