//
//  Persistence.swift
//  freeza
//
//  Created by Carlos Alcala on 1/11/21.
//  Copyright © 2021 Zerously. All rights reserved.
//

import Foundation
import RealmSwift

final class Persistence {
    private let realm: Realm

    static let shared = Persistence()

    private init() {
        self.realm = try! Realm()

    }

    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }

    func createOrUpdate(object: Favorite) {
        try! realm.write {
            realm.add(object)
        }
    }

    func fetch(with predicate: NSPredicate?, sortDescriptors: [SortDescriptor]) -> Results<Favorite> {
        var results = realm.objects(Favorite.self)
        if let predicate = predicate {
            results = results.filter(predicate)
        }
        if sortDescriptors.count > 0 {
            results = results.sorted(by: sortDescriptors)
        }
        return results
    }

    func delete(object: Favorite) {
        try! realm.write {
            realm.delete(object)
        }
    }

    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}
