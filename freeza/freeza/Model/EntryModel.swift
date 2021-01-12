import Foundation

struct EntryModel {
    let title: String?
    let author: String?
    let creation: Date?
    let thumbnailURL: URL?
    let commentsCount: Int?
    let over18: Bool?
    let url: URL?

    init(object: Favorite) {
        self.title = object.title
        self.author = object.author
        self.creation = object.creation
        self.thumbnailURL = URL(string: object.thumbnailURL ?? "")
        self.commentsCount = object.commentsCount
        self.over18 = object.over18
        self.url = URL(string: object.url ?? "")
    }

    init(withDictionary dictionary: [String: AnyObject]) {
        func dateFromDictionary(withAttributeName attribute: String) -> Date? {
            guard let rawDate = dictionary[attribute] as? Double else {
                return nil
            }

            return Date(timeIntervalSince1970: rawDate)
        }

        func urlFromDictionary(withAttributeName attribute: String) -> URL? {
            guard let rawURL = dictionary[attribute] as? String else {
                return nil
            }

            return URL(string: rawURL)
        }

        self.title = dictionary["title"] as? String
        self.author = dictionary["author"] as? String
        self.creation = dateFromDictionary(withAttributeName: "created_utc")
        self.thumbnailURL = urlFromDictionary(withAttributeName: "thumbnail")
        self.commentsCount = dictionary["num_comments"] as? Int
        self.over18 = dictionary["over_18"] as? Bool
        self.url = urlFromDictionary(withAttributeName: "url")
    }
}

// MARK: - Seed Data
extension EntryModel {
    static let entry1: EntryModel = EntryModel(withDictionary: [
        "title": "Big Little Lies" as AnyObject,
        "author": "Carlos Alcala" as AnyObject,
        "created_utc": NSDate().timeIntervalSince1970 as AnyObject,
        "num_comments": 100 as AnyObject
    ])
    static let entry2: EntryModel = EntryModel(withDictionary: [
        "title": "South and West" as AnyObject,
        "author": "Carlos Alcala" as AnyObject,
        "created_utc": NSDate().timeIntervalSince1970 as AnyObject,
        "num_comments": 200 as AnyObject
    ])
    static let entry3: EntryModel = EntryModel(withDictionary: [
        "title": "Testing Entry" as AnyObject,
        "author": "Carlos Alcala" as AnyObject,
        "created_utc": NSDate().timeIntervalSince1970 as AnyObject,
        "num_comments": 300 as AnyObject
    ])
}
