import Foundation
import UIKit

class EntryViewModel {
    var hasError = false
    var errorMessage: String?

    let title: String
    let author: String

    let over18: Bool

    var age: String {
        guard let creation = self.creation else {
            return "---"
        }

        return creation.age()
    }

    var model: EntryModel

    var thumbnail: UIImage
    let commentsCount: String
    let url: URL?

    private let creation: Date?
    private let thumbnailURL: URL?
    private var thumbnailFetched = false

    init(withModel model: EntryModel) {
        func markAsMissingRequiredField() {
            self.hasError = true
            self.errorMessage = "Missing required field"
        }

        self.model = model
        self.title = model.title ?? "Untitled"
        self.author = model.author ?? "Anonymous"
        self.thumbnailURL = model.thumbnailURL
        self.thumbnail = UIImage(named: "thumbnail-placeholder")!
        self.commentsCount = " \(model.commentsCount ?? 0) " // Leave space for the rounded corner. I know, not cool, but does the trick.
        self.creation = model.creation
        self.url = model.url
        self.over18 = model.over18 ?? false

        if model.title == nil ||
            model.author == nil ||
            model.creation == nil ||
            model.commentsCount == nil {
            markAsMissingRequiredField()
        }
    }

    func loadThumbnail(withCompletion completion: @escaping () -> ()) {
        guard let thumbnailURL = self.thumbnailURL, self.thumbnailFetched == false else {
            return
        }

        let downloadThumbnailTask = URLSession.shared.downloadTask(with: thumbnailURL) { [weak self] url, _, _ in

            guard let strongSelf = self,
                let url = url,
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) else {
                return
            }

            strongSelf.thumbnail = image
            strongSelf.thumbnailFetched = true

            DispatchQueue.main.async {
                completion()
            }
        }

        downloadThumbnailTask.resume()
    }
}
