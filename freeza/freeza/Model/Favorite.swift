//
//  Favorite.swift
//  freeza
//
//  Created by Carlos Alcala on 1/11/21.
//  Copyright © 2021 Zerously. All rights reserved.
//

import Foundation
import RealmSwift

final class Favorite: Object {
    @objc dynamic var title: String?
    @objc dynamic var author: String?
    @objc dynamic var creation: Date?
    @objc dynamic var thumbnailURL: String?
    @objc dynamic var commentsCount: Int = 0
    @objc dynamic var over18: Bool = false
    @objc dynamic var url: String?
}

extension Favorite {
    convenience init(entry: EntryModel) {
        self.init()

        self.title = entry.title
        self.author = entry.author
        self.creation = entry.creation
        self.thumbnailURL = entry.thumbnailURL?.absoluteString
        self.commentsCount = entry.commentsCount ?? 0
        self.over18 = entry.over18 ?? false
        self.url = entry.url?.absoluteString
    }
}
